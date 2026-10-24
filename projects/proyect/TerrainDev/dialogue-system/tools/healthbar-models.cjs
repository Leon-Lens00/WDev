// Classic MDX800, native sequence-index life states. Same contract as UI Studio.
const {fs,path,assert,Model,dependency}=require('../../../ModelEditor/src/model.cjs');
const war3=dependency('war3-model');
const root=path.resolve(__dirname,'..'),out=path.join(root,'exports/health-bars-horizontal-v1');
const contract=JSON.parse(fs.readFileSync(path.join(out,'healthbars.json')));
const dest=path.join(root,'assets/UI/HealthBarsHorizontal');fs.mkdirSync(dest,{recursive:true});
for(const file of fs.readdirSync(path.join(out,'game/UI/HealthBarsHorizontal')))fs.copyFileSync(path.join(out,'game/UI/HealthBarsHorizontal',file),path.join(dest,file));
// Native calibration retained from the dialogue editor's measured camera plane.
const depth=400,scale=1.2,kx=.544*depth/718.1893054298849*scale,kz=.302*depth/387.7381926120089*scale;
const extent='MinimumExtent {-1,-1,-40},MaximumExtent {1,180,1},BoundsRadius 190,';
const seqs=Array.from({length:101},(_,i)=>[i,i*2000+1,i*2000+1001]);
const track=(type,values,vector=false)=>`${type} ${values.length} {DontInterp,${values.map(([t,v])=>`${t}: ${vector?'{'+v.join(',')+'}':v},`).join('')}}`;
const values=fn=>seqs.flatMap(([p,a,b])=>[[a,fn(p)],[b,fn(p)]]);
const results=[];
for(const [name,role,icon] of [['Hero',contract.player,contract.portraits.paladin],['EnemyTauren',contract.enemy,contract.portraits.tauren],['EnemyPaladin',contract.enemy,contract.portraits.paladin]]){
 const textures=[`UI\\HealthBarsHorizontal\\${role.frame}.blp`,`UI\\HealthBarsHorizontal\\${contract.fill.normal}.blp`,`UI\\HealthBarsHorizontal\\${contract.fill.critical}.blp`];if(icon)textures.push(icon.nativePath);
 let mdl=`Version {FormatVersion 800,} Model "Health${name}" {BlendTime 0,${extent}} Sequences 101 {${seqs.map(([p,a,b])=>`Anim "Stand - ${p}" {Interval {${a},${b}},${extent}}`).join('')}} Textures ${textures.length} {${textures.map(t=>`Bitmap {Image "${t}",}`).join('')}}`;
 mdl+=`Materials ${textures.length} {${textures.map((_,i)=>`Material {PriorityPlane ${i===0?1:i===3?0:2},Layer {FilterMode Blend,Unshaded,TwoSided,Unfogged,NoDepthTest,NoDepthSet,static TextureID ${i},${i===1||i===2?'TVertexAnimId 0,':''}static Alpha 1,}}`).join('')}}`;
 const [cw,ch]=role.contentRect.slice(2),[tw,th]=role.textureSize,[lx,ly,lw,lh]=role.lifeRect;
 const quads=[[0,0,cw,ch,0,0,[0,0,cw/tw,ch/th]], [lx,ly,lw,lh,1,1,[0,0,1,1]],[lx,ly,lw,lh,2,1,[0,0,1,1]]];
 if(icon)quads.push([...role.portraitRect,3,0,[0,0,1,1]]);
 for(const [i,[x,y,w,h,mat,bone,uv]] of quads.entries()){
  const [u,v,ur,vb]=uv,px=mat===0?0:mat===3?-.04:.04;
  mdl+=`Geoset {Vertices 4 {{${px},${x*kx},${-y*kz}},{${px},${(x+w)*kx},${-y*kz}},{${px},${(x+w)*kx},${-(y+h)*kz}},{${px},${x*kx},${-(y+h)*kz}},} Normals 4 {{1,0,0},{1,0,0},{1,0,0},{1,0,0},} TVertices 4 {{${u},${v}},{${ur},${v}},{${ur},${vb}},{${u},${vb}},} VertexGroup {0,0,0,0,} Faces 1 6 {Triangles {{0,2,1,0,3,2},}} Groups 1 1 {Matrices {${bone}},}${extent}${seqs.map(()=>`Anim {${extent}}`).join('')} MaterialID ${mat},SelectionGroup 0,}`;
  if(mat===1||mat===2)mdl+=`GeosetAnim {${track('Alpha',values(p=>p>0&&((mat===2)===(p<=20))?1:0))}GeosetId ${i},}`;
 }
 mdl+=`Bone "Screen" {ObjectId 0,Billboarded,GeosetId Multiple,GeosetAnimId None,} Bone "Life" {ObjectId 1,Parent 0,GeosetId Multiple,GeosetAnimId None,${track('Scaling',values(p=>[1,Math.max(.0001,p/100),1]),true)}} PivotPoints 2 {{0,0,0},{0,${lx*kx},${-(ly+lh/2)*kz}},}`;
 mdl+=`TextureAnims 1 {TVertexAnim {${track('Scaling',values(p=>[Math.max(.0001,p/100),1,1]),true)}}}`;
 const model=new Model();model.loadMdl(mdl);const bytes=Buffer.from(model.saveMdx()),again=new Model();again.loadMdx(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));
 const second=war3.parseMDX(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));assert.equal(second.Version,800);assert.equal(second.Sequences.length,101);assert.equal(second.Geosets.length,quads.length);
 assert.deepEqual(again.sequences.map(s=>Array.from(s.interval)),seqs.map(([,a,b])=>[a,b]));
 fs.writeFileSync(path.join(dest,`Health${name}.mdx`),bytes);fs.writeFileSync(path.join(out,'sources',`Health${name}.mdl`),mdl);
 results.push({name,bytes:bytes.length,sequences:101,triangles:quads.length*2,textures});
}
fs.writeFileSync(path.join(root,'evidence/healthbar-models.json'),JSON.stringify({version:800,depth,scale,results,independentReaders:true,nativeTested:false},null,2)+'\n');console.log(JSON.stringify(results,null,2));
