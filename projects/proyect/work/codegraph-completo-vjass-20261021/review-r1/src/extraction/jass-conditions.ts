import type { ExtractionError } from '../types';
import type { JassCatalog, JassSourceLine } from './jass-preprocessor';
import { lexJass } from './jass-lexer';

type Truth = boolean | undefined;
interface Fact { value: Truth; scope: string; private: boolean; file?: string }
interface Scope { kind: string; name: string; qualified: string; methods: Map<string, Fact>; uncertain: boolean }
interface Branch { static: boolean; active: Truth; taken: Truth }
const MODIFIERS = new Set(['private', 'public', 'static', 'constant', 'stub', 'readonly', 'debug']);
const CONTAINERS = new Set(['library', 'library_once', 'scope', 'struct', 'interface', 'module', 'function', 'method']);
const and = (a: Truth, b: Truth): Truth => a === false || b === false ? false : a === true && b === true ? true : undefined;
const or = (a: Truth, b: Truth): Truth => a === true || b === true ? true : a === false && b === false ? false : undefined;
const not = (a: Truth): Truth => a === undefined ? undefined : !a;
const GLOBAL_CACHE = new WeakMap<JassCatalog, { flags: Map<string, Fact>; libraries: Map<string, Set<string>>; types: Map<string, Set<string>> }>();

/** Compiler-profile condition selection. JassHelper's static-if language is
 * an ordered conjunction of optional `not` and names, not general JASS boolean
 * expression evaluation. Global booleans are pooled first; method existence
 * is registered in source order. Unknown build inputs retain potential paths.
 */
