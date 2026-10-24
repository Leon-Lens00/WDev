import fs from 'node:fs';import path from 'node:path';import {fileURLToPath} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..'),cases=[];
const add=(name,font,text,kind='static')=>cases.push({name,font,text,kind,bytes:Buffer.byteLength(text),graphemes:[...new Intl.Segmenter('es',{granularity:'grapheme'}).segment(text)].length,explicitLines:text.split('\n').length});
for(const font of [.018,.027,.036,.045])for(const n of [40,80,160])add(`words-${font}-${n}`,font,('0123 56789 '.repeat(20)).slice(0,n-4)+' FIN');
for(const n of [40,80,160])add(`unbroken-.027-${n}`,.027,'W'.repeat(n-3)+'FIN');
add('narrow-i-80',.027,'i'.repeat(77)+'FIN');add('wide-W-80',.027,'W'.repeat(77)+'FIN');
for(const [rows,cols] of [[2,70],[4,35],[8,18]])add(`paragraph-${rows}x${cols}`,.027,Array.from({length:rows},(_,i)=>`L${String(i+1).padStart(2,'0')} `+('0123 56789 '.repeat(8)).slice(0,cols-4)).join('\n')+' FIN');
for(const target of [128,256,512,1024]){let text='';for(let row=1;text.length<target-4;row++){let s=`L${String(row).padStart(2,'0')} `+'abcdefghijklmnopqrstuvwx0123';text+=s.slice(0,Math.min(32,target-4-text.length));if(text.length<target-4)text+='\n';}add(`payload-${target}-bytes`,.010,text+' FIN');}
add('spanish-accents',.027,'¿Dónde está la señal? El pingüino cruzó el río. ¡Sí, aquí está! FIN');
add('newlines-backslash-n',.027,'PRIMERA LINEA\nSEGUNDA LINEA\nTERCERA LINEA FIN');
add('newlines-pipe-n',.027,'PRIMERA LINEA|nSEGUNDA LINEA|nTERCERA LINEA FIN');
add('inline-colors',.027,'Inicio |cFFFF0000ROJO|r y |cFF00FFFFCIAN|r. FIN');
const typing='¿Dónde está la señal? El pingüino cruzó el río. Ahora podemos continuar la conversación sin cortar las letras. FIN';add('typewriter-unicode',.027,typing,'typing');
const q=s=>'"'+s.replaceAll('\\','\\\\').replaceAll('"','\\"').replaceAll('\n','\\n')+'"';
let lines=[];for(const [i,c] of cases.entries())for(const [key,val] of Object.entries({LabName:c.name,LabFont:c.font,LabText:c.text,LabBytes:c.bytes,LabTyping:c.kind==='typing'})){if(typeof val==='string'&&val.length>200){lines.push(`set ${key}[${i}] = ${q(val.slice(0,200))}`);for(let at=200;at<val.length;at+=200)lines.push(`set ${key}[${i}] = ${key}[${i}] + ${q(val.slice(at,at+200))}`);}else lines.push(`set ${key}[${i}] = ${typeof val==='string'?q(val):typeof val==='number'&&key==='LabFont'?val.toFixed(5):val}`);}
const prefixes=['',...Array.from(new Intl.Segmenter('es',{granularity:'grapheme'}).segment(typing)).map((x,i,all)=>all.slice(0,i+1).map(a=>a.segment).join(''))];prefixes.forEach((s,i)=>lines.push(`set LabPrefix[${i}] = ${q(s)}`));
fs.writeFileSync(path.join(root,'src/TextTagCases.j'),`library TextTagCases initializer Init\nglobals\n string array LabName\n string array LabText\n string array LabPrefix\n real array LabFont\n integer array LabBytes\n boolean array LabTyping\n constant integer LAB_COUNT = ${cases.length}\n constant integer LAB_TYPE_LENGTH = ${prefixes.length-1}\nendglobals\nprivate function Init takes nothing returns nothing\n ${lines.join('\n ')}\nendfunction\nendlibrary\n`);
fs.mkdirSync(path.join(root,'evidence/texttag-lab'),{recursive:true});fs.writeFileSync(path.join(root,'evidence/texttag-lab/cases.json'),JSON.stringify(cases,null,2));console.log(`${cases.length} native texttag cases`);
