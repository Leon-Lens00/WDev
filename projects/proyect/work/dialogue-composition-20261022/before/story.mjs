import {projectionJass} from '/home/snz/Documentos/WarDatsPy/ui-studio/dist/dialogue-calibration.js';
import {dialoguePreset,validateDialogue,dialoguePages,graphemes,dialogueNotes} from '/home/snz/Documentos/WarDatsPy/ui-studio/dist/dialogue-core.js';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const args=process.argv.slice(2);if(args.length&&!(args.length===2&&args[0]==='--input'))throw Error('Usage: node tools/story.mjs [--input /absolute/design.json]');
const input=args[1]?path.resolve(args[1]):path.join(root,'conversation.wc3dialogue.json');
if(args.length&&!fs.existsSync(input))throw Error('Dialogue JSON does not exist: '+input);
const design=validateDialogue(fs.existsSync(input)?JSON.parse(fs.readFileSync(input,'utf8')):dialoguePreset());
fs.writeFileSync(path.join(root,'src/DialogueProjection.j'),projectionJass(design));
const q=s=>'"'+s.replaceAll('\\','\\\\').replaceAll('"','\\"').replaceAll('\n','\\n').replaceAll('\r','')+'"';
let init=[],cursor=0,story=[];
for(const message of design.messages)for(const page of dialoguePages(message.text,Math.max(28,Math.floor(36*2.45/design.layout.font)),3))story.push({speaker:message.speaker,text:page});
story.forEach((message,i)=>{
 init.push(`set DialogueStart[${i}] = ${cursor}`,`set DialogueSpeaker[${i}] = ${q(design.portraits[message.speaker].name)}`,`set DialogueLeft[${i}] = ${message.speaker==='left'}`);
 const letters=graphemes(message.text);
 for(let n=0;n<=letters.length;n++){
  const lines=letters.slice(0,n).join('').split('\n');
  for(let j=0;j<3;j++)init.push(`set DialogueLine${j}[${cursor}] = ${q(lines[j]??'')}`);
  init.push(`set DialoguePause[${cursor}] = ${design.punctuationPause&&/[.,!?…:;]/u.test(letters[n-1]??'')?6:1}`);
  cursor++;
 }
 init.push(`set DialogueEnd[${i}] = ${cursor-1}`);
});
if(cursor>=8191)throw new Error('Demo exceeds Classic array capacity; split the story into chapters.');
const source=`// Generated from conversation.wc3dialogue.json. Grapheme-safe prefixes, no UTF-8 byte slicing.\nlibrary DialogueData initializer Init\nglobals\n string array DialogueLine0\n string array DialogueLine1\n string array DialogueLine2\n string array DialogueSpeaker\n boolean array DialogueLeft\n integer array DialogueStart\n integer array DialogueEnd\n integer array DialoguePause\n constant real DIALOGUE_SPEED = ${design.lettersPerSecond.toFixed(3)}\n constant integer DIALOGUE_COUNT = ${story.length}\nendglobals\nprivate function Init takes nothing returns nothing\n ${init.join('\n ')}\nendfunction\nendlibrary\n`;
fs.writeFileSync(path.join(root,'src/DialogueData.j'),source);
fs.writeFileSync(path.join(root,'conversation.wc3dialogue.json'),JSON.stringify(design,null,2));
fs.writeFileSync(path.join(root,'evidence/story.json'),JSON.stringify({messages:story.length,prefixes:cursor,lettersPerSecond:design.lettersPerSecond,unicode:'Intl.Segmenter graphemes'},null,2));
console.log(`${story.length} pages, ${cursor} Unicode-safe prefixes`);
