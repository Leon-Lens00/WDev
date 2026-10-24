import type { ExtractionError } from '../types';
export interface Token { value: string; line: number; column: number; kind?: 'string' | 'rawcode' | 'number' }
export interface JassComment { start: number; end: number; firstLine: number; lastLine: number }
export interface JassLexed { comments: JassComment[]; lines: Token[][]; semanticLines: Token[][]; errors: ExtractionError[]; directives: { line: number; text: string; kind: string }[] }
/** Offset-preserving lexical pass; literals/comments never become executable tokens.
 * Preprocessor regions are excluded BEFORE lexing their arbitrary contents.
 * novjass is inactive documentation; templates/Zinc remain unsupported coverage.
 */
export function lexJass(source: string): JassLexed {
  const masked = source.split('');
  const errors: ExtractionError[] = [];
  const directives: { line: number; text: string; kind: string }[] = [];
  const literals: Token[] = [];
  const comments: JassComment[] = [];
  let externalBlock = false;
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
        } else if (directive === 'textmacro' || directive === 'textmacro_once' || directive === 'zinc' || directive === 'novjass') {
          if (omitted) warn(`Nested ${directive} region is unsupported.`, line);
          else omitted = directive === 'textmacro_once' ? 'textmacro' : directive;
          if (directive !== 'novjass') warn(`Directive ${directive} is not expanded; coverage is partial.`, line);
        } else if (directive === 'endexternalblock') {
          if (!externalBlock) warn('Unexpected endexternalblock.', line, 'error');
          externalBlock = false;
        } else if (directive === 'i' && externalBlock) {
          // Input text for the external build tool, not JASS source.
        } else if (directive && !omitted) {
          if (directive === 'externalblock') externalBlock = true;
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
      let nesting = 1;
      while (i < source.length && nesting) {
        if (source.startsWith('/*', i)) { nesting++; i += 2; }
        else if (source.startsWith('*/', i)) { nesting--; i += 2; }
        else { if (source[i] === '\n') { line++; lineStart = i + 1; } i++; }
      }
      if (nesting) warn('Unclosed block comment; remaining source excluded.', at, 'error');
      comments.push({ start, end: i, firstLine: at, lastLine: line });
      blank(start, i);
    } else if (source[i] === '"' || source[i] === "'") {
      const quote = source[i]!, start = i++, at = line, column = start - lineStart;
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
      if (closed) literals.push({ value: source.slice(start, i), line: at, column, kind: quote === '"' ? 'string' : 'rawcode' });
      blank(start, i);
    } else { i++; }
  }
  const sourceLines = source.split(/\r?\n/);
  const maskedLines = masked.join('').split(/\r?\n/);
  const lines = maskedLines.map((text, index) => {
    return [...text.matchAll(/[A-Za-z_][A-Za-z_0-9]*|[^\s]/g)].map(m => ({ value: m[0], line: index + 1, column: m.index! }));
  });
  if (externalBlock) warn('Unclosed externalblock.', sourceLines.length, 'error');
  if (omitted) warn(`Unclosed ${omitted} region.`, sourceLines.length, 'error');
  // The structural lexer keeps its historical masked stream. Expression ASTs
  // need atomic literals and compound operators, with the same source offsets.
  const semanticLines = maskedLines.map((text, index) => [...text.matchAll(/[A-Za-z_][A-Za-z_0-9]*|(?:0[xX][0-9a-fA-F]+|\$[0-9a-fA-F]+|(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+))|(?:==|!=|<=|>=)|[^\s]/g)].map(m => ({ value: m[0], line: index + 1, column: m.index!, ...(/^(?:[0-9]|\$|\.[0-9])/.test(m[0]) ? { kind: 'number' as const } : {}) })) as Token[]);
  for (const literal of literals) semanticLines[literal.line - 1]!.push(literal);
  for (const tokens of semanticLines) tokens.sort((a, b) => a.column - b.column);
  // JassHelper's linebreak fixer joins the physical lines covered by a
  // string. Keep token coordinates physical, but parse one logical statement.
  const roots = semanticLines.map((_, i) => i);
  for (const literal of literals) {
    const start = literal.line - 1, last = start + (literal.value.match(/\n/g)?.length ?? 0);
    for (let i = start + 1; i <= last; i++) roots[i] = roots[start]!;
  }
  for (let i = 0; i < semanticLines.length; i++) if (roots[i] !== i) {
    semanticLines[roots[i]!]!.push(...semanticLines[i]!); semanticLines[i] = [];
  }
  for (const tokens of semanticLines) tokens.sort((a, b) => a.line - b.line || a.column - b.column);
  return { lines, semanticLines, errors, directives, comments };
}

