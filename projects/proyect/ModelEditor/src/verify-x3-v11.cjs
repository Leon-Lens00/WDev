const k=require('./x3-effect-kit-v11.cjs'),{c}=k,crypto=require('node:crypto');
const build=JSON.parse(c.fs.readFileSync(c.path.join(k.ev,'build.json'))),file=c.path.join(k.root,build.entries[0].path),m=c.read(file),prev=c.read(c.path.join(k.root,'exports/megaman-x3-buster-v10/A-Buster/X3_Buster_Cargado.mdx'));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const raw=c.fs.readFileSync(file),other=c.dependency('war3-model').parseMDX(raw.buffer.slice(raw.byteOffset,raw.byteOffset+raw.byteLength));
c.assert.equal(m.version,800);c.assert.equal(other.Geosets.length,m.geosets.length);c.assert.equal(other.ParticleEmitters2.length,m.particleEmitters2.length);c.assert.equal(other.RibbonEmitters.length,1);
const nodes=[...m.bones,...m.lights,...m.helpers,...m.attachments,...m.particleEmitters,...m.particleEmitters2,...m.ribbonEmitters,...m.eventObjects,...m.collisionShapes];
c.assert.deepEqual(nodes.map(n=>n.objectId),nodes.map((_,i)=>i));c.assert.equal(m.bones[0].animations.length,0);c.assert.deepEqual(Array.from(m.pivotPoints[0]),[0,0,0]);
for(const o of [...nodes,...m.geosetAnimations,...m.textureAnimations,...m.materials.flatMap(x=>x.layers)])for(const a of o.animations||[]){c.assert.equal(a.globalSequenceId,-1);for(let i=0;i<a.frames.length;i++){if(i)c.assert(a.frames[i]>a.frames[i-1]);for(const v of a.values[i])c.assert(Number.isFinite(v));}}
for(const mat of m.materials)for(const l of mat.layers){c.assert(l.textureId>=0&&l.textureId<m.textures.length);c.assert(l.textureAnimationId===-1||l.textureAnimationId<m.textureAnimations.length);}
for(const g of m.geosets){for(const i of g.faces)c.assert(i<g.vertices.length/3);for(const i of g.matrixIndices)c.assert(i<nodes.length);c.assert.equal(g.uvSets[0].length,g.vertices.length/3*2);}
for(let i=0;i<18;i++){c.assert.deepEqual(m.geosets[i].vertices,prev.geosets[i].vertices,'blue geometry preserved');c.assert.deepEqual(m.geosets[i].uvSets,prev.geosets[i].uvSets);c.assert.deepEqual(m.geosets[i].faces,prev.geosets[i].faces);}
let poses=0,minX=Infinity,maxFlightX=-Infinity;
for(let si=0;si<3;si++)for(const t of c.frames(m,si,5)){const p=c.pose(m,si,t);c.assert.deepEqual(p.anchors[0],[0,0,0]);for(let j=0;j<p.points.length;j++)for(const v of p.points[j]){for(let d=0;d<3;d++)c.assert(v[d]>=m.sequences[si].extent.min[d]-.001&&v[d]<=m.sequences[si].extent.max[d]+.001);if(j<48){minX=Math.min(minX,v[0]);maxFlightX=Math.max(maxFlightX,v[0]);}}poses++;}
c.assert(maxFlightX<.0001);
const body=m.bones.find(n=>n.name.startsWith('Flight body'));
const scale=body.animations[0];c.assert.deepEqual(Array.from(scale.values.at(-1)),[1,1,1]);
function scalar(o,key,si,t){const out=new Float32Array(1);new c.Generic(m,o,0).getScalarValue(out,key,si,t,0,0);return out[0];}
for(const ga of m.geosetAnimations.slice(0,48)){c.assert.equal(scalar(ga,'KGAO',2,1590),0);c.assert.equal(scalar(ga,'KGAO',2,2500),0);}
for(const p of m.particleEmitters2.slice(0,11)){c.assert(scalar(p,'KP2E',1,600)>0);c.assert.equal(scalar(p,'KP2E',2,1500),0);}
const bursts=m.particleEmitters2.slice(11);for(const p of bursts){c.assert.equal(scalar(p,'KP2E',1,600),0);c.assert(scalar(p,'KP2E',2,1600)>0);c.assert.equal(scalar(p,'KP2E',2,1800),0);c.assert.equal(p.segmentAlphas[2],0);c.assert(p.lifeSpan<.5);}
const pulse=build.pulse,at=(a,t)=>{let i=0;while(i+1<a.frames.length&&a.frames[i+1]<=t)i++;let j=Math.min(i+1,a.frames.length-1),u=j===i?0:(t-a.frames[i])/(a.frames[j]-a.frames[i]);return a.values[i][0]*(1-u)+a.values[j][0]*u;};
for(const [index,period] of [[pulse.textureAnimation,240],...pulse.arcAnimations.map(i=>[i,120])]){const a=m.textureAnimations[index].animations[0];for(const t of [425,460,490])c.assert(Math.abs(at(a,t)-at(a,t+period))<1e-5);}
global.ImageData=class{constructor(w,h){this.width=w;this.height=h;this.data=new Uint8ClampedArray(w*h*4);}};
const {BlpImage}=c.dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image'),texReport=[];
for(const tex of m.textures){const p=c.path.join(c.path.dirname(file),...tex.path.split('\\')),b=c.fs.readFileSync(p);c.assert.equal(b.toString('ascii',0,4),'BLP1');if(b.readUInt32LE(4)===1){c.assert.equal(b.readUInt32LE(8),8);c.assert.equal(b.readUInt32LE(20),4);c.assert.equal(b.readUInt32LE(24),1);}else{c.assert.equal(b.readUInt32LE(4),0);c.assert.equal(sha(b),sha(c.fs.readFileSync(c.path.join(k.root,'assets/x3-v10',c.path.basename(p)))));}const im=new BlpImage();im.load(b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength));let mip=0;while(mip<16&&b.readUInt32LE(28+mip*4)){const d=im.getMipmap(mip);c.assert(d.width>0);mip++;}texReport.push({file:tex.path,mips:mip,sha256:sha(b)});}
const mdl=new c.Model();mdl.loadMdl(c.fs.readFileSync(file.replace('.mdx','.mdl'),'utf8'));c.assert.equal(mdl.geosets.length,m.geosets.length);for(let i=0;i<m.geosets.length;i++)for(let j=0;j<m.geosets[i].vertices.length;j++)c.assert(Math.abs(m.geosets[i].vertices[j]-mdl.geosets[i].vertices[j])<1e-4);
const report={sha256:sha(raw),status:'PASS',target:'MDX800 / Classic 1.27b',independentReader:'war3-model 4.0.1',poses,rootFixed:true,blueGeometryAndUVPreserved:18,flightX:[minX,maxFlightX],deathBodyFadeMs:90,deathContraction:false,impactEmitters:bursts.length,seq:m.sequences.map(s=>({name:s.name,interval:Array.from(s.interval)})),pinkPeriodMs:240,greenPeriodMs:120,textures:texReport,limitations:'Structure, decoded textures and sampled local poses; visual and native execution documented separately.'};
c.fs.writeFileSync(c.path.join(k.ev,'verification.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify({...report,textures:texReport.length}));
