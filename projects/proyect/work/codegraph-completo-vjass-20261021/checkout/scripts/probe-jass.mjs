// Deterministic local probes; not an agent A/B or a language-completeness claim.
// Usage: node --liftoff-only scripts/probe-jass.mjs SOURCE_ROOT...
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const { CodeGraph } = require('../dist');
const { ToolHandler } = require('../dist/mcp/tools');

const reports = [];
for (const input of process.argv.slice(2)) {
  const root = path.resolve(input);
  const sources = fs.readdirSync(root).filter(f => /\.(?:j|jass|vjass)$/i.test(f)).sort();
  const hashes = () => Object.fromEntries(sources.map(f => [f, crypto.createHash('sha256').update(fs.readFileSync(path.join(root, f))).digest('hex')]));
  const before = hashes();
  let cg = fs.existsSync(path.join(root, '.codegraph')) ? await CodeGraph.recreate(root) : await CodeGraph.init(root);
  const started = performance.now();
  try {
    const indexed = await cg.indexAll();
    assert.ok(indexed.success, JSON.stringify(indexed.errors));
    assert.equal(cg.getStats().fileCount, sources.length);
    const node = name => {
      const found = cg.getNodesByQualifiedName(name);
      assert.equal(found.length, 1, `ambiguous/missing ${name}`);
      return found[0];
    };
    const pairs = [
      ['CodeGraphProbe.Init', 'CodeGraphProbe.Counter.run'],
      ['CodeGraphProbe.Counter.run', 'CodeGraphProbe.Ping'],
      ['CodeGraphProbe.Done', 'CodeGraphProbe.Ping'],
    ];
    const handler = new ToolHandler(cg);
    const flows = [];
    for (const [from, to] of pairs) {
      const route = cg.findPath(node(from).id, node(to).id, ['calls', 'references']);
      assert.ok(route, `${from} must reach ${to}`);
      const result = await handler.execute('codegraph_explore', { query: `${from} ${to}` });
      assert.ok(!result.isError, JSON.stringify(result));
      const text = result.content.map(c => c.text ?? '').join('\n');
      assert.ok(text.includes('JASS/vJASS local support'));
      assert.ok(text.includes('call ') || text.includes('function '));
      const file = path.join(root, `.probe-${flows.length + 1}.txt`);
      fs.writeFileSync(file, text);
      flows.push({ from, to, graph_path: route, response_chars: text.length, output: file });
    }
    const stats = cg.getStats();
    const errors = cg.getFiles().flatMap(f => (f.errors ?? []).map(e => ({ file: f.path, ...e })));
    // A truly empty rebuild, not another indexAll over unchanged hashes.
    cg.destroy();
    cg = await CodeGraph.recreate(root);
    await cg.indexAll();
    assert.equal(cg.getStats().nodeCount, stats.nodeCount);
    assert.equal(cg.getStats().edgeCount, stats.edgeCount);
    assert.deepEqual(hashes(), before);
    reports.push({ root, index_ms: indexed.durationMs, total_probe_ms: Math.round(performance.now() - started),
      files: stats.fileCount, nodes: stats.nodeCount, edges: stats.edgeCount,
      errors, flows, stable_rebuild_counts: true, source_hashes_unchanged: true, source_hashes: before });
  } finally { cg.destroy(); }
}
console.log(JSON.stringify(reports, null, 2));
