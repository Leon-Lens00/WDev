import { Node, NodeKind, Edge, ExtractionResult, ExtractionError, UnresolvedReference } from '../types';
import { generateNodeId } from './tree-sitter-helpers';
import { expandJass, JassCatalog } from './jass-preprocessor';

import { lexJass, Token } from './jass-lexer';
export { lexJass } from './jass-lexer';
interface Block { keyword: string; node: Node }
const IDENTIFIER = /^[A-Za-z_][A-Za-z_0-9]*$/;
const MODIFIERS = new Set(['private', 'public', 'static', 'stub', 'constant', 'readonly', 'debug']);
const STATEMENTS = new Set(['call', 'set', 'return', 'if', 'elseif', 'exitwhen', 'loop', 'then', 'else', 'endif', 'endloop', 'and', 'or', 'not']);
const PRIMITIVES = new Set(['nothing', 'integer', 'real', 'boolean', 'string', 'code', 'handle', 'thistype']);
const CONTAINERS: Record<string, NodeKind> = {
  library: 'namespace', library_once: 'namespace', scope: 'namespace',
  struct: 'struct', module: 'module', interface: 'interface',
};

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

  constructor(private filePath: string, private source: string, private language: 'jass' | 'vjass', private catalog?: JassCatalog) {
    this.sourceLines = source.split(/\r?\n/);
  }

  extract(): ExtractionResult {
    const start = Date.now();
    const original = this.source;
    const expansion = expandJass(this.filePath, original, this.catalog);
    this.source = expansion.source;
    this.sourceLines = this.source.split(/\r?\n/);
    const lexed = lexJass(this.source);
    this.errors = lexed.errors.filter(e => !/^Directive (textmacro|runtextmacro|import) /.test(e.message)).map(e => ({ ...e, filePath: this.filePath }));
    this.file = this.node('file', this.filePath, { value: this.filePath, line: 1, column: 0 }, null);
    this.file.endLine = this.sourceLines.length;
    this.file.endColumn = this.sourceLines.at(-1)?.length ?? 0;
    for (const tokens of lexed.lines) this.parseLine(tokens);
    for (const open of this.stack) this.error(`Missing end${open.keyword} for ${open.node.qualifiedName}.`, open.node.startLine);
    if (this.globals) this.error('Missing endglobals.', this.sourceLines.length);
    for (const node of this.nodes) {
      const origin = expansion.lines[node.startLine - 1];
      if (origin?.via) node.docstring = `CodeGraph static projection: ${origin.via}. Declaration origin ${origin.file}:${origin.line}. Source below is the invocation, not an expanded body.`;
      node.startLine = origin?.anchor ?? node.startLine;
      node.endLine = expansion.lines[node.endLine - 1]?.anchor ?? node.endLine;
      if (origin?.via) { node.startColumn = 0; node.endColumn = original.split(/\r?\n/)[node.endLine - 1]?.length ?? 0; }
    }
    for (const ref of this.refs) { const origin = expansion.lines[ref.line - 1]; ref.line = origin?.anchor ?? ref.line; if (origin?.via) ref.column = 0; }
    for (const edge of this.edges) if (edge.line) edge.line = expansion.lines[edge.line - 1]?.anchor ?? edge.line;
    for (const error of this.errors) if (error.line) error.line = expansion.lines[error.line - 1]?.anchor ?? error.line;
    this.errors.push(...expansion.errors);
    for (const imp of expansion.imported) this.ref(this.file, `__jass_import__:${imp.path}`, 'imports', { value: imp.path, line: imp.line, column: 0 });
    const projections = new Set(expansion.lines.filter(l => l.via).map(l => `${l.anchor}:${l.via}`));
    for (const projection of projections) {
      const at = Number(projection.slice(0, projection.indexOf(':')));
      this.error(`Static projection at invocation: ${projection.slice(projection.indexOf(':') + 1)}. Generated bodies are not verbatim on-disk source.`, at, 'warning');
    }
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
      // Persist executable header tokens: comments may quote another base.
      const signature = tokens.map(t => t.value).join(' ').replace(/\s*\.\s*/g, '.');
      const node = this.node(kind, name.value, head, parent, signature);
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
        if (/\[\]/.test(declaredName)) this.error('Index operator dispatch is not resolved.', head.line, 'warning');
      }
      const node = this.node(functionInterface ? 'type_alias' : word === 'method' ? 'method' : 'function', declaredName, head, parent, this.sourceLines[head.line - 1]?.trim());
      this.visibility(node, modifiers);
      node.isStatic = modifiers.includes('static');
      node.isAbstract = parent.kind === 'interface';
      node.returnType = tokens[returns + 1]!.value;
      if (word === 'method' && modifiers.includes('static') && (name.value === 'onInit' || /^__cg_.+_onInit$/.test(name.value)) && parent.kind === 'struct') this.ref(parent, declaredName, 'calls', head);
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
          this.error('Factory/index receiver requires a declared type/return type; other chains are not inferred.', first.line, 'warning');
          const close = tokens[j - 1]!.value;
          const open = close === ')' ? '(' : '[';
          let depth = 1, k = j - 2;
          for (; k >= 0; k--) {
            if (tokens[k]!.value === close) depth++;
            if (tokens[k]!.value === open && --depth === 0) break;
          }
          let begin = k - 1;
          while (begin > 0 && tokens[begin - 1]?.value === '.' && IDENTIFIER.test(tokens[begin - 2]?.value ?? '')) begin -= 2;
          const receiver = tokens.slice(begin, k).map(t => t.value).join('');
          name = k > 0 && /^[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*$/.test(receiver)
            ? `__jass_${close === ')' ? 'factory' : 'index'}__:${receiver}.` : '__jass_unresolved_receiver.';
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
        if (name === 'ExecuteFunc') {
          const literal = this.sourceLines[first.line - 1]?.slice(first.column).match(/^ExecuteFunc\s*\(\s*"([A-Za-z_]\w*)"\s*\)/)?.[1];
          if (literal) this.ref(owner, `__jass_execute_func__:${literal}`, 'calls', first);
          else this.error(`Computed dispatch ${name} is not resolved.`, first.line, 'warning');
        }
        else if (/\.(execute|evaluate)$/.test(name)) this.error(`Potential indirect dispatch ${name} is not expanded unless a declared method matches the receiver.`, first.line, 'warning');
        i = j - 1;
      } else if (!callback && name.includes('.') && !name.startsWith('__jass_') && !name.endsWith('.exists')) {
        const setter = tokens[j]?.value === '=' && tokens[0]?.value === 'set';
        this.ref(owner, `__jass_property_${setter ? 'set' : 'get'}__:${name}`, 'references', first);
        i = j - 1;
      }
    }
  }
}
