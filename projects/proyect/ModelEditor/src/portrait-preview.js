(async()=>{'use strict';
const $=id=>document.getElementById(id),canvas=$('view'),overlay=$('labels'),ctx=overlay.getContext('2d'),status=$('status');
const errors=[];function fail(e){errors.push(String(e.error||e.message||e));status.textContent='Error: '+errors.join('\n');status.style.color='#ffa9a9';}
window.addEventListener('error',fail);window.addEventListener('unhandledrejection',e=>fail(e.reason));
const manifest=await fetch('metrics.json').then(r=>r.json());
const viewer=new ModelViewer.viewer.ModelViewer(canvas,{alpha:false,antialias:true,preserveDrawingBuffer:true});
viewer.addHandler(ModelViewer.viewer.handlers.mdx);viewer.addHandler(ModelViewer.viewer.handlers.blp);viewer.on('error',fail);
const scenes=[viewer.addScene(),viewer.addScene()];scenes.forEach(s=>s.color.set([.035,.047,.067]));
const binary=b=>Uint8Array.from(atob(b),c=>c.charCodeAt(0)).buffer;
const gridBuffer=binary(GRID.mdx),gridTexture=binary(GRID.texture);
const gm=await viewer.load(gridBuffer,src=>src===gridBuffer?src:gridTexture);
const grids=scenes.map(s=>{const i=gm.addInstance();i.setScale([.32,.32,.32]);i.setScene(s);return i;});
let instances=[],playing=true,clock=0,yaw=0,pitch=.025,distance=40,serial=0,grid=true,busy=false;
const cache=new Map();
async function load(url){if(cache.has(url))return cache.get(url);const m=await viewer.load(url,src=>src===url?url:'textures/'+String(src).replaceAll('\\','/').split('/').at(-1));if(!m)throw Error('No se cargó '+url);cache.set(url,m);return m;}
const fmt=n=>(n/1024).toFixed(1)+' KiB';
async function display(){busy=true;const token=++serial,id=$('actor').value,tol=+$('quality').value;
const stats=manifest.models.find(m=>m.id===id),candidate=stats.candidates.find(c=>c.tolerance===tol);
status.textContent='Cargando '+id+'…';
const models=await Promise.all([load('models/'+id+'-before.mdx'),load('models/'+id+'-'+tol+'.mdx')]);if(token!==serial)return;
instances.forEach(i=>i.detach());instances=models.map((m,j)=>{const i=m.addInstance();i.setScene(scenes[j]);i.setSequenceLoopMode(2);return i;});
const old=$('sequence').value;$('sequence').replaceChildren(...models[0].sequences.map((s,i)=>Object.assign(document.createElement('option'),{value:String(i),textContent:s.name})));if(old!=='' && +old<models[0].sequences.length)$('sequence').value=old;else $('sequence').value='0';
$('sizes').innerHTML='<table><tr><th>Modelo MDX</th><th>Peso</th></tr><tr><td>Original Warcraft</td><td>'+fmt(stats.originalBytes)+'</td></tr><tr><td>Adaptación actual</td><td>'+fmt(stats.beforeBytes)+'</td></tr><tr><td>Optimizado</td><td>'+fmt(candidate.bytes)+'</td></tr></table><p>'+((1-candidate.bytes/stats.beforeBytes)*100).toFixed(1)+'% menos que la adaptación<br>'+(candidate.bytes/stats.originalBytes).toFixed(1)+'× el original</p>';
$('error').textContent='Claves: '+stats.beforeKeys.toLocaleString('es')+' → '+candidate.keys.toLocaleString('es')+'. Error máximo medido: '+candidate.validation.maxVertexError.toFixed(5)+' unidades.';
setSequence();await viewer.whenAllLoaded();busy=false;}
function setSequence(){clock=0;instances.forEach(i=>i.setSequence(+$('sequence').value));}
$('actor').onchange=()=>display().catch(fail);$('quality').onchange=()=>display().catch(fail);$('sequence').onchange=setSequence;
$('pause').onclick=()=>{playing=!playing;$('pause').textContent=playing?'Pausar':'Reproducir';};
$('reset').onclick=()=>{yaw=0;pitch=.025;distance=40;};$('grid').onclick=()=>{grid=!grid;grids.forEach(i=>grid?i.show():i.hide());$('grid').textContent=grid?'Ocultar ejes':'Mostrar ejes';};
$('time').oninput=()=>{playing=false;$('pause').textContent='Reproducir';if(instances[0]){const s=instances[0].model.sequences[+$('sequence').value];clock=(s.interval[1]-s.interval[0])*$('time').value/1000;}};
let drag;canvas.onpointerdown=e=>{drag=[e.clientX,e.clientY];canvas.setPointerCapture(e.pointerId);};canvas.onpointerup=()=>drag=null;canvas.onpointermove=e=>{if(drag){yaw-=(e.clientX-drag[0])*.008;pitch=Math.max(-1.4,Math.min(1.4,pitch+(e.clientY-drag[1])*.008));drag=[e.clientX,e.clientY];}};canvas.onwheel=e=>{e.preventDefault();distance=Math.max(18,Math.min(130,distance*Math.exp(e.deltaY*.001)));};
function resize(){const r=$('stage').getBoundingClientRect(),d=Math.min(devicePixelRatio||1,2);canvas.width=Math.round(r.width*d);canvas.height=Math.round(r.height*d);overlay.width=canvas.width;overlay.height=canvas.height;}new ResizeObserver(resize).observe($('stage'));resize();await display();
function label(scene,p,text,color){const m=scene.camera.viewProjectionMatrix,x=p[0],y=p[1],z=p[2],w=m[3]*x+m[7]*y+m[11]*z+m[15];if(w<=0)return;const a=(m[0]*x+m[4]*y+m[8]*z+m[12])/w,b=(m[1]*x+m[5]*y+m[9]*z+m[13])/w,vp=scene.viewport;ctx.fillStyle=color;ctx.font=(12*Math.min(devicePixelRatio||1,2))+'px system-ui';ctx.fillText(text,vp[0]+(a+1)*vp[2]/2+4,canvas.height-vp[1]-(b+1)*vp[3]/2-4);}
let last=performance.now();function frame(now){requestAnimationFrame(frame);const dt=Math.min(40,Math.max(0,now-last));last=now;const width=canvas.width/2;
for(let j=0;j<2;j++){const s=scenes[j];s.viewport.set([j*width,0,width,canvas.height]);s.camera.perspective(Math.PI/4,width/canvas.height,.1,1000);s.camera.moveToAndFace([distance*Math.cos(yaw)*Math.cos(pitch),distance*Math.sin(yaw)*Math.cos(pitch),distance*Math.sin(pitch)],[0,0,0],[0,0,1]);}
if(instances.length && !busy){const seq=+$('sequence').value,s=instances[0].model.sequences[seq],duration=s.interval[1]-s.interval[0];if(playing)clock=(clock+dt*+$('speed').value)%duration;
instances.forEach(i=>{i.frame=s.interval[0]+clock;i.counter=clock;i.forced=true;});$('time').value=Math.round(clock/duration*1000);}
viewer.updateAndRender(0);ctx.clearRect(0,0,overlay.width,overlay.height);if(grid)for(const scene of scenes){label(scene,[0,0,0],'0 · origen','#ffe39b');label(scene,[12,0,0],'+X','#ff8b96');label(scene,[0,12,0],'+Y','#77dfb1');label(scene,[0,0,12],'+Z','#85baff');}
if(!errors.length && !busy)status.textContent=instances[0]?.model.sequences[+$('sequence').value].name+' · '+(playing?'reproduciendo':'pausa')+' · '+Math.round(clock)+' ms\nMismo tiempo en ambas vistas · sólo reducción de claves · preview, sin prueba nativa';}
requestAnimationFrame(frame);
})().catch(e=>{document.getElementById('status').textContent='Error: '+e.message;});
