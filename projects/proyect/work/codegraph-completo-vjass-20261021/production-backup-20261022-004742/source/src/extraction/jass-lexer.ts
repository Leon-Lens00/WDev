import type { ExtractionError } from '../types';
export interface Token { value: string; line: number; column: number }
export interface JassLexed { lines: Token[][]; errors: ExtractionError[]; directives: { line: number; text: string; kind: string }[] }
/** Offset-preserving lexical pass; literals/comments never become executable tokens.
 * Preprocessor regions are excluded BEFORE lexing their arbitrary contents.
 * novjass is inactive documentation; templates/Zinc remain unsupported coverage.
 */
export function lexJass(source: string): JassLexed {
  const masked = source.split('');
  const errors: ExtractionError[] = [];
  const directives: { line: number; text: string; kind: string }[] = [];
  let line = 1, lineStart = 0;
  let omitted: 'textmacro' | 'zinc' | 'novjass' | null = null;
  const blank = (start: number, end: number) => {
    for (let p = start; p < end; p++) if (source[p] !== '\n' && source[p] !== '\r') masked[p] = ' ';
  };
  const warn = (message: string, at: number, severity: 'error' | 'warning' = 'warning') =>
    errors.push({ message, line: at, severity, code: severity === 'error' ? 'jass_parse_error' : 'jass_partial_coverage' });
  for (let i = 0; i < source.length;) {
    // Only active source reaches this branch: strings and block comments are
    // consumed below, so directive-shaped text inside them cannot change mode.
    // Once omitted, do not lex the region's strings/comments at all: a template
    // may intentionally contain fragments that are not standalone JASS.
    if (i === lineStart) {
      const end = source.indexOf('\n', i);
      const lineEnd = end < 0 ? source.length : end;
      const directive = source.slice(i, lineEnd).match(/^[\t \uFEFF]*\/\/![\t ]*(\w+)/)?.[1];
      if (directive && (!omitted || directive === `end${omitted}`)) directives.push({ line, text: source.slice(i, lineEnd).trim(), kind: directive });
      if (omitted || directive) {
        if (omitted) {
          // Other markers can be quoted as documentation/template content.
          // Only this region's own terminator is active here.
          if (directive === `end${omitted}`) omitted = null;
        }
        else if (directive && ['endtextmacro', 'endzinc', 'endnovjass'].includes(directive)) {
          warn(`Unmatched ${directive} directive.`, line, 'error');
        } else if (directive === 'textmacro' || directive === 'zinc' || directive === 'novjass') {
          if (omitted) warn(`Nested ${directive} region is unsupported.`, line);
          else omitted = directive;
          if (directive !== 'novjass') warn(`Directive ${directive} is not expanded; coverage is partial.`, line);
        } else if (directive && !omitted) {
          warn(`Directive ${directive} is not expanded; coverage is partial.`, line);
        }
        blank(i, lineEnd);
        i = lineEnd;
        if (i === source.length) break;
      }
    }
    if (source[i] === '\n') { line++; lineStart = ++i; continue; }
    if (source.startsWith('//', i)) {
      const start = i;
      while (i < source.length && source[i] !== '\n') i++;
      blank(start, i);
    } else if (source.startsWith('/*', i)) {
      const start = i, at = line;
      i += 2;
      while (i < source.length && !source.startsWith('*/', i)) {
        if (source[i] === '\n') { line++; lineStart = i + 1; }
        i++;
      }
      if (i === source.length) warn('Unclosed block comment; remaining source excluded.', at, 'error');
      else i += 2;
      blank(start, i);
    } else if (source[i] === '"' || source[i] === "'") {
      const quote = source[i]!, start = i++, at = line;
      let closed = false;
      while (i < source.length && (quote === '"' || (source[i] !== '\n' && source[i] !== '\r'))) {
        if (source[i] === '\\') {
          // Visit physical newlines separately to preserve line coordinates.
          i = Math.min(source.length, i + ((source[i + 1] === '\n' || source[i + 1] === '\r') ? 1 : 2));
          continue;
        }
        if (source[i] === '\n') { line++; lineStart = i + 1; }
        if (source[i++] === quote) { closed = true; break; }
      }
      if (!closed) warn('Unclosed string/rawcode; literal excluded from extraction.', at, 'error');
      blank(start, i);
    } else { i++; }
  }
  const sourceLines = source.split(/\r?\n/);
  const maskedLines = masked.join('').split(/\r?\n/);
  const lines = maskedLines.map((text, index) => {
    return [...text.matchAll(/[A-Za-z_][A-Za-z_0-9]*|[^\s]/g)].map(m => ({ value: m[0], line: index + 1, column: m.index! }));
  });
  if (omitted) warn(`Unclosed ${omitted} region.`, sourceLines.length, 'error');
  return { lines, errors, directives };
}

