export interface JassProfile {
  mode: 'conservative' | 'release' | 'debug';
  /** Only explicitly complete translation units may infer absence. */
  completeInputs: boolean;
  /** Build-supplied constants missing from the indexed source inputs. */
  defines: Record<string, boolean | number | string>;
  /** In-scope relative import search directories; never authorizes external IO. */
  lookupPaths: string[];
  /** Indexed common.j/Blizzard.j inputs, processed externally by JassHelper. */
  apiFiles: string[];
  /** Explicit, in-scope SYLK build inputs. Never discovered outside the root. */
  dataFiles: string[];
}
export const DEFAULT_JASS_PROFILE: JassProfile = Object.freeze({ mode: 'conservative', completeInputs: false, defines: Object.freeze({}), lookupPaths: Object.freeze([]) as unknown as string[], apiFiles: Object.freeze([]) as unknown as string[], dataFiles: Object.freeze([]) as unknown as string[] });

export function parseJassProfile(value: unknown, warn: (message: string) => void): JassProfile | undefined {
  if (value === undefined) return undefined;
  if (!value || typeof value !== 'object' || Array.isArray(value)) { warn('jass must be an object'); return undefined; }
  const raw = value as Record<string, unknown>;
  let mode: JassProfile['mode'] = 'conservative';
  if (raw.mode !== undefined) {
    if (['conservative', 'release', 'debug'].includes(String(raw.mode))) mode = raw.mode as JassProfile['mode'];
    else warn('jass.mode must be conservative, release or debug');
  }
  const defines: JassProfile['defines'] = {};
  if (raw.defines && typeof raw.defines === 'object' && !Array.isArray(raw.defines)) {
    for (const [name, constant] of Object.entries(raw.defines)) {
      if (/^[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*$/.test(name) && (['boolean', 'string'].includes(typeof constant) || (typeof constant === 'number' && Number.isFinite(constant)))) defines[name] = constant as boolean | number | string;
      else warn(`invalid jass.defines entry ${name}`);
    }
  } else if (raw.defines !== undefined) warn('jass.defines must be an object');
  const lookupPaths: string[] = [];
  if (Array.isArray(raw.lookupPaths)) for (const entry of raw.lookupPaths) {
    if (typeof entry === 'string' && !/^(?:[A-Za-z]:|\/|\\)/.test(entry) && !entry.replace(/\\/g, '/').split('/').includes('..')) lookupPaths.push(entry.replace(/\\/g, '/'));
    else warn('jass.lookupPaths entries must stay within the indexed root');
  }
  const apiFiles: string[] = [];
  if (Array.isArray(raw.apiFiles)) for (const entry of raw.apiFiles) {
    if (typeof entry === 'string' && !/^(?:[A-Za-z]:|\/|\\)/.test(entry) && !entry.replace(/\\/g, '/').split('/').includes('..')) apiFiles.push(entry.replace(/\\/g, '/').replace(/^\.\//, ''));
    else warn('jass.apiFiles entries must stay within the indexed root');
  }
  const dataFiles: string[] = [];
  if (Array.isArray(raw.dataFiles)) for (const entry of raw.dataFiles) {
    if (typeof entry === 'string' && entry.length && !/^(?:[A-Za-z]:|\/|\\)/.test(entry) && !entry.replace(/\\/g, '/').split('/').includes('..')) dataFiles.push(entry.replace(/\\/g, '/').replace(/^\.\//, ''));
    else warn('jass.dataFiles entries must stay within the indexed root');
  } else if (raw.dataFiles !== undefined) warn('jass.dataFiles must be an array');
  return { mode, completeInputs: raw.completeInputs === true, defines: Object.fromEntries(Object.entries(defines).sort(([a], [b]) => a.localeCompare(b))), lookupPaths, apiFiles, dataFiles };
}
