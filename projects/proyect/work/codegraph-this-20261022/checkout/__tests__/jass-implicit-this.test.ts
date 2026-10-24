import { afterEach, describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { CodeGraph } from '../src';

describe('vJASS implicit instance receiver in static methods', () => {
  let root: string | undefined, graph: CodeGraph | undefined;
  afterEach(() => { graph?.destroy(); if (root) fs.rmSync(root, { recursive: true, force: true }); });
  const index = async (declaration: string, invocation = 'call cast(1.)', parameters = 'nothing', preamble = '') => {
    root = fs.mkdtempSync(path.join(os.tmpdir(), 'cg-jass-implicit-this-'));
    fs.writeFileSync(path.join(root, 'test.j'), `${preamble}struct Pair
method cast takes real x returns nothing
endmethod
private static method spell takes ${parameters} returns nothing
${declaration}
${invocation}
endmethod
endstruct
`);
    graph = await CodeGraph.init(root); await graph.indexAll();
    return graph.getCallees(graph.getNodesByQualifiedName('Pair.spell')[0]!.id)
      .map(x => x.node.qualifiedName);
  };

  it('uses a local thistype this for an unqualified instance call', async () => {
    expect(await index('local thistype this = 1')).toContain('Pair.cast');
  });

  it('uses an explicitly declared owning struct as the local receiver type', async () => {
    expect(await index('local Pair this = 1')).toContain('Pair.cast');
  });

  it('accepts an integer this, matching the lowered JASS receiver', async () => {
    expect(await index('local integer this = 1')).toContain('Pair.cast');
  });

  it('does not resolve a handle-valued this as an instance', async () => {
    expect(await index('local unit this = null')).not.toContain('Pair.cast');
  });

  it('uses a parameter this in the current static method', async () => {
    expect(await index('', 'call cast(1.)', 'thistype this')).toContain('Pair.cast');
  });

  it('does not invent a local receiver from a global this', async () => {
    expect(await index('', 'call cast(1.)', 'nothing', 'globals\ninteger this = 1\nendglobals\n')).not.toContain('Pair.cast');
  });

  it('does not invent an instance in a static method without this', async () => {
    expect(await index('')).not.toContain('Pair.cast');
  });

  it('does not turn an implicit instance method into a function reference', async () => {
    expect(await index('local thistype this = 1', 'call TimerStart(null, 0., false, function cast)')).not.toContain('Pair.cast');
  });
});
