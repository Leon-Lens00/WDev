// Visor 3D (mdx-m3-viewer) de v14zn: los 6 Interceptor Shell (T1 a T6, de izquierda a derecha, 300 entre ellos) y el
// original con luz detrás, con rejilla y ejes. Botones Stand (vuelo) y Death (explosión). Texturas sacadas del juego
// (misil-v14zn/texturas-juego). Es la muestra del visor, no la prueba en el juego.
// Uso: node visor_misil_v14zn.cjs → misil-v14zn/visor/
const c = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const ME = '/home/snz/Documentos/ChatGPT/Proyect/ModelEditor';
const raiz = c.path.resolve(__dirname, '..'), base = c.path.join(raiz, 'misil-v14zn'), out = c.path.join(base, 'visor');
c.fs.mkdirSync(out, { recursive: true });
const b64 = p => c.fs.readFileSync(p).toString('base64');
const modelos = [];
for (let t = 1; t <= 6; t++) {
  const f = c.path.join(base, 'InterceptorShell' + t + '.mdx');
  modelos.push({ n: 'T' + t, x: (t - 3.5) * 300, y: 0, mdx: b64(f), luces: c.read(f).lights.length });
}
const orig = c.path.join(raiz, 'fuentes/culling-interceptor/x/Interceptor Shell/Interceptor Shell.mdx');
modelos.push({ n: 'original', x: 0, y: 500, mdx: b64(orig), luces: c.read(orig).lights.length });
const dir = c.path.join(base, 'texturas-juego');
const tex = Object.fromEntries(c.fs.readdirSync(dir).map(f => [f.replaceAll('|', '/'), b64(c.path.join(dir, f))]));
c.fs.writeFileSync(c.path.join(out, 'data.js'), 'window.DATA=' + JSON.stringify({ modelos, tex }) + ';\n' +
  c.fs.readFileSync(c.path.join(ME, 'viewer/x3-v15/grid.js'), 'utf8'));
c.fs.copyFileSync(c.path.join(require(ME + '/src/runtime.cjs').modules, 'mdx-m3-viewer/dist/umd/viewer.min.js'), c.path.join(out, 'viewer.min.js'));
c.fs.writeFileSync(c.path.join(out, 'index.html'), `<!doctype html><html lang="es"><meta charset="utf-8"><title>Misil v14zn</title>
<style>body{margin:0;background:#0b1220;color:#dce6fa;font:14px system-ui;height:100vh;display:flex}aside{width:250px;padding:14px;background:#121b29;overflow:auto}
button{display:inline-block;margin:3px;padding:6px 10px;background:#23344e;color:#fff;border:1px solid #41536d;border-radius:5px;cursor:pointer}
section{position:relative;flex:1}canvas{position:absolute;inset:0;width:100%;height:100%}
#st{position:absolute;left:12px;bottom:12px;background:#121e30da;padding:8px;font:12px monospace;white-space:pre}</style>
<aside><b>Interceptor Shell</b><p>T1 a T6 de izquierda a derecha; el original, detrás.</p><div id="seq"></div>
<p style="font-size:12px;color:#9ab">Arrastra para orbitar, rueda para acercar. Es la muestra del visor, no la prueba en el juego.</p></aside>
<section id="stage"><canvas id="v"></canvas><div id="st">Cargando…</div></section>
<script src="viewer.min.js"></script><script src="data.js"></script><script>
(async()=>{const $=x=>document.getElementById(x),cv=$('v'),buf=b=>Uint8Array.from(atob(b),x=>x.charCodeAt(0)).buffer;
const V=new ModelViewer.viewer.ModelViewer(cv,{alpha:false,antialias:true,preserveDrawingBuffer:true});V.addHandler(ModelViewer.viewer.handlers.mdx);V.addHandler(ModelViewer.viewer.handlers.blp);
const sc=V.addScene();sc.color.set([.04,.06,.09]);const tex=Object.fromEntries(Object.entries(DATA.tex).map(([k,v])=>[k,buf(v)]));
const gb=buf(GRID.mdx),gt=buf(GRID.texture),g=(await V.load(gb,s=>s===gb?s:gt)).addInstance();g.setScene(sc);g.setScale([4,4,4]);
let inst=[],yaw=-1.57,pitch=0.6,dist=2200,drag,seq=0;
for(const m of DATA.modelos){const b=buf(m.mdx),mo=await V.load(b,s=>s===b?s:tex[String(s).toLowerCase().replaceAll('\\\\','/')]);
 const i=mo.addInstance();i.setScene(sc);i.setLocation([m.x,m.y,0]);inst.push(i);}
function poner(s){seq=s;inst.forEach(i=>{i.setSequence(s);i.setSequenceLoopMode(2)});
 $('st').textContent=(s?'Death':'Stand')+'\\n'+DATA.modelos.map(m=>m.n+': '+m.luces+' luces').join('\\n');}
['Stand','Death'].forEach((n,k)=>{const b=document.createElement('button');b.textContent=n;b.onclick=()=>poner(k);$('seq').appendChild(b)});
cv.onpointerdown=e=>{drag=[e.clientX,e.clientY];cv.setPointerCapture(e.pointerId)};cv.onpointerup=()=>drag=null;
cv.onpointermove=e=>{if(drag){yaw-=(e.clientX-drag[0])*.006;pitch=Math.max(-1.4,Math.min(1.55,pitch+(e.clientY-drag[1])*.006));drag=[e.clientX,e.clientY]}};
cv.onwheel=e=>{e.preventDefault();dist=Math.max(80,Math.min(8000,dist*Math.exp(e.deltaY*.001)))};
function rs(){const r=$('stage').getBoundingClientRect();cv.width=r.width;cv.height=r.height}new ResizeObserver(rs).observe($('stage'));rs();
poner(0);
function paso(dt){sc.viewport.set([0,0,cv.width,cv.height]);sc.camera.perspective(Math.PI/4,cv.width/cv.height,1,20000);
 sc.camera.moveToAndFace([dist*Math.cos(yaw)*Math.cos(pitch),200+dist*Math.sin(yaw)*Math.cos(pitch),dist*Math.sin(pitch)],[0,200,60],[0,0,1]);V.updateAndRender(dt)}
(function f(){requestAnimationFrame(f);paso(16)})();
window.STEP=ms=>{for(let t=0;t<ms;t+=16)paso(16);paso(0)};
window.SEQ=poner;window.CAM=(y,p,d)=>{yaw=y;pitch=p;dist=d};})();</script></html>`);
console.log(out, modelos.length, 'modelos');
