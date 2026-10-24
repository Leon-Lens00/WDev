const c=require('./model.cjs'),v=require('./vol-ii.cjs');
const core=require('/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/scripts/fallen_core.cjs');
const build=JSON.parse(c.fs.readFileSync(c.path.join(v.evidence,'build-manifest.json')));
const result={models:0,poseSamples:0,maxBodyError:0,maxEmitterError:0,maxIndependentPoseError:0,maxFlightFront:0,birthContinuous:'PASS',activeEmitterCounts:8,originals:'PASS',preservation:'PASS',dependencies:'PASS',mdl:'PASS',game:'separate check'};
function near(a,b,label='',tol=0.001){c.assert(Number.isFinite(a)&&Number.isFinite(b)&&Math.abs(a-b)<=tol,`${label}: ${a} != ${b}`);}
function anchorInvariant(model,original) {
  const m=c.plain(model);delete m.extent;delete m.pivotPoints;
  for(const g of m.geosets){delete g.vertices;delete g.extent;delete g.sequenceExtents;}
  for(const s of m.sequences)delete s.extent;
  m.bones.find(b=>b.objectId===0).animations=m.bones.find(b=>b.objectId===0).animations.filter(t=>t.name!=='KGTR');
  m.helpers=m.helpers.filter(h=>h.objectId<original.pivotPoints.length);
  for(const p of m.particleEmitters2)if([9,12].includes(p.objectId))p.parentId=4;
  return m;
}
function colorInvariant(model) {
  const m=c.plain(model);delete m.name;
  for(const g of m.geosetAnimations)delete g.color;
  for(const e of m.particleEmitters2)delete e.segmentColors;
  for(const l of m.lights){delete l.color;delete l.ambientColor;}
  for(const t of m.textures)delete t.path;
  return m;
}
function canonicalMdl(model) {
  const m=c.plain(model);
  for(const l of m.lights)l.flags&=~512;
  for(const p of m.particleEmitters2)p.flags&=~4096;
  function sort(o){if(!o||typeof o!=='object')return;if(o.animations)o.animations.sort((a,b)=>a.name.localeCompare(b.name));for(const x of Object.values(o))sort(x);}
  sort(m);return m;
}
function compare(a,b,label='') {
  if(typeof a==='number'){near(a,b,label,0.00003);return;}
  if(a&&typeof a==='object'){c.assert.deepEqual(Object.keys(a),Object.keys(b),label);for(const key of Object.keys(a))compare(a[key],b[key],label+'.'+key);}
  else c.assert.equal(a,b,label);
}
v.checkOriginals();
for(const entry of build.entries) {
  const file=c.path.join(v.root,entry.path),m=c.read(file);
  c.assert.equal(v.sha(file),entry.sha256);c.assert.equal(m.version,800);c.assert.equal(m.particleEmitters2.length,8);c.assert.equal(m.globalSequences.length,0);
  const src=c.read(c.path.join(entry.pack==='anchor'?v.source:v.anchored,entry.source));
  if(entry.pack==='anchor') {
    c.assert.deepEqual(anchorInvariant(m,src),anchorInvariant(src,src));
    c.assert.equal(m.pivotPoints.length,src.pivotPoints.length+2);
    for(let g=0;g<m.geosets.length;g++)m.geosets[g].vertices.forEach((x,i)=>near(x,src.geosets[g].vertices[i]+entry.transform.delta[i%3],'raw shift'));
    for(let id=0;id<src.pivotPoints.length;id++)m.pivotPoints[id].forEach((x,j)=>near(x,src.pivotPoints[id][j]+(entry.transform.bodyNodes.includes(id)?entry.transform.delta[j]:0),'pivot shift'));
    const clone=m.helpers.find(h=>h.objectId===15),offset=m.helpers.find(h=>h.objectId===14);
    c.assert.equal(offset.parentId,3);c.assert.equal(clone.parentId,14);
    c.assert.deepEqual(c.plain(clone.animations),c.plain(src.helpers.find(h=>h.objectId===4).animations));
  } else c.assert.deepEqual(colorInvariant(m),colorInvariant(src));
  const primary=core.nodes(core.read(file));
  const parentGeneric=new c.Generic(src,src.helpers.find(h=>h.name==='Default'),0);
  const bodyGeneric=new c.Generic(src,src.bones.find(b=>b.objectId===0),0);
  for(let si=0;si<m.sequences.length;si++)for(const t of c.frames(m,si,5)) {
    const before=c.pose(src,si,t),after=c.pose(m,si,t),seq=m.sequences[si];
    let delta=[0,0,0],extra=[0,0,0];
    if(entry.pack==='anchor') {
      const factor=new Float32Array([1,1,1]);
      if(seq.name==='Death')bodyGeneric.getScale(factor,si,t,0);
      if(seq.name==='Birth')parentGeneric.getScale(factor,si,t,0);
      delta=entry.transform.delta.map((x,j)=>x*factor[j]);
      extra=seq.name==='Death'?[0,0,0]:delta;
    }
    after.points.forEach((ps,g)=>ps.forEach((p,i)=>p.forEach((x,j)=>{
      const error=Math.abs(x-before.points[g][i][j]-delta[j]);result.maxBodyError=Math.max(result.maxBodyError,error);near(error,0,'body displacement');
      c.assert(x>=seq.extent.min[j]-0.001&&x<=seq.extent.max[j]+0.001,'body escaped sequence bounds');
    })));
    for(const e of src.particleEmitters2.concat(src.lights,src.eventObjects)) {
      const displacement=entry.pack==='anchor'&&entry.transform.bodyNodes.includes(e.objectId)?delta:entry.pack==='anchor'&&entry.transform.flightTrailIds.includes(e.objectId)?extra:[0,0,0];
      after.anchors[e.objectId].forEach((x,j)=>{const error=Math.abs(x-before.anchors[e.objectId][j]-displacement[j]);result.maxEmitterError=Math.max(result.maxEmitterError,error);near(error,0,e.name);});
    }
    if(['Stand','Birth'].includes(seq.name)){const front=c.bounds(after.points.flat()).max[0];result.maxFlightFront=Math.max(result.maxFlightFront,front);c.assert(front<=0.001,'nose passed front plane');}
    if(t===seq.interval[0]||t===seq.interval[1]) {
      const other=core.points(primary,t,primary.Sequences[si]);after.points.forEach((ps,g)=>ps.forEach((p,i)=>p.forEach((x,j)=>{const error=Math.abs(x-other[g][i][j]);result.maxIndependentPoseError=Math.max(result.maxIndependentPoseError,error);near(error,0,'independent pose');})));
    }
    result.poseSamples++;
  }
  // Continuous Birth: body translations are linear, parent scale is >=0 and
  // no scale/rotation acts inside the two-bone skin during this sequence.
  const bi=m.sequences.findIndex(s=>s.name==='Birth'),interval=m.sequences[bi].interval;
  const body=m.bones.find(b=>b.objectId===0),tail=m.bones.find(b=>b.objectId===1),parent=m.helpers.find(h=>h.objectId===3);
  c.assert.deepEqual(parent.animations.map(a=>a.name),['KGSC']);
  c.assert.equal(parent.animations[0].interpolationType,1);c.assert(parent.animations[0].values.every(v=>v.every(x=>x>=0)));
  for(const n of [body,tail])for(const tr of n.animations) {
    const keys=tr.frames.filter(t=>t>=interval[0]&&t<=interval[1]);
    if(['KGSC','KGRT'].includes(tr.name))c.assert.equal(keys.length,0);
    if(tr.name==='KGTR'){c.assert.equal(tr.interpolationType,1);c.assert.deepEqual(keys,Array.from(interval));}
  }
  for(const t of interval) {
    const a=new Float32Array(3),b=new Float32Array(3);new c.Generic(m,body,0).getTranslation(a,bi,t,0);new c.Generic(m,tail,1).getTranslation(b,bi,t,0);
    for(const g of m.geosets){let p=0;const weights=Array.from(g.matrixGroups,n=>{const ids=Array.from(g.matrixIndices.slice(p,p+n));p+=n;c.assert(ids.every(id=>id===0||id===1));return ids.filter(id=>id===1).length/n;});for(let i=0;i<g.vertexGroups.length;i++)c.assert(g.vertices[i*3]+a[0]+weights[g.vertexGroups[i]]*b[0]<=0.001);}
  }
  const mdl=new c.Model();mdl.loadMdl(c.fs.readFileSync(file.replace(/\.mdx$/,'.mdl'),'utf8'));compare(canonicalMdl(m),canonicalMdl(mdl));
  if(entry.pack==='players') {
    const rgb=v.palette[entry.color].rgb.map(x=>x/255);
    for(const color of [...m.geosetAnimations.map(g=>g.color),...m.lights.flatMap(l=>[l.color,l.ambientColor]),...m.particleEmitters2.flatMap(e=>e.segmentColors)]){
      const scale=Math.max(...color)/Math.max(...rgb);color.forEach((x,i)=>near(x,rgb[i]*scale,'color',0.000001));
    }
    for(const t of m.textures)c.assert(c.fs.existsSync(c.path.join(v.players,...t.path.split('\\'))));
  }
  result.models++;
}
v.checkOriginals();
c.fs.writeFileSync(c.path.join(v.evidence,'verification.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
