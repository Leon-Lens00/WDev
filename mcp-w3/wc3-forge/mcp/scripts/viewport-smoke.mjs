// Live read-only acceptance check. Arguments: editor.exe PID output-directory.
// Uses real MCP stdio, preserves camera pose, and never saves or edits the map.
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { mkdir, writeFile } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import assert from 'node:assert/strict';

const [exe, rawPID, output] = process.argv.slice(2);
if (!exe || !rawPID || !output) throw new Error('Usage: node viewport-smoke.mjs editor.exe PID output-directory');
const out = resolve(output);
await mkdir(out, { recursive: true });
const client = new Client({ name: 'wc3-forge-viewport-smoke', version: '1' });
const transport = new StdioClientTransport({ command: resolve(exe), args: ['--mcp'], stderr: 'pipe' });
const checks = [];
let original;
async function call(name, args = {}) {
  const result = await client.callTool({ name, arguments: args });
  if (result.isError) throw new Error(`${name}: ${JSON.stringify(result.content)}`);
  return result;
}
function data(result) { return JSON.parse(result.content.find(c => c.type === 'text').text); }
try {
  await client.connect(transport);
  const names = (await client.listTools()).tools.map(t => t.name);
  for (const tool of ['camera_get_state','camera_set_state','camera_frame','viewport_screenshot']) assert.ok(names.includes(tool), tool);
  await call('session_select', { pid: Number(rawPID) });
  const map = data(await call('map_status'));
  assert.equal(map.loaded, true, 'Open a disposable map before running this test');
  original = data(await call('camera_get_state')).state;
  const diag = data(await call('diagnostics_get')).diagnostics;
  const [x, y] = diag.centerOffset;
  const bounds = { min: [x, y, -256], max: [x + (diag.terrainWidth-1)*128, y + (diag.terrainHeight-1)*128, 1400] };
  for (const view of ['top','isometric','north','east','south','west']) {
    const framed = data(await call('camera_frame', { bounds, view, projection: view === 'top' ? 'orthographic' : 'perspective' }));
    if (view === 'top') { assert.equal(framed.state.pitch, Math.PI/2); assert.equal(framed.state.projection, 'orthographic'); }
    const capture = await call('viewport_screenshot', { max_width: 1280 });
    const image = capture.content.find(c => c.type === 'image');
    assert.equal(image?.mimeType, 'image/png');
    const bytes = Buffer.from(image.data, 'base64');
    assert.equal(bytes.subarray(1,4).toString(), 'PNG');
    const metadata = data(capture);
    assert.deepEqual(metadata.camera, framed.state);
    assert.ok(metadata.frame > framed.frame);
    await writeFile(join(out, `${view}.png`), bytes);
    await writeFile(join(out, `${view}.json`), JSON.stringify(metadata, null, 2));
    checks.push({ view, bytes: bytes.length, width: metadata.width, height: metadata.height });
    console.log(JSON.stringify(checks.at(-1)));
  }
  // Bad input must leave the current pose untouched.
  const before = data(await call('camera_get_state')).state;
  const invalid = await client.callTool({ name: 'camera_set_state', arguments: { distance: -1 } });
  assert.equal(invalid.isError, true);
  assert.deepEqual(data(await call('camera_get_state')).state, before);
  console.log('Invalid-input check passed');
} finally {
  if (original) {
    const restored = data(await call('camera_set_state', original));
    assert.deepEqual(restored.state, original);
    console.log('Original camera restored');
  }
  await client.close();
  await writeFile(join(out, 'report.json'), JSON.stringify({ checks, restored: !!original }, null, 2));
}
