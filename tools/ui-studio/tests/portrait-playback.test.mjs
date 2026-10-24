import test from 'node:test';import assert from 'node:assert/strict';
import {portraitPlayback} from '../dist/portrait-playback.js';
const reg={talk:1,idleVariants:[{index:0,durationMs:2666},{index:2,durationMs:2667},{index:3,durationMs:10667},{index:5,durationMs:1333}]};
test('idle variants play complete clips, include Stand and wrap without drift',()=>{
 const state={};assert.deepEqual(portraitPlayback(reg,state,100,false),{sequence:0,elapsed:0});
 assert.deepEqual(portraitPlayback(reg,state,2766,false),{sequence:2,elapsed:0});
 assert.deepEqual(portraitPlayback(reg,state,5433,false),{sequence:3,elapsed:0});
 assert.deepEqual(portraitPlayback(reg,state,16100,false),{sequence:5,elapsed:0});
 assert.deepEqual(portraitPlayback(reg,state,17433,false),{sequence:0,elapsed:0});
 assert.deepEqual(portraitPlayback(reg,state,100+17333*1000+75,false),{sequence:0,elapsed:75});
});
test('speech interrupts long idle; returning to idle starts the primary clip',()=>{
 const state={};portraitPlayback(reg,state,0,false);assert.equal(portraitPlayback(reg,state,6000,false).sequence,3);
 assert.deepEqual(portraitPlayback(reg,state,6100,true),{sequence:1,elapsed:0});
 assert.deepEqual(portraitPlayback(reg,state,6200,true),{sequence:1,elapsed:100});
 assert.deepEqual(portraitPlayback(reg,state,6300,false),{sequence:0,elapsed:0});
});
test('rewinding the editor resets the clip clock',()=>{
 const state={};portraitPlayback(reg,state,3000,false);portraitPlayback(reg,state,6000,false);
 assert.deepEqual(portraitPlayback(reg,state,0,false),{sequence:0,elapsed:0});
});
