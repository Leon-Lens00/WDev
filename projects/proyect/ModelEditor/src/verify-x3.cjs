const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),ev=c.path.join(root,'evidence/x3-v1');
const entries=JSON.parse(c.fs.readFileSync(c.path.join(ev,'build.json'))).entries;
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
global.ImageData=class {constructor(w,h){this.width=w;this.height=h;this.data=new Uint8ClampedArray(w*h*4);}};
const {BlpImage}=c.dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image');
const textures=JSON.parse(c.fs.readFileSync(c.path.join(ev,'textures.json')));
for(const t of textures){const b=c.fs.readFileSync(c.path.join(root,'assets/x3-v1',t.file));const image=new BlpImage();image.load(b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength));const level=image.getMipmap(0);c.assert.equal(sha(level.data),t.rgbaSha256);for(let i=0;i<t.mips;i++){const l=image.getMipmap(i);c.assert.equal(l.width,Math.max(1,t.size>>i));c.assert.equal(l.height,l.width);}t.independentM3Decode='PASS';}
const result=[];
for(const e of entries){const file=c.path.join(root,e.path),m=c.read(file),flight=!e.name.includes('Flash');let tested=0,maxX=-Infinity,minX=Infinity;
 c.assert.equal(m.version,800);c.assert.deepEqual(Array.from(m.pivotPoints[0]),[0,0,0]);c.assert.equal(m.bones[0].parentId,-1);
 c.assert(!m.bones[0].animations.some(a=>a.name==='KGTR'),'root translation');
 const ids=c.allNodes(m).map(n=>n.objectId);c.assert.equal(new Set(ids).size,ids.length);for(const n of c.allNodes(m)){c.assert(n.parentId===-1||ids.includes(n.parentId));for(const a of n.animations){c.assert.equal(a.globalSequenceId,-1);for(const v of a.values)for(const x of v)c.assert(Number.isFinite(x));}}
 for(const g of m.geosets){c.assert.equal(g.vertices.length/3,g.vertexGroups.length);c.assert.equal(g.uvSets[0].length,g.vertexGroups.length*2);for(const i of g.faces)c.assert(i<g.vertexGroups.length);for(const i of g.matrixIndices)c.assert(ids.includes(i));}
 for(let si=0;si<3;si++)for(const f of c.frames(m,si,5)){const p=c.pose(m,si,f);c.assert.deepEqual(p.anchors[0],[0,0,0]);for(const geo of p.points)for(const v of geo){maxX=Math.max(maxX,v[0]);minX=Math.min(minX,v[0]);for(let i=0;i<3;i++)c.assert(v[i]>=m.sequences[si].extent.min[i]-.001&&v[i]<=m.sequences[si].extent.max[i]+.001,'bounds');}tested++;}
 if(flight)c.assert(maxX<.0001,'geometry passes tip');
 for(const t of m.textures)c.assert(c.fs.existsSync(c.path.join(c.path.dirname(file),...t.path.split('\\'))));
 for(const ga of m.geosetAnimations){const a=ga.animations.find(a=>a.name==='KGAO');c.assert.equal(a.values.at(-1)[0],0);}
 const text=new c.Model();text.loadMdl(c.fs.readFileSync(file.replace('.mdx','.mdl'),'utf8'));c.assert.equal(text.geosets.length,m.geosets.length);for(let i=0;i<m.geosets.length;i++)for(let j=0;j<m.geosets[i].vertices.length;j++)c.assert(Math.abs(m.geosets[i].vertices[j]-text.geosets[i].vertices[j])<.0001);
 if(e.name==='X3_Grupo_Orbital'){const emit=m.particleEmitters2[0];const samples=[200,400,600,800,1000].map(f=>c.pose(m,1,f).anchors[emit.objectId]);for(const p of samples){c.assert(Math.abs(p[0]+13)<.001);c.assert(Math.abs(Math.hypot(p[1],p[2])-26)<.001);}c.assert(Math.abs(samples[0][1]-samples[1][1])>20);}
 result.push({name:e.name,posesSampled:tested,geometryX:[minX,maxX],frontAtOrigin:flight?'PASS':'impact expansion around origin',rootAtOrigin:'PASS',dependencies:'PASS',birthStandDeath:'structure and pose PASS',mdlGeometry:'PASS',binaryAndIndependentReaders:'PASS in build'});
}
c.fs.writeFileSync(c.path.join(ev,'verification.json'),JSON.stringify({models:result,textures,limits:'No world physics or multiplayer tests; visual runtime checked separately.'},null,2)+'\n');console.log(JSON.stringify(result));
