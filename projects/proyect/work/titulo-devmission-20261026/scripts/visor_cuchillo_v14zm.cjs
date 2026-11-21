// Visor 3D (mdx-m3-viewer) de v14zm: Culling Cleave (izq., golpe A) y Culling Slash (der., golpe B) del tier elegido,
// con rejilla y ejes; la flecha +X es «delante» del héroe (facing 0). Botones de tier y de velocidad (1×, T1 2,67×,
// T6 9,33×: la escala de tiempo que usa el mapa, 1 / intervalo). Texturas: Textures\Flare.blp sacada del juego.
// Uso: node visor_cuchillo_v14zm.cjs → cuchillo-v14zm/visor/
const c = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const ME = '/home/snz/Documentos/ChatGPT/Proyect/ModelEditor';
const base = c.path.resolve(__dirname, '..', 'cuchillo-v14zm'), out = c.path.join(base, 'visor');
c.fs.mkdirSync(out, { recursive: true });
const b64 = p => c.fs.readFileSync(p).toString('base64');
const modelos = [];
for (let t = 1; t <= 6; t++) for (const n of ['CullingCleave', 'CullingSlash']) {
  const m = c.read(c.path.join(base, n + t + '.mdx'));
  modelos.push({ n, t, mdx: b64(c.path.join(base, n + t + '.mdx')), luces: m.lights.length });
}
const tex = { 'textures/flare.blp': b64(c.path.join(base, 'texturas-juego/Textures|Flare.blp')) };
c.fs.writeFileSync(c.path.join(out, 'data.js'), 'window.DATA=' + JSON.stringify({ modelos, tex }) + ';\n' +
  c.fs.readFileSync(c.path.join(ME, 'viewer/x3-v15/grid.js'), 'utf8'));
c.fs.copyFileSync(c.path.join(require(ME + '/src/runtime.cjs').modules, 'mdx-m3-viewer/dist/umd/viewer.min.js'), c.path.join(out, 'viewer.min.js'));
c.fs.writeFileSync(c.path.join(out, 'index.html'), `<!doctype html><html lang="es"><meta charset="utf-8"><title>Cuchillo v14zm</title>
<style>body{margin:0;background:#0b1220;color:#dce6fa;font:14px system-ui;height:100vh;display:flex}aside{width:250px;padding:14px;background:#121b29;overflow:auto}
button{display:inline-block;margin:3px;padding:6px 10px;background:#23344e;color:#fff;border:1px solid #41536d;border-radius:5px;cursor:pointer}
button.on{background:#3d5f8f}section{position:relative;flex:1}canvas{position:absolute;inset:0;width:100%;height:100%}
#st{position:absolute;left:12px;bottom:12px;background:#121e30da;padding:8px;font:12px monospace;white-space:pre}</style>
<aside><b>Cleave (izq.) · Slash (der.)</b><p>Tier</p><div id="tiers"></div><p>Velocidad</p><div id="vel"></div>
<p style="font-size:12px;color:#9ab">El eje X (rojo) es «delante» del héroe. Arrastra para orbitar, rueda para acercar. Es la muestra del visor, no la prueba en el juego.</p></aside>
<section id="stage"><canvas id="v"></canvas><div id="st">Cargando…</div></section>
<script src="viewer.min.js"></script><script src="data.js"></script><script>
(async()=>{const $=x=>document.getElementById(x),cv=$('v'),buf=b=>Uint8Array.from(atob(b),x=>x.charCodeAt(0)).buffer;
const V=new ModelViewer.viewer.ModelViewer(cv,{alpha:false,antialias:true,preserveDrawingBuffer:true});V.addHandler(ModelViewer.viewer.handlers.mdx);V.addHandler(ModelViewer.viewer.handlers.blp);
const sc=V.addScene();sc.color.set([.04,.06,.09]);const tex=Object.fromEntries(Object.entries(DATA.tex).map(([k,v])=>[k,buf(v)]));
const gb=buf(GRID.mdx),gt=buf(GRID.texture),g=(await V.load(gb,s=>s===gb?s:gt)).addInstance();g.setScene(sc);g.setScale([4,4,4]);
let inst=[],yaw=-1.57,pitch=1.1,dist=1500,drag,vel=1,tier=1;
async function ver(t){inst.forEach(i=>i.hide());inst=[];tier=t;
 for(const m of DATA.modelos.filter(m=>m.t===t)){const b=buf(m.mdx),mo=await V.load(b,s=>s===b?s:tex[String(s).toLowerCase().replaceAll('\\\\','/')]);
  const i=mo.addInstance();i.setScene(sc);i.setSequence(0);i.setSequenceLoopMode(2);i.setLocation([m.n==='CullingCleave'?-350:350,0,0]);inst.push(i);}
 [...$('tiers').children].forEach(b=>b.classList.toggle('on',+b.dataset.t===t));
 $('st').textContent='tier '+t+' · velocidad '+vel+'×\\n'+DATA.modelos.filter(m=>m.t===t).map(m=>m.n+': '+m.luces+' luces').join('\\n');}
for(let t=1;t<=6;t++){const b=document.createElement('button');b.textContent='T'+t;b.dataset.t=t;b.onclick=()=>ver(t);$('tiers').appendChild(b);}
for(const v of [1,2.67,9.33]){const b=document.createElement('button');b.textContent=v+'×';b.onclick=()=>{vel=v;ver(tier)};$('vel').appendChild(b);}
cv.onpointerdown=e=>{drag=[e.clientX,e.clientY];cv.setPointerCapture(e.pointerId)};cv.onpointerup=()=>drag=null;
cv.onpointermove=e=>{if(drag){yaw-=(e.clientX-drag[0])*.006;pitch=Math.max(-1.4,Math.min(1.55,pitch+(e.clientY-drag[1])*.006));drag=[e.clientX,e.clientY]}};
cv.onwheel=e=>{e.preventDefault();dist=Math.max(80,Math.min(5000,dist*Math.exp(e.deltaY*.001)))};
function rs(){const r=$('stage').getBoundingClientRect();cv.width=r.width;cv.height=r.height}new ResizeObserver(rs).observe($('stage'));rs();
await ver(1);
function paso(dt){sc.viewport.set([0,0,cv.width,cv.height]);sc.camera.perspective(Math.PI/4,cv.width/cv.height,1,20000);
 sc.camera.moveToAndFace([dist*Math.cos(yaw)*Math.cos(pitch),dist*Math.sin(yaw)*Math.cos(pitch),dist*Math.sin(pitch)],[0,0,0],[0,0,1]);V.updateAndRender(dt)}
(function f(){requestAnimationFrame(f);paso(16*vel)})();
// Para capturas con el panel oculto: avanza ms milisegundos de animación en pasos de 16 ms.
window.STEP=ms=>{for(let t=0;t<ms;t+=16)paso(16);paso(0)};
window.VER=ver;window.CAM=(y,p,d)=>{yaw=y;pitch=p;dist=d};window.VEL=v=>{vel=v};})();</script></html>`);
console.log(out, modelos.length, 'modelos');
