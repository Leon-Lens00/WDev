// v21f (22/11/2026): retrato de Goku de D.O.N 2.1a con cabeza.
// En 2.1a la cabeza es otro modelo (NormalHeadGoku.mdx) que la habilidad A069 (AId5) cuelga del punto "head"; el
// retrato no dibuja lo colgado, así que salía sin cabeza (captura de Leon). 2.1a usaba de retrato un plano con el icono.
// Se copia Goku21.mdx y se le añade la geometría de la cabeza base: vértices + pivote de "Head Ref" del cuerpo, todos
// pegados a Bone_Head (el padre de Head Ref), con su textura y material. Sólo la cabeza base: el retrato no cambia
// de cabeza con la forma.
// Uso: node retrato_goku21.cjs CUERPO.mdx CABEZA.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [fc, fh, sal] = process.argv.slice(2);
const b = M.read(fc), h = M.read(fh);
const ref = b.attachments.find(a => a.name === 'Head Ref');
M.assert(ref && b.bones[ref.parentId] && b.bones[ref.parentId].name === 'Bone_Head', 'Head Ref cuelga de Bone_Head');
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
M.save(b, sal);
console.log('retrato:', b.geosets.length, 'geosets; cabeza en', piv.map(x => x.toFixed(1)).join(','), 'hueso', b.bones[ref.parentId].name);
