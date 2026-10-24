/** JassHelper's SYLK data subset. Cells are data, never executable tools.
 * Sparse coordinates stay sparse and limits avoid allocating hostile tables.
 */
export interface JassSlk { typeName: string; fields: Map<number, string>; rows: { key: string; values: { field: string; value: string }[] }[] }
export function parseJassSlk(source: string): JassSlk {
  if (!source.startsWith('ID')) throw new Error('SLK input must start with ID');
  const cells = new Map<number, Map<number, string>>();
  let x = 1, y = 1, count = 0;
  // The installed JassHelper tokenizes fields at semicolons. Embedded
  // semicolons/quoted physical newlines require a different compiler profile.
  for (const line of source.split(/\r?\n/)) {
    if (line === 'E') break;
    if (!line.startsWith('C;')) continue;
    let value: string | undefined;
    for (const part of line.split(';').slice(1)) {
      if (/^X\d+$/.test(part)) x = Number(part.slice(1));
      else if (/^Y\d+$/.test(part)) y = Number(part.slice(1));
      else if (part.startsWith('K')) {
        value = part.slice(1);
        if (value.startsWith('"')) {
          if (!value.endsWith('"') || value.length < 2) throw new Error('Unsupported split/unterminated SLK cell');
          value = value.slice(1, -1);
        }
        value = value.replace(/[\u0093\u0094\u201c\u201d]|\u001b\)[34]/g, '"');
      }
    }
    if (x < 1 || y < 1 || x > 4096 || y > 100000 || ++count > 100000) throw new Error('SLK coordinate/cell budget exceeded');
    if (value) { const row = cells.get(y) ?? new Map<number, string>(); row.set(x, value); cells.set(y, row); }
  }
  const header = cells.get(1), typeName = header?.get(1);
  if (!typeName || !/^[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*$/.test(typeName) || !header || header.size < 2) throw new Error('SLK requires a struct name and field headers');
  const fields = new Map([...header].filter(([column]) => column > 1));
  for (const name of fields.values()) if (!/^[A-Za-z_]\w*$/.test(name)) throw new Error('Invalid SLK field header');
  const rows = [...cells].filter(([row]) => row > 1).sort(([a], [b]) => a - b).map(([, row]) => ({ key: row.get(1) ?? '', values: [...fields].filter(([column]) => row.has(column) && !/^\s*[-_]\s*$/.test(row.get(column)!)).map(([column, field]) => ({ field, value: row.get(column)! })) }));
  return { typeName, fields, rows };
}

/** Match JassHelper's scalar conversions before parsing cell expressions. */
export function jassSlkExpression(value: string, type: string): string {
  if (type === 'boolean') return value === '0' ? 'false' : value === '1' ? 'true' : value;
  if (type === 'integer' && !/^\d+$/.test(value) && [1, 4].includes(value.length)) return "'" + value + "'";
  if (type === 'string') return (value.startsWith('"') ? '' : '"') + value + (value.endsWith('"') ? '' : '"');
  return value;
}
