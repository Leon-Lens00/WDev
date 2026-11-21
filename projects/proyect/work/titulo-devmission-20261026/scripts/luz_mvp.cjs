// v20d: luz de los modelos del cuadro MVP / menos puntos. La noche fija (DNC Dark Nights, 0,05) deja negras las
// unidades lejos de la luz del héroe; esta luz va pegada al modelo, sólo en el cliente que lo ve.
// Parte de BatLuz5.mdx (luz del héroe, con Death que la apaga al momento) con alcance corto para no tocar el suelo.
// Uso: node luz_mvp.cjs BatLuz5.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal] = process.argv.slice(2);
const m = M.read(ent);
M.assert.equal(m.lights.length, 1); M.assert.equal(m.pivotPoints.length, 1);
m.pivotPoints[0][2] = Math.fround(150);
m.lights[0].attenuation = new Float32Array([0, 500]);
for (const a of m.lights[0].animations) if (a.name === 'KLAI') a.values = a.values.map((v, i) => new Float32Array([i === 0 ? 700 : 0]));
m.lights[0].intensity = Math.fround(700);
m.lights[0].ambientIntensity = Math.fround(3);
const r = M.save(m, sal);
const l = r.lights[0];
console.log(l.intensity, l.ambientIntensity, Array.from(l.attenuation), r.pivotPoints[0][2],
  JSON.stringify(M.plain(r.sequences).map(q => [q.name, q.interval])), JSON.stringify(M.plain(l.animations)));
