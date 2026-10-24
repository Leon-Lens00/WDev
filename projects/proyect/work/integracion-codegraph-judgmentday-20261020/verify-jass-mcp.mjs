import { Client } from '/home/snz/Documentos/MCP W3/wc3-forge/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js';
import { StdioClientTransport } from '/home/snz/Documentos/MCP W3/wc3-forge/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readdir, readFile } from 'node:fs/promises';

const root = '/home/snz/Documentos/ChatGPT/Proyect/work/integracion-codegraph-judgmentday-20261020/fixtures/vjass-only';
const identities = async () => Object.fromEntries(await Promise.all((await readdir(root)).filter(f => /\.(j|jass|vjass)$/.test(f)).sort().map(async f => [f, createHash('sha256').update(await readFile(`${root}/${f}`)).digest('hex')])));
const before = await identities();
const transport = new StdioClientTransport({
  command: '/usr/bin/python3',
  args: ['/home/snz/.local/share/wc3-jass-explore/server.py', '--jassgraph', '/home/snz/Documentos/MCP W3/wc3-forge/scripts/jassgraph'],
  stderr: 'pipe',
});
let stderr = '';
transport.stderr.on('data', chunk => { stderr += chunk.toString(); });
const client = new Client({ name: 'wc3-integration-verification', version: '1.0.0' });
try {
  await client.connect(transport);
  const listed = await client.listTools();
  assert.deepEqual(listed.tools.map(t => t.name).sort(), ['jass_explore', 'jass_query']);
  assert.ok(listed.tools.every(t => t.annotations.readOnlyHint));
  const invoke = async (name, args) => {
    const response = await client.callTool({ name, arguments: args });
    assert.equal(response.isError, false, JSON.stringify(response));
    return JSON.parse(response.content[0].text);
  };
  const query = await invoke('jass_query', { root, query: 'spellping' });
  assert.equal(query.source_count, 3);
  assert.equal(query.symbols.total, 1);
  const explored = await invoke('jass_explore', { root, symbol: 'SpellPing' });
  assert.equal(explored.calls.total, 1);
  assert.equal(explored.calls.items[0].caller_name, 'main');
  assert.equal(explored.calls.items[0].resolution, 'lexical_candidate');
  assert.equal(explored.snippets.items.length, 2);
  const rejected = await client.callTool({ name: 'jass_query', arguments: { root: '.' } });
  assert.equal(rejected.isError, true);
  const after = await identities();
  assert.deepEqual(after, before);
  console.log(JSON.stringify({
    client: '@modelcontextprotocol/sdk 1.29.0 (existing Forge dependency)',
    server: client.getServerVersion(), capabilities: client.getServerCapabilities(),
    tools: listed.tools.map(t => t.name), source_count: query.source_count,
    query_symbols: query.symbols.items.map(s => s.qualified),
    explored_calls: explored.calls.items, snippet_count: explored.snippets.items.length,
    coverage: explored.coverage, source_set_sha256: explored.source_set_sha256,
    invalid_root_rejected: rejected.isError, source_hashes_unchanged: true,
    source_hashes: after, stderr,
  }, null, 2));
} finally {
  await client.close();
}
