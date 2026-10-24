// Travel along the approved envelope using UVs; never translate the projectile.
module.exports=function addPulse(m,k){
 const {c,track,mesh}=k;
 const L=n=>c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/'+n).default;
 const Texture=L('texture'),Material=L('material'),Layer=L('layer'),TA=L('textureanimation');
 const original=m.geosets.filter(g=>g.materialId===9);
 c.assert.equal(original.length,12,'V7 envelope must remain intact');
 const texture=new Texture();texture.path='X3BusterV8\\Pulse.blp';texture.wrapMode=0;
 const mat=new Material(),layer=new Layer();layer.flags=17;layer.filterMode=4;layer.textureId=m.textures.length;
 m.textures.push(texture);layer.textureAnimationId=m.textureAnimations.length;
 const ta=new TA();ta.animations=[track('Vector3Animation','KTAT',
  [0,160,200,600,679,680,1080,1159,1160,1300,1720],
  [.70,.70,.70,-.70,-.70,.70,-.70,-.70,.70,.70,.70].map(x=>[x,0,0]))];
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
 m.geosetAnimations.at(-1).animations=[track('FloatAnimation','KGAO',
  [0,160,200,240,520,600,679,680,720,1000,1080,1160,1300,1720],
  [0,0,0,.92,.92,0,0,0,.92,.92,0,0,0,0])];
 return {geoset:index,material,texture:layer.textureId,textureAnimation:layer.textureAnimationId,periodMs:480,travelMs:400,geometry:'exact V7 Flow surface',direction:'nose to rear (-X)',birthDeath:'hidden; original V7 sequences preserved'};
};
