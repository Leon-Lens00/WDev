// Restore the map and exact camera saved before a read-only capture session.
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
const [exe, pid, saved, output] = process.argv.slice(2);
const before = JSON.parse(await readFile(saved, 'utf8'));
const client = new Client({ name: 'terrain-restore-session', version: '1' });
const transport = new StdioClientTransport({ command: resolve(exe), args: ['--mcp'], stderr: 'pipe' });
async function call(name, args = {}) {
  const result = await client.callTool({ name, arguments: args });
  if (result.isError) throw Error(name + ': ' + JSON.stringify(result.content));
  return JSON.parse(result.content.find(c => c.type === 'text').text);
}
try {
  await client.connect(transport);
  await call('session_select', { pid: Number(pid) });
  const generation = (await call('diagnostics_get')).diagnostics.scene.loadGeneration;
  await call('map_open', { path: before.map.path });
  let loaded = false;
  for (let i = 0; i < 100; i++) {
    const d = (await call('diagnostics_get')).diagnostics.scene;
    if (d.loadGeneration > generation && !d.loadingMap) { loaded = true; break; }
    await new Promise(r => setTimeout(r, 200));
  }
  if (!loaded) throw Error('Map load was not acknowledged');
  await call('camera_set_state', before.camera.state);
  const after = await call('camera_get_state');
  if (after.map.path !== before.map.path) throw Error('Map was not restored');
  for (const [key, value] of Object.entries(before.camera.state)) {
    if (after.state[key] !== value) throw Error('Camera mismatch: ' + key);
  }
  await writeFile(output, JSON.stringify({ restored: true, pid: Number(pid), after }, null, 2));
  console.log('Map and camera restored');
} finally { await client.close(); }
