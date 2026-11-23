// v22l (23/11/2026): el modelo del MVP deja de mirar siempre a la cámara: quita Billboarded (0x8) del hueso "MvpFrente"
// que añadió mvp_frente.cjs. El hueso queda como raíz fija (sin pistas): la pose no cambia; el giro lo da la unidad,
// como el jefe de la presentación (JefePres).
// Uso: node mvp_sin_billboard.cjs ENTRADA.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal] = process.argv.slice(2);
const m = M.read(ent);
const b = m.bones[0];
M.assert(b.name === 'MvpFrente' && b.objectId === 0 && (b.flags & 8), 'hueso MvpFrente con billboard');
M.assert(!(m.helpers || []).some(h => h.name === 'MvpVista'), 'sin MvpVista');
b.flags &= ~8;
M.save(m, sal);
const r = M.read(sal);
M.assert(r.bones[0].flags === (b.flags), 'flags guardadas');
console.log(sal.split('/').pop(), 'flags', r.bones[0].flags.toString(16));
