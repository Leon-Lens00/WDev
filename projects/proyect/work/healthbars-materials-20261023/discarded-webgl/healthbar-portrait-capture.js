// Static material photographs from the existing original Classic portrait MDX.
const lib=window.ModelViewer;
const definitions=[['paladin','HeroPaladin'],['tauren','Tauren']];
async function renderPortrait(id,source){
 const canvas=document.getElementById(id),status=document.getElementById(id+'-status');
 const viewer=new lib.viewer.ModelViewer(canvas,{alpha:false,antialias:true,preserveDrawingBuffer:true});
 viewer.addHandler(lib.viewer.handlers.mdx);viewer.addHandler(lib.viewer.handlers.blp);
 const errors=[];viewer.on('error',e=>{errors.push(String(e.error||e.message)+' '+e.fetchUrl);console.error('Portrait capture',e.fetchUrl,e.error,e.reason?.message);});
 const scene=viewer.addScene();scene.color.set([.055,.075,.095]);scene.viewport.set([0,0,128,128]);
 const url='assets/healthbars/source/'+id+'.mdx';
 const bytes=await(await fetch(url)).arrayBuffer();
 const model=await viewer.load(bytes,src=>typeof src==='string'?'assets/healthbars/source/'+src.split(/[\\/]/).at(-1):src);
 if(!model)throw Error('No se pudo cargar '+source);
 await viewer.whenAllLoaded();if(errors.length)throw Error(errors.join('; '));
 const sequence=1,elapsed=600,frame=model.sequences[sequence].interval[0]+elapsed;
 const instance=model.addInstance();instance.setScene(scene);instance.setSequence(sequence);instance.frame=frame;instance.forced=true;
 const camera=model.cameras[0],position=new Float32Array(3),target=new Float32Array(3);
 camera.getTranslation(position,sequence,frame,0);camera.getTargetTranslation(target,sequence,frame,0);
 scene.camera.perspective(camera.fieldOfView,1,camera.nearClippingPlane,camera.farClippingPlane);
 scene.camera.moveToAndFace(Array.from(camera.position,(v,i)=>v+position[i]),Array.from(camera.targetPosition,(v,i)=>v+target[i]),[0,0,1]);
 viewer.updateAndRender(0);
 canvas.dataset.source=url;canvas.dataset.sequence=model.sequences[sequence].name;
 canvas.dataset.frame=String(frame);canvas.dataset.ready='true';
 status.textContent=model.sequences[sequence].name+' · '+elapsed+' ms · 128×128 · cámara original';
}
Promise.all(definitions.map(([id,source])=>renderPortrait(id,source))).then(()=>{
 document.getElementById('status').textContent='Dos fotografías estáticas preparadas desde MDX reales.';
}).catch(e=>{document.getElementById('status').textContent='Error: '+e.message;console.error(e);});
