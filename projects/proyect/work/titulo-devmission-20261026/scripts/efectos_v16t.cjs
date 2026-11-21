// v16t (08/11/2026): Firebrand Shot ligero para los perdigones de la escopeta (Arm_Bala c == 4).
// Medición v16s: con 8 SPAS-12 el modelo costaba ~27 ms por cuadro. Cada perdigón que choca reproduce Death, donde
// 8 emisores sueltan ~70 partículas; con ~384 perdigones/s son ~27 000 partículas/s.
// Cambios, nada más: tasa (KP2E) de todos los emisores de partículas a 1/4; vida de la estela «S L Trail» 0,4 -> 0,25 s
// y de las cintas «Rib US» 0,10 -> 0,05 s. Mismos bloques, ids, texturas, secuencias y pivotes.
// Uso: node efectos_v16t.cjs CARPETA_ORIGEN CARPETA_SALIDA   (ORIGEN = sin-luz-v14zk/FirebrandShots, el del mapa)
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal] = process.argv.slice(2);
for (const c of ['Yellow', 'Green', 'Teal', 'Blue', 'Purple', 'Red']) {
  const f = `Firebrand Shot ${c}.mdx`;
  const m = M.read(`${ent}/${f}`);
  M.assert.equal(m.particleEmitters2.length, 10); M.assert.equal(m.ribbonEmitters.length, 6);
  let antes = 0, despues = 0;
  for (const e of m.particleEmitters2) {
    M.assert.equal(e.emissionRate, 0);
    const a = e.animations.find(x => x.name === 'KP2E');
    a.values = a.values.map(v => { antes += v[0]; despues += Math.fround(v[0] / 4); return new Float32Array([v[0] / 4]); });
    if (e.name === 'S L Trail') { M.assert.ok(Math.abs(e.lifeSpan - 0.4) < 1e-6); e.lifeSpan = Math.fround(0.25); }
  }
  for (const e of m.ribbonEmitters) {
    if (e.name.startsWith('Rib US')) { M.assert.ok(Math.abs(e.lifeSpan - 0.1) < 1e-6); e.lifeSpan = Math.fround(0.05); }
  }
  M.save(m, `${sal}/${f}`);
  const r = M.read(`${sal}/${f}`);
  const kp = r.particleEmitters2.map(e => M.plain(e.animations.find(x => x.name === 'KP2E').values).join('/')).join(' ');
  console.log(c, 'tasas', antes, '->', despues, '|', kp);
}
