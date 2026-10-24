const {assert,allNodes,pose,bounds,frames,assignBounds,Generic} = require('./model.cjs');
function anchor(m) {
  assert.equal(m.version,800);assert.equal(m.globalSequences.length,0);
  const root=m.bones.find(n=>n.name==='Bone_B1'); assert(root);
  assert(!root.animations.some(a=>a.name==='KGRT'));
  const stand=m.sequences.findIndex(s=>s.name==='Stand');
  const death=m.sequences.findIndex(s=>s.name==='Death');
  const flight=bounds(pose(m,stand,m.sequences[stand].interval[0]).points.flat());
  const delta=[-flight.max[0],-(flight.min[1]+flight.max[1])/2,0];
  const ids=new Set([root.objectId]);
  for(let changed=true;changed;) {changed=false;for(const n of allNodes(m)) if(ids.has(n.parentId)&&!ids.has(n.objectId)){ids.add(n.objectId);changed=true;}}
  const originalGeneric=new Generic(m,root,0);
  const tr=root.animations.find(a=>a.name==='KGTR'),sc=root.animations.find(a=>a.name==='KGSC');
  assert.equal(tr.interpolationType,1);assert.equal(sc.interpolationType,1);
  const [start,end]=m.sequences[death].interval;
  const times=[...new Set([...tr.frames,...sc.frames,start,end].filter(t=>t>=start&&t<=end))].sort((a,b)=>a-b);
  const replacements=times.map(t=>{
    const pos=new Float32Array(3),scale=new Float32Array(3);
    originalGeneric.getTranslation(pos,death,t,0);originalGeneric.getScale(scale,death,t,0);
    return {t,v:Float32Array.from(pos,(x,i)=>x+delta[i]*(scale[i]-1))};
  });
  const all=tr.frames.map((t,i)=>({t,v:tr.values[i]})).filter(x=>x.t<start||x.t>end).concat(replacements).sort((a,b)=>a.t-b.t);
  tr.frames=all.map(x=>x.t);tr.values=all.map(x=>x.v);
  for(const id of ids) m.pivotPoints[id]=Float32Array.from(m.pivotPoints[id],(x,i)=>x+delta[i]);
  for(const g of m.geosets) for(let j=0;j<g.vertices.length;j++) g.vertices[j]+=delta[j%3];
  // Keep old bounds as well as the newly positioned animated body; never shrink the original effect envelope.
  const total=[Array.from(m.extent.min),Array.from(m.extent.max)];
  for(let si=0;si<m.sequences.length;si++) {
    const per=m.geosets.map(g=>[Array.from(g.sequenceExtents[si].min),Array.from(g.sequenceExtents[si].max)]);
    for(const t of frames(m,si)) pose(m,si,t).points.forEach((p,i)=>per[i].push(...p));
    per.forEach((p,i)=>assignBounds(m.geosets[i].sequenceExtents[si],p));
    const seq=m.sequences[si];assignBounds(seq.extent,[Array.from(seq.extent.min),Array.from(seq.extent.max),...per.flat()]);
    total.push(...per.flat());
  }
  for(const g of m.geosets) assignBounds(g.extent,[Array.from(g.extent.min),Array.from(g.extent.max),...g.sequenceExtents.flatMap(e=>[Array.from(e.min),Array.from(e.max)]),...Array.from(g.vertexGroups,(_,i)=>Array.from(g.vertices.slice(i*3,i*3+3)))]);
  assignBounds(m.extent,total);
  return {delta,bodyNodes:[...ids],standBefore:flight};
}
module.exports={anchor};
