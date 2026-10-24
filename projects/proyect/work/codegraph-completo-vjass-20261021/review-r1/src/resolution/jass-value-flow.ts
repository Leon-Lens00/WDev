import { jassRuntimeFunctions } from './jass-runtime-name';
import type { Node } from '../types';
import type { JassExpression } from '../extraction/jass-expression';
import { evaluateJassConstant } from '../extraction/jass-constant';
import type { ResolutionContext } from './types';
import type { JassExpressionEnvironment } from './jass-expression';

const BINDINGS = new Set(['variable', 'parameter', 'field', 'constant']);
const CALLABLE = new Set(['function', 'method']);
const TYPES = new Set(['struct', 'interface', 'type_alias']);
const parent = (name: string) => name.includes('.') ? name.slice(0, name.lastIndexOf('.')) : '';
const array = <T>(value: unknown): T[] => Array.isArray(value) ? value as T[] : [];
const path = (e: JassExpression): string | undefined => {
  if (e.kind === 'name') return e.name;
  if (e.kind !== 'member' || e.colon) return undefined;
  const prefix = path(e.object);
  return prefix ? prefix + '.' + e.name : undefined;
};

const functionCache = new WeakMap<ResolutionContext, Node[]>();
export function clearJassValueCaches(context: ResolutionContext): void { functionCache.delete(context); }

interface Call { callee: JassExpression; args: JassExpression[]; line: number }
interface Assignment { target: JassExpression; value: JassExpression }

/** Conservative, interprocedural value origins. These are POSSIBLE targets,
 * not proof that a registration or dispatch executes. Unknown writers and
 * recursion are retained as uncertainty, never filled by name coincidence.
 */
