// CPU photograph preparation: actual skinned geometry, animated original camera,
// and actual BLP texels. Raster stage is separate from a native-engine claim.
const {fs,path,read,pose,dependency}=require('../../../ModelEditor/src/model.cjs');
const Camera=dependency('mdx-m3-viewer/dist/cjs/viewer/handlers/mdx/camera').default;
const crypto=require('node:crypto'),sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const {vec3}=dependency('gl-matrix');
const {BlpImage}=dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image');
global.ImageData=class{constructor(w,h){this.width=w;this.height=h;this.data=new Uint8ClampedArray(w*h*4);}};
const root=path.resolve(__dirname,'..'),out=path.join(root,'exports/health-bars-v1/sources');
fs.mkdirSync(out,{recursive:true});
for(const [id,name] of [['paladin','HeroPaladin'],['tauren','Tauren']]){
 const source=path.resolve(root,'../../work/dialogue-animated-20261022/originals',name+'_portrait.mdx');
 const model=read(source),sequence=1,frame=model.sequences[sequence].interval[0]+600;
 const c=new Camera(model,model.cameras[0]),eye=vec3.clone(c.position),target=vec3.clone(c.targetPosition),a=vec3.create(),b=vec3.create(),roll=new Float32Array(1);
 c.getTranslation(a,sequence,frame,0);c.getTargetTranslation(b,sequence,frame,0);c.getRotation(roll,sequence,frame,0);vec3.add(eye,eye,a);vec3.add(target,target,b);
 const d=vec3.normalize(vec3.create(),vec3.sub(vec3.create(),eye,target));
 const r=vec3.normalize(vec3.create(),vec3.cross(vec3.create(),[0,0,1],d)),u=vec3.cross(vec3.create(),d,r),cs=Math.cos(roll[0]),sn=Math.sin(roll[0]);
 const rr=Array.from(r,(v,i)=>v*cs+u[i]*sn),uu=Array.from(u,(v,i)=>v*cs-r[i]*sn),focal=128/Math.tan(c.fieldOfView/2);
 const photoFraming=id==='paladin'?{zoom:1.35,offsetPixels:[0,-44]}:{zoom:1,offsetPixels:[0,0]};
 const project=w=>{const depth=vec3.dot(d,eye)-vec3.dot(d,w);return [128+(vec3.dot(rr,w)-vec3.dot(rr,target))*focal*photoFraming.zoom/Math.max(c.nearClippingPlane,depth)+photoFraming.offsetPixels[0],128-(vec3.dot(uu,w)-vec3.dot(uu,target))*focal*photoFraming.zoom/Math.max(c.nearClippingPlane,depth)+photoFraming.offsetPixels[1],depth];};
 const points=pose(model,sequence,frame).points;
 const textures=model.textures.map((t,i)=>{
  if(t.replaceableId)return {replaceable:t.replaceableId};
  const file=path.join(root,'assets/UI/Dialogue/Portraits',t.path.split(/[\\/]/).at(-1)),bytes=fs.readFileSync(file),image=new BlpImage();image.load(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));const mip=image.getMipmap(0),raw=id+'-texture-'+i+'.rgba';fs.writeFileSync(path.join(out,raw),mip.data);return {file,sha256:sha(bytes),width:mip.width,height:mip.height,raw};
 });
 const meshes=model.geosets.flatMap((g,i)=>{
  const layers=model.materials[g.materialId].layers.filter(l=>model.textures[l.textureId].replaceableId!==2).map(l=>({texture:l.textureId,filter:l.filterMode,alpha:l.alpha}));
  return layers.length?[{vertices:points[i].map(project),uv:Array.from(g.uvSets[0]),faces:Array.from(g.faces),layers}]:[];
 });
 fs.writeFileSync(path.join(out,id+'-render.json'),JSON.stringify({source,sourceSha256:sha(fs.readFileSync(source)),sequence:model.sequences[sequence].name,frame,elapsed:600,camera:{position:Array.from(eye),target:Array.from(target),horizontalFieldOfView:c.fieldOfView,roll:roll[0]},photoFraming,size:256,textures,meshes}));
}
console.log('Skinned source geometry + animated cameras + BLP texels exported.');
