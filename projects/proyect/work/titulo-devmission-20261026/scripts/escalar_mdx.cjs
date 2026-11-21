// v16t-perfora (13/11/2026): escala un modelo de bala entero, partículas y estelas incluidas.
// SetUnitScale no agranda las partículas ni las estelas en 1.27b; aquí se multiplican en el MDX:
// vértices, pivotes, traslaciones, extensiones, PE2 (tamaño, velocidad, ancho/largo, gravedad) y alto de las estelas.
// Uso: node escalar_mdx.cjs ORIGEN.mdx DESTINO.mdx FACTOR
const fs=require('fs');const wm=require('/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/migracion-linux/runtime/node_modules/war3-model');
const [src,dst,arg]=process.argv.slice(2);const k=Number(arg);if(!(k>0))throw new Error('factor');
const m=wm.parseMDX(new Uint8Array(fs.readFileSync(src)).buffer);
const mul=(a)=>{for(let i=0;i<a.length;i++)a[i]*=k;};
const ext=(o)=>{if(!o)return;if(o.Min)mul(o.Min);if(o.Max)mul(o.Max);if(o.BoundsRadius!=null)o.BoundsRadius*=k;};
const seenT=new Set();
const pista=(t)=>{if(!t||seenT.has(t))return;seenT.add(t);if(Array.isArray(t.Keys))for(const q of t.Keys){if(q.Vector)mul(q.Vector);if(q.InTan)mul(q.InTan);if(q.OutTan)mul(q.OutTan);}else if(ArrayBuffer.isView(t)||Array.isArray(t))mul(t);};
const num=(o,c)=>{const v=o[c];if(v==null)return;if(typeof v==='number')o[c]=v*k;else pista(v);};
ext(m.Info);for(const s of m.Sequences)ext(s);
for(const g of m.Geosets){mul(g.Vertices);ext(g);for(const a of g.Anims||[])ext(a);}
for(const p of m.PivotPoints)mul(p);
for(const n of m.Nodes){if(!n)continue;pista(n.Translation);if(n.PivotPoint&&!m.PivotPoints.includes(n.PivotPoint))mul(n.PivotPoint);}
for(const e of m.ParticleEmitters2){mul(e.ParticleScaling);for(const c of ['Speed','Width','Length','Gravity'])num(e,c);}
for(const r of m.RibbonEmitters||[]){num(r,'HeightAbove');num(r,'HeightBelow');num(r,'Gravity');}
fs.writeFileSync(dst,Buffer.from(wm.generateMDX(m)));
const r2=wm.parseMDX(new Uint8Array(fs.readFileSync(dst)).buffer);
console.log(dst.split('/').pop(),'x'+k,'PE2',r2.ParticleEmitters2.map(e=>e.ParticleScaling[1].toFixed(0)).join(','),'rib',r2.RibbonEmitters.map(r=>(typeof r.HeightAbove==='number'?r.HeightAbove:'p').toString()).join(','),r2.Sequences.map(s=>s.Name+' '+s.Interval.join('-')).join(', '));
