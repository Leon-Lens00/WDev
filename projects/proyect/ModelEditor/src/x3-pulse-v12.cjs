// Travel along the approved envelope using UVs; never translate the projectile.
module.exports=function addPulse(m,k){
 const {c,track,mesh}=k;const shape=require('./x3-profile-v12.cjs');
 const L=n=>c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/'+n).default;
 const Texture=L('texture'),Material=L('material'),Layer=L('layer'),TA=L('textureanimation');
 const original=m.geosets.filter(g=>g.materialId===9);
 c.assert.equal(original.length,12,'Twelve longitudinal sheath strips required');
 const texture=new Texture();texture.path='X3BusterV12\\Pulse.blp';texture.wrapMode=0;
 const mat=new Material(),layer=new Layer();layer.flags=17;layer.filterMode=4;layer.textureId=m.textures.length;
 m.textures.push(texture);layer.textureAnimationId=m.textureAnimations.length;
 const period=240,travel=210;
 const uvFrames=[0,160],uvValues=[.70,.70],alphaFrames=[0,160],alphaValues=[0,0];
 for(let start=200;start<1160;start+=period){
  uvFrames.push(start,start+travel,start+period-1);uvValues.push(.70,-.70,-.70);
  alphaFrames.push(start,start+20,start+164,start+travel,start+period-1);alphaValues.push(0,.88,.88,0,0);
 }
 uvFrames.push(1160,1300,1720);uvValues.push(.70,.70,.70);
 alphaFrames.push(1160,1300,1720);alphaValues.push(0,0,0);
 const ta=new TA();ta.animations=[track('Vector3Animation','KTAT',uvFrames,uvValues.map(x=>[x,0,0]))];
 m.textureAnimations.push(ta);mat.layers.push(layer);const material=m.materials.length;m.materials.push(mat);
 // Copy the current rounded surface into a single additional geoset. Each strip maps
 // from nose U=0 to wake U=1, so decreasing translation sends light rearward.
 const v=[],uv=[],f=[];
 for(const g of original){
  const start=v.length/3;v.push(...g.vertices);f.push(...Array.from(g.faces,i=>i+start));
  for(let i=0;i<g.vertices.length/3;i++)uv.push(Math.floor(i/2)/(g.vertices.length/6-1),i%2);
 }
 const index=m.geosets.length;
 mesh(m,{v,uv,f},[1,1,1],1,material);
 m.geosetAnimations.at(-1).animations=[track('FloatAnimation','KGAO',alphaFrames,alphaValues)];
 // Staggered angular channels curve with the body; a fine hot core adds light
 // through a wider, softer green corona. Both use native AddAlpha (4).
 const arcTexture=new Texture();arcTexture.path='X3BusterV12\\Arc.blp';arcTexture.wrapMode=0;
 const arcTextureId=m.textures.length;m.textures.push(arcTexture);
 const accents=[],arcMaterials=[],arcAnimations=[],haloGeosets=[];
 for(let j=0;j<4;j++){
  const theta=j*Math.PI/2;
  const xs=[-4,-8,-13,-18,-23,-29,-35,-41,-47,-54,-62,-71,-81];
  const frames=[0,160],offsets=[.7,.7],values=[0,0],phase=j*30;
  for(let t=200;t<=1160;t+=5){
   const p=(t-200+phase)%120;
   frames.push(t);offsets.push(.7-1.4*Math.min(p/100,1));
   values.push(Math.min(p/10,1)*Math.max(0,Math.min((100-p)/10,1)));
  }
  frames.push(1300,1720);offsets.push(.7,.7);values.push(0,0);
  const arcTA=new TA();arcTA.animations=[track('Vector3Animation','KTAT',frames,offsets.map(x=>[x,0,0]))];
  const taIndex=m.textureAnimations.length;arcAnimations.push(taIndex);m.textureAnimations.push(arcTA);
  const arcMat=new Material(),arcLayer=new Layer();arcMat.priorityPlane=1;
  arcLayer.flags=17;arcLayer.filterMode=4;arcLayer.textureId=arcTextureId;arcLayer.textureAnimationId=taIndex;
  arcMat.layers.push(arcLayer);const id=m.materials.length;arcMaterials.push(id);m.materials.push(arcMat);
  for(const [width,alpha,color,list] of [[5.4,.72,[.04,1,.01],haloGeosets],[1.3,1,[.18,1,.04],accents]]){
   const v=[],uv=[],f=[];
   // Two crossed soft ribbons keep the lightning luminous at side and game angles.
   for(let plane=0;plane<2;plane++){
    const base=v.length/3;
    for(let q=0;q<xs.length;q++){
     const x=xs[q]+(q>0&&q<xs.length-1?1.1*Math.sin(q*1.7+j*2.1):0);
     const a=theta+.05*Math.sin(q*2.7+j),r=shape.radius(x)*.91+(q%2?1.4:-1.0);
     const w=width*Math.sin(Math.PI*(q+.5)/xs.length)**.65;
     const wy=plane?Math.cos(a):-Math.sin(a),wz=plane?Math.sin(a):Math.cos(a);
     for(const side of [-1,1]){v.push(x,r*Math.cos(a)+side*w*wy,r*Math.sin(a)+side*w*wz);uv.push(q/(xs.length-1),side<0?0:1);}
     if(q){const n=base+(q-1)*2;f.push(n,n+1,n+2,n+1,n+3,n+2);}
    }
   }
   list.push(m.geosets.length);mesh(m,{v,uv,f},color,alpha,id);
   m.geosetAnimations.at(-1).animations=[track('FloatAnimation','KGAO',frames,values.map(v=>v*alpha))];
  }
 }
 return {geoset:index,accentGeosets:accents,haloGeosets,arcMaterials,arcAnimations,arcTexture:arcTextureId,arcPeriodMs:120,arcTravelMs:100,arcPhaseMs:[0,30,60,90],material,texture:layer.textureId,textureAnimation:layer.textureAnimationId,periodMs:period,travelMs:travel,geometry:'rounded open wake; four jagged additive cores with soft halos',direction:'nose to rear (-X)',birthDeath:'remapped by x3-lifecycle-v12; flight fades at impact'};
};
