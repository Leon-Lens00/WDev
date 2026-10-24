// Separate components: orbit, convergence and travel are owned by the game.
const k=require('./x3-effect-kit-v13.cjs'),shape=require('./x3-profile-v12.cjs');
const {c,track,v3,make,mesh,glow,lathe,ring,bone,particle,trail,finish}=k;
const crypto=require('node:crypto'),L=n=>c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/'+n).default;
const source=c.path.join(k.root,'exports/shots-vol-ii-anclaje/Shot II Blue.mdx');
const sourceOriginal=c.path.join(k.root,'../descargas/warcraft3/misiles/vinz/shots-vol-ii/originales/Shots Vol. II/Shot II Blue.mdx');
const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');
const entries=[],details={};
c.fs.mkdirSync(k.ev,{recursive:true});
const tint=(v,color)=>{const hi=Math.max(...v),lo=Math.min(...v);return v3(color.map(x=>lo+(hi-lo)*x));};
function sourceStack(m){
 const src=c.read(source),offset=m.textures.length;
 for(const t of src.textures){t.path='X3BusterV13\\'+c.path.basename(t.path.replaceAll('\\','/')).replace('Blue_Glow2','White_Glow2');m.textures.push(t);}
 const mat=src.materials[0];for(const l of mat.layers){l.textureId+=offset;l.alpha=1;l.flags=17;}
 const material=m.materials.length;m.materials.push(mat);return {src,offset,material};
}
function orb(name,color){
 const m=make('X3_Orbe_'+name),{src,offset,material}=sourceStack(m);
 const points=c.pose(src,0,100).points[0],tip=Math.max(...points.map(v=>v[0]));
 for(const a of [0,Math.PI/4])mesh(m,{v:points.flatMap(([x,y,z])=>[(x-tip)*.14,(y*Math.cos(a)-z*Math.sin(a))*.50,(y*Math.sin(a)+z*Math.cos(a))*.50]),uv:Array.from(src.geosets[0].uvSets[0]),f:Array.from(src.geosets[0].faces)},color,.85,material);
 glow(m,[-10,0,0],10,13,color,.85);
 glow(m,[-8,0,0],8,9,color.map(x=>.55+.45*x),.8);
 glow(m,[-7,0,0],7,6.5,[1,1,1],.72);
 glow(m,[-24,0,0],22,4.2,color,.55);
 lathe(m,[[0,0],[-2,4],[-6,7.5],[-12,8.5],[-19,6],[-30,2.5],[-42,0]],color,.18,1);
 const TA=L('textureanimation'),ta=new TA();ta.animations=[track('Vector3Animation','KTAT',[0,160,200,1160,1300,1720],[[0,0,0],[-2/3,0,0],[0,0,0],[-4,0,0],[0,0,0],[-1.75,0,0]])];
 m.materials[9].layers[0].textureAnimationId=m.textureAnimations.length;m.textureAnimations.push(ta);m.textures[9].wrapMode=1;
 for(let j=0;j<10;j++){
  const v=[],uv=[],f=[];
  for(let q=0;q<=24;q++){
   const t=q/24,x=-.28-(38+(j%3)*3)*t,r=shape.radius(x/.42)*.52;
   for(const side of [-1,1]){const a=j*Math.PI/5+.06*Math.sin(t*8+j)*t+side*(.36*(1-t)**.7+.01)*Math.min(1,t/.1);v.push(x,r*Math.cos(a),r*Math.sin(a));uv.push(t*1.5+j*.11,side<0?0:1);}
   if(q){const n=(q-1)*2;f.push(n,n+1,n+2,n+1,n+3,n+2);}
  }mesh(m,{v,uv,f},color,.68,9);
 }
 // Source white-hot particles, with the hue separated from the value mask.
 for(const [name,pos,size,rate,speed,local] of [['F1',[-9,0,0],.26,22,0,true],['F2',[-13,0,0],.28,38,14,true],['Atras Uno',[-24,0,0],.22,30,24,false]]){
  const p=c.read(source).particleEmitters2.find(x=>x.name===name);p.name='Vinz adapted '+name;p.objectId=m.pivotPoints.length;p.parentId=0;p.flags=0x9000|(local?0x80000:0);p.textureId+=offset;p.segmentScaling=v3(Array.from(p.segmentScaling,x=>x*size));p.segmentColors=p.segmentColors.map(v=>tint(v,color));p.segmentAlphas[2]=0;p.speed=Math.fround(speed);p.lifeSpan=Math.fround(.24);p.latitude=18;p.width=p.length=0;p.variation=Math.fround(.3);p.animations=[track('FloatAnimation','KP2E',[0,160,200,1160,1300,1720],[rate,rate,rate,rate,0,0],0)];
  if(!local){const b=bone(m,'Rear residue direction',pos,0,Array(10).fill([0,-Math.SQRT1_2,0,Math.SQRT1_2]));p.objectId=m.pivotPoints.length;p.parentId=b;}
  m.particleEmitters2.push(p);m.pivotPoints.push(v3(pos));
 }
 const rear=bone(m,'Open wake',[-28,0,0],0,Array(10).fill([0,-Math.SQRT1_2,0,Math.SQRT1_2]));
 particle(m,[-28,0,0],color,{parent:rear,local:false,size:2.2,rate:42,life:.24,alpha:220,speed:65,latitude:14,tex:offset});
 trail(m,[-24,0,0],color,2.7,.16,0,.65);
 m.x3FlightStaticCount=m.geosets.length;
 details[m.name]=require('./x3-lifecycle-v13.cjs')(m,k,{tint:color,size:.5});
 entries.push(finish(m,'B-Orbes-individuales/'+name));
}
orb('Verde',[.12,1,.08]);orb('Naranja',[1,.26,.015]);orb('Cian',[.06,.74,1]);

