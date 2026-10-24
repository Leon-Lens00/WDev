import type { ExtractionError } from '../types';
import { lexJass } from './jass-lexer';
import * as path from 'node:path';

export interface JassSourceLine { text: string; file: string; line: number; anchor: number; via?: string }
interface Definition { name: string; qualified: string; scope: string; file: string; line: number; private: boolean; args: string[]; body: JassSourceLine[] }
export interface JassCatalog { macros: Definition[]; modules: Definition[]; files: Set<string> }
const scopes = new Set(['library', 'library_once', 'scope', 'struct', 'module', 'interface']);

/** Only evaluate a positive fact proved by an unconditional public declaration
 * in this exact struct projection. Absence, inheritance, compound expressions,
 * debug flags and blocks with elseif remain unknown. This removes the common
 * `static if not thistype.member.exists` fallback without assuming global flags.
 */
function declaredExists(lines: JassSourceLine[]): JassSourceLine[] {
  const lexed = lexJass(lines.map(l => l.text).join('\n'));
  const owners = new Map<number, number>();
  const members = new Map<number, Set<string>>();
  const blocks: { kind: string; id: number }[] = [];
  const conditions: number[] = [];
  const elseif = new Set<number>();
  for (let i = 0; i < lines.length; i++) {
    const words = lexed.lines[i]!.map(t => t.value);
    const head = words.findIndex(w => !['private', 'public', 'static', 'readonly', 'constant', 'stub', 'debug'].includes(w));
    const keyword = words[head];
    if (keyword === 'if') conditions.push(i);
    if (keyword === 'elseif' && conditions.length) elseif.add(conditions.at(-1)!);
    if (keyword === 'endif') conditions.pop();
    const owner = [...blocks].reverse().find(b => b.kind === 'struct');
    if (owner) {
      owners.set(i, owner.id);
      if (!conditions.length && !words.includes('private') && !words.includes('debug') && blocks.at(-1)?.kind === 'struct') {
        const fieldAt = words[head + 1] === 'array' ? head + 2 : head + 1;
        const field = keyword && /^[A-Za-z_]\w*$/.test(keyword) && !['implement', 'delegate', 'hook', 'key', 'keyword', 'call', 'set', 'return', 'else', 'endif'].includes(keyword) && [undefined, '=', '['].includes(words[fieldAt + 1]);
        const name = keyword === 'method' ? words[head + 1] : field ? words[fieldAt] : undefined;
        if (name && /^[A-Za-z_]\w*$/.test(name) && name !== 'operator') members.get(owner.id)!.add(name);
      }
    }
    if (keyword && (scopes.has(keyword) || ['method', 'function'].includes(keyword))) {
      const kind = keyword === 'library_once' ? 'library' : keyword;
      blocks.push({ kind, id: i });
      if (kind === 'struct') members.set(i, new Set());
    } else if (keyword?.startsWith('end') && blocks.at(-1)?.kind === keyword.slice(3)) blocks.pop();
  }
  const stack: { enabled: boolean; known: boolean; selected: boolean }[] = [];
  return lines.map((line, i) => {
    const words = lexed.lines[i]!.map(t => t.value);
    const text = words.join(' ');
    const keyword = words[0] === 'static' ? words[1] : words[0];
    const enabled = stack.every(s => s.enabled);
    if (keyword === 'if') {
      const match = text.match(/^static if (not )?thistype \. ([A-Za-z_]\w*) \. exists then$/);
      const owner = owners.get(i);
      const known = !!match && owner !== undefined && !!members.get(owner)?.has(match[2]!) && !elseif.has(i);
      const selected = known ? !match![1] : true;
      stack.push({ enabled: known ? enabled && selected : enabled, known, selected });
      return !enabled || known ? { ...line, text: '' } : line;
    }
    if (keyword === 'else' || keyword === 'elseif') {
      const frame = stack.at(-1);
      if (frame?.known) { frame.enabled = stack.slice(0, -1).every(s => s.enabled) && !frame.selected; return { ...line, text: '' }; }
    }
    if (keyword === 'endif') {
      const frame = stack.pop();
      return frame?.known || !stack.every(s => s.enabled) ? { ...line, text: '' } : line;
    }
    return enabled ? line : { ...line, text: '' };
  });
}

/** Read only the sources supplied by the indexer's existing scope scanner.
 * No imports are opened here, no compiler is run, and no source is rewritten.
 */
