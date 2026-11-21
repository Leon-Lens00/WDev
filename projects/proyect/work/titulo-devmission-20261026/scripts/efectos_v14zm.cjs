// v14zm: Culling Cleave (golpe A, por delante) y Culling Slash (golpe B, área) de Vinz en los 6 colores de tier
// (Arm_ColorTier: amarillo, verde, cian, azul, morado, rojo), sin luz. Parte de los modelos base (verdes); sólo cambia
// los colores estáticos de sus dos animaciones de geoset (RGB: el claro = color + 50 % de blanco, el oscuro = color ×
// 0,88, como en las variantes Red/Purple de Vinz). Slash pierde su luz con sin_luz_v14zk.cjs. Lo demás queda igual.
// Uso: node efectos_v14zm.cjs → cuchillo-v14zm/CullingCleave1..6.mdx, CullingSlash1..6.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const cp = require('child_process');
const aqui = M.path.resolve(__dirname, '..');
const src = M.path.join(aqui, 'fuentes/culling-interceptor/x/Culling Slash');
const out = M.path.join(aqui, 'cuchillo-v14zm');
M.fs.mkdirSync(out, { recursive: true });
const TIER = [[0xfd, 0xea, 0x00], [0x65, 0xfd, 0x00], [0x00, 0xe3, 0xfd], [0x00, 0x45, 0xfd], [0x72, 0x00, 0xfd], [0xfd, 0x00, 0x06]]
  .map(c => c.map(v => v / 255));
const sinLuz = M.path.join(out, 'slash-sin-luz.mdx');
cp.execFileSync('node', [M.path.join(__dirname, 'sin_luz_v14zk.cjs'), M.path.join(src, 'Culling Slash.mdx'), sinLuz]);
for (const [nombre, base] of [['CullingCleave', M.path.join(src, 'Culling Cleave.mdx')], ['CullingSlash', sinLuz]]) {
  for (let t = 0; t < 6; t++) {
    const m = M.read(base);
    M.assert.equal(m.geosetAnimations.length, 2);
    M.assert.equal(m.lights.length, 0);
    const c = TIER[t];
    m.geosetAnimations.forEach((g, i) => {
      M.assert.ok(!g.colorAnim && !(g.animations || []).some(a => a.name === 'KGAC'), 'color animado');
      const v = i === 0 ? c.map(x => x + (1 - x) * 0.5) : c.map(x => x * 0.88);
      g.color = new Float32Array(v);
    });
    const f = M.path.join(out, `${nombre}${t + 1}.mdx`);
    M.save(m, f);
    const r = M.read(f);
    M.assert.equal(r.lights.length, 0);
    console.log(M.path.basename(f), r.geosetAnimations.map(g => [...g.color].map(x => x.toFixed(2)).join(',')).join(' | '));
  }
}
M.fs.rmSync(sinLuz);
