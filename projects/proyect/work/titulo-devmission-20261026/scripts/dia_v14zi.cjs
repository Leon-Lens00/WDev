// v14zi: día con neblina en los modelos de Dark Nights de v14zh (tarde_v14zh.cjs). Añade una meseta de luz tenue y
// blanca a las 3,0 h (±0,08 h, cuadro = 333 + 2500 × hora), en el tramo noche-alba que nadie usa con la hora parada:
// la noche (0 h, cuadro 333) y la tarde (18,8 h) no cambian. El tono lo da sobre todo la niebla (v14zi.py).
// Uso: node dia_v14zi.cjs DIR_TARDE_V14ZH CARPETA → DNCDarkNightsLordaeron{Terrain,Unit}.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, dir] = process.argv.slice(2);
const cuadro = h => Math.round(333 + 2500 * h);
for (const t of ['Terrain', 'Unit']) {
  const m = M.read(`${ent}/DNCDarkNightsLordaeron${t}.mdx`);
  const extra = t === 'Unit' ? 0.02 : 0;
  const DIA = { KLAI: [0.10], KLAC: [0.85, 0.88, 0.92], KLBI: [0.06 + extra], KLBC: [0.80, 0.83, 0.88] };
  for (const a of m.lights[0].animations) {
    if (!DIA[a.name]) continue;
    M.assert.equal(a.interpolationType, 1);
    const f = Array.from(a.frames), v = a.values.map(x => Array.from(x));
    M.assert.equal(f[0], 333); M.assert.ok(f[1] > cuadro(3.08));
    f.splice(1, 0, cuadro(2.92), cuadro(3.08)); v.splice(1, 0, DIA[a.name], DIA[a.name]);
    a.frames = new Uint32Array(f); a.values = v.map(x => new Float32Array(x));
  }
  const r = M.save(m, `${dir}/DNCDarkNightsLordaeron${t}.mdx`);
  console.log(t, r.lights[0].animations.map(a => a.name + ':' + a.frames.length).join(' '));
}
