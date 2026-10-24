// Independent readback of every native life state and all texture dependencies.
const {fs,path,assert,read,Generic,dependency}=require('../../../ModelEditor/src/model.cjs');
const crypto=require('node:crypto'),war3=dependency('war3-model'),root=path.resolve(__dirname,'..');
const meta=JSON.parse(fs.readFileSync(path.join(root,'evidence/healthbar-models.json'))),contract=JSON.parse(fs.readFileSync(path.join(root,'exports/health-bars-horizontal-v1/healthbars.json'))),build=JSON.parse(fs.readFileSync(path.join(root,'latest-build.json')));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),result=[];
for(const spec of meta.results){
 const internal='UI/HealthBarsHorizontal/Health'+spec.name+'.mdx',file=path.join(root,'assets',internal),bytes=fs.readFileSync(file),m=read(file),other=war3.parseMDX(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));
 assert.equal(m.version,800);assert.equal(other.Sequences.length,101);assert.equal(other.Geosets.length,4);
 const life=new Generic(m,m.bones[1],1),v=new Float32Array(3),uv=m.textureAnimations[0].animations.find(t=>t.name==='KTAS');assert(uv);
 const normal=m.geosetAnimations[0].animations.find(t=>t.name==='KGAO'),critical=m.geosetAnimations[1].animations.find(t=>t.name==='KGAO');
 for(let p=0;p<=100;p++)for(const frame of m.sequences[p].interval){
  life.getScale(v,p,frame,0);assert(Math.abs(v[1]-Math.max(.0001,p/100))<1e-6);
  const idx=Array.from(uv.frames).indexOf(frame);assert(idx>=0);assert(Math.abs(uv.values[idx][0]-Math.max(.0001,p/100))<1e-6);
  for(const [track,expected] of [[normal,p>20?1:0],[critical,p>0&&p<=20?1:0]])assert.equal(track.values[Array.from(track.frames).indexOf(frame)][0],expected);
 }
 for(const texture of m.textures){
  let resolved=path.join(root,'assets',texture.path.replaceAll('\\','/'));
  if(texture.path.startsWith('ReplaceableTextures')){const icon=Object.values(contract.portraits).find(i=>i.nativePath===texture.path);assert(icon);resolved=icon.icon.file;assert.equal(sha(fs.readFileSync(resolved)),icon.icon.sha256);}
  assert(fs.existsSync(resolved));
 }
 const reextracted=path.join(build.build,'verified',internal);assert.deepEqual(fs.readFileSync(reextracted),bytes);
 result.push({model:internal,sha256:sha(bytes),states:101,sequenceEndpoints:202,vertices:m.geosets.reduce((n,g)=>n+g.vertices.length/3,0),bytes:bytes.length});
}
assert.equal(contract.enemy.portraitRect[0],367);assert.equal(contract.enemy.lifeRect[0],21);
assert.equal(sha(fs.readFileSync(build.map)),build.sha256);
const report={models:result,statesChecked:303,endpointsChecked:606,mapSha256:build.sha256,modelImportsEqualSource:true,allTextureDependenciesResolved:true,nativeTested:false};
fs.writeFileSync(path.join(root,'evidence/healthbar-model-validation.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report,null,2));
