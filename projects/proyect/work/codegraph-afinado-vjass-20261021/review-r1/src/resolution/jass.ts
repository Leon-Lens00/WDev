import type { Node } from '../types';
import type { ResolutionContext, ResolvedRef, UnresolvedRef } from './types';

const isJass = (node: Node) => node.language === 'jass' || node.language === 'vjass';
const parentName = (name: string) => name.includes('.') ? name.slice(0, name.lastIndexOf('.')) : '';
const TYPES = new Set(['struct', 'interface', 'type_alias']);
const explicitPublic = (node: Node) => /^(?:(?:static|constant|readonly|stub)\s+)*public\b/.test(node.signature ?? '');

/** Strict language-specific resolution: never fall through to fuzzy/global
 * method-name matching. Unknown receivers, ambiguity and generated dispatch stay
 * unresolved. Every lookup uses the current index, including incremental sync.
 */
export function resolveJassReference(ref: UnresolvedRef, ctx: ResolutionContext): ResolvedRef | null {
  const from = ctx.getNodeById?.(ref.fromNodeId) ?? ctx.getNodesInFile(ref.filePath).find(n => n.id === ref.fromNodeId);
  if (!from) return null;
  const enclosing = (node: Node) => parentName(node.qualifiedName);
  const visible = (node: Node): boolean => {
    if (!isJass(node)) return false;
    if (node.visibility !== 'private') return true;
    const scope = enclosing(node);
    return scope ? from.qualifiedName === scope || from.qualifiedName.startsWith(scope + '.') : from.filePath === node.filePath;
  };
  const unique = (nodes: Node[]) => {
    const distinct = [...new Map(nodes.filter(visible).map(n => [n.id, n])).values()];
    return distinct.length === 1 ? distinct[0] : undefined;
  };
  const scopesFor = (anchor: Node): string[] => {
    const list: string[] = [];
    for (let scope = anchor.kind === 'file' ? '' : anchor.qualifiedName; scope; scope = parentName(scope)) list.push(scope);
    return [...list, ''];
  };
  // A declaration owns its local/parameter scope; type refs originate on the
  // declared variable itself and also see the enclosing function.
  const lookup = (name: string, kinds: Set<string>, anchor = from): Node | undefined => {
    for (const scope of scopesFor(anchor)) {
      const qualified = scope ? scope + '.' + name : name;
      const candidates = ctx.getNodesByQualifiedName(qualified).filter(n => visible(n) && kinds.has(n.kind));
      if (candidates.length) return unique(candidates);
    }
    // Unqualified, non-private declarations in a library can be global. Do not
    // let a bare member name escape its receiver, even when unique project-wide.
    if (!name.includes('.')) {
      const candidates = ctx.getNodesByName(name).filter(n => visible(n) && kinds.has(n.kind) &&
        (!explicitPublic(n) || scopesFor(anchor).includes(enclosing(n))) &&
        !['method', 'field', 'parameter'].includes(n.kind) &&
        !ctx.getNodesByQualifiedName(enclosing(n)).some(p => isJass(p) && ['struct', 'interface', 'module', 'function', 'method'].includes(p.kind)));
      if (candidates.length) return unique(candidates);
      // JassHelper's explicit public spelling: library/scope prefix + '_'.
      for (let i = name.indexOf('_'); i > 0; i = name.indexOf('_', i + 1)) {
        const candidate = unique(ctx.getNodesByName(name.slice(i + 1)).filter(n => kinds.has(n.kind) && explicitPublic(n) && enclosing(n).replace(/\./g, '_') === name.slice(0, i)));
        if (candidate) return candidate;
      }
    }
    return undefined;
  };
  const owningType = scopesFor(from).flatMap(s => ctx.getNodesByQualifiedName(s)).find(n => isJass(n) && ['struct', 'interface'].includes(n.kind));
  const declaredType = (binding: Node): Node | undefined => {
    const type = binding.signature?.match(/^(?:(?:local|private|public|constant|static|readonly)\s+)*([A-Za-z_]\w*)\s+/)?.[1];
    if (type === 'thistype') {
      return ctx.getNodesByQualifiedName(enclosing(binding)).find(n => isJass(n) && ['struct', 'interface'].includes(n.kind)) ?? owningType;
    }
    return type ? lookup(type, TYPES, binding) : undefined;
  };
  const member = (type: Node, name: string, kinds: Set<string>, visited = new Set<string>()): Node | undefined => {
    if (visited.has(type.id) || visited.size >= 16) return undefined;
    visited.add(type.id);
    const candidates = ctx.getNodesByQualifiedName(type.qualifiedName + '.' + name).filter(n => visible(n) && kinds.has(n.kind));
    if (candidates.length) return unique(candidates);
    const base = type.signature?.match(/\bextends\s+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)/)?.[1];
    if (!base) return undefined;
    // The base name is resolved in the DECLARING type's scope, not the caller's
    // namespace, which might have a different same-named type.
    const baseCandidates = ctx.getNodesByQualifiedName(enclosing(type) ? enclosing(type) + '.' + base : base).filter(n => TYPES.has(n.kind));
    const parent = baseCandidates.length ? unique(baseCandidates) : lookup(base, TYPES, type);
    return parent ? member(parent, name, kinds, visited) : undefined;
  };
  const CALLABLE = new Set(['function', 'method']);
  let target: Node | undefined;
  let reason = 'lexical-scope';
  if (ref.referenceKind === 'imports') target = lookup(ref.referenceName, new Set(['namespace']));
  else if (['extends', 'implements', 'type_of', 'returns'].includes(ref.referenceKind)) target = lookup(ref.referenceName, TYPES);
  else if (ref.referenceKind === 'calls' || ref.referenceKind === 'function_ref') {
    if (/\.(execute|evaluate)$/.test(ref.referenceName)) return null;
    const parts = ref.referenceName.split('.');
    if (parts.length === 1) {
      // JassHelper resolves an unqualified method in the enclosing struct
      // before a same-named global function. Never search unrelated structs.
      const implicit = owningType && member(owningType, ref.referenceName, new Set(['method']));
      if (implicit) {
        const enclosingMethod = scopesFor(from).flatMap(s => ctx.getNodesByQualifiedName(s)).find(n => isJass(n) && n.kind === 'method');
        if (!implicit.isStatic && (ref.referenceKind === 'function_ref' || enclosingMethod?.isStatic)) return null;
        target = implicit;
        reason = 'enclosing-struct-method';
      } else target = lookup(ref.referenceName, new Set(['function']));
    }
    else {
      const method = parts.pop()!;
      const receiver = parts.join('.');
      const binding = lookup(receiver, new Set(['variable', 'parameter', 'field', 'constant']));
      let type = receiver === 'this' || receiver === 'thistype' ? owningType : binding ? declaredType(binding) : lookup(receiver, TYPES);
      let staticReceiver = !binding && receiver !== 'this';
      if (!type && parts.length > 1) {
        const first = parts.shift()!;
        const firstBinding = lookup(first, new Set(['variable', 'parameter', 'field', 'constant']));
        type = first === 'this' || first === 'thistype' ? owningType : firstBinding ? declaredType(firstBinding) : lookup(first, TYPES);
        staticReceiver = false;
        for (const field of parts) {
          const declared = type && member(type, field, new Set(['field', 'variable']));
          type = declared ? declaredType(declared) : undefined;
        }
      }
      if (type) {
        target = member(type, method, new Set(['method']));
        if (staticReceiver && target && !target.isStatic) target = undefined;
        reason = 'declared-receiver-type';
      } else {
        // Qualified library/scope functions have no receiver instance.
        target = lookup(ref.referenceName, new Set(['function']));
      }
    }
    if (target && !CALLABLE.has(target.kind)) target = undefined;
  }
  return target ? {
    original: ref, targetNodeId: target.id, confidence: 0.95,
    resolvedBy: ref.referenceKind === 'function_ref' ? 'function-ref' : 'qualified-name',
    metadata: { jassStaticSubset: true, resolutionScope: reason },
  } : null;
}
