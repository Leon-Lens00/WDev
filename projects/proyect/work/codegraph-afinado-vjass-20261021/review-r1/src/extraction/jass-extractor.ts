import { Node, NodeKind, Edge, ExtractionResult, ExtractionError, UnresolvedReference } from '../types';
import { generateNodeId } from './tree-sitter-helpers';

interface Token { value: string; line: number; column: number }
interface Block { keyword: string; node: Node }
export interface JassLexed { lines: Token[][]; errors: ExtractionError[] }
const IDENTIFIER = /^[A-Za-z_][A-Za-z_0-9]*$/;
const MODIFIERS = new Set(['private', 'public', 'static', 'stub', 'constant', 'readonly', 'debug']);
const STATEMENTS = new Set(['call', 'set', 'return', 'if', 'elseif', 'exitwhen', 'loop', 'then', 'else', 'endif', 'endloop', 'and', 'or', 'not']);
const PRIMITIVES = new Set(['nothing', 'integer', 'real', 'boolean', 'string', 'code', 'handle', 'thistype']);
const CONTAINERS: Record<string, NodeKind> = {
  library: 'namespace', library_once: 'namespace', scope: 'namespace',
  struct: 'struct', module: 'module', interface: 'interface',
};

/** Offset-preserving lexical pass; literals/comments never become executable tokens.
 * Preprocessor regions are excluded BEFORE lexing their arbitrary contents.
 * novjass is inactive documentation; templates/Zinc remain unsupported coverage.
 */
