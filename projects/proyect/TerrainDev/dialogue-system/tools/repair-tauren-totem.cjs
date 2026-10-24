// Restore the full unit's team-color material on the portrait's existing closed totem.
const assert=require('node:assert/strict');
const {read}=require('../../../ModelEditor/src/model.cjs');
function repairTotem(model,unitFile){
 const unit=read(unitFile),sourceMaterial=unit.materials[1],textureMap=new Map();
 const material=Object.assign(Object.create(Object.getPrototypeOf(sourceMaterial)),sourceMaterial);
 material.layers=sourceMaterial.layers.map(layer=>{
  const copy=Object.assign(Object.create(Object.getPrototypeOf(layer)),layer),texture=unit.textures[layer.textureId];
  let target=model.textures.findIndex(t=>t.path===texture.path&&t.replaceableId===texture.replaceableId);
  if(target<0){target=model.textures.length;model.textures.push(texture);}
  copy.textureId=target;return copy;
 });
 assert.equal(material.layers.length,2);assert.equal(model.textures[material.layers[0].textureId].replaceableId,1);
 const materialId=model.materials.length;model.materials.push(material);
 const body=model.geosets[0];let cursor=0;
 const groups=Array.from(body.matrixGroups,count=>{const ids=Array.from(body.matrixIndices.slice(cursor,cursor+count));cursor+=count;return ids;});
 const owns=i=>groups[body.vertexGroups[i]].length===1&&groups[body.vertexGroups[i]][0]===23;
 const kept=[],totem=[];
 for(let i=0;i<body.faces.length;i+=3){const tri=Array.from(body.faces.slice(i,i+3));if(tri.every(owns))totem.push(...tri);else kept.push(...tri);}
 assert.equal(totem.length,42,'Original complete totem: 14 triangles');
 const used=[...new Set(totem)],index=new Map(used.map((v,i)=>[v,i])),g=Object.assign(Object.create(Object.getPrototypeOf(body)),body);
 g.vertices=new Float32Array(used.flatMap(i=>Array.from(body.vertices.slice(i*3,i*3+3))));g.normals=new Float32Array(used.flatMap(i=>Array.from(body.normals.slice(i*3,i*3+3))));g.uvSets=body.uvSets.map(uv=>new Float32Array(used.flatMap(i=>Array.from(uv.slice(i*2,i*2+2)))));g.vertexGroups=new Uint8Array(used.length);g.matrixGroups=new Uint32Array([1]);g.matrixIndices=new Uint32Array([23]);g.faces=new Uint16Array(totem.map(v=>index.get(v)));g.faceGroups=new Uint32Array([totem.length]);g.faceTypeGroups=new Uint32Array([4]);g.materialId=materialId;
 // A missing wall would leave boundary edges after welding UV seams.
 const keys=new Map(),weld=used.map(i=>{const key=Array.from(body.vertices.slice(i*3,i*3+3),v=>v.toFixed(3)).join(',');if(!keys.has(key))keys.set(key,keys.size);return keys.get(key);}),edges=new Map();
 for(let i=0;i<g.faces.length;i+=3)for(let j=0;j<3;j++){const a=weld[g.faces[i+j]],b=weld[g.faces[i+(j+1)%3]],key=[a,b].sort((a,b)=>a-b).join(',');edges.set(key,(edges.get(key)||0)+1);}
 assert(Array.from(edges.values()).every(v=>v===2),'Totem is watertight');
 body.faces=new Uint16Array(kept);body.faceGroups=new Uint32Array([kept.length]);model.geosets.push(g);
 return {kind:'restore full-unit totem material',geometryAdded:false,triangles:14,weldedVertices:keys.size,boundaryEdges:0,sourceUnit:unitFile,materialLayers:2,teamColorBase:true};
}
module.exports={repairTotem};
