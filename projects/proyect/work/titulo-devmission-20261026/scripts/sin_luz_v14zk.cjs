// v14zk: copias sin luz de los efectos (balas, granadas, dash, Windwalk, efectos del jefe y RecargaRoja/Verde) para
// no gastar el límite de 8 luces del motor. Quita cada nodo LITE y renumera los ObjectId que le siguen, los padres y
// los pivotes (los ObjectId tienen que ir seguidos por orden de bloques: memoria mdx-objectid-orden-bloques).
// Lo demás del modelo queda igual. Uso: node sin_luz_v14zk.cjs ENTRADA.mdx SALIDA.mdx
const M = require('/home/snz/Documentos/ChatGPT/Proyect/ModelEditor/src/model.cjs');
const [ent, sal] = process.argv.slice(2);
const m = M.read(ent);
const bloques = Object.keys(m).filter(k => Array.isArray(m[k]) && m[k].length && m[k][0] && m[k][0].objectId !== undefined);
const nodos = bloques.flatMap(k => m[k]);
nodos.forEach((o, i) => M.assert.equal(o.objectId, i, `${ent}: ObjectId fuera de orden en ${o.name}`));
M.assert.equal(m.pivotPoints.length, nodos.length);
M.assert.ok(m.lights.length > 0, `${ent}: no tiene luz`);
const quitar = m.lights.map(l => l.objectId).sort((a, b) => b - a);
for (const L of quitar) M.assert.ok(!nodos.some(o => o.parentId === L), `${ent}: la luz ${L} tiene hijos`);
for (const g of m.geosets) for (const x of g.matrixIndices) M.assert.ok(x < Math.min(...quitar), `${ent}: hueso tras la luz`);
const nuevo = id => id < 0 ? id : id - quitar.filter(L => L < id).length;
m.lights = [];
for (const L of quitar) m.pivotPoints.splice(L, 1);
for (const o of bloques.flatMap(k => m[k])) { o.objectId = nuevo(o.objectId); o.parentId = nuevo(o.parentId); }
const quedan = bloques.flatMap(k => m[k]);
quedan.forEach((o, i) => M.assert.equal(o.objectId, i));
M.assert.equal(m.pivotPoints.length, quedan.length);
M.save(m, sal);
const r = M.read(sal);
M.assert.equal(r.lights.length, 0);
M.assert.equal(r.pivotPoints.length, quedan.length);
console.log(`${require('path').basename(sal)}: ${quitar.length} luz quitada, ${quedan.length} nodos`);