export function lexJass(source: string): JassLexed {
  const masked = source.split('');
  const errors: ExtractionError[] = [];
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
      if (omitted || directive) {
        if (omitted && directive === `end${omitted}`) omitted = null;
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
  return { lines, errors };
}

/** Native CodeGraph extraction result, consumed by its normal SQLite/index/sync
 * pipeline. This is a structural JASS/vJASS parser, not JassHelper or a VM.
 */
export class JassExtractor {
  private nodes: Node[] = [];
  private edges: Edge[] = [];
  private refs: UnresolvedReference[] = [];
  private errors: ExtractionError[] = [];
  private stack: Block[] = [];
  private globals = false;
  private sourceLines: string[];
  private file!: Node;

  constructor(private filePath: string, private source: string, private language: 'jass' | 'vjass') {
    this.sourceLines = source.split(/\r?\n/);
  }

  extract(): ExtractionResult {
    const start = Date.now();
    const lexed = lexJass(this.source);
    this.errors = lexed.errors.map(e => ({ ...e, filePath: this.filePath }));
    this.file = this.node('file', this.filePath, { value: this.filePath, line: 1, column: 0 }, null);
    this.file.endLine = this.sourceLines.length;
    this.file.endColumn = this.sourceLines.at(-1)?.length ?? 0;
    for (const tokens of lexed.lines) this.parseLine(tokens);
    for (const open of this.stack) this.error(`Missing end${open.keyword} for ${open.node.qualifiedName}.`, open.node.startLine);
    if (this.globals) this.error('Missing endglobals.', this.sourceLines.length);
    return { nodes: this.nodes, edges: this.edges, unresolvedReferences: this.refs,
             errors: this.errors, durationMs: Date.now() - start };
  }

  private error(message: string, line: number, severity: 'error' | 'warning' = 'error'): void {
    this.errors.push({ message, filePath: this.filePath, line, severity,
                       code: severity === 'error' ? 'jass_parse_error' : 'jass_partial_coverage' });
  }

  private parent(): Node { return this.stack.at(-1)?.node ?? this.file; }

  private node(kind: NodeKind, name: string, token: Token, parent: Node | null, signature?: string): Node {
    const qualifiedName = parent && parent.kind !== 'file' ? `${parent.qualifiedName}.${name}` : name;
    const node: Node = {
      id: generateNodeId(this.filePath, kind, qualifiedName, token.line), kind, name, qualifiedName,
      filePath: this.filePath, language: this.language, startLine: token.line, endLine: token.line,
      startColumn: token.column, endColumn: this.sourceLines[token.line - 1]?.length ?? 0,
      signature, updatedAt: Date.now(),
    };
    this.nodes.push(node);
    if (parent) this.edges.push({ source: parent.id, target: node.id, kind: 'contains', provenance: 'heuristic' });
    return node;
  }

  private ref(from: Node, name: string, kind: UnresolvedReference['referenceKind'], at: Token): void {
    if ((kind === 'type_of' || kind === 'returns' || kind === 'extends') && PRIMITIVES.has(name)) return;
    this.refs.push({ fromNodeId: from.id, referenceName: name, referenceKind: kind,
                     line: at.line, column: at.column, filePath: this.filePath, language: this.language });
  }

  private parseLine(tokens: Token[]): void {
    if (!tokens.length) return;
    let p = 0;
    const modifiers: string[] = [];
    while (MODIFIERS.has(tokens[p]?.value ?? '')) modifiers.push(tokens[p++]!.value);
    const head = tokens[p];
    if (!head) return;
    const word = head.value;
    const parent = this.parent();
    if (word.startsWith('end') && ['endfunction', 'endmethod', 'endlibrary', 'endscope', 'endstruct', 'endmodule', 'endinterface'].includes(word)) {
      const open = this.stack.at(-1);
      if (!open || `end${open.keyword}` !== word) { this.error(`Unmatched ${word}.`, head.line); return; }
      open.node.endLine = head.line;
      open.node.endColumn = this.sourceLines[head.line - 1]?.length ?? 0;
      this.stack.pop();
      return;
    }
    if (word === 'globals') { if (this.globals) this.error('Nested globals block.', head.line); this.globals = true; return; }
    if (word === 'endglobals') { if (!this.globals) this.error('Unmatched endglobals.', head.line); this.globals = false; return; }
    if (word === 'implement' || word === 'delegate' || word === 'hook' || word === 'key') {
      this.error(`${word} expansion/dispatch is not modeled.`, head.line, 'warning'); return;
    }
    if ((word === 'if' && modifiers.includes('static')) || modifiers.includes('debug')) {
      this.error('Conditional compilation is not evaluated; extracted references are potential paths.', head.line, 'warning');
    }
    const kind = CONTAINERS[word];
    if (kind) {
      const name = tokens[p + 1];
      if (!name || !IDENTIFIER.test(name.value)) { this.error(`Missing ${word} name.`, head.line); return; }
      const node = this.node(kind, name.value, head, parent, this.sourceLines[head.line - 1]?.trim());
      this.visibility(node, modifiers);
      this.stack.push({ keyword: word === 'library_once' ? 'library' : word, node });
      let dependencies = false;
      for (let i = p + 2; i < tokens.length; i++) {
        const directive = tokens[i]!.value;
        if (directive === 'extends' && tokens[i + 1]) this.ref(node, tokens[++i]!.value, 'extends', tokens[i]!);
        else if (directive === 'initializer' && tokens[i + 1]) { dependencies = false; this.ref(node, tokens[++i]!.value, 'calls', tokens[i]!); }
        else if (['requires', 'needs', 'uses'].includes(directive)) dependencies = true;
        else if (dependencies && IDENTIFIER.test(directive) && directive !== 'optional') this.ref(node, directive, 'imports', tokens[i]!);
      }
      return;
    }
    if (word === 'type') {
      const name = tokens[p + 1];
      if (name && IDENTIFIER.test(name.value)) {
        const node = this.node('type_alias', name.value, head, parent, this.sourceLines[head.line - 1]?.trim());
        this.visibility(node, modifiers);
        if (tokens[p + 2]?.value === 'extends' && tokens[p + 3]) this.ref(node, tokens[p + 3]!.value, 'extends', tokens[p + 3]!);
      } else this.error('Missing type name.', head.line);
      return;
    }
    if (word === 'function' || word === 'method' || word === 'native') {
      const functionInterface = word === 'function' && tokens[p + 1]?.value === 'interface';
      const name = tokens[p + (functionInterface ? 2 : 1)];
      const takes = tokens.findIndex(t => t.value === 'takes');
      const returns = tokens.findIndex(t => t.value === 'returns');
      if (!name || !IDENTIFIER.test(name.value) || takes < 0 || returns <= takes || !tokens[returns + 1]) {
        this.error(`Incomplete ${word} header. Multiline headers are not supported.`, head.line); return;
      }
      let declaredName = name.value;
      if (word === 'method' && name.value === 'operator') {
        declaredName = 'operator ' + tokens.slice(p + 2, takes).map(t => t.value).join('');
        this.error('Operator getter/setter/index dispatch is not resolved.', head.line, 'warning');
      }
      const node = this.node(functionInterface ? 'type_alias' : word === 'method' ? 'method' : 'function', declaredName, head, parent, this.sourceLines[head.line - 1]?.trim());
      this.visibility(node, modifiers);
      node.isStatic = modifiers.includes('static');
      node.isAbstract = parent.kind === 'interface';
      node.returnType = tokens[returns + 1]!.value;
      this.ref(node, node.returnType, 'returns', tokens[returns + 1]!);
      const parameters = tokens.slice(takes + 1, returns);
      for (let i = 0; i < parameters.length;) {
        const type = parameters[i++];
        if (!type || type.value === 'nothing') break;
        const parameter = parameters[i++];
        if (!parameter || !IDENTIFIER.test(parameter.value)) { this.error('Incomplete parameter declaration.', head.line); break; }
        const declared = this.node('parameter', parameter.value, parameter, node, `${type.value} ${parameter.value}`);
        this.ref(declared, type.value, 'type_of', type);
        if (parameters[i]?.value === ',') i++;
      }
      if (word !== 'native' && !functionInterface && parent.kind !== 'interface') this.stack.push({ keyword: word, node });
      if (functionInterface) this.error('Function-interface indirect dispatch is not resolved.', head.line, 'warning');
      return;
    }
    let body = tokens.slice(p);
    // Globals, struct fields and explicitly local declarations. The tokens
    // after '=' are still visited, so initializer calls enter the same graph.
    const local = word === 'local';
    const declarationsAllowed = local || this.globals || ['struct', 'interface', 'module'].includes(parent.kind);
    let at = local ? p + 1 : p;
    const type = tokens[at++];
    if (tokens[at]?.value === 'array') at++;
    const variable = tokens[at];
    if (declarationsAllowed && type && variable && IDENTIFIER.test(type.value) && IDENTIFIER.test(variable.value) &&
        !['call', 'set', 'return', 'if', 'elseif', 'exitwhen', 'loop'].includes(type.value) &&
        [undefined, '=', '['].includes(tokens[at + 1]?.value)) {
      const node = this.node(local ? 'variable' : modifiers.includes('constant') ? 'constant' : this.globals ? 'variable' : 'field', variable.value, type, parent,
                             this.sourceLines[type.line - 1]?.trim());
      this.visibility(node, modifiers);
      node.isStatic = modifiers.includes('static');
      this.ref(node, type.value, 'type_of', type);
      const equal = tokens.findIndex(t => t.value === '=');
      body = equal < 0 ? [] : tokens.slice(equal + 1);
      // A local initializer executes in its function/method, as in upstream
      // extraction. Keep the variable's type edge on the declaration itself.
      this.calls(body, local ? parent : node);
      return;
    }
    this.calls(body, parent);
  }

  private visibility(node: Node, modifiers: string[]): void {
    node.visibility = modifiers.includes('private') ? 'private' : 'public';
    node.isExported = !modifiers.includes('private') && !['parameter', 'variable'].includes(node.kind);
  }

  private calls(tokens: Token[], owner: Node): void {
    for (let i = 0; i < tokens.length; i++) {
      const token = tokens[i]!;
      if (STATEMENTS.has(token.value)) continue;
      const callback = token.value === 'function';
      const start = callback ? i + 1 : i;
      const first = tokens[start];
      if (!first || (!IDENTIFIER.test(first.value) && first.value !== '.')) continue;
      if (!callback && tokens[i - 1]?.value === '.') continue;
      let j = start;
      let name = '';
      if (tokens[j]?.value === '.') {
        if (tokens[j - 1]?.value === ')' || tokens[j - 1]?.value === ']') {
          this.error('Chained call/index receiver is not inferred.', first.line, 'warning');
          name = '__jass_unresolved_receiver.';
        } else name = 'this.';
        j++;
      }
      if (!tokens[j] || !IDENTIFIER.test(tokens[j]!.value)) continue;
      name += tokens[j++]!.value;
      while (tokens[j]?.value === '.' && tokens[j + 1] && IDENTIFIER.test(tokens[j + 1]!.value)) {
        name += '.' + tokens[j + 1]!.value; j += 2;
      }
      if (callback || tokens[j]?.value === '(') {
        this.ref(owner, name, callback ? 'function_ref' : 'calls', first);
        if (name === 'ExecuteFunc' || /\.(execute|evaluate)$/.test(name)) this.error(`Dynamic dispatch ${name} is not expanded.`, first.line, 'warning');
        i = j - 1;
      }
    }
  }
}
