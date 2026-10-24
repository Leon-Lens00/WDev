import test from 'node:test';import assert from 'node:assert/strict';
import {dialoguePreset,validateDialogue,dialoguePages,DialoguePlayer,graphemes} from '../dist/dialogue-core.js';
test('dialogue round-trip is independent from inventory and preserves accents',()=>{const d=dialoguePreset();assert.deepEqual(validateDialogue(JSON.parse(JSON.stringify(d))),d);assert.equal(d.messages[0].speaker,'right');assert.ok(d.messages[2].text.includes('río'));assert.equal(d.elements,undefined);});
test('typewriter uses elapsed time and does not reveal the entire phrase immediately',()=>{const d=dialoguePreset();d.lettersPerSecond=20;d.punctuationPause=false;const p=new DialoguePlayer(d,1000);p.update(1049);assert.equal(p.text,'');p.update(1150);assert.equal(p.text,'Sé ');assert.equal(p.complete,false);});
test('advance completes before changing pages, speakers and retaining the final message',()=>{
 const d=dialoguePreset();d.messages[1].text='Primero.\nSegundo.\nTercero.\nCuarto.';
 const p=new DialoguePlayer(d);
 assert.equal(p.advance(0),'complete');assert.equal(p.message,0);
 assert.equal(p.advance(1),'message');assert.equal(p.message,1);
 assert.equal(p.advance(2),'complete');assert.equal(p.advance(3),'page');assert.equal(p.page,1);
 assert.equal(p.advance(4),'complete');assert.equal(p.text,'Cuarto.');
 assert.equal(p.advance(5),'message');assert.equal(p.advance(6),'complete');assert.equal(p.advance(7),'finished');assert.equal(p.message,2);assert.equal(p.complete,true);
});
test('punctuation inserts a pause and pause/resume preserves timing',()=>{const d=dialoguePreset();d.messages=[{id:'one',speaker:'left',text:'A,B'}];d.lettersPerSecond=10;const p=new DialoguePlayer(d);p.update(200);assert.equal(p.text,'A,');p.update(799);assert.equal(p.text,'A,');p.update(800);assert.equal(p.text,'A,B');const q=new DialoguePlayer(d);q.pause(50);q.update(1000);assert.equal(q.text,'');q.resume(1050);q.update(1099);assert.equal(q.text,'');q.update(1100);assert.equal(q.text,'A');});
test('long messages paginate without truncation, including long words',()=>{const text='Palabra '.repeat(100)+'ABCDEFGHIJKLMN';const pages=dialoguePages(text,12,3);assert.ok(pages.length>3);for(const page of pages){assert.ok(page.split('\n').length<=3);assert.ok(page.split('\n').every(line=>graphemes(line).length<=12));}assert.equal(pages.join('').replace(/\s/g,''),text.replace(/\s/g,''));});
test('Unicode graphemes are revealed without cutting emoji sequences or accents',()=>{assert.equal(graphemes('a\u0301👩‍🚀').length,2);const d=dialoguePreset();d.messages=[{id:'one',speaker:'left',text:'a\u0301👩‍🚀'}];d.lettersPerSecond=10;const p=new DialoguePlayer(d);p.update(100);assert.equal(p.text,'a\u0301');});
test('invalid imports reject arbitrary image URLs, duplicates, unsafe colors and bad speeds',()=>{for(const change of [d=>d.portraits.left.image='https://example.com/p.png',d=>d.messages.push({...d.messages[0]}),d=>d.layout.color='red;display:none',d=>d.lettersPerSecond=0]){const d=dialoguePreset();change(d);assert.throws(()=>validateDialogue(d));}});

test('talk continues through punctuation waits and returns to idle at page completion',()=>{const d=dialoguePreset();d.messages=[{id:'speech',speaker:'left',text:'A,B.C'}];d.lettersPerSecond=10;const p=new DialoguePlayer(d);p.update(200);assert.equal(p.text,'A,');assert.equal(p.talking,true);p.update(799);assert.equal(p.text,'A,');assert.equal(p.talking,true);p.update(900);assert.equal(p.text,'A,B.');assert.equal(p.talking,true);p.update(1500);assert.equal(p.complete,true);assert.equal(p.talking,false);const q=new DialoguePlayer(d);q.update(100);q.advance(150);assert.equal(q.talking,false);});
