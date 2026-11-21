// StormLuz.mdx: dummy de Storm v1.3.1 (OVOgenez) con la luz direccional dentro, siempre presente y encendida por
// animación. Evita crear un efecto de luz en cada destello (tirones de ~175 ms medidos en v14r).
// Secuencias: 0 "Stand" apagada; 1 + (v-1)*61 + (z+90) encendida con la intensidad v (0,4/0,8/1,2) y cenit z
// (-90..-30), con el giro de Bone_Chest que Ldummy usa para ese cenit. El acimut sigue siendo el giro de la unidad.
// Uso: node storm_luz.cjs LDUMMY.mdx L1.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const P = 'mdx-m3-viewer/dist/cjs/parsers/mdlx/';
const Sequence = M.dependency(P + 'sequence').default;
const A = M.dependency(P + 'animations');
const [ldummy, l1, salida] = process.argv.slice(2);
const d = M.read(ldummy), luz = M.read(l1);
const chest = d.helpers[1], rot = chest.animations[0];
M.assert.equal(chest.name, 'Bone_Chest'); M.assert.equal(rot.name, 'KGRT');
M.assert.equal(d.bones.length, 0); M.assert.equal(d.lights.length, 0); M.assert.equal(d.geosets.length, 0);
M.assert.equal(d.helpers[0].animations.length, 0);
const inicio = d.sequences.map(s => s.interval[0]);
M.assert.deepEqual(Array.from(rot.frames).slice(0, 61), inicio.slice(0, 61));

const L = 1000, INT = [0.4, 0.8, 1.2];
const seqs = [], kf = [], kv = [], vf = [], vv = [], ff = [], fv = [];
function seq(name, i) {
  const s = new Sequence(); s.name = name; s.interval = new Uint32Array([1000 + i * 2 * L, 1000 + i * 2 * L + L]);
  s.extent.boundsRadius = 1e9; seqs.push(s); return s.interval[0];
}
let t = seq('Stand', 0);
kf.push(t); kv.push(rot.values[0]); vf.push(t); vv.push(new Float32Array([0])); ff.push(t); fv.push(new Float32Array([0]));
for (let v = 1; v <= 3; v++) for (let z = 0; z <= 60; z++) {
  t = seq('Spell Luz' + v + ' ' + (z - 90), 1 + (v - 1) * 61 + z);
  kf.push(t); kv.push(rot.values[z]);
  vf.push(t); vv.push(new Float32Array([1])); ff.push(t); fv.push(new Float32Array([INT[v - 1]]));
}
function track(C, name, frames, values, gs = -1) {
  const a = new C(); a.name = name; a.interpolationType = 0; a.globalSequenceId = gs;
  a.frames = frames.map(Number); a.values = values; return a;
}
// Bone_Chest: un giro constante por secuencia (sin interpolación; cada secuencia tiene una sola clave).
chest.animations = [track(A.Vector4Animation, 'KGRT', kf, kv)];

// Luz: la de L1 (color y tipo), hija de Bone_Chest, con giro fijo de su secuencia global.
const lz = luz.lights[0];
M.assert.equal(lz.type, 1); M.assert.equal(luz.globalSequences[0], 0);
const giro = lz.animations.find(a => a.name === 'KGRT');
lz.name = 'StormLuz';
lz.animations = [giro, track(A.FloatAnimation, 'KLAV', vf, vv), track(A.FloatAnimation, 'KLAI', ff, fv)];
lz.intensity = 0;

// Orden de bloques del MDX: bones, lights, helpers, attachments. La luz pasa a ser el objeto 0.
const pivChest = d.pivotPoints[1];
lz.objectId = 0; lz.parentId = 2;
d.helpers.forEach(h => { h.objectId += 1; if (h.parentId >= 0) h.parentId += 1; });
d.attachments.forEach(a => { a.objectId += 1; if (a.parentId >= 0) a.parentId += 1; });
d.pivotPoints = [new Float32Array(pivChest), ...d.pivotPoints];
d.lights = [lz];
d.globalSequences = [0];
d.sequences = seqs;
d.name = 'StormLuz';
d.extent.boundsRadius = 1e9;
const r = M.save(d, salida);
console.log(JSON.stringify({secuencias: r.sequences.length, luces: r.lights.length,
  nodos: [...r.lights, ...r.helpers, ...r.attachments].map(n => [n.name, n.objectId, n.parentId]),
  pivotes: r.pivotPoints.length, ultima: r.sequences.at(-1).name, intervalo: Array.from(r.sequences.at(-1).interval)}));
