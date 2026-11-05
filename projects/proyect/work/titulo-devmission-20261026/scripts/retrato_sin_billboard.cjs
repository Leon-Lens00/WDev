// v14k: copia de un retrato ligero para la tienda (X 2400). Lejos de X 0 el billboard deja la cadena de canto y, como
// esta aplanada, no se ve (diagnostico en evidencia/vista-v14k-diag). Se quita Billboarded de PortraitBillboard y se le da
// un giro fijo hacia la camara cenital de la tienda (rotacion 180: derecha +Y, arriba -X): X del modelo (hacia la camara)
// a +Z, Y (derecha) a +Y y Z (arriba) a -X, es decir -90 grados en Y. El giro va en una secuencia global propia: con
// claves por secuencia, al abrir la tienda (antes de fijar la animación) el motor usaba el valor por defecto y el retrato
// salía un instante enorme y sin aplanar (vista en la LAN de v14k, 05/11/2026).
// Uso: node retrato_sin_billboard.cjs ENTRADA.mdx SALIDA.mdx
const {Model,read,save}=require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [inp,out]=process.argv.slice(2);
const m=read(inp),b=m.bones.find(n=>n.name==='PortraitBillboard');
if(!b||!(b.flags&8)||b.animations.length)throw new Error('PortraitBillboard sin billboard o con pistas');
b.flags&=~8;
const q=[0,-Math.SQRT1_2,0,Math.SQRT1_2].join(','),keys=[`0: {${q}},`,`1000: {${q}},`];
const t=new Model();t.loadMdl(`Version {FormatVersion 800,} Model "T" {}Helper "H" {ObjectId 0,Rotation ${keys.length} {DontInterp,${keys.join('')}}}PivotPoints 1 {{0,0,0},}`);
const g=t.helpers[0].animations[0];m.globalSequences.push(1000);g.globalSequenceId=m.globalSequences.length-1;b.animations.push(g);
save(m,out);
const r=read(out).bones.find(n=>n.name==='PortraitBillboard');
console.log(out,'flags',r.flags.toString(16),'claves',r.animations[0].frames.length,'global',r.animations[0].globalSequenceId,'de',read(out).globalSequences.join(' '));
