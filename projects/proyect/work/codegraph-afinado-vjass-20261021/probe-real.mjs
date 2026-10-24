import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
import {createHash} from 'node:crypto';
const require = createRequire(import.meta.url);
const base = path.dirname(new URL(import.meta.url).pathname);
const repo = '/home/snz/Documentos/MCP W3/codegraph-vjass';
const {CodeGraph} = require(repo + '/dist');
const {ToolHandler} = require(repo + '/dist/mcp/tools');
const upstream = require('/home/snz/Documentos/ChatGPT/Proyect/work/integracion-codegraph-judgmentday-20261020/upstream/codegraph-linux-x64/package/lib/dist');
const original = JSON.parse(fs.readFileSync('/home/snz/Documentos/ChatGPT/Proyect/work/codegraph-proyectos-20261021/verification.json')).indexes;
const hash = p => createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const report = {roots: [], controls: {}};
for (const scope of original) {
  const root = path.join(base, 'real-' + scope.label);
  fs.mkdirSync(root, {recursive: true});
  for (const file of scope.files) {
    const target = path.join(root, file);
    fs.mkdirSync(path.dirname(target), {recursive: true});
    fs.copyFileSync(path.join(scope.root, file), target);
  }
  const cg = fs.existsSync(path.join(root, '.codegraph')) ? await CodeGraph.recreate(root) : await CodeGraph.init(root);
  try {
    const indexed = await cg.indexAll();
    assert.ok(indexed.success);
    assert.equal(cg.getStats().fileCount, scope.files.length);
    const errors = cg.getFiles().flatMap(f => (f.errors ?? []).map(e => ({...e, file: f.path})));
    const checks = [];
    if (scope.label === 'missiles') {
      assert.equal(cg.getNodesByQualifiedName('Missile.Missile').length, 1);
      assert.equal(cg.getNodesByQualifiedName('Missile.Missile.createEx.create').length, 0);
      assert.equal(errors.filter(e => e.file === 'libraries/Missile.j' && e.severity === 'error').length, 0);
      const pairs = [
        ['RapidFire.RapidPair.emit', 'RapidFire.RapidPair.face'],
        ['RapidFire.RapidPair.cast', 'RapidFire.RapidPair.emit'],
        ['RapidFire.RapidBolt.onPeriod', 'RapidFire.RapidBolt.resolve'],
      ];
      const handler = new ToolHandler(cg);
      for (const [from, to] of pairs) {
        const a = cg.getNodesByQualifiedName(from), b = cg.getNodesByQualifiedName(to);
        assert.equal(a.length, 1); assert.equal(b.length, 1);
        assert.ok(cg.getCallees(a[0].id).some(c => c.node.id === b[0].id), `${from} -> ${to}`);
        const response = await handler.execute('codegraph_explore', {query: `${from} ${to}`});
        assert.ok(!response.isError);
        const text = response.content.map(c => c.text ?? '').join('\n');
        assert.ok(text.includes('JASS/vJASS local support'));
        const output = `flow-${checks.length + 1}.txt`;
        fs.writeFileSync(path.join(base, output), text);
        checks.push({from, to, direct_edge: true, output});
      }
    }
    assert.ok(scope.files.every(f => hash(path.join(scope.root, f)) === hash(path.join(root, f))));
    report.roots.push({root: scope.root, copy: root, stats: cg.getStats(), errors, checks, source_hashes_equal: true});
    fs.writeFileSync(path.join(base, 'real-probes.json'), JSON.stringify(report, null, 2));
  } finally {cg.close();}
}
const python = 'def helper():\n return 1\ndef run():\n value = helper()\n return value\n';
const normalized = [];
for (const [label, Engine] of [['fork', CodeGraph], ['upstream', upstream.CodeGraph]]) {
  const root = path.join(base, 'python-' + label);
  fs.mkdirSync(root, {recursive: true}); fs.writeFileSync(path.join(root, 'control.py'), python);
  const cg = fs.existsSync(path.join(root, '.codegraph')) ? await Engine.recreate(root) : await Engine.init(root);
  try {
    assert.ok((await cg.indexAll()).success);
    const nodes = cg.getNodesByKind('function');
    const nodeRows = nodes.map(n => [n.kind, n.qualifiedName, n.startLine, n.endLine]).sort();
    const calls = nodes.flatMap(n => cg.getCallees(n.id).map(c => [n.qualifiedName, c.node.qualifiedName])).sort();
    normalized.push({nodes: nodeRows, calls});
    report.controls[label] = {nodes: nodeRows, calls};
  } finally {cg.close();}
}
assert.deepEqual(normalized[0], normalized[1]);
report.controls.equal_to_pinned_upstream = true;
fs.writeFileSync(path.join(base, 'real-probes.json'), JSON.stringify(report, null, 2));
console.log(JSON.stringify({roots: report.roots.map(r => ({root:r.root, files:r.stats.fileCount, nodes:r.stats.nodeCount, edges:r.stats.edgeCount, errors:r.errors.filter(e=>e.severity==='error').length, flows:r.checks.length})), control_equal:true}));
