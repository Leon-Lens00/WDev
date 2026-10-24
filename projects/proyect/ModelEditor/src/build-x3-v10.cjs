// A V10: V7 preserved with an additional periodic luminous envelope sweep.
const k=require('./x3-effect-kit-v10.cjs');
const {c,track,v3,make,mesh,lathe,sphere,glow,bone,particle,trail,finish}=k;
c.assert.equal(c.path.basename(k.out),'megaman-x3-buster-v10','V10 must never write to an older export');
c.assert.equal(c.path.basename(k.ev),'x3-v10','V10 evidence destination');
const crypto=require('node:crypto');
const source=c.path.join(k.root,'exports/shots-vol-ii-anclaje/Shot II Blue.mdx');
const original=c.path.join(k.root,'../descargas/warcraft3/misiles/vinz/shots-vol-ii/originales/Shots Vol. II/Shot II Blue.mdx');
const base=c.read(source),m=make('X3_Buster_Cargado');
const BLUE=[.07,.44,1],CYAN=[.30,.83,1],PINK=[1,.025,.29],WHITE=[1,.92,.98];
const offset=m.textures.length;
for(const t of base.textures){t.path='X3BusterV10\\'+c.path.basename(t.path.replaceAll('\\','/'));m.textures.push(t);}
const material=base.materials[0];
for(const l of material.layers){l.textureId+=offset;l.alpha=1;l.flags=17;}
const materialId=m.materials.length;m.materials.push(material);
const posed=c.pose(base,0,100).points[0],maxX=Math.max(...posed.map(p=>p[0]));
// Extend only the rear section: the front 30 units retain their position.
const longerTail=x=>x<-30?x+(x+30)*.38:x;
for(const angle of [0,Math.PI/4]){
 const vertices=posed.flatMap(([x,y,z])=>[longerTail((x-maxX)*.36),(y*Math.cos(angle)-z*Math.sin(angle))*1.10,(y*Math.sin(angle)+z*Math.cos(angle))*1.10]);
 mesh(m,{v:vertices,uv:Array.from(base.geosets[0].uvSets[0]),f:Array.from(base.geosets[0].faces)},[.3333,.6,1],.88,materialId);
}
// One blue/cyan spindle reaches the origin, with a narrow luminous rear.
glow(m,[-29,0,0],29,23,BLUE,.7);
glow(m,[-27,0,0],27,14,CYAN,.65);
glow(m,[-23,0,0],23,9,[.88,.96,1],.8);
glow(m,[-59,0,0],42,8,BLUE,.58);
glow(m,[-52,0,0],34,3.5,CYAN,.36);
// A single continuous skin replaces the separate pink/white nose spheres.
const skin=lathe(m,[[0,0],[-1.5,3],[-6,7],[-14,10],[-25,10],[-42,7],[-64,3],[-96,0]],CYAN,.14,1);
// Radial UVs remove the opaque circular cap while keeping the front filled.
for(let i=0;i<skin.vertices.length/3;i++){
 skin.uvSets[0][i*2]=.5+skin.vertices[i*3+1]/28;
 skin.uvSets[0][i*2+1]=.5+skin.vertices[i*3+2]/28;
}
// The existing pink bow remains an outer flow, with no separate nose bead.
lathe(m,[[0,0],[-2,6],[-5,11],[-9,15],[-14,18],[-21,20]],PINK,.34,8);
// A UV streak travels toward increasing U (rear). Four exact repeat periods
// per Stand loop prevent a seam. The attached strip never translates.
const TA=c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/textureanimation').default;
const flow=new TA();flow.animations=[track('Vector3Animation','KTAT',[0,160,200,1160,1300,1720],[[0,0,0],[-2/3,0,0],[0,0,0],[-4,0,0],[0,0,0],[-1.75,0,0]])];
m.materials[9].layers[0].textureAnimationId=m.textureAnimations.length;m.textureAnimations.push(flow);m.textures[9].wrapMode=1;
for(let j=0;j<12;j++){
 const vs=[],uv=[],fs=[],theta=j*Math.PI/6;
 for(let q=0;q<=24;q++){
  const t=q/24,x=-.7-(91+(j%3)*7)*t;
  const radius=23*Math.sin(Math.min(t/.18,1)*Math.PI/2)*(1-.56*t);
  const half=(.31*(1-t)**.65+.008)*Math.min(1,t/.08);
  for(const side of [-1,1]){const a=theta+.09*Math.sin(t*9+j)*t+side*half;vs.push(x,radius*Math.cos(a),radius*Math.sin(a));uv.push(t*1.5+j*.117,side<0?0:1);}
  if(q){const n=(q-1)*2;fs.push(n,n+1,n+2,n+1,n+3,n+2);}
 }
 mesh(m,{v:vs,uv,f:fs},PINK,.8,9);
 // Short luminous leading edge, fading into broad moving pink streams.
 const v2=[],u2=[],f2=[];
 for(let q=0;q<=12;q++){
  const t=q/12,x=-.5-31*t,r=21*Math.sin(t*Math.PI/2);
  for(const side of [-1,1]){const a=theta+side*.065*(1-t);v2.push(x,r*Math.cos(a),r*Math.sin(a));u2.push(t,side<0?0:1);}
  if(q){const n=(q-1)*2;f2.push(n,n+1,n+2,n+1,n+3,n+2);}
 }
 mesh(m,{v:v2,uv:u2,f:f2},[1,.58,.75],.24,3);
}
// Adapt actual Vinz F1/F2/Atras properties (textures, color ramps, sizes,
// variation and head/tail roles), with new positions and emission windows.
function vinzEmitter(name,pos,scale,rate,speed,local,parent=0){
 const p=base.particleEmitters2.find(p=>p.name===name);c.assert(p,'Missing source emitter '+name);
 p.name='Vinz adapted '+name;p.objectId=m.pivotPoints.length;p.parentId=parent;p.flags=0x9000|(local?0x80000:0);p.textureId+=offset;
 p.segmentScaling=v3(Array.from(p.segmentScaling,x=>x*scale));p.speed=Math.fround(speed);p.lifeSpan=Math.fround(name==='F1'?.24:.32);p.latitude=Math.fround(name==='F1'?0:22);p.variation=Math.fround(name==='F1'?0:.5);p.tailLength=Math.fround(.15);p.width=p.length=0;
 p.animations=[track('FloatAnimation','KP2E',[0,160,200,1160,1300,1720],[rate,rate,rate,rate,0,0],0)];
 m.particleEmitters2.push(p);m.pivotPoints.push(v3(pos));return p;
}
vinzEmitter('F1',[-24,0,0],.52,24,0,true);
vinzEmitter('F2',[-29,0,0],.65,48,28,true);
const q=[0,-Math.SQRT1_2,0,Math.SQRT1_2];
const rear=bone(m,'Blue residue direction',[-60,0,0],0,Array(10).fill(q));
vinzEmitter('Atras Uno',[-60,0,0],.50,36,40,false,rear);
vinzEmitter('Atras Dos Sq Tails',[-60,0,0],.40,34,85,false,rear);
// Pink flow continues rearward along the shoulder, then leaves luminous residue.
for(let j=0;j<6;j++){
 const a=j*Math.PI/3,pos=[-17,19*Math.cos(a),19*Math.sin(a)],b=bone(m,'Pink boundary stream '+j,pos,0,Array(10).fill(q));
 const p=particle(m,pos,PINK,{parent:b,size:2,rate:42,life:.29,alpha:180,speed:195,latitude:5,tex:offset});p.headOrTail=1;p.tailLength=Math.fround(.045);p.segmentScaling=v3([1.1,2.2,.3]);
}
const tail=bone(m,'Pink wake direction',[-72,0,0],0,Array(10).fill(q));
particle(m,[-72,0,0],PINK,{parent:tail,local:false,size:2.7,rate:40,life:.33,alpha:145,speed:55,latitude:14,tex:offset});
trail(m,[-61,0,0],[1,.12,.44],2,.18,0,.50);
const pulse=require('./x3-pulse-v10.cjs')(m,k);
const entry=finish(m,'A-Buster');
c.fs.writeFileSync(c.path.join(k.ev,'pulse.json'),JSON.stringify(pulse,null,2)+'\n');
const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');
c.fs.writeFileSync(c.path.join(k.ev,'build.json'),JSON.stringify({target:'Classic1.27b MDX800',revision:'V10 A 240ms pink sweep preserved, 120ms interior green lightning',entries:[entry],source:{author:'Vinz',pack:'Shots Vol. II',original:c.path.relative(k.root,original),sha256:sha(original),anchored:c.path.relative(k.root,source),anchoredSha256:sha(source),reuse:'posed geometry/UV and full additive stack; adapted F1/F2/Atras Uno/Atras Dos Sq Tails; attached bow/UV flow; blue rear lengthened 38% behind X=-30; continuous blue tip replaces separate nose spheres'},pulse,worldTrajectory:false},null,2)+'\n');
console.log(JSON.stringify(entry));
