import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';

assert(process.argv[2], 'Pass the probe directory');
const root = path.resolve(process.argv[2]);
const input = JSON.parse(fs.readFileSync(path.join(root, 'inputs.json')));
const client = new Client({ name: 'codex-wc3-integration-probe', version: '1.0.0' });
const transport = new StdioClientTransport({
  command: process.execPath, args: [path.resolve('dist/index.js')],
  env: { ...process.env, WC3FORGE_MCP_LOCK_DIR: path.join(root, 'locks') }, stderr: 'pipe',
});
const evidence = { passed: false, mode: 'actual MCP stdio -> wc3-forge bridge -> forge.Session',
  fixture: 'synthetic Classic-format map and minimal test metadata; not native installation tables',
  gui_test: false, in_game_test: false, playable_map: false, calls: [] };
const record = () => fs.writeFileSync(path.join(root, 'integration-result.json'), JSON.stringify(evidence, null, 2));
async function call(name, args = {}) {
  const result = await client.callTool({ name, arguments: args });
  const text = result.content?.filter(x => x.type === 'text').map(x => x.text).join('\n');
  let value; try { value = JSON.parse(text); } catch { value = text; }
  const safe = { ...args }; if (safe.data_base64) safe.data_base64 = `[${safe.data_base64.length} base64 characters omitted]`;
  evidence.calls.push({ name, args: safe, isError: !!result.isError, result: value }); record();
  assert(!result.isError, `${name}: ${text}`); return value;
}
function entities(result) { return result.entities ?? result.units ?? result.items ?? []; }
try {
  await client.connect(transport);
  evidence.tool_count = (await client.listTools()).tools.length;
  const sessions = await call('sessions_list');
  assert.equal(sessions.sessions.length, 1);
  await call('session_select', { pid: sessions.sessions[0].pid });
  await call('map_open', { path: path.join(root, 'map') });
  for (const item of input.imports) {
    const file = path.isAbsolute(item.file) ? item.file : path.resolve(root, item.file);
    await call('imports_add', { path: item.path, data_base64: fs.readFileSync(file).toString('base64') });
  }
  await call('history_begin_group', { label: 'Three infection models: MCP integration probe' });
  for (let i = 0; i < input.models.length; i++) {
    const row = input.models[i];
    await call('objects_units_create_custom', { base_id: 'hfoo', id: row.rawcode });
    for (const [column, value] of [['unam', row.key], ['umdl', row.model_path], ['udtm', String(row.death_seconds)], ['usca', '1']]) {
      await call('objects_units_set_field', { id: row.rawcode, column, value });
    }
    await call('units_create', { type_id: row.rawcode, player: 0, x: (i - 1) * 384, y: 0, z: 0, rotation: 0, scale: 1 });
  }
  await call('history_end_group');
  assert.equal(entities(await call('units_list')).length, 3);
  await call('history_undo');
  assert.equal(entities(await call('units_list')).length, 0);
  await call('history_redo');
  assert.equal(entities(await call('units_list')).length, 3);
  const map = path.join(root, 'MCP_Technical_Probe.w3x');
  await call('map_save_as', { path: map });
  await call('map_close');
  await call('map_open', { path: map });
  assert.equal(entities(await call('units_list')).length, 3);
  for (const row of input.models) await call('objects_units_get', { id: row.rawcode });
  const imports = await call('imports_list');
  assert.equal(imports.imports.length, input.imports.length);
  assert(imports.imports.every(i => i.present));
  await call('map_extract_to_folder', { path: path.join(root, 'reopened') });
  evidence.passed = true;
  evidence.models = input.models;
  evidence.imports = input.imports.map(({ file, ...rest }) => rest);
  evidence.saved_map = map;
  record();
  console.log(JSON.stringify({ passed: true, tools: evidence.tool_count, calls: evidence.calls.length, models: input.models.length, imports: input.imports.length, gui_test: false, in_game_test: false }));
} catch (err) {
  evidence.error = String(err.stack ?? err); record(); throw err;
} finally { await client.close(); }
