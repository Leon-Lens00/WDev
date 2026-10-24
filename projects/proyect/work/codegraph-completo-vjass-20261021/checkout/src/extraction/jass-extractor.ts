import { Node, NodeKind, Edge, ExtractionResult, ExtractionError, UnresolvedReference } from '../types';
import { generateNodeId } from './tree-sitter-helpers';
import { expandJass, buildJassCatalog, JassCatalog } from './jass-preprocessor';

import { lexJass, Token } from './jass-lexer';
import { parseJassExpression, encodeJassExpression, JassExpression } from './jass-expression';
export { lexJass } from './jass-lexer';
interface Block { keyword: string; node: Node }
const IDENTIFIER = /^[A-Za-z_][A-Za-z_0-9]*$/;
const MODIFIERS = new Set(['private', 'public', 'static', 'stub', 'constant', 'readonly', 'debug']);
const STATEMENTS = new Set(['call', 'set', 'return', 'if', 'elseif', 'exitwhen', 'loop', 'then', 'else', 'endif', 'endloop', 'while', 'endwhile', 'for', 'endfor', 'break', 'debug', 'static']);
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
    this.catalog ??= buildJassCatalog(new Map([[this.filePath, original]]));
    const expansion = expandJass(this.filePath, original, this.catalog);
    this.source = expansion.source;
    this.sourceLines = this.source.split(/\r?\n/);
    const lexed = lexJass(this.source);
    this.errors = lexed.errors.filter(e => !/^Directive (textmacro(?:_once)?|runtextmacro|import|inject|endinject|dovjassinit|loaddata) /.test(e.message)).map(e => ({ ...e, filePath: this.filePath }));
    this.file = this.node('file', this.filePath, { value: this.filePath, line: 1, column: 0 }, null);
    this.file.endLine = this.sourceLines.length;
    this.file.endColumn = this.sourceLines.at(-1)?.length ?? 0;
    const unknownPreprocessing = lexed.lines.some(tokens => tokens[0]?.value === '#');
    if (unknownPreprocessing) this.error('C/cJASS preprocessing is outside the JASS/vJASS profile; resolved targets are conditional on the indexed source being the actual build input.', 1, 'warning');
    const externalTools = lexed.directives.filter(d => ['external', 'externalblock'].includes(d.kind)).map(d => ({ kind: d.kind, tool: d.text.split(/\s+/)[2], line: d.line, outputs: 'not-inferred' }));
    if (externalTools.length) (this.file.semanticData ??= {}).externalTools = externalTools;
    const injections = new Map<string, { tokens: Token[][]; at: number; init?: number; end?: number }>();
    const injectionLines = new Set<number>();
    let activeInjection: string | undefined;
    const directives = new Map(lexed.directives.map(d => [d.line, d]));
    for (let i = 0; i < lexed.semanticLines.length; i++) {
      const directive = directives.get(i + 1);
      if (directive?.kind === 'inject') {
        const name = directive.text.match(/^\/\/!\s*inject\s+(main|config)\s*$/)?.[1];
        if (!name || activeInjection || injections.has(name)) this.error('Invalid, nested or duplicate inject directive.', i + 1);
        else { activeInjection = name; injections.set(name, { tokens: [], at: i + 1 }); }
      } else if (directive?.kind === 'endinject') {
        if (!activeInjection) this.error('Unexpected endinject.', i + 1);
        else injections.get(activeInjection)!.end = i + 1;
        activeInjection = undefined;
      } else if (directive?.kind === 'dovjassinit') {
        if (activeInjection !== 'main') this.error('dovjassinit requires inject main.', i + 1);
        else injections.get('main')!.init = i + 1;
      } else if (activeInjection) {
        injections.get(activeInjection)!.tokens.push(lexed.semanticLines[i]!);
        injectionLines.add(i);
      }
    }
    if (activeInjection) this.error('Missing endinject.', injections.get(activeInjection)!.at);
    if (injections.has('main') && !injections.get('main')!.init) this.error('inject main requires dovjassinit.', injections.get('main')!.at);
    for (let i = 0; i < lexed.semanticLines.length; i++) {
      if (injectionLines.has(i)) continue;
      const tokens = lexed.semanticLines[i]!;
      const parent = this.parent();
      if (parent.kind === 'function' && (injections.has(parent.name) || this.catalog?.injections.get(parent.name)?.length === 1) && tokens[0]?.value !== 'endfunction') continue;
      this.parseStatement(tokens);
    }
    for (const [name, body] of injections) {
      const targets = this.nodes.filter(n => n.kind === 'function' && n.qualifiedName === name);
      if (targets.length > 1) { this.error(`inject ${name}: multiple entry functions in this source.`, body.at, 'warning'); continue; }
      const sourceOwner = this.nodes.filter(n => n.kind === 'namespace' && n.startLine <= body.at && n.endLine >= (body.end ?? body.at)).sort((a, b) => b.qualifiedName.length - a.qualifiedName.length)[0] ?? this.file;
      const target = this.node('namespace', '__jass_inject_' + name, { value: name, line: body.at, column: 0 }, sourceOwner, '//! inject ' + name);
      target.endLine = body.end ?? Math.max(body.at, ...body.tokens.flat().map(t => t.line));
      (target.semanticData ??= {}).injectionTarget = name;
      (target.semanticData ??= {}).injection = { at: body.at, init: body.init };
      for (const entry of targets) entry.docstring = `JassHelper inject ${name} replaces this original body. Executable source: ${target.qualifiedName} at ${this.filePath}:${body.at}.`;
      this.stack.push({ keyword: 'function', node: target });
      for (const tokens of body.tokens) this.parseStatement(tokens);
      this.stack.pop();
    }
    for (const open of this.stack) this.error(`Missing end${open.keyword} for ${open.node.qualifiedName}.`, open.node.startLine);
    if (this.globals) this.error('Missing endglobals.', this.sourceLines.length);
    const position = (line: number, column: number) => {
      const origin = expansion.lines[line - 1];
      const segment = !origin?.via ? origin?.offsets?.find(s => column >= s.from && column < s.to) : undefined;
      return { line: segment?.line ?? origin?.anchor ?? line, column: segment ? segment.column + column - segment.from : origin?.via ? 0 : column };
    };
    for (const node of this.nodes) {
      if (unknownPreprocessing) (node.semanticData ??= {}).unknownPreprocessing = true;
      const globalInjection = node.kind === 'function' ? this.catalog?.injections.get(node.qualifiedName) : undefined;
      if (globalInjection?.length === 1) {
        (node.semanticData ??= {}).injection = globalInjection[0];
        node.docstring ??= `JassHelper inject ${node.name} replaces this original body. Executable source at ${globalInjection[0]!.file}:${globalInjection[0]!.at}.`;
      }
      if (this.catalog?.profile.apiFiles.includes(this.filePath)) (node.semanticData ??= {}).api = true;
      const origin = expansion.lines[node.startLine - 1];
      if (origin?.conditional) (node.semanticData ??= {}).conditional = true;
      if (origin?.via) node.docstring = `${node.docstring ? node.docstring + '\n' : ''}CodeGraph static projection: ${origin.via}. Declaration origin ${origin.file}:${origin.line}. Source below is the invocation, not an expanded body.`;
      if (node.semanticData) node.semanticData = JSON.parse(JSON.stringify(node.semanticData, (key, value) => key === 'at' ? undefined : key === 'line' && typeof value === 'number' ? expansion.lines[value - 1]?.anchor ?? value : value));
      const startPosition = position(node.startLine, node.startColumn);
      node.startLine = startPosition.line; node.startColumn = startPosition.column;
      node.endLine = expansion.lines[node.endLine - 1]?.endAnchor ?? expansion.lines[node.endLine - 1]?.anchor ?? node.endLine;
      if (node.kind === 'file') { node.startLine = 1; node.startColumn = 0; node.endLine = original.split(/\r?\n/).length; }
      if (origin?.via || origin?.normalized) { if (origin.via) node.startColumn = 0; node.endColumn = original.split(/\r?\n/)[node.endLine - 1]?.length ?? 0; }
    }
    const byId = new Map(this.nodes.map(node => [node.id, node]));
    for (const ref of this.refs) {
      const origin = expansion.lines[ref.line - 1];
      const mapped = position(ref.line, ref.column);
      ref.line = mapped.line; ref.column = mapped.column;
      if (origin?.conditional) {
        const owner = byId.get(ref.fromNodeId);
        if (owner) (((owner.semanticData ??= {}).conditionalRefs ??= []) as string[]).push(ref.line + ':' + ref.referenceName);
      }
    }
    for (const edge of this.edges) if (edge.line) edge.line = expansion.lines[edge.line - 1]?.anchor ?? edge.line;
    for (const error of this.errors) if (error.line) error.line = expansion.lines[error.line - 1]?.anchor ?? error.line;
    this.errors.push(...expansion.errors);
    for (const imp of expansion.imported) this.ref(this.file, `__jass_import_resolved__:${imp.path}`, 'imports', { value: imp.path, line: imp.line, column: 0 });
    for (const macro of this.catalog.macros.filter(m => m.file === this.filePath)) {
      const node = this.node('module', macro.name, { value: macro.name, line: macro.line, column: 0 }, this.file, original.split(/\r?\n/)[macro.line - 1]?.trim());
      node.semanticData = { templateKind: 'textmacro', parameters: macro.args };
      node.endLine = macro.endLine;
      node.endColumn = original.split(/\r?\n/)[node.endLine - 1]?.length ?? 0;
    }
    for (const use of expansion.templateUses) {
      const owner = this.nodes.find(n => n.qualifiedName === use.consumer && ['struct', 'namespace', 'module'].includes(n.kind)) ?? this.file;
      this.ref(owner, '__jass_template__:' + JSON.stringify({ kind: use.kind, name: use.name, file: use.file, line: use.definitionLine }), 'imports', { value: use.name, line: use.line, column: 0 });
    }
    for (const load of expansion.slkLoads) {
      const owner = this.nodes.find(n => n.qualifiedName === load.consumer && ['namespace', 'struct'].includes(n.kind)) ?? this.file;
      (((owner.semanticData ??= {}).slkLoads ??= []) as unknown[]).push({ path: load.path, sha256: load.sha256, line: load.line, struct: load.data.typeName });
      const at = { value: load.data.typeName, line: load.line, column: 0 };
      const firstRef = this.refs.length;
      this.ref(owner, '__jass_slk_method__:' + load.data.typeName, load.data.rows.length ? 'calls' : 'references', at);
      for (const field of load.data.fields.values()) this.ref(owner, '__jass_slk_field__:' + JSON.stringify({ type: load.data.typeName, field }), 'references', at);
      for (const row of load.data.rows) {
        this.ref(owner, '__jass_slk_value__:' + JSON.stringify({ type: load.data.typeName, value: row.key }), 'calls', at);
        for (const cell of row.values) this.ref(owner, '__jass_slk_value__:' + JSON.stringify({ type: load.data.typeName, ...cell }), 'calls', at);
      }
      if (load.conditional) for (const ref of this.refs.slice(firstRef)) (((owner.semanticData ??= {}).conditionalRefs ??= []) as string[]).push(ref.line + ':' + ref.referenceName);
    }
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

  private parseStatement(tokens: Token[]): void {
    const before = this.nodes.length;
    this.parseLine(tokens);
    const end = tokens.reduce((end, t) => Math.max(end, t.line + (t.kind === 'string' ? t.value.match(/\n/g)?.length ?? 0 : 0)), 0);
    for (const node of this.nodes.slice(before)) node.endLine = Math.max(node.endLine, end);
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
    if (parent.kind === 'module' && word !== 'endmodule') return;
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
    if (word === 'delegate') {
      if (parent.kind !== 'struct') { this.error('delegate requires a struct owner.', head.line); return; }
      const before = this.nodes.length;
      this.parseLine(tokens.filter((_, i) => i !== p));
      const field = this.nodes.slice(before).find(n => n.kind === 'field');
      if (field) {
        (field.semanticData ??= {}).isDelegate = true;
        (((parent.semanticData ??= {}).delegates ??= []) as string[]).push(field.name);
      }
      return;
    }
    if (word === 'key') {
      if (!this.globals && parent.kind !== 'struct') { this.error('key declaration requires globals or a struct field.', head.line); return; }
      const name = tokens[p + 1];
      if (!name || !IDENTIFIER.test(name.value)) { this.error('Missing key name.', head.line); return; }
      const node = this.node('constant', name.value, head, parent, this.sourceLines[head.line - 1]?.trim());
      this.visibility(node, modifiers); node.semanticData = { declaredType: 'integer', isKey: true }; return;
    }
    if (word === 'keyword') {
      const name = tokens[p + 1];
      if (name) this.ref(parent, '__jass_keyword__:' + name.value, 'references', name);
      return;
    }
    if (word === 'hook') {
      const target = tokens[p + 1]?.value;
      const callback = tokens.slice(p + 2).map(t => t.value).join('');
      if (!target || !callback) { this.error('Incomplete hook declaration.', head.line); return; }
      (((parent.semanticData ??= {}).hooks ??= []) as unknown[]).push({ target, callback, line: head.line });
      this.ref(parent, callback, 'function_ref', head); return;
    }
    if (word === 'implement') {
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
      if (kind === 'module') (node.semanticData ??= {}).templateKind = 'module';
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
        node.semanticData = { isArray: tokens.some(t => t.value === 'array') };
        if (tokens[p + 2]?.value === 'extends' && tokens[p + 3]) this.ref(node, tokens[p + 3]!.value, 'extends', tokens[p + 3]!);
      } else this.error('Missing type name.', head.line);
      return;
    }
    if (word === 'function' || word === 'method' || word === 'native') {
      const functionInterface = word === 'function' && tokens[p + 1]?.value === 'interface';
      const name = tokens[p + (functionInterface ? 2 : 1)];
      if (parent.kind === 'interface' && word === 'method' && name?.value === 'operator' && tokens[p + 2]?.value === '<' && !tokens.some(t => t.value === 'takes')) {
        const node = this.node('method', 'operator <', head, parent, this.sourceLines[head.line - 1]?.trim());
        this.visibility(node, modifiers); node.isAbstract = true; node.isStatic = false; node.returnType = 'boolean';
        node.semanticData = { parameterTypes: [parent.name], shorthandOperator: true }; return;
      }
      const takes = tokens.findIndex(t => t.value === 'takes');
      const returns = tokens.findIndex(t => t.value === 'returns');
      if (!name || !IDENTIFIER.test(name.value) || takes < 0 || returns <= takes || !tokens[returns + 1]) {
        this.error(`Incomplete ${word} header. Multiline headers are not supported.`, head.line); return;
      }
      let declaredName = name.value;
      if (word === 'method' && name.value === 'operator') {
        declaredName = 'operator ' + tokens.slice(p + 2, takes).map(t => t.value).join('');
      }
      const node = this.node(functionInterface ? 'type_alias' : word === 'method' ? 'method' : 'function', declaredName, head, parent, this.sourceLines[head.line - 1]?.trim());
      this.visibility(node, modifiers);
      node.isStatic = modifiers.includes('static');
      node.isAbstract = parent.kind === 'interface';
      node.returnType = tokens[returns + 1]!.value;
      node.semanticData = { functionInterface, parameterTypes: tokens.slice(takes + 1, returns).filter((_, i) => i % 3 === 0).filter(t => t.value !== 'nothing').map(t => t.value) };
      if (word === 'method' && modifiers.includes('static') && (name.value === 'onInit' || /^__cg_.+_onInit$/.test(name.value)) && parent.kind === 'struct') this.ref(parent, declaredName, 'calls', head);
      this.ref(node, node.returnType, 'returns', tokens[returns + 1]!);
      const parameters = tokens.slice(takes + 1, returns);
      for (let i = 0; i < parameters.length;) {
        const type = parameters[i++];
        if (!type || type.value === 'nothing') break;
        const parameter = parameters[i++];
        if (!parameter || !IDENTIFIER.test(parameter.value)) { this.error('Incomplete parameter declaration.', head.line); break; }
        const declared = this.node('parameter', parameter.value, parameter, node, `${type.value} ${parameter.value}`);
        declared.semanticData = { declaredType: type.value };
        this.ref(declared, type.value, 'type_of', type);
        if (parameters[i]?.value === ',') i++;
      }
      if (word !== 'native' && !functionInterface && parent.kind !== 'interface') this.stack.push({ keyword: word, node });
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
      node.semanticData = { declaredType: type.value, isArray: tokens[(local ? p + 1 : p) + 1]?.value === 'array', arrayDepth: tokens[(local ? p + 1 : p) + 1]?.value === 'array' ? Math.max(1, tokens.slice(at + 1, tokens.findIndex(t => t.value === '=') < 0 ? undefined : tokens.findIndex(t => t.value === '=')).filter(t => t.value === '[').length) : 0 };
      this.ref(node, type.value, 'type_of', type);
      const equal = tokens.findIndex(t => t.value === '=');
      body = equal < 0 ? [] : tokens.slice(equal + 1);
      if (body.length) { const parsed = parseJassExpression(body); if (parsed.expression && !parsed.errors.length) node.semanticData.values = [parsed.expression]; }
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
    const path = (expression: JassExpression): string | undefined => {
      if (expression.kind === 'name') return expression.name;
      if (expression.kind !== 'member' || expression.colon) return undefined;
      const prefix = path(expression.object);
      return prefix ? prefix + '.' + expression.name : undefined;
    };
    const emit = (expression: JassExpression, access: 'call' | 'get' | 'set' | 'function') => {
      const target = access === 'call' && expression.kind === 'call' ? expression.callee : expression;
      const named = path(target);
      if ((access === 'function' || (access === 'call' && target.kind === 'name')) && named) this.ref(owner, named, access === 'function' ? 'function_ref' : 'calls', target.at);
      else this.ref(owner, encodeJassExpression(expression, access), access === 'call' ? 'calls' : 'references', target.at);
      if (access === 'call' && expression.kind === 'call') {
        const data = owner.semanticData ??= {};
        const calls = (data.calls ??= []) as unknown[];
        calls.push({ callee: expression.callee, args: expression.args, line: expression.at.line });
        if (named === 'ExecuteFunc') {
          const first = expression.args[0];
          const literal = first?.kind === 'literal' && first.literalKind === 'string' ? first.value.match(/^"([A-Za-z_]\w*)"$/)?.[1] : undefined;
          if (literal) this.ref(owner, '__jass_execute_func__:' + literal, 'calls', target.at);
          else {
            this.ref(owner, encodeJassExpression(expression, 'call'), 'calls', target.at);
            this.error('Computed dispatch ExecuteFunc requires value-flow evidence.', target.at.line, 'warning');
          }
        } else if (named && /\.(execute|evaluate)$/.test(named)) this.error(`Potential indirect dispatch ${named} requires a named callable or value-flow evidence.`, target.at.line, 'warning');
      }
    };
    const visit = (expression: JassExpression, access: 'get' | 'set' = 'get'): void => {
      switch (expression.kind) {
        case 'call':
          if (expression.callee.kind === 'member') visit(expression.callee.object);
          else if (expression.callee.kind === 'index') { visit(expression.callee.object); visit(expression.callee.index); }
          for (const arg of expression.args) visit(arg);
          emit(expression, 'call'); break;
        case 'name': emit(expression, access); break;
        case 'member': visit(expression.object); emit(expression, access); break;
        case 'index': visit(expression.object); visit(expression.index); emit(expression, access); break;
        case 'function': emit(expression.value, 'function'); break;
        case 'group': case 'unary': visit(expression.value); break;
        case 'binary': visit(expression.left); visit(expression.right); if (['<', '>', '<=', '>='].includes(expression.operator)) emit(expression, 'get'); break;
        default: break;
      }
    };
    let offset = 0;
    const assignment = tokens[0]?.value === 'set';
    while (offset < tokens.length) {
      if (STATEMENTS.has(tokens[offset]!.value) || ['=', ',', ';'].includes(tokens[offset]!.value)) { offset++; continue; }
      const parsed = parseJassExpression(tokens, offset);
      if (!parsed.expression || parsed.consumed <= 0) break;
      if (parsed.errors.length) {
        this.error(parsed.errors.join(' '), tokens[offset]!.line, 'warning');
        offset += parsed.consumed; continue;
      }
      const lhs = assignment && tokens[offset + parsed.consumed]?.value === '=';
      if (tokens[0]?.value === 'return') (((owner.semanticData ??= {}).returns ??= []) as unknown[]).push(parsed.expression);
      visit(parsed.expression, lhs ? 'set' : 'get');
      if (lhs) {
        const rhs = parseJassExpression(tokens, offset + parsed.consumed + 1);
        if (rhs.expression && !rhs.errors.length) {
          const data = owner.semanticData ??= {};
          ((data.assignments ??= []) as unknown[]).push({ target: parsed.expression, value: rhs.expression, line: tokens[offset]!.line });
        }
      }
      offset += parsed.consumed;
    }
  }
}
