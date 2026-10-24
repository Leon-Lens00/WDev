// V14 changes only the travelling green sheath of the approved Cross Buster.
const k=require('./x3-effect-kit-v14.cjs'),{c,track,v3,bone,mesh,finish}=k;
const crypto=require('node:crypto'),L=n=>c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/'+n).default;
const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');
const old=JSON.parse(c.fs.readFileSync(c.path.join(k.root,'evidence/x3-v13/build.json')));
const entry=old.entries.find(e=>e.name==='X3_Cross_Buster'),source=c.path.join(k.root,entry.path),m=c.read(source);
c.assert.equal(sha(source),entry.sha256);
// Last four geosets are the two static rotating loops; leave all earlier layers intact.
c.assert.equal(m.geosets.length,65);m.geosets.splice(61);m.geosetAnimations=m.geosetAnimations.filter(g=>g.geosetId<61);
m.bones=m.bones.filter(b=>b.name!=='Fused green loops local roll');
for(const t of m.textures)t.path=t.path.replace('X3BusterV13','X3BusterV14');
const body=m.bones.find(b=>b.name.startsWith('Flight body')).objectId;
const duration=400,travel=320,interval=200;
const globalId=m.globalSequences.length;m.globalSequences.push(duration);
const frames=Array.from({length:81},(_,i)=>i*5);
// A sharp, round nose opens to the visible shoulder and tapers down the rear.
function radius(s){return s<=24?31*Math.sqrt(Math.max(.0001,1-((s-24)/24)**2)):31*Math.cos(Math.min(1,(s-24)/60)*Math.PI/2)**.9;}
function sample(age){
 const u=Math.min(1,age/travel),x=-.5-80*u,r=radius(-x);
 const smooth=t=>{t=Math.max(0,Math.min(1,t));return t*t*(3-2*t);};
 const alpha=smooth(age/20)*(1-smooth((age-190)/110));
 return {x,r,alpha:age<300?alpha:0};
}
const records=[];
function globalTrack(kind,name,values){const a=track(kind,name,frames,values);a.globalSequenceId=globalId;return a;}
function material(texture,colorAlpha,phase,kind){
 const mat=new (L('material'))(),l=new (L('layer'))();l.flags=17;l.filterMode=4;l.textureId=m.textures.findIndex(t=>t.path.endsWith(texture));c.assert(l.textureId>=0);l.alpha=1;
 const values=frames.map(t=>{const age=(t+phase)%duration,s=sample(age);const flicker=kind==='electric'?.70+.30*Math.sin(age*Math.PI/25+phase)**2:1;return s.alpha*colorAlpha*flicker;});
 l.animations=[globalTrack('FloatAnimation','KMTA',values)];mat.layers.push(l);mat.priorityPlane=1;
 const id=m.materials.length;m.materials.push(mat);return id;
}
function gate(){return track('FloatAnimation','KGAO',[0,70,180,300,400,1360,1500,1535,1580,2500],[0,.3,1,1,1,1,1,.3,0,0]);}
function add(data,color,mat,parent){const id=m.geosets.length;mesh(m,data,color,1,mat,parent);m.geosetAnimations.at(-1).animations=[gate()];return id;}
function irregular(a,phase){return 1+.028*Math.sin(a*13+phase)+.016*Math.sin(a*31+phase*.7);}
// Sweep the rim along X too: a flat YZ hoop becomes a vertical line in the game camera.
function sweep(a,phase){return -5.5*(1+Math.cos(a+phase*.6));}
// Tubular edge around the YZ section. All X coordinates are behind its moving front.
function edge(phase,width,depth){const v=[],uv=[],f=[],n=64,sides=4;
 for(let i=0;i<=n;i++)for(let j=0;j<=sides;j++){
  const a=i*2*Math.PI/n,b=j*2*Math.PI/sides,r=irregular(a,phase)+width*Math.cos(b);
  const x=sweep(a,phase)-depth*(1+Math.sin(b))-.6*(.5+.5*Math.sin(a*17+phase));
  v.push(x,r*Math.cos(a),r*Math.sin(a));uv.push(i/n,j/sides);
  if(i&&j){const p=(i-1)*(sides+1)+j-1,q=p+sides+1;f.push(p,q,p+1,p+1,q,q+1);}
 }return {v,uv,f};}
