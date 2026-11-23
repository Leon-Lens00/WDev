// v22e (23/11/2026): el retrato de Vegito sube. Leon tras v22d-prueba: "el portrait esta algo bajo".
// En v22d la cámara miraba a "Head Ref" + 20 (Z 184) desde 115 con 45°: encuadre Z ~136-232, y la cara (geoset de la
// cabeza, Z 151-200; cara abajo) quedaba bajo la vida y el maná. Se baja 14 la mirada y la cámara (misma inclinación):
// mira a Z ~170, encuadre ~122-218. Parte del retrato de v22d (fuentes/vt21) sin tocarlo.
// Uso: node retrato_vt22e.cjs RETRATO-v22d.mdx RETRATO-NUEVO.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal] = process.argv.slice(2);
const b = M.read(ent);
M.assert(b.cameras.length === 1 && !b.cameras[0].animations.length, 'una cámara fija');
const cam = b.cameras[0];
M.assert(Math.abs(cam.targetPosition[2] - 184.22) < 0.1 && Math.abs(cam.position[2] - 176.22) < 0.1, 'cámara de v22d');
cam.targetPosition[2] -= 14;
cam.position[2] -= 14;
M.save(b, sal);
console.log('retrato: cámara', Array.from(cam.position).map(x => x.toFixed(1)).join(','), 'mira',
            Array.from(cam.targetPosition).map(x => x.toFixed(1)).join(','));
