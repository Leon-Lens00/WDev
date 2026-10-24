// Same local matrix evaluation, with an explicit global animation clock.
const c=require('./model.cjs');const {Generic,assert,allNodes}=c;const {mat4,vec3}=c.dependency('gl-matrix');
function pose(m, sequence, frame, counter=frame) {
  const objects = new Map(allNodes(m).map((n,i)=>[n.objectId,new Generic(m,n,i)]));
  const cache = new Map();
  function world(id) {
    if(cache.has(id)) return cache.get(id);
    const n = objects.get(id); assert(n, 'Missing node '+id);
    assert(!(allNodes(m).find(x=>x.objectId===id).flags & 255), 'Unsupported inheritance/billboard');
    const t=vec3.create(), s=vec3.create(), q=new Float32Array(4);
    n.getTranslation(t,sequence,frame,counter); n.getRotation(q,sequence,frame,counter); n.getScale(s,sequence,frame,counter);
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

module.exports=pose;
