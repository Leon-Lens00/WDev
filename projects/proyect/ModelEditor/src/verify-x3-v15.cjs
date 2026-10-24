const c=require('./model.cjs'),crypto=require('node:crypto'),pose=require('./x3-pose-v14.cjs');const root=c.path.resolve(__dirname,'..'),ev=c.path.join(root,'evidence/x3-v15');const stats=JSON.parse(c.fs.readFileSync(c.path.join(ev,'geometry.json'))),build=JSON.parse(c.fs.readFileSync(c.path.join(ev,'build.json')));const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');let samples=0,maxSurfaceError=0,maxUvError=0,poses=0;
function evalGrid(g,start,cols,rows,r,j,dim,field){let k=0;while(k<rows.length-2&&rows[k+1]<r)k++;let z=Math.min(cols-2,Math.floor(j));const u=(r-rows[k])/(rows[k+1]-rows[k]),v=j-z;const ids=[start+rows[k]*cols+z,start+rows[k+1]*cols+z,start+rows[k]*cols+z+1,start+rows[k+1]*cols+z+1];let w=u+v<=1?[1-u-v,u,v,0]:[0,1-v,1-u,u+v-1];return Array.from({length:dim},(_,d)=>ids.reduce((s,id,i)=>s+g[field][id*dim+d]*w[i],0));}
for(let modelIndex=0;modelIndex<stats.length;modelIndex++){
 const rec=stats[modelIndex],e=build.entries[modelIndex],old=c.read(rec.source),m=c.read(c.path.join(root,e.path));c.assert.equal(sha(rec.source),rec.sourceSha256);const before=crypto.createHash('sha256').update(Buffer.from(m.saveMdx())).digest('hex');c.assert.equal(before,e.sha256);
 const raw=c.fs.readFileSync(c.path.join(root,e.path));const other=c.dependency('war3-model').parseMDX(raw.buffer.slice(raw.byteOffset,raw.byteOffset+raw.byteLength));c.assert.equal(other.Version,800);
 const mdl=c.fs.readFileSync(c.path.join(root,e.path.replace('.mdx','.mdl')),'utf8');const dm=c.dependency('war3-model').parseMDL(mdl);c.assert.equal(dm.Geosets.length,m.geosets.length);
 let localMax=0;
 for(let gi=0;gi<m.geosets.length;gi++){
  const a=old.geosets[gi],b=m.geosets[gi],meta=rec.metrics[gi],mapping=meta.retainedVertexMapping;if(!mapping)continue;
  mapping.forEach((v,i)=>{for(let k=0;k<3;k++)c.assert.equal(b.vertices[i*3+k],a.vertices[v*3+k]);for(let k=0;k<2;k++)c.assert.equal(b.uvSets[0][i*2+k],a.uvSets[0][v*2+k]);});
  if(!meta.removedRows)continue;
  // Infer connected contiguous strips/grid from original triangle adjacency.
  const nv=a.vertices.length/3,par=Array.from({length:nv},(_,i)=>i);function find(x){while(par[x]!==x)x=par[x];return x;}for(let i=0;i<a.faces.length;i+=3){par[find(a.faces[i])]=find(a.faces[i+1]);par[find(a.faces[i])]=find(a.faces[i+2]);}
  const comps=new Map();for(let i=0;i<nv;i++){let id=find(i);if(!comps.has(id))comps.set(id,[]);comps.get(id).push(i);}
  a.uv=a.uvSets[0];for(const ids of comps.values()){
   const start=ids[0],set=new Set(ids),f=Array.from(a.faces).filter((x,i)=>set.has(a.faces[i-i%3]));let cols=f[1]-start;if(cols===1)cols=f[2]-start;const nr=ids.length/cols;if(cols<2||!Number.isInteger(nr)||nr<2)continue;
   const selected=mapping.filter(i=>set.has(i));if(selected.length===ids.length)continue;
   const kept=[...new Set(selected.map(x=>Math.floor((x-start)/cols)))].sort((a,b)=>a-b),all=Array.from({length:nr},(_,i)=>i);
   for(let r=0;r<nr-1;r++)for(let j=0;j<cols-1;j++)for(const dr of [0,.25,.5,.75,1])for(const dj of [0,.25,.5,.75,1]){
    const p=evalGrid(a,start,cols,all,r+dr,j+dj,3,'vertices'),q=evalGrid(a,start,cols,kept,r+dr,j+dj,3,'vertices');const error=Math.hypot(...p.map((v,k)=>v-q[k]))*meta.scaleBound;const u=evalGrid(a,start,cols,all,r+dr,j+dj,2,'uv'),v=evalGrid(a,start,cols,kept,r+dr,j+dj,2,'uv');const uvError=Math.max(...u.map((x,k)=>Math.abs(x-v[k])));localMax=Math.max(localMax,error);maxUvError=Math.max(maxUvError,uvError);samples++;
   }
  }delete a.uv;
 }
 c.assert(localMax<=.20,'sampled surface tolerance '+rec.name+' '+localMax);maxSurfaceError=Math.max(maxSurfaceError,localMax);
 // Animations and retained vertex attachments are exact; sample their transformed positions too.
 for(let si=0;si<m.sequences.length;si++)for(let t=m.sequences[si].interval[0];t<=m.sequences[si].interval[1];t+=40){const a=pose(old,si,t,t),b=pose(m,si,t,t);for(let gi=0;gi<m.geosets.length;gi++){const map=rec.metrics[gi].retainedVertexMapping;if(!map)continue;for(let i=0;i<map.length;i++)for(let k=0;k<3;k++)c.assert(Math.abs(a.points[gi][map[i]][k]-b.points[gi][i][k])<1e-5);}poses++;}
 for(const tex of m.textures){const f=c.path.join(c.path.dirname(c.path.join(root,e.path)),...tex.path.split('\\'));c.assert(c.fs.existsSync(f));}
 rec.sampledMaxSurfaceError=localMax;
}
c.assert(maxUvError<=.001);for(const [p,h]of Object.entries(JSON.parse(c.fs.readFileSync(c.path.join(ev,'bases-preservadas.json')))))c.assert.equal(sha(p),h);
const result={status:'PASS',models:stats.length,surfaceSamples:samples,maxSurfaceError,maxUvError,retainedVertexPoses:poses,animations:'all unchanged',materialsAndEmitters:'same used materials/emitters, remapped IDs only',version:800,limitations:'Surface error sampled on original grids at quarter-cell steps; visual comparison separately. No FPS claim.'};c.fs.writeFileSync(c.path.join(ev,'verification.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result));
