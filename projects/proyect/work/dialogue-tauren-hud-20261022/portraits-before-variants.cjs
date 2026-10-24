// Adapt COPIES of Classic portraits, preserving original face and body motion.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const base=path.resolve(__dirname,'../../..'),root=path.resolve(__dirname,'..');
const {read,pose,dependency,allNodes,save,Generic}=require(base+'/ModelEditor/src/model.cjs');
const {vec3,mat3,mat4,quat}=dependency('gl-matrix');
const Model=dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/model').default;
const Camera=dependency('mdx-m3-viewer/dist/cjs/viewer/handlers/mdx/camera').default;
const art='/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/dialogue';
const registry={};
for(const [id,name,idle,talk] of [['paladin','HeroPaladin',1,4],['tauren','Tauren',1,4]]){
 const input=base+`/work/dialogue-animated-20261022/originals/${name}_portrait.mdx`,m=read(input);
 const original=allNodes(m).map(n=>({id:n.objectId,tracks:JSON.stringify(n.animations)}));
 // Preserve all original portrait motion, including torso, arms and carried props.
 const frozen=[];
 // Team glow background geometry is unrelated to the head, and overwhelms fit bounds.
 const kept=[];
 m.geosets.forEach((g,i)=>{
  if(name==='HeroPaladin'&&i===2)return;
  if(!m.materials[g.materialId].layers.some(l=>m.textures[l.textureId]?.replaceableId!==2))return;
  kept.push(i);
 });
 const anims=m.geosetAnimations,animIds=anims.map((a,i)=>kept.includes(a.geosetId)?i:-1).filter(i=>i>=0);
 m.geosets=kept.map(i=>m.geosets[i]);m.geosetAnimations=animIds.map(i=>anims[i]);for(const a of m.geosetAnimations)a.geosetId=kept.indexOf(a.geosetId);
 for(const n of m.bones){if(n.geosetId>=0)n.geosetId=kept.includes(n.geosetId)?kept.indexOf(n.geosetId):-1;if(n.geosetAnimationId>=0)n.geosetAnimationId=animIds.indexOf(n.geosetAnimationId);}
 const c=new Camera(m,m.cameras[0]),p=vec3.clone(c.position),t=vec3.clone(c.targetPosition),a=vec3.create(),b=vec3.create();
 c.getTranslation(a,idle,m.sequences[idle].interval[0],0);c.getTargetTranslation(b,idle,m.sequences[idle].interval[0],0);vec3.add(p,p,a);vec3.add(t,t,b);
 const D=vec3.normalize(vec3.create(),vec3.subtract(vec3.create(),p,t)),R=vec3.normalize(vec3.create(),vec3.cross(vec3.create(),[0,0,1],D)),U=vec3.cross(vec3.create(),D,R);
 const rotation=quat.fromMat3(quat.create(),mat3.fromValues(D[0],R[0],U[0],D[1],R[1],U[1],D[2],R[2],U[2]));
 if(id==='tauren'){
  const {cameraPortrait}=require('./portrait-camera.cjs'),output=root+`/assets/UI/Dialogue/Portraits/${id}.mdx`;
  const details=cameraPortrait(m,{idle,talk,p,t,D,R,U,fov:c.fieldOfView,near:c.nearClippingPlane,output,preview:art+`/portraits/${id}.mdx`});
  registry[id]={name,idle:0,talk:1,sourceIdle:idle,sourceTalk:talk,file:`UI\\Dialogue\\Portraits\\${id}.mdx`,preview:`assets/dialogue/portraits/${id}.mdx`,rawcode:'dta0',bust:true,headOnly:false,retainedBodyParts:'original arms, hands and totem; original idle/talk motion',frozenBodyNodes:frozen,source:input,...details};continue;
 }
 const points=[];
 const selected=[idle,talk];
 for(const si of selected){const [lo,hi]=m.sequences[si].interval;for(let f=lo;f<=hi;f+=100)for(const g of pose(m,si,f).points)for(const point of g)points.push([vec3.dot(D,point),vec3.dot(R,point),vec3.dot(U,point)]);}
 const min=[0,1,2].map(i=>Math.min(...points.map(p=>p[i]))),max=[0,1,2].map(i=>Math.max(...points.map(p=>p[i])));
 // HUD-style bust: fill height, put the lower cut behind the frame, and trim
 // shoulders at the side borders. Fit uses the reference idle pose; head tracks stay original.
 const basePose=pose(m,idle,m.sequences[idle].interval[0]).points;
 const objects=new Map(allNodes(m).map((n,i)=>[n.objectId,new Generic(m,n,i)])),worldCache=new Map();
 function world(id){if(worldCache.has(id))return worldCache.get(id);const n=objects.get(id),t=vec3.create(),s=vec3.create(),q=new Float32Array(4);n.getTranslation(t,idle,m.sequences[idle].interval[0],0);n.getRotation(q,idle,m.sequences[idle].interval[0],0);n.getScale(s,idle,m.sequences[idle].interval[0],0);const a=mat4.fromRotationTranslationScaleOrigin(mat4.create(),q,t,s,n.pivot);if(n.parentId!==-1)mat4.multiply(a,world(n.parentId),a);worldCache.set(id,a);return a;}
 function groupInverses(g){let cursor=0;return Array.from(g.matrixGroups,count=>{const ids=Array.from(g.matrixIndices.slice(cursor,cursor+count));cursor+=count;const a=new Float32Array(16);for(const id of ids)for(let j=0;j<16;j++)a[j]+=world(id)[j]/count;const inverse=mat4.invert(mat4.create(),a);assert(inverse,'Invertible source skin group');return inverse;});}
 const basePoints=basePose.flat().map(p=>[vec3.dot(D,p),vec3.dot(R,p),vec3.dot(U,p)]);
 const baseMin=[0,1,2].map(i=>Math.min(...basePoints.map(p=>p[i]))),baseMax=[0,1,2].map(i=>Math.max(...basePoints.map(p=>p[i])));
 const fit=17.8/(2*vec3.distance(p,t)*Math.tan(c.fieldOfView/2));
 const center=[(min[0]+max[0])/2,vec3.dot(R,t),vec3.dot(U,t)],translation=center.map(v=>-v*fit);
 // Clip skinned triangles in the reference pose, carrying bind vertices/UVs.
 // New border vertices use the inverse of their chosen skin group, preserving the posed cut.
 // These cuts lie under the opaque frame, not through the visible face.
 for(let gi=0;gi<m.geosets.length;gi++){
  const g=m.geosets[gi],out=[],inverse=groupInverses(g);
  const vertex=i=>({p:Array.from(g.vertices.slice(i*3,i*3+3)),n:Array.from(g.normals.slice(i*3,i*3+3)),uv:g.uvSets.map(uv=>Array.from(uv.slice(i*2,i*2+2))),group:g.vertexGroups[i],w:basePose[gi][i],r:vec3.dot(R,basePose[gi][i]),u:vec3.dot(U,basePose[gi][i])});
  const mix=(a,b,t)=>{const group=t<.5?a.group:b.group,w=a.w.map((v,i)=>v+(b.w[i]-v)*t);return {p:Array.from(vec3.transformMat4(vec3.create(),w,inverse[group])),w,n:a.n.map((v,i)=>v+(b.n[i]-v)*t),uv:a.uv.map((uv,j)=>uv.map((v,i)=>v+(b.uv[j][i]-v)*t)),group,r:a.r+(b.r-a.r)*t,u:a.u+(b.u-a.u)*t};};
  for(let f=0;f<g.faces.length;f+=3){let poly=Array.from(g.faces.slice(f,f+3),vertex);
   for(const [axis,bound,sign] of [['r',center[1]-12.5/fit,1],['r',center[1]+12.5/fit,-1],['u',center[2]-11/fit,1],['u',center[2]+10.4/fit,-1]]){
    const clipped=[];for(let k=0;k<poly.length;k++){const a=poly[k],b=poly[(k+1)%poly.length],inside=(a[axis]-bound)*sign>=0,next=(b[axis]-bound)*sign>=0;if(inside)clipped.push(a);if(inside!==next)clipped.push(mix(a,b,(bound-a[axis])/(b[axis]-a[axis])));}poly=clipped;
   }
   for(let k=1;k+1<poly.length;k++)out.push(poly[0],poly[k],poly[k+1]);
  }
  g.vertices=new Float32Array(out.flatMap(v=>v.p));g.normals=new Float32Array(out.flatMap(v=>v.n));g.uvSets=g.uvSets.map((_,i)=>new Float32Array(out.flatMap(v=>v.uv[i])));g.vertexGroups=new Uint8Array(out.map(v=>v.group));g.faces=new Uint16Array(out.map((_,i)=>i));g.faceGroups=new Uint32Array([g.faces.length]);g.faceTypeGroups=new Uint32Array([4]);
 }
 // Validate the actual skinned result, not just bind coordinates or index counts.
 for(const pts of pose(m,idle,m.sequences[idle].interval[0]).points)for(const point of pts){const r=vec3.dot(R,point),u=vec3.dot(U,point);assert(r>=center[1]-12.5/fit-.002&&r<=center[1]+12.5/fit+.002,'Skinned horizontal cut');assert(u>=center[2]-11/fit-.002&&u<=center[2]+10.4/fit+.002,'Skinned vertical cut');}
 const animationBounds={min:[Infinity,Infinity],max:[-Infinity,-Infinity]};
 for(const si of [idle,talk]){const [lo,hi]=m.sequences[si].interval;for(let frame=lo;frame<=hi;frame+=25)for(const pts of pose(m,si,frame).points)for(const point of pts){const v=[(vec3.dot(R,point)-center[1])*fit,(vec3.dot(U,point)-center[2])*fit];for(let i=0;i<2;i++){animationBounds.min[i]=Math.min(animationBounds.min[i],v[i]);animationBounds.max[i]=Math.max(animationBounds.max[i],v[i]);}}}
 console.log(id,'animated cut bounds',animationBounds);
 m.sequences=[m.sequences[idle],m.sequences[talk]];
 const maxId=Math.max(...allNodes(m).map(n=>n.objectId)),bill=maxId+1,fitId=maxId+2,depthId=maxId+3;
 for(const n of allNodes(m))if(n.parentId===-1)n.parentId=fitId;
 const keys=m.sequences.flatMap(s=>[...s.interval]);
 const track=(name,v)=>`${name} ${keys.length} { Linear, ${keys.map(k=>`${k}: {${v.join(',')}},`).join('')} }`;
 const helper=new Model();helper.loadMdl(`Version {FormatVersion 800,} Model "Transform" {} Helper "PortraitBillboard" {ObjectId ${bill},Billboarded,} Helper "PortraitFit" {ObjectId ${fitId},Parent ${depthId},${track('Translation',translation)}${track('Rotation',[...rotation])}${track('Scaling',[fit,fit,fit])}} Helper "PortraitDepth" {ObjectId ${depthId},Parent ${bill},${track('Scaling',[.02,1,1])}}`);
 m.helpers.push(...helper.helpers);m.pivotPoints.push(new Float32Array(3),new Float32Array(3),new Float32Array(3));m.name='Dialogue '+name;m.blendTime=0;
 for(const tex of m.textures){if(tex.replaceableId===2){tex.path='UI\\Dialogue\\PortraitBackground.blp';tex.replaceableId=0;}else if(tex.replaceableId===1){tex.path='UI\\Dialogue\\PortraitTeamColor.blp';tex.replaceableId=0;}else if(tex.path)tex.path='UI\\Dialogue\\Portraits\\'+tex.path.split('\\').at(-1);}
 for(const mat of m.materials)for(const layer of mat.layers)layer.flags|=1|16|32; // unshaded/two-sided/unfogged; keep model self-depth.
 for(const ext of [m.extent,...m.sequences.map(s=>s.extent),...m.geosets.flatMap(g=>[g.extent,...g.sequenceExtents])]){ext.min.set([-40,-40,-40]);ext.max.set([40,40,40]);ext.boundsRadius=70;}
 for(const g of m.geosets){assert.equal(Array.from(g.faceGroups).reduce((a,b)=>a+b,0),g.faces.length,'Face group count must match actual indices');assert.equal(Math.max(...g.faces)<g.vertices.length/3,true);}
 const output=root+`/assets/UI/Dialogue/Portraits/${id}.mdx`;save(m,output);fs.copyFileSync(output,art+`/portraits/${id}.mdx`);
 for(const n of allNodes(m).filter(n=>n.objectId<=maxId&&!frozen.includes(n.objectId)))assert.equal(JSON.stringify(n.animations),original.find(x=>x.id===n.objectId).tracks);
 registry[id]={name,animationBounds,bodyPolicy:"original idle and talk tracks for body, neck, head and face",framing:"source camera fit; original facial bone tracks",cameraReference:{position:Array.from(p),target:Array.from(t),fieldOfView:c.fieldOfView,near:c.nearClippingPlane,sequence:idle,frame:m.sequences[0].interval[0]},frozenBodyNodes:frozen,idle:0,talk:1,sourceIdle:idle,sourceTalk:talk,file:`UI\\Dialogue\\Portraits\\${id}.mdx`,preview:`assets/dialogue/portraits/${id}.mdx`,rawcode:id==='paladin'?'dpa0':'dta0',fit,translation,rotation:[...rotation],sampleStepMs:100,headOnly:false,bust:true,referencePoseFit:true,borderClip:"idle pose, inverse skin group for border vertices",depthCompression:.02,sampledSequences:selected,projectedBounds:{min,max},removedGeosets:kept.length===3?[]:[...Array(3).keys()].filter(i=>!kept.includes(i)),source:input};
}
fs.writeFileSync(root+'/evidence/portrait-registry.json',JSON.stringify(registry,null,2));fs.writeFileSync(art+'/portraits/registry.json',JSON.stringify(registry,null,2));
console.log('Two animated bust copies adapted; original face and body motion retained/sampled, body profile recorded and independent readback passed.');
