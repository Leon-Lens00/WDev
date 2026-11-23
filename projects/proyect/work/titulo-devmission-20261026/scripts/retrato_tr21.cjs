// v21v (22/11/2026): retrato de Future Trunks de D.O.N 2.1a con cabeza (Leon: "sale sin cabeza").
// Como retrato_goku21.cjs (v21f): en 2.1a la cabeza es otro modelo (TrunkHead.mdx) que A07X cuelga del punto "head" y
// el retrato no dibuja lo colgado. Se copia TrunkNormal.mdx y se le añade la geometría de la cabeza base: vértices +
// pivote de "Head Ref" del cuerpo, pegados al hueso padre de Head Ref (bone_new12), con su textura y material. Sólo la
// cabeza base: el retrato no cambia de pelo con la forma.
// Uso: node retrato_tr21.cjs CUERPO.mdx CABEZA.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [fc, fh, sal] = process.argv.slice(2);
const b = M.read(fc), h = M.read(fh);
const ref = b.attachments.find(a => a.name === 'Head Ref');
M.assert(ref && b.bones[ref.parentId] && b.bones[ref.parentId].objectId === ref.parentId && b.bones[ref.parentId].name === 'bone_new12', 'Head Ref cuelga de bone_new12');
const piv = Array.from(b.pivotPoints[ref.objectId]);
M.assert(h.geosets.length === 1 && h.materials.length === 1 && h.textures.length === 1, 'cabeza de una pieza');
const g = h.geosets[0];
const v = g.vertices;
for (let i = 0; i < v.length; i += 3) for (let k = 0; k < 3; k++) v[i + k] += piv[k];
g.vertexGroups = new Uint8Array(v.length / 3);
g.matrixGroups = new Uint32Array([1]);
g.matrixIndices = new Uint32Array([ref.parentId]);
// textura y material nuevos al final
const ti = b.textures.length;
b.textures.push(h.textures[0]);
const mat = h.materials[0];
for (const l of mat.layers) {
  M.assert(typeof l.textureId === 'number' && l.textureId === 0 && !l.textureIdTrack, 'capa con textura fija');
  l.textureId = ti;
}
g.materialId = b.materials.length;
b.materials.push(mat);
// extensiones: la propia y una por secuencia del cuerpo
const pts = [];
for (let i = 0; i < v.length; i += 3) pts.push([v[i], v[i + 1], v[i + 2]]);
const E = g.extent.constructor;
const ext = () => { const e = new E(); M.assignBounds(e, pts); return e; };
g.extent = ext();
g.sequenceExtents = b.sequences.map(ext);
g.selectionGroup = 0;
b.geosets.push(g);
// Cámara: la de TrunkNormal mira al pecho (Z 165) y la cabeza va de Z 191 a 235. Como en Goku21_portrait (cámara a la
// altura de Head Ref, mirando 13 más arriba, a 105), escalado por el tamaño de Trunks (x 1,19): a 125, misma dirección.
const cam = b.cameras[0];
M.assert(b.cameras.length === 1 && !cam.animations.length, 'una cámara fija');
const dx = cam.position[0] - cam.targetPosition[0], dy = cam.position[1] - cam.targetPosition[1], dl = Math.hypot(dx, dy);
cam.targetPosition[2] = piv[2] + 13;
cam.position[0] = cam.targetPosition[0] + 125 * dx / dl;
cam.position[1] = cam.targetPosition[1] + 125 * dy / dl;
cam.position[2] = piv[2];
M.save(b, sal);
console.log('retrato:', b.geosets.length, 'geosets; cabeza en', piv.map(x => x.toFixed(1)).join(','), 'hueso', b.bones[ref.parentId].name);
