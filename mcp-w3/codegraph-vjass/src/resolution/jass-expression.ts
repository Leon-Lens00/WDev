import type { Node } from '../types';
import type { JassExpression } from '../extraction/jass-expression';
import { lexJass } from '../extraction/jass-lexer';
import { collectJassFunctionValues } from './jass-value-flow';
import type { ResolvedRef, UnresolvedRef, ResolutionContext } from './types';

export interface JassExpressionEnvironment {
  from: Node;
  context: ResolutionContext;
  owningType?: Node;
  lookup(name: string, kinds: Set<string>, anchor?: Node): Node | undefined;
  member(type: Node, name: string, kinds: Set<string>): Node | null | undefined;
  declaredType(node: Node): Node | undefined;
  named(ref: UnresolvedRef): ResolvedRef | null;
  node(id: string): Node | null | undefined;
}

interface Value { conditional?: boolean; candidates?: Node[]; unknownTargets?: boolean; node?: Node; type?: Node; static?: boolean; array?: boolean; arrayDepth?: number; functionInterfaceDispatch?: boolean; origin?: JassExpression; helper?: boolean; builtin?: string }
const TYPES = new Set(['struct', 'interface', 'type_alias']);
const FIELDS = new Set(['variable', 'parameter', 'field', 'constant']);
const METHODS = new Set(['method']);
const CALLABLE = new Set(['function', 'method']);
const parent = (name: string) => name.includes('.') ? name.slice(0, name.lastIndexOf('.')) : '';
const words = (node: Node) => lexJass(node.signature ?? '').semanticLines.flat().map(t => t.value);
const isArray = (node: Node) => node.semanticData?.isArray === true || words(node).includes('array');

/** Resolve arbitrary expression receivers through declared types. No fuzzy
 * member lookup or execution is involved; unknown values stay unresolved.
 */
