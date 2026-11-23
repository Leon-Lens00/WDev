// v22m (23/11/2026): el modelo del MVP se orienta como el jefe de la presentación (jefe_modelos_v17h.py, PresJefe*).
// Leon tras v22l-prueba: "segun el apartado de presentacion de boss ... usa otro modelo inclinado para que cuadre con la
// vista". En v22l se quitó el billboard y el modelo quedó de pie en el mundo: la cámara de juego (56° hacia abajo) lo veía
// desde arriba. Ahora el hueso "MvpFrente" (raíz de todo el modelo, de mvp_frente.cjs) pierde Billboarded (0x8) y lleva
// una rotación fija en una secuencia global nueva, la misma matriz que el jefe:
//   arriba del modelo (+Z) = arriba de la pantalla U = (0, 0.829, 0.559);
//   frente del modelo (+X) hacia la cámara B = (0, -0.559, 0.829), girado GIRO grados hacia la izquierda de la pantalla.
// La unidad va con facing 0 (MVP_MOD_GIRO 0, ya en v22l). Las capas ya eran sin sombra ni niebla.
// Comprobación: en el principio, el centro y el final de cada secuencia, cada vértice = matriz · vértice original.
// Uso: node mvp_giro_camara.cjs ENTRADA-v22j.mdx SALIDA.mdx GIRO
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const A = M.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/animations');
const [ent, sal, gr] = process.argv.slice(2);
const g = Number(gr) * Math.PI / 180;
// Cámara de juego (Camera_create): ojo en (0, -1597.176, 2367.912) del punto mirado.
const ojo = [0, -1597.176, 2367.912], L = Math.hypot(...ojo);
const F = ojo.map(v => -v / L), U = [0, -F[2], F[1]], B = F.map(v => -v), R = [1, 0, 0];
const X = B.map((v, i) => Math.cos(g) * v - Math.sin(g) * R[i]);
const Z = U;
const Y = [Z[1] * X[2] - Z[2] * X[1], Z[2] * X[0] - Z[0] * X[2], Z[0] * X[1] - Z[1] * X[0]];
// m[fila][col], columnas X, Y, Z.
const m = [0, 1, 2].map(i => [X[i], Y[i], Z[i]]);
const det = m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1]) - m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0]) +
            m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]);
M.assert(Math.abs(det - 1) < 1e-9, 'matriz de giro');
// Cuaternión (x, y, z, w) de la matriz.
let q;
{
  const t = m[0][0] + m[1][1] + m[2][2];
  if (t > 0) { const s = 0.5 / Math.sqrt(t + 1); q = [(m[2][1] - m[1][2]) * s, (m[0][2] - m[2][0]) * s, (m[1][0] - m[0][1]) * s, 0.25 / s]; }
  else if (m[0][0] > m[1][1] && m[0][0] > m[2][2]) { const s = 2 * Math.sqrt(1 + m[0][0] - m[1][1] - m[2][2]); q = [0.25 * s, (m[0][1] + m[1][0]) / s, (m[0][2] + m[2][0]) / s, (m[2][1] - m[1][2]) / s]; }
  else if (m[1][1] > m[2][2]) { const s = 2 * Math.sqrt(1 + m[1][1] - m[0][0] - m[2][2]); q = [(m[0][1] + m[1][0]) / s, 0.25 * s, (m[1][2] + m[2][1]) / s, (m[0][2] - m[2][0]) / s]; }
  else { const s = 2 * Math.sqrt(1 + m[2][2] - m[0][0] - m[1][1]); q = [(m[0][2] + m[2][0]) / s, (m[1][2] + m[2][1]) / s, 0.25 * s, (m[1][0] - m[0][1]) / s]; }
}
const rot = v => [0, 1, 2].map(i => m[i][0] * v[0] + m[i][1] * v[1] + m[i][2] * v[2]);
const md = M.read(ent);
const b = md.bones[0];
M.assert(b.name === 'MvpFrente' && b.objectId === 0 && b.parentId === -1 && (b.flags & 8), 'hueso MvpFrente con billboard');
M.assert(!(md.helpers || []).some(h => h.name === 'MvpVista'), 'sin MvpVista');
M.assert(!b.animations.length, 'MvpFrente sin pistas');
M.assert(Array.from(md.pivotPoints[0]).every(v => v === 0), 'pivote de MvpFrente en el origen');
b.flags &= ~8;
const G = md.globalSequences.length; md.globalSequences.push(1000);
const a = new A.Vector4Animation();
a.name = 'KGRT'; a.interpolationType = 0; a.globalSequenceId = G;
a.frames = new Uint32Array([0]); a.values = [new Float32Array(q.map(Math.fround))]; a.inTans = []; a.outTans = [];
b.animations.push(a);
M.save(md, sal);
// Comprobación: original sin billboard (pose() no lo aplica) contra copia releída, vértice a vértice.
const kinds = ['bones','helpers','lights','attachments','particleEmitters','particleEmitters2','ribbonEmitters','eventObjects','collisionShapes'];
const llano = x => { for (const k of kinds) for (const nd of (x[k] || [])) if ('flags' in nd) nd.flags &= ~(1|2|4|8|16|32|64|128);
  x.particleEmitters2 = []; x.eventObjects = []; };
const o = M.read(ent), r = M.read(sal);
M.assert(!(r.bones[0].flags & 8) && r.bones[0].animations.length === 1, 'MvpFrente guardado sin billboard y con giro');
llano(o); llano(r);
let peor = 0, n = 0, zmin = 1e9, zmax = -1e9;
for (let si = 0; si < r.sequences.length; si++) {
  const [i0, i1] = r.sequences[si].interval;
  for (const f of [i0, Math.round((i0 + i1) / 2), i1]) {
    const pa = M.pose(o, si, f).points, pb = M.pose(r, si, f).points;
    pa.forEach((gg, gi) => gg.forEach((v, vi) => { const w = pb[gi][vi], e = rot(v);
      peor = Math.max(peor, Math.hypot(e[0]-w[0], e[1]-w[1], e[2]-w[2])); n++; }));
  }
}
M.assert(peor < 0.01, 'desviación ' + peor);
console.log(`${sal.split('/').pop()}: giro ${gr}°, q ${q.map(v => v.toFixed(4)).join(',')}, ${n} vértices = matriz·original (máx. ${peor.toExponential(1)})`);
