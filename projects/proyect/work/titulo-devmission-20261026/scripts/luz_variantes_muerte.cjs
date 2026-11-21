// Variantes de LightWhite700.mdx («Light - Lights», DarknessFalls003) para elegir la luz del héroe con «-luz N» en
// v14zd. Cambia altura del pivote (Z), atenuación [inicio, fin], intensidad y luz ambiental, y añade una secuencia
// «Death» (3400-3433, sin bucle) con la luz invisible e intensidad 0: al destruir el efecto se apaga al momento, sin
// los segundos que tardaba en v14zc. Uso: node luz_variantes_muerte.cjs LightWhite700.mdx CARPETA → Luz1..10.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const P = 'mdx-m3-viewer/dist/cjs/parsers/mdlx/';
const Sequence = M.dependency(P + 'sequence').default;
const A = M.dependency(P + 'animations');
const [ent, dir] = process.argv.slice(2);
function track(C, name, frames, values) {
  const a = new C(); a.name = name; a.interpolationType = 0; a.globalSequenceId = -1;
  a.frames = frames; a.values = values.map(v => new Float32Array([v])); return a;
}
const V = [ // z, inicio, fin, intensidad, ambiental
  [17, 0, 1500, 300, 2],  // 1: la de v14zb
  [17, 0, 700, 300, 2],   // 2: la original (v14za)
  [200, 0, 1500, 300, 2], // 3
  [400, 0, 1500, 300, 2], // 4
  [200, 0, 1500, 600, 2], // 5
  [200, 0, 1500, 1000, 2],// 6
  [200, 0, 1500, 600, 5], // 7
  [400, 0, 1500, 1000, 5],// 8
  [200, 600, 1500, 300, 2],// 9
  [200, 0, 3000, 600, 2], // 10
];
V.forEach(([z, a0, a1, it, amb], i) => {
  const m = M.read(ent);
  M.assert.equal(m.lights.length, 1); M.assert.equal(m.pivotPoints.length, 1);
  M.assert.deepEqual(Array.from(m.lights[0].attenuation), [0, 700]);
  m.pivotPoints[0][2] = Math.fround(z);
  m.lights[0].attenuation = new Float32Array([a0, a1]);
  m.lights[0].intensity = Math.fround(it);
  m.lights[0].ambientIntensity = Math.fround(amb);
  M.assert.equal(m.sequences.length, 1); M.assert.equal(m.lights[0].animations.length, 0);
  const d = new Sequence(); d.name = 'Death'; d.interval = new Uint32Array([3400, 3433]); d.nonLooping = 1;
  m.sequences.push(d);
  m.lights[0].animations = [track(A.FloatAnimation, 'KLAV', [0, 3400], [1, 0]),
                            track(A.FloatAnimation, 'KLAI', [0, 3400], [Math.fround(it), 0])];
  const r = M.save(m, `${dir}/Luz${i + 1}.mdx`);
  console.log(i + 1, JSON.stringify(M.plain(r.sequences).map(q => [q.name, q.interval, q.nonLooping])), JSON.stringify(M.plain(r.lights[0].animations)));
});
