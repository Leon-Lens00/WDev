const c=require('./model.cjs');
const root=c.path.resolve(__dirname,'..'),project=c.path.dirname(root);
const manifest=JSON.parse(c.fs.readFileSync(c.path.join(root,'evidence/build-manifest.json')));
const palette=JSON.parse(c.fs.readFileSync(c.path.join(root,'assets/palette.json')));
const core=require('/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/scripts/fallen_core.cjs');
const result={models:0,poseComparisons:0,maxPoseError:0,maxCrossReaderPoseError:0,maxFlightFront:0,birthContinuous:'PASS',impactAnchors:'PASS',colorFields:'PASS',preservation:'PASS',limits:'Numerical/file validation; visual game test separate.'};
function near(a,b,tolerance=0.0005) {c.assert(Math.abs(a-b)<=tolerance,`${a} != ${b}`);}
function invariant(m,color=false) {
  const a=c.plain(m);delete a.extent;
  for(const g of a.geosets){delete g.vertices;delete g.extent;delete g.sequenceExtents;}
  for(const s of a.sequences)delete s.extent;
  delete a.pivotPoints;
  a.bones.find(n=>n.name==='Bone_B1').animations=a.bones.find(n=>n.name==='Bone_B1').animations.filter(t=>t.name!=='KGTR');
  if(color){delete a.name;for(const g of a.geosetAnimations)delete g.color;for(const p of a.particleEmitters2)delete p.segmentColors;for(const l of a.lights){delete l.color;delete l.ambientColor;}for(const t of a.textures)delete t.path;}
  return a;
}
for(const entry of manifest.entries) {
  const file=c.path.join(root,entry.path),m=c.read(file);
  const original=entry.pack==='anchor'?c.path.join(project,'descargas/warcraft3/misiles/vinz/shots-vol-i/originales/Shots Vol. I',entry.source):c.path.join(root,'exports/shots-vol-i-anclaje',entry.source);
  const src=c.read(original);
  c.assert.deepEqual(invariant(m,entry.pack==='players'),invariant(src,entry.pack==='players'));
  const primary=core.read(file);core.nodes(primary);
  const stand=m.sequences.findIndex(s=>s.name==='Stand');
  const front=c.bounds(c.pose(m,stand,100).points.flat()).max[0];near(front,0,0.001);
  // Continuous Birth bound: before the nonnegative parent scale, each skinned
  // X is linear. If both endpoints are <=0, no interior point can pass X=0.
  const birth=m.sequences.findIndex(s=>s.name==='Birth'),interval=m.sequences[birth].interval;
  const body=m.bones.find(n=>n.objectId===0),tail=m.bones.find(n=>n.objectId===1),parent=m.helpers.find(n=>n.name==='Default');
  c.assert.deepEqual(parent.animations.map(a=>a.name),['KGSC']);
  for(const n of [body,tail]) {
    for(const tr of n.animations) {
      const keys=tr.frames.filter(t=>t>=interval[0]&&t<=interval[1]);
      if(tr.name==='KGSC'||tr.name==='KGRT')c.assert.equal(keys.length,0);
      else if(tr.name==='KGTR'){c.assert.equal(tr.interpolationType,1);c.assert.deepEqual(keys,Array.from(interval));}
    }
  }
  const parentScale=parent.animations[0];c.assert.equal(parentScale.interpolationType,1);
  c.assert(parentScale.values.every(v=>v.every(x=>x>=0)));
  const bg=new c.Generic(m,body,0),tg=new c.Generic(m,tail,1);
  for(const time of interval) {
    const bt=new Float32Array(3),tt=new Float32Array(3);bg.getTranslation(bt,birth,time,0);tg.getTranslation(tt,birth,time,0);
    for(const g of m.geosets) {
      let index=0;const tailWeights=Array.from(g.matrixGroups,n=>{const ids=Array.from(g.matrixIndices.slice(index,index+n));index+=n;c.assert(ids.every(i=>i===0||i===1));return ids.filter(i=>i===1).length/n;});
      for(let i=0;i<g.vertexGroups.length;i++)c.assert(g.vertices[i*3]+bt[0]+tailWeights[g.vertexGroups[i]]*tt[0]<=0.001);
    }
  }
  const bone=src.bones.find(n=>n.name==='Bone_B1'),rootGeneric=new c.Generic(src,bone,0);
  const defaultGeneric=new c.Generic(src,src.helpers.find(n=>n.name==='Default'),0);
  for(let si=0;si<m.sequences.length;si++) for(const time of c.frames(m,si,5)) {
    const after=c.pose(m,si,time),before=c.pose(src,si,time);
    const scale=new Float32Array([1,1,1]);
    if(entry.pack==='anchor') {
      if(m.sequences[si].name==='Death')rootGeneric.getScale(scale,si,time,0);
      if(m.sequences[si].name==='Birth')defaultGeneric.getScale(scale,si,time,0);
    }
    const delta=entry.pack==='anchor'?entry.transform.delta.map((v,i)=>v*scale[i]):[0,0,0];
    after.points.forEach((ps,g)=>ps.forEach((p,i)=>p.forEach((v,j)=>{
      const error=Math.abs(v-before.points[g][i][j]-delta[j]);result.maxPoseError=Math.max(result.maxPoseError,error);near(error,0);
    })));
    if(['Stand','Birth'].includes(m.sequences[si].name)) {
      const max=c.bounds(after.points.flat()).max[0];result.maxFlightFront=Math.max(result.maxFlightFront,max);c.assert(max<=0.001,'Front passed anchor');
    }
    for(const node of src.particleEmitters2.filter(n=>['Stars','Lumps','A Uno'].includes(n.name)).concat(src.lights,src.eventObjects)) after.anchors[node.objectId].forEach((v,j)=>near(v,before.anchors[node.objectId][j]));
    if(time===m.sequences[si].interval[0]||time===m.sequences[si].interval[1]) {
      const other=core.points(primary,time,primary.Sequences[si]);
      after.points.forEach((ps,g)=>ps.forEach((p,i)=>p.forEach((v,j)=>{const error=Math.abs(v-other[g][i][j]);result.maxCrossReaderPoseError=Math.max(result.maxCrossReaderPoseError,error);near(error,0);}))); 
    }
    result.poseComparisons++;
  }
  // Verify that both parsers read the textual companion with all components/colors intact.
  const text=new c.Model();text.loadMdl(c.fs.readFileSync(file.replace(/\.mdx$/,'.mdl'),'utf8'));
  function compare(a,b) {
    if(typeof a==='number') {near(a,b,0.00002);return;}
    if(a&&typeof a==='object') {c.assert.deepEqual(Object.keys(a),Object.keys(b));for(const k of Object.keys(a))compare(a[k],b[k]);}
    else c.assert.equal(a,b);
  }
  function mdlCanonical(model) {
    const a=c.plain(model);
    for(const n of a.lights)n.flags&=~512;
    for(const n of a.particleEmitters2)n.flags&=~4096;
    function sortTracks(value) {
      if(!value||typeof value!=='object')return;
      if(value.animations)value.animations.sort((a,b)=>a.name.localeCompare(b.name));
      for(const x of Object.values(value))sortTracks(x);
    }
    sortTracks(a);return a;
  }
  compare(mdlCanonical(m),mdlCanonical(text));
  if(entry.pack==='players') {
    const rgb=palette[entry.color].rgb.map(x=>x/255);
    for(const color of [...m.geosetAnimations.map(g=>g.color),...m.lights.map(l=>l.color),...m.particleEmitters2.flatMap(p=>p.segmentColors)]) {
      const peak=Math.max(...color)/Math.max(...rgb);
      color.forEach((v,i)=>near(v,rgb[i]*peak,0.000001));
    }
    for(const texture of m.textures)c.assert(c.fs.existsSync(c.path.join(root,'exports/shots-vol-i-jugadores',...texture.path.split('\\'))),'Missing import');
  }
  result.models++;
}
c.fs.writeFileSync(c.path.join(root,'evidence/verification.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result));
