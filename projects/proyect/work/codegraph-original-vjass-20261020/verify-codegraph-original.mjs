import { Client } from '/home/snz/Documentos/MCP W3/wc3-forge/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js';
import { StdioClientTransport } from '/home/snz/Documentos/MCP W3/wc3-forge/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js';
import assert from 'node:assert/strict';
import { writeFile, unlink, readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';

const root = '/home/snz/Documentos/ChatGPT/Proyect/work/codegraph-original-vjass-20261020/small';
const globalMode = process.argv.includes('--global-config');
const original = createHash('sha256').update(await readFile(`${root}/probe.vjass`)).digest('hex');
const transport = new StdioClientTransport({
  command: '/home/snz/.local/bin/codegraph',
  args: globalMode ? ['serve', '--mcp'] : ['serve', '--mcp', '--path', root],
  cwd: '/home/snz/Documentos/ChatGPT/Proyect',
  env: { CODEGRAPH_DAEMON_IDLE_TIMEOUT_MS: '1000' }, stderr: 'pipe',
});
const client = new Client({ name: 'wc3-original-codegraph-verification', version: '1.0.0' });
let stderr = '';
transport.stderr.on('data', b => { stderr += b.toString(); });
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
const invoke = async query => {
  const response = await client.callTool({ name: 'codegraph_explore', arguments: { query, ...(globalMode ? { projectPath: root } : {}) } });
  assert.ok(!response.isError, JSON.stringify(response));
  return response.content.map(c => c.text ?? '').join('\n');
};
try {
  await client.connect(transport);
  const server = client.getServerVersion();
  assert.ok(server.version.includes('jass-vjass'), JSON.stringify(server));
  const listed = await client.listTools();
  assert.deepEqual(listed.tools.map(t => t.name), ['codegraph_explore']);
  const text = await invoke('CodeGraphProbe.Init CodeGraphProbe.Ping');
  assert.ok(text.includes('JASS/vJASS local support'));
  assert.ok(text.includes('call Ping()'));
  await writeFile(`${root}/watch-probe.jass`, 'function WatchTarget takes nothing returns nothing\nendfunction\nfunction WatchProbe takes nothing returns nothing\n call WatchTarget()\nendfunction\n');
  let watched = '';
  const start = performance.now();
  while (performance.now() - start < 15000) {
    await sleep(250);
    watched = await invoke('WatchProbe WatchTarget');
    if (watched.includes('call WatchTarget()')) break;
  }
  assert.ok(watched.includes('call WatchTarget()'), 'watcher failed to index added .jass source');
  const addMs = Math.round(performance.now() - start);
  await unlink(`${root}/watch-probe.jass`);
  let removed = false;
  const removedStart = performance.now();
  while (performance.now() - removedStart < 15000) {
    await sleep(250);
    const answer = await invoke('WatchProbe');
    if (!answer.includes('function WatchProbe')) { removed = true; break; }
  }
  assert.ok(removed, 'watcher retained removed source');
  assert.equal(createHash('sha256').update(await readFile(`${root}/probe.vjass`)).digest('hex'), original);
  console.log(JSON.stringify({ server, global_config_command: globalMode, client: '@modelcontextprotocol/sdk 1.29.0',
    tools: listed.tools.map(t => t.name), original_explore_passed: true,
    watcher_jass_add_passed: true, watcher_add_observed_ms: addMs,
    watcher_jass_remove_passed: true, original_source_hash_unchanged: true,
    response_chars: text.length, stderr,
  }, null, 2));
} finally {
  await unlink(`${root}/watch-probe.jass`).catch(() => {});
  await client.close();
}
