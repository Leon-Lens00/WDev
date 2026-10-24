import test from 'node:test';
import assert from 'node:assert/strict';
import {preset,validateProject,exportJass,screenToUI,uiToScreen,MODELS,ASPECT} from '../dist/core.js';
test('map layout keeps row-major inventory and equipment identities',()=>{
 const p=validateProject(preset());
 assert.equal(p.elements.filter(e=>e.id.startsWith('inventory.slot.')).length,30);
 assert.equal(p.elements.filter(e=>e.id.startsWith('equipment.slot.')).length,14);
 const first=p.elements.find(e=>e.id==='inventory.slot.0'),last=p.elements.find(e=>e.id==='inventory.slot.29');
 assert.equal(first.x,.5615);assert.equal(first.y,-.228);assert.equal(last.x,.8865);
 assert(Math.abs(last.y-(-.228-4*.065*ASPECT))<.00001);
 assert.deepEqual(validateProject(JSON.parse(JSON.stringify(p))),p);
});
test('screen conversion round-trips at common aspects',()=>{
 for(const [w,h] of [[1600,900],[1200,900]])for(const [x,y] of [[-1,1],[0,0],[.5615,-.228]]){
  const a=uiToScreen(x,y,w,h);assert.deepEqual(screenToUI(a.x,a.y,w,h),{x,y});
 }
});
test('invalid imports cannot introduce duplicate bindings or code through rawcodes',()=>{
 const p=preset();p.elements.push({...p.elements[0]});assert.throws(()=>validateProject(p),/repetido/);
 const q=preset();q.elements[0].texture="'foo";assert.throws(()=>validateProject(q),/rawcode/);
 q.elements[0].texture='D201';q.elements[0].x=NaN;assert.throws(()=>validateProject(q),/inválido/);
});
test('JASS preserves text escapes and runtime texture override',()=>{
 const p=preset();p.elements.find(e=>e.type==='text').text='"Rey"\nC:\\Mapa';
 const j=exportJass(p);assert(j.includes('\\"Rey\\"\\nC:\\\\Mapa'));
 assert(j.includes('if texture == -1 then'));assert(j.includes('call SaveInteger(H,k,13,\'ewin\')'));
 assert(!j.includes('Blz'));assert(!j.includes('GetLocalPlayer'));
});
test('model bounds yield original constructor anchors and scales',()=>{
 const p=preset();
 for(const [id,x,y,scale] of [['equipment.background',.425,.93,.28],['inventory.background',.61,-.3,.228],['tooltip.background',-.7,0,.1]]){
  const e=p.elements.find(e=>e.id===id),m=MODELS[e.modelId],d=100.2+e.z;
  const s=e.w*.544*d/m.vw;
  assert(Math.abs(s-scale)<.00002);
  assert(Math.abs(e.x+e.w/2-m.mw*s/(2*.544*d)-x)<.00002);
  assert(Math.abs(e.y-e.h/2+m.mh*s/(2*.302*d)-y)<.00002);
 }
});
