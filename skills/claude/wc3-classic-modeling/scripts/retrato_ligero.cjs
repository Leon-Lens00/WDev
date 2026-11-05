// Rehace los retratos sobre el esqueleto original: mismas claves de hueso, una cadena
// fija (billboard, aplanado, vista) y vertices de reposo ajustados por minimos cuadrados
// a la trayectoria proyectada de portrait-camera.cjs. No toca los originales.
const fs=require('node:fs'),path=require('node:path');
const base='/home/snz/Documentos/ChatGPT/Proyect',tools=base+'/TerrainDev/dialogue-system/tools';
const {Model,read,allNodes,save,dependency}=require(base+'/ModelEditor/src/model.cjs');
const Generic=dependency('mdx-m3-viewer/dist/cjs/viewer/handlers/mdx/genericobject').default;
const Camera=dependency('mdx-m3-viewer/dist/cjs/viewer/handlers/mdx/camera').default;
const {mat4,vec3,quat,mat3}=dependency('gl-matrix');
const outDir=process.argv[2],step=+(process.argv[3]||25);
const HID=+(process.env.HID||1),CK=+(process.env.CK||4),TTOL=+(process.env.TTOL||.5),STOL=+(process.env.STOL||.07);
const W=24.36,XL=13.5,YL=10.7,VX=12.18,VY=9.477; // VX/VY: abertura visible del marco

function skin(m,si,f){ // matrices de cada grupo de cada geoset, en mundo
 const objs=new Map(allNodes(m).map((n,i)=>[n.objectId,new Generic(m,n,i)])),cache=new Map();
 const world=id=>{if(cache.has(id))return cache.get(id);const n=objs.get(id),t=vec3.create(),s=vec3.create(),q=new Float32Array(4);
  n.getTranslation(t,si,f,0);n.getRotation(q,si,f,0);n.getScale(s,si,f,0);
  const l=mat4.fromRotationTranslationScaleOrigin(mat4.create(),q,t,s,n.pivot);if(n.parentId!==-1)mat4.multiply(l,world(n.parentId),l);cache.set(id,l);return l;};
 const out=m.geosets.map(g=>{let c=0;return Array.from(g.matrixGroups,k=>{const ids=Array.from(g.matrixIndices.slice(c,c+k)),a=new Float64Array(16);c+=k;for(const id of ids)for(let j=0;j<16;j++)a[j]+=world(id)[j]/k;return a;});});
 out.world=world;return out;
}
function solve3(N,b){const m=N.map((r,i)=>[...r,b[i]]);for(let i=0;i<3;i++){let p=i;for(let j=i+1;j<3;j++)if(Math.abs(m[j][i])>Math.abs(m[p][i]))p=j;[m[i],m[p]]=[m[p],m[i]];for(let j=0;j<3;j++)if(j!==i){const k=m[j][i]/m[i][i];for(let c=i;c<4;c++)m[j][c]-=k*m[i][c];}}return m.map((r,i)=>r[3]/r[i]);}
function decimate(ts,vs,tol){ // Ramer-Douglas-Peucker por canal
 const keep=new Set([0,ts.length-1]);const rec=(a,b)=>{let w=-1,e=tol;for(let i=a+1;i<b;i++){const u=(ts[i]-ts[a])/(ts[b]-ts[a]);for(let c=0;c<vs[i].length;c++){const d=Math.abs(vs[i][c]-(vs[a][c]+(vs[b][c]-vs[a][c])*u));if(d>e){e=d;w=i;}}}if(w>=0){keep.add(w);rec(a,w);rec(w,b);}};rec(0,ts.length-1);return [...keep].sort((x,y)=>x-y);}

