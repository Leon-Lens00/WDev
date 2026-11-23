// v21y (22/11/2026): cuerpo y retrato de Naruto Kurama (D.O.N 2.1a, "Naruto (Sage Mode)_squished.mdx" de 2.1a, que no es
// el nuestro del sabio aunque se llame igual).
// - Sin la luz omni del modelo (atenuación 250/500): el motor dibuja como mucho 8 luces de modelo a la vez y con varias
//   copias de Kurama se apagarían otras. ObjectId por orden de bloques: al quitar el nodo se renumeran los demás, sus
//   padres, PivotPoints y matrixIndices (como mvp_limpio.cjs).
// - Retrato propio: el de 2.1a es el del sabio. La cámara Camera01 mira al pecho (Z 88); la cabeza va de Z 120 a 160 en
//   Stand (head ref en 159, arriba). Como retrato_tr21.cjs (Trunks: 13 por encima de la base de la cabeza, a 125 para
//   una cabeza de 44): mira a Z 133 desde Z 120, a 115, en la misma dirección horizontal que la cámara original.
// Comprobación: la pose de los vértices en cada secuencia es igual a la del original.
// Uso: node retrato_nk21.cjs ENTRADA.mdx CUERPO.mdx RETRATO.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, cuerpo, retrato] = process.argv.slice(2);
const kinds = ['bones','lights','helpers','attachments','particleEmitters','particleEmitters2','ribbonEmitters','eventObjects','cameras','collisionShapes'];
const sinLuz = () => {
  const m = M.read(ent);
  const nodos = kinds.flatMap(k => (m[k] || []).filter(n => 'objectId' in n));
  M.assert(nodos.length === m.pivotPoints.length, 'nodos ' + nodos.length + ' pivotes ' + m.pivotPoints.length);
  nodos.forEach((n, i) => M.assert(n.objectId === i, 'ObjectId fuera de orden: ' + n.name));
  M.assert(m.lights.length === 1, 'una luz');
  const quita = new Set(m.lights.map(n => n.objectId));
  const quedan = nodos.filter(n => !quita.has(n.objectId));
  for (const n of quedan) M.assert(!quita.has(n.parentId), 'cuelga de la luz: ' + n.name);
  const id = new Map(quedan.map((n, i) => [n.objectId, i]));
  for (const g of m.geosets) for (const v of g.matrixIndices) M.assert(id.has(v), 'matrixIndex de la luz');
  const piv = m.pivotPoints;
  m.pivotPoints = quedan.map(n => piv[n.objectId]);
  for (const g of m.geosets) g.matrixIndices = new Uint32Array(Array.from(g.matrixIndices, v => id.get(v)));
  for (const n of quedan) { n.parentId = n.parentId === -1 ? -1 : id.get(n.parentId); n.objectId = id.get(n.objectId); }
  m.lights = [];
  // Un ayudante de 2.1a se llama 'Bone"': la comilla rompe la comprobación MDL de M.save. Sólo el nombre.
  let k = 0;
  for (const n of quedan) if (n.name.includes('"')) { n.name = n.name.replace(/"/g, ''); k++; }
  M.assert(k === 1, 'nombres con comilla ' + k);
  return m;
};
const b = sinLuz();
M.save(b, cuerpo);
const r = sinLuz();
M.assert(r.cameras.length === 1 && !r.cameras[0].animations.length, 'una cámara fija');
const cam = r.cameras[0];
const dx = cam.position[0] - cam.targetPosition[0], dy = cam.position[1] - cam.targetPosition[1], dl = Math.hypot(dx, dy);
cam.targetPosition[2] = 133;
cam.position[0] = cam.targetPosition[0] + 115 * dx / dl;
cam.position[1] = cam.targetPosition[1] + 115 * dy / dl;
cam.position[2] = 120;
M.save(r, retrato);
// comprobación de pose (sin billboard ni herencias, que pose() no admite)
const o = M.read(ent);
const llano = x => { for (const k of kinds) for (const nd of (x[k] || [])) if ('flags' in nd) nd.flags &= ~0xff;
  x.particleEmitters = []; x.particleEmitters2 = []; x.ribbonEmitters = []; x.eventObjects = []; };
let peor = 0, n = 0;
for (const f of [cuerpo, retrato]) {
  const c = M.read(f);
  M.assert(c.lights.length === 0, 'quedó la luz');
  const oo = M.read(ent); llano(oo); llano(c);
  for (let si = 0; si < c.sequences.length; si++) {
    const [i0, i1] = c.sequences[si].interval;
    for (const t of [i0, Math.round((i0 + i1) / 2), i1]) {
      const a = M.pose(oo, si, t).points, q = M.pose(c, si, t).points;
      a.forEach((g, gi) => g.forEach((v, vi) => { const w = q[gi][vi]; peor = Math.max(peor, Math.hypot(v[0]-w[0], v[1]-w[1], v[2]-w[2])); n++; }));
    }
  }
}
M.assert(peor < 0.001, 'desviación ' + peor);
console.log(`kurama: sin luz, ${b.pivotPoints.length} nodos, ${b.sequences.length} secuencias, ${n} vértices iguales; cámara`,
  Array.from(cam.position).map(x => x.toFixed(0)).join(','), '->', Array.from(cam.targetPosition).map(x => x.toFixed(0)).join(','));
