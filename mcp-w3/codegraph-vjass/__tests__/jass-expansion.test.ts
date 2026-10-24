import { afterEach, describe, expect, it, vi } from 'vitest';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { CodeGraph } from '../src';
import { extractFromSource } from '../src/extraction/tree-sitter';
import * as fileLimits from '../src/file-limits';

describe('JASS project expansion', { timeout: 60000 }, () => {
  let root: string;
  let cg: CodeGraph | undefined;
  const init = async (files: Record<string, string>) => {
    root = fs.mkdtempSync(path.join(os.tmpdir(), 'cg-jass-expansion-'));
    for (const [file, text] of Object.entries(files)) { fs.mkdirSync(path.dirname(path.join(root, file)), { recursive: true }); fs.writeFileSync(path.join(root, file), text); }
    cg = await CodeGraph.init(root);
    await cg.indexAll();
  };
  const calls = (name: string) => {
    const node = cg!.getNodesByQualifiedName(name)[0];
    expect(node, name).toBeDefined();
    return cg!.getCallees(node!.id).filter(c => c.edge.kind === 'calls' || c.edge.kind === 'instantiates' || !!c.edge.metadata?.jassBuiltin).map(c => c.node.qualifiedName);
  };
  const graph = () => cg!.getFiles().flatMap(f => cg!.getNodesInFile(f.path)).flatMap(n => cg!.getOutgoingEdges(n.id).map(e => `${e.source}|${e.target}|${e.kind}|${e.line ?? ''}|${JSON.stringify(e.metadata ?? {})}`)).sort();
  afterEach(() => { cg?.destroy(); cg = undefined; if (root) fs.rmSync(root, { recursive: true, force: true }); });

  it('specializes nested module methods and thistype callbacks for each implementing struct', async () => {
    await init({
      'modules.j': 'module Launch\nstatic method launch takes nothing returns nothing\ncall thistype.onPeriod()\nendmethod\nendmodule\nmodule Bundle\nimplement Launch\nendmodule\n',
      'users.j': 'struct One extends array\nstatic method onPeriod takes nothing returns nothing\nendmethod\nimplement Bundle\nstatic method start takes nothing returns nothing\ncall launch()\nendmethod\nendstruct\nstruct Two extends array\nstatic method onPeriod takes nothing returns nothing\nendmethod\nimplement Bundle\nendstruct\n',
    });
    expect(calls('One.start')).toContain('One.launch');
    expect(calls('One.launch')).toEqual(['One.onPeriod']);
    expect(calls('Two.launch')).toEqual(['Two.onPeriod']);
    const node = cg!.getNodesByQualifiedName('One.launch')[0]!;
    expect(node.filePath).toBe('users.j');
    expect(node.startLine).toBe(4);
    expect(node.docstring).toContain('modules.j:2');
  });

  it('expands parameterized cross-file textmacros while preserving the invocation source location', async () => {
    await init({
      'macros.j': '//! textmacro DECL takes NAME, TARGET\nfunction $NAME$ takes nothing returns nothing\ncall $TARGET$()\nendfunction\n//! endtextmacro\n',
      'users.j': 'function Ping takes nothing returns nothing\nendfunction\n//! runtextmacro DECL("Run", "Ping")\n',
    });
    expect(calls('Run')).toEqual(['Ping']);
    expect(cg!.getNodesByQualifiedName('Run')[0]!.startLine).toBe(3);
  });

  it('rebuilds unchanged module and macro consumers after modification and deletion', async () => {
    await init({ 'defs.j': 'module M\nstatic method run takes nothing returns nothing\ncall Ping()\nendmethod\nendmodule\n',
      'use.j': 'function Ping takes nothing returns nothing\nendfunction\nfunction Pong takes nothing returns nothing\nendfunction\nstruct S extends array\nimplement M\nendstruct\n' });
    expect(calls('S.run')).toEqual(['Ping']);
    fs.writeFileSync(path.join(root, 'defs.j'), fs.readFileSync(path.join(root, 'defs.j'), 'utf8').replace('Ping()', 'Pong()'));
    await cg!.sync({ paths: ['defs.j'] });
    expect(calls('S.run')).toEqual(['Pong']);
    const incremental = graph();
    cg!.destroy(); cg = await CodeGraph.recreate(root); await cg.indexAll();
    expect(graph()).toEqual(incremental);
    fs.unlinkSync(path.join(root, 'defs.j'));
    await cg!.sync({ paths: ['defs.j'] });
    expect(cg!.getNodesByQualifiedName('S.run')).toEqual([]);
    const deleted = graph();
    cg!.destroy(); cg = await CodeGraph.recreate(root); await cg.indexAll();
    expect(graph()).toEqual(deleted);
  });

  it('links only imports within the indexed scope without reading or indexing outside paths', async () => {
    await init({ 'a.j': '//! import "b.j"\n//! import "../outside.j"\n', 'b.j': 'function B takes nothing returns nothing\nendfunction\n' });
    const file = cg!.getNodesInFile('a.j').find(n => n.kind === 'file')!;
    expect(cg!.getCallees(file.id).map(c => [c.node.filePath, c.edge.kind])).toContainEqual(['b.j', 'imports']);
    expect(cg!.getFiles()).toHaveLength(2);
  });

  it('keeps recursion and duplicate definitions unresolved, never choosing another module', async () => {
    await init({ 'a.j': 'module M\nstatic method wrong takes nothing returns nothing\nendmethod\nendmodule\n',
      'b.j': 'module M\nstatic method other takes nothing returns nothing\nendmethod\nendmodule\nstruct S\nimplement M\nendstruct\nmodule Cycle\nimplement Cycle\nendmodule\nstruct C\nimplement Cycle\nendstruct\n' });
    expect(cg!.getNodesByQualifiedName('S.wrong')).toEqual([]);
    expect(cg!.getNodesByQualifiedName('S.other')).toEqual([]);
    expect(cg!.getFiles().some(f => f.errors?.some(e => /ambiguous|cycle/i.test(e.message)))).toBe(true);
  });

  it('ignores directive-looking text inside inactive regions, comments and strings', () => {
    const source = '//! textmacro T\nfunction Generated takes nothing returns nothing\nendfunction\n//! endtextmacro\n/*\n//! runtextmacro T()\n*/\n//! novjass\n//! runtextmacro T()\n//! endnovjass\nfunction Real takes nothing returns nothing\nlocal string s = "//! runtextmacro T()"\nendfunction\n';
    expect(extractFromSource('safe.j', source).nodes.some(n => n.name === 'Generated')).toBe(false);
  });

  it('keeps module definition scope for private helpers and independent module initializers', async () => {
    await init({ 'defs.j': 'library Defs\nprivate function Captured takes nothing returns nothing\nendfunction\nmodule M\nstatic method run takes nothing returns nothing\ncall Captured()\nendmethod\nprivate static method onInit takes nothing returns nothing\ncall thistype.run()\nendmethod\nendmodule\nmodule N\nprivate static method onInit takes nothing returns nothing\nendmethod\nendmodule\nendlibrary\n',
      'use.j': 'library Use\nstruct S extends array\nimplement M\nimplement N\nendstruct\nendlibrary\n' });
    expect(calls('Use.S.run')).toEqual(['Defs.Captured']);
    expect(calls('Use.S')).toEqual(expect.arrayContaining(['Use.S.__cg_Defs_M_onInit', 'Use.S.__cg_Defs_N_onInit']));
  });

  it('resolves explicit function helpers and literal ExecuteFunc without following computed strings', async () => {
    await init({ 'functions.j': 'function Ping takes nothing returns nothing\nendfunction\nfunction Run takes string target returns nothing\ncall Ping.execute()\ncall ExecuteFunc("Ping")\ncall ExecuteFunc(target)\nendfunction\n' });
    expect(calls('Run')).toContain('Ping');
    const run = cg!.getNodesByQualifiedName('Run')[0]!;
    const ping = cg!.getNodesByQualifiedName('Ping')[0]!;
    const refs = cg!.getOutgoingEdges(run.id).filter(e => e.target === ping.id).map(edge => ({ edge }));
    expect(refs.some(c => c.edge.metadata?.resolutionScope === 'named-execute-evaluate')).toBe(true);
    expect(refs.some(c => c.edge.metadata?.resolutionScope === 'literal-execute-func')).toBe(true);
    expect(cg!.getFiles()[0]!.errors?.some(e => /Computed dispatch/.test(e.message))).toBe(true);
  });

  it('resolves declared property operators and factory/index receivers without guessing unknown types', async () => {
    await init({ 'operators.j': 'struct S extends array\nmethod tick takes nothing returns nothing\nendmethod\nmethod operator value takes nothing returns integer\nreturn 1\nendmethod\nmethod operator value= takes integer v returns nothing\nendmethod\nstatic method make takes nothing returns thistype\nreturn 1\nendmethod\nendstruct\nglobals\nS array values\ninteger array other\nendglobals\nfunction Run takes S s returns nothing\nlocal integer n = s.value\nset s.value = 2\ncall S.make().tick()\ncall values[0].tick()\ncall other[0].tick()\ncall Unknown().tick()\nendfunction\n' });
    expect(calls('Run')).toEqual(expect.arrayContaining(['S.operator value', 'S.operator value=', 'S.make', 'S.tick']));
    const run = cg!.getNodesByQualifiedName('Run')[0]!;
    const target = cg!.getNodesByQualifiedName('S.tick')[0]!;
    const tick = cg!.getOutgoingEdges(run.id).filter(e => e.target === target.id).map(edge => ({ edge }));
    expect(tick).toHaveLength(2);
    expect(tick.map(c => c.edge.metadata?.resolutionScope).sort()).toEqual(['declared-factory-receiver', 'declared-index-receiver']);
  });

  it('models compiler-provided lifecycle only on normal structs without inventing method bodies', async () => {
    await init({ 'alloc.j': 'struct S\nstatic method make takes nothing returns thistype\nreturn thistype.allocate()\nendmethod\nendstruct\nstruct A extends array\nendstruct\nfunction Run takes S s returns nothing\ncall s.destroy()\ncall A.create()\nendfunction\n' });
    expect(calls('S.make')).toContain('S');
    expect(cg!.getNodesByQualifiedName('S.allocate')).toEqual([]);
    const run = cg!.getNodesByQualifiedName('Run')[0]!;
    expect(cg!.getCallees(run.id).map(c => [c.node.qualifiedName, c.edge.kind, c.edge.metadata?.jassBuiltin])).toContainEqual(['S', 'references', 'destroy']);
    expect(calls('Run')).not.toContain('A');
  });

  it('invalidates macro consumers and never expands excluded definitions', async () => {
    await init({ 'codegraph.json': JSON.stringify({ exclude: ['excluded.j'], extensions: { '.incj': 'vjass' } }),
      'excluded.j': '//! textmacro HIDDEN\nfunction Wrong takes nothing returns nothing\nendfunction\n//! endtextmacro\n',
      'macro.incj': '//! textmacro DEF takes NAME\nfunction $NAME$ takes nothing returns nothing\nendfunction\n//! endtextmacro\n',
      'use.j': '//! runtextmacro DEF("Before")\n//! runtextmacro HIDDEN()\n//! import "excluded.j"\n' });
    expect(cg!.getNodesByQualifiedName('Before')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('Wrong')).toEqual([]);
    fs.writeFileSync(path.join(root, 'macro.incj'), fs.readFileSync(path.join(root, 'macro.incj'), 'utf8').replace('$NAME$', '$NAME$After'));
    await cg!.sync({ paths: ['macro.incj'] });
    expect(cg!.getNodesByQualifiedName('Before')).toEqual([]);
    expect(cg!.getNodesByQualifiedName('BeforeAfter')).toHaveLength(1);
  });

  it('retains negative coverage diagnostics for unsupported directives and bounded recursion', () => {
    const source = '//! textmacro LOOP\n//! runtextmacro LOOP()\n//! endtextmacro\n//! runtextmacro LOOP()\n//! runtextmacro BROKEN(noQuotes)\n//! import noQuotes\n';
    const result = extractFromSource('bad.j', source);
    expect(result.errors.some(e => /cycle/.test(e.message))).toBe(true);
    expect(result.errors.some(e => /BROKEN.*not expanded/.test(e.message))).toBe(true);
    expect(result.errors.some(e => /Unsupported import/.test(e.message))).toBe(true);
  });

  it('uses an explicitly typed local this alias instead of the implementing struct', async () => {
    await init({ 'alias.j': 'struct Other extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nmodule M\nstatic method run takes nothing returns nothing\nlocal Other this = 1\ncall this.tick()\nendmethod\nendmodule\nstruct S extends array\nmethod tick takes nothing returns nothing\nendmethod\nimplement M\nendstruct\n' });
    expect(calls('S.run')).toEqual(['Other.tick']);
  });

  it('discards exists fallbacks only when the projected struct has an unconditional declaration', async () => {
    await init({ 'exists.j': 'module M\nmethod describe takes nothing returns nothing\nendmethod\nendmodule\nstruct S extends array\nimplement M\nstatic if not thistype.describe.exists then\nmethod describe takes nothing returns nothing\nendmethod\nendif\nstatic method run takes S s returns nothing\ncall s.describe()\nendmethod\nendstruct\nstruct Unknown extends array\nstatic if FLAG then\nmethod maybe takes nothing returns nothing\nendmethod\nendif\nstatic if not thistype.maybe.exists then\nmethod maybe takes nothing returns nothing\nendmethod\nendif\nendstruct\n' });
    expect(cg!.getNodesByQualifiedName('S.describe')).toHaveLength(1);
    expect(calls('S.run')).toEqual(['S.describe']);
    expect(cg!.getNodesByQualifiedName('Unknown.maybe')).toHaveLength(2);
  });

  it('does not resolve index operators as if their receiver were a declared array', async () => {
    await init({ 'index.j': 'struct Other extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nstruct S extends array\nstatic method operator [] takes integer index returns Other\nreturn Other(index)\nendmethod\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nfunction Run takes nothing returns nothing\ncall S[0].tick()\nendfunction\n' });
    expect(calls('Run')).not.toContain('S.tick');
    expect(calls('Run')).toEqual(expect.arrayContaining(['Other.tick', 'S.operator []'])); // Declared operator result, not receiver type.
  });

  it('does not mistake an array comment on a scalar for an array declaration', async () => {
    await init({ 'index.j': "struct Other extends array\n    method tick takes nothing returns nothing\n    endmethod\nendstruct\nstruct S extends array\n    method operator [] takes integer index returns Other\n        return Other(index)\n    endmethod\n    method tick takes nothing returns nothing\n    endmethod\nendstruct\nfunction Run takes nothing returns nothing\n    local S scalar = 0 // array\n    call scalar[0].tick()\nendfunction\nfunction config takes nothing returns nothing\nendfunction\n" });
    expect(calls('Run')).not.toContain('S.tick');
    expect(calls('Run')).toEqual(expect.arrayContaining(['Other.tick', 'S.operator []'])); // A scalar invokes its declared instance operator.
  });

  it('resolves declared arrays with block comments between declaration tokens', async () => {
    await init({ 'comments.j': 'struct S extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nglobals\nS /* type */ array before\nS array /* name */ after\nendglobals\nfunction Before takes nothing returns nothing\ncall before[0].tick()\nendfunction\nfunction After takes nothing returns nothing\ncall after[0].tick()\nendfunction\n' });
    expect(calls('Before')).toContain('S.tick');
    expect(calls('After')).toContain('S.tick');
  });

  it('keeps debug-dependent exists fallbacks as potential paths', () => {
    const result = extractFromSource('debug.j', 'struct S extends array\ndebug integer feature\nstatic if not thistype.feature.exists then\nstatic method fallback takes nothing returns nothing\nendmethod\nendif\nendstruct\n');
    expect(result.nodes.some(n => n.qualifiedName === 'S.fallback')).toBe(true);
    expect(result.errors.some(e => /Conditional compilation/.test(e.message))).toBe(true);
  });

  it('shares one project catalog across all consumers of an incremental batch', async () => {
    await init({ 'defs.j': 'module M\nstatic method run takes nothing returns nothing\nendmethod\nendmodule\n', 'one.j': 'struct One extends array\nimplement M\nendstruct\n', 'two.j': 'struct Two extends array\nimplement M\nendstruct\n' });
    const reads = vi.spyOn(fileLimits, 'readBoundedSourceSync');
    try {
      fs.writeFileSync(path.join(root, 'defs.j'), fs.readFileSync(path.join(root, 'defs.j'), 'utf8').replace('run', 'advance'));
      await cg!.sync({ paths: ['defs.j'] });
      expect(cg!.getNodesByQualifiedName('One.advance')).toHaveLength(1);
      expect(cg!.getNodesByQualifiedName('Two.advance')).toHaveLength(1);
      const sourceReads = reads.mock.calls.filter(([file]) => /\.(j|jass|vjass)$/i.test(String(file)));
      expect(sourceReads).toHaveLength(4); // Three catalog reads plus the changed-file hash reconciliation.
    } finally { reads.mockRestore(); }
  });
  const fixture = (name: string) => fs.readFileSync(path.join(__dirname, 'fixtures/jass-conformance', name + '.j'), 'utf8');
  it('collects modules generated by textmacros before implementing them', async () => {
    await init({ 'generated.j': fixture('macro-module') });
    expect(calls('S.run')).toEqual(['Ping']);
    expect(cg!.getNodesByQualifiedName('S.run')[0]!.docstring).toContain('textmacro DECL');
  });
  it('expands macros inside module definitions before applying module private namespaces', async () => {
    await init({ 'generated.j': fixture('macro-in-module') });
    expect(cg!.getNodesByQualifiedName('S.go')).toHaveLength(1);
  });
  it('isolates all private module members, fields and calls while preserving lifecycle names', async () => {
    await init({ 'modules.j': fixture('private') });
    expect(calls('S.runM')).toEqual(['S.__cg_M_helper']);
    expect(calls('S.runN')).toEqual(['S.__cg_N_helper']);
    expect(cg!.getNodesByQualifiedName('S.__cg_M_value')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('S.__cg_N_value')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('S.helper')).toHaveLength(0);
  });
  it('supports compiler quote escapes and textmacro_once without emitting a duplicate definition', async () => {
    await init({ 'escape.j': fixture('escaped').replaceAll('DECL', 'ESCAPED'), 'once.j': fixture('once') });
    expect(cg!.getNodesByQualifiedName('Value')[0]!.semanticData?.returns).toBeDefined();
    expect(cg!.getNodesByQualifiedName('Ping')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('Pong')).toHaveLength(0);
  });
  it('resolves vjass imports via scoped lookup paths and ignores comment imports', async () => {
    await init({ 'codegraph.json': JSON.stringify({ jass: { lookupPaths: ['libs'] } }),
      'nested/use.j': '//! import vjass "dep.j"\n//! import comment "ignored.j"\n',
      'libs/dep.j': 'function Dep takes nothing returns nothing\nendfunction\n',
      'ignored.j': 'function Ignored takes nothing returns nothing\nendfunction\n' });
    const file = cg!.getNodesInFile('nested/use.j').find(n => n.kind === 'file')!;
    expect(cg!.getOutgoingEdges(file.id).filter(e => e.kind === 'imports').map(e => cg!.getNode(e.target)?.filePath)).toEqual(['libs/dep.j']);
  });

  it('replaces the original main body with the injected source and links compiler initialization', async () => {
    await init({ 'injection.j': fixture('inject') });
    const injection = cg!.getNodesByQualifiedName('__jass_inject_main')[0]!;
    expect(calls('__jass_inject_main')).toContain('Demo.Ping');
    expect(cg!.getOutgoingEdges(cg!.getNodesByQualifiedName('main')[0]!.id).some(e => e.target === injection.id && e.metadata?.phase === 'injected-body')).toBe(true);
    expect(calls('main')).not.toContain('Original');
    const main = cg!.getNodesByQualifiedName('main')[0]!;
    expect(cg!.getOutgoingEdges(main.id).some(e => e.metadata?.phase === 'library-scope-initializer')).toBe(true);
    expect(cg!.getCallees(main.id, 3).map(c => c.node.qualifiedName)).toContain('Demo.Init');
  });
  it('keeps cross-file injection source locations and restores the original body after deletion', async () => {
    const source = fixture('inject'), split = source.indexOf('function main takes');
    await init({ 'inject.j': source.slice(0, split), 'main.j': source.slice(split) });
    const main = cg!.getNodesByQualifiedName('main')[0]!;
    expect(cg!.getCallees(main.id, 3).map(c => c.node.qualifiedName)).toContain('Demo.Ping');
    expect(calls('main')).not.toContain('Original');
    const injected = cg!.getNodesByQualifiedName('__jass_inject_main')[0]!;
    expect(injected.filePath).toBe('inject.j');
    expect(cg!.getOutgoingEdges(main.id).some(e => e.target === injected.id && e.metadata?.phase === 'injected-body')).toBe(true);
    // Keep declarations while removing the injection directives/body.
    fs.writeFileSync(path.join(root, 'inject.j'), source.slice(0, source.indexOf('//! inject main')));
    await cg!.sync({ paths: ['inject.j'] });
    expect(calls('main')).toContain('Original');
    expect(cg!.getNodesByQualifiedName('__jass_inject_main')).toHaveLength(0);
    const incremental = graph(); cg!.destroy(); cg = await CodeGraph.recreate(root); await cg.indexAll();
    expect(graph()).toEqual(incremental);
  });
  it('routes config injection calls to config rather than to the file', async () => {
    await init({ 'injection.j': fixture('inject-config') });
    expect(calls('__jass_inject_config')).toEqual(['Ping']);
  });
  it('reports a missing dovjassinit rather than fabricating initialization', async () => {
    await init({ 'bad.j': '//! inject main\ncall Unknown()\n//! endinject\nfunction main takes nothing returns nothing\nendfunction\n' });
    expect(cg!.getFiles()[0]!.errors?.some(e => /requires dovjassinit/.test(e.message))).toBe(true);
    const main = cg!.getNodesByQualifiedName('main')[0]!;
    expect(cg!.getOutgoingEdges(main.id).some(e => e.metadata?.phase === 'library-scope-initializer')).toBe(false);
  });

  it.each(['repeat', 'diamond'])('implements each module only once per struct (%s)', async name => {
    await init({ 'modules.j': fixture('module-' + name) });
    expect(cg!.getNodesByQualifiedName('S.ping')).toHaveLength(1);
  });
  it('matches compiler module deduplication before static-if elimination', async () => {
    await init({ 'modules.j': fixture('module-conditional') });
    // JassHelper consumes the first implementation before removing its false
    // branch; the second implementation is already skipped. The oracle emits no ping.
    expect(cg!.getNodesByQualifiedName('S.ping')).toHaveLength(0);
  });

  it('composes intentionally open module method bodies before semantic parsing', async () => {
    await init({ 'open.j': 'module Begin\nstatic method run takes nothing returns nothing\nendmodule\nmodule Finish\nendmethod\nendmodule\nfunction Ping takes nothing returns nothing\nendfunction\nstruct S\nimplement Begin\ncall Ping()\nimplement Finish\nendstruct\n' });
    expect(calls('S.run')).toEqual(['Ping']);
    expect(cg!.getFiles().some(f => f.errors?.some(e => e.severity === 'error'))).toBe(false);
    expect(cg!.getNodesByQualifiedName('Begin.run')).toHaveLength(0);
  });
  it('links implemented/generated symbols to real template definitions for impact analysis', async () => {
    await init({ 'generated.j': fixture('macro-module') });
    const module = cg!.getNodesByQualifiedName('M').find(n => n.semanticData?.templateKind === 'module')!;
    const macro = cg!.getNodesByQualifiedName('DECL').find(n => n.semanticData?.templateKind === 'textmacro')!;
    const user = cg!.getNodesByQualifiedName('S')[0]!;
    expect(cg!.getOutgoingEdges(user.id).some(e => e.target === module.id && e.metadata?.resolutionScope === 'template-input-dependency')).toBe(true);
    expect(cg!.getFiles().flatMap(f => cg!.getNodesInFile(f.path)).flatMap(n => cg!.getOutgoingEdges(n.id)).some(e => e.target === macro.id && e.metadata?.resolutionScope === 'template-input-dependency')).toBe(true);
  });

  it('keeps the first in-file library_once before collecting module definitions', async () => {
    await init({ 'once.j': 'library_once Once\nfunction First takes nothing returns nothing\nendfunction\nmodule M\nstatic method target takes nothing returns nothing\nendmethod\nendmodule\nendlibrary\nlibrary_once Once\nfunction Ignored takes nothing returns nothing\nendfunction\nmodule M\nstatic method wrong takes nothing returns nothing\nendmethod\nendmodule\nendlibrary\nstruct S\nimplement M\nendstruct\n' });
    expect(cg!.getNodesByQualifiedName('Once.First')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('Once.Ignored')).toHaveLength(0);
    expect(cg!.getNodesByQualifiedName('S.target')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('S.wrong')).toHaveLength(0);
  });

  it('normalizes block-comment newlines and joined identifiers while keeping real source spans', async () => {
    await init({ 'comments.j': 'function Pi/* comment\ncontinued */ng takes /* another\ncomment */ nothing returns nothing\nendfunction\nfunction Run takes nothing returns nothing\ncall Pi/**/ng()\nendfunction\n' });
    expect(calls('Run')).toEqual(['Ping']);
    expect(cg!.getNodesByQualifiedName('Ping')[0]!.startLine).toBe(1);
    expect(cg!.getNodesByQualifiedName('Ping')[0]!.endLine).toBe(4);
    expect(cg!.getFiles().some(f => f.errors?.some(e => e.severity === 'error'))).toBe(false);
  });
  it('normalizes comments before directive recognition and static-if selection', async () => {
    await init({ 'comments.j': '/* prefix\ncomment */ //! textmacro M\nfunction Generated takes nothing returns nothing\nendfunction\n//! endtextmacro\n//! runtextmacro M()\n/* comment\nclosed */ static if false then\nfunction Hidden takes nothing returns nothing\nendfunction\nendif\n' });
    expect(cg!.getNodesByQualifiedName('Generated')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('Hidden')).toHaveLength(0);
    expect(cg!.getFiles().some(f => f.errors?.some(e => e.severity === 'error'))).toBe(false);
  });
  it('does not execute external tools or parse their input payload as JASS code', async () => {
    await init({ 'external.j': '//! externalblock extension=lua ToolName\n//! i function Fake takes nothing returns nothing\n//! i call Evil()\n//! endexternalblock\nfunction Real takes nothing returns nothing\nendfunction\n' });
    expect(cg!.getNodesByQualifiedName('Fake')).toHaveLength(0);
    expect(cg!.getNodesByQualifiedName('Real')).toHaveLength(1);
    const file = cg!.getNodesInFile('external.j').find(n => n.kind === 'file')!;
    expect(file.semanticData?.externalTools).toEqual([expect.objectContaining({ kind: 'externalblock', outputs: 'not-inferred' })]);
    expect(cg!.getFiles()[0]!.errors?.filter(e => /externalblock.*not expanded/.test(e.message))).toHaveLength(1);
    expect(cg!.getFiles()[0]!.errors?.some(e => /Directive i /.test(e.message))).toBe(false);
  });

  it('keeps module definition scope for SCOPE_PRIVATE dispatch after cross-library implementation', async () => {
    await init({ 'defs.j': 'library Defs\nprivate function Hidden takes nothing returns nothing\nendfunction\nmodule M\nstatic method run takes nothing returns nothing\ncall ExecuteFunc(SCOPE_PRIVATE+"Hidden")\nendmethod\nendmodule\nendlibrary\n',
      'use.j': 'library Use\nprivate function Hidden takes nothing returns nothing\nendfunction\nstruct S extends array\nimplement M\nendstruct\nendlibrary\n' });
    expect(calls('Use.S.run')).toContain('Defs.Hidden');
    expect(calls('Use.S.run')).not.toContain('Use.Hidden');
  });

  it('keeps optional cross-file flags unknown until the build inputs or imports prove their presence', async () => {
    await init({ 'optional.j': 'library Extra\nglobals\nconstant boolean ENABLED=true\nendglobals\nendlibrary\n',
      'use.j': 'static if LIBRARY_Extra and ENABLED then\nfunction Present takes nothing returns nothing\nendfunction\nelse\nfunction Absent takes nothing returns nothing\nendfunction\nendif\n' });
    expect(cg!.getNodesByQualifiedName('Present')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('Absent')).toHaveLength(1);
    expect(cg!.getNodesByQualifiedName('Present')[0]!.semanticData?.conditional).toBe(true);
    fs.writeFileSync(path.join(root, 'use.j'), '//! import "optional.j"\n' + fs.readFileSync(path.join(root, 'use.j'), 'utf8'));
    await cg!.sync({ paths: ['use.j'] }); expect(cg!.getNodesByQualifiedName('Absent')).toHaveLength(0);
  });

  it('preserves full declaration spans across multiline literals and the complete local injection region', async () => {
    await init({ 'spans.j': 'globals\nstring text="first\nsecond"\nendglobals\n//! inject main\nlocal string value="first\nsecond"\n//! dovjassinit\n\n//! endinject\nfunction main takes nothing returns nothing\nendfunction\n' });
    expect(cg!.getNodesByQualifiedName('text')[0]!.endLine).toBe(3);
    const injection = cg!.getNodesByQualifiedName('__jass_inject_main')[0]!;
    expect(injection.endLine).toBe(10);
    expect(cg!.getNodesByQualifiedName('main')[0]!.docstring).toContain('replaces this original body');
  });

});
