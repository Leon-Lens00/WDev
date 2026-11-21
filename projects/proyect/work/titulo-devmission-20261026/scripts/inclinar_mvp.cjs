// v20h: copia de un modelo de héroe inclinada hacia atrás para el cuadro MVP / menos puntos. La cámara de juego mira
// el cuadro desde arriba (~40-55°) y un modelo de pie se ve como mirando al suelo; Warcraft 1.27b no puede inclinar una
// unidad desde JASS. Se compone una rotación fija R0 (eje Y del modelo, cabeza hacia -X, de frente a la cámara) en cada
// nodo raíz, sin añadir nodos (los ObjectId deben seguir el orden de bloques):
//   traslación t' = R0 (p + t) - p,  rotación q' = q0 · q,  tangentes: hermite R0·tan (traslación), q0·tan (rotación),
//   bezier como valores. Raíz sin pista: pista constante en una secuencia global nueva. Pista por secuencia sin claves
//   en alguna secuencia: claves con el valor por defecto transformado al principio y al final.
// Comprobación: en el centro y los extremos de cada secuencia, cada vértice inclinado = R0 · vértice original.
// Uso: node inclinar_mvp.cjs ENTRADA.mdx SALIDA.mdx GRADOS
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const P = 'mdx-m3-viewer/dist/cjs/parsers/mdlx/';
const A = M.dependency(P + 'animations');
const [ent, sal, gr] = process.argv.slice(2);
const th = Number(gr) * Math.PI / 180;
const q0 = [0, Math.sin(-th / 2), 0, Math.cos(-th / 2)];
const c = Math.cos(-th), s = Math.sin(-th);
const R = v => [v[0] * c + v[2] * s, v[1], -v[0] * s + v[2] * c];
const qmul = (a, b) => [a[3]*b[0] + a[0]*b[3] + a[1]*b[2] - a[2]*b[1], a[3]*b[1] - a[0]*b[2] + a[1]*b[3] + a[2]*b[0],
                        a[3]*b[2] + a[0]*b[1] - a[1]*b[0] + a[2]*b[3], a[3]*b[3] - a[0]*b[0] - a[1]*b[1] - a[2]*b[2]];
const f32 = a => new Float32Array(a.map(Math.fround));
const kinds = ['bones','helpers','lights','attachments','particleEmitters','particleEmitters2','ribbonEmitters','eventObjects','collisionShapes'];
const m = M.read(ent), orig = M.read(ent);
const G = m.globalSequences.length; m.globalSequences.push(1000);
function pista(C, name, value) {
  const a = new C(); a.name = name; a.interpolationType = 0; a.globalSequenceId = G;
  a.frames = new Uint32Array([0]); a.values = [f32(value)]; a.inTans = []; a.outTans = []; return a;
}
let raices = 0, anadidas = 0;
for (const k of kinds) for (const n of (m[k] || [])) {
  if (n.parentId !== -1) continue;
  raices++;
  const p = Array.from(m.pivotPoints[n.objectId]);
  const def = { KGTR: [0, 0, 0], KGRT: [0, 0, 0, 1] };
  const tv = v => { const r = R([p[0] + v[0], p[1] + v[1], p[2] + v[2]]); return [r[0] - p[0], r[1] - p[1], r[2] - p[2]]; };
  const fx = { KGTR: { val: tv, tan: (v, it) => it === 3 ? tv(v) : R(v) }, KGRT: { val: q => qmul(q0, q), tan: q => qmul(q0, q) } };
  for (const nom of ['KGTR', 'KGRT']) {
    const a = n.animations.find(x => x.name === nom);
    if (!a) { n.animations.push(pista(nom === 'KGTR' ? A.Vector3Animation : A.Vector4Animation, nom, fx[nom].val(def[nom]))); anadidas++; continue; }
    // Claves que falten en alguna secuencia (pista por secuencia): valor por defecto al principio y al final.
    if (a.globalSequenceId === -1) {
      const fr = Array.from(a.frames), vals = a.values.map(v => Array.from(v));
      const it = a.interpolationType, tanDef = (it === 1 || it === 0) ? null : (it === 3 ? def[nom] : (nom === 'KGTR' ? [0,0,0] : def[nom]));
      let ins = Array.from(a.inTans || []).map(v => Array.from(v)), outs = Array.from(a.outTans || []).map(v => Array.from(v));
      for (const q of m.sequences) {
        const [i0, i1] = q.interval;
        if (fr.some(t => t >= i0 && t <= i1)) continue;
        for (const t of [i0, i1]) { fr.push(t); vals.push(def[nom]); if (tanDef) { ins.push(tanDef); outs.push(tanDef); } }
        anadidas++;
      }
      const ord = fr.map((t, i) => i).sort((x, y) => fr[x] - fr[y]);
      a.frames = new Uint32Array(ord.map(i => fr[i])); a.values = ord.map(i => f32(vals[i]));
      if (tanDef) { a.inTans = ord.map(i => f32(ins[i])); a.outTans = ord.map(i => f32(outs[i])); }
    }
    const it = a.interpolationType;
    a.values = a.values.map(v => f32(fx[nom].val(Array.from(v))));
    if (it > 1) { a.inTans = a.inTans.map(v => f32(fx[nom].tan(Array.from(v), it))); a.outTans = a.outTans.map(v => f32(fx[nom].tan(Array.from(v), it))); }
  }
  // El escritor pone las pistas de nodo (KGTR, KGRT, KGSC) antes que las propias del emisor: mismo orden aquí.
  const rango = x => ({ KGTR: 0, KGRT: 1, KGSC: 2 })[x.name] ?? 3;
  n.animations = n.animations.map((x, i) => [x, i]).sort((x, y) => rango(x[0]) - rango(y[0]) || x[1] - y[1]).map(x => x[0]);
}
// Extents: los del modelo girado (aprox.: caja de las 8 esquinas).
function caja(t) {
  if ([...t.min, ...t.max].some(v => !(Math.abs(v) < 1e30))) return;   // extensión vacía (±FLT_MAX): se deja
  const pts = []; for (const x of [t.min[0], t.max[0]]) for (const y of [t.min[1], t.max[1]]) for (const z of [t.min[2], t.max[2]]) pts.push(R([x, y, z]));
  const b = M.bounds(pts); t.min.set(b.min); t.max.set(b.max);
}
for (const q of m.sequences) caja(q.extent);
for (const g of m.geosets) { caja(g.extent); for (const e of g.sequenceExtents || []) caja(e); }
// Comprobación con la pose completa.
let peor = 0, muestras = 0;
for (let si = 0; si < m.sequences.length; si++) {
  const [i0, i1] = m.sequences[si].interval;
  for (const t of [i0, Math.round((i0 + i1) / 2), i1]) {
    const a = M.pose(orig, si, t).points, b = M.pose(m, si, t).points;
    a.forEach((g, gi) => g.forEach((v, vi) => { const r = R(v), w = b[gi][vi]; peor = Math.max(peor, Math.hypot(r[0]-w[0], r[1]-w[1], r[2]-w[2])); muestras++; }));
  }
}
M.assert(peor < 0.05, 'desviación ' + peor);
M.save(m, sal);
console.log(`${gr}°: ${raices} raíces, ${anadidas} pistas/claves añadidas, ${muestras} vértices comprobados, desviación máx. ${peor.toFixed(5)}`);
