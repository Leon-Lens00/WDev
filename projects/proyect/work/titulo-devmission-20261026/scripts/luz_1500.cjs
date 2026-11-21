// LightWhite1500.mdx: LightWhite700.mdx («Light - Lights», DarknessFalls003) con AttenuationEnd 1500 en lugar de 700;
// el resto igual (omni blanca, intensidad 300, ambiental 2). Uso: node luz_1500.cjs LightWhite700.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal] = process.argv.slice(2);
const m = M.read(ent);
M.assert.equal(m.lights.length, 1); M.assert.deepEqual(Array.from(m.lights[0].attenuation), [0, 700]);
m.lights[0].attenuation = new Float32Array([0, 1500]);
const r = M.save(m, sal);
console.log(JSON.stringify(M.plain(r.lights[0])));
