// Conservative grid reduction: retained vertices/UVs are exact original samples.
const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),ev=c.path.join(root,'evidence/x3-v15'),out=c.path.join(root,'exports/megaman-x3-buster-v15');
const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');
const base=JSON.parse(c.fs.readFileSync(c.path.join(root,'evidence/x3-v14/build.json')));
const info=[],entries=[],textureJobs=new Map();
function scaleBound(m,id){const n=c.allNodes(m).find(n=>n.objectId===id);c.assert(n);let s=1;for(const a of n.animations)if(a.name==='KGSC')for(const v of a.values)s=Math.max(s,...Array.from(v,Math.abs));return s*(n.parentId<0?1:scaleBound(m,n.parentId));}
function gridFaces(rows,cols,kind){const a=[];for(let i=1;i<rows;i++)for(let j=1;j<cols;j++){const p=(i-1)*cols+j-1,q=p+cols;if(kind===0)a.push(p,q,p+1,p+1,q,q+1);else a.push(p,p+1,q,p+1,q+1,q);}return a;}
function simplify(m,g){
 const oldV=Array.from(g.vertices),oldUV=Array.from(g.uvSets[0]),oldN=Array.from(g.normals),faces=Array.from(g.faces),nv=oldV.length/3;
 if(g.uvSets.length!==1||g.matrixGroups.length!==1||g.matrixGroups[0]!==1||!g.vertexGroups.every(x=>x===0))return {reason:'non-rigid grid preserved',before:faces.length/3,after:faces.length/3};
 const bound=scaleBound(m,g.matrixIndices[0]),tol=.10/bound;
 // Connected components split independently animated-looking strips within one geoset.
 const par=Array.from({length:nv},(_,i)=>i);function find(i){while(par[i]!==i)i=par[i];return i;}function join(a,b){par[find(a)]=find(b);}
 for(let i=0;i<faces.length;i+=3){join(faces[i],faces[i+1]);join(faces[i],faces[i+2]);}
 const comps=new Map();for(let i=0;i<nv;i++){const id=find(i);if(!comps.has(id))comps.set(id,[]);comps.get(id).push(i);}
 const vv=[],nn=[],uv=[],ff=[],mapping=[];let maxRowError=0,removedRows=0;
 for(const ids of comps.values()){
  const set=new Set(ids),cf=faces.filter((x,i)=>set.has(faces[i-i%3]));const start=ids[0];let cols=cf[1]-start,kind=0;
  if(cols===1){cols=cf[2]-start;kind=1;}
  const rows=ids.length/cols;
  const matches=cols>=2&&Number.isInteger(rows)&&rows>=2&&ids.every((x,i)=>x===start+i)&&JSON.stringify(cf.map(x=>x-start))===JSON.stringify(gridFaces(rows,cols,kind));
  let keep=matches?Array.from({length:rows},(_,i)=>i):null;
  if(matches&&rows>2){
   const selected=new Set([0,rows-1]),stack=[[0,rows-1]];
   while(stack.length){const [a,b]=stack.pop();let max=0,which=-1;
    for(let r=a+1;r<b;r++){const t=(r-a)/(b-a);let error=0;
     for(let j=0;j<cols;j++){const x=start+r*cols+j,lo=start+a*cols+j,hi=start+b*cols+j;
      const pos=Math.hypot(...[0,1,2].map(k=>oldV[x*3+k]-(oldV[lo*3+k]*(1-t)+oldV[hi*3+k]*t)));
      const uvErr=Math.max(...[0,1].map(k=>Math.abs(oldUV[x*2+k]-(oldUV[lo*2+k]*(1-t)+oldUV[hi*2+k]*t))));
      error=Math.max(error,pos/tol,uvErr/.0005);
     }if(error>max){max=error;which=r;}
    }if(max>1){selected.add(which);stack.push([a,which],[which,b]);}else maxRowError=Math.max(maxRowError,max*tol*bound);
   }keep=[...selected].sort((a,b)=>a-b);
   // Curved quads can change between retained rows. Refine against the triangle surfaces.
   const all=Array.from({length:rows},(_,i)=>i);
   function sample(list,r,j,data,dim){let k=0;while(k<list.length-2&&list[k+1]<r)k++;const z=Math.min(cols-2,Math.floor(j)),u=(r-list[k])/(list[k+1]-list[k]),v=j-z,ids=[start+list[k]*cols+z,start+list[k+1]*cols+z,start+list[k]*cols+z+1,start+list[k+1]*cols+z+1],w=u+v<=1?[1-u-v,u,v,0]:[0,1-v,1-u,u+v-1];return Array.from({length:dim},(_,d)=>ids.reduce((s,id,i)=>s+data[id*dim+d]*w[i],0));}
   while(keep.length<rows){let worst=1,where=-1;
    for(let r=0;r<rows-1;r++)for(let j=0;j<cols-1;j++)for(const dr of [0,.25,.5,.75,1])for(const dj of [0,.25,.5,.75,1]){
     const a=sample(all,r+dr,j+dj,oldV,3),b=sample(keep,r+dr,j+dj,oldV,3),u=sample(all,r+dr,j+dj,oldUV,2),v=sample(keep,r+dr,j+dj,oldUV,2);
     const err=Math.max(Math.hypot(...a.map((x,k)=>x-b[k]))*bound/.18,Math.max(...u.map((x,k)=>Math.abs(x-v[k])))/.0009);
     if(err>worst){worst=err;where=r+dr;}
    }
    if(where<0)break;const missing=all.filter(x=>!keep.includes(x));missing.sort((a,b)=>Math.abs(a-where)-Math.abs(b-where));keep.push(missing[0]);keep.sort((a,b)=>a-b);
   }
   removedRows+=rows-keep.length;
  }
  const chosen=matches?keep.flatMap(i=>Array.from({length:cols},(_,j)=>start+i*cols+j)):ids;
  const offset=vv.length/3,remap=new Map(chosen.map((v,i)=>[v,offset+i]));
  for(const v of chosen){vv.push(...oldV.slice(v*3,v*3+3));nn.push(...oldN.slice(v*3,v*3+3));uv.push(...oldUV.slice(v*2,v*2+2));mapping.push(v);}
  const newFaces=matches?gridFaces(keep.length,cols,kind).map(x=>x+offset):cf.map(x=>remap.get(x));
  for(let i=0;i<newFaces.length;i+=3){const a=newFaces[i],b=newFaces[i+1],d=newFaces[i+2],ab=[0,1,2].map(k=>vv[b*3+k]-vv[a*3+k]),ac=[0,1,2].map(k=>vv[d*3+k]-vv[a*3+k]);const area=Math.hypot(ab[1]*ac[2]-ab[2]*ac[1],ab[2]*ac[0]-ab[0]*ac[2],ab[0]*ac[1]-ab[1]*ac[0]);if(area>1e-10)ff.push(a,b,d);}
 }
 g.vertices=Float32Array.from(vv);g.normals=Float32Array.from(nn);g.uvSets=[Float32Array.from(uv)];g.vertexGroups=new Uint8Array(vv.length/3);g.faces=Uint16Array.from(ff);g.faceGroups=Uint32Array.from([ff.length]);
 return {before:faces.length/3,after:ff.length/3,removedRows,maxRowError,scaleBound:bound,retainedVertexMapping:mapping};
}
for(const e of base.entries){
 const source=c.path.join(root,e.path);c.assert.equal(sha(source),e.sha256);const m=c.read(source),before=c.read(source),metrics=m.geosets.map(g=>simplify(m,g));
 // Remove only unreachable material/texture records; keep animation arrays and IDs otherwise.
 const usedM=new Set(m.geosets.map(g=>g.materialId));m.ribbonEmitters.forEach(r=>usedM.add(r.materialId));const matIds=[...usedM].sort((a,b)=>a-b),matMap=new Map(matIds.map((id,i)=>[id,i]));
 const texIds=new Set(m.particleEmitters2.map(p=>p.textureId));for(const id of matIds)for(const l of m.materials[id].layers){c.assert(!l.animations.some(a=>a.name==='KMTF'),'animated texture ID needs explicit handling');texIds.add(l.textureId);}
 const tids=[...texIds].sort((a,b)=>a-b),tmap=new Map(tids.map((id,i)=>[id,i]));
 m.materials=matIds.map(i=>m.materials[i]);for(const g of m.geosets)g.materialId=matMap.get(g.materialId);for(const p of m.ribbonEmitters)p.materialId=matMap.get(p.materialId);
 for(const mat of m.materials)for(const l of mat.layers)l.textureId=tmap.get(l.textureId);for(const p of m.particleEmitters2)p.textureId=tmap.get(p.textureId);
 m.textures=tids.map(i=>m.textures[i]);const folder=c.path.join(out,e.category);c.fs.mkdirSync(folder,{recursive:true});
 for(const t of m.textures){const input=c.path.join(c.path.dirname(source),...t.path.split('\\')),hash=sha(input),baseName=c.path.basename(input,'.blp'),name=baseName+'_'+hash.slice(0,8)+'.blp';t.path='X3BusterV15\\'+name;const dest=c.path.join(folder,'X3BusterV15',name);if(!textureJobs.has(hash))textureJobs.set(hash,{input,hash,baseName,name,targets:[]});textureJobs.get(hash).targets.push(dest);}
 const file=c.path.join(folder,e.name+'.mdx');c.save(m,file);
 // Exact semantic comparison of all non-geometry data after reversing reference remaps.
 const normalized=c.read(file);normalized.materials=before.materials;normalized.textures=before.textures;
 normalized.geosets=before.geosets;normalized.ribbonEmitters.forEach((r,i)=>r.materialId=before.ribbonEmitters[i].materialId);normalized.particleEmitters2.forEach((p,i)=>p.textureId=before.particleEmitters2[i].textureId);
 c.assert.deepEqual(c.plain(normalized),c.plain(before),'Non-geometry animation/particle contract');
 const entry={name:e.name,category:e.category,path:c.path.relative(root,file),sha256:sha(file),triangles:m.geosets.reduce((s,g)=>s+g.faces.length/3,0),pe2:m.particleEmitters2.length,ribbons:m.ribbonEmitters.length};entries.push(entry);
 info.push({name:e.name,source,sourceSha256:e.sha256,beforeBytes:c.fs.statSync(source).size,afterBytes:c.fs.statSync(file).size,beforeTriangles:e.triangles,afterTriangles:entry.triangles,beforeTextures:before.textures.length,afterTextures:m.textures.length,metrics,materialRemap:matIds,textureRemap:tids,semanticContract:'PASS'});
 console.log(e.name,e.triangles,'->',entry.triangles,c.fs.statSync(source).size,'->',c.fs.statSync(file).size);
}
c.fs.writeFileSync(c.path.join(ev,'geometry.json'),JSON.stringify(info,null,2));c.fs.writeFileSync(c.path.join(ev,'texture-jobs.json'),JSON.stringify([...textureJobs.values()],null,2));c.fs.writeFileSync(c.path.join(ev,'build.json'),JSON.stringify({...base,revision:'V15 conservative geometry and texture optimization',entries},null,2));
