const assert = require('node:assert/strict');
const {fs, path, dependency} = require('./runtime.cjs');
const Model = dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/model').default;
const Generic = dependency('mdx-m3-viewer/dist/cjs/viewer/handlers/mdx/genericobject').default;
const {mat4, vec3} = dependency('gl-matrix');
const war3 = dependency('war3-model');
const plain = value => JSON.parse(JSON.stringify(value, (k,v) => ArrayBuffer.isView(v) ? Array.from(v) : v));
function read(file) {
  const b = fs.readFileSync(file), m = new Model();
  m.loadMdx(b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength));
  return m;
}
function allNodes(m) { return [...m.bones,...m.helpers,...m.lights,...m.particleEmitters2,...m.eventObjects]; }
function pose(m, sequence, frame) {
  const objects = new Map(allNodes(m).map((n,i)=>[n.objectId,new Generic(m,n,i)]));
  const cache = new Map();
  function world(id) {
    if(cache.has(id)) return cache.get(id);
    const n = objects.get(id); assert(n, 'Missing node '+id);
    assert(!(allNodes(m).find(x=>x.objectId===id).flags & 255), 'Unsupported inheritance/billboard');
    const t=vec3.create(), s=vec3.create(), q=new Float32Array(4);
    n.getTranslation(t,sequence,frame,0); n.getRotation(q,sequence,frame,0); n.getScale(s,sequence,frame,0);
    const local=mat4.fromRotationTranslationScaleOrigin(mat4.create(),q,t,s,n.pivot);
    if(n.parentId!==-1) mat4.multiply(local,world(n.parentId),local);
    cache.set(id,local); return local;
  }
  const points=m.geosets.map(g=>{
    let cursor=0;
    const matrices=Array.from(g.matrixGroups,count=>{
      const ids=Array.from(g.matrixIndices.slice(cursor,cursor+count)); cursor+=count;
      const a=new Float64Array(16);
      for(const id of ids) for(let j=0;j<16;j++) a[j]+=world(id)[j]/count;
      return a;
    });
    return Array.from(g.vertexGroups,(group,i)=>{
      const a=matrices[group], x=g.vertices[i*3],y=g.vertices[i*3+1],z=g.vertices[i*3+2];
      return [a[0]*x+a[4]*y+a[8]*z+a[12],a[1]*x+a[5]*y+a[9]*z+a[13],a[2]*x+a[6]*y+a[10]*z+a[14]];
    });
  });
  const anchors=Object.fromEntries(allNodes(m).map(n=>[n.objectId,Array.from(vec3.transformMat4(vec3.create(),m.pivotPoints[n.objectId],world(n.objectId)))]));
  return {points,anchors};
}
function bounds(points) {
  const min=[Infinity,Infinity,Infinity],max=[-Infinity,-Infinity,-Infinity];
  for(const p of points) p.forEach((v,i)=>{assert(Number.isFinite(v));min[i]=Math.min(min[i],v);max[i]=Math.max(max[i],v);});
  return {min,max,boundsRadius:Math.hypot(...min.map((v,i)=>Math.max(Math.abs(v),Math.abs(max[i]))))};
}
function assignBounds(target,points) {
  const b=bounds(points); target.min.set(b.min);target.max.set(b.max);target.boundsRadius=Math.fround(b.boundsRadius);
}
function frames(m,seq,step=5) {
  const [a,b]=m.sequences[seq].interval, times=new Set([a,b]);
  for(let t=a;t<b;t+=step) times.add(t);
  for(const n of allNodes(m)) for(const tr of n.animations) for(const t of tr.frames) if(t>=a&&t<=b) times.add(t);
  return [...times].sort((x,y)=>x-y);
}
function save(m,file) {
  fs.mkdirSync(path.dirname(file),{recursive:true});
  const b=Buffer.from(m.saveMdx());
  const reader=new Model();reader.loadMdx(b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength));
  assert.deepEqual(plain(reader),plain(m),'MDX roundtrip');
  const other=war3.parseMDX(b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength));
  assert.equal(other.Version,800);assert.equal(other.ParticleEmitters2.length,m.particleEmitters2.length);
  assert.equal(other.EventObjects.length,m.eventObjects.length);
  for(let i=0;i<m.geosets.length;i++) assert.deepEqual(Array.from(other.Geosets[i].Vertices),Array.from(m.geosets[i].vertices));
  const text=m.saveMdl(); const textReader=new Model(); textReader.loadMdl(text);
  // The independent MDL exporter may round decimals. Verify both parser paths, allowing float formatting only.
  const textOther=war3.parseMDL(text);assert.equal(textOther.Version,800);
  assert.equal(textOther.ParticleEmitters2.length,m.particleEmitters2.length);
  fs.writeFileSync(file,b);fs.writeFileSync(file.replace(/\.mdx$/,'.mdl'),text);
  return reader;
}
module.exports={assert,fs,path,dependency,Model,Generic,plain,read,allNodes,pose,bounds,assignBounds,frames,save};
