import type { Token } from './jass-lexer';

/** Source expression tree, independent of a particular receiver or graph. */
export type JassExpression =
  | { kind: 'name'; name: string; at: Token }
  | { kind: 'literal'; value: string; literalKind: string; at: Token }
  | { kind: 'member'; object: JassExpression; name: string; at: Token; colon?: boolean }
  | { kind: 'index'; object: JassExpression; index: JassExpression; at: Token }
  | { kind: 'call'; callee: JassExpression; args: JassExpression[]; at: Token }
  | { kind: 'group'; value: JassExpression; at: Token }
  | { kind: 'unary' | 'function'; operator: string; value: JassExpression; at: Token }
  | { kind: 'binary'; operator: string; left: JassExpression; right: JassExpression; at: Token }
  | { kind: 'unknown'; at: Token };

const IDENTIFIER = /^[A-Za-z_]\w*$/;
const PRECEDENCE: Record<string, number> = { or: 10, and: 20, '==': 30, '!=': 30, '<': 40, '>': 40, '<=': 40, '>=': 40, '+': 50, '-': 50, '%': 50, '*': 60, '/': 60 };

/** Pratt parser for JASS/vJASS expressions. Statements supply the expression
 * boundaries; every postfix preserves its receiver rather than guessing a name.
 * A malformed expression remains unknown and never becomes a global fallback.
 */
export function parseJassExpression(tokens: readonly Token[], start = 0): { expression?: JassExpression; consumed: number; errors: string[] } {
  let position = start;
  const errors: string[] = [];
  const heights = new WeakMap<object, number>();
  let nodes = 0;
  const bounded = (expression: JassExpression): boolean => {
    let children: JassExpression[] = [];
    switch (expression.kind) {
      case 'member': children = [expression.object]; break;
      case 'index': children = [expression.object, expression.index]; break;
      case 'call': children = [expression.callee, ...expression.args]; break;
      case 'binary': children = [expression.left, expression.right]; break;
      case 'group': case 'unary': case 'function': children = [expression.value]; break;
    }
    const height = 1 + children.reduce((max, child) => Math.max(max, heights.get(child) ?? 1), 0);
    if (height > 96 || ++nodes > 50000) { errors.push('Expression tree depth/node budget exceeded.'); position = tokens.length; return false; }
    heights.set(expression, height); return true;
  };
  const take = () => tokens[position++];
  const peek = () => tokens[position];
  const expect = (value: string) => {
    if (peek()?.value === value) { position++; return true; }
    errors.push(`Expected ${value} in expression at ${peek()?.line ?? tokens.at(-1)?.line ?? 1}.`);
    return false;
  };
  const parse = (minimum = 0, depth = 0): JassExpression | undefined => {
    if (depth > 96) { errors.push('Expression nesting limit exceeded.'); position = tokens.length; return undefined; }
    const token = take();
    if (!token) { errors.push('Incomplete expression.'); return undefined; }
    let left: JassExpression;
    if (token.kind || ['true', 'false', 'null'].includes(token.value)) {
      left = { kind: 'literal', value: token.value, literalKind: token.kind ?? token.value, at: token };
    } else if (token.value === '(') {
      const inner = parse(0, depth + 1);
      if (!inner || !expect(')')) return { kind: 'unknown', at: token };
      left = { kind: 'group', value: inner, at: token };
    } else if (['not', '-', '+', 'function'].includes(token.value)) {
      const value = parse(70, depth + 1);
      if (!value) return { kind: 'unknown', at: token };
      left = { kind: token.value === 'function' ? 'function' : 'unary', operator: token.value, value, at: token };
    } else if (token.value === '.') {
      const name = take();
      if (!name || !IDENTIFIER.test(name.value)) { errors.push('Missing implicit member.'); return { kind: 'unknown', at: token }; }
      left = { kind: 'member', object: { kind: 'name', name: 'this', at: token }, name: name.value, at: name };
    } else if (IDENTIFIER.test(token.value)) left = { kind: 'name', name: token.value, at: token };
    else { errors.push(`Unexpected expression token ${token.value}.`); return { kind: 'unknown', at: token }; }
    if (!bounded(left)) return { kind: 'unknown', at: token };
    while (position < tokens.length) {
      const next = peek()!;
      if (next.value === '.' || next.value === ':') {
        position++;
        const name = take();
        if (!name || !IDENTIFIER.test(name.value)) { errors.push('Missing member name.'); return { kind: 'unknown', at: next }; }
        left = { kind: 'member', object: left, name: name.value, colon: next.value === ':', at: name };
      } else if (next.value === '[') {
        position++;
        const index = parse(0, depth + 1);
        if (!index || !expect(']')) return { kind: 'unknown', at: next };
        left = { kind: 'index', object: left, index, at: next };
      } else if (next.value === '(') {
        position++;
        const args: JassExpression[] = [];
        if (peek()?.value !== ')') {
          while (position < tokens.length) {
            const before = position, argument = parse(0, depth + 1);
            if (argument) args.push(argument);
            if (position === before || peek()?.value !== ',') break;
            position++;
          }
        }
        if (!expect(')')) return { kind: 'unknown', at: next };
        left = { kind: 'call', callee: left, args, at: left.at };
      } else {
        const precedence = PRECEDENCE[next.value];
        if (precedence === undefined || precedence < minimum) break;
        position++;
        const right = parse(precedence + 1, depth + 1);
        if (!right) return { kind: 'unknown', at: next };
        left = { kind: 'binary', operator: next.value, left, right, at: left.at };
      }
      if (!bounded(left)) return { kind: 'unknown', at: token };
    }
    return left;
  };
  const expression = parse();
  return { expression, consumed: position - start, errors };
}

export function expressionName(expression: JassExpression): string {
  switch (expression.kind) {
    case 'name': return expression.name;
    case 'literal': return expression.value;
    case 'member': return expressionName(expression.object) + (expression.colon ? ':' : '.') + expression.name;
    case 'index': return expressionName(expression.object) + '[]';
    case 'call': return expressionName(expression.callee) + '()';
    case 'function': return 'function ' + expressionName(expression.value);
    case 'group': return '(' + expressionName(expression.value) + ')';
    case 'unary': return expression.operator + ' ' + expressionName(expression.value);
    case 'binary': return expressionName(expression.left) + ' ' + expression.operator + ' ' + expressionName(expression.right);
    default: return '?';
  }
}

/** Graph descriptors omit source coordinates already carried by the reference. */
export function encodeJassExpression(expression: JassExpression, access: 'call' | 'get' | 'set' | 'function'): string {
  return '__jass_expr__:' + JSON.stringify({ access, expression }, (key, value) => key === 'at' ? undefined : value);
}
