// Actual installed Pi loader and exec API; no replacement TypeScript transpiler.
import assert from 'node:assert/strict';
import childProcess from 'node:child_process';
import { EventEmitter } from 'node:events';
import { existsSync } from 'node:fs';
import { createRequire, syncBuiltinESMExports } from 'node:module';
import { dirname, join, resolve } from 'node:path';
import { PassThrough } from 'node:stream';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { test } from 'node:test';

process.env.JITI_FS_CACHE = 'false';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '../../..');
const extension = join(root, '.pi/extensions/wc3-workshop.ts');
const cli = join(root, 'tools/wc3-workshop/wc3.py');
const kinds = ['unit', 'item', 'ability', 'destructable', 'doodad', 'buff', 'upgrade'];

function installedPi() {
  if (process.env.WC3_PI_PACKAGE_DIR) return resolve(process.env.WC3_PI_PACKAGE_DIR);
  const agent = process.env.PI_CODING_AGENT_DIR;
  const anchors = [import.meta.url];
  if (agent) {
    anchors.push(pathToFileURL(join(agent, 'npm/package.json')),
                 pathToFileURL(resolve(agent, '../current/package.json')));
  }
  for (const anchor of anchors) {
    // Pi is import-only; inspect normal package search locations without using
    // require.resolve() on its import-only public export.
    const locations = createRequire(anchor).resolve.paths('@earendil-works/pi-coding-agent') ?? [];
    for (const location of locations) {
      const candidate = join(location, '@earendil-works/pi-coding-agent');
      if (existsSync(join(candidate, 'dist/core/extensions/loader.js'))) return candidate;
    }
  }
  throw new Error('Installed Pi unavailable: set WC3_PI_PACKAGE_DIR to its package directory.');
}

const piDir = installedPi();
const { loadExtensions } = await import(pathToFileURL(join(piDir, 'dist/core/extensions/loader.js')));
const loaded = await loadExtensions([extension], root);
function tool() {
  assert.deepEqual(loaded.errors, [], 'Actual installed Pi must load the extension');
  assert.equal(loaded.extensions.length, 1);
  return loaded.extensions[0].tools.get('wc3_workshop').definition;
}
const invoke = (params, signal) => tool().execute('test-call', params, signal, undefined, {});
const envelope = (action, ok = true) => ({
  schema_version: 1, ok, action, target: 'Warcraft III Classic 1.27b',
  evidence: ok ? 'Scanned' : 'Rejected', limitations: ['Static evidence only.'],
  result: ok ? { sample: true } : null,
  error: ok ? null : { code: 'path', message: 'Rejected project path.' },
});

function mockSpawn(t, respond) {
  const calls = [];
  t.mock.method(childProcess, 'spawn', (command, argv, options) => {
    const proc = new EventEmitter();
    proc.stdout = new PassThrough();
    proc.stderr = new PassThrough();
    proc.killed = false;
    proc.kill = () => {
      proc.killed = true;
      queueMicrotask(() => proc.emit('close', null));
      return true;
    };
    calls.push({ command, argv, options, proc });
    queueMicrotask(() => {
      const response = respond(argv, proc);
      if (!response) return;
      if (response.error) return proc.emit('error', new Error('private spawn diagnostic'));
      proc.stdout.write(response.stdout ?? JSON.stringify(envelope(argv[2])) + '\n');
      proc.stderr.write(response.stderr ?? '');
      proc.emit('close', response.code ?? 0);
    });
    return proc;
  });
  syncBuiltinESMExports();
  t.after(() => {
    t.mock.restoreAll();
    syncBuiltinESMExports();
  });
  return calls;
}

function expectedError(code) {
  return { message: `[wc3_workshop:${code}] ${ {
    arguments: 'Invalid action, fields or action-specific arguments.',
    cancelled: 'Inspection cancelled.',
    deadline: 'Inspection exceeded its execution deadline.',
    output: 'Inspector output exceeds the tool limit; inspect a narrower input.',
    protocol: 'Inspector returned an invalid evidence envelope.',
    process: 'Inspector process failed without valid rejection evidence.',
  }[code]}` };
}

test('actual Pi loader registers one read-only Classic tool and typed schema', () => {
  const definition = tool();
  assert.deepEqual([...loaded.extensions[0].tools.keys()], ['wc3_workshop']);
  assert.equal(loaded.extensions[0].handlers.size, 0);
  assert.equal(definition.parameters.type, 'object');
  assert.deepEqual(definition.parameters.required, ['action']);
  assert.equal(definition.parameters.additionalProperties, false);
  assert.deepEqual(definition.parameters.properties.action.anyOf.map(x => x.const),
                   ['doctor', 'sources', 'objects', 'imports']);
  assert.deepEqual(definition.parameters.properties.kind.anyOf.map(x => x.const), kinds);
  assert.deepEqual(definition.annotations, { readOnlyHint: true, destructiveHint: false,
                                            idempotentHint: true, openWorldHint: false });
  assert.match(definition.description, /1\.27b/);
});

