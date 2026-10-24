import { afterEach, describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { CodeGraph } from '../src';
import { parseJassSlk } from '../src/extraction/jass-slk';
import { FileWatcher, __emitWatchEventForTests } from '../src/sync/watcher';

describe('JassHelper SLK build inputs', () => {
  let root: string, cg: CodeGraph | undefined, watcher: FileWatcher | undefined;
  const fixture = (name: string) => fs.readFileSync(path.join(__dirname, 'fixtures/jass-conformance', name), 'utf8');
  const init = async (config = {}) => {
    root = fs.mkdtempSync(path.join(os.tmpdir(), 'cg-jass-slk-'));
    fs.writeFileSync(path.join(root, 'test.j'), fixture('slk.j'));
    fs.writeFileSync(path.join(root, 'data.slk'), fixture('data.slk'));
    fs.writeFileSync(path.join(root, 'codegraph.json'), JSON.stringify({ jass: { dataFiles: ['data.slk'] }, ...config }));
    cg = await CodeGraph.init(root); await cg.indexAll();
  };
  const dataTargets = () => {
    const file = cg!.getNodesInFile('test.j').find(n => n.kind === 'file')!;
    return cg!.getOutgoingEdges(file.id).filter(e => String(e.metadata?.resolutionScope).startsWith('slk-')).map(e => cg!.getNode(e.target)?.qualifiedName).sort();
  };
  const edges = () => cg!.getFiles().flatMap(f => cg!.getNodesInFile(f.path)).flatMap(n => cg!.getOutgoingEdges(n.id)).map(e => JSON.stringify([e.source,e.target,e.kind,e.line,e.metadata])).sort();
  afterEach(async () => { await watcher?.stop(); watcher = undefined; cg?.destroy(); cg = undefined; if (root) fs.rmSync(root, { recursive: true, force: true }); });
  it('links constructor, written fields and typed cell expressions, not string contents', async () => {
    await init();
    expect(dataTargets()).toEqual(expect.arrayContaining(['Data.getFromKey', 'Data.amount', 'Data.enabled', 'Data.label', 'Compute']));
    expect(dataTargets()).not.toContain('OtherCompute');
    const file = cg!.getNodesInFile('test.j').find(n => n.kind === 'file')!;
    expect(file.semanticData?.slkLoads).toEqual([expect.objectContaining({ path: 'data.slk', sha256: expect.stringMatching(/^[a-f0-9]{64}$/) })]);
    expect(cg!.getCallees(cg!.getNodesByQualifiedName('main')[0]!.id, 3).map(c => c.node.qualifiedName)).toContain('Compute');
  });
  it('invalidates consumers on a data-only edit and converges with a fresh graph', async () => {
    await init();
    fs.writeFileSync(path.join(root, 'data.slk'), fixture('data.slk').replace('K"Compute()"', 'K"OtherCompute()"'));
    await cg!.sync({ paths: ['data.slk'] });
    expect(dataTargets()).toContain('OtherCompute'); expect(dataTargets()).not.toContain('Compute');
    const incremental = edges(); cg!.destroy(); cg = await CodeGraph.recreate(root); await cg.indexAll(); expect(edges()).toEqual(incremental);
    fs.unlinkSync(path.join(root, 'data.slk')); await cg!.sync({ paths: ['data.slk'] }); expect(dataTargets()).toEqual([]);
    expect(cg!.getFiles().some(f => f.errors?.some(e => /SLK data.slk unavailable/.test(e.message)))).toBe(true);
  });
  it('keeps excluded data unread and records unavailable coverage', async () => {
    await init({ exclude: ['data.slk'] });
    expect(dataTargets()).toEqual([]);
    expect(cg!.getFiles().some(f => f.errors?.some(e => /excluded by project scope/.test(e.message)))).toBe(true);
  });
  it('refuses out-of-root data symlinks', async () => {
    await init(); const outside = path.join(os.tmpdir(), path.basename(root) + '-outside.slk');
    try {
      fs.writeFileSync(outside, fixture('data.slk')); fs.unlinkSync(path.join(root, 'data.slk')); fs.symlinkSync(outside, path.join(root, 'data.slk'));
      await cg!.sync({ paths: ['data.slk'] }); expect(dataTargets()).toEqual([]);
      expect(cg!.getFiles().some(f => f.errors?.some(e => /outside indexed root|symlink leaves indexed root/.test(e.message)))).toBe(true);
    } finally { fs.rmSync(outside, { force: true }); }
  });
  it('passes declared non-source data changes through the watcher filter', async () => {
    await init(); let observed: string[] = [];
    watcher = new FileWatcher(root, async paths => { observed = paths ?? []; return { filesChanged: 1, durationMs: 0 }; }, { inertForTests: true, debounceMs: 10 });
    await watcher.start(); __emitWatchEventForTests(root, 'data.slk');
    await new Promise(resolve => setTimeout(resolve, 150)); expect(observed).toContain('data.slk');
  });
  it('rejects malformed or oversized sparse coordinates with an explicit data diagnostic', () => {
    expect(() => parseJassSlk('ID;X\nC;X999999999;Y1;K"Data"\nE\n')).toThrow(/budget/);
    expect(() => parseJassSlk('not a table')).toThrow(/ID/);
  });
  it('does not turn inactive SLK directives into executable dependencies', async () => {
    await init();
    fs.writeFileSync(path.join(root, 'test.j'), fixture('slk.j').replace('//! loaddata "data.slk"', 'static if false then\n//! loaddata "data.slk"\nendif'));
    await cg!.sync({ paths: ['test.j'] }); expect(dataTargets()).toEqual([]);
  });

  it('resolves SLK header types by compiler spelling rather than a private lexical homonym', async () => {
    await init();
    const text = fixture('slk.j').replace('//! loaddata "data.slk"', 'library L\nprivate struct Data extends array\ninteger wrong\nendstruct\n//! loaddata "data.slk"\nendlibrary');
    fs.writeFileSync(path.join(root, 'test.j'), text); await cg!.sync({ paths: ['test.j'] });
    const owner = cg!.getNodesByQualifiedName('L')[0]!;
    const targets = cg!.getOutgoingEdges(owner.id).filter(e => String(e.metadata?.resolutionScope).startsWith('slk-')).map(e => cg!.getNode(e.target)?.qualifiedName);
    expect(targets).toEqual(expect.arrayContaining(['Data.getFromKey', 'Data.amount'])); expect(targets).not.toContain('L.Data.wrong');
  });

});
