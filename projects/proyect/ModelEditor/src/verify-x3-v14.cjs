const k=require('./x3-effect-kit-v14.cjs'),{c}=k,crypto=require('node:crypto');
const build=JSON.parse(c.fs.readFileSync(c.path.join(k.ev,'build.json'))),reports=[];
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
global.ImageData=class{constructor(w,h){this.width=w;this.height=h;this.data=new Uint8ClampedArray(w*h*4);}};
const {BlpImage}=c.dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image');
for(const e of build.entries){
 const file=c.path.join(k.root,e.path),m=c.read(file),raw=c.fs.readFileSync(file),other=c.dependency('war3-model').parseMDX(raw.buffer.slice(raw.byteOffset,raw.byteOffset+raw.byteLength));
 c.assert.equal(m.version,800);c.assert.equal(other.Geosets.length,m.geosets.length);c.assert.equal(other.ParticleEmitters2.length,m.particleEmitters2.length);
 c.assert.equal(sha(raw),e.sha256);
 const nodes=[...m.bones,...m.lights,...m.helpers,...m.attachments,...m.particleEmitters,...m.particleEmitters2,...m.ribbonEmitters,...m.eventObjects,...m.collisionShapes];
 c.assert.deepEqual(nodes.map(n=>n.objectId),nodes.map((_,i)=>i));c.assert.equal(m.bones[0].animations.length,0);c.assert.deepEqual(Array.from(m.pivotPoints[0]),[0,0,0]);
 for(const o of [...nodes,...m.geosetAnimations,...m.textureAnimations,...m.materials.flatMap(x=>x.layers)])for(const a of o.animations||[]){for(let i=0;i<a.frames.length;i++){if(i)c.assert(a.frames[i]>a.frames[i-1]);for(const v of a.values[i])c.assert(Number.isFinite(v));}}
 for(const mat of m.materials)for(const l of mat.layers){c.assert(l.textureId>=0&&l.textureId<m.textures.length);c.assert(l.textureAnimationId===-1||l.textureAnimationId<m.textureAnimations.length);c.assert([3,4].includes(l.filterMode));}
 for(const g of m.geosets){for(const i of g.faces)c.assert(i<g.vertices.length/3);for(const i of g.matrixIndices)c.assert(i<nodes.length);c.assert.equal(g.uvSets[0].length,g.vertices.length/3*2);c.assert.equal(g.sequenceExtents.length,3);}
 const detail=build.details[e.name],flash=e.name.includes('Flash'),ids=flash?[]:detail?.flightGeosets||[...Array(detail?.flightCount||52).keys()];
 let poses=0,minX=Infinity,maxX=-Infinity;
 for(let si=0;si<3;si++)for(const t of c.frames(m,si,10)){
  const p=c.pose(m,si,t,t);c.assert.deepEqual(p.anchors[0],[0,0,0]);
  for(let j=0;j<p.points.length;j++)for(const v of p.points[j]){for(let d=0;d<3;d++)c.assert(Number.isFinite(v[d])&&v[d]>=m.sequences[si].extent.min[d]-.001&&v[d]<=m.sequences[si].extent.max[d]+.001);if(ids.includes(j)){minX=Math.min(minX,v[0]);maxX=Math.max(maxX,v[0]);}}
  poses++;
 }
 if(!flash)c.assert(maxX<=.001,'front exceeds origin: '+e.name+' '+maxX);
 function scalar(o,key,si,t){const out=new Float32Array(1);new c.Generic(m,o,0).getScalarValue(out,key,si,t,0,0);return out[0];}
 for(const ga of m.geosetAnimations)c.assert.equal(scalar(ga,'KGAO',2,m.sequences[2].interval[1]),0);
 if(!flash){const body=m.bones.find(n=>n.name.startsWith('Flight body'));c.assert.deepEqual(Array.from(body.animations[0].values.at(-1)),[1,1,1]);for(const id of ids)c.assert.equal(scalar(m.geosetAnimations[id],'KGAO',2,1610),0);}
 const textures=[];
 for(const tex of m.textures){const p=c.path.join(c.path.dirname(file),...tex.path.split('\\')),b=c.fs.readFileSync(p);c.assert.equal(b.toString('ascii',0,4),'BLP1');if(b.readUInt32LE(4)===1){c.assert.equal(b.readUInt32LE(8),8);c.assert.equal(b.readUInt32LE(20),4);c.assert.equal(b.readUInt32LE(24),1);}const im=new BlpImage();im.load(b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength));let mip=0;while(mip<16&&b.readUInt32LE(28+mip*4)){const d=im.getMipmap(mip);c.assert(d.width>0);mip++;}textures.push({path:tex.path,mips:mip,sha256:sha(b)});}
 const mdl=new c.Model();mdl.loadMdl(c.fs.readFileSync(file.replace('.mdx','.mdl'),'utf8'));c.assert.equal(mdl.geosets.length,m.geosets.length);for(let i=0;i<m.geosets.length;i++)for(let j=0;j<m.geosets[i].vertices.length;j++)c.assert(Math.abs(m.geosets[i].vertices[j]-mdl.geosets[i].vertices[j])<1e-4);
 reports.push({name:e.name,sha256:sha(raw),status:'PASS',poses,flightX:flash?null:[minX,maxX],rootFixed:true,finiteFlash:flash,deathBodyContraction:false,textures});
}
require('./verify-x3-wave-v14.cjs')(k,build);
const baseline=JSON.parse(c.fs.readFileSync(c.path.join(k.ev,'bases-preservadas.json')));let preserved=0;
// The snapshot stores absolute files, so no resource outside the baseline is inferred.
for(const [p,hash] of Object.entries(baseline)){c.assert.equal(sha(c.fs.readFileSync(p)),hash,p);preserved++;}
const report={status:'PASS',independentReader:'war3-model 4.0.1',models:reports,preservedFiles:preserved,limitations:'Structure, BLP mips and poses; native and visual evidence separate.'};
c.fs.writeFileSync(c.path.join(k.ev,'verification.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({status:report.status,models:reports.map(r=>({name:r.name,poses:r.poses,flightX:r.flightX})),preservedFiles:preserved}));
