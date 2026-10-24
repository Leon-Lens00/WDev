// A only: Shots II geometry/UV basis and a nose-to-rear plasma cycle.
const k=require('./x3-effect-kit-v5.cjs');
const {c,track,v3,make,mesh,lathe,sphere,glow,bone,particle,trail,finish}=k;
const crypto=require('node:crypto');
const source=c.path.join(k.root,'exports/shots-vol-ii-anclaje/Shot II Blue.mdx');
const original=c.path.join(k.root,'../descargas/warcraft3/misiles/vinz/shots-vol-ii/originales/Shots Vol. II/Shot II Blue.mdx');
const base=c.read(source),m=make('X3_Buster_Cargado');
const BLUE=[.035,.40,1],CYAN=[.24,.82,1],PINK=[1,.035,.37],WHITE=[1,.91,.98];
// Preserve actual Shots II UVs and material stack; fit the now-fixed tip.
const offset=m.textures.length;
for(const t of base.textures){t.path='X3BusterV5\\'+c.path.basename(t.path.replaceAll('\\','/'));m.textures.push(t);}
const material=base.materials[0];
for(const [i,l] of material.layers.entries()){l.textureId+=offset;l.alpha=Math.fround(i<2?.32:.11);l.flags=17;}
const materialId=m.materials.length;m.materials.push(material);
const posed=c.pose(base,0,100).points[0],maxX=Math.max(...posed.map(p=>p[0]));
for(const angle of [0,Math.PI/4]){
 const vertices=posed.flatMap(([x,y,z])=>[(x-maxX)*.36,(y*Math.cos(angle)-z*Math.sin(angle))*1.06,(y*Math.sin(angle)+z*Math.cos(angle))*1.06]);
 mesh(m,{v:vertices,uv:Array.from(base.geosets[0].uvSets[0]),f:Array.from(base.geosets[0].faces)},[.32,.78,1],.8,materialId);
}
// A continuous filled spindle, not the former open blue cup.
lathe(m,[[-79,0],[-61,5],[-39,14],[-23,17.5],[-12,15],[-5,7],[-2,0]],BLUE,.12,8);
lathe(m,[[-68,0],[-46,5],[-29,11],[-16,11.5],[-7,6],[-3,0]],CYAN,.08,8);
glow(m,[-31,0,0],29,24,BLUE,.42);
glow(m,[-25,0,0],22,14,CYAN,.23);
sphere(m,[-22,0,0],[18,8,8],[.42,.91,1],.20);
// The pink nose is joined to the blue body and reaches X=0 exactly.
sphere(m,[-5.5,0,0],[5.5,8.5,8.5],PINK,.36).uvSets[0].fill(.5);
sphere(m,[-5,0,0],[4.8,5.5,5.5],WHITE,.30).uvSets[0].fill(.5);
glow(m,[-5,0,0],5,10,PINK,.18);

// Two interleaved shells travel locally behind the tip. Their fade is zero
// at the reset, so no mesh jumps visibly from the rear back to the nose.
for(let phase=0;phase<2;phase++){
 const id=bone(m,'Plasma flow '+phase,[0,0,0]);
 const frames=[],translations=[],scales=[],opacity=[];
 for(const [start,end] of [[0,160],[200,1160],[1300,1720]]){
  const times=new Set([start,end]);for(let t=start;t<=end;t+=8)times.add(t);
  for(let t=start;t<=end;t++){const p=((t-start+phase*160)%320);if(p===0||p===319)times.add(t);}
  for(const t of [...times].sort((a,b)=>a-b)){
   const p=((t-start+phase*160)%320)/320;
   frames.push(t);translations.push([-1.5-48*p,0,0]);
   const r=.40+2.45*Math.sin(p*Math.PI*.83);scales.push([.45+1.5*p,r,r]);
   const fade=Math.min(1,p/.09)*Math.max(0,1-Math.max(0,p-.55)/.45);
   opacity.push(fade*(start===1300?Math.max(0,1-(t-start)/210):start===0?Math.min(1,(t-start)/100):1));
  }
 }
 m.bones.find(b=>b.objectId===id).animations=[track('Vector3Animation','KGTR',frames,translations),track('Vector3Animation','KGSC',frames,scales)];
 const geosetStart=m.geosets.length;
 lathe(m,[[0,0],[-1,3],[-3,6],[-5.5,7.5],[-8,8]],PINK,.32,8,id);
 lathe(m,[[-.2,0],[-1.4,2.8],[-3.4,5.6],[-5.5,6.8]],WHITE,.18,8,id);
 // Broad curved tongues give a continuous bow front and broken rear edge.
 for(let j=0;j<12;j++){
  const vs=[],uv=[],fs=[],theta=j*Math.PI/6;
  for(let q=0;q<=12;q++){
   const t=q/12,r=8*Math.sin(t*Math.PI*.51),x=-14*t;
   const half=.27*(1-.64*Math.max(0,(t-.4)/.6));
   for(const side of [-1,1]){const a=theta+half*side+.08*t;vs.push(x-(j%2)*1.5*t*t,r*Math.cos(a),r*Math.sin(a));uv.push(t,side<0?0:1);}
   if(q){const n=(q-1)*2;fs.push(n,n+1,n+2,n+1,n+3,n+2);}
  }
  mesh(m,{v:vs,uv,f:fs},PINK,.70,2,id);
  // A thin hot stripe, leaving saturated pink edges visible.
  const hot=vs.map((v,i)=>i%3===0?v+.12:v*.92);
  mesh(m,{v:hot,uv,f:fs},WHITE,.28,3,id);
 }
 for(let g=geosetStart;g<m.geosets.length;g++){
  const a=m.geosetAnimations[g],strength=a.alpha;
  a.animations=[track('FloatAnimation','KGAO',frames,opacity.map(x=>x*strength))];
 }
}
// Narrow local nose stream; residual particles remain in world space.
const q=[0,-Math.SQRT1_2,0,Math.SQRT1_2];
const rear=bone(m,'Flow from nose to rear',[-7,0,0],0,Array(10).fill(q));
particle(m,[-7,0,0],PINK,{parent:rear,size:3,rate:65,life:.24,alpha:95,speed:130,latitude:22,tex:7});
particle(m,[-40,0,0],CYAN,{size:7,rate:40,life:.16,alpha:38,tex:7,spread:4});
const residue=bone(m,'Rear residue direction',[-57,0,0],0,Array(10).fill(q));
particle(m,[-57,0,0],PINK,{parent:residue,local:false,size:2,rate:25,life:.32,alpha:120,speed:30,latitude:16,tex:0});
trail(m,[-43,0,0],PINK,1.25,.13,0,.34);
const entry=finish(m,'A-Buster');
const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');
c.fs.writeFileSync(c.path.join(k.ev,'build.json'),JSON.stringify({target:'Classic1.27b MDX800',revision:'V5 A blue body / nose-to-rear pink flow',entries:[entry],source:{author:'Vinz',pack:'Shots Vol. II',original:c.path.relative(k.root,original),sha256:sha(original),anchored:c.path.relative(k.root,source),anchoredSha256:sha(source),reuse:'posed geometry, UVs, material stack; compressed X0.36 and widened YZ1.06, new volume and flow geometry'},worldTrajectory:false},null,2)+'\n');
console.log(JSON.stringify(entry));
