// Visor 3D (mdx-m3-viewer) de los doodads de v14ze: original a la izquierda (X −) y corregido a la derecha (X +),
// con rejilla y ejes. Uso: node visor_doodads_v14ze.cjs → doodads-v14ze/visor/index.html
const c = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const ME = '/home/snz/Documentos/ChatGPT/Proyect/ModelEditor';
const aqui = c.path.resolve(__dirname, '..'), out = c.path.join(aqui, 'doodads-v14ze/visor');
c.fs.mkdirSync(out, { recursive: true });
const rutas = [];
(function walk(d, r) { for (const e of c.fs.readdirSync(d, { withFileTypes: true }))
  e.isDirectory() ? walk(c.path.join(d, e.name), r + e.name + '/') : e.name.endsWith('.mdx') && rutas.push(r + e.name); })(c.path.join(aqui, 'doodads-v14ze/Doodads'), 'Doodads/');
rutas.sort();
const tex = {}, modelos = [];
const b64 = p => c.fs.readFileSync(p).toString('base64');
for (const r of rutas) {
  for (const [lado, dir] of [['orig', 'fuentes/doodads-juego/orig'], ['nuevo', 'doodads-v14ze']]) {
    const p = c.path.join(aqui, dir, r), m = c.read(p);
    for (const t of m.textures) if (t.path) {
      const k = t.path.toLowerCase().replaceAll('\\', '/');
      const f = c.path.join(aqui, 'fuentes/doodads-juego/texturas', ...t.path.split('\\'));
      if (!tex[k]) { c.assert.ok(c.fs.existsSync(f), f); tex[k] = b64(f); }
    }
    modelos.push({ nombre: r.split('/').pop(), lado, mdx: b64(p), luces: m.lights.length, geo: m.geosets.length });
  }
}
c.fs.writeFileSync(c.path.join(out, 'data.js'), 'window.DATA=' + JSON.stringify({ modelos, tex }) + ';\n' +
  c.fs.readFileSync(c.path.join(ME, 'viewer/x3-v15/grid.js'), 'utf8'));
c.fs.copyFileSync(c.path.join(require(ME + '/src/runtime.cjs').modules, 'mdx-m3-viewer/dist/umd/viewer.min.js'), c.path.join(out, 'viewer.min.js'));
c.fs.writeFileSync(c.path.join(out, 'index.html'), `<!doctype html><html lang="es"><meta charset="utf-8"><title>Doodads v14ze</title>
<style>body{margin:0;background:#0b1220;color:#dce6fa;font:14px system-ui;height:100vh;display:flex}aside{width:240px;padding:14px;background:#121b29;overflow:auto}
button{display:block;width:100%;margin:3px 0;padding:7px;background:#23344e;color:#fff;border:1px solid #41536d;border-radius:5px;cursor:pointer;text-align:left}
button.on{background:#3d5f8f}section{position:relative;flex:1}canvas{position:absolute;inset:0;width:100%;height:100%}#st{position:absolute;left:12px;bottom:12px;background:#121e30da;padding:8px;font:12px monospace;white-space:pre}</style>
<aside><b>Original (izq.) · corregido (der.)</b><div id="lista"></div><p style="font-size:12px;color:#9ab">Arrastra para orbitar, rueda para acercar. Muestra del visor; no es la prueba en el juego.</p></aside>
<section id="stage"><canvas id="v"></canvas><div id="st">Cargando…</div></section>
<script src="viewer.min.js"></script><script src="data.js"></script><script>
(async()=>{const $=x=>document.getElementById(x),cv=$('v'),buf=b=>Uint8Array.from(atob(b),x=>x.charCodeAt(0)).buffer;
const V=new ModelViewer.viewer.ModelViewer(cv,{alpha:false,antialias:true,preserveDrawingBuffer:true});V.addHandler(ModelViewer.viewer.handlers.mdx);V.addHandler(ModelViewer.viewer.handlers.blp);
const sc=V.addScene();sc.color.set([.04,.06,.09]);const tex=Object.fromEntries(Object.entries(DATA.tex).map(([k,v])=>[k,buf(v)]));
const gb=buf(GRID.mdx),gt=buf(GRID.texture),g=(await V.load(gb,s=>s===gb?s:gt)).addInstance();g.setScene(sc);g.setScale([2,2,2]);
const nombres=[...new Set(DATA.modelos.map(m=>m.nombre))];let inst=[],yaw=-1.2,pitch=.5,dist=420,drag,actual;
async function ver(n){inst.forEach(i=>i.detach&&i.detach());inst.forEach(i=>i.hide());inst=[];actual=n;
 for(const m of DATA.modelos.filter(m=>m.nombre===n)){const b=buf(m.mdx),mo=await V.load(b,s=>s===b?s:tex[String(s).toLowerCase().replaceAll('\\\\','/')]);
  const i=mo.addInstance();i.setScene(sc);i.setSequence(0);i.setSequenceLoopMode(2);i.setLocation([m.lado==='orig'?-110:110,0,0]);inst.push(i);}
 [...$('lista').children].forEach(b=>b.classList.toggle('on',b.textContent===n));
 const o=DATA.modelos.filter(m=>m.nombre===n);$('st').textContent=n+'\\n'+o.map(m=>m.lado+': '+m.geo+' geosets, '+m.luces+' luces').join('\\n');}
for(const n of nombres){const b=document.createElement('button');b.textContent=n;b.onclick=()=>ver(n);$('lista').appendChild(b);}
cv.onpointerdown=e=>{drag=[e.clientX,e.clientY];cv.setPointerCapture(e.pointerId)};cv.onpointerup=()=>drag=null;
cv.onpointermove=e=>{if(drag){yaw-=(e.clientX-drag[0])*.006;pitch=Math.max(-1.4,Math.min(1.55,pitch+(e.clientY-drag[1])*.006));drag=[e.clientX,e.clientY]}};
cv.onwheel=e=>{e.preventDefault();dist=Math.max(80,Math.min(3000,dist*Math.exp(e.deltaY*.001)))};
function rs(){const r=$('stage').getBoundingClientRect();cv.width=r.width;cv.height=r.height}new ResizeObserver(rs).observe($('stage'));rs();
await ver(nombres[0]);
(function f(){requestAnimationFrame(f);sc.viewport.set([0,0,cv.width,cv.height]);sc.camera.perspective(Math.PI/4,cv.width/cv.height,1,10000);
 sc.camera.moveToAndFace([dist*Math.cos(yaw)*Math.cos(pitch),dist*Math.sin(yaw)*Math.cos(pitch),dist*Math.sin(pitch)+60],[0,0,60],[0,0,1]);V.updateAndRender(16)})();
window.VER=ver;window.CAM=(y,p,d)=>{yaw=y;pitch=p;dist=d};})();</script></html>`);
console.log(out, rutas.length, 'modelos');