// Reuse the approved flowing body, then give the fused shot its own proportions.
const approved=c.path.join(k.root,'exports/megaman-x3-buster-v12/A-Buster/X3_Buster_Cargado.mdx');
const m=c.read(approved);m.name='X3_Cross_Buster';
const pink=[1,.065,.36],sx=.78,sy=1.2;
for(const g of m.geosets)for(let i=0;i<g.vertices.length;i++)g.vertices[i]*=i%3===0?sx:sy;
for(const p of m.pivotPoints){p[0]*=sx;p[1]*=sy;p[2]*=sy;}
for(const t of m.textures)t.path=t.path.replace('X3BusterV12','X3BusterV13').replace('Blue_Glow2','White_Glow2');
for(let i=0;i<18;i++)m.geosetAnimations[i].color=tint(m.geosetAnimations[i].color,pink);
for(let i=52;i<m.geosetAnimations.length;i++)m.geosetAnimations[i].color=tint(m.geosetAnimations[i].color,pink);
for(const p of m.particleEmitters2){p.segmentScaling=v3(Array.from(p.segmentScaling,x=>x*1.12));p.speed=Math.fround(p.speed*1.08);p.segmentColors=p.segmentColors.map(v=>tint(v,pink));}
for(const r of m.ribbonEmitters)r.color=tint(r.color,pink);
// Electricity remains secondary to two luminous, visibly volumetric green loops.
for(let i=44;i<52;i++)for(const a of m.geosetAnimations[i].animations)if(a.name==='KGAO')a.values=a.values.map(v=>v3([v[0]*.42]));
const flight=m.bones.find(b=>b.name.startsWith('Flight body')).objectId;
const spin=bone(m,'Fused green loops local roll',[-29,0,0],flight);
m.bones.at(-1).animations=[track('Vector4Animation','KGRT',[0,300,400,640,880,1120,1360,1500,2500],[0,Math.PI/3,0,Math.PI/2,Math.PI,1.5*Math.PI,2*Math.PI,0,0].map(a=>[Math.sin(a/2),0,0,Math.cos(a/2)]))];
const ringIds=[];
for(const axis of [0,1])for(const [width,color,alpha] of [[3.3,[.035,1,.035],.52],[.8,[.52,1,.26],.98]]){
 ringIds.push(m.geosets.length);ring(m,[-29,0,0],24,33,width,axis,color,alpha,spin);
 m.geosetAnimations.at(-1).animations=[track('FloatAnimation','KGAO',[0,80,180,300,400,640,880,1120,1360,1500,1550,1600,2500],[0,alpha*.4,alpha,alpha,alpha,alpha*.8,alpha,alpha*.8,alpha,alpha,alpha*.4,0,0])];
}
details[m.name]={flightGeosets:[...Array(52).keys(),...ringIds],impactGeosets:[52,53,54,55,56,57],approvedSource:sha(approved),shapeScale:[sx,sy,sy],worldTrajectory:false,localRingRollMs:960};
entries.push(finish(m,'C-Buster-fusionado'));

