// v22d (23/11/2026): retrato de Vegito de D.O.N 2.1a ("Vegetto SS_squished.mdx", que ya trae la cabeza: geoset con
// VegitoHeadSuperSaiyan.blp, Z 151-200). 2.1a no trae _portrait; el retrato usa la cámara del modelo, que mira desde
// Z 143 hacia arriba. Se copia el cuerpo y se pone la cámara delante (+X, el frente del modelo), mirando a la cabeza
// (pivote de "Head Ref", Z 164) + 20 desde + 12, a 115, como Vegeta (retrato_vg21.cjs, misma altura de cabeza).
// Uso: node retrato_vt21.cjs CUERPO.mdx RETRATO.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [fc, sal] = process.argv.slice(2);
const b = M.read(fc);
const ref = b.attachments.find(a => a.name === 'Head Ref');
M.assert(ref, 'Head Ref');
const piv = Array.from(b.pivotPoints[ref.objectId]);
M.assert(piv[2] > 150 && piv[2] < 180, 'cabeza a ' + piv[2]);
M.assert(b.cameras.length === 1 && !b.cameras[0].animations.length, 'una cámara fija');
const cam = b.cameras[0];
cam.targetPosition[0] = piv[0];
cam.targetPosition[1] = piv[1];
cam.targetPosition[2] = piv[2] + 20;
cam.position[0] = piv[0] + 115;
cam.position[1] = piv[1];
cam.position[2] = piv[2] + 12;
M.save(b, sal);
console.log('retrato: cabeza en', piv.map(x => x.toFixed(1)).join(','), 'cámara', Array.from(cam.position).map(x => x.toFixed(1)).join(','));
