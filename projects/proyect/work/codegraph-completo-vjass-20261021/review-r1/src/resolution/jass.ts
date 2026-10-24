import type { Node } from '../types';
import type { ResolutionContext, ResolvedRef, UnresolvedRef } from './types';
import * as path from 'node:path';
import { lexJass } from '../extraction/jass-lexer';
import { parseJassExpression, encodeJassExpression, JassExpression } from '../extraction/jass-expression';
import { jassSlkExpression } from '../extraction/jass-slk';
import { jassRuntimeFunctions, jassRuntimeDeclarations } from './jass-runtime-name';
import { resolveJassExpression } from './jass-expression';

const isJass = (node: Node) => node.language === 'jass' || node.language === 'vjass';
const parentName = (name: string) => name.includes('.') ? name.slice(0, name.lastIndexOf('.')) : '';
const TYPES = new Set(['struct', 'interface', 'type_alias']);
const explicitPublic = (node: Node) => /^(?:(?:static|constant|readonly|stub)\s+)*public\b/.test(node.signature ?? '');

/** Strict language-specific resolution: never fall through to fuzzy/global
 * method-name matching. Unknown receivers, ambiguity and generated dispatch stay
 * unresolved. Every lookup uses the current index, including incremental sync.
 */
function resolveJassReferenceCore(ref: UnresolvedRef, ctx: ResolutionContext): ResolvedRef | null {
  const from = ctx.getNodeById?.(ref.fromNodeId) ?? ctx.getNodesInFile(ref.filePath).find(n => n.id === ref.fromNodeId);
  if (!from) return null;
  if (ref.referenceKind === 'imports' && ref.referenceName.startsWith('__jass_template__:')) {
    try {
      const info = JSON.parse(ref.referenceName.slice('__jass_template__:'.length)) as { kind: string; name: string; file: string; line: number };
      const nodes = ctx.getNodesByQualifiedName(info.name).filter(n => isJass(n) && n.kind === 'module' && n.filePath === info.file && n.startLine === info.line && n.semanticData?.templateKind === info.kind);
      return nodes.length === 1 ? { original: ref, targetNodeId: nodes[0]!.id, confidence: 1, resolvedBy: 'qualified-name', metadata: { jassStaticSubset: true, resolutionScope: 'template-input-dependency' } } : null;
    } catch { return null; }
  }
  if (ref.referenceKind === 'imports' && ref.referenceName.startsWith('__jass_import_resolved__:')) {
    const raw = ref.referenceName.slice('__jass_import_resolved__:'.length).replace(/\\/g, '/');
    if (path.posix.isAbsolute(raw) || /^[A-Za-z]:/.test(raw)) return null;
    const candidates = [path.posix.normalize(raw)]
      .filter(p => p !== '..' && !p.startsWith('../') && ctx.getAllFiles().includes(p));
    if (candidates.length !== 1) return null;
    const target = ctx.getNodesInFile(candidates[0]!).find(n => isJass(n) && n.kind === 'file');
    return target ? { original: ref, targetNodeId: target.id, confidence: 1, resolvedBy: 'file-path', metadata: { jassStaticSubset: true, resolutionScope: 'indexed-source-import' } } : null;
  }
  const enclosing = (node: Node) => parentName(node.qualifiedName);
  const moduleScope = (node: Node): string | undefined => {
    const module = [...(node.docstring ?? '').matchAll(/module ([\w.]+) defined at/g)].at(-1)?.[1];
    return module ? parentName(module) : undefined;
  };
  const originScope = moduleScope(from);
  const visible = (node: Node): boolean => {
    if (!isJass(node)) return false;
    if (node.visibility !== 'private') return true;
    const scope = enclosing(node);
    return scope ? from.qualifiedName === scope || from.qualifiedName.startsWith(scope + '.') || originScope === scope || !!originScope?.startsWith(scope + '.') : from.filePath === node.filePath;
  };
  const unique = (nodes: Node[]) => {
    const distinct = [...new Map(nodes.filter(visible).map(n => [n.id, n])).values()];
    if (distinct.length === 1) return distinct[0];
    if (!distinct.length || !distinct.every(n => n.semanticData?.conditional === true)) return undefined;
    // Alternative bindings may only supply a receiver when their declared
    // shapes agree. Keeping the first incompatible branch invents a type.
    const shape = (n: Node) => JSON.stringify([n.kind, n.semanticData?.declaredType, n.semanticData?.isArray, n.semanticData?.arrayDepth,
      TYPES.has(n.kind) ? n.signature : undefined]);
    return distinct.every(n => shape(n) === shape(distinct[0]!)) ? distinct[0] : undefined;
  };
  const scopesFor = (anchor: Node): string[] => {
    const list: string[] = [];
    for (let scope = anchor.kind === 'file' ? '' : anchor.qualifiedName; scope; scope = parentName(scope)) list.push(scope);
    const origin = moduleScope(anchor);
    if (origin) {
      const typeAt = list.findIndex(s => ctx.getNodesByQualifiedName(s).some(n => isJass(n) && ['struct', 'interface'].includes(n.kind)));
      list.splice(typeAt < 0 ? 0 : typeAt + 1, 0, origin);
    }
    return [...new Set([...list, ''])];
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
    const tokens = lexJass(binding.signature ?? '').semanticLines.flat().map(t => t.value);
    while (['local', 'private', 'public', 'constant', 'static', 'readonly', 'debug', 'delegate'].includes(tokens[0] ?? '')) tokens.shift();
    const type = typeof binding.semanticData?.declaredType === 'string' ? binding.semanticData.declaredType : tokens[0];
    if (type === 'thistype') {
      for (let scope = enclosing(binding); scope; scope = parentName(scope)) {
        const owner = ctx.getNodesByQualifiedName(scope).find(n => isJass(n) && ['struct', 'interface'].includes(n.kind));
        if (owner) return owner;
      }
      return undefined;
    }
    return type ? lookup(type, TYPES, binding) : undefined;
  };
  // undefined means absent; null means ambiguous/unknown. The latter cannot
  // permit a same-named global function to become a fallback target.
  const member = (type: Node, name: string, kinds: Set<string>, visited = new Set<string>()): Node | null | undefined => {
    if (visited.has(type.id) || visited.size >= 16) return null;
    visited.add(type.id);
    const candidates = ctx.getNodesByQualifiedName(type.qualifiedName + '.' + name).filter(n => visible(n) && kinds.has(n.kind));
    if (candidates.length) return unique(candidates) ?? null;
    const base = type.signature?.match(/\bextends\s+([A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*)/)?.[1];
    // JassHelper's array structs have no inherited member namespace.
    const delegated = (): Node | null | undefined => {
      for (const delegateName of (type.semanticData?.delegates ?? []) as string[]) {
        const field = ctx.getNodesByQualifiedName(type.qualifiedName + '.' + delegateName).find(n => isJass(n) && n.kind === 'field');
        const targetType = field && declaredType(field);
        if (!targetType) continue;
        const target = member(targetType, name, kinds, new Set(visited));
        if (target !== undefined) return target;
      }
      return undefined;
    };
    if (!base || base === 'array') return delegated();
    // The base name is resolved in the DECLARING type's scope, not the caller's
    // namespace, which might have a different same-named type.
    const baseCandidates = ctx.getNodesByQualifiedName(enclosing(type) ? enclosing(type) + '.' + base : base).filter(n => TYPES.has(n.kind));
    const parent = baseCandidates.length ? unique(baseCandidates) : lookup(base, TYPES, type);
    if (!parent) return null;
    const inherited = member(parent, name, kinds, visited);
    return inherited === undefined ? delegated() : inherited;
  };
  const CALLABLE = new Set(['function', 'method']);
  if (ref.referenceName.startsWith('__jass_slk_')) {
    const methodType = ref.referenceName.startsWith('__jass_slk_method__:') ? ref.referenceName.slice('__jass_slk_method__:'.length) : undefined;
    let info: { type: string; field?: string; value?: string };
    try { info = methodType ? { type: methodType } : JSON.parse(ref.referenceName.slice(ref.referenceName.indexOf(':') + 1)); } catch { return null; }
    const types = jassRuntimeDeclarations(info.type, ctx, 'struct'), type = types.length === 1 ? types[0] : undefined;
    if (!type) return null;
    const declaration = member(type, info.field ?? 'getFromKey', new Set([info.field ? 'field' : 'method']));
    if (!declaration || (info.field ? declaration.isStatic : !declaration.isStatic)) return null;
    if (!ref.referenceName.startsWith('__jass_slk_value__:')) return { original: ref, targetNodeId: declaration.id, confidence: 0.95, resolvedBy: 'qualified-name', metadata: { jassStaticSubset: true, resolutionScope: info.field ? 'slk-field-write' : 'slk-row-constructor' } };
    const inputType = info.field ? String(declaration.semanticData?.declaredType ?? '') : (declaration.semanticData?.parameterTypes as string[] | undefined)?.[0];
    if (!inputType || info.value === undefined) return null;
    const parsed = parseJassExpression(lexJass(jassSlkExpression(info.value, inputType)).semanticLines.flat());
    if (!parsed.expression || parsed.errors.length) return null;
    const results: ResolvedRef[] = [];
    const visit = (expression: JassExpression): void => {
      if (expression.kind === 'call') { visit(expression.callee); for (const arg of expression.args) visit(arg); }
      else if (expression.kind === 'member') visit(expression.object);
      else if (expression.kind === 'index') { visit(expression.object); visit(expression.index); }
      else if (expression.kind === 'binary') { visit(expression.left); visit(expression.right); }
      else if (['group', 'unary', 'function'].includes(expression.kind) && 'value' in expression) visit(expression.value as JassExpression);
      if (['call', 'member', 'index', 'binary'].includes(expression.kind)) {
        const target = resolveJassReference({ ...ref, referenceName: encodeJassExpression(expression, expression.kind === 'call' ? 'call' : 'get') }, ctx);
        if (target && (target.edgeKind ?? 'calls') === 'calls') results.push(target);
      }
    };
    visit(parsed.expression);
    const first = results[0];
    if (!first) return null;
    return { ...first, original: ref, metadata: { ...first.metadata, resolutionScope: 'slk-cell-expression' }, alsoTargets: [ ...(first.alsoTargets ?? []), ...results.slice(1).flatMap(r => [{ targetNodeId: r.targetNodeId, metadata: { ...r.metadata, resolutionScope: 'slk-cell-expression' } }, ...(r.alsoTargets ?? [])]) ] };
  }
  if (ref.referenceName.startsWith('__jass_keyword__:')) {
    const target = lookup(ref.referenceName.slice('__jass_keyword__:'.length), new Set([...TYPES, 'function']));
    return target ? { original: ref, targetNodeId: target.id, confidence: 1, resolvedBy: 'qualified-name', metadata: { jassStaticSubset: true, resolutionScope: 'forward-keyword' } } : null;
  }
  if (ref.referenceName.startsWith('__jass_expr__:')) return resolveJassExpression(ref, {
    from, context: ctx, owningType, lookup, member, declaredType,
    named: reference => resolveJassReference(reference, ctx),
    node: id => ctx.getNodeById?.(id),
  });
  const special = ref.referenceName.match(/^__jass_(property_get|property_set|factory|index|execute_func)__:(.+)$/);
  if (special) {
    const [, mode, expression] = special;
    if (mode === 'execute_func') {
      const candidates = jassRuntimeFunctions(expression!, ctx), candidate = candidates[0];
      const metadata = { jassStaticSubset: true, resolutionScope: 'literal-execute-func', ...(candidates.length > 1 ? { jassCandidate: true } : {}) };
      return candidate ? { original: ref, targetNodeId: candidate.id, confidence: 1, resolvedBy: 'qualified-name', metadata, alsoTargets: candidates.slice(1).map(n => ({ targetNodeId: n.id, metadata })) } : null;
    }
    const parts = expression!.split('.');
    const name = parts.pop()!;
    const receiver = parts.join('.');
    let type: Node | undefined;
    if (mode === 'factory') {
      const factory = resolveJassReference({ ...ref, referenceKind: 'calls', referenceName: receiver }, ctx);
      const node = factory && ctx.getNodeById?.(factory.targetNodeId);
      type = node?.kind === 'struct' ? node : node?.returnType === 'thistype'
        ? ctx.getNodesByQualifiedName(parentName(node.qualifiedName)).find(n => TYPES.has(n.kind))
        : node?.returnType ? lookup(node.returnType, TYPES, node) : undefined;
    } else {
      const binding = lookup(receiver, new Set(['variable', 'parameter', 'field', 'constant']));
      // Require the declaration shape, not an incidental word in a comment or initializer.
      if (mode === 'index' && (!binding || !/^(?:(?:local|private|public|constant|static|readonly|debug)\s+)*[A-Za-z_]\w*\s+array\s+[A-Za-z_]\w*\b/.test(lexJass(binding.signature ?? '').lines.flat().map(t => t.value).join(' ')))) return null;
      type = receiver === 'thistype' ? owningType : binding ? declaredType(binding) : receiver === 'this' ? owningType : lookup(receiver, TYPES);
    }
    if (!type) return null;
    const operator = mode!.startsWith('property_');
    // A real field shadows any guessed property dispatch; unknown chains stay unresolved.
    if (operator && member(type, name, new Set(['field', 'variable', 'constant'])) !== undefined) return null;
    const target = member(type, operator ? `operator ${name}${mode === 'property_set' ? '=' : ''}` : name, new Set(['method']));
    return target ? { original: ref, targetNodeId: target.id, edgeKind: 'calls', confidence: 0.95, resolvedBy: 'qualified-name', metadata: { jassStaticSubset: true, resolutionScope: operator ? 'declared-property-operator' : `declared-${mode}-receiver` } } : null;
  }
  let target: Node | undefined;
  let reason = 'lexical-scope';
  let conditionalReceiver = false;
  if (ref.referenceKind === 'imports') target = lookup(ref.referenceName, new Set(['namespace']));
  else if (['extends', 'implements', 'type_of', 'returns'].includes(ref.referenceKind)) target = lookup(ref.referenceName, TYPES);
  else if (ref.referenceKind === 'calls' || ref.referenceKind === 'function_ref') {
    const parts = ref.referenceName.split('.');
    if (parts.length === 1) {
      // JassHelper resolves an unqualified method in the enclosing struct
      // before a same-named global function. Never search unrelated structs.
      const implicit = owningType && member(owningType, ref.referenceName, new Set(['method']));
      if (implicit === null) return null;
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
      let type = receiver === 'thistype' ? owningType : binding ? declaredType(binding) : receiver === 'this' ? owningType : lookup(receiver, TYPES);
      let staticReceiver = !binding && receiver !== 'this';
      conditionalReceiver = binding?.semanticData?.conditional === true || type?.semanticData?.conditional === true;
      if (!type && parts.length > 1) {
        const first = parts.shift()!;
        const firstBinding = lookup(first, new Set(['variable', 'parameter', 'field', 'constant']));
        type = first === 'thistype' ? owningType : firstBinding ? declaredType(firstBinding) : first === 'this' ? owningType : lookup(first, TYPES);
        staticReceiver = false;
        conditionalReceiver ||= firstBinding?.semanticData?.conditional === true || type?.semanticData?.conditional === true;
        for (const field of parts) {
          const declared = type && member(type, field, new Set(['field', 'variable']));
          type = declared ? declaredType(declared) : undefined;
          conditionalReceiver ||= declared?.semanticData?.conditional === true || type?.semanticData?.conditional === true;
        }
      }
      if (type) {
        const declared = member(type, method, new Set(['method']));
        target = declared ?? undefined;
        if (staticReceiver && target && !target.isStatic) target = undefined;
        reason = 'declared-receiver-type';
        if (ref.referenceKind === 'calls' && declared === undefined && type.kind === 'struct' && !/\bextends\b/.test(type.signature ?? '') && ['allocate', 'create', 'destroy', 'deallocate'].includes(method)) {
          if (ctx.getNodesByQualifiedName(type.qualifiedName + '.' + method).some(n => isJass(n) && n.kind === 'method')) return null;
          if (['allocate', 'deallocate'].includes(method) && owningType?.id !== type.id) return null;
          if (staticReceiver !== ['allocate', 'create'].includes(method)) return null;
          return { original: ref, targetNodeId: type.id, confidence: 0.95, resolvedBy: 'qualified-name', edgeKind: staticReceiver ? 'instantiates' : 'references', metadata: { jassStaticSubset: true, resolutionScope: 'generated-struct-lifecycle', jassBuiltin: method } };
        }
      } else {
        // Qualified library/scope functions have no receiver instance.
        target = lookup(ref.referenceName, new Set(['function']));
      }
    }
    if (target && !CALLABLE.has(target.kind)) target = undefined;
  }
  if (!target && ref.referenceKind === 'calls' && /\.(execute|evaluate)$/.test(ref.referenceName)) {
    const receiver = ref.referenceName.replace(/\.(execute|evaluate)$/, '');
    if (lookup(receiver, new Set(['variable', 'parameter', 'field', 'constant']))) return null;
    const direct = resolveJassReference({ ...ref, referenceName: ref.referenceName.replace(/\.(execute|evaluate)$/, '') }, ctx);
    const callable = direct && ctx.getNodeById?.(direct.targetNodeId);
    if (direct && callable && (callable.kind === 'function' || (callable.kind === 'method' && callable.isStatic))) {
      return { ...direct, original: ref, metadata: { ...direct.metadata, resolutionScope: 'named-execute-evaluate' } };
    }
  }
  return target ? {
    original: ref, targetNodeId: target.id, confidence: 0.95,
    resolvedBy: ref.referenceKind === 'function_ref' ? 'function-ref' : 'qualified-name',
    metadata: { jassStaticSubset: true, resolutionScope: reason, ...(conditionalReceiver ? { jassCandidate: true, jassConditional: true } : {}) },
  } : null;
}

export function resolveJassReference(ref: UnresolvedRef, ctx: ResolutionContext): ResolvedRef | null {
  let result = resolveJassReferenceCore(ref, ctx);
  if (!result) return null;
  const from = ctx.getNodeById?.(ref.fromNodeId), target = ctx.getNodeById?.(result.targetNodeId);
  if (from?.semanticData?.unknownPreprocessing === true) result = { ...result, metadata: { ...result.metadata, jassCandidate: true, jassUnknownTargets: true, jassUnknownPreprocessing: true }, alsoTargets: result.alsoTargets?.map(t => ({ ...t, metadata: { ...t.metadata, jassCandidate: true, jassUnknownTargets: true, jassUnknownPreprocessing: true } })) };
  const refs = from?.semanticData?.conditionalRefs;
  if (from?.semanticData?.conditional === true || target?.semanticData?.conditional === true || (Array.isArray(refs) && refs.includes(ref.line + ':' + ref.referenceName))) {
    const metadata = { ...result.metadata, jassCandidate: true, jassConditional: true };
    const alternatives = target?.semanticData?.conditional === true ? ctx.getNodesByQualifiedName(target.qualifiedName).filter(n => n.id !== target.id && n.kind === target.kind && n.semanticData?.conditional === true) : [];
    return { ...result, metadata, alsoTargets: [
      ...(result.alsoTargets ?? []).map(t => ({ ...t, metadata: { ...t.metadata, jassCandidate: true, jassConditional: true } })),
      ...alternatives.map(n => ({ targetNodeId: n.id, metadata })),
    ] };

  }
  return result;
}
