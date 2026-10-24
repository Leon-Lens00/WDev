import test from 'node:test';
import assert from 'node:assert/strict';
import {selectionBounds,moveSelection,resizeSelection,displayGeometry,geometryValue} from '../dist/geometry.js';
import {preset,validateProject} from '../dist/core.js';
const rect=(x,y,w,h,type='button')=>({x,y,w,h,type});
const near=(a,b)=>assert(Math.abs(a-b)<.0001,`${a} != ${b}`);

test('group movement clamps one delta without changing relative spacing',()=>{
 const es=[rect(3.8,0,.1,.1),rect(3.9,.2,.1,.1)];const out=moveSelection(es,.5,-.2);
 near(out[1].x,4);near(out[1].x-out[0].x,.1);near(out[1].y-out[0].y,.2);near(es[0].x,3.8);
});
test('each resize handle anchors the opposite side; no flipped or zero sizes',()=>{
 const es=[rect(-.5,.5,.4,.2)];
 for(const h of ['nw','n','ne','e','se','s','sw','w']){
  const [e]=resizeSelection(es,h,.08,.04);assert(e.w>0&&e.h>0);
  if(h.includes('w'))near(e.x+e.w,-.1);if(h.includes('e'))near(e.x,-.5);
  if(h.includes('n'))near(e.y-e.h,.3);if(h.includes('s'))near(e.y,.5);
 }
 const [tiny]=resizeSelection(es,'se',-100,100);assert(tiny.w>=.005&&tiny.h>=.005);
});
test('groups scale uniformly with their spacing and frame proportions',()=>{
 const es=[rect(-.5,.5,.4,.2,'panel'),rect(.1,.3,.2,.1)];const out=resizeSelection(es,'se',.4,-.1);
 const scale=out[0].w/es[0].w;near(out[0].h/es[0].h,scale);near((out[1].x-out[0].x)/(.1+.5),scale);
 near(selectionBounds(out).x,selectionBounds(es).x);near(selectionBounds(out).y,.5);
});
test('single panel and Shift resizing preserve aspect ratio',()=>{
 for(const type of ['panel','button']){const [e]=resizeSelection([rect(0,0,.4,.2,type)],'e',.3,0,type==='button');near(e.w/e.h,2);}
});
test('pixel coordinates use top-left origin and round-trip without exporting pixels',()=>{
 const e=rect(.5,-.25,.1,.2),view={width:1600,height:900};const px=displayGeometry(e,view);
 assert.deepEqual(px,{x:1200,y:562.5,w:80,h:90});
 for(const key of ['x','y','w','h'])near(geometryValue(key,px[key],view),e[key]);
 assert.equal(geometryValue('y',0,view),1);assert.equal(geometryValue('x',0,view),-1);
});
test('transformed original groups continue to validate as a v1 project',()=>{
 const p=preset();const es=p.elements.filter(e=>e.group==='equipment');const replacements=new Map(resizeSelection(es,'nw',-.08,.08).map(e=>[e.id,e]));
 p.elements=p.elements.map(e=>replacements.get(e.id)||e);assert.equal(validateProject(p).elements.length,74);
});

test('group scaling also scales text and respects its exportable font range',()=>{
 const es=[rect(0,1,1,1,'panel'),{...rect(.1,.8,.4,.1,'text'),font:10}];
 const out=resizeSelection(es,'se',.5,-.5);near(out[1].font,15);
 const huge=resizeSelection(es,'se',20,-20);assert(huge[1].font<=40);
});
