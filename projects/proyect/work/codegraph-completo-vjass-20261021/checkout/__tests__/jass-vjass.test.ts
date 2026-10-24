import { afterEach, describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { CodeGraph } from '../src';
import { extractFromSource } from '../src/extraction/tree-sitter';
import { detectLanguage, getSupportedLanguages } from '../src/extraction/grammars';
import { createDatabase } from '../src/db/sqlite-adapter';
import { ToolHandler } from '../src/mcp/tools';

const fn = (name: string, body = '', prefix = '') => `${prefix}function ${name} takes nothing returns nothing\n${body}\nendfunction\n`;

describe('JASS/vJASS structural extraction', () => {
  it('detects all three extensions, including uppercase', () => {
    expect(detectLanguage('a.j')).toBe('jass');
    expect(detectLanguage('a.JASS')).toBe('jass');
    expect(detectLanguage('a.VJASS')).toBe('vjass');
    expect(getSupportedLanguages()).toEqual(expect.arrayContaining(['jass', 'vjass']));
  });

  it('extracts containers, fields, parameter/local types, returns and native signatures', () => {
    const source = `type widget extends handle\nnative NativePing takes widget w returns integer\nlibrary Demo initializer Init requires optional Utils\nglobals\n private integer N = NativePing(null)\nendglobals\nstruct Counter\n real speed\n method tick takes Counter other returns thistype\n local Counter c = other\n call c.tick(this)\n return this\n endmethod\nendstruct\n${fn('Init')}endlibrary\n`;
    const result = extractFromSource('demo.vjass', source);
    expect(result.errors).toEqual([]);
    expect(result.nodes.map(n => [n.kind, n.qualifiedName])).toEqual(expect.arrayContaining([
      ['type_alias', 'widget'], ['function', 'NativePing'], ['parameter', 'NativePing.w'],
      ['namespace', 'Demo'], ['variable', 'Demo.N'], ['struct', 'Demo.Counter'],
      ['field', 'Demo.Counter.speed'], ['method', 'Demo.Counter.tick'],
      ['parameter', 'Demo.Counter.tick.other'], ['variable', 'Demo.Counter.tick.c'],
    ]));
    expect(result.unresolvedReferences).toEqual(expect.arrayContaining([
      expect.objectContaining({ referenceName: 'Utils', referenceKind: 'imports' }),
      expect.objectContaining({ referenceName: 'Init', referenceKind: 'calls' }),
      expect.objectContaining({ referenceName: 'NativePing', referenceKind: 'calls' }),
      expect.objectContaining({ referenceName: expect.stringMatching(/^__jass_expr__:/), referenceKind: 'calls' }),
    ]));
    expect(result.nodes.find(n => n.qualifiedName === 'Demo.Counter.tick')?.endLine).toBe(13);
  });

  it('ignores literal/comment call-shaped text and preserves BOM/CRLF locations', () => {
    const source = '\uFEFF' + fn('Run', ' local string x = "call Fake() //! textmacro M"\n local integer id = \'hfoo\'\n // call Comment()\n /* call Block() */\n call Real()').replace(/\n/g, '\r\n');
    const result = extractFromSource('main.j', source);
    expect(result.errors).toEqual([]);
    expect(result.unresolvedReferences.filter(r => r.referenceKind === 'calls').map(r => [r.referenceName, r.line])).toEqual([['Real', 6]]);
    expect(result.nodes.find(n => n.name === 'Run')?.startLine).toBe(1);
  });

  it('excludes templates and Zinc, exposes directives, and does not treat a commented directive as real', () => {
    const source = `/*\n//! zinc\n*/\n//! textmacro M\n${fn('Template')}//! endtextmacro\n//! zinc\nfunction NotJass() {}\n//! endzinc\n//! runtextmacro M()\n//! import "not-followed.j"\n${fn('Real')}`;
    const result = extractFromSource('main.j', source);
    expect(result.nodes.filter(n => n.kind === 'function').map(n => n.name)).toEqual(['Template', 'Real']);
    expect(result.errors.some(e => /Zinc|zinc/.test(e.message))).toBe(true);
    expect(result.errors.some(e => /Static projection/.test(e.message))).toBe(true);
  });

  it('reports malformed input instead of claiming a complete parse', () => {
    for (const body of ['function Broken takes nothing returns nothing\n', 'endstruct\n', 'globals\n', '/* broken', '"broken\n', '//! zinc\n']) {
      expect(extractFromSource('broken.j', body).errors.some(e => e.severity === 'error')).toBe(true);
    }
  });

  it('excludes novjass documentation without corrupting the enclosing scope or source locations', () => {
    const source = `library Demo\n//! novjass\nstruct Documented\n method fake takes nothing returns nothing\n call Ghost()\n//! endnovjass\n${fn('Real')}endlibrary\n`;
    const result = extractFromSource('docs.vjass', source);
    expect(result.errors.filter(e => e.severity === 'error')).toEqual([]);
    expect(result.nodes.filter(n => n.kind === 'function').map(n => [n.qualifiedName, n.startLine])).toEqual([['Demo.Real', 7]]);
    expect(result.nodes.some(n => n.name === 'Documented' || n.name === 'fake')).toBe(false);
    expect(result.unresolvedReferences.some(r => r.referenceName === 'Ghost')).toBe(false);
  });

  it('does not lex excluded template and novjass contents as active JASS literals/comments', () => {
    const source = `//! textmacro T takes NAME\nfunction $NAME$ takes nothing returns nothing\n local string s = "unclosed template fragment\n/* template fragment\n//! endtextmacro\n//! novjass\n"arbitrary documentation\n//! endnovjass\n${fn('Real', ' call Ping()')}`;
    const result = extractFromSource('excluded.vjass', source);
    expect(result.errors.filter(e => e.severity === 'error')).toEqual([]);
    expect(result.nodes.filter(n => n.kind === 'function').map(n => n.name)).toEqual(['Real']);
    expect(result.unresolvedReferences.map(r => r.referenceName)).toEqual(['Ping']);
  });

  it('captures explicit callbacks, qualified callbacks and potential dynamic boundaries', () => {
    const result = extractFromSource('callback.j', fn('Wire', ' call TimerStart(t, 1., false, function Done)\n call Register(function Counter.done)\n call ExecuteFunc("Hidden")\n call Do.evaluate()'));
    expect(result.unresolvedReferences.filter(r => r.referenceKind === 'function_ref').map(r => r.referenceName)).toEqual(['Done', 'Counter.done']);
    expect(result.unresolvedReferences.some(r => r.referenceName === 'Hidden')).toBe(false);
    expect(result.errors.filter(e => e.severity === 'warning')).toHaveLength(1);
  });

  it('does not invent this.method for a chained factory/index receiver', () => {
    const result = extractFromSource('chain.vjass', fn('Run', ' call Factory().tick()\n call values[0].tick()'));
    expect(result.unresolvedReferences.some(r => r.referenceName === 'this.tick')).toBe(false);
    expect(result.errors.filter(e => e.severity === 'warning')).toHaveLength(0);
    expect(result.unresolvedReferences.filter(r => r.referenceKind === 'calls' && r.referenceName.startsWith('__jass_expr__:'))).toHaveLength(2);
    expect(result.unresolvedReferences.some(r => r.referenceName === 'Factory')).toBe(true);
  });

  it('interfaces have bodyless method declarations and module expansion stays explicit', () => {
    const result = extractFromSource('types.vjass', 'interface I\n method tick takes nothing returns nothing defaults nothing\nendinterface\nmodule M\n method ping takes nothing returns nothing\n endmethod\nendmodule\nstruct S\n implement M\nendstruct\n');
    expect(result.errors.some(e => e.severity === 'error')).toBe(false);
    expect(result.nodes.some(n => n.qualifiedName === 'S.ping')).toBe(true);
    expect(result.errors.some(e => /Static projection/.test(e.message))).toBe(true);
    expect(result.nodes.find(n => n.qualifiedName === 'I.tick')?.isAbstract).toBe(true);
  });

  it('does not merge distinct operator bodies and makes missing access dispatch explicit', () => {
    const result = extractFromSource('operators.vjass', 'struct S\n method operator value takes nothing returns integer\n return 0\n endmethod\n method operator value= takes integer v returns nothing\n endmethod\nendstruct\n');
    expect(result.nodes.filter(n => n.kind === 'method').map(n => n.name)).toEqual(['operator value', 'operator value=']);
    expect(result.errors.filter(e => e.severity === 'error')).toHaveLength(0);
  });

  it('keeps unterminated multiline strings out of executable references', () => {
    const result = extractFromSource('literal.j', fn('Run', ' local string x = "broken\\\n call Real()'));
    expect(result.errors.some(e => e.code === 'jass_parse_error')).toBe(true);
    expect(result.unresolvedReferences.some(r => r.referenceName === 'Real')).toBe(false);
  });

  it('accepts JassHelper multiline strings and preserves following call coordinates', () => {
    const source = fn('Run', ' local string s = "first\n call Fake()\n//! zinc\nlast"\n call Real()').replace(/\n/g, '\r\n');
    const result = extractFromSource('multiline.vjass', source);
    expect(result.errors).toEqual([]);
    expect(result.unresolvedReferences.filter(r => r.referenceKind === 'calls').map(r => [r.referenceName, r.line, r.column])).toEqual([['Real', 6, 6]]);
    expect(result.nodes.find(n => n.name === 'Run')?.endLine).toBe(7);
  });

  it('ignores unrelated preprocessor markers inside inactive novjass documentation', () => {
    const result = extractFromSource('docs.j', `//! novjass\n//! zinc\n//! endzinc\n//! textmacro EXAMPLE\n//! endtextmacro\n//! endnovjass\n${fn('Real')}`);
    expect(result.errors).toEqual([]);
    expect(result.nodes.filter(n => n.kind === 'function').map(n => n.name)).toEqual(['Real']);
  });
});

describe('JASS/vJASS original CodeGraph SQLite/index/resolver/sync', { timeout: 60_000 }, () => {
  let root: string;
  let cg: CodeGraph | undefined;
  const write = (file: string, source: string) => fs.writeFileSync(path.join(root, file), source);
  const init = async (files: Record<string, string>) => {
    root = fs.mkdtempSync(path.join(os.tmpdir(), 'codegraph-jass-'));
    for (const [file, source] of Object.entries(files)) write(file, source);
    cg = await CodeGraph.init(root);
    const result = await cg.indexAll();
    expect(result.success, JSON.stringify(result.errors)).toBe(true);
    return cg;
  };
  const symbol = (qualified: string) => cg!.getNodesByQualifiedName(qualified)[0]!;
  const callees = (qualified: string) => cg!.getCallees(symbol(qualified).id).filter(c => c.edge.kind === 'calls' || c.edge.kind === 'instantiates' || !!c.edge.metadata?.jassBuiltin || ['function', 'method'].includes(c.node.kind)).map(c => c.node.qualifiedName).sort();
  const edges = () => {
    const { db } = createDatabase(path.join(root, '.codegraph', 'codegraph.db'), { readOnly: true });
    try { return new Set((db.prepare('SELECT source,target,kind FROM edges').all() as Array<{ source: string; target: string; kind: string }>).map(e => `${e.source}|${e.target}|${e.kind}`)); }
    finally { db.close(); }
  };
  afterEach(() => { cg?.destroy(); cg = undefined; if (root) fs.rmSync(root, { recursive: true, force: true }); });

  it('persists native edges, cross-file callbacks, callers, impact and reopen', async () => {
    await init({ 'api.j': fn('Ping'), 'callback.jass': fn('Done', ' call Ping()'),
      'main.vjass': fn('Run', ' call Ping()\n call Register(function Done)'), 'native.j': 'native Register takes code callback returns nothing\n' });
    expect(cg!.getFiles()).toHaveLength(4);
    expect(callees('Run')).toEqual(['Done', 'Ping', 'Register']);
    expect(cg!.getCallers(symbol('Ping').id).map(c => c.node.name).sort()).toEqual(['Done', 'Run']);
    expect(cg!.getImpactRadius(symbol('Ping').id).nodes.has(symbol('Run').id)).toBe(true);
    const before = edges();
    cg!.destroy();
    cg = await CodeGraph.open(root);
    expect(edges()).toEqual(before);
    expect(callees('Run')).toContain('Ping');
    const explored = await new ToolHandler(cg).execute('codegraph_explore', { query: 'Run Ping Done' });
    expect(explored.isError).not.toBe(true);
    expect(explored.content[0]?.text).toContain('JASS/vJASS local support');
    expect(explored.content[0]?.text).toContain('call Ping()');
  });

  it('labels static JASS links without claiming dynamic dispatch, with and without a flow', async () => {
    await init({ 'main.j': fn('Start', ' call Run()') + fn('Run', ' call Ping()\n call Other()') + fn('Ping') + fn('Other') });
    const handler = new ToolHandler(cg!);
    for (const query of ['Run Ping', 'Start Run Ping']) {
      const result = await handler.execute('codegraph_explore', { query });
      const text = result.content[0]?.text as string;
      expect(result.isError).not.toBe(true);
      expect(text).toContain('**Additional graph links among your symbols**');
      expect(text).toContain('[static JASS: calls]');
      expect(text).not.toContain('**Dynamic-dispatch links');
      expect(text).not.toContain('[dynamic:');
      if (query.startsWith('Start')) expect(text).toContain('**Flow (call path');
      else expect(text).not.toContain('**Flow (call path');
    }
  });

  it('uses scoped private functions, explicit public prefixes, exact case and no cross-language fallback', async () => {
    await init({
      'one.j': `library One\n${fn('Hidden', '', 'private ')}${fn('Exported', '', 'public ')}${fn('Inside', ' call Hidden()\n call Exported()')}endlibrary\n`,
      'two.jass': `library Two\n${fn('Hidden', '', 'private ')}${fn('Inside', ' call Hidden()')}endlibrary\n`,
      'main.vjass': fn('Run', ' call Hidden()\n call Exported()\n call One_Exported()\n call inside()\n call JsOnly()'),
      'other.js': 'function JsOnly() {}\n',
    });
    expect(callees('One.Inside')).toEqual(['One.Exported', 'One.Hidden']);
    expect(callees('Two.Inside')).toEqual(['Two.Hidden']);
    expect(callees('Run')).toEqual(['One.Exported']);
  });

  it('resolves declared locals, parameters, fields, this/thistype and inherited methods without name guessing', async () => {
    await init({
      'types.vjass': `library Demo\nstruct Base\n method tick takes nothing returns nothing\n endmethod\nendstruct\nstruct Child extends Base\n Child child\n static method start takes nothing returns nothing\n endmethod\n method run takes Child other returns nothing\n local Child c = other\n call c.tick()\n call other.tick()\n call this.tick()\n call .tick()\n call this.child.tick()\n call thistype.start()\n call mystery.tick()\n endmethod\nendstruct\nendlibrary\n`,
    });
    expect(callees('Demo.Child.run')).toEqual(['Demo.Base.tick', 'Demo.Child.start']);
    const { db } = createDatabase(path.join(root, '.codegraph', 'codegraph.db'), { readOnly: true });
    try {
      const rows = db.prepare("SELECT line,metadata FROM edges WHERE source=? AND kind='calls'").all(symbol('Demo.Child.run').id) as Array<{ line: number; metadata: string }>;
      expect(rows).toHaveLength(6);
      expect(rows.every(e => JSON.parse(e.metadata).jassStaticSubset)).toBe(true);
    } finally { db.close(); }
  });

  it('does not resolve an ambiguous free function or unknown receiver to a unique method', async () => {
    await init({ 'a.j': fn('Duplicate'), 'b.jass': fn('Duplicate'),
      'type.vjass': 'struct S\n method tick takes nothing returns nothing\n endmethod\nendstruct\n',
      'main.j': fn('Run', ' call Duplicate()\n call missing.tick()\n call tick()') });
    expect(callees('Run')).toEqual([]);
  });

  it('attributes local initializer calls and callbacks to the enclosing function, like upstream extraction', async () => {
    await init({ 'init.j': `function Make takes nothing returns integer\n return 1\nendfunction\n${fn('Done')}${fn('Run', ' local integer value = Make()\n local code callback = function Done')}` });
    expect(callees('Run')).toEqual(['Done', 'Make']);
    expect(cg!.getCallers(symbol('Make').id).map(c => c.node.qualifiedName)).toEqual(['Run']);
  });

  it('resolves unqualified methods inside the declaring struct without leaking member names outside', async () => {
    await init({ 'methods.vjass': `${fn('ping')}struct Counter\n static method ping takes nothing returns nothing\n endmethod\n static method internalOnly takes nothing returns nothing\n endmethod\n static method run takes nothing returns nothing\n call ping()\n endmethod\nendstruct\n${fn('Outside', ' call ping()\n call internalOnly()')}` });
    expect(callees('Counter.run')).toEqual(['Counter.ping']);
    expect(callees('Outside')).toEqual(['ping']);
  });

  it('uses parsed inheritance rather than extends text inside header comments', async () => {
    await init({ 'bases.j': `struct WrongBase\n method tick takes nothing returns nothing\n endmethod\nendstruct\nstruct CorrectBase\n method tick takes nothing returns nothing\n endmethod\nendstruct\nstruct Child /* extends WrongBase */ extends CorrectBase\nendstruct\nfunction Probe takes Child c returns nothing\n call c.tick()\nendfunction\n` });
    expect(callees('Probe')).toEqual(['CorrectBase.tick']);
  });

  it('preserves ambiguous conditional members without falling through to a global homonym', async () => {
    await init({ 'conditional.j': `${fn('ping')}struct S\n static if FLAG then\n static method ping takes nothing returns nothing\n endmethod\n else\n static method ping takes nothing returns nothing\n endmethod\n endif\n static method run takes nothing returns nothing\n call ping()\n endmethod\nendstruct\n` });
    expect(callees('S.run')).toEqual(['S.ping', 'S.ping']);
    const possible = cg!.getOutgoingEdges(symbol('S.run').id).filter(e => e.kind === 'calls');
    expect(possible).toHaveLength(2);
    expect(possible.every(e => e.metadata?.jassCandidate === true && e.metadata?.jassConditional === true)).toBe(true);
  });

  it('does not treat extends array as an unknown inherited member namespace', async () => {
    await init({ 'array.j': `${fn('GlobalHelper')}struct S extends array\n static method run takes nothing returns nothing\n call GlobalHelper()\n endmethod\nendstruct\n` });
    expect(callees('S.run')).toEqual(['GlobalHelper']);
  });

  it('resolves ordinary declared execute/evaluate methods on known receivers', async () => {
    await init({ 'names.j': `struct S\n method execute takes nothing returns nothing\n endmethod\n method evaluate takes nothing returns nothing\n endmethod\nendstruct\nfunction Probe takes S s returns nothing\n call s.execute()\n call s.evaluate()\nendfunction\n` });
    expect(callees('Probe')).toEqual(['S.evaluate', 'S.execute']);
  });

  it('preserves JASS coverage warnings in secondary symbol, overload and file responses', async () => {
    await init({ 'one.j': `${fn('Ping')}//! runtextmacro NOT_EXPANDED()\n`, 'two.j': `library Two\n${fn('Ping')}endlibrary\n` });
    const handler = new ToolHandler(cg!);
    for (const args of [{symbol:'Ping',includeCode:true},{symbol:'Ping',file:'one.j',includeCode:true},{file:'one.j'}]) {
      const response = await handler.execute('codegraph_node', args);
      expect(response.isError).not.toBe(true);
      expect(response.content[0]?.text).toContain('JASS/vJASS local support');
      expect(response.content[0]?.text).toContain('NOT_EXPANDED: definition unavailable');
    }
  });

  it('syncs changes, additions, deletion and line shifts to the same edge set as a fresh rebuild', async () => {
    await init({ 'api.j': fn('Ping'), 'main.vjass': fn('Run', ' call Ping()') });
    write('api.j', '\n' + fn('Ping', ' call Pong()'));
    write('new.jass', fn('Pong'));
    await cg!.sync();
    expect(callees('Ping')).toEqual(['Pong']);
    expect(callees('Run')).toEqual(['Ping']);
    fs.unlinkSync(path.join(root, 'new.jass'));
    await cg!.sync();
    expect(callees('Ping')).toEqual([]);
    const synced = edges();
    cg!.destroy();
    cg = await CodeGraph.recreate(root);
    await cg.indexAll();
    expect(edges()).toEqual(synced);
    expect(callees('Run')).toEqual(['Ping']);
  });
});
