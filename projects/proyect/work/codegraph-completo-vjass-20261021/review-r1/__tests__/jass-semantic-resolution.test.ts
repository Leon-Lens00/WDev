import { afterEach, describe, expect, it } from 'vitest';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';
import { CodeGraph } from '../src';

describe('vJASS typed expression resolution', () => {
  let root: string | undefined, graph: CodeGraph | undefined;
  const init = async (source: string) => {
    root = fs.mkdtempSync(path.join(os.tmpdir(), 'cg-jass-semantic-'));
    fs.writeFileSync(path.join(root, 'test.j'), source);
    graph = await CodeGraph.init(root); await graph.indexAll();
  };
  const calls = (name: string) => graph!.getCallees(graph!.getNodesByQualifiedName(name)[0]!.id).filter(x => x.edge.kind === 'calls' || x.edge.kind === 'instantiates' || !!x.edge.metadata?.jassBuiltin).map(x => x.node.qualifiedName);
  afterEach(() => { graph?.destroy(); if (root) fs.rmSync(root, { recursive: true, force: true }); });

  it('traces a factory, field and instance index operator to the actual return type', async () => {
    await init(`struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Box extends array
method operator [] takes integer i returns Leaf
return Leaf(i)
endmethod
endstruct
struct Factory extends array
Box box
static method make takes nothing returns thistype
return 0
endmethod
endstruct
function Run takes nothing returns nothing
call Factory.make().box[0].tick()
endfunction
`);
    expect(calls('Run')).toEqual(expect.arrayContaining(['Factory.make', 'Box.operator []', 'Leaf.tick']));
  });

  it('resolves the operator result, rather than a homonymous method on its receiver', async () => {
    await init(`struct Other extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct S extends array
method operator [] takes integer i returns Other
return Other(i)
endmethod
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
local S scalar = 0 // array
call scalar[0].tick()
endfunction
`);
    expect(calls('Run')).toEqual(expect.arrayContaining(['S.operator []', 'Other.tick']));
    expect(calls('Run')).not.toContain('S.tick');
  });

  it('follows a property return in a chain and distinguishes its read and write operators', async () => {
    await init(`struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Box extends array
method operator leaf takes nothing returns Leaf
return 0
endmethod
method operator leaf= takes Leaf value returns nothing
endmethod
endstruct
function Run takes Box box returns nothing
call box.leaf.tick()
set box.leaf = box.leaf
endfunction
`);
    expect(calls('Run')).toEqual(expect.arrayContaining(['Box.operator leaf', 'Box.operator leaf=', 'Leaf.tick']));
  });

  it('keeps unknown factories and ambiguous receivers unresolved', async () => {
    await init(`struct Other extends array
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes nothing returns nothing
call Unknown().field[0].tick()
endfunction
`);
    expect(calls('Run')).toEqual([]);
  });
  it('follows declared delegate fields without selecting unrelated homonyms', async () => {
    await init(`struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
struct Wrapper extends array
delegate Leaf delegated
endstruct
function Run takes Wrapper w returns nothing
call w.tick()
endfunction
`);
    expect(calls('Run')).toContain('Leaf.tick');
  });

  it('resolves super in the declaring base and preserves overridden calls', async () => {
    await init(`struct Base
stub method tick takes nothing returns nothing
endmethod
endstruct
struct Child extends Base
method tick takes nothing returns nothing
call super.tick()
endmethod
endstruct
function Run takes Child c returns nothing
call c.tick()
endfunction
`);
    expect(calls('Run')).toContain('Child.tick');
    expect(calls('Child.tick')).toContain('Base.tick');
  });

  it('records key declarations and forward keywords without duplicate symbol definitions', async () => {
    await init(`scope Demo
private keyword Later
globals
private key SLOT
endglobals
private function Run takes Later value returns nothing
call value.tick()
endfunction
private struct Later extends array
method tick takes nothing returns nothing
endmethod
endstruct
endscope
`);
    expect(graph!.getNodesByQualifiedName('Demo.Later')).toHaveLength(1);
    expect(graph!.getNodesByQualifiedName('Demo.SLOT')[0]?.kind).toBe('constant');
    expect(calls('Demo.Run')).toContain('Demo.Later.tick');
  });

  it('tracks function-interface values across assignments, aliases and parameter passing', async () => {
    await init(`function interface Callback takes nothing returns nothing
function One takes nothing returns nothing
endfunction
function Two takes nothing returns nothing
endfunction
function Invoke takes Callback cb returns nothing
local Callback callbackAlias = cb
call callbackAlias.evaluate()
endfunction
function Run takes boolean chooseTwo returns nothing
local Callback cb = Callback.One
if chooseTwo then
set cb = Callback.Two
endif
call Invoke(cb)
endfunction
`);
    expect(calls('Invoke')).toEqual(expect.arrayContaining(['One', 'Two']));
    const invoke = graph!.getNodesByQualifiedName('Invoke')[0]!;
    const edges = graph!.getOutgoingEdges(invoke.id).filter(e => e.kind === 'calls');
    expect(edges).toHaveLength(2);
    expect(edges.every(e => e.metadata?.jassCandidate === true)).toBe(true);
  });

  it('resolves a function name value passed to ExecuteFunc without guessing computed names', async () => {
    await init(`function Target takes nothing returns nothing
endfunction
function Run takes string unknown returns nothing
call ExecuteFunc(Target.name)
call ExecuteFunc(unknown)
endfunction
`);
    expect(calls('Run')).toContain('Target');
    const target = graph!.getNodesByQualifiedName('Target')[0]!;
    expect(graph!.getOutgoingEdges(graph!.getNodesByQualifiedName('Run')[0]!.id).some(e => e.kind === 'calls' && e.target === target.id)).toBe(true);
    expect(calls('Target')).toEqual([]);
  });

  it('resolves reverse colon indexing using the array element type', async () => {
    await init(`struct Leaf extends array
method tick takes nothing returns nothing
endmethod
endstruct
globals
Leaf array leaves
endglobals
function Run takes integer index returns nothing
call Leaf(index:leaves).tick()
endfunction
`);
    expect(calls('Run')).toContain('Leaf.tick');
  });

  it('synthesizes hook call-site dependencies and removes them when wiring is deleted', async () => {
    await init(`function OnRemoval takes unit u returns nothing
endfunction
function Run takes unit u returns nothing
call RemoveUnit(u)
endfunction
`);
    fs.writeFileSync(path.join(root!, 'api.j'), 'native RemoveUnit takes unit u returns nothing\n');
    fs.writeFileSync(path.join(root!, 'hook.j'), 'hook RemoveUnit OnRemoval\n');
    await graph!.sync({ paths: ['api.j', 'hook.j'] });
    expect(calls('Run')).toContain('OnRemoval');
    const run = graph!.getNodesByQualifiedName('Run')[0]!;
    expect(graph!.getOutgoingEdges(run.id).some(e => e.metadata?.synthesizedBy === 'jass-hook' && e.metadata?.registeredAt === 'hook.j:1')).toBe(true);
    fs.unlinkSync(path.join(root!, 'hook.j'));
    await graph!.sync({ paths: ['hook.j'] });
    expect(calls('Run')).not.toContain('OnRemoval');
  });

  it('connects abstract interface and stub declarations to known implementations as candidates', async () => {
    await init(`interface I
method tick takes nothing returns nothing defaults nothing
endinterface
struct A extends I
method tick takes nothing returns nothing
endmethod
endstruct
struct B extends I
method tick takes nothing returns nothing
endmethod
endstruct
function Run takes I value returns nothing
call value.tick()
endfunction
`);
    const start = graph!.getNodesByQualifiedName('Run')[0]!, end = graph!.getNodesByQualifiedName('A.tick')[0]!;
    expect(graph!.findPath(start.id, end.id, ['calls'])).toBeTruthy();
    expect(calls('I.tick')).toEqual(expect.arrayContaining(['A.tick', 'B.tick']));
  });

  it('parses comparison interface shorthand and connects comparison operator calls', async () => {
    await init(`interface Ordered
method operator <
endinterface
struct Value extends Ordered
method operator < takes Value other returns boolean
return false
endmethod
endstruct
function Run takes Value a, Value b returns boolean
return a < b
endfunction
`);
    expect(calls('Run')).toContain('Value.operator <');
    expect(graph!.getNodesByQualifiedName('Ordered.operator <')[0]?.isAbstract).toBe(true);
    expect(graph!.getFiles().flatMap(f => f.errors ?? []).some(e => e.severity === 'error')).toBe(false);
  });

  it('models compiler destruction callbacks including their base chain without inventing method bodies', async () => {
    await init(`function BaseCleanup takes nothing returns nothing
endfunction
function ChildCleanup takes nothing returns nothing
endfunction
struct Base
method onDestroy takes nothing returns nothing
call BaseCleanup()
endmethod
endstruct
struct Child extends Base
method onDestroy takes nothing returns nothing
call ChildCleanup()
endmethod
endstruct
function Run takes Child value returns nothing
call value.destroy()
endfunction
`);
    expect(calls('Run')).toEqual(expect.arrayContaining(['Child.onDestroy', 'Base.onDestroy']));
    expect(calls('Child.onDestroy')).toContain('ChildCleanup');
    expect(calls('Base.onDestroy')).toContain('BaseCleanup');
  });

  it('preserves JassHelper type erasure through grouped receivers instead of inventing a method call', async () => {
    await init(`struct S extends array
method tick takes nothing returns nothing
endmethod
static method make takes nothing returns thistype
return 0
endmethod
endstruct
function Run takes nothing returns nothing
call (S.make()).tick()
endfunction
`);
    expect(calls('Run')).toContain('S.make');
    expect(calls('Run')).not.toContain('S.tick');
  });

  const fixture = (name: string) => fs.readFileSync(path.join(__dirname, 'fixtures/jass-conformance', name + '.j'), 'utf8');
  it('resolves nested dynamic array elements and their generated lifecycle without fake methods', async () => {
    await init(fixture('dynamic'));
    expect(calls('Run')).toContain('Leaf.tick');
    const run = graph!.getNodesByQualifiedName('Run')[0]!;
    const edges = graph!.getOutgoingEdges(run.id);
    expect(edges.filter(e => e.metadata?.jassBuiltin === 'array-create')).toHaveLength(2);
    expect(edges.some(e => e.metadata?.jassBuiltin === 'array-destroy')).toBe(true);
    expect(graph!.getNodesByQualifiedName('Row.create')).toHaveLength(0);
  });
  it('preserves both dimensions before resolving the array element type', async () => {
    await init(fixture('multidim'));
    const run = graph!.getNodesByQualifiedName('Run')[0]!;
    expect(graph!.getOutgoingEdges(run.id).filter(e => e.kind === 'calls' && graph!.getNode(e.target)?.qualifiedName === 'Leaf.tick')).toHaveLength(2);
  });
  it('includes known subtype destruction callbacks on a base-typed receiver', async () => {
    await init(fixture('base-destroy'));
    expect(calls('Run')).toEqual(expect.arrayContaining(['Base.onDestroy', 'Child.onDestroy']));
  });
  it('retains the constructed subtype through an inherited create method', async () => {
    await init(fixture('constructor'));
    expect(calls('Run')).toEqual(expect.arrayContaining(['Base.create', 'Child.tick']));
  });
  it('links a sized primitive or struct array property to its real declaration', async () => {
    await init(fixture('array-size'));
    const run = graph!.getNodesByQualifiedName('Run')[0]!;
    expect(graph!.getOutgoingEdges(run.id).some(e => e.metadata?.jassBuiltin === 'array-size')).toBe(true);
  });

  it('tracks constant function-name concatenation and lexical scope prefixes', async () => {
    await init(`function Target takes nothing returns nothing
endfunction
globals
constant string PREFIX = "Tar"
endglobals
library Demo
private function PrivateTarget takes nothing returns nothing
endfunction
public function PublicTarget takes nothing returns nothing
endfunction
function Run takes string unknownName returns nothing
call ExecuteFunc(PREFIX+"get")
call ExecuteFunc(SCOPE_PRIVATE+"PrivateTarget")
call ExecuteFunc(SCOPE_PREFIX+"PublicTarget")
call ExecuteFunc(unknownName+"Target")
endfunction
endlibrary
`);
    const run = graph!.getNodesByQualifiedName('Demo.Run')[0]!;
    const targets = graph!.getOutgoingEdges(run.id).filter(e => e.metadata?.resolutionScope === 'function-name-value').map(e => graph!.getNode(e.target)?.qualifiedName);
    expect(targets.sort()).toEqual(['Demo.PrivateTarget', 'Demo.PublicTarget', 'Target']);
  });
  it('keeps field and global reads/writes as dependencies with real storage targets', async () => {
    await init(`globals
integer Counter = 0
endglobals
struct S
integer value
method run takes nothing returns nothing
set this.value = Counter
set Counter = this.value
endmethod
endstruct
`);
    const run = graph!.getNodesByQualifiedName('S.run')[0]!;
    expect(graph!.getOutgoingEdges(run.id).filter(e => e.kind === 'references').map(e => graph!.getNode(e.target)?.qualifiedName)).toEqual(expect.arrayContaining(['S.value', 'Counter']));
    expect(calls('S.run')).toEqual([]);
  });

  it('preserves static method name/execute/evaluate objects through chained return values', async () => {
    await init(fixture('method-helpers'));
    expect(calls('Run')).toEqual(expect.arrayContaining(['Factory.make', 'Factory.target', 'Leaf.tick']));
    const run = graph!.getNodesByQualifiedName('Run')[0]!;
    expect(graph!.getOutgoingEdges(run.id).some(e => e.metadata?.resolutionScope === 'function-name-value' && graph!.getNode(e.target)?.qualifiedName === 'Factory.target')).toBe(true);
  });

  it('invokes comparison operators for typed operands while keeping comparisons to zero primitive', async () => {
    await init(fixture('compare-zero'));
    const run = graph!.getNodesByQualifiedName('Run')[0]!;
    expect(graph!.getOutgoingEdges(run.id).filter(e => graph!.getNode(e.target)?.qualifiedName === 'S.operator <')).toHaveLength(1);
  });
  it('models deallocate callbacks within their owning struct and rejects private builtin access from outside', async () => {
    await init(fixture('deallocate-internal') + '\nfunction Bad takes S s returns nothing\ncall s.deallocate()\ncall S.allocate()\nendfunction\n');
    expect(calls('S.release')).toContain('S.onDestroy');
    const bad = graph!.getNodesByQualifiedName('Bad')[0]!;
    expect(graph!.getOutgoingEdges(bad.id).some(e => ['allocate', 'deallocate'].includes(String(e.metadata?.jassBuiltin)))).toBe(false);
  });
  it('compares lowered function-interface signatures while preserving the source variable receiver type', async () => {
    await init(fixture('interface-compatible'));
    expect(calls('Run')).toEqual(expect.arrayContaining(['Target', 'A.tick']));
  });
  it('does not give function-interface helper expressions a struct result receiver that JassHelper rejects', async () => {
    await init('struct A extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nfunction interface Callback takes nothing returns A\nfunction Target takes nothing returns A\nreturn A(1)\nendfunction\nfunction Bad takes nothing returns nothing\nlocal Callback cb=Callback.Target\ncall cb.evaluate().tick()\nendfunction\n');
    expect(calls('Bad')).toContain('Target');
    expect(calls('Bad')).not.toContain('A.tick');
  });

  it('resolves runtime function spellings without confusing lexical graph scopes or private names', async () => {
    await init('library Demo\nfunction Plain takes nothing returns nothing\nendfunction\npublic function Published takes nothing returns nothing\nendfunction\nprivate function Hidden takes nothing returns nothing\nendfunction\nfunction Run takes nothing returns nothing\ncall ExecuteFunc("Plain")\ncall ExecuteFunc("Demo_Published")\ncall ExecuteFunc("Hidden")\ncall ExecuteFunc("Demo.Hidden")\nendfunction\nendlibrary\n');
    const run = graph!.getNodesByQualifiedName('Demo.Run')[0]!;
    expect(graph!.getOutgoingEdges(run.id).filter(e => e.metadata?.resolutionScope === 'literal-execute-func').map(e => graph!.getNode(e.target)?.qualifiedName).sort()).toEqual(['Demo.Plain', 'Demo.Published']);
  });
  it('does not replace an inaccessible declared constructor with a fictional public builtin', async () => {
    await init('struct S\nprivate static method create takes nothing returns thistype\nreturn thistype.allocate()\nendmethod\nendstruct\nfunction Bad takes nothing returns nothing\nlocal S s=S.create()\nendfunction\n');
    expect(calls('Bad')).not.toContain('S');
    expect(calls('Bad')).not.toContain('S.create');
  });

  it('does not choose one concrete receiver from incompatible conditional field types', async () => {
    await init('struct A extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nstruct B extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nstruct S extends array\nstatic if DEBUG_MODE then\nA child\nelse\nB child\nendif\nmethod run takes nothing returns nothing\ncall this.child.tick()\nendmethod\nendstruct\n');
    expect(calls('S.run')).not.toContain('A.tick'); expect(calls('S.run')).not.toContain('B.tick');
    fs.writeFileSync(path.join(root!, 'codegraph.json'), JSON.stringify({ jass: { mode: 'debug' } }));
    await graph!.sync({ paths: ['codegraph.json'] }); expect(calls('S.run')).toContain('A.tick');
  });
  it('does not invent a return receiver when conditional factories declare different types', async () => {
    await init('struct A extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nstruct B extends array\nmethod tick takes nothing returns nothing\nendmethod\nendstruct\nstruct S extends array\nstatic if DEBUG_MODE then\nstatic method make takes nothing returns A\nreturn A(1)\nendmethod\nelse\nstatic method make takes nothing returns B\nreturn B(1)\nendmethod\nendif\nstatic method run takes nothing returns nothing\ncall thistype.make().tick()\nendmethod\nendstruct\n');
    expect(calls('S.run')).not.toContain('A.tick'); expect(calls('S.run')).not.toContain('B.tick');
    expect(calls('S.run')).toContain('S.make');
  });

});
