// Variantes de LightWhite700.mdx («Light - Lights», DarknessFalls003) para elegir la luz del héroe con «-luz N» en
// v14zc. Cambia altura del pivote (Z), atenuación [inicio, fin], intensidad y luz ambiental; todo lo demás igual.
// Uso: node luz_variantes.cjs LightWhite700.mdx CARPETA  →  CARPETA/Luz1.mdx … Luz10.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, dir] = process.argv.slice(2);
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
  const r = M.save(m, `${dir}/Luz${i + 1}.mdx`);
  console.log(i + 1, JSON.stringify(M.plain(r.pivotPoints)), JSON.stringify(M.plain(r.lights[0])));
});
