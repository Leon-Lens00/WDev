// Original 3D study of the user-confirmed X3 forms; no source geometry is copied.
const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),out=c.path.join(root,'exports/megaman-x3-buster-v1'),ev=c.path.join(root,'evidence/x3-v1');
const load=n=>c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/'+n).default;
const Sequence=load('sequence'),Bone=load('bone'),Geoset=load('geoset'),GeoAnim=load('geosetanimation'),Extent=load('extent'),Material=load('material'),Layer=load('layer'),Texture=load('texture'),PE2=load('particleemitter2');
const animations=c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/animations');
const entries=[];
function track(kind,name,frames,values,interpolationType=1){const a=new animations[kind]();a.name=name;a.interpolationType=interpolationType;a.globalSequenceId=-1;a.frames=frames;a.values=values.map(v=>Float32Array.from(Array.isArray(v)?v:[v]));return a;}
const v3=(...v)=>Float32Array.from(v);
function model(name,flash=false){const m=new c.Model();m.name=name;m.version=800;
 for(const [n,from,to,once] of [['Birth',0,180,1],['Stand',200,1000,flash?1:0],['Death',1200,1700,1]]){const s=new Sequence();s.name=n;s.interval=new Uint32Array([from,to]);s.nonLooping=once;m.sequences.push(s);}
 const b=new Bone();b.name='Root';b.objectId=0;b.parentId=-1;b.geosetId=-1;b.geosetAnimationId=-1;
 b.animations=[track('Vector3Animation','KGSC',[0,80,180,200,1000,1200,1350,1700],flash?[[.03,.03,.03],[1,1,1],[2.4,2.4,2.4],[.03,.03,.03],[2.4,2.4,2.4],[1,1,1],[1.8,1.8,1.8],[2,2,2]]:[[.04,.04,.04],[.8,.8,.8],[1,1,1],[1,1,1],[1,1,1],[1,1,1],[.5,.5,.5],[.03,.03,.03]])];m.bones.push(b);m.pivotPoints.push(v3(0,0,0));
 for(const path of ['Band','Solid','Glow','Spark']){const t=new Texture();t.path='X3Buster\\'+path+'.blp';m.textures.push(t);const mat=new Material(),l=new Layer();l.textureId=m.materials.length;l.filterMode=4;l.flags=17;l.alpha=1;mat.layers.push(l);m.materials.push(mat);}
 for(const textureId of [0,1]){const mat=new Material(),l=new Layer();l.textureId=textureId;l.filterMode=4;l.flags=1;mat.layers.push(l);m.materials.push(mat);}
 return m;}
function rotatingBone(m,pivot=[0,0,0],period=800){const b=new Bone();b.name='Local orbital rotation';b.objectId=m.pivotPoints.length;b.parentId=0;b.geosetId=-1;b.geosetAnimationId=-1;
 const keys=[0,90,180,200,400,600,800,1000,1200,1450,1700],angles=[0,Math.PI/2,Math.PI,0,Math.PI/2,Math.PI,3*Math.PI/2,2*Math.PI,0,Math.PI,2*Math.PI];
 b.animations=[track('Vector4Animation','KGRT',keys,angles.map(a=>[Math.sin(a/2),0,0,Math.cos(a/2)]))];m.bones.push(b);m.pivotPoints.push(Float32Array.from(pivot));return b.objectId;}
function mesh(m,data,color,alpha=1,material=0,bone=0,flash=false){const g=new Geoset();g.vertices=Float32Array.from(data.vertices);g.normals=Float32Array.from(data.normals||data.vertices.map((v,i)=>i%3===2?1:0));g.faces=Uint16Array.from(data.faces);g.faceTypeGroups=new Uint32Array([4]);g.faceGroups=new Uint32Array([g.faces.length]);g.vertexGroups=new Uint8Array(g.vertices.length/3);g.matrixGroups=new Uint32Array([1]);g.matrixIndices=new Uint32Array([bone]);g.uvSets=[Float32Array.from(data.uv)];g.materialId=data.closed&&material<2?material+4:material;
 const a=new GeoAnim();a.geosetId=m.geosets.length;a.flags=2;a.color=Float32Array.from(color);a.alpha=Math.fround(alpha);
 a.animations=[track('FloatAnimation','KGAO',flash?[0,35,180,200,230,650,1000,1200,1300,1700]:[0,30,180,200,1000,1200,1320,1550,1700],flash?[0,alpha,0,0,alpha,0,0,alpha,.2*alpha,0]:[0,.7*alpha,alpha,alpha,alpha,alpha,.6*alpha,0,0])];
 m.geosets.push(g);m.geosetAnimations.push(a);return g;}
