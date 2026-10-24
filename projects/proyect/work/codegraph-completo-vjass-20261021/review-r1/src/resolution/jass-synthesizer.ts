import type { Edge, Node } from '../types';
import type { ResolutionContext } from './types';
import type { JassExpression } from '../extraction/jass-expression';
import { resolveJassReference } from './jass';
import type { MaybeYield } from './cooperative-yield';
import type { QueryBuilder } from '../db/queries';

const path = (e: JassExpression): string | undefined => {
  if (e.kind === 'name') return e.name;
  if (e.kind !== 'member' || e.colon) return undefined;
  const prefix = path(e.object);
  return prefix ? prefix + '.' + e.name : undefined;
};
const jass = (node: Node) => node.language === 'jass' || node.language === 'vjass';

/** Hooks affect individual translated call sites, not the native's own body.
 * Caller→hook edges avoid inventing hook execution through unmodified BJs.
 * External declarations absent from the index are not guessed by spelling.
 */
export async function jassHookEdges(ctx: ResolutionContext, yieldToLoop: MaybeYield): Promise<Edge[]> {
  const resolved = (name: string, from: Node, kind: 'calls' | 'function_ref') => resolveJassReference({ fromNodeId: from.id, referenceName: name, referenceKind: kind, line: from.startLine, column: 0, filePath: from.filePath, language: from.language }, ctx);
  const hooks: { target: string; callback: string; site: string }[] = [];
  for (const kind of ['file', 'namespace', 'struct', 'module'] as const) {
    const nodes = ctx.iterateNodesByKind?.(kind) ?? ctx.getNodesByKind(kind);
    for (const owner of nodes) {
      await yieldToLoop();
      if (!jass(owner) || !Array.isArray(owner.semanticData?.hooks)) continue;
      for (const hook of owner.semanticData.hooks as { target: string; callback: string; line: number }[]) {
        const target = resolved(hook.target, owner, 'calls'), callback = resolved(hook.callback, owner, 'function_ref');
        const declaration = target && ctx.getNodeById?.(target.targetNodeId);
        if (target && callback && declaration && (/^(?:(?:constant|public|private)\s+)*native\b/.test(declaration.signature ?? '') || declaration.semanticData?.api === true)) hooks.push({ target: target.targetNodeId, callback: callback.targetNodeId, site: `${owner.filePath}:${hook.line}` });
      }
    }
  }
  if (!hooks.length) return [];
  const byTarget = new Map<string, typeof hooks>();
  for (const hook of hooks) { const group = byTarget.get(hook.target) ?? []; group.push(hook); byTarget.set(hook.target, group); }
  const edges: Edge[] = [];
  for (const kind of ['function', 'method', 'namespace', 'file', 'variable', 'field'] as const) {
    const nodes = ctx.iterateNodesByKind?.(kind) ?? ctx.getNodesByKind(kind);
    for (const from of nodes) {
      await yieldToLoop();
      if (!jass(from) || from.semanticData?.api === true || !Array.isArray(from.semanticData?.calls)) continue;
      for (const call of from.semanticData.calls as { callee: JassExpression; line: number }[]) {
        const name = path(call.callee), target = name && resolved(name, from, 'calls');
        if (!target) continue;
        for (const hook of byTarget.get(target.targetNodeId) ?? []) edges.push({ source: from.id, target: hook.callback, kind: 'calls', line: call.line, provenance: 'heuristic', metadata: { synthesizedBy: 'jass-hook', registeredAt: hook.site, jassCandidate: true, via: name } });
      }
    }
  }
  return edges;
}

/** Like the original interface/implementation pass: virtual declarations lead
 * to known implementations, explicitly tagged as possible runtime targets. */