export function buildJassCatalog(sources: ReadonlyMap<string, string>): JassCatalog {
  const catalog: JassCatalog = { macros: [], modules: [], files: new Set(sources.keys()) };
  for (const [file, source] of sources) {
    const raw = source.split(/\r?\n/);
    const lexed = lexJass(source);
    for (const directive of lexed.directives) {
      const match = directive.text.match(/^\/\/!\s*textmacro\s+(\w+)(?:\s+takes\s+(.+))?\s*$/);
      if (!match) continue;
      const end = lexed.directives.find(d => d.line > directive.line && d.kind === 'endtextmacro');
      if (!end) continue;
      catalog.macros.push({ name: match[1]!, qualified: match[1]!, scope: '', file, line: directive.line, private: false,
        args: match[2]?.split(',').map(s => s.trim()) ?? [],
        body: raw.slice(directive.line, end.line - 1).map((text, i) => ({ text, file, line: directive.line + i + 1, anchor: directive.line + i + 1 })) });
    }
    const stack: { kind: string; name: string; line: number; private: boolean }[] = [];
    for (const tokens of lexed.lines) {
      const words = tokens.map(t => t.value);
      const offset = words.findIndex(w => !['private', 'public', 'static', 'readonly', 'constant', 'stub'].includes(w));
      const kind = words[offset];
      if (!kind) continue;
      if (scopes.has(kind) && words[offset + 1]) stack.push({ kind: kind === 'library_once' ? 'library' : kind, name: words[offset + 1]!, line: tokens[0]!.line, private: words.includes('private') });
      else if (kind.startsWith('end') && stack.at(-1)?.kind === kind.slice(3)) {
        const block = stack.pop()!;
        if (block.kind !== 'module') continue;
        const scope = stack.map(s => s.name).join('.');
        catalog.modules.push({ name: block.name, qualified: scope ? scope + '.' + block.name : block.name, scope, file, line: block.line, private: block.private, args: [],
          body: raw.slice(block.line, tokens[0]!.line - 1).map((text, i) => ({ text, file, line: block.line + i + 1, anchor: block.line + i + 1 })) });
      }
    }
  }
  return catalog;
}

function argumentsOf(text: string): string[] | null {
  const args: string[] = [];
  let offset = 0;
  while (offset < text.length) {
    const match = text.slice(offset).match(/^\s*"((?:\\.|[^"\\])*)"\s*(,|$)/);
    if (!match) return text.trim() === '' ? [] : null;
    // JassHelper arguments are textual strings, not JavaScript escape sequences.
    if (match[1]!.includes('\\')) return null; // Escaped macro arguments require compiler-specific unescaping.
    args.push(match[1]!);
    offset += match[0].length;
    if (match[2] === ',' && !text.slice(offset).trim()) return null;
  }
  return args;
}

/** Finite, context-specific source projection. Generated nodes point at the
 * invocation in the REAL source; docstrings retain the definition location.
 * Limits/cycles/ambiguities are coverage diagnostics, never guessed targets.
 */