function lathe(profile,segments=16,offset=[0,0,0]){const vertices=[],normals=[],uv=[],faces=[];for(let i=0;i<profile.length;i++)for(let j=0;j<=segments;j++){const angle=2*Math.PI*j/segments,[x,r]=profile[i];vertices.push(x+offset[0],r*Math.cos(angle)+offset[1],r*Math.sin(angle)+offset[2]);normals.push(0,Math.cos(angle),Math.sin(angle));uv.push(i/(profile.length-1),j/segments);if(i&&j){const a=(i-1)*(segments+1)+j-1,b=a+segments+1;faces.push(a,a+1,b,a+1,b+1,b);}}return {vertices,normals,uv,faces,closed:true};}
function quad(center,u,v){const vertices=[],uv=[0,0,1,0,1,1,0,1];for(const [a,b] of [[-1,-1],[1,-1],[1,1],[-1,1]])vertices.push(...center.map((x,i)=>x+a*u[i]+b*v[i]));return{vertices,uv,faces:[0,1,2,0,2,3]};}
function halo(m,center,length,r,color,alpha=.25,bone=0){mesh(m,quad(center,[length,0,0],[0,r,0]),color,alpha,2,bone);mesh(m,quad(center,[length,0,0],[0,0,r]),color,alpha,2,bone);}
function torus(center,r,tube,axis=0){const vertices=[],normals=[],uv=[],faces=[],n=40,k=4;for(let i=0;i<=n;i++)for(let j=0;j<=k;j++){const a=i*2*Math.PI/n,b=j*2*Math.PI/k,rr=r+tube*Math.cos(b);let p=axis===0?[rr*Math.cos(a),rr*Math.sin(a),tube*Math.sin(b)]:axis===1?[rr*Math.cos(a),tube*Math.sin(b),rr*Math.sin(a)]:[tube*Math.sin(b),rr*Math.cos(a),rr*Math.sin(a)];vertices.push(...p.map((x,q)=>x+center[q]));normals.push(0,0,1);uv.push(i/n,j/k);if(i&&j){const a=(i-1)*(k+1)+j-1,b=a+k+1;faces.push(a,b,a+1,a+1,b,b+1);}}return{vertices,normals,uv,faces};}
function sparks(m,position,color,size=9,rate=18,modelSpace=false,parent=0){const p=new PE2();p.name=modelSpace?'Local luminous core':'Short residual glints';p.objectId=m.pivotPoints.length;p.parentId=parent;p.flags=0x9000|(modelSpace?0x80000:0);p.textureId=3;p.rows=1;p.columns=1;p.lifeSpan=Math.fround(.12);p.filterMode=1;p.emissionRate=rate;p.speed=0;p.width=0;p.length=0;p.timeMiddle=Math.fround(.35);p.segmentColors=[v3(1,1,1),Float32Array.from(color),Float32Array.from(color)];p.segmentAlphas=new Uint8Array([160,190,0]);p.segmentScaling=new Float32Array([size*.5,size,size*.15]);p.headIntervals=[new Uint32Array([0,0,1]),new Uint32Array([0,0,1])];p.tailIntervals=p.headIntervals.map(x=>new Uint32Array(x));p.animations=[track('FloatAnimation','KP2E',[0,180,200,1000,1200,1700],[rate,rate,rate,rate,0,0],0)];m.particleEmitters2.push(p);m.pivotPoints.push(Float32Array.from(position));}
function petals(m,scale=1,bone=0){for(let i=0;i<10;i++){const a=i*Math.PI/5,ca=Math.cos(a),sa=Math.sin(a),r=17*scale;const vertices=[-91*scale,r*.4*ca,r*.4*sa,-48*scale,r*1.35*ca,r*1.35*sa,-24*scale,r*.92*ca,r*.92*sa,-57*scale,r*.42*ca,r*.42*sa];const side=3.5*scale;for(let j=0;j<4;j++){vertices[j*3+1]+=j<2?-side*sa:side*sa;vertices[j*3+2]+=j<2?side*ca:-side*ca;}mesh(m,{vertices,uv:[0,.5,.4,0,1,.5,.4,1],faces:[0,1,2,0,2,3]},[1,.10,.52],.72,0,bone);}}
function charged(m,cross=false){const s=cross?1.18:1;
 mesh(m,lathe([[-88*s,0],[-70*s,5],[-55*s,10],[-32*s,14],[-20*s,10]]),[.05,.32,1],.65);petals(m,s);
 mesh(m,lathe([[-75*s,0],[-58*s,10],[-43*s,23],[-31*s,29],[-24*s,29],[-20*s,24],[-20*s,0]],24),[1,.10,.46],.72);
 mesh(m,lathe([[-60*s,0],[-47*s,12],[-35*s,23],[-26*s,25],[-20*s,21],[-20*s,0]],24),[1,.72,.90],.72);
 mesh(m,lathe([[-23*s,0],[-22*s,15],[-17*s,18],[-11*s,16],[-7*s,10],[-7*s,0]],24),cross?[.18,1,.25]:[.04,.48,1],.90,1);
 mesh(m,lathe([[-13*s,0],[-11*s,6],[-7*s,8],[-2*s,6],[0,0]],20),[1,.96,1],.95,1);
 halo(m,[-52*s,0,0],48*s,29*s,[1,.10,.47],.18);halo(m,[-14*s,0,0],13*s,20*s,cross?[.3,1,.35]:[.08,.45,1],.18);
 if(cross){const b=rotatingBone(m,[-44,0,0]);mesh(m,torus([-44,0,0],40,1.25,0),[.22,1,.17],.85,1,b);mesh(m,torus([-44,0,0],40,1.25,1),[.45,1,.3],.65,1,b);sparks(m,[-29,0,0],[.3,1,.15],7,16,true);}
 sparks(m,[-72*s,0,0],[1,.15,.52],6,18,false);sparks(m,[-9,0,0],[1,.8,.98],4,12,true);}
