import type { JassExpression } from './jass-expression';

export type JassConstant = boolean | number | string | null;
export function constantPath(expression: JassExpression): string | undefined {
  if (expression.kind === 'name') return expression.name;
  if (expression.kind !== 'member' || expression.colon) return undefined;
  const prefix = constantPath(expression.object);
  return prefix ? prefix + '.' + expression.name : undefined;
}

/** Evaluate only language constants, using three-valued boolean logic.
 * Undefined is unknown, distinct from false, zero, null and empty string.
 */
export function evaluateJassConstant(expression: JassExpression, resolve: (name: string) => JassConstant | undefined, depth = 0): JassConstant | undefined {
  if (!expression || depth > 64) return undefined;
  if (expression.kind === 'group') return evaluateJassConstant(expression.value, resolve, depth + 1);
  if (expression.kind === 'literal') {
    const text = expression.value;
    if (text === 'true') return true;
    if (text === 'false') return false;
    if (text === 'null') return null;
    if (expression.literalKind === 'string') {
      if (text.length > 65538 || !/^"[\s\S]*"$/.test(text)) return undefined;
      return text.slice(1, -1).replace(/\\([\\"nrt])/g, (_, value: string) => ({ n: '\n', r: '\r', t: '\t', '\\': '\\', '"': '"' })[value]!);
    }
    if (expression.literalKind === 'rawcode') {
      const value = text.slice(1, -1);
      return (value.length === 1 || value.length === 4) && [...value].every(c => c.charCodeAt(0) < 256) ? [...value].reduce((n, c) => n * 256 + c.charCodeAt(0), 0) : undefined;
    }
    if (expression.literalKind === 'number') {
      const number = /^\$/.test(text) ? parseInt(text.slice(1), 16) : /^0[xX]/.test(text) ? parseInt(text.slice(2), 16) : /^0[0-7]+$/.test(text) ? parseInt(text, 8) : Number(text);
      return Number.isFinite(number) ? number : undefined;
    }
    return undefined;
  }
  const name = constantPath(expression);
  if (name) return resolve(name);
  if (expression.kind === 'unary') {
    const value = evaluateJassConstant(expression.value, resolve, depth + 1);
    if (expression.operator === 'not') return typeof value === 'boolean' ? !value : undefined;
    if (typeof value !== 'number') return undefined;
    return expression.operator === '-' ? -value : expression.operator === '+' ? value : undefined;
  }
  if (expression.kind !== 'binary') return undefined;
  const left = evaluateJassConstant(expression.left, resolve, depth + 1);
  if (expression.operator === 'and' && left === false) return false;
  if (expression.operator === 'or' && left === true) return true;
  const right = evaluateJassConstant(expression.right, resolve, depth + 1);
  if (expression.operator === 'and') return right === false ? false : left === true && right === true ? true : undefined;
  if (expression.operator === 'or') return right === true ? true : left === false && right === false ? false : undefined;
  if (left === undefined || right === undefined) return undefined;
  if (['==', '!='].includes(expression.operator)) {
    if (typeof left !== typeof right) return undefined;
    return expression.operator === '==' ? left === right : left !== right;
  }
  if (expression.operator === '+' && typeof left === 'string' && typeof right === 'string') return left.length + right.length <= 65536 ? left + right : undefined;
  if (typeof left !== 'number' || typeof right !== 'number') return undefined;
  switch (expression.operator) {
    case '+': return left + right;
    case '-': return left - right;
    case '*': return left * right;
    // Integer/real division needs operand types: do not guess from JS numbers.
    case '<': return left < right;
    case '>': return left > right;
    case '<=': return left <= right;
    case '>=': return left >= right;
    default: return undefined;
  }
}
