import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
const require = createRequire('/home/snz/Documentos/MCP W3/codegraph-vjass/package.json');
const { CodeGraph } = require('./dist');
const { ToolHandler } = require('./dist/mcp/tools');
const directory = path.dirname(new URL(import.meta.url).pathname);
const inputs = JSON.parse(fs.readFileSync(path.join(directory, 'real-sources.json'), 'utf8'));
const digest = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const probes = [
  ['RapidFire.RapidBolt.shoot', 'RapidFire.RapidBolt.launch'],
  ['RapidFire.RapidBolt.missileIterateP', 'RapidFire.RapidBolt.onPeriod'],
  ['RapidFire.RapidBolt.missileTerminateP', 'RapidFire.RapidBolt.onRemove'],
  ['Missile.Missile.createXYZ', 'Missile.Missile.createEx'],
  ['RapidFire.RapidPair.emit', 'RapidFire.RapidBolt.shoot'],
];
const reports = [];
for (const input of inputs) {
  const root = input.copy;
  let cg = fs.existsSync(path.join(root, '.codegraph')) ? await CodeGraph.recreate(root) : await CodeGraph.init(root);
  try {
    const result = await cg.indexAll();
    assert.ok(result.success, JSON.stringify(result.errors));
    const errors = cg.getFiles().flatMap(f => (f.errors ?? []).filter(e => e.severity === 'error').map(e => ({ file: f.path, ...e })));
    assert.equal(errors.length, 0, JSON.stringify(errors));
    const nodes = cg.getFiles().flatMap(f => cg.getNodesInFile(f.path));
    const projected = nodes.filter(n => n.docstring?.startsWith('CodeGraph static projection:'));
    if (input.label !== 'ui') assert.ok(projected.length > 0);
    for (const node of projected) {
      const line = fs.readFileSync(path.join(root, node.filePath), 'utf8').split(/\r?\n/)[node.startLine - 1];
      assert.ok(/\bimplement\b|\/\/!\s*runtextmacro/.test(line), `${node.qualifiedName}: wrong anchor ${line}`);
    }
    const flows = [];
    if (input.label !== 'ui') {
      const handler = new ToolHandler(cg);
      const selected = input.label === 'missiles' ? probes : [
        ['InventoryCore.LClickItemSlot', 'InventoryCore.Inventory.setTooltipTitle'],
        ['InventoryItem.InvItem.buildDescription', 'InventoryCore.Inventory.setTooltipLine'],
        ['SocketItem.OnAgree', 'InventoryCore.Inventory.setTooltipInfo'],
      ];
      for (const [from, to] of selected) {
        const sources = cg.getNodesByQualifiedName(from), targets = cg.getNodesByQualifiedName(to);
        assert.equal(sources.length, 1, from); assert.equal(targets.length, 1, to);
        const route = cg.findPath(sources[0].id, targets[0].id, ['calls', 'references', 'instantiates']);
        assert.ok(route, `${from} does not reach ${to}`);
        const response = await handler.execute('codegraph_explore', { query: `${from} ${to}`, maxFiles: 2 });
        assert.ok(!response.isError);
        const text = response.content.map(c => c.text ?? '').join('\n');
        assert.ok(text.includes('Bounded macro/module projections'));
        fs.writeFileSync(path.join(directory, `flow-${input.label}-${flows.length}.txt`), text);
        flows.push({ from, to, path: route });
      }
    }
    const edges = () => cg.getFiles().flatMap(f => cg.getNodesInFile(f.path)).flatMap(n => cg.getOutgoingEdges(n.id).map(e => `${e.source}|${e.target}|${e.kind}|${e.line ?? ''}|${JSON.stringify(e.metadata ?? {})}`)).sort();
    const before = edges(), stats = cg.getStats();
    assert.equal(stats.fileCount, Object.keys(input.files).length);
    cg.destroy(); cg = await CodeGraph.recreate(root); await cg.indexAll();
    assert.deepEqual(edges(), before);
    for (const [file, hash] of Object.entries(input.files)) {
      assert.equal(digest(path.join(input.root, file)), hash, `production source changed: ${file}`);
      assert.equal(digest(path.join(root, file)), hash, `copy source changed: ${file}`);
    }
    reports.push({ label: input.label, root, files: stats.fileCount, nodes: stats.nodeCount, edges: stats.edgeCount,
      projected_nodes: projected.length, errors, warnings: cg.getFiles().reduce((n, f) => n + (f.errors ?? []).filter(e => e.severity === 'warning').length, 0),
      index_ms: result.durationMs, stable_full_rebuild: true, original_hashes_unchanged: true, flows,
      projection_examples: projected.filter(n => ['method', 'function', 'struct'].includes(n.kind)).slice(0, 5).map(n => ({ name: n.qualifiedName, file: n.filePath, line: n.startLine, origin: n.docstring })) });
    fs.writeFileSync(path.join(directory, 'real-results.json'), JSON.stringify(reports, null, 2));
    console.log(JSON.stringify({ label: input.label, files: stats.fileCount, nodes: stats.nodeCount, edges: stats.edgeCount, projections: projected.length, flows: flows.length, index_ms: result.durationMs }));
  } finally { cg.destroy(); }
}
