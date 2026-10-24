import { lexJass } from './jass-lexer';
import type { JassSourceLine } from './jass-preprocessor';
import type { ExtractionError } from '../types';

/** JassHelper's import phase removes block comments, including their physical
 * newlines. Preserve original statement spans while composing its logical
 * input; displayed code is still read from the real file by CodeGraph. */
export function normalizeJassComments(input: JassSourceLine[]): { lines: JassSourceLine[]; errors: ExtractionError[] } {
  const source = input.map(l => l.text).join('\n');
  if (!source.includes('/*')) return { lines: input, errors: [] };
  const lexed = lexJass(source);
  if (!lexed.comments.length) return { lines: input, errors: [] };
  const clean = source.split('');
  for (const comment of lexed.comments) for (let i = comment.start; i < comment.end; i++) if (clean[i] !== '\n' && clean[i] !== '\r') clean[i] = '';
  const text = clean.join('').split('\n');
  const positions: NonNullable<JassSourceLine['offsets']>[] = [];
  let physicalOffset = 0;
  for (const line of input) {
    const segments: NonNullable<JassSourceLine['offsets']> = [];
    let run: number | undefined, column = 0;
    for (let i = 0; i <= line.text.length; i++) {
      const kept = i < line.text.length && clean[physicalOffset + i] !== '';
      if (kept && run === undefined) run = i;
      else if (!kept && run !== undefined) {
        segments.push({ from: column, to: column + i - run, line: line.anchor, column: run });
        column += i - run; run = undefined;
      }
    }
    positions.push(segments); physicalOffset += line.text.length + 1;
  }
  const roots = input.map((_, i) => i);
  for (const comment of lexed.comments) for (let i = comment.firstLine; i < comment.lastLine; i++) roots[i] = roots[comment.firstLine - 1]!;
  const groups = new Map<number, number[]>();
  for (let i = 0; i < roots.length; i++) { const group = groups.get(roots[i]!) ?? []; group.push(i); groups.set(roots[i]!, group); }
  const lines = input.map((line, i) => ({ ...line, text: text[i] ?? '' }));
  for (const [root, members] of groups) {
    if (members.length === 1 && lines[root]!.text === input[root]!.text) continue;
    const firstCode = members.find(i => (text[i] ?? '').trim().length > 0) ?? root;
    const end = input[members.at(-1)!]!;
    let shift = 0;
    const offsets = members.flatMap(i => { const segments = positions[i]!.map(s => ({ ...s, from: s.from + shift, to: s.to + shift })); shift += (text[i] ?? '').length; return segments; });
    lines[root] = { ...input[firstCode]!, text: members.map(i => text[i] ?? '').join(''), endAnchor: end.endAnchor ?? end.anchor, normalized: true, offsets };
    for (const index of members.slice(1)) lines[index] = { ...input[index]!, text: '' };
  }
  const errors = lexed.errors.filter(e => /^Unclosed block comment/.test(e.message)).map(e => ({ ...e, filePath: input[0]?.file, line: input[(e.line ?? 1) - 1]?.anchor ?? e.line }));
  return { lines, errors };
}
