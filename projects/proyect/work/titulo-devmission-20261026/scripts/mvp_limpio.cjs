// v20z: copia de MvpFrente*.mdx sin efectos de partículas, cintas ni eventos (manchas al morir, pisadas, salpicaduras,
// sonidos). Los modelos se dibujan en la interfaz (pieza voladora) y esos efectos se quedaban pintados en el cuadro.
// ObjectId por orden de bloques: al quitar nodos se renumeran el resto, sus padres, PivotPoints y matrixIndices.
// Comprobación: la pose de los vértices en cada secuencia es igual a la del modelo de entrada.
// Uso: node mvp_limpio.cjs ENTRADA.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal] = process.argv.slice(2);
const m = M.read(ent);
const kinds = ['bones','lights','helpers','attachments','particleEmitters','particleEmitters2','ribbonEmitters','eventObjects','cameras','collisionShapes'];
const fuera = ['particleEmitters','particleEmitters2','ribbonEmitters','eventObjects'];
const nodos = kinds.flatMap(k => (m[k] || []).filter(n => 'objectId' in n));
M.assert(nodos.length === m.pivotPoints.length, 'nodos ' + nodos.length + ' pivotes ' + m.pivotPoints.length);
nodos.forEach((n, i) => M.assert(n.objectId === i, 'ObjectId fuera de orden: ' + n.name));
const quita = new Set(fuera.flatMap(k => (m[k] || []).map(n => n.objectId)));
const quedan = nodos.filter(n => !quita.has(n.objectId));
for (const n of quedan) M.assert(!quita.has(n.parentId), 'cuelga de un efecto: ' + n.name);
const id = new Map(quedan.map((n, i) => [n.objectId, i]));
for (const g of m.geosets) for (const v of g.matrixIndices) M.assert(id.has(v), 'matrixIndex de un efecto');
const piv = m.pivotPoints;
m.pivotPoints = quedan.map(n => piv[n.objectId]);
for (const g of m.geosets) g.matrixIndices = new Uint32Array(Array.from(g.matrixIndices, v => id.get(v)));
for (const n of quedan) { n.parentId = n.parentId === -1 ? -1 : id.get(n.parentId); n.objectId = id.get(n.objectId); }
for (const k of fuera) m[k] = [];
M.save(m, sal);
const r = M.read(sal);
for (const k of fuera) M.assert((r[k] || []).length === 0, 'quedó ' + k);
const o = M.read(ent);
const llano = x => { for (const k of kinds) for (const nd of (x[k] || [])) if ('flags' in nd) nd.flags &= ~(1|2|4|8|16|32|64|128);
  x.particleEmitters = []; x.particleEmitters2 = []; x.ribbonEmitters = []; x.eventObjects = []; };
llano(o); llano(r);
let peor = 0, n = 0;
for (let si = 0; si < r.sequences.length; si++) {
  const [i0, i1] = r.sequences[si].interval;
  for (const f of [i0, Math.round((i0 + i1) / 2), i1]) {
    const a = M.pose(o, si, f).points, b = M.pose(r, si, f).points;
    a.forEach((g, gi) => g.forEach((v, vi) => { const w = b[gi][vi]; peor = Math.max(peor, Math.hypot(v[0]-w[0], v[1]-w[1], v[2]-w[2])); n++; }));
  }
}
M.assert(peor < 0.001, 'desviación ' + peor);
console.log(`${sal}: ${quita.size} efectos fuera, ${quedan.length} nodos, ${r.sequences.length} secuencias, ${n} vértices iguales (máx. ${peor.toExponential(1)})`);
