// MDX800: frame apertures, background, bounded signal and independent opening line.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const lib='/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/migracion-linux/runtime/node_modules';
const {parseMDX}=require(lib+'/war3-model'),Model=require(lib+'/mdx-m3-viewer/dist/cjs/parsers/mdlx/model').default;
const root=path.resolve(__dirname,'..'),H=140*809/1942,config=JSON.parse(fs.readFileSync(root+'/evidence/visual-design.json')).transition;
const open=config.lineOpen+config.unfold+config.acquire,close=config.loss+config.fold+config.lineClose,full=config.lineOpen+config.unfold,fold=config.loss+config.fold;
const seqs=[['Stand',1,1000],['Stand Alternate',2001,3000],['Birth',4001,4001+open],['Death',7001,7001+close],['Birth Alternate',10001,10001+open],['Death Alternate',13001,13001+close]];
const extent=`MinimumExtent {-3,-71,${-H/2}},MaximumExtent {1,71,${H/2}},BoundsRadius 78,`;
let mdl=`Version {FormatVersion 800,} Model "Conversation" {BlendTime 0,${extent}} Sequences ${seqs.length} {${seqs.map(([n,a,b])=>`Anim "${n}" {Interval {${a},${b}},${n.startsWith('Stand')?'':'NonLooping,'}${extent}}`).join('')}} GlobalSequences 1 {Duration 800,}`;
mdl+=`Textures 5 {${['FrameOpenRed','FrameOpenBlue','Signal','PortraitBackground','Line'].map(n=>`Bitmap {Image "UI\\Dialogue\\${n}.blp",}`).join('')}}`;
mdl+=`Materials 5 {${[0,1,2,3,4].map(i=>`Material {PriorityPlane ${i===2?2:0}, Layer {FilterMode ${i<2?'Transparent':i===2?'Blend':'None'},Unshaded,TwoSided,Unfogged,${i===2?'NoDepthSet,':''}static TextureID ${i},${i===2?'TVertexAnimId 0,':''}static Alpha 1,}}`).join('')}}`;
const quads=[[0,1,0,1,0,0,0],[0,1,0,1,0,1,0],[.063,.237,.148,.473,.05,2,0],[.766,.940,.148,.473,.05,2,0],[.056,.244,.140,.481,-3,3,0],[.759,.947,.140,.481,-3,3,0],[.033,.967,.499,.501,.06,4,1]];
// Grow only the inside bezel; base frame vertices, silhouette and panel join stay intact.
const bezel={horizontal:1.2,vertical:.85},dx=bezel.horizontal/140,dy=bezel.vertical/H;
for(const material of [0,1])for(const [l,r] of [[.063,.237],[.766,.940]]){
 const t=.148,b=.473;
 quads.push([l,l+dx,t,b,.09,material,0,[.060,.0618,t,b]],
  [r-dx,r,t,b,.09,material,0,[.2385,.2405,t,b]],
  [l+dx,r-dx,t,t+dy,.09,material,0,[.073,.227,.140,.1458]],
  [l+dx,r-dx,b-dy,b,.09,material,0,[.073,.227,.477,.487]]);
}
const keys=(array,interp='DontInterp')=>`${array.length} {${interp},${array.map(([t,a])=>`${t}: ${a},`).join('')}}`;
for(let i=0;i<quads.length;i++){
 const [l,r,t,b,x,material,bone,region]=quads[i],y1=(l-.5)*140,y2=(r-.5)*140,z1=(.5-t)*H,z2=(.5-b)*H,uv=material===2?.25:1;
 const [ul,ur,vt,vb]=region??[0,uv,0,uv];
 mdl+=`Geoset {Vertices 4 {{${x},${y1},${z1}},{${x},${y2},${z1}},{${x},${y2},${z2}},{${x},${y1},${z2}},} Normals 4 {{1,0,0},{1,0,0},{1,0,0},{1,0,0},} TVertices 4 {{${ul},${vt}},{${ur},${vt}},{${ur},${vb}},{${ul},${vb}},} VertexGroup {0,0,0,0,} Faces 1 6 {Triangles {{0,2,1,0,3,2},}} Groups 1 1 {Matrices {${bone}},} ${extent}${seqs.map(()=>`Anim {${extent}}`).join('')} MaterialID ${material},SelectionGroup 0,}`;
 const alpha=[];
 for(const [si,[name,a,b]] of seqs.entries()){
  const blue=si===1||si>=4,on=material===0?!blue:material===1?blue:true;
  if(material===4){alpha.push([a,name.startsWith('Birth')?1:0]);if(name.startsWith('Birth'))alpha.push([a+config.lineOpen,0]);if(name.startsWith('Death'))alpha.push([a+fold,1]);alpha.push([b,0]);}
  else if(!on)alpha.push([a,0],[b,0]);
  else if(material===2){if(name.startsWith('Birth'))alpha.push([a,0],[a+config.lineOpen,1],[a+full,1],[b,0]);else if(name.startsWith('Death'))alpha.push([a,0],[a+config.loss,1],[a+fold-1,1],[a+fold,0],[b,0]);else alpha.push([a,0],[b,0]);}
  else if(name.startsWith('Birth'))alpha.push([a,0],[a+config.lineOpen-1,0],[a+config.lineOpen,1],[b,1]);
  else if(name.startsWith('Death'))alpha.push([a,1],[a+fold-1,1],[a+fold,0],[b,0]);else alpha.push([a,1],[b,1]);
 }
 mdl+=`GeosetAnim {Alpha ${keys(alpha,material===2?'Linear':'DontInterp')} GeosetId ${i},}`;
}
const panel=[],line=[];
for(const [name,a,b] of seqs){if(name.startsWith('Birth')){panel.push([a,.0001],[a+config.lineOpen,.0001],[a+full,1],[b,1]);line.push([a,.0001],[a+config.lineOpen,1],[b,1]);}else if(name.startsWith('Death')){panel.push([a,1],[a+config.loss,1],[a+fold,.0001],[b,.0001]);line.push([a,1],[a+fold,1],[b,.0001]);}else{panel.push([a,1],[b,1]);line.push([a,1],[b,1]);}}
const scale=(arr,axis)=>`Scaling ${arr.length} {Linear,${arr.map(([t,v])=>`${t}: {1,${axis==='y'?v:1},${axis==='z'?v:1}},`).join('')}}`;
mdl+=`Bone "Panel" {ObjectId 0,Billboarded,GeosetId Multiple,GeosetAnimId None,${scale(panel,'z')}} Bone "Line" {ObjectId 1,Billboarded,GeosetId Multiple,GeosetAnimId None,${scale(line,'y')}} PivotPoints 2 {{0,0,0},{0,0,0},}`;
mdl+=`TextureAnims 1 {TVertexAnim {Translation 17 {DontInterp,GlobalSeqId 0,${Array.from({length:17},(_,i)=>`${i*50}: {${i%4*.25},${Math.floor(i%16/4)*.25},0},`).join('')}}}}`;
const m=new Model();m.loadMdl(mdl);const bytes=Buffer.from(m.saveMdx()),check=parseMDX(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));assert.equal(check.Version,800);assert.equal(check.Geosets.length,quads.length);assert.equal(check.Sequences.length,6);
fs.writeFileSync(root+'/assets/UI/Dialogue/Conversation.mdl',mdl);fs.writeFileSync(root+'/assets/UI/Dialogue/Conversation.mdx',bytes);
fs.copyFileSync(root+'/assets/UI/Dialogue/Conversation.mdx','/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/dialogue/Conversation.mdx');
fs.writeFileSync(root+'/evidence/model.json',JSON.stringify({version:800,vertices:quads.length*4,triangles:quads.length*2,innerBezel:bezel,outerFrameUnchanged:true,sequences:seqs,transition:config,independentRoundtrip:true,textBaked:false,portraitsBaked:false},null,2));console.log('Layered MDX800 generated; opening/closing and signal share editor timings.');