export function foldJassConditions(file: string, lines: JassSourceLine[], catalog: JassCatalog): { lines: JassSourceLine[]; errors: ExtractionError[] } {
  const errors: ExtractionError[] = [];
  const cached = GLOBAL_CACHE.get(catalog);
  const flags = cached ? new Map(cached.flags) : new Map<string, Fact>();
  const libraries = cached ? new Map(cached.libraries) : new Map<string, Set<string>>();
  const declaredTypes = cached ? new Map(cached.types) : new Map<string, Set<string>>();
  const closures = new Map<string, Set<string>>();
  const includedFor = (input: string) => {
    const cached = closures.get(input); if (cached) return cached;
    const included = new Set<string>(), pending = [input];
    while (pending.length) { const next = pending.pop()!; if (included.has(next)) continue; included.add(next); for (const imported of catalog.projections.get(next)?.imported ?? []) pending.push(imported.path); }
    closures.set(input, included); return included;
  };
  const available = (files: Set<string> | undefined, input: string) => !!files && (catalog.profile.completeInputs || [...files].some(file => includedFor(input).has(file)));
  const addSource = (map: Map<string, Set<string>>, name: string, input: string) => { const list = map.get(name) ?? new Set<string>(); list.add(input); map.set(name, list); };
  const typeFacts = new Map<string, Scope>();
  const stack: Scope[] = [];
  const branches: Branch[] = [];
  const namespace = () => stack.filter(s => ['library', 'scope', 'struct', 'interface', 'module'].includes(s.kind)).map(s => s.name).join('.');
  const active = () => branches.reduce<Truth>((value, branch) => and(value, branch.active), true);
  const scopeNames = (scope: string) => {
    const names: string[] = [];
    for (let current = scope; current; current = current.includes('.') ? current.slice(0, current.lastIndexOf('.')) : '') names.push(current);
    return [...names, ''];
  };
  const lookupFlag = (name: string, scope: string, input = file): Truth => {
    if (name === 'DEBUG_MODE') return catalog.profile.mode === 'conservative' ? undefined : catalog.profile.mode === 'debug';
    if (name.startsWith('LIBRARY_')) return available(libraries.get(name.slice(8)), input) ? true : catalog.profile.completeInputs ? false : undefined;
    for (const parent of scopeNames(scope)) {
      const qualified = parent ? parent + '.' + name : name;
      const flag = flags.get(qualified);
      if (flag?.file && !catalog.profile.completeInputs && !includedFor(input).has(flag.file)) return undefined;
      if (flag) return flag.private && !(scope === flag.scope || scope.startsWith(flag.scope + '.')) ? false : flag.value;
    }
    const external = catalog.profile.defines[name];
    return typeof external === 'boolean' ? external : catalog.profile.completeInputs ? false : undefined;
  };
  // Pool global declarations before body conditions, as the compiler does.
  // Replace this file's raw body with its actual macro/module projection.
  const sources = catalog.projections.size ? [...catalog.projections].map(([name, projection]) => [name, projection.source] as const) : [...catalog.sources];
  if (!cached) for (const [sourceFile, text] of sources) {
    const scopes: { kind: string; name: string }[] = [];
    let globals = false, conditional = 0, inModule = false;
    for (const tokens of lexJass(text).semanticLines) {
      const words = tokens.map(t => t.value), p = words.findIndex(w => !MODIFIERS.has(w));
      const word = words[p];
      if (!word) continue;
      if (word === 'module') { inModule = true; continue; }
      if (inModule) { if (word === 'endmodule') inModule = false; continue; }
      if (word === 'if' && words.includes('static')) conditional++;
      if (word === 'endif' && conditional) conditional--;
      if (word === 'globals') { globals = true; continue; }
      if (word === 'endglobals') { globals = false; continue; }
      const scope = scopes.filter(s => ['library', 'scope'].includes(s.kind)).map(s => s.name).join('.');
      if (globals && word === 'boolean' && words[p + 1]) {
        const name = words[p + 1]!, at = words.indexOf('='), rhs = words.slice(at + 1);
        const value = conditional ? undefined : !words.includes('constant') ? false : at < 0 ? undefined : rhs.length === 1 ? rhs[0] === 'true' ? true : rhs[0] === 'false' ? false : lookupFlag(rhs[0]!, scope, sourceFile) : false;
        const qualified = scope ? scope + '.' + name : name;
        const fact = { value, scope, private: words.includes('private'), file: sourceFile };
        if (flags.has(qualified)) flags.set(qualified, { ...fact, value: undefined }); else flags.set(qualified, fact);
        if (scope && !words.includes('public') && !words.includes('private')) {
          if (flags.has(name)) flags.set(name, { ...fact, value: undefined }); else flags.set(name, { ...fact, scope: '', private: false });
        }
        if (words.includes('public') && scope) flags.set(scope.replace(/\./g, '_') + '_' + name, { ...fact, private: false });
      }
      if (['library', 'library_once'].includes(word) && words[p + 1]) addSource(libraries, words[p + 1]!, sourceFile);
      if (['struct', 'interface'].includes(word) && words[p + 1]) {
        const name = words[p + 1]!; addSource(declaredTypes, scope ? scope + '.' + name : name, sourceFile);
        if (!words.includes('private')) addSource(declaredTypes, words.includes('public') && scope ? scope.replace(/\./g, '_') + '_' + name : name, sourceFile);
      }
      if (CONTAINERS.has(word) && words[p + 1] && !(word === 'method' && scopes.at(-1)?.kind === 'interface') && !(word === 'function' && words[p + 1] === 'interface')) scopes.push({ kind: word === 'library_once' ? 'library' : word, name: words[p + 1]! });
      else if (word.startsWith('end') && scopes.at(-1)?.kind === word.slice(3)) scopes.pop();
    }
  }
  if (!cached) GLOBAL_CACHE.set(catalog, { flags: new Map(flags), libraries: new Map(libraries), types: new Map(declaredTypes) });
  const lexed = lexJass(lines.map(l => l.text).join('\n'));
  const resolve = (name: string): Truth => {
    const scope = namespace();
    const own = [...stack].reverse().find(s => s.kind === 'struct');
    const exists = name.match(/^(.+)\.([A-Za-z_]\w*)\.exists$/);
    if (exists) {
      let type: Scope | undefined;
      if (exists[1] === 'thistype') { if (!own) return undefined; type = own; }
      else for (const prefix of scopeNames(scope)) {
        const found = typeFacts.get(prefix ? prefix + '.' + exists[1] : exists[1]!);
        if (found) { type = found; break; }
      }
      if (!type) {
        const external = scopeNames(scope).some(prefix => [...(declaredTypes.get(prefix ? prefix + '.' + exists[1] : exists[1]!) ?? [])].some(input => input !== file));
        return external ? undefined : catalog.profile.completeInputs ? false : undefined;
      }
      const fact = type.methods.get(exists[2]!);
      if (fact) return fact.private && type !== own ? false : fact.value;
      return type.uncertain ? undefined : false;
    }
    const normalized = name.startsWith('thistype.') && own ? own.qualified + name.slice(8) : name;
    return lookupFlag(normalized, scope);
  };
  const condition = (words: string[], at: JassSourceLine): Truth => {
    const parts = words.filter(w => w !== '(' && w !== ')');
    if (words.filter(w => w === '(').length > 1 || words.filter(w => w === ')').length > 1) {
      errors.push({ filePath: file, line: at.anchor, severity: 'error', code: 'jass_parse_error', message: 'JassHelper static-if accepts at most one parenthesis pair.' }); return undefined;
    }
    if (parts.at(-1) === 'then') parts.pop();
    let result: Truth = true, offset = 0;
    while (offset < parts.length) {
      const negate = parts[offset] === 'not';
      if (negate) offset++;
      let name = parts[offset++] ?? '';
      while (parts[offset] === '.' && parts[offset + 1]) { name += '.' + parts[offset + 1]; offset += 2; }
      if (!/^[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*$/.test(name)) { errors.push({ filePath: file, line: at.anchor, severity: 'error', code: 'jass_parse_error', message: 'Invalid JassHelper static-if requirement.' }); return undefined; }
      const value = name === 'true' ? true : name === 'false' ? false : resolve(name);
      result = and(result, negate ? not(value) : value);
      if (offset < parts.length && parts[offset++] !== 'and') { errors.push({ filePath: file, line: at.anchor, severity: 'error', code: 'jass_parse_error', message: 'JassHelper static-if supports conjunction with and; other operators are invalid.' }); return undefined; }
    }
    return offset ? result : undefined;
  };
  const output: JassSourceLine[] = [];
  let inModule = false;
  for (let i = 0; i < lines.length; i++) {
    let line = lines[i]!;
    const tokens = lexed.semanticLines[i]!, words = tokens.map(t => t.value);
    let p = words.findIndex(w => !MODIFIERS.has(w)), word = words[p];
    if (word === 'module') { inModule = true; output.push(line); continue; }
    if (inModule) { if (word === 'endmodule') inModule = false; output.push(line); continue; }
    const state = active();
    const own = [...stack].reverse().find(s => s.kind === 'struct');
    if (/CodeGraph: (?:unresolved expansion|expansion budget)/.test(line.text) && own && state !== false) own.uncertain = true;
    if (words.includes('debug') && catalog.profile.mode === 'release') { output.push({ ...line, text: '' }); continue; }
    if (words.includes('debug') && catalog.profile.mode === 'debug') {
      const debug = tokens.find(t => t.value === 'debug')!;
      line = { ...line, text: line.text.slice(0, debug.column) + ' '.repeat(5) + line.text.slice(debug.column + 5) };
    }
    if (word === 'if') {
      const isStatic = words.includes('static');
      const selected = isStatic ? condition(words.slice(p + 1), line) : true;
      branches.push({ static: isStatic, active: selected, taken: selected });
      output.push(state === false || (isStatic && selected !== undefined) ? { ...line, text: '' } : { ...line, conditional: state === undefined || selected === undefined }); continue;
    }
    if (word === 'elseif' || word === 'else') {
      const frame = branches.at(-1);
      if (frame?.static) {
        const selected = word === 'else' ? true : condition(words.slice(p + 1), line);
        frame.active = and(not(frame.taken), selected);
        frame.taken = or(frame.taken, selected);
        output.push(frame.active === undefined ? { ...line, conditional: true } : { ...line, text: '' }); continue;
      }
    }
    if (word === 'endif') {
      const frame = branches.pop();
      output.push(frame?.static && frame.active !== undefined ? { ...line, text: '' } : line); continue;
    }
    if (word === 'method' && own && stack.at(-1)?.kind === 'struct' && !words.includes('stub') && words[p + 1]) {
      const value = state === false ? false : state === undefined || (words.includes('debug') && catalog.profile.mode === 'conservative') ? undefined : true;
      if (state !== false) own.methods.set(words[p + 1]!, { value, scope: own.qualified, private: words.includes('private') });
    }
    if (word === 'boolean' && own && words.includes('static') && words.includes('constant') && words[p + 1]) {
      const rhs = words.slice(words.indexOf('=') + 1), value = state !== true ? undefined : rhs.length === 1 ? rhs[0] === 'true' ? true : rhs[0] === 'false' ? false : resolve(rhs[0]!) : false;
      flags.set(own.qualified + '.' + words[p + 1], { value, scope: own.qualified, private: words.includes('private') });
    }
    if (word && CONTAINERS.has(word) && words[p + 1] && !(word === 'method' && stack.at(-1)?.kind === 'interface') && !(word === 'function' && words[p + 1] === 'interface')) {
      const name = words[p + 1]!, scope = namespace(), kind = word === 'library_once' ? 'library' : word;
      const frame: Scope = { kind, name, qualified: scope ? scope + '.' + name : name, methods: new Map(), uncertain: state === undefined };
      stack.push(frame);
      if (kind === 'struct' && state !== false) typeFacts.set(frame.qualified, frame);
    } else if (word?.startsWith('end') && stack.at(-1)?.kind === word.slice(3)) stack.pop();
    output.push(state === false ? { ...line, text: '' } : { ...line, conditional: state === undefined || (words.includes('debug') && catalog.profile.mode === 'conservative') });
  }
  return { lines: output, errors };
}
