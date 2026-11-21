// v14zf: luz del héroe con batería. A partir de LightWhite700.mdx («Light - Lights», DarknessFalls003) con los valores
// de la Luz 8 de v14zc (pivote Z 400, atenuación 0-1500, intensidad 1000, ambiental 5) escalados por paso:
// BatLuz5 = 100% (batería por encima del 10%) y BatLuz4..BatLuz0 = 80, 60, 40, 20 y 10% (del 10% al 0%).
// Intensidad y ambiental bajan con el paso; el alcance baja de 1500 a 750 para que el círculo también se encoja.
// Cada una lleva la secuencia Death de luz_variantes_muerte.cjs: al cambiar de paso la anterior se apaga al momento.
// Uso: node luz_bateria.cjs LightWhite700.mdx CARPETA → BatLuz0..5.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const P = 'mdx-m3-viewer/dist/cjs/parsers/mdlx/';
const Sequence = M.dependency(P + 'sequence').default;
const A = M.dependency(P + 'animations');
const [ent, dir] = process.argv.slice(2);
function track(C, name, frames, values) {
  const a = new C(); a.name = name; a.interpolationType = 0; a.globalSequenceId = -1;
  a.frames = frames; a.values = values.map(v => new Float32Array([v])); return a;
}
[0.1, 0.2, 0.4, 0.6, 0.8, 1].forEach((f, i) => {
  const m = M.read(ent);
  M.assert.equal(m.lights.length, 1); M.assert.equal(m.pivotPoints.length, 1);
  M.assert.deepEqual(Array.from(m.lights[0].attenuation), [0, 700]);
  M.assert.equal(m.sequences.length, 1); M.assert.equal(m.lights[0].animations.length, 0);
  const it = Math.fround(1000 * f);
  m.pivotPoints[0][2] = Math.fround(400);
  m.lights[0].attenuation = new Float32Array([0, 750 + 750 * f]);
  m.lights[0].intensity = it;
  m.lights[0].ambientIntensity = Math.fround(5 * f);
  const d = new Sequence(); d.name = 'Death'; d.interval = new Uint32Array([3400, 3433]); d.nonLooping = 1;
  m.sequences.push(d);
  m.lights[0].animations = [track(A.FloatAnimation, 'KLAV', [0, 3400], [1, 0]),
                            track(A.FloatAnimation, 'KLAI', [0, 3400], [it, 0])];
  const r = M.save(m, `${dir}/BatLuz${i}.mdx`);
  const l = r.lights[0];
  console.log(i, f, l.intensity, l.ambientIntensity, Array.from(l.attenuation), r.pivotPoints[0][2], JSON.stringify(M.plain(r.sequences).map(q => [q.name, q.interval])));
});
