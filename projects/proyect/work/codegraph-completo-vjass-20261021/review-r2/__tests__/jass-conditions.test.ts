import { afterEach, describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { CodeGraph } from '../src';
import { JassExtractor } from '../src/extraction/jass-extractor';
import { buildJassCatalog } from '../src/extraction/jass-preprocessor';
import { DEFAULT_JASS_PROFILE, JassProfile } from '../src/jass-profile';

const extract = (source: string, profile: Partial<JassProfile> = {}) => new JassExtractor('test.j', source, 'jass', buildJassCatalog(new Map([['test.j', source]]), { ...DEFAULT_JASS_PROFILE, ...profile })).extract();
const has = (source: string, name: string) => extract(source).nodes.some(n => n.qualifiedName === name);
let root: string | undefined, graph: CodeGraph | undefined;
afterEach(() => { graph?.destroy(); graph = undefined; if (root) fs.rmSync(root, { recursive: true, force: true }); });

describe('JassHelper condition conformance', () => {
  it('uses prior method declarations for exists, not fields or future methods', () => {
    const body = (member: string) => `struct S extends array\n${member}\nstatic if thistype.feature.exists then\nmethod chosen takes nothing returns nothing\nendmethod\nendif\nendstruct\n`;
    expect(has(body('private method feature takes nothing returns nothing\nendmethod'), 'S.chosen')).toBe(true);
    expect(has(body('integer feature'), 'S.chosen')).toBe(false);
    expect(has('struct S extends array\nstatic if thistype.later.exists then\nmethod early takes nothing returns nothing\nendmethod\nendif\nmethod later takes nothing returns nothing\nendmethod\nendstruct\n', 'S.early')).toBe(false);
  });

  it('does not count a stub method as a registered existence fact in this compiler', () => {
    expect(has('struct S\nstub method feature takes nothing returns nothing\nendmethod\nstatic if thistype.feature.exists then\nmethod chosen takes nothing returns nothing\nendmethod\nendif\nendstruct\n', 'S.chosen')).toBe(false);
  });

  it('selects conjunctions, elseif and pooled boolean declarations according to the compiler', () => {
    const source = 'static if FLAG and not DEBUG_MODE then\nfunction Chosen takes nothing returns nothing\nendfunction\nelseif false then\nfunction Wrong takes nothing returns nothing\nendfunction\nelse\nfunction DebugChosen takes nothing returns nothing\nendfunction\nendif\nglobals\nconstant boolean FLAG=true\nendglobals\n';
    const release = extract(source, { mode: 'release' }).nodes.map(n => n.name);
    const debug = extract(source, { mode: 'debug' }).nodes.map(n => n.name);
    expect(release).toContain('Chosen'); expect(release).not.toContain('Wrong'); expect(release).not.toContain('DebugChosen');
    expect(debug).toContain('DebugChosen'); expect(debug).not.toContain('Chosen');
    expect(extract('globals\nconstant boolean FLAG = true and true\nendglobals\nstatic if FLAG then\nfunction Wrong takes nothing returns nothing\nendfunction\nendif\n').nodes.some(n => n.name === 'Wrong')).toBe(false);
  });

  it('rejects static-if operators the actual compiler rejects', () => {
    expect(extract('static if true or false then\nendif\n').errors.some(e => e.severity === 'error')).toBe(true);
    expect(extract('static if (true) and (true) then\nendif\n').errors.some(e => e.severity === 'error')).toBe(true);
  });

  it('retains uncertainty without a profile and marks conditional reference origins', () => {
    const source = 'function Run takes nothing returns nothing\nstatic if DEBUG_MODE then\ncall One()\nelse\ncall Two()\nendif\nendfunction\n';
    const result = extract(source), run = result.nodes.find(n => n.name === 'Run')!;
    expect(result.unresolvedReferences.map(r => r.referenceName)).toEqual(expect.arrayContaining(['One', 'Two']));
    expect(run.semanticData?.conditionalRefs).toEqual(expect.arrayContaining(['3:One', '5:Two']));
    const release = extract(source, { mode: 'release' });
    expect(release.unresolvedReferences.map(r => r.referenceName)).toEqual(['Two']);
  });

  it('invalidates JASS consumers when only the compiler profile changes', async () => {
    root = fs.mkdtempSync(path.join(os.tmpdir(), 'cg-jass-profile-'));
    fs.writeFileSync(path.join(root, 'test.j'), 'static if DEBUG_MODE then\nfunction DebugChosen takes nothing returns nothing\nendfunction\nelse\nfunction ReleaseChosen takes nothing returns nothing\nendfunction\nendif\n');
    fs.writeFileSync(path.join(root, 'codegraph.json'), JSON.stringify({ jass: { mode: 'release' } }));
    graph = await CodeGraph.init(root); await graph.indexAll();
    expect(graph.getNodesByName('ReleaseChosen')).toHaveLength(1); expect(graph.getNodesByName('DebugChosen')).toHaveLength(0);
    fs.writeFileSync(path.join(root, 'codegraph.json'), JSON.stringify({ jass: { mode: 'debug' } }));
    await graph.sync({ paths: ['codegraph.json'] });
    expect(graph.getNodesByName('DebugChosen')).toHaveLength(1); expect(graph.getNodesByName('ReleaseChosen')).toHaveLength(0);
  });
  it('recognizes default library globals by their global spelling across namespaces', () => {
    const source = 'library A\nglobals\nconstant boolean FLAG=true\nendglobals\nendlibrary\nlibrary B requires A\nstatic if FLAG then\nfunction Chosen takes nothing returns nothing\nendfunction\nelse\nfunction Fallback takes nothing returns nothing\nendfunction\nendif\nendlibrary\n';
    const result = extract(source, { completeInputs: true });
    expect(result.nodes.some(n => n.name === 'Chosen')).toBe(true);
    expect(result.nodes.some(n => n.name === 'Fallback')).toBe(false);
  });

  it('does not let the first consumer of a shared catalog decide another file’s alias truth', () => {
    const sources = new Map([
      ['a.j', 'globals\nconstant boolean FLAG=true\nendglobals\n'],
      ['b.j', 'globals\nconstant boolean ALIAS=FLAG\nendglobals\nstatic if ALIAS then\nfunction Yes takes nothing returns nothing\nendfunction\nelse\nfunction No takes nothing returns nothing\nendfunction\nendif\n'],
    ]);
    const names = (first: string) => {
      const catalog = buildJassCatalog(sources);
      new JassExtractor(first, sources.get(first)!, 'jass', catalog).extract();
      return new JassExtractor('b.j', sources.get('b.j')!, 'jass', catalog).extract().nodes.filter(n => n.kind === 'function').map(n => n.name).sort();
    };
    expect(names('a.j')).toEqual(['No', 'Yes']); expect(names('b.j')).toEqual(['No', 'Yes']);
  });

  it('does not close a static branch when an ordinary runtime endif is encountered while pooling flags', () => {
    const source='static if DEBUG_MODE then\nfunction Optional takes nothing returns nothing\nif true then\nendif\nendfunction\nglobals\nconstant boolean FLAG=true\nendglobals\nendif\nstatic if FLAG then\nfunction Yes takes nothing returns nothing\nendfunction\nelse\nfunction No takes nothing returns nothing\nendfunction\nendif\n';
    const result=extract(source);
    expect(result.nodes.filter(n=>['Yes','No'].includes(n.name)).map(n=>n.name).sort()).toEqual(['No','Yes']);
  });

});
