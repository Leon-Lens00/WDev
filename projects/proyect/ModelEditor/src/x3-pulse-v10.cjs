// Travel along the approved envelope using UVs; never translate the projectile.
module.exports=function addPulse(m,k){
 const {c,track,mesh}=k;
 const L=n=>c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/'+n).default;
 const Texture=L('texture'),Material=L('material'),Layer=L('layer'),TA=L('textureanimation');
 const original=m.geosets.filter(g=>g.materialId===9);
 c.assert.equal(original.length,12,'V7 envelope must remain intact');
 const texture=new Texture();texture.path='X3BusterV10\\Pulse.blp';texture.wrapMode=0;
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
 // Copy the exact V7 surface into a single additional geoset. Each strip maps
 // from nose U=0 to wake U=1, so decreasing translation sends light rearward.
 const v=[],uv=[],f=[];
 for(const g of original){
  const start=v.length/3;v.push(...g.vertices);f.push(...Array.from(g.faces,i=>i+start));
  for(let i=0;i<g.vertices.length/3;i++)uv.push(Math.floor(i/2)/24,i%2);
 }
 const index=m.geosets.length;
 mesh(m,{v,uv,f},[1,1,1],1,material);
 m.geosetAnimations.at(-1).animations=[track('FloatAnimation','KGAO',alphaFrames,alphaValues)];
 // Four angular paths sit between the cyan spindle and the pink outer flow.
 // Alpha blend preserves their green hue over the bright additive body.
 const arcTexture=new Texture();arcTexture.path='X3BusterV10\\Arc.blp';arcTexture.wrapMode=0;
 const arcTextureId=m.textures.length;m.textures.push(arcTexture);
 const accents=[],arcMaterials=[],arcAnimations=[];
 for(let j=0;j<4;j++){
  const theta=.65+j*Math.PI/2;
  const xs=[-8,-13,-18,-23,-28,-33,-38,-43,-48,-54,-61,-69,-77];
  const rr=[8,13,18,14,18,13,16,12,14,9,11,6,3];
  const v=[],uv=[],f=[];
  for(let q=0;q<xs.length;q++){
   const a=theta+((q+j)%2?.10:-.09),r=rr[q]*(1+.08*Math.sin(q*2.3+j*1.9)),x=xs[q]+(q>0&&q<xs.length-1?1.8*Math.sin(q*1.7+j*2.1):0),width=.90*Math.sin(Math.PI*(q+.5)/xs.length)**.4;
   for(const side of [-1,1]){v.push(x,r*Math.cos(a)-side*width*Math.sin(a),r*Math.sin(a)+side*width*Math.cos(a));uv.push(q/(xs.length-1),side<0?0:1);}
   if(q){const n=(q-1)*2;f.push(n,n+1,n+2,n+1,n+3,n+2);}
  }
  const frames=[0,160],offsets=[.7,.7],values=[0,0],phase=j*30;
  for(let t=200;t<=1160;t+=5){
   const p=(t-200+phase)%120;
   frames.push(t);offsets.push(.7-1.4*Math.min(p/100,1));
   values.push(.96*Math.min(p/10,1)*Math.max(0,Math.min((100-p)/10,1)));
  }
  frames.push(1300,1720);offsets.push(.7,.7);values.push(0,0);
  const arcTA=new TA();arcTA.animations=[track('Vector3Animation','KTAT',frames,offsets.map(x=>[x,0,0]))];
  const arcMat=new Material(),arcLayer=new Layer();arcMat.priorityPlane=1;
  arcLayer.flags=17;arcLayer.filterMode=2;arcLayer.textureId=arcTextureId;
  arcLayer.textureAnimationId=m.textureAnimations.length;arcAnimations.push(m.textureAnimations.length);m.textureAnimations.push(arcTA);
  arcMat.layers.push(arcLayer);const id=m.materials.length;arcMaterials.push(id);m.materials.push(arcMat);
  accents.push(m.geosets.length);mesh(m,{v,uv,f},[.12,1,.04],1,id);
  m.geosetAnimations.at(-1).animations=[track('FloatAnimation','KGAO',frames,values)];
 }
 return {geoset:index,accentGeosets:accents,arcMaterials,arcAnimations,arcTexture:arcTextureId,arcPeriodMs:120,arcTravelMs:100,arcPhaseMs:[0,30,60,90],material,texture:layer.textureId,textureAnimation:layer.textureAnimationId,periodMs:period,travelMs:travel,geometry:'exact V7 Flow surface; four angular interior green paths',direction:'nose to rear (-X)',birthDeath:'new layers hidden; original V7 sequences preserved'};
};
