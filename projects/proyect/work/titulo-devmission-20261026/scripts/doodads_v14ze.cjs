// v14ze: doodads del juego que no respetan la oscuridad, reescritos con su misma ruta para importarlos como reemplazo.
// - RiverRushes0..3 (juncos, 1163 en el mapa): su único material era Unshaded; pasa a sombreado, como Ruins_Shrub y
//   los árboles (RuinsTree/LordaeronTree), para que Dark Nights los oscurezca.
// - TorchHumanOmni, TorchHuman, LanternPost0/1 y Firepot: se quita la luz omni (el motor sólo dibuja 8 a la vez), el
//   geoset del halo aditivo (Yellow_Glow3 / lensflare1Ax) y el Unshaded de las piezas que brillaban (cristal del farol,
//   brasas del Firepot). El fuego de partículas se conserva.
// Uso: node doodads_v14ze.cjs DIR_ORIG DIR_SALIDA (las dos con rutas Doodads/...)
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [orig, sal] = process.argv.slice(2);
const NODOS = ['bones', 'lights', 'helpers', 'attachments', 'particleEmitters', 'particleEmitters2', 'ribbonEmitters',
  'eventObjects', 'collisionShapes'];

function quitarLuces(m) {
  while (m.lights.length) {
    const id = m.lights[0].objectId;
    for (const k of NODOS) for (const n of m[k]) M.assert.notEqual(n.parentId, id);
    m.lights.shift();
    for (const k of NODOS) for (const n of m[k]) {
      if (n.objectId > id) n.objectId--;
      if (n.parentId > id) n.parentId--;
    }
    m.pivotPoints.splice(id, 1);
  }
}
function quitarGeoset(m, g) {
  m.geosets.splice(g, 1);
  const ga = m.geosetAnimations.findIndex(a => a.geosetId === g);
  if (ga >= 0) m.geosetAnimations.splice(ga, 1);
  for (const a of m.geosetAnimations) if (a.geosetId > g) a.geosetId--;
  for (const b of m.bones) {
    if (b.geosetId === g) b.geosetId = -1; else if (b.geosetId > g) b.geosetId--;
    if (ga >= 0) { if (b.geosetAnimationId === ga) b.geosetAnimationId = -1; else if (b.geosetAnimationId > ga) b.geosetAnimationId--; }
  }
}
function sinHalo(m) { // geosets cuyo material es sólo aditivo (filterMode 3)
  for (let g = m.geosets.length - 1; g >= 0; g--)
    if (m.materials[m.geosets[g].materialId].layers.every(l => l.filterMode === 3)) quitarGeoset(m, g);
}
function sombreado(m) {
  for (const t of m.materials) for (const l of t.layers) if (l.filterMode < 3) l.flags &= ~1;
}
const D = 'Doodads/LordaeronSummer/';
const lista = [
  ...[0, 1, 2, 3].map(v => [D + `Plants/RiverRushes/RiverRushes${v}.mdx`, 'pasto']),
  [D + 'Props/TorchHumanOmni/TorchHumanOmni.mdx', 'luz'], [D + 'Props/TorchHuman/TorchHuman.mdx', 'luz'],
  [D + 'Props/LanternPost/LanternPost0.mdx', 'luz'], [D + 'Props/LanternPost/LanternPost1.mdx', 'luz'],
  ['Doodads/Ruins/Props/Firepot/Firepot.mdx', 'luz'],
];
for (const [ruta, tipo] of lista) {
  const m = M.read(`${orig}/${ruta}`);
  const antes = { geo: m.geosets.length, luces: m.lights.length, pe2: m.particleEmitters2.length };
  if (tipo === 'luz') { quitarLuces(m); sinHalo(m); }
  sombreado(m);
  M.fs.mkdirSync(M.path.dirname(`${sal}/${ruta}`), { recursive: true });
  const r = M.save(m, `${sal}/${ruta}`);
  M.assert.equal(r.lights.length, 0); M.assert.equal(r.pivotPoints.length, NODOS.reduce((s, k) => s + r[k].length, 0));
  M.assert.ok(r.materials.every(t => t.layers.every(l => l.filterMode >= 3 || !(l.flags & 1))));
  console.log(ruta, JSON.stringify(antes), '→', JSON.stringify({ geo: r.geosets.length, luces: r.lights.length, pe2: r.particleEmitters2.length }));
}
