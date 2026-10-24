import test from 'node:test';
import assert from 'node:assert/strict';
import {preset,exportJass,validateProject} from '../dist/core.js';
import {previewGeometry,previewValue,previewDelta,tooltipPreview} from '../dist/projection.js';
import {displayGeometry,geometryValue} from '../dist/geometry.js';
const view={width:1920,height:1080,projection:'classic-127b'};
const near=(a,b,tolerance=.0001)=>assert(Math.abs(a-b)<tolerance,`${a} differs from ${b}`);
test('measured button centers match the captured 1920x1080 client within five pixels',()=>{
 const p=preset();
 for(const [id,x,y] of [['equipment.slot.0',1374,127],['equipment.slot.5',1374,443],['inventory.pageUp',1315,544],['inventory.pageDown',1315,725]]){
  const box=previewGeometry(p.elements.find(e=>e.id===id),view);
  near(box.x+box.w/2,x,5);near(box.y+box.h/2,y,5);
 }
});
test('calibrated dragging, dimensions and inspector coordinates share one transform',()=>{
 const e=preset().elements.find(e=>e.id==='inventory.slot.0');
 const b=previewGeometry(e,view);for(const k of ['x','y','w','h'])near(previewValue(k,b[k],view),e[k]);
 const px=displayGeometry(e,view);for(const k of ['x','y','w','h'])near(geometryValue(k,px[k],view),e[k],.0001);
 const delta=previewDelta(72,38.88,view);near(delta.x,.1);near(delta.y,-.1);
});
test('tooltip follows the clicked slot without changing saved design coordinates',()=>{
 const p=preset(),before=JSON.stringify(p);const a=tooltipPreview(p.elements,'inventory.slot.0'),b=tooltipPreview(p.elements,'inventory.slot.1');
 const first=a.find(e=>e.id==='tooltip.title'),second=b.find(e=>e.id==='tooltip.title');near(second.x-first.x,.065);near(second.y,first.y);
 assert.equal(JSON.stringify(p),before);
});
test('preview calibration never changes exported vJASS coordinates',()=>{
 const p=preset(),full=structuredClone(p);full.viewport.projection='full';assert.equal(exportJass(p),exportJass(full));
 const invalid=structuredClone(p);invalid.viewport.projection='unknown';assert.throws(()=>validateProject(invalid),/Perfil/);
});
