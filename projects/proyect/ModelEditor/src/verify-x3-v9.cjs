const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),ev=c.path.join(root,'evidence/x3-v9');
const entries=JSON.parse(c.fs.readFileSync(c.path.join(ev,'build.json'))).entries;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
global.ImageData=class {constructor(w,h){this.width=w;this.height=h;this.data=new Uint8ClampedArray(w*h*4);}};
const {BlpImage}=c.dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image');
const textures=JSON.parse(c.fs.readFileSync(c.path.join(ev,'textures.json')));
for(const t of textures){const b=c.fs.readFileSync(c.path.join(root,'assets/x3-v9',t.file));const image=new BlpImage();image.load(b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength));const level=image.getMipmap(0);c.assert.equal(sha(level.data),t.rgbaSha256);for(let i=0;i<t.mips;i++){const l=image.getMipmap(i);c.assert.equal(l.width,Math.max(1,t.size>>i));c.assert.equal(l.height,l.width);}t.independentM3Decode='PASS';}
c.assert.equal(entries.length,1);const result=[];
for(const e of entries){const file=c.path.join(root,e.path),m=c.read(file),flight=!e.name.includes('Flash');let tested=0,maxX=-Infinity,minX=Infinity;
 c.assert.equal(m.version,800);for(const mat of m.materials)for(const l of mat.layers){c.assert(l.textureId<m.textures.length);c.assert(l.textureAnimationId===-1||l.textureAnimationId<m.textureAnimations.length);}for(const ta of m.textureAnimations)for(const a of ta.animations)c.assert.equal(a.globalSequenceId,-1);c.assert.deepEqual(Array.from(m.pivotPoints[0]),[0,0,0]);c.assert.equal(m.bones[0].parentId,-1);
 c.assert(!m.bones[0].animations.some(a=>a.name==='KGTR'),'root translation');
 const nodes=[...m.bones,...m.lights,...m.helpers,...m.attachments,...m.particleEmitters,...m.particleEmitters2,...m.ribbonEmitters,...m.eventObjects,...m.collisionShapes];nodes.forEach((n,i)=>c.assert.equal(n.objectId,i,'canonical serialized node order'));const ids=nodes.map(n=>n.objectId);c.assert.equal(new Set(ids).size,ids.length);for(const n of c.allNodes(m)){c.assert(n.parentId===-1||ids.includes(n.parentId));for(const a of n.animations){c.assert.equal(a.globalSequenceId,-1);for(const v of a.values)for(const x of v)c.assert(Number.isFinite(x));}}
 for(const g of m.geosets){c.assert.equal(g.vertices.length/3,g.vertexGroups.length);c.assert.equal(g.uvSets[0].length,g.vertexGroups.length*2);for(const i of g.faces)c.assert(i<g.vertexGroups.length);for(const i of g.matrixIndices)c.assert(ids.includes(i));}
 for(let si=0;si<3;si++)for(const f of c.frames(m,si,5)){const p=c.pose(m,si,f);c.assert.deepEqual(p.anchors[0],[0,0,0]);for(const geo of p.points)for(const v of geo){maxX=Math.max(maxX,v[0]);minX=Math.min(minX,v[0]);for(let i=0;i<3;i++)c.assert(v[i]>=m.sequences[si].extent.min[i]-.001&&v[i]<=m.sequences[si].extent.max[i]+.001,'bounds');}tested++;}
 if(flight)c.assert(maxX<.0001,'geometry passes tip');
 if(flight){const wake=m.particleEmitters2.filter(p=>p.lifeSpan>.15&&!(p.flags&0x80000));c.assert(wake.length>=1,'continuous wake required');for(const p of wake){c.assert(p.speed>0||p.textureId===6);const g=new c.Generic(m,p,0),v=new Float32Array(1);for(const t of [201,440,680,1159]){g.getScalarValue(v,'KP2E',1,t,0,0);c.assert(v[0]>0,'continuous stand emission');}g.getScalarValue(v,'KP2E',2,1310,0,0);c.assert.equal(v[0],0,'wake stops in Death');}}const raw=c.fs.readFileSync(file);const other=c.dependency('war3-model').parseMDX(raw.buffer.slice(raw.byteOffset,raw.byteOffset+raw.byteLength));c.assert.equal(other.RibbonEmitters.length,m.ribbonEmitters.length);for(const r of m.ribbonEmitters){c.assert(ids.includes(r.parentId));c.assert(r.materialId<m.materials.length);c.assert(r.lifeSpan>0&&r.lifeSpan<.3);const v=r.animations.find(a=>a.name==='KRVS');c.assert.equal(v.values.at(-1)[0],0);}
 for(const t of m.textures)c.assert(c.fs.existsSync(c.path.join(c.path.dirname(file),...t.path.split('\\'))));
 for(const ga of m.geosetAnimations){const a=ga.animations.find(a=>a.name==='KGAO');c.assert.equal(a.values.at(-1)[0],0);}
 const text=new c.Model();text.loadMdl(c.fs.readFileSync(file.replace('.mdx','.mdl'),'utf8'));c.assert.equal(text.geosets.length,m.geosets.length);for(let i=0;i<m.geosets.length;i++)for(let j=0;j<m.geosets[i].vertices.length;j++)c.assert(Math.abs(m.geosets[i].vertices[j]-text.geosets[i].vertices[j])<.0001);
 if(e.name==='X3_Grupo_Orbital'){c.assert.equal(m.particleEmitters2.length,8,'two original orbs');c.assert.equal(m.ribbonEmitters.length,2);const emit=m.particleEmitters2[0];const samples=[200,440,680,920,1160].map(f=>c.pose(m,1,f).anchors[emit.objectId]);for(const p of samples){c.assert(Math.abs(p[0]+7.5)<.001);c.assert(Math.abs(Math.hypot(p[1],p[2])-23)<.001);}c.assert(Math.abs(samples[0][1]-samples[1][1])>20);}
 if(e.name==='X3_Flash_Union'){for(const p of m.particleEmitters2){c.assert.equal(p.squirt,1);const g=new c.Generic(m,p,0);for(const [si,t] of [[0,16.7],[1,516.7],[2,1116.7]]){const v=new Float32Array(1);g.getScalarValue(v,'KP2E',si,t,0,0);c.assert(v[0]>0,'flash first simulation step skipped burst');}}}
 result.push({name:e.name,canonicalNodeOrder:'PASS',ribbonReaderAndVisibility:'PASS',posesSampled:tested,geometryX:[minX,maxX],frontAtOrigin:flight?'PASS':'impact expansion around origin',rootAtOrigin:'PASS',dependencies:'PASS',birthStandDeath:'structure and pose PASS',mdlGeometry:'PASS',binaryAndIndependentReaders:'PASS in build'});
}
const file=c.path.join(root,entries[0].path),full=c.read(file),pulse=JSON.parse(c.fs.readFileSync(c.path.join(ev,'pulse.json')));
c.assert.equal(full.geosets.length-5,pulse.geoset);
const uv=full.textureAnimations[pulse.textureAnimation].animations[0];
const samples=[];
function at(a,t){let i=0;while(i+1<a.frames.length&&a.frames[i+1]<=t)i++;const j=Math.min(i+1,a.frames.length-1),mix=j===i?0:(t-a.frames[i])/(a.frames[j]-a.frames[i]);return a.values[i][0]*(1-mix)+a.values[j][0]*mix;}
for(const t of [250,290,330,370]){const u=at(uv,t),rearProgress=.5-u;samples.push({time:t,rearProgress});c.assert(rearProgress>=0&&rearProgress<=1.0);for(const dt of [240,480,720])c.assert(Math.abs(at(uv,t)-at(uv,t+dt))<1e-5,'repeat period');}
c.assert(samples.every((s,i)=>i===0||s.rearProgress>samples[i-1].rearProgress),'light must move to the rear');
const extra=full.geosetAnimations.filter(g=>g.geosetId>=pulse.geoset);
for(const ga of extra){const alpha=ga.animations[0];for(const t of [0,160,200,420,440,660,680,900,920,1140,1160,1300,1720])c.assert.equal(at(alpha,t),0,'hidden between sweeps and in Birth/Death');for(let i=1;i<alpha.frames.length;i++)c.assert(alpha.frames[i]>alpha.frames[i-1]);}
// Removing only the additive pulse reconstructs the previous MDX byte for byte.
full.geosets.splice(pulse.geoset);full.geosetAnimations.splice(pulse.geoset);full.materials.pop();full.textures.pop();full.textureAnimations.pop();
for(const t of full.textures)t.path=t.path.replace('X3BusterV9','X3BusterV7');
const old=c.fs.readFileSync(c.path.join(root,'exports/megaman-x3-buster-v7/A-Buster/X3_Buster_Cargado.mdx'));
c.assert(Buffer.from(full.saveMdx()).equals(old),'V7 body, pink envelope and particles changed');
const originals=JSON.parse(c.fs.readFileSync(c.path.join(ev,'v7-input-hashes.json')));for(const [p,h] of Object.entries(originals))c.assert.equal(sha(c.fs.readFileSync(p)),h,'V7 file changed: '+p);
const v8=JSON.parse(c.fs.readFileSync(c.path.join(ev,'v8-input-hashes.json')));for(const [p,h] of Object.entries(v8))c.assert.equal(sha(c.fs.readFileSync(p)),h,'V8 file changed');
const pulseCheck={samples,periodMs:240,cyclesPerStand:4,oldModelReconstruction:'byte-identical V7',v7FilesPreserved:Object.keys(originals).length,v8FilesPreserved:Object.keys(v8).length,birthDeathPulseHidden:'PASS'};
c.fs.writeFileSync(c.path.join(ev,'verification.json'),JSON.stringify({models:result,textures,pulseCheck,limits:'No world physics or multiplayer tests; visual runtime checked separately.'},null,2)+'\n');console.log(JSON.stringify({models:result,pulseCheck}));
