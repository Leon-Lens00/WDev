import type { Node } from '../types';
import type { ResolutionContext } from './types';
const jass = (node: Node) => node.language === 'jass' || node.language === 'vjass';
const explicitPublic = (node: Node) => /^(?:(?:static|constant|readonly|stub)\s+)*public\b/.test(node.signature ?? '');
/** Unmodified library/scope functions keep a global runtime spelling; explicit
 * public adds the scope prefix, and private names require .name/SCOPE_PRIVATE.
 * Do not mistake a graph qualified name for the compiler's runtime name. */
export function jassRuntimeDeclarations(name: string, ctx: ResolutionContext, kind: Node['kind']): Node[] {
  if (!/^[A-Za-z_]\w*$/.test(name)) return [];
  const candidates: Node[] = ctx.getNodesByName(name).filter(n => jass(n) && n.kind === kind && n.visibility !== 'private' && (!explicitPublic(n) || !n.qualifiedName.includes('.')));
  for (let at = name.indexOf('_'); at > 0; at = name.indexOf('_', at + 1)) {
    const prefix = name.slice(0, at), suffix = name.slice(at + 1);
    candidates.push(...ctx.getNodesByName(suffix).filter(n => jass(n) && n.kind === kind && n.visibility !== 'private' && explicitPublic(n) && n.qualifiedName.slice(0, n.qualifiedName.lastIndexOf('.')).replace(/\./g, '_') === prefix));
  }
  const unique = [...new Map(candidates.map(n => [n.id, n])).values()];
  return unique.length === 1 || (unique.length > 1 && unique.every(n => n.semanticData?.conditional === true)) ? unique : [];
}

export function jassRuntimeFunctions(name: string, ctx: ResolutionContext): Node[] { return jassRuntimeDeclarations(name, ctx, 'function'); }
