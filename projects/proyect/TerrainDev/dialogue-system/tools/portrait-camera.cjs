// Bake the animated native portrait camera and original portrait motion into MDX800 vertex bones.
// Body and facial motion remain animated. Source models remain untouched.
const fs=require('node:fs');
const {Model,pose,save,dependency}=require('../../../ModelEditor/src/model.cjs');
const {vec3}=dependency('gl-matrix');
function cameraPortrait(source,{sequenceIndices,camera,idle,talk,p,t,D,R,U,fov,near,output,preview}){
 const distance=vec3.distance(p,t);
 // A 3ds Max camera's horizontal field of view; viewport is the original aperture.
 const width=24.36,height=18.954,focal=width/(2*Math.tan(fov/2)),xLimit=13.5,yLimit=10.7;
 const frames=sequenceIndices.map(si=>{const [a,b]=source.sequences[si].interval,ts=[];for(let f=a;f<b;f+=25)ts.push(f);ts.push(b);return ts;});
 const samples=frames.map((ts,j)=>ts.map(f=>pose(source,sequenceIndices[j],f).points));
 function view(si,frame){
  const eye=vec3.clone(camera.position),target=vec3.clone(camera.targetPosition),a=vec3.create(),b=vec3.create(),roll=new Float32Array(1);
  camera.getTranslation(a,si,frame,0);camera.getTargetTranslation(b,si,frame,0);camera.getRotation(roll,si,frame,0);vec3.add(eye,eye,a);vec3.add(target,target,b);
  const d=vec3.normalize(vec3.create(),vec3.subtract(vec3.create(),eye,target)),r=vec3.normalize(vec3.create(),vec3.cross(vec3.create(),[0,0,1],d)),u=vec3.cross(vec3.create(),d,r),cs=Math.cos(roll[0]),sn=Math.sin(roll[0]);
  const rr=Array.from(r,(v,i)=>v*cs+u[i]*sn),uu=Array.from(u,(v,i)=>v*cs-r[i]*sn);
  return w=>{const depth=vec3.dot(d,eye)-vec3.dot(d,w);return {depth,y:(vec3.dot(rr,w)-vec3.dot(rr,target))*focal/Math.max(near,depth),z:(vec3.dot(uu,w)-vec3.dot(uu,target))*focal/Math.max(near,depth)};};
 }
 const views=frames.map((ts,si)=>ts.map(frame=>view(sequenceIndices[si],frame)));
 // UI actor center is x=-2, gray backing is x=-3. Keep ALL sampled poses
 // inside a shallow slab, including maximum editor scale 1.4: -2 ± 0.63.
 let maximumDepthDeviation=1;
 samples.forEach((ts,si)=>ts.forEach((groups,fi)=>groups.forEach(points=>points.forEach(w=>{maximumDepthDeviation=Math.max(maximumDepthDeviation,Math.abs(distance-views[si][fi](w).depth));}))));
 const depthScale=.45/maximumDepthDeviation;
 const out=new Model();out.name='Dialogue '+source.name;out.version=800;out.blendTime=200;out.sequences=sequenceIndices.map(si=>Object.assign(Object.create(Object.getPrototypeOf(source.sequences[si])),source.sequences[si]));out.materials=source.materials;out.textures=source.textures;
 const nodes=[],sequenceMotion=sequenceIndices.map(()=>0);
 source.geosets.forEach((g,gi)=>{
  // Keep complete source topology across all poses. Overscan clamps are hidden
  // beneath the opaque frame; they are not cuts through arms or carried props.
  const indices=Array.from(g.faces),verts=Array.from({length:g.vertices.length/3},(_,i)=>({refs:[[i,1]]}));
  const groupRecords=[];
  const vertexData=verts.map(v=>{
   const positions=samples.map((ts,si)=>ts.map((pts,fi)=>{const w=[0,0,0];for(const [i,weight]of v.refs)for(let a=0;a<3;a++)w[a]+=pts[gi][i][a]*weight;const q=views[si][fi](w);return [(distance-q.depth)*depthScale,Math.max(-xLimit,Math.min(xLimit,q.y)),Math.max(-yLimit,Math.min(yLimit,q.z))];}));
   positions.forEach((ts,si)=>ts.forEach(p=>p.forEach((v,a)=>{sequenceMotion[si]=Math.max(sequenceMotion[si],Math.abs(v-ts[0][a]));})));
   const first=positions[0][0],moving=positions.some(ts=>ts.some(p=>p.some((x,i)=>Math.abs(x-first[i])>.00001)));
   const nodeId=moving?nodes.length+1:0;
   if(moving)nodes.push({positions,first,nodeId});
   // Each source vertex gets its own translation, preserving projected body and facial deformation.
   if(!groupRecords.includes(nodeId))groupRecords.push(nodeId);
   const uv=g.uvSets.map(uv=>[0,1].map(a=>v.refs.reduce((sum,[i,w])=>sum+uv[i*2+a]*w,0)));
   return {first,uv,nodeId};
  });
  // vertexGroups are bytes: partition triangles into independent local palettes.
  // Matrix indices themselves are uint32 object IDs, not byte-sized node IDs.
  const batches=[];let batch=[],palette=new Set();
  for(let i=0;i<indices.length;i+=3){const tri=indices.slice(i,i+3),ids=tri.map(v=>vertexData[v].nodeId),next=new Set([...palette,...ids]);
   if(next.size>240){batches.push(batch);batch=[];palette=new Set();}
   batch.push(...tri);for(const id of ids)palette.add(id);
  }
  if(batch.length)batches.push(batch);
  for(const batch of batches){
   const used=[...new Set(batch)],remap=new Map(used.map((v,i)=>[v,i])),data=used.map(i=>vertexData[i]),ids=[...new Set(data.map(v=>v.nodeId))];
   const proto=Object.getPrototypeOf(g),og=Object.assign(Object.create(proto),g);
   og.vertices=new Float32Array(data.flatMap(v=>v.first));og.normals=new Float32Array(data.flatMap(()=>[1,0,0]));og.uvSets=g.uvSets.map((_,i)=>new Float32Array(data.flatMap(v=>v.uv[i])));og.vertexGroups=new Uint8Array(data.map(v=>ids.indexOf(v.nodeId)));og.matrixGroups=new Uint32Array(ids.map(()=>1));og.matrixIndices=new Uint32Array(ids);og.faces=new Uint16Array(batch.map(v=>remap.get(v)));og.faceGroups=new Uint32Array([og.faces.length]);og.faceTypeGroups=new Uint32Array([4]);og.sequenceExtents=out.sequences.map(()=>og.extent);out.geosets.push(og);
  }
 });
 if(nodes.length+2>1024)throw Error('Camera portrait exceeds tool safety budget (1024 nodes): '+nodes.length);
 const rootId=0,nodeCount=nodes.length+1,transform=new Model();let mdl='Version {FormatVersion 800,} Model "CameraBones" {}';
 mdl+=`Bone "PortraitBillboard" {ObjectId 0,Billboarded,GeosetId Multiple,GeosetAnimId None,}`;
 for(const n of nodes){const keys=n.positions.flatMap((ts,si)=>ts.map((p,i)=>({time:frames[si][i],delta:p.map((v,a)=>v-n.first[a])}))).sort((a,b)=>a.time-b.time).map(k=>`${k.time}: {${k.delta.join(',')}},`);mdl+=`Bone "CameraVertex${n.nodeId}" {ObjectId ${n.nodeId},Parent ${rootId},GeosetId Multiple,GeosetAnimId None,Translation ${keys.length} {Linear,${keys.join('')}}}`;}
 mdl+=`PivotPoints ${nodeCount} {${Array.from({length:nodeCount},()=>'{0,0,0},').join('')}}`;transform.loadMdl(mdl);out.bones=transform.bones;out.helpers=transform.helpers;out.pivotPoints=transform.pivotPoints;
 for(const mat of out.materials)for(const l of mat.layers)l.flags|=1|16|32;
 for(const ext of [out.extent,...out.sequences.map(s=>s.extent),...out.geosets.flatMap(g=>[g.extent,...g.sequenceExtents])]){ext.min.set([-40,-40,-40]);ext.max.set([40,40,40]);ext.boundsRadius=70;}
 for(const tex of out.textures){if(tex.replaceableId===2){tex.path='UI\\Dialogue\\PortraitBackground.blp';tex.replaceableId=0;}else if(tex.replaceableId===1){tex.path='UI\\Dialogue\\PortraitTeamColor.blp';tex.replaceableId=0;}else if(tex.path)tex.path='UI\\Dialogue\\Portraits\\'+tex.path.split('\\').at(-1);}
 save(out,output);fs.copyFileSync(output,preview);
 return {method:'source-camera-projected vertex animation',sourceCamera:{position:Array.from(p),target:Array.from(t),horizontalFieldOfView:fov,near,referenceSequence:idle,referenceFrame:frames[sequenceIndices.indexOf(idle)][0],frozen:false,animatedCamera:true},depthBudget:{actorCenter:-2,backdrop:-3,localHalfDepth:.45,maxEditorScale:1.4,scale:depthScale},sampleStepMs:25,sequenceMotion,sequenceNames:out.sequences.map(s=>s.name),sourceSequences:sequenceIndices,bodyPolicy:'projected all original Stand/Portrait/Talk body, arms, props, head and face motion',animatedVertexBones:nodes.length,totalNodes:nodeCount,geosets:out.geosets.length,maxLocalPalette:Math.max(...out.geosets.map(g=>g.matrixGroups.length)),frustum:{width,height,xLimit,yLimit},vertices:out.geosets.reduce((a,g)=>a+g.vertices.length/3,0),triangles:out.geosets.reduce((a,g)=>a+g.faces.length/3,0)};
}
module.exports={cameraPortrait};
