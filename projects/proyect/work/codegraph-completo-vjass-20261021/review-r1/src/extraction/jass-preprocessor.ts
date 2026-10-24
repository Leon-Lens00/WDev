import { normalizeJassComments } from './jass-comments';
import type { ExtractionError } from '../types';
import { lexJass } from './jass-lexer';
import * as path from 'node:path';
import { DEFAULT_JASS_PROFILE, JassProfile } from '../jass-profile';
import { parseJassSlk, JassSlk } from './jass-slk';
import { createHash } from 'node:crypto';
import { foldJassConditions } from './jass-conditions';

export interface JassSourceLine { text: string; file: string; line: number; anchor: number; via?: string; conditional?: boolean; endAnchor?: number; normalized?: boolean; offsets?: { from: number; to: number; line: number; column: number }[] }
interface Definition { name: string; qualified: string; scope: string; file: string; line: number; endLine: number; private: boolean; args: string[]; body: JassSourceLine[] }
export interface JassTemplateUse { kind: string; name: string; file: string; definitionLine: number; consumer: string; line: number }
export interface JassSlkLoad { path: string; sha256: string; data: JassSlk; consumer: string; line: number; originFile: string; originLine: number; via?: string; conditional?: boolean }
export interface JassProjection { slkLoads: JassSlkLoad[]; templateUses: JassTemplateUse[]; source: string; lines: JassSourceLine[]; errors: ExtractionError[]; imported: { path: string; line: number }[] }
export interface JassCatalog { macros: Definition[]; modules: Definition[]; files: Set<string>; profile: JassProfile; sources: ReadonlyMap<string, string>; normalizedSources: Map<string, JassSourceLine[]>; sourceErrors: Map<string, ExtractionError[]>; projections: Map<string, JassProjection>; dataInputs: ReadonlyMap<string, string>; dataErrors: ReadonlyMap<string, string>; injections: Map<string, { file: string; at: number; init?: number }[]> }
const scopes = new Set(['library', 'library_once', 'scope', 'struct', 'module', 'interface']);

/** Read only the sources supplied by the indexer's existing scope scanner.
 * No imports are opened here, no compiler is run, and no source is rewritten.
 */