export async function jassPolymorphicEdges(queries: QueryBuilder, ctx: ResolutionContext, yieldToLoop: MaybeYield): Promise<Edge[]> {
  const methods = ctx.getNodesByKind('method').filter(n => jass(n) && !n.isStatic && n.visibility !== 'private' && (n.isAbstract || /\bstub\b/.test(n.signature ?? '')));
  if (!methods.length) return [];
  const byOwner = new Map<string, Node[]>();
  for (const method of methods) {
    const owner = method.qualifiedName.slice(0, method.qualifiedName.lastIndexOf('.'));
    const group = byOwner.get(owner) ?? []; group.push(method); byOwner.set(owner, group);
  }
  const result: Edge[] = [];
  const structs = ctx.iterateNodesByKind?.('struct') ?? ctx.getNodesByKind('struct');
  for (const child of structs) {
    await yieldToLoop();
    if (!jass(child)) continue;
    const visited = new Set<string>(), todo = [child.id];
    while (todo.length) {
      const id = todo.pop()!;
      if (visited.has(id) || visited.size >= 64) continue;
      visited.add(id);
      for (const edge of queries.getOutgoingEdges(id).filter(e => e.kind === 'extends' || e.kind === 'implements')) {
        const base = ctx.getNodeById?.(edge.target);
        if (!base || !jass(base) || /\bextends\s+array\b/.test(base.signature ?? '')) continue;
        todo.push(base.id);
        for (const declaration of byOwner.get(base.qualifiedName) ?? []) {
          const candidates = ctx.getNodesByQualifiedName(child.qualifiedName + '.' + declaration.name).filter(n => jass(n) && n.kind === 'method' && !n.isStatic && n.visibility !== 'private');
          if (candidates.length !== 1) continue;
          result.push({ source: declaration.id, target: candidates[0]!.id, kind: 'calls', line: declaration.startLine, provenance: 'heuristic', metadata: { synthesizedBy: 'jass-polymorphic', jassCandidate: true, registeredAt: `${child.filePath}:${child.startLine}`, via: declaration.name } });
        }
      }
    }
  }
  return result;
}

/** Compiler-inserted initialization paths retain their declaration/marker
 * locations and are explicitly synthetic. Source bodies stay verbatim. */
export async function jassInitializationEdges(queries: QueryBuilder, ctx: ResolutionContext, yieldToLoop: MaybeYield): Promise<Edge[]> {
  const mains = ctx.getNodesByQualifiedName('main').filter(n => jass(n) && n.kind === 'function' && n.semanticData?.api !== true);
  const main = mains.length === 1 ? mains[0] : undefined;
  const result: Edge[] = [];
  const add = (source: Node, target: Node, site: number, phase: string) => result.push({ source: source.id, target: target.id, kind: 'references', line: site, provenance: 'heuristic', metadata: { synthesizedBy: 'jass-initialization', jassCandidate: true, registeredAt: `${target.filePath}:${target.startLine}`, phase } });
  const injection = main?.semanticData?.injection as { file?: string; init?: number } | undefined;
  const mainInitializes = main && (!injection || !!injection.init);
  for (const kind of ['file', 'namespace', 'struct', 'variable', 'field'] as const) {
    const nodes = ctx.iterateNodesByKind?.(kind) ?? ctx.getNodesByKind(kind);
    for (const node of nodes) {
      await yieldToLoop();
      if (!jass(node) || node.semanticData?.api === true) continue;
      if (mainInitializes && Array.isArray(node.semanticData?.slkLoads) && node.semanticData.slkLoads.length) add(main, node, main.startLine, 'slk-data-initializer');
      if (node.semanticData?.injectionTarget === 'main' || node.semanticData?.injectionTarget === 'config') {
        const target = ctx.getNodesByQualifiedName(String(node.semanticData.injectionTarget)).filter(n => jass(n) && n.kind === 'function');
        if (target.length === 1) add(target[0]!, node, target[0]!.startLine, 'injected-body');
      } else if (kind === 'namespace' || kind === 'struct') {
        if (mainInitializes && queries.getOutgoingEdges(node.id).some(e => e.kind === 'calls')) add(main, node, injection?.file && injection.file !== main.filePath ? main.startLine : injection?.init ?? main.startLine, kind === 'struct' ? 'struct-onInit' : 'library-scope-initializer');
      } else if (Array.isArray(node.semanticData?.calls) && node.semanticData.calls.length) {
        const ownerName = node.qualifiedName.includes('.') ? node.qualifiedName.slice(0, node.qualifiedName.lastIndexOf('.')) : '';
        const owner = kind === 'field' ? ctx.getNodesByQualifiedName(ownerName).find(n => jass(n) && n.kind === 'struct') : undefined;
        if (owner && !node.isStatic) add(owner, node, owner.startLine, 'instance-field-initializer');
        else if (mainInitializes && !ctx.getNodesByQualifiedName(ownerName).some(n => ['function', 'method'].includes(n.kind))) add(main, node, injection?.file && injection.file !== main.filePath ? main.startLine : injection?.init ?? main.startLine, 'static-global-initializer');
      }
    }
  }
  return result;
}
