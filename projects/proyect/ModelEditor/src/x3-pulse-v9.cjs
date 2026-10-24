// Travel along the approved envelope using UVs; never translate the projectile.
module.exports=function addPulse(m,k){
 const {c,track,mesh}=k;
 const L=n=>c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/'+n).default;
 const Texture=L('texture'),Material=L('material'),Layer=L('layer'),TA=L('textureanimation');
 const original=m.geosets.filter(g=>g.materialId===9);
 c.assert.equal(original.length,12,'V7 envelope must remain intact');
 const texture=new Texture();texture.path='X3BusterV9\\Pulse.blp';texture.wrapMode=0;
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
 // Sparse green filaments seen in the first sprite phases. They stay behind
 // the tip, flicker briefly, and never replace the approved pink envelope.
 const accents=[];
 for(let j=0;j<4;j++){
  const theta=.10+j*Math.PI/2;
  const xs=[-12,-19,-24,-29,-33,-39,-45,-51],rr=[15,18,20.5,20,18,20.5,18.5,13];
  const v=[],uv=[],f=[];
  for(let q=0;q<xs.length;q++){
   const a=theta+[0,.08,-.08,.07,-.10,.10,-.07,0][q];
   const width=.70*Math.sin(Math.PI*(q+.5)/xs.length);
   for(const side of [-1,1]){v.push(xs[q],rr[q]*Math.cos(a)-side*width*Math.sin(a),rr[q]*Math.sin(a)+side*width*Math.cos(a));uv.push(q/(xs.length-1),side<0?0:1);}
   if(q){const n=(q-1)*2;f.push(n,n+1,n+2,n+1,n+3,n+2);}
  }
  accents.push(m.geosets.length);mesh(m,{v,uv,f},[.12,.92,.18],1,3);
  const frames=[0,160],values=[0,0],delay=(j%2)*20;
  for(let start=200;start<1160;start+=period){frames.push(start,start+24+delay,start+60+delay,start+110+delay,start+174,start+239);values.push(0,.48,.62,.20,0,0);}
  frames.push(1160,1300,1720);values.push(0,0,0);
  m.geosetAnimations.at(-1).animations=[track('FloatAnimation','KGAO',frames,values)];
 }
 return {geoset:index,accentGeosets:accents,material,texture:layer.textureId,textureAnimation:layer.textureAnimationId,periodMs:period,travelMs:travel,geometry:'exact V7 Flow surface plus four sparse green sprite filaments',direction:'nose to rear (-X)',birthDeath:'new layers hidden; original V7 sequences preserved'};
};