export function resolveJassExpression(ref: UnresolvedRef, env: JassExpressionEnvironment): ResolvedRef | null {
  let descriptor: { access: string; expression: JassExpression };
  try { descriptor = JSON.parse(ref.referenceName.slice('__jass_expr__:'.length)); } catch { return null; }
  if (!descriptor || typeof descriptor.access !== 'string' || !descriptor.expression) return null;
  let budget = 256;
  const typeOfReturn = (node: Node): Node | undefined => {
    if (node.semanticData?.conditional === true) {
      const alternatives = env.context.getNodesByQualifiedName(node.qualifiedName).filter(n => n.kind === node.kind && n.semanticData?.conditional === true);
      if (alternatives.some(n => n.returnType !== node.returnType)) return undefined;
    }
    return node.returnType === 'thistype' ? env.lookup(parent(node.qualifiedName), TYPES, node)
      : node.returnType ? env.lookup(node.returnType, TYPES, node) : undefined;
  };
  const arrayElement = (type: Node | undefined): Node | undefined => {
    if (!type || type.kind !== 'type_alias' || !isArray(type)) return type;
    const w = words(type), at = w.indexOf('extends');
    return at >= 0 && w[at + 1] ? env.lookup(w[at + 1]!, TYPES, type) : undefined;
  };
  const binding = (node: Node): Value => {
    const type = env.declaredType(node);
    return { node, type, conditional: node.semanticData?.conditional === true || type?.semanticData?.conditional === true, static: false, array: isArray(node) || !!(type?.kind === 'type_alias' && isArray(type)), arrayDepth: typeof node.semanticData?.arrayDepth === 'number' && node.semanticData.arrayDepth > 0 ? node.semanticData.arrayDepth : 1 };
  };
  const pathname = (expression: JassExpression): string | undefined => {
    if (expression.kind === 'name') return expression.name;
    if (expression.kind !== 'member' || expression.colon) return undefined;
    const prefix = pathname(expression.object);
    return prefix ? prefix + '.' + expression.name : undefined;
  };
  const memberValue = (owner: Value, name: string): Value | undefined => {
    if (owner.functionInterfaceDispatch && ['name', 'exists'].includes(name)) return undefined;
    if (owner.node && CALLABLE.has(owner.node.kind) && ['execute', 'evaluate', 'name', 'exists'].includes(name)) return { ...owner, helper: true, builtin: name };
    if (owner.array && owner.node && ['size', 'width', 'height'].includes(name)) return { node: owner.node, builtin: 'array-' + name };
    if (owner.type?.kind === 'type_alias' && isArray(owner.type)) {
      if ((name === 'create' && owner.static) || (name === 'destroy' && !owner.static) || name === 'size') return { conditional: owner.conditional, node: owner.type, type: owner.type, builtin: 'array-' + name, static: owner.static };
    }
    if (!owner.type) {
      if (owner.node && CALLABLE.has(owner.node.kind) && ['execute', 'evaluate', 'name'].includes(name)) return { ...owner, helper: true, builtin: name };
      return undefined;
    }
    if (owner.type.semanticData?.functionInterface === true) {
      const normalize = (name: string | undefined, anchor: Node): string | undefined => {
        if (!name) return undefined;
        const type = env.lookup(name === 'thistype' ? parent(anchor.qualifiedName) : name, TYPES, anchor);
        return type && (['struct', 'interface'].includes(type.kind) || type.semanticData?.functionInterface === true || (type.kind === 'type_alias' && isArray(type))) ? 'integer' : name;
      };
      const compatible = (node: Node) => {
        const expected = owner.type!.semanticData?.parameterTypes as string[] | undefined;
        const actual = node.semanticData?.parameterTypes as string[] | undefined;
        return normalize(node.returnType, node) === normalize(owner.type!.returnType, owner.type!) && !!expected && !!actual && expected.length === actual.length && expected.every((t, i) => normalize(t, owner.type!) === normalize(actual[i], node));
      };
      if (['execute', 'evaluate'].includes(name) && ((owner.node && FIELDS.has(owner.node.kind)) || owner.origin)) {
        const values = collectJassFunctionValues(owner.origin ?? owner.node!, env);
        const candidates = values.targets.filter(compatible).sort((a, b) => a.qualifiedName.localeCompare(b.qualifiedName));
        return candidates.length ? { node: candidates[0], candidates, unknownTargets: values.unknown, helper: true, builtin: name, functionInterfaceDispatch: true } : undefined;
      }
      const pointer = env.lookup(name, CALLABLE);
      if (pointer && compatible(pointer)) return { node: pointer, helper: true, builtin: 'function-pointer', functionInterfaceDispatch: true };
    }
    const field = env.member(owner.type, name, FIELDS);
    if (field === null) return undefined;
    if (field) return owner.static && !field.isStatic ? undefined : { ...binding(field), conditional: owner.conditional || field.semanticData?.conditional === true || binding(field).conditional };
    const method = env.member(owner.type, name, METHODS);
    if (method === null) return undefined;
    if (method) return owner.static && !method.isStatic ? undefined : { node: method, type: owner.type, static: owner.static, conditional: owner.conditional || method.semanticData?.conditional === true };
    const getter = env.member(owner.type, 'operator ' + name, METHODS);
    if (getter === null) return undefined;
    if (getter) return owner.static && !getter.isStatic ? undefined : { node: getter, type: typeOfReturn(getter), conditional: owner.conditional || getter.semanticData?.conditional === true };
    if (env.context.getNodesByQualifiedName(owner.type.qualifiedName + '.' + name).some(n => (n.language === 'jass' || n.language === 'vjass') && n.kind === 'method')) return undefined;
    if (['allocate', 'create', 'destroy', 'deallocate', 'typeid', 'getType'].includes(name) && owner.type.kind === 'struct' && !/\bextends\s+array\b/.test(owner.type.signature ?? '')) {
      if (['allocate', 'deallocate'].includes(name) && env.owningType?.id !== owner.type.id) return undefined;
      if (['allocate', 'create'].includes(name) !== !!owner.static && !['typeid', 'getType'].includes(name)) return undefined;
      return { conditional: owner.conditional, node: owner.type, type: owner.type, builtin: name, static: owner.static };
    }
    return undefined;
  };
  const infer = (expression: JassExpression, depth = 0): Value | undefined => {
    if (!expression || depth > 48 || --budget < 0) return undefined;
    switch (expression.kind) {
      case 'name': {
        const declared = env.lookup(expression.name, FIELDS);
        if (declared) return binding(declared);
        if (expression.name === 'this' || expression.name === 'thistype') return { type: env.owningType, static: expression.name === 'thistype' };
        if (expression.name === 'super' && env.owningType) {
          const base = env.owningType.signature?.match(/\bextends\s+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)/)?.[1];
          return base && base !== 'array' ? { type: env.lookup(base, TYPES, env.owningType), static: false } : undefined;
        }
        const type = env.lookup(expression.name, TYPES);
        if (type) return { node: type, type, static: true, conditional: type.semanticData?.conditional === true };
        const callable = env.lookup(expression.name, CALLABLE);
        return callable ? { node: callable } : undefined;
      }
      case 'member': {
        if (expression.colon) return infer({ kind: 'index', object: { kind: 'name', name: expression.name, at: expression.at }, index: expression.object, at: expression.at }, depth + 1);
        const full = pathname(expression);
        if (full) {
          const declared = env.lookup(full, FIELDS);
          if (declared && (declared.kind !== 'field' || declared.isStatic)) return binding(declared);
          const type = env.lookup(full, TYPES);
          if (type) return { node: type, type, static: true, conditional: type.semanticData?.conditional === true };
          const callable = env.lookup(full, new Set(['function']));
          if (callable) return { node: callable };
        }
        const owner = infer(expression.object, depth + 1);
        return owner ? memberValue(owner, expression.name) : undefined;
      }
      case 'index': {
        const owner = infer(expression.object, depth + 1);
        if (!owner) return undefined;
        if (owner.array) {
          if ((owner.arrayDepth ?? 1) > 1) return { ...owner, arrayDepth: owner.arrayDepth! - 1, static: false };
          const type = arrayElement(owner.type);
          return { node: owner.node, type, conditional: owner.conditional, static: false, array: !!(type?.kind === 'type_alias' && isArray(type)), arrayDepth: 1 };
        }
        const operator = owner.type && env.member(owner.type, 'operator []', METHODS);
        return operator && !!operator.isStatic === !!owner.static ? { node: operator, type: typeOfReturn(operator), static: false, conditional: owner.conditional || operator.semanticData?.conditional === true } : undefined;
      }
      case 'call': {
        const callee = infer(expression.callee, depth + 1);
        if (callee?.functionInterfaceDispatch) return undefined;
        if (callee?.node && CALLABLE.has(callee.node.kind)) {
          const type = callee.node.name === 'create' && callee.node.returnType === 'thistype' ? callee.type ?? typeOfReturn(callee.node) : typeOfReturn(callee.node);
          return { type, conditional: callee.conditional || callee.node.semanticData?.conditional === true || type?.semanticData?.conditional === true, static: false, array: !!(type?.kind === 'type_alias' && isArray(type)), arrayDepth: 1 };
        }
        if (callee?.builtin) return { conditional: callee.conditional, type: callee.type, static: false, array: !!(callee.type?.kind === 'type_alias' && isArray(callee.type)), arrayDepth: 1 };
        if (callee?.node && TYPES.has(callee.node.kind)) return { type: callee.node, origin: expression, static: false, array: callee.node.kind === 'type_alias' && isArray(callee.node) };
        return callee?.node && CALLABLE.has(callee.node.kind) ? { type: typeOfReturn(callee.node), static: false } : undefined;
      }
      case 'function': return infer(expression.value, depth + 1);
      case 'binary': {
        if (!['<', '>', '<=', '>='].includes(expression.operator)) return undefined;
        const receiver = infer(['>', '<='].includes(expression.operator) ? expression.right : expression.left, depth + 1);
        const other = infer(['>', '<='].includes(expression.operator) ? expression.left : expression.right, depth + 1);
        const operator = receiver?.type && other?.type && env.member(receiver.type, 'operator <', METHODS);
        return operator && !operator.isStatic && !receiver?.static ? { node: operator } : undefined;
      }
      default: return undefined;
    }
  };
  const expression = descriptor.expression;
  let value: Value | undefined;
  let scope = 'declared-expression';
  if (descriptor.access === 'call') {
    if (expression.kind !== 'call') return null;
    const name = pathname(expression.callee);
    if (name === 'ExecuteFunc' && expression.args[0]) {
      const values = collectJassFunctionValues(expression.args[0], env);
      const candidates = values.targets.filter(n => (n.kind === 'function' || (n.kind === 'method' && n.isStatic)) && (!Array.isArray(n.semanticData?.parameterTypes) || n.semanticData.parameterTypes.length === 0));
      if (!candidates.length) return null;
      value = { node: candidates[0], candidates, unknownTargets: values.unknown, helper: true, builtin: 'execute-function-name' };
      scope = 'function-name-value';
    }
    if (!value && expression.callee.kind === 'member' && ['destroy', 'deallocate'].includes(expression.callee.name)) {
      const lifecycle = infer(expression.callee);
      if (['destroy', 'deallocate'].includes(lifecycle?.builtin ?? '')) value = lifecycle;
    }
    if (!value && name) {
      const direct = env.named({ ...ref, referenceName: name });
      if (direct) return { ...direct, original: ref };
    }
    value ??= infer(expression.callee);
    if (expression.callee.kind === 'member') scope = expression.callee.object.kind === 'index' ? 'declared-index-receiver' : expression.callee.object.kind === 'call' ? 'declared-factory-receiver' : 'declared-receiver-type';
    if (value?.node && !CALLABLE.has(value.node.kind) && !value.builtin && !TYPES.has(value.node.kind)) return null;
  } else if (descriptor.access === 'set') {
    if (expression.kind === 'name') {
      const node = env.lookup(expression.name, FIELDS);
      return node ? { original: ref, targetNodeId: node.id, edgeKind: 'references', confidence: 0.95, resolvedBy: 'qualified-name', metadata: { jassStaticSubset: true, resolutionScope: 'declared-storage-write' } } : null;
    }
    if (expression.kind !== 'member' && expression.kind !== 'index') return null;
    const owner = infer(expression.object);
    if (owner?.node && (expression.kind === 'index' && owner.array)) return { original: ref, targetNodeId: owner.node.id, edgeKind: 'references', confidence: 0.95, resolvedBy: 'qualified-name', metadata: { jassStaticSubset: true, resolutionScope: 'declared-storage-write' } };
    if (!owner?.type) return null;
    if (expression.kind === 'member') {
      const field = env.member(owner.type, expression.name, FIELDS);
      if (field && (!owner.static || field.isStatic)) return { original: ref, targetNodeId: field.id, edgeKind: 'references', confidence: 0.95, resolvedBy: 'qualified-name', metadata: { jassStaticSubset: true, resolutionScope: 'declared-storage-write' } };
    }
    const name = expression.kind === 'index' ? 'operator []=' : 'operator ' + expression.name + '=';
    const setter = env.member(owner.type, name, METHODS);
    value = setter && !!setter.isStatic === !!owner.static ? { node: setter } : undefined;
  } else if (descriptor.access === 'get' || descriptor.access === 'function') {
    value = infer(expression);
    if (descriptor.access === 'get' && value?.node && !value.helper && !value.builtin && !FIELDS.has(value.node.kind) && !TYPES.has(value.node.kind) && !value.node.name.startsWith('operator ')) return null;
  }
  if (['destroy', 'deallocate'].includes(value?.builtin ?? '') && value?.type) {
    const callbacks: Node[] = [], seenCallbacks = new Set<string>();
    const possibleTypes = [value.type, ...env.context.getNodesByKind('struct').filter(n => (n.language === 'jass' || n.language === 'vjass') && n.id !== value!.type!.id)];
    for (const concrete of possibleTypes) {
      const lineage: Node[] = [], visited = new Set<string>();
      for (let type: Node | undefined = concrete; type && visited.size < 64 && !visited.has(type.id);) {
        visited.add(type.id); lineage.push(type);
        const base: string | undefined = type.signature?.match(/\bextends\s+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)/)?.[1];
        type = base && base !== 'array' ? env.lookup(base, TYPES, type) : undefined;
      }
      if (!lineage.some(n => n.id === value!.type!.id)) continue;
      for (const type of lineage) for (const callback of env.context.getNodesByQualifiedName(type.qualifiedName + '.onDestroy').filter(n => (n.language === 'jass' || n.language === 'vjass') && n.kind === 'method' && !n.isStatic)) {
        if (!seenCallbacks.has(callback.id)) { seenCallbacks.add(callback.id); callbacks.push(callback); }
      }
    }
    if (callbacks.length) { value = { ...value, node: callbacks[0], candidates: callbacks, unknownTargets: false }; scope = 'generated-struct-lifecycle'; }
  }
  const target = value?.node;
  if (!target) return null;
  const metadata = { jassStaticSubset: true, resolutionScope: value?.candidates ? ['function-name-value', 'generated-struct-lifecycle'].includes(scope) ? scope : 'function-interface-value-flow' : scope, ...(value?.conditional ? { jassConditional: true, jassCandidate: true } : {}), ...(value?.builtin ? { jassBuiltin: value.builtin } : {}), ...(value?.candidates ? { jassCandidate: true, jassUnknownTargets: value.unknownTargets ?? false } : {}) };
  return { original: ref, targetNodeId: target.id, confidence: value?.candidates ? 0.85 : 0.95, resolvedBy: 'qualified-name',
    edgeKind: descriptor.access === 'function' || (descriptor.access === 'get' && value?.helper) ? 'references' : CALLABLE.has(target.kind) ? 'calls' : value?.builtin ? (value.static ? 'instantiates' : 'references') : 'references',
    metadata, alsoTargets: value?.candidates?.slice(1).map(n => ({ targetNodeId: n.id, metadata })) };
}
