const {read,allNodes}=require('../../../ModelEditor/src/model.cjs');
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const root=path.resolve(__dirname,'..'),registry=JSON.parse(fs.readFileSync(root+'/evidence/portrait-registry.json')),result={};
for(const [name,reg]of Object.entries(registry)){
 const file=root+'/assets/'+reg.file.replaceAll('\\','/'),m=read(file);let tracks=0,minDepth=Infinity,maxDepth=-Infinity;
 assert.equal(m.blendTime,200,`${name}: portrait blend time`);
 for(const n of allNodes(m))for(const t of n.animations){tracks++;for(let i=1;i<t.frames.length;i++)assert(t.frames[i]>t.frames[i-1],`${name} ${n.name} ${t.name}: unordered/duplicate frames`);}
 // Evaluate every exported vertex translation key against the actual backing plane.
 for(const g of m.geosets){let cursor=0;const groups=Array.from(g.matrixGroups,count=>{const ids=Array.from(g.matrixIndices.slice(cursor,cursor+count));cursor+=count;return ids;});
  for(let i=0;i<g.vertices.length;i+=3){const bone=m.bones.find(n=>n.objectId===groups[g.vertexGroups[i/3]][0]),track=bone.animations.find(t=>t.name==='KGTR');
   for(const value of track?.values??[[0,0,0]]){const x=g.vertices[i]+value[0];minDepth=Math.min(minDepth,-2+1.4*x);maxDepth=Math.max(maxDepth,-2+1.4*x);}}
 }
 assert(minDepth>-2.75,`${name}: gray backing occludes the model`);assert(maxDepth<-.25,`${name}: model crosses the front frame`);
 for(const v of reg.idleVariants){assert.equal(m.sequences[v.index].name,v.name);assert.equal(m.sequences[v.index].interval[1]-m.sequences[v.index].interval[0],v.durationMs);assert(!/talk/i.test(v.name));assert(reg.sequenceMotion[v.index]>.0001,'Static clip in automatic idle cycle');}
 for(const s of m.sequences)assert.equal(s.nonLooping,0,`${name}: sequence must loop`);
 for(let i=1;i<m.sequences.length;i++)assert(m.sequences[i].interval[0]>m.sequences[i-1].interval[1],`${name}: sequence intervals must be chronological and disjoint`);
 const declared=new Set();for(const n of allNodes(m)){assert(n.parentId===-1||declared.has(n.parentId),`${name}: parent must precede child`);declared.add(n.objectId);}
 for(const g of m.geosets){assert(g.matrixGroups.length<=256);assert.equal(Array.from(g.faceGroups).reduce((a,b)=>a+b,0),g.faces.length);assert(Array.from(g.faces).every(v=>v<g.vertices.length/3));}
 for(const t of m.textures)if(t.path)assert(fs.existsSync(root+'/assets/'+t.path.replaceAll('\\','/')),'Missing '+t.path);
 result[name]={blendTimeMs:m.blendTime,tracks,chronological:true,depthAtMaximumEditorScale:[minDepth,maxDepth],idleVariants:reg.idleVariants.length,sequences:m.sequences.length,nodes:allNodes(m).length,geosets:m.geosets.length};
}
fs.writeFileSync(root+'/evidence/portrait-validation.json',JSON.stringify(result,null,2));console.log(result);
