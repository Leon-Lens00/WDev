import test from 'node:test';
import assert from 'node:assert/strict';
import {dialoguePreset,validateDialogue} from '../dist/dialogue-core.js';
import {dialogueProjection,projectionJass} from '../dist/dialogue-calibration.js';
import {cameraPlane,dialogueModel} from '../dist/dialogue-calibration.js';
import {toUIText,composeMessage} from '../dist/dialogue-layout.js';
test('unit-camera view reserves HUD and shares frame/text camera coordinates',()=>{
 const d=dialoguePreset();assert.equal(d.viewport,'gameplay');
 for(const presentation of ['wide','compact']){
  const page=composeMessage(d,{speaker:'right',text:'Uno.\nDos.\nTres.',presentation}).pages[0],p=page.plane;
  assert.ok(p.top>=0);assert.ok(p.top+p.height<cameraPlane.hudTop);
  assert.deepEqual(toUIText((p.left+p.width/2)*19.2,(p.top+p.height/2)*10.8),{x:p.anchorX,y:p.anchorY});
  const screenWidth=p.nativeScale*dialogueModel.width/(cameraPlane.screenWidth*p.depth)*cameraPlane.unitX;
  const screenHeight=p.nativeScale*dialogueModel.height/(cameraPlane.screenHeight*p.depth)*cameraPlane.unitY;
  assert.ok(Math.abs(screenWidth-p.width*19.2)<1e-8);assert.ok(Math.abs(screenHeight-p.height*10.8)<1e-8);
  assert.ok(page.top+page.lineHeight*2+page.fontPx<(p.top+p.height)*10.8);
 }
});
test('legacy dialogue imports acquire the capture profile without losing the story',()=>{const old=dialoguePreset();delete old.calibration;old.viewport='cinema';const loaded=validateDialogue(old);assert.equal(loaded.viewport,'warcraft');assert.deepEqual(loaded.messages,old.messages);assert.equal(dialogueProjection(loaded).depth,400);});
test('moving the plane farther away retains screen size and increases physical scale',()=>{const d=dialoguePreset(),a=dialogueProjection(d);d.calibration.depth=1200;const b=dialogueProjection(d);assert.equal(b.width,a.width);assert.equal(b.height,a.height);assert.equal(b.top,a.top);assert.ok(Math.abs(b.scale/a.scale-3)<1e-10);});
test('width, bottom margin and native frustum controls update the same projection',()=>{const d=dialoguePreset(),a=dialogueProjection(d);d.layout.width=95;let b=dialogueProjection(d);assert.ok(b.width>a.width);assert.ok(b.frustumWidth>a.frustumWidth);assert.ok(b.scale>a.scale);const top=b.top;d.layout.bottom+=3;b=dialogueProjection(d);assert.ok(Math.abs(b.top-(top-3))<1e-10);assert.ok(b.centerY>a.centerY);d.calibration.frustumWidth=1.2;b=dialogueProjection(d);assert.equal(b.clipped,true);assert.match(projectionJass(d),/library DialogueProjection/);assert.match(projectionJass(d),new RegExp(b.frustumWidth.toFixed(6).replace('.','\\.')));});
test('calibration import rejects unbounded or nonnumeric geometry before producing JASS',()=>{for(const value of [null,{version:2},{version:1,planeWidth:Infinity}]){const d=dialoguePreset();d.calibration=value;assert.throws(()=>validateDialogue(d));}const d=dialoguePreset();d.calibration.centerY='0\nendglobals';assert.throws(()=>validateDialogue(d));});

import {modelPreviewRect} from '../dist/dialogue-calibration.js';
test('gameplay artwork reproduces the recorded Classic frame edges without changing exported projection',()=>{
 const d=dialoguePreset();d.layout.width=68;d.layout.bottom=3;
 const nativeBefore=projectionJass(d),p=dialogueProjection(d),v=modelPreviewRect(p);
 // Measured source PNG landmarks -> calibrated-moving-0.png client landmarks.
 for(const [source,target] of [[79.5,321.5],[1862.5,1600.5]])assert.ok(Math.abs(v.left+source/1942*v.width-target)<1);
 for(const [source,target] of [[62,256],[751.5,737]])assert.ok(Math.abs(v.top+source/809*v.height-target)<1);
 assert.equal(projectionJass(d),nativeBefore);
 d.calibration.depth=1200;const far=modelPreviewRect(dialogueProjection(d));
 for(const key of ['left','top','width','height'])assert.ok(Math.abs(far[key]-v[key])<1e-8);
});