// Ragged tongues trail behind the rim; taper by width and texture, not a solid cone.
function flames(phase){const v=[],uv=[],f=[];
 for(let j=0;j<20;j++){
  const theta=j*2*Math.PI/20+phase*.3,len=10+7*(.5+.5*Math.sin(j*2.37+phase)),start=v.length/3;
  for(let q=0;q<=8;q++){
   const t=q/8;
   for(const side of [-1,1]){
    const a=theta+.12*Math.sin(t*6+j)*t+side*(.14*(1-t)**.8+.004),r=irregular(a,phase)*(1+.055*Math.sin(t*Math.PI));
    v.push(sweep(a,phase)-.8-len*t,r*Math.cos(a),r*Math.sin(a));uv.push(t,side<0?0:1);
   }
   if(q){const p=start+(q-1)*2;f.push(p,p+1,p+2,p+1,p+3,p+2);}
  }
 }return {v,uv,f};}
for(const phase of [0,200]){
 const id=bone(m,'Travelling green wave '+phase,[0,0,0],body),states=frames.map(t=>sample((t+phase)%duration));
 m.bones.at(-1).animations=[globalTrack('Vector3Animation','KGTR',states.map(s=>[s.x,0,0])),globalTrack('Vector3Animation','KGSC',states.map(s=>[.18+.82*s.r/31,s.r,s.r])),globalTrack('Vector4Animation','KGRT',frames.map(t=>{const a=.15*Math.sin((t+phase)*Math.PI/50);return [Math.sin(a/2),0,0,Math.cos(a/2)];}))];
 const geometry=[];
 geometry.push(add(edge(phase/200,.15,2.7),[.035,1,.02],material('Ring.blp',.72,phase,'halo'),id));
 geometry.push(add(flames(phase/200),[.10,1,.035],material('Filament.blp',.88,phase,'fire'),id));
 geometry.push(add(edge(phase/200,.025,.65),[.38,1,.15],material('Ring.blp',.95,phase,'electric'),id));
 records.push({phaseMs:phase,boneName:m.bones.at(-1).name,geosets:geometry});
}
const cross=finish(m,'C-Buster-fusionado'),entries=[cross];
for(const e of old.entries.filter(e=>e.name!=='X3_Cross_Buster')){
 const folder=c.path.join(k.out,e.category),oldFile=c.path.join(k.root,e.path);c.fs.cpSync(c.path.dirname(oldFile),folder,{recursive:true});
 const file=c.path.join(folder,c.path.basename(oldFile));c.assert.equal(sha(file),e.sha256);entries.push({...e,path:c.path.relative(k.root,file),preservedV13:true});
}
const waves={intervalMs:interval,travelMs:travel,clockMs:duration,globalId,alphaZeroFromMs:300,radiusWhenInvisible:sample(300).r,records,profile:frames.filter(t=>t<=travel).map(t=>({time:t,...sample(t)})),scope:'local wave only; root, body and existing lifecycle retained'};
c.fs.writeFileSync(c.path.join(k.ev,'waves.json'),JSON.stringify(waves,null,2));
const details={...old.details,X3_Cross_Buster:{...old.details.X3_Cross_Buster,flightGeosets:[...Array(52).keys(),...records.flatMap(r=>r.geosets)],localRingRollMs:null,waves}};
c.fs.writeFileSync(c.path.join(k.ev,'build.json'),JSON.stringify({target:old.target,revision:'V14 travelling green fire/electric wave',entries,details,sourceCross:{path:source,sha256:sha(source)},source:old.source,worldTrajectory:false},null,2));
console.log(JSON.stringify({cross,waves:{intervalMs:interval,travelMs:travel,visibleMs:300},preservedOtherModels:entries.length-1}));
