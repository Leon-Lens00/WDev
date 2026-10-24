import test from 'node:test';import assert from 'node:assert/strict';
import {dialoguePreset,validateDialogue,DialoguePlayer} from '../dist/dialogue-core.js';
import {composeMessage,visibleFragments,compileDialogue,measureText,TEXT_POOL,speakerLabel} from '../dist/dialogue-layout.js';
test('proportional widths wrap W earlier than i, with bounded rows and fragments',()=>{
 const d=dialoguePreset(),message={speaker:'left',text:'W'.repeat(400),presentation:'wide'};
 const wide=composeMessage(d,message),narrow=composeMessage(d,{...message,text:'i'.repeat(400)});
 assert.ok(wide.pages.length>narrow.pages.length);
 for(const p of [...wide.pages,...narrow.pages]){
  assert.ok(p.lines.length<=3);assert.ok(p.fragments.length<=12);
  for(const f of p.fragments)assert.ok(f.x+f.width<=p.width+.001);
 }
});
test('paragraphs, long words and Unicode survive pagination, with fixed fragment positions',()=>{
 const d=dialoguePreset(),text='á ñ u\u0301 ¿Señal?\n\n'+('Árboles y WWW '.repeat(35))+'Z'.repeat(180);
 const c=composeMessage(d,{speaker:'right',presentation:'compact',text});
 assert.equal(c.pages.map(p=>p.text).join('').replace(/\s/g,''),text.replace(/\s/g,''));
 assert.ok(c.pages[0].lines.includes(''));
 for(const p of c.pages)for(let n=0;n<=p.characters.length;n++){
  const visible=visibleFragments(p,n);
  assert.deepEqual(visible.map(f=>[f.left,f.top]),p.fragments.map(f=>[f.left,f.top]));
  assert.equal(visible.map(f=>f.text).join(''),p.characters.slice(0,n).join('').replaceAll('\n',''));
 }
});
test('compact frame, font and positions derive from the same message without changing global layout',()=>{
 const d=dialoguePreset(),m={speaker:'right',text:'Mensaje',presentation:'wide'},a=composeMessage(d,m).pages[0],b=composeMessage(d,{...m,presentation:'compact'}).pages[0];
 assert.ok(b.plane.width<a.plane.width);assert.equal(b.fontHeight,a.fontHeight);assert.equal(d.layout.width,68);assert.ok(b.top>a.top);assert.equal(TEXT_POOL.total,14);
});
test('legacy messages migrate, unsupported glyphs warn, native color codes and chapter overflow reject',()=>{
 const d=dialoguePreset();delete d.messages[0].presentation;assert.equal(validateDialogue(d).messages[0].presentation,'wide');
 assert.ok(composeMessage(d,{speaker:'left',text:'👩‍🚀'}).warnings.length);
 const colors=dialoguePreset();colors.messages[0].text='|cffff0000Rojo|r';assert.throws(()=>validateDialogue(colors),/selector de color/);
 const huge=dialoguePreset();huge.messages=Array.from({length:4},(_,i)=>({id:'m'+i,speaker:'left',text:'a'.repeat(4000)}));assert.throws(()=>compileDialogue(huge),/8190/);
});
test('empty messages and page transitions keep reusable slots and punctuation timing',()=>{
 const d=dialoguePreset();d.messages=[{id:'empty',speaker:'left',text:''},{id:'long',speaker:'right',text:'Uno.\nDos.\nTres.\nCuatro.'}];
 const p=new DialoguePlayer(d);assert.ok(p.complete);assert.equal(p.advance(0),'message');assert.equal(p.advance(1),'complete');assert.equal(p.advance(2),'page');assert.equal(p.text,'');assert.equal(p.layouts[1].text,'Cuatro.');
});

test('word packing always fits four slots, even when words fit poorly in the tag width',()=>{
 const d=dialoguePreset();for(let length=8;length<30;length++){
  const c=composeMessage(d,{speaker:'left',text:('a'.repeat(length)+' ').repeat(40)});
  for(const p of c.pages)assert.ok(p.fragments.every(f=>f.slot<12));
 }
 assert.ok(speakerLabel('W'.repeat(40),29.16).endsWith('…'));assert.ok(measureText(speakerLabel('W'.repeat(40),29.16),29.16*1.37)<=350);
});

test('measured advances agree with independent texttag lab fixture extents',()=>{
 // Ink extents can differ from advances by glyph bearings: allow four pixels.
 assert.ok(Math.abs(measureText('i'.repeat(77)+'FIN',29.16)-424)<=4);
 assert.ok(Math.abs(measureText('0123 56789 0123 56789 0123 56789 012 FIN',.018*1080)-350)<=5);
});
