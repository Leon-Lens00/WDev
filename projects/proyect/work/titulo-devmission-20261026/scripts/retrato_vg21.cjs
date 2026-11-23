// v22b (22/11/2026): retrato y frente del MVP de Vegeta de D.O.N 2.1a con cabeza.
// Como retrato_tr21.cjs (v21v): en 2.1a el cuerpo "Vegeta'sBody_squished.mdx" no tiene cabeza; A080/A081/A0JN cuelgan
// "Vegeta Super Saiyan 2 Head_squished.mdx" (o la azul) del punto "head", y el retrato no dibuja lo colgado. Se copia el
// cuerpo y se le añade la geometría de la cabeza base: vértices + pivote de "Head Ref" (Z 164), pegados a su hueso padre
// (Bone_Head), con su textura y material. El retrato de 2.1a (Vegeta'sBody_squished_portrait.mdx) es un modelo vacío.
// Cámara: la del cuerpo mira hacia arriba desde el pecho; se pone delante (+X, el frente del modelo), mirando a Z 184
// (cabeza de Z 156 a 214) desde Z 176, a 115, como Trunks (a 125 para su cabeza) y Kurama (a 115).
// Uso: node retrato_vg21.cjs CUERPO.mdx CABEZA.mdx RETRATO.mdx CON_CABEZA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [fc, fh, sal, conCabeza] = process.argv.slice(2);
const pon = () => {
  const b = M.read(fc), h = M.read(fh);
  const ref = b.attachments.find(a => a.name === 'Head Ref');
  M.assert(ref && b.bones[ref.parentId] && b.bones[ref.parentId].objectId === ref.parentId && b.bones[ref.parentId].name === 'Bone_Head', 'Head Ref cuelga de Bone_Head');
  const piv = Array.from(b.pivotPoints[ref.objectId]);
  M.assert(h.geosets.length === 1 && h.textures.length === 1, 'cabeza de una pieza');
  const g = h.geosets[0];
  const v = g.vertices;
  for (let i = 0; i < v.length; i += 3) for (let k = 0; k < 3; k++) v[i + k] += piv[k];
  g.vertexGroups = new Uint8Array(v.length / 3);
  g.matrixGroups = new Uint32Array([1]);
  g.matrixIndices = new Uint32Array([ref.parentId]);
  const ti = b.textures.length;
  b.textures.push(h.textures[0]);
  const mat = h.materials[g.materialId];
  for (const l of mat.layers) {
    M.assert(typeof l.textureId === 'number' && l.textureId === 0 && !l.textureIdTrack, 'capa con textura fija');
    l.textureId = ti;
  }
  g.materialId = b.materials.length;
  b.materials.push(mat);
  const pts = [];
  for (let i = 0; i < v.length; i += 3) pts.push([v[i], v[i + 1], v[i + 2]]);
  const E = g.extent.constructor;
  const ext = () => { const e = new E(); M.assignBounds(e, pts); return e; };
  g.extent = ext();
  g.sequenceExtents = b.sequences.map(ext);
  g.selectionGroup = 0;
  b.geosets.push(g);
  return { b, piv, z: [Math.min(...pts.map(p => p[2])), Math.max(...pts.map(p => p[2]))] };
};
const r = pon();
M.save(r.b, conCabeza);
const { b, piv, z } = pon();
M.assert(b.cameras.length === 1 && !b.cameras[0].animations.length, 'una cámara fija');
const cam = b.cameras[0];
cam.targetPosition[0] = piv[0];
cam.targetPosition[1] = piv[1];
cam.targetPosition[2] = piv[2] + 20;
cam.position[0] = piv[0] + 115;
cam.position[1] = piv[1];
cam.position[2] = piv[2] + 12;
M.save(b, sal);
console.log('retrato:', b.geosets.length, 'geosets; cabeza en', piv.map(x => x.toFixed(1)).join(','), 'Z', z.map(x => x.toFixed(1)).join('-'));
