// Bounded temporal reduction for the dialogue's baked, linear vertex rig only.
// Does not retime clips, alter the rig, or write to active map/UI assets.
const {assert,fs,path,dependency,read,plain,Generic,save}=require('./model.cjs');
const crypto=require('node:crypto');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const root=path.resolve(__dirname,'../..');
const outRoot=path.resolve(__dirname,'../exports/dialogue-portraits-optimized');
const evidence=path.resolve(__dirname,'../evidence/portrait-keys-20261022');
const source=path.join(root,'TerrainDev/dialogue-system/assets');
const tolerances=[0.005,0.01,0.02,0.05,0.1];

function reduceLinear(frames,values,tolerance) {
  assert(frames.length===values.length && frames.length>=2);
  assert(tolerance>=0 && Number.isFinite(tolerance));
  for(let i=0;i<frames.length;i++) {
    assert(Number.isFinite(frames[i]));
    if(i)assert(frames[i]>frames[i-1]);
    assert(values[i].length===3 && Array.from(values[i]).every(Number.isFinite));
  }
  const keep=new Set([0,frames.length-1]),stack=[[0,frames.length-1]];
  while(stack.length) {
    const [a,b]=stack.pop();let max=tolerance*tolerance,index=-1;
    for(let i=a+1;i<b;i++) {
      const t=(frames[i]-frames[a])/(frames[b]-frames[a]);let d=0;
      for(let j=0;j<3;j++)d+=(values[i][j]-(values[a][j]*(1-t)+values[b][j]*t))**2;
      if(d>max){max=d;index=i;}
    }
    if(index!==-1){keep.add(index);stack.push([a,index],[index,b]);}
  }
  return [...keep].sort((a,b)=>a-b);
}
function assertContract(m) {
  assert.equal(m.version,800);assert.equal(m.blendTime,200);
  for(const key of ['helpers','lights','attachments','particleEmitters','particleEmitters2','ribbonEmitters','eventObjects','collisionShapes','globalSequences','geosetAnimations','textureAnimations'])assert.equal(m[key].length,0,key);
  assert.equal(m.bones[0].objectId,0);assert.equal(m.bones[0].parentId,-1);
  assert.equal(m.bones[0].flags,264);assert.equal(m.bones[0].animations.length,0);
  assert(m.pivotPoints.every(p=>p.every(x=>x===0)),'Nonzero pivot');
  for(let i=0;i<m.sequences.length;i++) {
    const [a,b]=m.sequences[i].interval;assert(b>a);
    if(i)assert(a>m.sequences[i-1].interval[1],'Overlapping/unordered SEQS');
  }
  for(let i=1;i<m.bones.length;i++) {
    const b=m.bones[i];assert.equal(b.objectId,i);assert.equal(b.parentId,0);assert.equal(b.flags,256);
    assert.equal(b.animations.length,1);const a=b.animations[0];
    assert.equal(a.name,'KGTR');assert.equal(a.interpolationType,1);assert.equal(a.globalSequenceId,-1);
    assert.equal(a.inTans.length,0);assert.equal(a.outTans.length,0);
    for(let k=1;k<a.frames.length;k++)assert(a.frames[k]>a.frames[k-1]);
    for(const seq of m.sequences)for(const frame of seq.interval)assert(Array.from(a.frames).includes(frame),'Missing clip endpoint');
  }
  for(const g of m.geosets){assert(g.matrixGroups.every(n=>n===1));assert(g.matrixIndices.every(id=>id>=0&&id<m.bones.length));assert(g.vertexGroups.every(id=>id<g.matrixGroups.length));}
}
function reduceModel(m,tolerance) {
  assertContract(m);
  for(const b of m.bones.slice(1))for(const a of b.animations) {
    const keep=new Set();
    for(let i=0;i<a.frames.length;i++)if(!m.sequences.some(s=>a.frames[i]>=s.interval[0]&&a.frames[i]<=s.interval[1]))keep.add(i);
    for(const s of m.sequences) {
      const indices=Array.from(a.frames,(_,i)=>i).filter(i=>a.frames[i]>=s.interval[0]&&a.frames[i]<=s.interval[1]);
      const chosen=reduceLinear(indices.map(i=>a.frames[i]),indices.map(i=>a.values[i]),tolerance);
      chosen.forEach(i=>keep.add(indices[i]));
    }
    const indices=[...keep].sort((a,b)=>a-b);
    a.frames=Uint32Array.from(indices,i=>a.frames[i]);a.values=indices.map(i=>a.values[i]);
  }
}
function immutable(m) {
  return sha(JSON.stringify(m,function(key,value){
    // Only bone translation key arrays are permitted to change.
    if((key==='frames'||key==='values') && this.name==='KGTR')return undefined;
    return ArrayBuffer.isView(value)?Array.from(value):value;
  }));
}
function interpolateOther(keys,t) {
  let lo=0,hi=keys.length-1;
  if(t<=keys[lo].Frame)return keys[lo].Vector;
  if(t>=keys[hi].Frame)return keys[hi].Vector;
  while(hi-lo>1){let mid=(lo+hi)>>1;if(keys[mid].Frame<=t)lo=mid;else hi=mid;}
  const f=(t-keys[lo].Frame)/(keys[hi].Frame-keys[lo].Frame);
  return Array.from(keys[lo].Vector,(v,i)=>v*(1-f)+keys[hi].Vector[i]*f);
}
function verify(before,after,file,tolerance) {
  assertContract(after);assert.equal(immutable(before),immutable(after),'Immutable model data changed');
  const bin=fs.readFileSync(file),other=dependency('war3-model').parseMDX(bin.buffer.slice(bin.byteOffset,bin.byteOffset+bin.byteLength));
  const old=before.bones.map((b,i)=>new Generic(before,b,i)),now=after.bones.map((b,i)=>new Generic(after,b,i));
  for(let i=1;i<now.length;i++){
    const a=after.bones[i].animations[0],original=before.bones[i].animations[0],k=other.Bones[i].Translation.Keys;
    const originalIndices=new Map(Array.from(original.frames,(t,i)=>[t,i]));
    for(let j=0;j<a.frames.length;j++){
      const oldIndex=originalIndices.get(a.frames[j]);assert.notEqual(oldIndex,undefined,'New key time');
      assert.deepEqual(a.values[j],original.values[oldIndex],'Retained key changed');
    }
    const afterIndices=new Map(Array.from(a.frames,(t,i)=>[t,i]));
    for(let j=0;j<original.frames.length;j++)if(!before.sequences.some(s=>original.frames[j]>=s.interval[0]&&original.frames[j]<=s.interval[1]))assert(afterIndices.has(original.frames[j]),'Outside-sequence key removed');
    for(const s of before.sequences)for(const frame of s.interval)assert.deepEqual(a.values[afterIndices.get(frame)],original.values[originalIndices.get(frame)],'Clip endpoint changed');
    assert.deepEqual(k.map(k=>k.Frame),Array.from(a.frames));
    assert.deepEqual(k.map(k=>Array.from(k.Vector)),a.values.map(v=>Array.from(v)));
  }
  const stats={maxError:0,maxVertexError:0,checks:0,vertexChecks:0,sequences:[]};
  const a=new Float32Array(3),b=new Float32Array(3);
  const vertices=before.geosets.flatMap(g=>Array.from(g.vertexGroups,(group,i)=>({id:g.matrixIndices[group],p:Array.from(g.vertices.slice(i*3,i*3+3))})));
  for(let seq=0;seq<before.sequences.length;seq++) {
    const s=before.sequences[seq],frames=new Set(Array.from(before.bones[1].animations[0].frames).filter(t=>t>=s.interval[0]&&t<=s.interval[1]));
    // All original curves share this sampling grid; assert instead of assuming it.
    for(const bone of before.bones.slice(1))for(const t of bone.animations[0].frames)if(t>=s.interval[0]&&t<=s.interval[1])frames.add(t);
    const breaks=[...frames].sort((a,b)=>a-b);for(let i=1;i<breaks.length;i++)frames.add((breaks[i-1]+breaks[i])/2);
    const local={name:s.name,interval:Array.from(s.interval),maxError:0,maxVertexError:0,frames:frames.size,keysBefore:0,keysAfter:0};
    for(const bone of before.bones.slice(1))local.keysBefore+=Array.from(bone.animations[0].frames).filter(t=>t>=s.interval[0]&&t<=s.interval[1]).length;
    for(const bone of after.bones.slice(1))local.keysAfter+=Array.from(bone.animations[0].frames).filter(t=>t>=s.interval[0]&&t<=s.interval[1]).length;
    const independentKeys=other.Bones.map(b=>b.Translation?.Keys.filter(k=>k.Frame>=s.interval[0]&&k.Frame<=s.interval[1]));
    for(const t of [...frames].sort((a,b)=>a-b)) {
      const poses=[];
      for(let id=0;id<now.length;id++) {
        old[id].getTranslation(a,seq,t,0);now[id].getTranslation(b,seq,t,0);
        const error=Math.hypot(...Array.from(a,(v,j)=>v-b[j]));
        local.maxError=Math.max(local.maxError,error);stats.checks++;
        if(id){const independent=interpolateOther(independentKeys[id],t);assert(Math.hypot(...independent.map((v,j)=>v-b[j]))<0.00001,'Independent interpolation mismatch');}
        poses[id]=[Array.from(a),Array.from(b)];
      }
      for(const v of vertices) {
        const [a,b]=poses[v.id],error=Math.hypot(...v.p.map((p,j)=>(p+a[j])-(p+b[j])));
        local.maxVertexError=Math.max(local.maxVertexError,error);stats.vertexChecks++;
      }
    }
    assert(local.maxError<=tolerance+0.00001,'Error exceeds tolerance');
    stats.maxError=Math.max(stats.maxError,local.maxError);stats.maxVertexError=Math.max(stats.maxVertexError,local.maxVertexError);stats.sequences.push(local);
  }
  // Common unchanged billboard rotation preserves Euclidean errors. Unanimated
  // vertices are byte-identical; identical endpoint keys preserve loop seams.
  stats.bound='All linear breakpoints + midpoints; shared rigid billboard rotation preserves error norm. No native/game/FPS claim.';
  return stats;
}
function run() {
  fs.mkdirSync(evidence,{recursive:true});fs.mkdirSync(outRoot,{recursive:true});
  const manifest={created:new Date().toISOString(),target:'Classic 1.27b / MDX800',tolerances,selectedTolerance:0.02,models:[]};
  for(const id of ['paladin','tauren']) {
    const input=path.join(source,'UI/Dialogue/Portraits',id+'.mdx'),bytes=fs.readFileSync(input),before=read(input),base=path.join(evidence,'baseline',id+'.mdx');
    fs.mkdirSync(path.dirname(base),{recursive:true});if(fs.existsSync(base))assert.equal(sha(fs.readFileSync(base)),sha(bytes),'Baseline changed');else fs.writeFileSync(base,bytes);
    const original=path.join(root,'work/dialogue-animated-20261022/originals',id==='paladin'?'HeroPaladin_portrait.mdx':'Tauren_portrait.mdx');
    const entry={id,source:input,sourceSha256:sha(bytes),originalBytes:fs.statSync(original).size,originalSha256:sha(fs.readFileSync(original)),beforeBytes:bytes.length,beforeKeys:before.bones.reduce((s,b)=>s+b.animations.reduce((s,a)=>s+a.frames.length,0),0),candidates:[]};
    for(const tolerance of tolerances) {
      const model=read(input);reduceModel(model,tolerance);
      const out=path.join(outRoot,String(tolerance),'UI/Dialogue/Portraits',id+'.mdx');
      const saved=save(model,out),validation=verify(before,saved,out,tolerance),data=fs.readFileSync(out);
      entry.candidates.push({tolerance,path:out,sha256:sha(data),bytes:data.length,keys:saved.bones.reduce((s,b)=>s+b.animations.reduce((s,a)=>s+a.frames.length,0),0),validation});
      console.log(id,tolerance,data.length,entry.candidates.at(-1).keys,validation.maxError);
    }
    assert.equal(sha(fs.readFileSync(input)),entry.sourceSha256,'Active source changed during run');manifest.models.push(entry);
  }
  const textures=['UI/Dialogue/PortraitTeamColor.blp','UI/Dialogue/PortraitBackground.blp','UI/Dialogue/Portraits/Heropaladin.blp','UI/Dialogue/Portraits/Minotaur.blp'];
  manifest.textures=textures.map(p=>({path:p,bytes:fs.statSync(path.join(source,p)).size,sha256:sha(fs.readFileSync(path.join(source,p)))}));
  for(const t of tolerances)for(const p of textures){const dest=path.join(outRoot,String(t),p);fs.mkdirSync(path.dirname(dest),{recursive:true});fs.copyFileSync(path.join(source,p),dest);}
  fs.writeFileSync(path.join(evidence,'metrics.json'),JSON.stringify(manifest,null,2)+'\n');
  return manifest;
}
if(require.main===module){
  if(process.argv.includes('--verify')){
    const manifest=JSON.parse(fs.readFileSync(path.join(evidence,'metrics.json'))),results=[];
    for(const m of manifest.models){
      assert.equal(sha(fs.readFileSync(m.source)),m.sourceSha256,'Active source changed');
      for(const c of m.candidates){assert.equal(sha(fs.readFileSync(c.path)),c.sha256,'Candidate changed');const v=verify(read(m.source),read(c.path),c.path,c.tolerance);results.push({id:m.id,tolerance:c.tolerance,...v});console.log('verified',m.id,c.tolerance,v.maxError);}
    }
    fs.writeFileSync(path.join(evidence,'validation-latest.json'),JSON.stringify({created:new Date().toISOString(),results},null,2)+'\n');
  }else run();
}
module.exports={reduceLinear,reduceModel,assertContract,verify,run};