export function buildJassCatalog(sources: ReadonlyMap<string, string>, profile: JassProfile = DEFAULT_JASS_PROFILE, dataInputs: ReadonlyMap<string, string> = new Map(), dataErrors: ReadonlyMap<string, string> = new Map()): JassCatalog {
  const catalog: JassCatalog = { macros: [], modules: [], files: new Set(sources.keys()), profile, sources, dataInputs, dataErrors, normalizedSources: new Map(), sourceErrors: new Map(), projections: new Map(), injections: new Map() };
  for (const [file, source] of sources) {
    const initial = normalizeJassComments(source.split(/\r?\n/).map((text, i) => ({ text, file, line: i + 1, anchor: i + 1 })));
    const normalized = initial.lines; catalog.sourceErrors.set(file, initial.errors);
    catalog.normalizedSources.set(file, normalized);
    const lexed = lexJass(normalized.map(l => l.text).join('\n'));
    for (const directive of lexed.directives) {
      const match = directive.text.match(/^\/\/!\s*textmacro(?:_once)?\s+(\w+)(?:\s+takes\s+(.+))?\s*$/);
      if (!match) continue;
      const end = lexed.directives.find(d => d.line > directive.line && d.kind === 'endtextmacro');
      if (!end) continue;
      if (directive.kind === 'textmacro_once' && catalog.macros.some(m => m.name === match[1] && m.file === file)) continue;
      catalog.macros.push({ name: match[1]!, qualified: match[1]!, scope: '', file, line: normalized[directive.line - 1]!.anchor, endLine: normalized[end.line - 1]!.anchor, private: false,
        args: match[2]?.split(',').map(s => s.trim()) ?? [],
        body: normalized.slice(directive.line, end.line - 1) });
    }
  }
  // JassHelper expands textmacros before collecting modules. This also
  // expands macro invocations inside module bodies, exactly once per catalog.
  for (const [file, source] of sources) {
    const projection = projectJass(file, source, catalog, false);
    const lexed = lexJass(projection.source);
    const stack: { kind: string; name: string; index: number; private: boolean }[] = [];
    for (let i = 0; i < lexed.lines.length; i++) {
      const words = lexed.lines[i]!.map(t => t.value);
      const offset = words.findIndex(w => !['private', 'public', 'static', 'readonly', 'constant', 'stub'].includes(w));
      const kind = words[offset];
      if (!kind) continue;
      if (scopes.has(kind) && words[offset + 1]) stack.push({ kind: kind === 'library_once' ? 'library' : kind, name: words[offset + 1]!, index: i, private: words.includes('private') });
      else if (kind.startsWith('end') && stack.at(-1)?.kind === kind.slice(3)) {
        const block = stack.pop()!;
        if (block.kind !== 'module') continue;
        const scope = stack.map(s => s.name).join('.');
        const origin = projection.lines[block.index]!;
        catalog.modules.push({ name: block.name, qualified: scope ? scope + '.' + block.name : block.name, scope, file, line: origin.anchor, endLine: projection.lines[i]!.anchor, private: block.private, args: [],
          body: projection.lines.slice(block.index + 1, i) });
      }
    }
  }
  for (const [file, source] of sources) catalog.projections.set(file, projectJass(file, source, catalog));
  for (const [file, projection] of catalog.projections) {
    let active: { file: string; at: number; init?: number } | undefined;
    for (const directive of lexJass(projection.source).directives) {
      if (directive.kind === 'inject') {
        const name = directive.text.match(/^\/\/!\s*inject\s+(main|config)\s*$/)?.[1];
        if (name) { active = { file, at: projection.lines[directive.line - 1]!.anchor }; const list = catalog.injections.get(name) ?? []; list.push(active); catalog.injections.set(name, list); }
      } else if (directive.kind === 'endinject') active = undefined;
      else if (directive.kind === 'dovjassinit' && active) active.init = projection.lines[directive.line - 1]!.anchor;
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
    // JassHelper removes the slash only for escaped quotes, preserving all
    // other escapes verbatim (including doubled backslashes).
    args.push(match[1]!.replace(/\\"/g, '"'));
    offset += match[0].length;
    if (match[2] === ',' && !text.slice(offset).trim()) return null;
  }
  return args;
}

/** Finite, context-specific source projection. Generated nodes point at the
 * invocation in the REAL source; docstrings retain the definition location.
 * Limits/cycles/ambiguities are coverage diagnostics, never guessed targets.
 */
export function projectJass(file: string, source: string, catalog: JassCatalog, expandModules = true): JassProjection {
  const errors: ExtractionError[] = [...(catalog.sourceErrors.get(file) ?? [])];
  const imported: { path: string; line: number }[] = [];
  const templateUses: JassTemplateUse[] = [];
  const slkLoads: JassSlkLoad[] = [];
  const warn = (at: JassSourceLine, message: string) => errors.push({ filePath: file, line: at.anchor, message, severity: 'warning', code: 'jass_partial_coverage' });
  let budget = 50000;
  let characters = 4 * 1024 * 1024;
  const implementations = new Map<string, Set<string>>();
  const libraries = new Set<string>();
  const project = (input: JassSourceLine[], scope: string[], chain: string[], initialInstance = ''): JassSourceLine[] => {
    let instance = initialInstance;
    const normalized = normalizeJassComments(input);
    input = normalized.lines;
    errors.push(...normalized.errors.map(e => ({ ...e, filePath: file })));
    const text = input.map(l => l.text).join('\n');
    const lexed = lexJass(text);
    const active = new Map(lexed.directives.map(d => [d.line, d]));
    const output: JassSourceLine[] = [];
    let inModule = 0, ignoredLibrary = 0;
    for (let i = 0; i < input.length; i++) {
      const line = input[i]!;
      characters -= line.text.length;
      if (--budget < 0 || characters < 0) { warn(line, 'JASS expansion line/byte budget exceeded; remaining projection omitted.'); break; }
      const directive = active.get(i + 1);
      const words = lexed.lines[i]!.map(t => t.value);
      const head = words.findIndex(w => !['private', 'public', 'static', 'readonly', 'constant', 'stub'].includes(w));
      const keyword = words[head];
      if (ignoredLibrary) {
        if (['library', 'library_once'].includes(keyword ?? '')) ignoredLibrary++;
        else if (keyword === 'endlibrary') ignoredLibrary--;
        output.push({ ...line, text: '' }); continue;
      }
      if (['library', 'library_once'].includes(keyword ?? '') && words[head + 1]) {
        const name = words[head + 1]!;
        if (keyword === 'library_once' && libraries.has(name)) { ignoredLibrary = 1; output.push({ ...line, text: '' }); continue; }
        libraries.add(name);
      }
      if (keyword === 'module') inModule++;
      if (keyword === 'endmodule') inModule--;
      const macro = directive?.text.match(/^\/\/!\s*runtextmacro\s+(optional\s+)?(\w+)\s*\((.*)\)\s*(?:\/\/.*)?$/);
      const implement = expandModules && !inModule && keyword === 'implement' ? words.slice(head + 1).filter(w => w !== 'optional').join('') : null;
      if (macro || implement) {
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
        const key = def && `${macro ? 'macro' : 'module'}:${def.file}:${def.line}:${def.qualified}`;
        if (!macro && key && implementations.get(instance)?.has(key)) continue;
        if (!def || !args || args.length !== def.args.length || chain.length >= 24 || (key && chain.includes(key))) {
          if (!optional || definitions.length > 0) warn(line, `${name}: ${definitions.length > 1 ? 'ambiguous definition' : !def ? 'definition unavailable in indexed scope' : key && chain.includes(key) ? 'expansion cycle' : 'unsupported arguments or expansion depth'}; not expanded.`);
          output.push({ ...line, text: '// CodeGraph: unresolved expansion' });
          continue;
        }
        templateUses.push({ kind: macro ? 'textmacro' : 'module', name: def.qualified, file: def.file, definitionLine: def.line, consumer: scope.join('.'), line: line.anchor });
        if (!macro && key) { const seen = implementations.get(instance) ?? new Set<string>(); seen.add(key); implementations.set(instance, seen); }
        const substitutions = new Map(def.args.map((name, j) => [name, args[j]!]));
        const estimated = def.body.reduce((total, l) => total + l.text.length + [...l.text.matchAll(/\$([A-Za-z_]\w*)\$/g)].reduce((n, m) => n + (substitutions.get(m[1]!)?.length ?? 0), 0), 0);
        if (estimated > characters || def.body.length > budget) { warn(line, `${name}: expansion budget exceeded; not expanded.`); output.push({ ...line, text: '// CodeGraph: expansion budget exceeded' }); continue; }
        let body = def.body.map(l => ({ ...l, anchor: line.anchor, endAnchor: line.endAnchor ?? line.anchor, via: `${l.via ? l.via + ' -> ' : ''}${line.via ? line.via + ' -> ' : ''}${macro ? 'textmacro' : 'module'} ${def.qualified} defined at ${def.file}:${def.line}; invoked at ${file}:${line.anchor}`,
          text: l.text.replace(/\$([A-Za-z_]\w*)\$/g, (whole, name: string) => substitutions.get(name) ?? whole) }));
        if (!macro) {
          // Each module has its own private namespace. JassHelper substitutes
          // identifier tokens throughout the module, except reserved lifecycle
          // methods create/destroy/onDestroy, which keep their compiler role.
          const lexedBody = lexJass(body.map(l => l.text).join('\n'));
          const privateNames = new Set<string>();
          for (const tokens of lexedBody.lines) {
            const words = tokens.map(t => t.value);
            if (words[0] !== 'private') continue;
            const at = words.indexOf('method');
            const name = at >= 0 ? words[at + 1] : words.filter(w => !['private', 'static', 'constant', 'readonly', 'delegate'].includes(w))[1];
            if (name && !['create', 'destroy', 'onDestroy'].includes(name)) privateNames.add(name === 'array' ? words[words.indexOf('array') + 1]! : name);
          }
          body = body.map((l, j) => {
            let text = l.text;
            for (const token of [...lexedBody.lines[j]!].reverse()) {
              if (!privateNames.has(token.value)) continue;
              const prefix = `__cg_${def.qualified.replace(/\W/g, '_')}_`;
              text = text.slice(0, token.column) + prefix + token.value + text.slice(token.column + token.value.length);
            }
            return { ...l, text };
          });
        }
        output.push(...project(body, [...scope], [...chain, key!], instance));
        continue;
      }
      if (directive?.kind === 'loaddata') {
        const requested = directive.text.match(/^\/\/!\s*loaddata\s+"([^"]+)"\s*(?:\/\/.*)?$/)?.[1];
        if (!requested) warn(line, 'Unsupported loaddata path syntax.');
        else {
          const raw = requested.replace(/\\/g, '/');
          const paths = [...new Set([path.posix.join(path.posix.dirname(file), raw), raw, ...catalog.profile.lookupPaths.map(dir => path.posix.join(dir, raw))].map(p => path.posix.normalize(p)))];
          const available = paths.filter(p => catalog.dataInputs.has(p));
          if (path.posix.isAbsolute(raw) || /^[A-Za-z]:/.test(raw) || available.length !== 1) warn(line, `SLK ${requested} unavailable or ambiguous; list in-scope inputs in jass.dataFiles. ${paths.map(p => catalog.dataErrors.get(p)).filter(Boolean).join('; ')}`);
          else try {
            const dataPath = available[0]!, text = catalog.dataInputs.get(dataPath)!;
            slkLoads.push({ path: dataPath, sha256: createHash('sha256').update(text).digest('hex'), data: parseJassSlk(text), consumer: scope.join('.'), line: line.anchor, originFile: line.file, originLine: line.line, via: line.via });
          } catch (error) { warn(line, `SLK ${requested}: ${error instanceof Error ? error.message : String(error)}; no generated targets assumed.`); }
        }
      }
      const imp = directive?.text.match(/^\/\/!\s*import\s+(?:(vjass|jass|zinc|comment)\s+)?"([^"]+)"\s*(?:\/\/.*)?$/);
      if (imp && imp[1] === 'comment') { /* JassHelper explicitly ignores these. */ }
      else if (imp && line.via) { warn(line, 'Import inside a generated projection is not expanded; imports precede textmacros in JassHelper.'); }
      else if (imp && imp[1] === 'zinc') { warn(line, 'Zinc import requires a Zinc frontend; no JASS target is fabricated.'); }
      else if (imp) {
        const raw = imp[2]!.replace(/\\/g, '/');
        const candidates = [...new Set([path.posix.join(path.posix.dirname(file), raw), raw, ...catalog.profile.lookupPaths.map(dir => path.posix.join(dir, raw))].map(p => path.posix.normalize(p)))];
        const available = candidates.filter(p => p !== '..' && !p.startsWith('../') && catalog.files.has(p));
        if (path.posix.isAbsolute(raw) || /^[A-Za-z]:/.test(raw) || available.length !== 1) warn(line, `Import ${imp[2]} unavailable or ambiguous within indexed scope; no external file was read.`);
        else imported.push({ path: available[0]!, line: line.anchor });
      } else if (directive && ['runtextmacro', 'import'].includes(directive.kind) && !macro) warn(line, `Unsupported ${directive.kind} directive syntax; not expanded.`);
      output.push(line);
      if (keyword === 'struct') instance = `${file}:${line.anchor}:${line.line}:${scope.join('.')}`;
      if (keyword === 'endstruct') instance = '';
      if (keyword && scopes.has(keyword) && words[head + 1]) scope.push(words[head + 1]!);
      else if (keyword && ['endlibrary', 'endscope', 'endstruct', 'endmodule', 'endinterface'].includes(keyword)) scope.pop();
    }
    return output;
  };
  const lines = project(catalog.normalizedSources.get(file) ?? source.split(/\r?\n/).map((text, i) => ({ text, file, line: i + 1, anchor: i + 1 })), [], []);
  return { source: lines.map(l => l.text).join('\n'), lines, errors, imported, templateUses, slkLoads };
}

export function expandJass(file: string, source: string, catalog = buildJassCatalog(new Map([[file, source]]))): JassProjection {
  const projection = catalog.projections.get(file) ?? projectJass(file, source, catalog);
  const folded = foldJassConditions(file, projection.lines, catalog);
  const slkLoads = projection.slkLoads.flatMap(load => {
    const active = folded.lines.find(l => l.file === load.originFile && l.line === load.originLine && l.anchor === load.line && l.via === load.via && /^\s*\/\/!\s*loaddata\b/.test(l.text));
    return active ? [{ ...load, conditional: active.conditional }] : [];
  });
  return { ...projection, slkLoads, source: folded.lines.map(l => l.text).join('\n'), lines: folded.lines, errors: [...projection.errors, ...folded.errors] };
}
