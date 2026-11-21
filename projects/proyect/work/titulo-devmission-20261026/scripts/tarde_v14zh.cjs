// v14zh: tarde más oscura y anaranjada en los modelos de Dark Nights (The_Silent, Hive 324142). La hora queda parada
// (SuspendTimeOfDay), así que sólo cuenta el tramo de la tarde: día (12 h) y noche (0 h) no cambian. El ciclo va de
// 333 a 60333 en 24 h (cuadro = 333 + 2500 × hora). Se quitan las claves entre 17,35 h y 24 h y se ponen cuatro
// mesetas de tarde (±0,08 h) en 18,0 / 18,4 / 18,8 / 19,2 h; a las 19,6 h vuelve a los valores de noche del original.
// Color y color ambiental pasan de Hermite a lineal para que las mesetas queden planas.
// Uso: node tarde_v14zh.cjs DIR_DARK_NIGHTS CARPETA → DNCDarkNightsLordaeron{Terrain,Unit}.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, dir] = process.argv.slice(2);
const HORAS = [18.0, 18.4, 18.8, 19.2];
// [directa, color directa, ambiental, color ambiental] por meseta: 1 la más clara, 4 la más oscura.
const TARDE = [
  [0.12, [1.0, 0.52, 0.22], 0.06, [1.0, 0.46, 0.16]],
  [0.08, [1.0, 0.47, 0.17], 0.05, [0.96, 0.41, 0.12]],
  [0.06, [1.0, 0.43, 0.13], 0.04, [0.92, 0.37, 0.10]],
  [0.04, [0.96, 0.39, 0.10], 0.03, [0.86, 0.33, 0.08]],
];
const cuadro = h => Math.round(333 + 2500 * h);
for (const t of ['Terrain', 'Unit']) {
  const m = M.read(`${ent}/DNCDarkNightsLordaeron${t}.mdx`);
  M.assert.equal(m.lights.length, 1);
  const anim = Object.fromEntries(m.lights[0].animations.map(a => [a.name, a]));
  const extra = t === 'Unit' ? 0.02 : 0; // el original da algo más de ambiental a las unidades
  const tramo = { KLAI: TARDE.map(c => c[0]), KLAC: TARDE.map(c => c[1]), KLBI: TARDE.map(c => c[2] + extra), KLBC: TARDE.map(c => c[3]) };
  for (const [n, vals] of Object.entries(tramo)) {
    const a = anim[n];
    const f = Array.from(a.frames), v = a.values.map(x => Array.from(x));
    M.assert.equal(f[0], 333); M.assert.equal(f[f.length - 1], 60333);
    const noche = v[v.length - 1];
    const fr = [], vs = [];
    f.forEach((k, i) => { if (k <= 43700) { fr.push(k); vs.push(v[i]); } });
    HORAS.forEach((h, i) => {
      const x = Array.isArray(vals[i]) ? vals[i] : [vals[i]];
      fr.push(cuadro(h - 0.08), cuadro(h + 0.08)); vs.push(x, x);
    });
    fr.push(cuadro(19.6), 60333); vs.push(noche, noche);
    a.frames = new Uint32Array(fr);
    a.values = vs.map(x => new Float32Array(x));
    a.interpolationType = 1;
    a.inTans = []; a.outTans = [];
  }
  const r = M.save(m, `${dir}/DNCDarkNightsLordaeron${t}.mdx`);
  for (const a of r.lights[0].animations) console.log(t, a.name, a.interpolationType, a.frames.length);
}