export function collectJassFunctionValues(root: Node | JassExpression, env: JassExpressionEnvironment, anchor = env.from): { targets: Node[]; unknown: boolean } {
  const targets = new Map<string, Node>();
  let unknown = false, budget = 4096;
  const seen = new Set<string>();
  const functions = () => {
    let list = functionCache.get(env.context);
    if (!list) { list = [...env.context.getNodesByKind('function'), ...env.context.getNodesByKind('method')].filter(n => n.language === 'jass' || n.language === 'vjass'); functionCache.set(env.context, list); }
    return list;
  };
  const storage = (e: JassExpression, from: Node): Node | undefined => {
    if (e.kind === 'index') return storage(e.object, from);
    const name = path(e);
    if (name) {
      const direct = env.lookup(name, BINDINGS, from);
      if (direct) return direct;
    }
    if (e.kind === 'member') {
      const receiver = storage(e.object, from);
      const type = receiver ? env.declaredType(receiver) : path(e.object) ? env.lookup(path(e.object)!, TYPES, from) : undefined;
      return type ? env.member(type, e.name, BINDINGS) ?? undefined : undefined;
    }
    return undefined;
  };
  const callable = (expression: JassExpression, from: Node): Node | undefined => {
    const name = path(expression);
    if (!name) return undefined;
    const resolved = env.named({ fromNodeId: from.id, referenceName: name, referenceKind: 'calls', line: from.startLine, column: 0, filePath: from.filePath, language: from.language });
    const node = resolved && env.node(resolved.targetNodeId);
    return node && CALLABLE.has(node.kind) ? node : undefined;
  };
  const namespace = (from: Node) => {
    const origin = [...(from.docstring ?? '').matchAll(/module ([\w.]+) defined at/g)].at(-1)?.[1];
    if (origin !== undefined) return parent(origin);
    for (let scope = parent(from.qualifiedName); scope; scope = parent(scope)) {
      if (env.context.getNodesByQualifiedName(scope).some(n => n.kind === 'namespace')) return scope;
    }
    return '';
  };
  const constantString = (expression: JassExpression, from: Node, visited = new Set<string>()): string | undefined => {
    const constant = evaluateJassConstant(expression, name => {
      if (name === 'SCOPE_PREFIX') { const scope = namespace(from); return scope ? scope.replace(/\./g, '_') + '_' : undefined; }
      const node = env.lookup(name, BINDINGS, from);
      if (!node || node.kind !== 'constant' || visited.has(node.id)) return undefined;
      const values = array<JassExpression>(node.semanticData?.values);
      if (values.length !== 1) return undefined;
      visited.add(node.id); const result = constantString(values[0]!, node, visited); visited.delete(node.id); return result;
    });
    return typeof constant === 'string' ? constant : undefined;
  };
  const stringTarget = (name: string): void => {
    const candidates = jassRuntimeFunctions(name, env.context);
    if (candidates.length) for (const target of candidates) targets.set(target.id, target); else unknown = true;
  };
  const value = (expression: JassExpression, from: Node, depth: number): void => {
    if (!expression || depth > 32 || --budget < 0) { unknown = true; return; }
    if (expression.kind === 'function' || expression.kind === 'group') { value(expression.value, from, depth + 1); return; }
    if (expression.kind === 'literal' || expression.kind === 'binary') {
      if (expression.kind === 'literal' && ['0', 'null'].includes(expression.value)) return;
      if (expression.kind === 'binary' && expression.operator === '+' && expression.left.kind === 'name' && expression.left.name === 'SCOPE_PRIVATE') {
        const suffix = constantString(expression.right, from), scope = namespace(from);
        const candidates = suffix && scope ? env.context.getNodesByQualifiedName(scope + '.' + suffix).filter(n => n.kind === 'function' && n.visibility === 'private') : [];
        if (candidates.length === 1) targets.set(candidates[0]!.id, candidates[0]!); else unknown = true;
        return;
      }
      const text = constantString(expression, from);
      if (text !== undefined) stringTarget(text); else unknown = true;
      return;
    }
    if (expression.kind === 'name' || expression.kind === 'member') {
      const declared = storage(expression, from);
      if (declared) { binding(declared, depth + 1); return; }
      const direct = callable(expression, from);
      if (direct && (direct.kind === 'function' || direct.isStatic)) { targets.set(direct.id, direct); return; }
      if (expression.kind === 'member') {
        if (expression.name === 'name') {
          const binding = storage(expression.object, from);
          const type = binding ? env.declaredType(binding) : expression.object.kind === 'member' && path(expression.object.object) ? env.lookup(path(expression.object.object)!, TYPES, from) : undefined;
          if (type?.semanticData?.functionInterface === true) { unknown = true; return; }
          value(expression.object, from, depth + 1); return;
        }
        const type = path(expression.object) && env.lookup(path(expression.object)!, TYPES, from);
        if (type && type.semanticData?.functionInterface === true) {
          const functionNode = env.lookup(expression.name, CALLABLE, from);
          if (functionNode && (functionNode.kind === 'function' || functionNode.isStatic)) { targets.set(functionNode.id, functionNode); return; }
        }
      }
      unknown = true; return;
    }
    if (expression.kind === 'call') {
      const name = path(expression.callee);
      const type = name ? env.lookup(name, TYPES, from) : undefined;
      if (type?.semanticData?.functionInterface === true && expression.args.length === 1) { value(expression.args[0]!, from, depth + 1); return; }
      const target = callable(expression.callee, from);
      const returns = array<JassExpression>(target?.semanticData?.returns);
      if (target && returns.length) { for (const returned of returns) value(returned, target, depth + 1); return; }
    }
    unknown = true;
  };
  const binding = (node: Node, depth: number): void => {
    if (depth > 32 || --budget < 0 || seen.has(node.id)) { unknown = true; return; }
    seen.add(node.id);
    const owner = env.lookup(parent(node.qualifiedName), CALLABLE, node) ?? node;
    const values = array<JassExpression>(node.semanticData?.values);
    for (const expression of values) value(expression, owner, depth + 1);
    let writers = values.length;
    for (const from of functions()) {
      if (node.kind === 'variable' && owner !== node && from.id !== owner.id) continue;
      for (const write of array<Assignment>(from.semanticData?.assignments)) {
        if (storage(write.target, from)?.id !== node.id) continue;
        writers++; value(write.value, from, depth + 1);
      }
    }
    if (node.kind === 'parameter' && owner !== node) {
      const parameters = env.context.getNodesInFile(node.filePath).filter(n => n.kind === 'parameter' && parent(n.qualifiedName) === owner.qualifiedName).sort((a, b) => a.startLine - b.startLine || a.startColumn - b.startColumn);
      const index = parameters.findIndex(n => n.id === node.id);
      if (index >= 0) for (const from of functions()) for (const call of array<Call>(from.semanticData?.calls)) {
        if (callable(call.callee, from)?.id !== owner.id || !call.args[index]) continue;
        writers++; value(call.args[index]!, from, depth + 1);
      }
    }
    if (!writers || node.kind === 'field' || node.kind === 'parameter' || (node.kind === 'variable' && owner === node)) unknown = true;
    seen.delete(node.id);
  };
  if ('qualifiedName' in root) binding(root, 0); else value(root, anchor, 0);
  return { targets: [...targets.values()], unknown };
}
