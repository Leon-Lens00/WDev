const {test}=require('node:test'),assert=require('node:assert/strict');
const {reduceLinear,reduceModel}=require('./optimize-portraits.cjs');
const {read,Model}=require('./model.cjs');
test('retains a sharp peak even when endpoints match',()=>assert.deepEqual(reduceLinear([0,1,2],[[0,0,0],[0,1,0],[0,0,0]],0.01),[0,1,2]));
test('constant and linear tracks collapse to clip endpoints',()=>{assert.deepEqual(reduceLinear([0,1,2,3],[[2,2,2],[2,2,2],[2,2,2],[2,2,2]],0),[0,3]);assert.deepEqual(reduceLinear([0,1,4],[[0,0,0],[1,2,3],[4,8,12]],0),[0,2]);});
test('uses real time spacing and Euclidean tolerance',()=>assert.deepEqual(reduceLinear([0,1,10],[[0,0,0],[1,1,0],[10,0,0]],0.9),[0,1,2]));
test('rejects unsupported interpolation and unordered input',()=>{assert.throws(()=>reduceLinear([1,0],[[0,0,0],[0,0,0]],0));const m=read(require('path').resolve(__dirname,'../../TerrainDev/dialogue-system/assets/UI/Dialogue/Portraits/paladin.mdx'));m.bones[1].animations[0].interpolationType=2;assert.throws(()=>reduceModel(m,0.005));});
