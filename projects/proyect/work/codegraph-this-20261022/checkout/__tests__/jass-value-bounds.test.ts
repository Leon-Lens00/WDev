import { describe, it, expect } from 'vitest';
import { collectJassFunctionValues } from '../src/resolution/jass-value-flow';
import { resolveJassExpression } from '../src/resolution/jass-expression';
import { evaluateJassConstant } from '../src/extraction/jass-constant';
import type { JassExpressionEnvironment } from '../src/resolution/jass-expression';
import type { Node } from '../src/types';

describe('JASS constant value bounds', () => {
  it('bounds shared constant dependency expansion instead of visiting exponential leaves', () => {
    const declarations=new Map<string,Node>();
    for(let i=0;i<21;i++) declarations.set('S'+i, { id:'S'+i,name:'S'+i,qualifiedName:'S'+i,kind:'constant',language:'jass',filePath:'test.j',startLine:i+1,semanticData:{values:[i?{kind:'binary',operator:'+',left:{kind:'name',name:'S'+(i-1)},right:{kind:'name',name:'S'+(i-1)}}:{kind:'literal',value:'""',literalKind:'string'}]} } as Node);
    let lookups=0; const root=declarations.get('S20')!;
    const env={from:root,lookup:(name:string)=>{if(++lookups>512)throw new Error('Unbounded constant expansion');return declarations.get(name);},context:{getNodesByKind:()=>[],getNodesByQualifiedName:()=>[]}} as unknown as JassExpressionEnvironment;
    expect(()=>collectJassFunctionValues(root,env)).not.toThrow();
    expect(lookups).toBeLessThan(512);
  });
  it('refuses constant string concatenation before materializing excessive output', () => {
    const literal={kind:'literal' as const,literalKind:'string',value:'"'+'x'.repeat(40000)+'"'};
    expect(evaluateJassConstant({kind:'binary',operator:'+',left:literal,right:literal} as any,()=>undefined) === undefined).toBe(true);
  });
  it('refuses foreign destructor targets even when a context supplies a colliding qualified name', () => {
    const type={id:'S',kind:'struct',name:'S',qualifiedName:'S',language:'jass',signature:'struct S'} as Node;
    const receiver={id:'s',kind:'parameter',name:'s',qualifiedName:'Run.s',language:'jass'} as Node;
    const foreign={id:'foreign',kind:'method',name:'onDestroy',qualifiedName:'S.onDestroy',language:'typescript',isStatic:false} as Node;
    const env={from:receiver,lookup:()=>receiver,declaredType:()=>type,member:()=>undefined,named:()=>null,context:{getNodesByKind:()=>[type],getNodesByQualifiedName:()=>[foreign]}} as unknown as JassExpressionEnvironment;
    const reference={referenceName:'__jass_expr__:'+JSON.stringify({access:'call',expression:{kind:'call',callee:{kind:'member',object:{kind:'name',name:'s'},name:'destroy'},args:[]}})} as any;
    expect(resolveJassExpression(reference,env)?.targetNodeId).not.toBe('foreign');
  });

});