test('dispatch uses exact fixed executable, explicit argv, cwd and bounded timeout', async t => {
  const calls = mockSpawn(t, () => ({}));
  const special = 'projects/a ;$(touch nope) "quoted".j';
  const cases = [
    [{ action: 'doctor' }, ['doctor']],
    [{ action: 'doctor', config: special }, ['doctor', '--config=' + special]],
    [{ action: 'sources', path: special }, ['sources', '--', special]],
    [{ action: 'imports', path: '--help' }, ['imports', '--', '--help']],
    ...kinds.map(kind => [{ action: 'objects', kind, path: special }, ['objects', kind, '--', special]]),
  ];
  for (const [params, tail] of cases) {
    const result = await invoke(params);
    const call = calls.at(-1);
    assert.equal(call.command, '/usr/bin/python3');
    assert.deepEqual(call.argv, ['-B', cli, ...tail]);
    assert.deepEqual(call.options, { cwd: root, shell: false, stdio: ['ignore', 'pipe', 'pipe'] });
    assert.deepEqual(result.structuredContent, envelope(params.action));
    assert.deepEqual(result.details, envelope(params.action));
    assert.deepEqual(result.content, [{ type: 'text', text: JSON.stringify(envelope(params.action)) }]);
    assert.equal(result.isError, false);
  }
});

test('invalid and cross-action fields never start a process', async t => {
  const calls = mockSpawn(t, () => ({}));
  for (const params of [null, { action: 'compile' }, { action: 'sources' },
    { action: 'doctor', path: 'x' }, { action: 'sources', path: 'x', config: 'x' },
    { action: 'objects', path: 'x', kind: 'unknown' }, { action: 'imports', path: '' },
    { action: 'imports', path: 'x', kind: 'unit' }, { action: 'doctor', command: 'evil' },
    { action: 'doctor', config: 'x'.repeat(4097) }, { action: 'sources', path: 'x\0y' }]) {
    await assert.rejects(invoke(params), expectedError('arguments'));
  }
  assert.equal(calls.length, 0);
});

test('valid nonzero CLI rejection is an error result preserving its envelope', async t => {
  mockSpawn(t, argv => ({ code: 2, stdout: JSON.stringify(envelope(argv[2], false)) }));
  const result = await invoke({ action: 'sources', path: '../outside.j' });
  assert.equal(result.isError, true);
  assert.deepEqual(result.structuredContent, envelope('sources', false));
  assert.deepEqual(result.details, envelope('sources', false));
  assert.deepEqual(result.content, [{ type: 'text', text: JSON.stringify(envelope('sources', false)) }]);
});

test('malformed JSON, mismatched envelopes and unexpected stderr fail closed', async t => {
  let response;
  mockSpawn(t, () => response);
  for (response of [
    { stdout: '{bad' }, { stdout: 'null' }, { stdout: '{}' },
    { stdout: JSON.stringify(envelope('imports')) },
    { stdout: JSON.stringify({ ...envelope('doctor'), evidence: 'Compiled' }) },
    { stdout: JSON.stringify(envelope('doctor')), stderr: 'unexpected diagnostic' },
    { stdout: JSON.stringify(envelope('doctor', false)), code: 0 },
  ]) await assert.rejects(invoke({ action: 'doctor' }), expectedError('protocol'));
  response = { code: 1, stdout: 'private diagnostic' };
  await assert.rejects(invoke({ action: 'doctor' }), expectedError('process'));
  response = { error: true };
  await assert.rejects(invoke({ action: 'doctor' }), expectedError('process'));
});

test('large stdout or stderr is rejected without echoing process data', async t => {
  let response = { stdout: 'x'.repeat(64 * 1024 + 1) };
  mockSpawn(t, () => response);
  await assert.rejects(invoke({ action: 'doctor' }), expectedError('output'));
  response = { stderr: 's'.repeat(64 * 1024 + 1) };
  await assert.rejects(invoke({ action: 'doctor' }), expectedError('output'));
});

test('cancellation before and during execution propagates without success', async t => {
  t.mock.timers.enable({ apis: ['setTimeout'] });
  const calls = mockSpawn(t, () => undefined);
  const before = new AbortController();
  before.abort();
  await assert.rejects(invoke({ action: 'doctor' }, before.signal), expectedError('cancelled'));
  assert.equal(calls.length, 0);
  const during = new AbortController();
  const pending = invoke({ action: 'doctor' }, during.signal);
  during.abort();
  await assert.rejects(pending, expectedError('cancelled'));
  assert.equal(calls[0].proc.killed, true);
});

test('installed exec deadline terminates the process and reports failure', async t => {
  t.mock.timers.enable({ apis: ['setTimeout'] });
  const calls = mockSpawn(t, () => undefined);
  const pending = invoke({ action: 'doctor' });
  t.mock.timers.tick(10_000);
  await assert.rejects(pending, expectedError('deadline'));
  assert.equal(calls[0].proc.killed, true);
});

test('actual local CLI doctor and suite-owned source smoke through installed Pi exec', async () => {
  const doctor = await invoke({ action: 'doctor' });
  assert.equal(doctor.isError, false);
  assert.equal(doctor.structuredContent.result.execution_verified, false);
  const fixture = 'tools/wc3-workshop/tests/fixtures/Smoke.j';
  const source = await invoke({ action: 'sources', path: fixture });
  assert.equal(source.isError, false);
  assert.equal(source.structuredContent.evidence, 'Scanned');
  assert.equal(source.structuredContent.result.files[0].path, fixture);
  assert.deepEqual(source.structuredContent.result.files[0].declarations,
                   [{ kind: 'function', name: 'WorkshopSmoke', line: 2 }]);
  const rejected = await invoke({ action: 'imports', path: '/etc/passwd' });
  assert.equal(rejected.isError, true);
  assert.equal(rejected.structuredContent.error.code, 'path');
});
