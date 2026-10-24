import test from 'node:test';
import assert from 'node:assert/strict';
import {blendPortraitPose} from '../dist/portrait-blend.js';
test('talk to idle begins at the displayed pose, approaches the moving target and completes',()=>{
 const s={};assert.deepEqual(blendPortraitPose(s,3,0,[[10,0,0]]),[[10,0,0]]);
 assert.deepEqual(blendPortraitPose(s,0,100,[[0,0,0]]),[[10,0,0]]);
 assert.deepEqual(blendPortraitPose(s,0,200,[[2,0,0]]),[[6,0,0]]);
 assert.deepEqual(blendPortraitPose(s,0,300,[[4,0,0]]),[[4,0,0]]);
 assert.deepEqual(blendPortraitPose(s,0,400,[[5,0,0]]),[[5,0,0]]);
});
test('interrupted blend starts at the visible intermediate pose; rewind resets',()=>{
 const s={};blendPortraitPose(s,3,0,[[10,0,0]]);blendPortraitPose(s,0,100,[[0,0,0]]);
 assert.deepEqual(blendPortraitPose(s,0,200,[[0,0,0]]),[[5,0,0]]);
 assert.deepEqual(blendPortraitPose(s,3,210,[[10,0,0]]),[[5,0,0]]);
 assert.deepEqual(blendPortraitPose(s,3,310,[[11,0,0]]),[[8,0,0]]);
 assert.deepEqual(blendPortraitPose(s,0,0,[[1,0,0]]),[[1,0,0]]);
});
