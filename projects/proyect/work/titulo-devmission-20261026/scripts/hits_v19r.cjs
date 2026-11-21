// v19r: quads de clic de los iconos (56 × 56) y las pestañas (104 × 36) de los paneles de mejoras; método de v15c.
// v15c: quads de clic de la tienda del prototipo, copias de v14a-recursos/ShopHitBtn.mdx (366 x 62 px, ±210.2 x ±35.6)
// con los vértices escalados al tamaño en píxeles de cada ranura (1,1486 unidades por píxel a la profundidad de la tienda).
// Uso: node scripts/hits_v19r.cjs DIR_SALIDA
const c = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const out = process.argv[2];
c.fs.mkdirSync(out, {recursive: true});
const SIZES = {CuaHitIco: [56, 56], CuaHitTab: [104, 36]};
function fit(e, hx, hy) {
  e.min[0] = -hx; e.max[0] = hx; e.min[1] = -hy; e.max[1] = hy;
  e.boundsRadius = Math.fround(Math.hypot(hx, hy, 14));
}
for (const [name, [w, h]] of Object.entries(SIZES)) {
  const m = c.read('v14a-recursos/ShopHitBtn.mdx');
  const hx = Math.fround(35.6 * h / 62), hy = Math.fround(210.2 * w / 366);
  for (const g of m.geosets) {
    for (let i = 0; i < g.vertices.length; i += 3) {
      g.vertices[i] = Math.sign(g.vertices[i]) * hx;
      g.vertices[i + 1] = Math.sign(g.vertices[i + 1]) * hy;
    }
    fit(g.extent, hx, hy);
    for (const e of g.sequenceExtents) fit(e, hx, hy);
  }
  fit(m.extent, hx, hy);
  for (const s of m.sequences) fit(s.extent, hx, hy);
  c.save(m, c.path.join(out, name + '.mdx'));
  console.log(name, hx.toFixed(1), hy.toFixed(1));
}
