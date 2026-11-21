// v14zn: Interceptor Shell de Vinz (no la versión Rain) en los 6 colores de tier (Arm_ColorTier: amarillo, verde, cian,
// azul, morado, rojo), sin luz. El original es naranja/fuego: a cada color con saturación > 0,15 (colores de segmento
// de los 23 emisores, color de las 8 cintas y color estático de las 3 animaciones de geoset) se le pone el tono del
// tier, conservando su saturación y su brillo. Grises y blancos quedan igual; las texturas del juego son casi neutras.
// Uso: node efectos_v14zn.cjs → misil-v14zn/InterceptorShell1..6.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const cp = require('child_process');
const aqui = M.path.resolve(__dirname, '..');
const src = M.path.join(aqui, 'fuentes/culling-interceptor/x/Interceptor Shell/Interceptor Shell.mdx');
const out = M.path.join(aqui, 'misil-v14zn');
M.fs.mkdirSync(out, { recursive: true });
const TIER = [[0xfd, 0xea, 0x00], [0x65, 0xfd, 0x00], [0x00, 0xe3, 0xfd], [0x00, 0x45, 0xfd], [0x72, 0x00, 0xfd], [0xfd, 0x00, 0x06]]
  .map(c => c.map(v => v / 255));

function hsv([r, g, b]) {
  const mx = Math.max(r, g, b), mn = Math.min(r, g, b), d = mx - mn;
  let h = 0;
  if (d > 0) h = mx === r ? ((g - b) / d) % 6 : mx === g ? (b - r) / d + 2 : (r - g) / d + 4;
  return [(h * 60 + 360) % 360, mx > 0 ? d / mx : 0, mx];
}
function rgb([h, s, v]) {
  const c = v * s, x = c * (1 - Math.abs((h / 60) % 2 - 1)), m = v - c;
  const [r, g, b] = h < 60 ? [c, x, 0] : h < 120 ? [x, c, 0] : h < 180 ? [0, c, x] : h < 240 ? [0, x, c] : h < 300 ? [x, 0, c] : [c, 0, x];
  return [r + m, g + m, b + m];
}
const tono = (col, h) => { const [, s, v] = hsv(col); return s > 0.15 ? rgb([h, s, v]) : Array.from(col); };

const sinLuz = M.path.join(out, 'interceptor-sin-luz.mdx');
cp.execFileSync('node', [M.path.join(__dirname, 'sin_luz_v14zk.cjs'), src, sinLuz]);
for (let t = 0; t < 6; t++) {
  const m = M.read(sinLuz);
  M.assert.equal(m.lights.length, 0);
  M.assert.equal(m.particleEmitters2.length, 23);
  M.assert.equal(m.ribbonEmitters.length, 8);
  const h = hsv(TIER[t])[0];
  let n = 0;
  for (const e of m.particleEmitters2) {
    M.assert.ok(!(e.animations || []).some(a => /KP2C|KPC/.test(a.name)), 'color de emisor animado');
    e.segmentColors = e.segmentColors.map(c => { n++; return new Float32Array(tono(c, h)); });
  }
  for (const r of m.ribbonEmitters) {
    M.assert.ok(!(r.animations || []).some(a => a.name === 'KRCO'), 'color de cinta animado');
    r.color = new Float32Array(tono(r.color, h)); n++;
  }
  for (const g of m.geosetAnimations) {
    M.assert.ok(!(g.animations || []).some(a => a.name === 'KGAC'), 'color de geoset animado');
    g.color = new Float32Array(tono(g.color, h)); n++;
  }
  const f = M.path.join(out, `InterceptorShell${t + 1}.mdx`);
  M.save(m, f);
  const r = M.read(f);
  M.assert.equal(r.lights.length, 0);
  console.log(M.path.basename(f), 'tono', h.toFixed(0), 'colores', n,
    'cinta0', [...r.ribbonEmitters[0].color].map(x => x.toFixed(2)).join(','),
    'geo1', [...r.geosetAnimations[1].color].map(x => x.toFixed(2)).join(','));
}
M.fs.rmSync(sinLuz);
for (const f of M.fs.readdirSync(out)) if (f.endsWith('.mdl')) M.fs.rmSync(M.path.join(out, f));