const colors={Verde:[.18,1,.13],Naranja:[1,.4,.025],Cian:[.4,.9,1]};
function orb(m,color,center=[-13,0,0],bone=0){const profile=Array.from({length:9},(_,i)=>{const a=-Math.PI/2+i*Math.PI/8;return[center[0]+13*Math.sin(a),13*Math.cos(a)];});mesh(m,lathe(profile,12,[0,center[1],center[2]]),color,.9,0,bone);
 const core=Array.from({length:7},(_,i)=>{const a=-Math.PI/2+i*Math.PI/6;return[center[0]+8*Math.sin(a),8*Math.cos(a)];});mesh(m,lathe(core,12,[0,center[1],center[2]]),[1,1,.93],.8,0,bone);halo(m,[-23,center[1],center[2]],23,23,color,.46,bone);sparks(m,center,color,7,16,true,bone);}
function finish(m,category){let points=[];for(let si=0;si<m.sequences.length;si++)for(const t of c.frames(m,si,20))points.push(...c.pose(m,si,t).points.flat());
 for(const g of m.geosets){c.assignBounds(g.extent,points);for(const s of m.sequences){const e=new Extent();c.assignBounds(e,points);g.sequenceExtents.push(e);}}
 // Include the short particle/glow radius without reducing the actual geometry bounds.
 const padded=points.flatMap(p=>[p.map(x=>x-18),p.map(x=>x+18)]);c.assignBounds(m.extent,padded);for(const s of m.sequences)c.assignBounds(s.extent,padded);
 const folder=c.path.join(out,category),file=c.path.join(folder,m.name+'.mdx');c.save(m,file);
 for(const t of m.textures){const p=c.path.join(folder,...t.path.split('\\'));c.fs.mkdirSync(c.path.dirname(p),{recursive:true});c.fs.copyFileSync(c.path.join(root,'assets/x3-v1',c.path.basename(t.path.replaceAll('\\','/'))),p);}
 entries.push({name:m.name,category,path:c.path.relative(root,file),sha256:crypto.createHash('sha256').update(c.fs.readFileSync(file)).digest('hex'),geosets:m.geosets.length,triangles:m.geosets.reduce((n,g)=>n+g.faces.length/3,0),pe2:m.particleEmitters2.length});}
let m=model('X3_Buster_Cargado');charged(m);finish(m,'A-Buster');
for(const [name,color] of Object.entries(colors)){m=model('X3_Orbe_'+name);orb(m,color);finish(m,'B-Orbes-individuales/'+name);}
m=model('X3_Grupo_Orbital');const b=rotatingBone(m,[-13,0,0]);Object.values(colors).forEach((color,i)=>orb(m,color,[-13,26*Math.cos(i*2*Math.PI/3),26*Math.sin(i*2*Math.PI/3)],b));finish(m,'B-Grupo-visual');
m=model('X3_Cross_Buster');charged(m,true);finish(m,'C-Buster-fusionado');
m=model('X3_Flash_Union',true);for(const axis of [0,1]){const q=axis===0?quad([0,0,0],[34,0,0],[0,34,0]):quad([0,0,0],[34,0,0],[0,0,34]);mesh(m,q,[.7,1,.65],1,2,0,true);}mesh(m,torus([0,0,0],24,1.2,0),[.4,1,.3],.9,1,0,true);finish(m,'C-Flash-union');
c.fs.mkdirSync(ev,{recursive:true});c.fs.writeFileSync(c.path.join(ev,'build.json'),JSON.stringify({target:'Classic 1.27b MDX800',revision:'first visual study v1',originalGeometryAndTextures:true,worldTrajectory:false,entries},null,2)+'\n');console.log(JSON.stringify(entries));
