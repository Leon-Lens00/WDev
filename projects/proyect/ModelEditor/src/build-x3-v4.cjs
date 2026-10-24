// X3 identity pass: compact crescent shells and differentiated energy layers.
const k=require('./x3-effect-kit-v4.cjs');const {c,mesh,make,glow,sphere,lathe,ring,orbit,particle,trail,wake,finish}=k;
const PINK=[1,.08,.43],PALE=[1,.96,.99],BLUE=[.07,.47,1],GREEN=[.12,1,.22];
function crown(m,{radius=27,back=-63,front=-17,bone=0,white=false,compact=1}={}){
 const count=12,steps=12;
 for(let j=0;j<count;j++){
  const theta=j*2*Math.PI/count,vertices=[],uv=[],faces=[];
  for(let i=0;i<=steps;i++){
   const t=i/steps,x=(white?back+10:back)+(front-(white?back+10:back))*t;
   const r=(white?.90:1)*radius*Math.sin(t*Math.PI*.57),half=(white?.255:.23)*(Math.sin(Math.PI*t*.92)**.3);
   for(const side of [-1,1]){const a=theta+side*half+.06*Math.sin(Math.PI*t+j*.8);vertices.push(x+(white?0:(j%2?3:-2)*(1-t)**2),r*Math.cos(a),r*Math.sin(a));uv.push(t,side<0?0:1);}
   if(i){const q=(i-1)*2;faces.push(q,q+1,q+2,q+1,q+3,q+2);}
  }
  mesh(m,{v:vertices,uv,f:faces},white?PALE:PINK,white?.66:.64,2,bone,false,j*.7);
 }
}
function fringe(m,centerX,radius,color,bone=0){for(let j=0;j<8;j++){const a=j*Math.PI/4,vertices=[],uv=[],faces=[];for(let i=0;i<=6;i++){const t=i/6,x=centerX-22+25*t,r=radius*(.15+.85*Math.sin(t*Math.PI*.56)),w=.08+.16*Math.sin(Math.PI*t);for(const s of [-1,1]){vertices.push(x,r*Math.cos(a+s*w),r*Math.sin(a+s*w));uv.push(t,s<0?0:1);}if(i){const q=(i-1)*2;faces.push(q,q+1,q+2,q+1,q+3,q+2);}}mesh(m,{v:vertices,uv,f:faces},color,.5,3,bone,false,j);}}
function buster(m,cross=false){
 const radius=cross?21:27,front=-24,back=cross?-55:-64;
 crown(m,{radius,back,front});
 const coreProfile=cross?[[-46,0],[-42,9],[-35,16],[-28,19],[-24,18.5]]:[[-49,0],[-45,12],[-37,20],[-29,24.5],[-25,24]];
 lathe(m,coreProfile,PALE,cross?.40:.82,8);fringe(m,back+12,radius*.8,PINK);
 glow(m,[-35,0,0],17,radius*.9,PINK,.10);glow(m,[-33,0,0],11,radius*.75,PALE,.09);
 if(!cross){
  lathe(m,[[-15,0],[-22,8],[-28,16],[-28,18.5],[-21,15],[-14,8]],BLUE,.73,8);
  ring(m,[-27,0,0],0,18.2,1.05,2,[.18,.75,1],.43);
  glow(m,[-21,0,0],7,16,BLUE,.14);
  glow(m,[-62,0,0],11,4,BLUE,.38);sphere(m,[-62,0,0],[9,2.5,2.5],[.20,.72,1],.28);
 }else{
  lathe(m,[[-15,0],[-21,9],[-27,18],[-26,21],[-20,16],[-14,8]],PINK,.68,8);
  ring(m,[-25,0,0],0,20.5,1.2,2,[1,.19,.6],.5);glow(m,[-21,0,0],7,17,PINK,.10);
 }
 sphere(m,[-7.5,0,0],[7.5,8.5,8.5],[1,.98,1],.58);
 glow(m,[-7.5,0,0],7.5,10,cross?GREEN:[1,.3,.62],.12);
 glow(m,[-7.5,0,0],7.5,8,[1,.97,1],.16);
 particle(m,[-32,0,0],PINK,{size:13,rate:32,alpha:28,tex:7,spread:5});
 particle(m,[-21,0,0],cross?PINK:BLUE,{size:11,rate:30,alpha:32});
 particle(m,[-7.7,0,0],[1,.98,1],{size:5,rate:42,life:.14,alpha:100,tex:1});
 wake(m,[cross?-53:-59,0,0],PINK);trail(m,[-37,0,0],PINK,2.8,.075);trail(m,[-39,0,0],[1,.78,.93],.7,.12,0,.23);
 if(cross){
  const b=orbit(m,[-29.5,0,0]);for(const axis of [0,1]){ring(m,[-29.5,0,0],27.3,34,1.15,axis,GREEN,.58,b);ring(m,[-29.5,0,0],27.3,34,.32,axis,[.77,1,.64],.48,b);}
  particle(m,[-29.5,32,0],GREEN,{size:2.7,rate:14,life:.15,alpha:95,parent:b,tex:6});particle(m,[-29.5,-32,0],GREEN,{size:2.7,rate:14,life:.15,alpha:95,parent:b,tex:6});
 }
}
const colors={Verde:[.15,1,.25],Naranja:[1,.35,.035],Cian:[.10,.72,1]};
function orb(m,color,center=[-10.5,0,0],parent=0){
 // Short shell lobes around a hot center, sharing the charged pulse's color hierarchy.
 const x=center[0],y=center[1],z=center[2],vertices=[],uv=[],faces=[];
 for(let j=0;j<12;j++){const a=j*Math.PI/6,q=vertices.length/3;for(let i=0;i<=5;i++){const t=i/5,xx=x-17+15*t,r=9.5*Math.sin(t*Math.PI*.58);for(const s of [-1,1]){vertices.push(xx,y+r*Math.cos(a+s*.22),z+r*Math.sin(a+s*.22));uv.push(t,s<0?0:1);}if(i){const n=q+(i-1)*2;faces.push(n,n+1,n+2,n+1,n+3,n+2);}}}
 mesh(m,{v:vertices,uv,f:faces},color,.50,2,parent);sphere(m,[x+5.5,y,z],[5,5.3,5.3],[1,1,.95],.32,parent);glow(m,[x+1,y,z],9.5,13,color,.18,parent);glow(m,[x+4.5,y,z],6,7,[1,1,.96],.12,parent);
 particle(m,[x+3,y,z],color,{size:9,rate:42,alpha:85,parent,tex:0,life:.16});particle(m,[x+4,y,z],[1,1,.94],{size:4,rate:36,alpha:95,parent,tex:1,life:.14});wake(m,[x-16,y,z],color,parent,true);trail(m,[x-5,y,z],color,1.6,.08,parent,.34);
}
const entries=[];let m=make('X3_Buster_Cargado');buster(m);entries.push(finish(m,'A-Buster'));
for(const [name,color] of Object.entries(colors)){m=make('X3_Orbe_'+name);orb(m,color);entries.push(finish(m,'B-Orbes-individuales/'+name));}
m=make('X3_Grupo_Orbital');const b=orbit(m,[-10.5,0,0]);[colors.Verde,colors.Naranja].forEach((color,i)=>orb(m,color,[-10.5,23*Math.cos(i*Math.PI),23*Math.sin(i*Math.PI)],b));entries.push(finish(m,'B-Grupo-visual'));
m=make('X3_Cross_Buster');buster(m,true);entries.push(finish(m,'C-Buster-fusionado'));
m=make('X3_Conjunto_Fusionado');buster(m,true);const satellites=orbit(m,[-64,0,0]);for(let i=0;i<4;i++){const angle=i*Math.PI/2;orb(m,i%2?colors.Naranja:colors.Verde,[-64,22*Math.cos(angle),22*Math.sin(angle)],satellites);}entries.push(finish(m,'C-Grupo-visual'));
m=make('X3_Flash_Union',true);glow(m,[0,0,0],19,22,[.78,1,.8],.35);for(const axis of [0,1])ring(m,[0,0,0],20,20,.9,axis,[.4,1,.5],.58);particle(m,[0,0,0],[.55,1,.62],{size:34,rate:2,life:.32,alpha:160,burst:true});particle(m,[0,0,0],[1,1,.96],{size:18,rate:2,life:.18,alpha:210,burst:true,tex:1});particle(m,[0,0,0],PINK,{size:2.2,rate:8,life:.24,alpha:170,burst:true,tex:6,speed:75,latitude:180});entries.push(finish(m,'C-Flash-union'));
c.fs.writeFileSync(c.path.join(k.ev,'build.json'),JSON.stringify({target:'Classic1.27b MDX800',revision:'V4 compact crescent/white core/differentiated trails',worldTrajectory:false,referenceStudy:'study/all-models.json',entries},null,2)+'\n');console.log(JSON.stringify(entries));