// Union flash: finite expansion, independent from the travelling result.
const flash=make('X3_Flash_Union',true);flash.bones[0].animations=[];
[[0,500],[600,1100],[1200,1700]].forEach((v,i)=>{flash.sequences[i].interval=Uint32Array.from(v);flash.sequences[i].nonLooping=1;});
const b=bone(flash,'Union expansion only',[0,0,0]);
const keys=[0,45,120,260,500],scales=[.15,.75,1.2,1.8,2.3];
const repeated=(kind,name,values,type=1)=>track(kind,name,[0,600,1200].flatMap(s=>keys.map(t=>s+t)),[0,600,1200].flatMap(()=>values),type);
flash.bones.at(-1).animations=[repeated('Vector3Animation','KGSC',scales.map(x=>[x,x,x]))];
glow(flash,[0,0,0],22,22,[1,.95,.98],.95,b);glow(flash,[0,0,0],31,31,pink,.6,b);
for(const axis of [0,1])ring(flash,[0,0,0],24,24,1.4,axis,[.32,1,.17],.8,b);
for(const ga of flash.geosetAnimations){const peak=Math.max(...ga.animations[0].values.map(v=>v[0]));ga.animations=[repeated('FloatAnimation','KGAO',[0,peak,peak*.8,peak*.2,0])];}
flash.textureAnimations.forEach(t=>t.animations=[repeated('Vector3Animation','KTAT',[[0,0,0],[.1,0,0],[.3,0,0],[.5,0,0],[1,0,0]])]);
for(const color of [pink,[.12,1,.08]]){
 const p=particle(flash,[0,0,0],color,{size:4.5,rate:85,life:.28,alpha:235,tex:6,local:false,speed:95,latitude:180,spread:0});
 p.animations=[track('FloatAnimation','KP2E',[0,25,140,500,600,625,740,1100,1200,1225,1340,1700],[0,85,0,0,0,85,0,0,0,85,0,0],0)];
}
details[flash.name]={finiteAllSequences:true,durationMs:500,center:'union origin',worldTrajectory:false};entries.push(finish(flash,'C-Flash-union'));

// Approved A is copied byte-for-byte, including its V12 texture namespace.
const approvedFolder=c.path.dirname(approved),copyFolder=c.path.join(k.out,'A-Buster-aprobado-V12');
c.fs.cpSync(approvedFolder,copyFolder,{recursive:true});
const aEntry=JSON.parse(c.fs.readFileSync(c.path.join(k.root,'evidence/x3-v12/build.json'))).entries[0];
entries.push({...aEntry,category:'A-Buster-aprobado-V12',path:c.path.relative(k.root,c.path.join(copyFolder,c.path.basename(approved))),preservedV12:true});
c.assert.equal(sha(c.path.join(copyFolder,c.path.basename(approved))),sha(approved));
c.fs.writeFileSync(c.path.join(k.ev,'build.json'),JSON.stringify({target:'Warcraft III Classic 1.27b / MDX800',revision:'V13 individual super-buster components',entries,details,source:{author:'Vinz',pack:'Shots Vol. II',path:sourceOriginal,sha256:sha(sourceOriginal)},worldTrajectory:false},null,2)+'\n');
console.log(JSON.stringify(entries,null,2));
