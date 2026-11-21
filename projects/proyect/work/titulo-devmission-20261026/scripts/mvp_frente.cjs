// v20i: copia de un modelo de héroe que mira siempre de frente a la cámara, como los retratos de las tarjetas de racha
// (RetratoTauren.mdx: cadena PortraitBillboard). Se cuelga todo el modelo de un hueso nuevo "MvpFrente" con Billboarded en
// el origen (los pies): el motor gira ese hueso para que su X (el frente del modelo) apunte a la cámara y su Z quede hacia
// arriba en pantalla, sea cual sea el ángulo de la cámara y el giro de la unidad. Capas sin sombreado ni niebla, como el
// retrato (no dependen de la luz de la noche).
// ObjectId por orden de bloques: el hueso nuevo es el 0 y el resto sube 1 (padres, matrixIndices y PivotPoints igual).
// Comprobación: sin cámara (mdx-m3-viewer no aplica billboard) la pose debe ser igual que la del original.
// v20k: con GRADOS, un ayudante "MvpVista" hijo de MvpFrente con un giro fijo hacia atrás (cabeza alejándose de la
// cámara) en una secuencia global de dos claves, como PortraitView del retrato y retrato_sin_billboard.cjs (probados en
// el juego); las raíces cuelgan de él y las pistas del modelo no se tocan. (v20j inclinaba las pistas de las raíces y
// esas copias no se vieron en el juego.)
// Uso: node mvp_frente.cjs ENTRADA.mdx SALIDA.mdx [GRADOS]
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal, gr] = process.argv.slice(2);
const th = gr ? Number(gr) * Math.PI / 180 : 0;
const m = M.read(ent);
const kinds = ['bones','lights','helpers','attachments','particleEmitters','particleEmitters2','ribbonEmitters','eventObjects','cameras','collisionShapes'];
const nodos = kinds.flatMap(k => (m[k] || []).filter(n => 'objectId' in n));
M.assert(nodos.length === m.pivotPoints.length, 'nodos ' + nodos.length + ' pivotes ' + m.pivotPoints.length);
nodos.forEach((n, i) => M.assert(n.objectId === i, 'ObjectId fuera de orden: ' + n.name));
let heredan = 0, raices = 0;
for (const n of nodos) { if (n.flags & 7) { n.flags &= ~7; heredan++; } if (n.parentId === -1) raices++; }
// Nodos nuevos: MvpFrente (hueso 0, billboard) y, con grados, MvpVista (primer ayudante, hijo de MvpFrente).
const t = new M.Model();
const q = [0, Math.sin(-th / 2), 0, Math.cos(-th / 2)].join(',');
t.loadMdl('Version {FormatVersion 800,} Model "F" {}Bone "MvpFrente" {ObjectId 0,Billboarded,GeosetId Multiple,GeosetAnimId None,}' +
  (th ? `Helper "MvpVista" {ObjectId 1,Parent 0,Rotation 2 {DontInterp,0: {${q}},1000: {${q}},}}` : '') +
  `PivotPoints ${th ? 2 : 1} {{0,0,0},${th ? '{0,0,0},' : ''}}`);
const raiz = th ? 'vista' : 0;
const viejo = new Map(nodos.map(n => [n, n.objectId]));
if (th) { m.globalSequences.push(1000); t.helpers[0].animations[0].globalSequenceId = m.globalSequences.length - 1; m.helpers = [t.helpers[0], ...m.helpers]; }
m.bones = [t.bones[0], ...m.bones];
const piv = m.pivotPoints;
const orden = kinds.flatMap(k => (m[k] || []).filter(n => 'objectId' in n));
const id = new Map();
orden.forEach((n, i) => id.set(viejo.has(n) ? viejo.get(n) : (n === t.bones[0] ? 'frente' : 'vista'), i));
m.pivotPoints = orden.map(n => viejo.has(n) ? piv[viejo.get(n)] : new Float32Array(3));
for (const n of orden) {
  if (viejo.has(n)) { n.parentId = n.parentId === -1 ? id.get(raiz === 0 ? 'frente' : 'vista') : id.get(n.parentId); n.objectId = id.get(viejo.get(n)); }
}
t.bones[0].objectId = id.get('frente'); t.bones[0].parentId = -1;
if (th) { t.helpers[0].objectId = id.get('vista'); t.helpers[0].parentId = id.get('frente'); }
for (const g of m.geosets) g.matrixIndices = new Uint32Array(Array.from(g.matrixIndices, v => id.get(v)));
orden.forEach((n, i) => M.assert(n.objectId === i, 'orden de ids'));
let capas = 0;
for (const mat of m.materials) for (const l of mat.layers) { l.flags |= 1 | 32; capas++; }
// Comprobación de la pose (sin billboard) en el principio, el centro y el final de cada secuencia.
M.save(m, sal);
const r = M.read(sal);
M.assert(r.bones[0].name === 'MvpFrente' && (r.bones[0].flags & 8) && r.bones[0].objectId === 0, 'hueso MvpFrente');
// Comprobación de la pose en el principio, el centro y el final de cada secuencia, original contra copia releída.
// pose() no admite billboard ni "no heredar": se quitan esas banderas (1|2|4 y 8..128) en los dos lados para medir.
const o = M.read(ent);
// Los emisores y eventos no mueven vértices y pueden colgar de anclajes, que pose() no sigue: fuera para medir.
const llano = x => { for (const k of kinds) for (const nd of (x[k] || [])) if ('flags' in nd) nd.flags &= ~(1|2|4|8|16|32|64|128);
  x.particleEmitters2 = []; x.eventObjects = []; };
// Con MvpVista la copia es el original girado: se compara con R · original.
const cR = Math.cos(-th), sR = Math.sin(-th), R = v => [v[0] * cR + v[2] * sR, v[1], -v[0] * sR + v[2] * cR];
llano(o); llano(r);
let peor = 0, n = 0;
for (let si = 0; si < r.sequences.length; si++) {
  const [i0, i1] = r.sequences[si].interval;
  for (const f of [i0, Math.round((i0 + i1) / 2), i1]) {
    const a = M.pose(o, si, f).points, b = M.pose(r, si, f).points;
    a.forEach((g, gi) => g.forEach((v, vi) => { const w = b[gi][vi]; v = R(v); peor = Math.max(peor, Math.hypot(v[0]-w[0], v[1]-w[1], v[2]-w[2])); n++; }));
  }
}
M.assert(peor < 0.001, 'desviación ' + peor);
console.log(`${sal}: ${nodos.length}+${th ? 2 : 1} nodos${th ? ', vista ' + gr + '°' : ''}, ${raices} raíces colgadas de MvpFrente, ${heredan} sin "no heredar", ${capas} capas sin sombra ni niebla, ${n} vértices iguales (máx. ${peor.toExponential(1)})`);