export function expandJass(file: string, source: string, catalog = buildJassCatalog(new Map([[file, source]]))) {
  const errors: ExtractionError[] = [];
  const imported: { path: string; line: number }[] = [];
  const warn = (at: JassSourceLine, message: string) => errors.push({ filePath: file, line: at.anchor, message, severity: 'warning', code: 'jass_partial_coverage' });
  let budget = 50000;
  let characters = 4 * 1024 * 1024;
  const project = (input: JassSourceLine[], scope: string[], chain: string[]): JassSourceLine[] => {
    const text = input.map(l => l.text).join('\n');
    const lexed = lexJass(text);
    const active = new Map(lexed.directives.map(d => [d.line, d]));
    const output: JassSourceLine[] = [];
    let inModule = 0;
    for (let i = 0; i < input.length; i++) {
      const line = input[i]!;
      characters -= line.text.length;
      if (--budget < 0 || characters < 0) { warn(line, 'JASS expansion line/byte budget exceeded; remaining projection omitted.'); break; }
      const directive = active.get(i + 1);
      const words = lexed.lines[i]!.map(t => t.value);
      const head = words.findIndex(w => !['private', 'public', 'static', 'readonly', 'constant', 'stub'].includes(w));
      const keyword = words[head];
      if (keyword === 'module') inModule++;
      if (keyword === 'endmodule') inModule--;
      const macro = directive?.text.match(/^\/\/!\s*runtextmacro\s+(optional\s+)?(\w+)\s*\((.*)\)\s*(?:\/\/.*)?$/);
      const implement = !inModule && keyword === 'implement' ? words.slice(head + 1).filter(w => w !== 'optional').join('') : null;
      if ((macro || implement) && !inModule) {
        const definitions = macro ? catalog.macros.filter(d => d.name === macro[2]) : (() => {
          const originModule = [...(line.via ?? '').matchAll(/module ([\w.]+) defined at/g)].at(-1)?.[1];
          const originScope = originModule?.includes('.') ? originModule.slice(0, originModule.lastIndexOf('.')) : '';
          if (originScope) { const found = catalog.modules.filter(d => d.qualified === originScope + '.' + implement); if (found.length) return found; }
          for (let n = scope.length; n >= 0; n--) {
            const qualified = [...scope.slice(0, n), implement!].join('.');
            const found = catalog.modules.filter(d => d.qualified === qualified);
            if (found.length) return found;
          }
          return catalog.modules.filter(d => d.name === implement && !d.private);
        })();
        const optional = macro ? !!macro[1] : words.includes('optional');
        const name = macro?.[2] ?? implement!;
        const args = macro ? argumentsOf(macro[3]!) : [];
        const def = definitions.length === 1 ? definitions[0] : undefined;
        const key = def && `${macro ? 'macro' : 'module'}:${def.file}:${def.line}`;
        if (!def || !args || args.length !== def.args.length || chain.length >= 24 || (key && chain.includes(key))) {
          if (!optional || definitions.length > 0) warn(line, `${name}: ${definitions.length > 1 ? 'ambiguous definition' : !def ? 'definition unavailable in indexed scope' : key && chain.includes(key) ? 'expansion cycle' : 'unsupported arguments or expansion depth'}; not expanded.`);
          output.push({ ...line, text: '// CodeGraph: unresolved expansion' });
          continue;
        }
        const substitutions = new Map(def.args.map((name, j) => [name, args[j]!]));
        const estimated = def.body.reduce((total, l) => total + l.text.length + [...l.text.matchAll(/\$([A-Za-z_]\w*)\$/g)].reduce((n, m) => n + (substitutions.get(m[1]!)?.length ?? 0), 0), 0);
        if (estimated > characters || def.body.length > budget) { warn(line, `${name}: expansion budget exceeded; not expanded.`); output.push({ ...line, text: '// CodeGraph: expansion budget exceeded' }); continue; }
        let body = def.body.map(l => ({ ...l, anchor: line.anchor, via: `${line.via ? line.via + ' -> ' : ''}${macro ? 'textmacro' : 'module'} ${def.qualified} defined at ${def.file}:${def.line}; invoked at ${file}:${line.anchor}`,
          text: l.text.replace(/\$([A-Za-z_]\w*)\$/g, (whole, name: string) => substitutions.get(name) ?? whole) }));
        if (!macro) {
          // Keep independent private module initializers distinct. Other
          // private-name collisions remain ambiguous instead of guessed.
          const lexedBody = lexJass(body.map(l => l.text).join('\n'));
          const privateNames = new Set<string>();
          for (const tokens of lexedBody.lines) {
            const words = tokens.map(t => t.value);
            if (words[0] !== 'private') continue;
            const at = words.indexOf('method');
            const name = at >= 0 ? words[at + 1] : words.filter(w => !['private', 'static', 'constant', 'readonly'].includes(w))[1];
            if (name === 'onInit') privateNames.add(name);
          }
          body = body.map((l, j) => {
            let text = l.text;
            for (const token of [...lexedBody.lines[j]!].reverse()) {
              if (!privateNames.has(token.value)) continue;
              const index = lexedBody.lines[j]!.indexOf(token);
              const tokens = lexedBody.lines[j]!;
              if (tokens[index - 1]?.value === '.' && !['this', 'thistype', undefined].includes(tokens[index - 2]?.value)) continue;
              const prefix = `__cg_${def.qualified.replace(/\W/g, '_')}_`;
              text = text.slice(0, token.column) + prefix + token.value + text.slice(token.column + token.value.length);
            }
            return { ...l, text };
          });
        }
        output.push(...project(body, [...scope], [...chain, key!]));
        continue;
      }
      const imp = directive?.text.match(/^\/\/!\s*import\s+(?:jass\s+)?"([^"]+)"\s*(?:\/\/.*)?$/);
      if (imp && line.via) { warn(line, 'Import inside a generated projection is not expanded; check JassHelper import ordering.'); } else if (imp) {
        const raw = imp[1]!.replace(/\\/g, '/');
        imported.push({ path: imp[1]!, line: line.anchor });
        const candidates = [...new Set([path.posix.normalize(path.posix.join(path.posix.dirname(file), raw)), path.posix.normalize(raw)])];
        if (path.posix.isAbsolute(raw) || /^[A-Za-z]:/.test(raw) || candidates.filter(p => !p.startsWith('../') && catalog.files.has(p)).length !== 1) warn(line, `Import ${imp[1]} unavailable or ambiguous within indexed scope; no external file was read.`);
      } else if (directive && ['runtextmacro', 'import'].includes(directive.kind) && !macro) warn(line, `Unsupported ${directive.kind} directive syntax; not expanded.`);
      output.push(line);
      if (keyword && scopes.has(keyword) && words[head + 1]) scope.push(words[head + 1]!);
      else if (keyword && ['endlibrary', 'endscope', 'endstruct', 'endmodule', 'endinterface'].includes(keyword)) scope.pop();
    }
    return output;
  };
  const lines = declaredExists(project(source.split(/\r?\n/).map((text, i) => ({ text, file, line: i + 1, anchor: i + 1 })), [], []));
  return { source: lines.map(l => l.text).join('\n'), lines, errors, imported };
}