const report={};
for(const [id,name,idle,talk] of [['paladin','HeroPaladin',1,4],['tauren','Tauren',1,4]]){
 const m=read(base+`/work/dialogue-animated-20261022/originals/${name}_portrait.mdx`);
 if(id==='tauren')require(tools+'/repair-tauren-totem.cjs').repairTotem(m,base+'/work/dialogue-tauren-hud-20261022/Tauren-original-unit.mdx');
 const selected=[idle,talk,...m.sequences.flatMap((s,i)=>i!==idle&&i!==talk&&(/^(stand|portrait)(?:\s|$)/i.test(s.name))?[i]:[])].sort((a,b)=>m.sequences[a].interval[0]-m.sequences[b].interval[0]);
 m.geosets=m.geosets.filter(g=>m.materials[g.materialId].layers.some(l=>m.textures[l.textureId]?.replaceableId!==2));
 const c=new Camera(m,m.cameras[0]),fov=c.fieldOfView,near=c.nearClippingPlane,focal=W/(2*Math.tan(fov/2));
 const camAt=(si,f)=>{const eye=vec3.clone(c.position),tg=vec3.clone(c.targetPosition),a=vec3.create(),b=vec3.create(),ro=new Float32Array(1);c.getTranslation(a,si,f,0);c.getTargetTranslation(b,si,f,0);c.getRotation(ro,si,f,0);vec3.add(eye,eye,a);vec3.add(tg,tg,b);
  const d=vec3.normalize(vec3.create(),vec3.subtract(vec3.create(),eye,tg)),r=vec3.normalize(vec3.create(),vec3.cross(vec3.create(),[0,0,1],d)),u=vec3.cross(vec3.create(),d,r),cs=Math.cos(ro[0]),sn=Math.sin(ro[0]);
  return {eye,tg,d,r:Array.from(r,(v,i)=>v*cs+u[i]*sn),u:Array.from(u,(v,i)=>v*cs-r[i]*sn)};};
 const ref=camAt(idle,m.sequences[idle].interval[0]),distance=vec3.distance(ref.eye,ref.tg);
 const times=selected.map(si=>{const [a,b]=m.sequences[si].interval,t=[];for(let f=a;f<b;f+=step)t.push(f);t.push(b);return t;});
 // datos exactos del metodo anterior
 const frames=[];let maxDev=1;
 selected.forEach((si,j)=>times[j].forEach(f=>{const v=camAt(si,f),A=skin(m,si,f),dd=vec3.dot(v.d,v.eye);
  const pts=m.geosets.map((g,gi)=>Array.from(g.vertexGroups,(gr,i)=>{const a=A[gi][gr],x=g.vertices[i*3],y=g.vertices[i*3+1],z=g.vertices[i*3+2],w=[a[0]*x+a[4]*y+a[8]*z+a[12],a[1]*x+a[5]*y+a[9]*z+a[13],a[2]*x+a[6]*y+a[10]*z+a[14]];const depth=dd-vec3.dot(v.d,w);maxDev=Math.max(maxDev,Math.abs(distance-depth));return {w,depth};}));
  frames.push({si,seq:j,f,v,A,pts});}));
 const ds=.45/maxDev;
 // transformacion rigida de vista + escala de perspectiva por instante
 for(const fr of frames){const {v}=fr,all=fr.pts.flat(),Dc=all.reduce((s,p)=>s+Math.max(near,p.depth),0)/all.length;
  fr.s=focal/vec3.distance(v.eye,v.tg);fr.s=focal/Math.max(near,Dc);
  fr.Rm=[v.d[0],v.d[1],v.d[2],v.r[0],v.r[1],v.r[2],v.u[0],v.u[1],v.u[2]]; // filas
  fr.T=[distance-vec3.dot(v.d,v.eye),-vec3.dot(v.r,v.tg),-vec3.dot(v.u,v.tg)];
 }
 const s0=frames.reduce((s,f)=>s+f.s,0)/frames.length,wx=s0/ds;
 const target=(fr,p)=>{const v=fr.v,w=p.w;return [(distance-p.depth)*ds,Math.max(-XL,Math.min(XL,(vec3.dot(v.r,w)-vec3.dot(v.r,v.tg))*focal/Math.max(near,p.depth))),Math.max(-YL,Math.min(YL,(vec3.dot(v.u,w)-vec3.dot(v.u,v.tg))*focal/Math.max(near,p.depth)))];};
 // minimos cuadrados por vertice; los pivotes se ajustan despues por descenso de coordenadas
 let fitted=m.geosets.map(g=>new Float32Array(g.vertices)),clamped=0;const played=frames.filter(fr=>!/^stand/i.test(m.sequences[fr.si].name));
 const fit=(frs,out)=>{let loss=0;clamped=0;
  m.geosets.forEach((g,gi)=>{for(let i=0;i<g.vertices.length/3;i++){
   const N=[[0,0,0],[0,0,0],[0,0,0]],b=[0,0,0],v0=[g.vertices[i*3],g.vertices[i*3+1],g.vertices[i*3+2]],gr=g.vertexGroups[i];let cl=false,rr=0;
   for(const fr of frs){const a=fr.A[gi][gr],R=fr.Rm,sc=[ds,fr.s,fr.s],wt=[wx,1,1],L=[0,1,2].map(r=>[0,1,2].map(cc=>R[r*3]*a[cc*4]+R[r*3+1]*a[cc*4+1]+R[r*3+2]*a[cc*4+2]));
    const off=[0,1,2].map(r=>R[r*3]*a[12]+R[r*3+1]*a[13]+R[r*3+2]*a[14]+fr.T[r]),t=fr.t[gi][i],vis=Math.abs(t[1])<VX&&Math.abs(t[2])<VY;
    if(Math.abs(t[1])>=XL||Math.abs(t[2])>=YL)cl=true;
    for(let r=0;r<3;r++){const k=vis?1:HID,row=L[r].map(x=>x*sc[r]*wt[r]*k),rhs=k*(t[r]-off[r]*sc[r])*wt[r];rr+=rhs*rhs;for(let p=0;p<3;p++){b[p]+=row[p]*rhs;for(let q=0;q<3;q++)N[p][q]+=row[p]*row[q];}}}
   const b0=b.slice();for(let p=0;p<3;p++){N[p][p]+=1e-6*frs.length;b[p]+=1e-6*frs.length*v0[p];}
   const v=solve3(N,b);if(out)out[gi].set(v,i*3);if(cl)clamped++;loss+=rr-b0[0]*v[0]-b0[1]*v[1]-b0[2]*v[2];
  }});return loss;};
 for(const fr of frames)fr.t=m.geosets.map((g,gi)=>fr.pts[gi].map(p=>target(fr,p)));
 // Correccion por hueso, de padre a hijo: traslacion en el plano de pantalla y escala uniforme
 // se escriben en las pistas KGTR/KGSC del propio hueso, a los tiempos que sobreviven al RDP.
 const pinned=m.geosets.map((g,gi)=>{const P=new Map();for(let i=0;i<g.vertices.length/3;i++){const ts=played.map(fr=>fr.t[gi][i]);if(ts.every(t=>Math.abs(t[1])>=VX||Math.abs(t[2])>=VY))P.set(i,[0,1,2].map(a=>ts.reduce((q,t)=>q+t[a],0)/ts.length));}return P;});
 const parents=new Map(allNodes(m).map(n=>[n.objectId,n.parentId])),depthOf=i=>parents.get(i)===-1?0:1+depthOf(parents.get(i));
 const order=[...parents.keys()].sort((a,b)=>depthOf(a)-depthOf(b)),byId=new Map(allNodes(m).map(n=>[n.objectId,n]));
 const members=new Map();m.geosets.forEach((g,gi)=>{let c=0;const grp=Array.from(g.matrixGroups,k=>{const r=Array.from(g.matrixIndices.slice(c,c+k));c+=k;return r;});for(let i=0;i<g.vertices.length/3;i++)if(!pinned[gi].has(i))for(const b of grp[g.vertexGroups[i]]){if(!members.has(b))members.set(b,[]);members.get(b).push([gi,i,1/grp[g.vertexGroups[i]].length]);}});
 const sub=selected.flatMap((si,j)=>{const l=frames.filter(f=>f.seq===j);return l.filter((_,i)=>i%CK===0||i===l.length-1);}),subP=sub.filter(fr=>!/^stand/i.test(m.sequences[fr.si].name));
 const reskin=frs=>{for(const fr of frs)fr.A=skin(m,fr.si,fr.f);};
 const track=(kind,keys,name)=>{const t=new Model();t.loadMdl(`Version {FormatVersion 800,} Model "T" {}Helper "H" {ObjectId 0,${name} ${keys.length} {Linear,${keys.join('')}}}PivotPoints 1 {{0,0,0},}`);return t.helpers[0].animations[0];};
 const pred=(fr,gi,i,fit)=>{const g=m.geosets[gi],a=fr.A[gi][g.vertexGroups[i]],x=fit[gi][i*3],y=fit[gi][i*3+1],z=fit[gi][i*3+2],w=[a[0]*x+a[4]*y+a[8]*z+a[12],a[1]*x+a[5]*y+a[9]*z+a[13],a[2]*x+a[6]*y+a[10]*z+a[14]],R=fr.Rm;return {w,y:(R[3]*w[0]+R[4]*w[1]+R[5]*w[2]+fr.T[1])*fr.s,z:(R[6]*w[0]+R[7]*w[1]+R[8]*w[2]+fr.T[2])*fr.s};};
 const rounds=+(process.env.ROUNDS??2);fit(subP,fitted);
 for(let rd=0;rd<rounds;rd++){
  for(const b of order){const vs=members.get(b);if(!vs)continue;reskin(sub);
   const n=byId.get(b),obj=new Generic(m,n,0),Tk=[],Sk=[];
   for(const fr of sub){const tv=vec3.create(),sv=vec3.create();obj.getTranslation(tv,fr.si,fr.f,0);obj.getScale(sv,fr.si,fr.f,0);let d=[0,0,0];
    if(!/^stand/i.test(m.sequences[fr.si].name)){
     const W=fr.A.world(b),pv=m.pivotPoints[b],cw=vec3.transformMat4(vec3.create(),pv,W),R=fr.Rm,cy=(R[3]*cw[0]+R[4]*cw[1]+R[5]*cw[2]+fr.T[1])*fr.s,cz=(R[6]*cw[0]+R[7]*cw[1]+R[8]*cw[2]+fr.T[2])*fr.s;
     const N=[[0,0,0],[0,0,0],[0,0,0]],r=[0,0,0];
     for(const [gi,i,w] of vs){const t=fr.t[gi][i],vis=Math.abs(t[1])<VX&&Math.abs(t[2])<VY,k=vis?1:HID,o=pred(fr,gi,i,fitted),ey=t[1]-o.y,ez=t[2]-o.z,rows=[[w,0,w*(o.y-cy)],[0,w,w*(o.z-cz)]],es=[ey,ez];
      rows.forEach((row,a)=>{for(let p=0;p<3;p++){r[p]+=k*row[p]*es[a];for(let q=0;q<3;q++)N[p][q]+=k*row[p]*row[q];}});}
     for(let p=0;p<3;p++)N[p][p]+=p===2?.5:.02;
     d=solve3(N,r);d[2]=Math.max(-.3,Math.min(.3,d[2]));
     // de pantalla a espacio local del padre
     const wd=[(R[3]*d[0]+R[6]*d[1])/fr.s,(R[4]*d[0]+R[7]*d[1])/fr.s,(R[5]*d[0]+R[8]*d[1])/fr.s],pid=n.parentId;
     if(pid!==-1){const P=mat3.fromMat4(mat3.create(),fr.A.world(pid)),I=mat3.invert(mat3.create(),P);vec3.transformMat3(tv,vec3.add(vec3.create(),tv,vec3.transformMat3(vec3.create(),wd,I)),mat3.create());}else vec3.add(tv,tv,wd);
    }
    Tk.push([fr.f,fr.seq,Array.from(tv)]);Sk.push([fr.f,fr.seq,Array.from(sv).map(v=>v*(1+d[2]))]);}
   const pack=(L,tol)=>selected.flatMap((_,j)=>{const l=L.filter(k=>k[1]===j);return decimate(l.map(k=>k[0]),l.map(k=>k[2]),tol).map(i=>`${l[i][0]}: {${l[i][2].join(',')}},`);});
   const repl=(tag,name,keys)=>{n.animations=n.animations.filter(a=>a.name!==tag);n.animations.push(track(tag,keys,name));};
   repl('KGTR','Translation',pack(Tk,TTOL/s0));repl('KGSC','Scaling',pack(Sk,STOL));
  }
  reskin(subP);fit(subP,fitted);
  const keyc=allNodes(m).reduce((a,n)=>a+n.animations.reduce((b,t)=>b+t.frames.length,0),0);console.error(id,'ronda',rd,'claves',keyc);
 }
 reskin(frames);
 const wallStats={moved:0,iterations:0,nativeOver:0,nativeVerts:0};
 m.geosets.forEach((g,gi)=>{for(let i=0;i<g.vertices.length/3;i++){let w=0;for(const fr of played){const v=fr.v,p=fr.pts[gi][i],k=focal/Math.max(near,p.depth);w=Math.max(w,Math.abs((vec3.dot(v.r,p.w)-vec3.dot(v.r,v.tg))*k)-XL,Math.abs((vec3.dot(v.u,p.w)-vec3.dot(v.u,v.tg))*k)-YL);}if(w>.01){wallStats.nativeVerts++;wallStats.nativeOver=Math.max(wallStats.nativeOver,w);}}});
 const predict=(fr,gi,i)=>{if(pinned[gi].has(i))return pinned[gi].get(i);const g=m.geosets[gi],a=fr.A[gi][g.vertexGroups[i]],x=fitted[gi][i*3],y=fitted[gi][i*3+1],z=fitted[gi][i*3+2],w=[a[0]*x+a[4]*y+a[8]*z+a[12],a[1]*x+a[5]*y+a[9]*z+a[13],a[2]*x+a[6]*y+a[10]*z+a[14]],R=fr.Rm,q=[0,1,2].map(r=>R[r*3]*w[0]+R[r*3+1]*w[1]+R[r*3+2]*w[2]+fr.T[r]);return [q[0]*ds,q[1]*fr.s,q[2]*fr.s];};
 // error frente al metodo anterior
 let e2=0,en=0,emax=0,xmax=0,over=0;const perSeq=selected.map(()=>[0,0,0]);
 for(const fr of frames)if(!/^stand/i.test(m.sequences[fr.si].name))m.geosets.forEach((g,gi)=>{for(let i=0;i<g.vertices.length/3;i++){const a=fr.A[gi][g.vertexGroups[i]],x=fitted[gi][i*3],y=fitted[gi][i*3+1],z=fitted[gi][i*3+2],w=[a[0]*x+a[4]*y+a[8]*z+a[12],a[1]*x+a[5]*y+a[9]*z+a[13],a[2]*x+a[6]*y+a[10]*z+a[14]],R=fr.Rm,q=[0,1,2].map(r=>R[r*3]*w[0]+R[r*3+1]*w[1]+R[r*3+2]*w[2]+fr.T[r]),o=[q[0]*ds,q[1]*fr.s,q[2]*fr.s],t=fr.t[gi][i],cut=p=>[Math.max(-VX,Math.min(VX,p[1])),Math.max(-VY,Math.min(VY,p[2]))],A1=cut(o),B1=cut(t),err=Math.hypot(A1[0]-B1[0],A1[1]-B1[1]);over=Math.max(over,Math.abs(o[1])-XL,Math.abs(o[2])-YL);
  e2+=err*err;en++;emax=Math.max(emax,err);xmax=Math.max(xmax,Math.abs(o[0]));const ps=perSeq[fr.seq];ps[0]+=err*err;ps[1]++;ps[2]=Math.max(ps[2],err);}});
 if(process.env.DUMP){const seqs=selected.map((si,j)=>j).filter(j=>!/^stand/i.test(m.sequences[selected[j]].name)),pick=[];
  for(const j of seqs){const fl=frames.filter(f=>f.seq===j);let best=null,be=-1;for(const fr of fl){let e=0;m.geosets.forEach((g,gi)=>{for(let i=0;i<g.vertices.length/3;i++){const o=predict(fr,gi,i),t=fr.t[gi][i];e+=Math.hypot(o[1]-t[1],o[2]-t[2]);}});if(e>be){be=e;best=fr;}}pick.push(best);}
  fs.writeFileSync(`${process.env.DUMP}/${id}.json`,JSON.stringify(pick.map(fr=>({name:m.sequences[fr.si].name,f:fr.f,faces:m.geosets.map(g=>Array.from(g.faces)),pred:m.geosets.map((g,gi)=>Array.from({length:g.vertices.length/3},(_,i)=>predict(fr,gi,i))),exact:fr.t}))));}
 report[id]={ds,s0,focal,distance,vertices:m.geosets.reduce((a,g)=>a+g.vertices.length/3,0),clampedVertices:clamped,pinned:pinned.reduce((a,p)=>a+p.size,0),rms:Math.sqrt(e2/en),max:emax,maxDepth:xmax,overflow:over,perSeq:selected.map((si,j)=>[m.sequences[si].name,+Math.sqrt(perSeq[j][0]/perSeq[j][1]).toFixed(3),+perSeq[j][2].toFixed(3)])};
 m.geosets.forEach((g,gi)=>{g.vertices=fitted[gi];for(const [i,t] of pinned[gi])g.vertices.set(t,i*3);});
 // pistas de vista y escala, por secuencia
 const keysR=[],keysT=[],keysS=[];
 selected.forEach((si,j)=>{const fs_=frames.filter(f=>f.seq===j),ts=fs_.map(f=>f.f);let prev=null;
  const qs=fs_.map(fr=>{const r=fr.Rm,q=quat.normalize(quat.create(),quat.fromMat3(quat.create(),mat3.transpose(mat3.create(),mat3.fromValues(...r))));if(prev&&quat.dot(prev,q)<0)quat.scale(q,q,-1);prev=q;return Array.from(q);});
  const trs=fs_.map(fr=>fr.T),scs=fs_.map(fr=>[ds,fr.s,fr.s]);
  for(const [out,vals,tol] of [[keysR,qs,.0015],[keysT,trs,.05],[keysS,scs,.0004]])for(const i of decimate(ts,vals,tol))out.push(`${ts[i]}: {${vals[i].join(',')}},`);});
 const n=allNodes(m).length,shift=3;
 const trf=new Model();trf.loadMdl(`Version {FormatVersion 800,} Model "Chain" {}Bone "PortraitBillboard" {ObjectId 0,Billboarded,GeosetId Multiple,GeosetAnimId None,}Helper "PortraitFlat" {ObjectId 1,Parent 0,Scaling ${keysS.length} {Linear,${keysS.join('')}}}Helper "PortraitView" {ObjectId 2,Parent 1,Translation ${keysT.length} {Linear,${keysT.join('')}}Rotation ${keysR.length} {Linear,${keysR.join('')}}}PivotPoints 3 {{0,0,0},{0,0,0},{0,0,0},}`);
 // Las banderas de no heredar sacarian el hueso de la cadena, y skin() no las ve.
 for(const nd of allNodes(m))nd.flags&=~7;
 for(const nd of allNodes(m)){nd.objectId+=shift;nd.parentId=nd.parentId===-1?2:nd.parentId+shift;if('geosetId'in nd)nd.geosetId=-1;if('geosetAnimationId'in nd)nd.geosetAnimationId=-1;}
 for(const g of m.geosets){g.matrixIndices=new Uint32Array(Array.from(g.matrixIndices,v=>v+shift));g.normals=new Float32Array(g.vertices.length).map((_,i)=>i%3===0?1:0);}
 m.bones=[...trf.bones,...m.bones];m.helpers=[...trf.helpers,...m.helpers];m.pivotPoints=[...trf.pivotPoints,...m.pivotPoints];
 // Los ids siguen el orden de los bloques (huesos y luego ayudantes), como en el original; si se intercalan, el motor deja el modelo en reposo.
 const remap=new Map(allNodes(m).map((nd,i)=>[nd.objectId,i])),piv=m.pivotPoints.slice(),rank={KGTR:0,KGRT:1,KGSC:2};
 m.pivotPoints=allNodes(m).map(nd=>piv[nd.objectId]);
 for(const nd of allNodes(m)){nd.objectId=remap.get(nd.objectId);nd.parentId=nd.parentId===-1?-1:remap.get(nd.parentId);nd.animations.sort((x,y)=>rank[x.name]-rank[y.name]);}
 m.geosets.forEach((g,gi)=>{g.matrixIndices=new Uint32Array(Array.from(g.matrixIndices,v=>remap.get(v)));
  if(pinned[gi].size){const G=g.matrixGroups.length;g.matrixGroups=new Uint32Array([...g.matrixGroups,1]);g.matrixIndices=new Uint32Array([...g.matrixIndices,0]);for(const i of pinned[gi].keys())g.vertexGroups[i]=G;}});
 m.sequences=selected.map(si=>m.sequences[si]);m.cameras=[];m.geosetAnimations=[];m.name='Dialogue '+m.name;m.blendTime=200;
 for(const g of m.geosets)g.sequenceExtents=m.sequences.map(()=>g.extent);
 for(const mat of m.materials)for(const l of mat.layers)l.flags|=1|16|32;
 for(const ext of [m.extent,...m.sequences.map(s=>s.extent),...m.geosets.flatMap(g=>[g.extent,...g.sequenceExtents])]){ext.min.set([-40,-40,-40]);ext.max.set([40,40,40]);ext.boundsRadius=70;}
 for(const tex of m.textures){if(tex.replaceableId===2){tex.path='UI\\Dialogue\\PortraitBackground.blp';tex.replaceableId=0;}else if(tex.replaceableId===1){tex.path='UI\\Dialogue\\PortraitTeamColor.blp';tex.replaceableId=0;}else if(tex.path)tex.path='UI\\Dialogue\\Portraits\\'+tex.path.split('\\').at(-1);}
 // Pared: proyeccion sobre cada semiespacio con la cadena final del archivo. Mueve lo minimo el vertice
 // que cruza, solo en la posicion de reposo, de modo que queda dentro en todos los fotogramas sin anadir claves.
 for(const fr of played)fr.F=skin(m,fr.seq,fr.f);
 m.geosets.forEach((g,gi)=>{for(let i=0;i<g.vertices.length/3;i++){if(pinned[gi].has(i))continue;
  const v=[g.vertices[i*3],g.vertices[i*3+1],g.vertices[i*3+2]],gr=g.vertexGroups[i];let moved=false,worst=1;
  for(let pass=0;pass<2000&&worst>.001;pass++){worst=0;
   for(const fr of played){const a=fr.F[gi][gr];for(const [o,lim] of [[1,XL-.02],[2,YL-.02]]){const row=[a[o],a[o+4],a[o+8]],val=row[0]*v[0]+row[1]*v[1]+row[2]*v[2]+a[o+12],e=Math.abs(val)-lim;
    if(e>0){const n=row[0]*row[0]+row[1]*row[1]+row[2]*row[2],st=Math.sign(val)*e/n;for(let c=0;c<3;c++)v[c]-=st*row[c];worst=Math.max(worst,e);moved=true;}}}
   wallStats.iterations++;}
  if(moved){wallStats.moved++;g.vertices.set(v,i*3);}
  wallStats.left=Math.max(wallStats.left||0,worst);
 }});
 let fe=0,fn=0,fm=0;for(const fr of played)m.geosets.forEach((g,gi)=>{for(let i=0;i<g.vertices.length/3;i++){const a=fr.F[gi][g.vertexGroups[i]],x=g.vertices[i*3],y=g.vertices[i*3+1],z=g.vertices[i*3+2],t=fr.t[gi][i],cl=(u,l)=>Math.max(-l,Math.min(l,u)),e=Math.hypot(cl(a[1]*x+a[5]*y+a[9]*z+a[13],VX)-cl(t[1],VX),cl(a[2]*x+a[6]*y+a[10]*z+a[14],VY)-cl(t[2],VY));fe+=e*e;fn++;fm=Math.max(fm,e);}});
 report[id].final={rms:Math.sqrt(fe/fn),max:fm};
 report[id].wall=wallStats;report[id].keys={R:keysR.length,T:keysT.length,S:keysS.length};report[id].nodes=n+shift;
 const file=path.join(outDir,id+'.mdx');save(m,file);report[id].bytes=fs.statSync(file).size;
}
fs.writeFileSync(path.join(outDir,'ajuste.json'),JSON.stringify(report,null,1));console.log(JSON.stringify(report));
