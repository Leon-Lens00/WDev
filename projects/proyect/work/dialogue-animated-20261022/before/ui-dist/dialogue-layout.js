import {dialogueFontProfile as profile} from './dialogue-font-metrics.js';
import {dialogueProjection,cameraPlane} from './dialogue-calibration.js';
export const segmentText=text=>[...new Intl.Segmenter('es',{granularity:'grapheme'}).segment(text)].map(x=>x.segment);
export const TEXT_POOL=Object.freeze({rows:3,columns:4,body:12,total:14});
export function messageDesign(design,message){
 const compact=message.presentation==='compact';
 return {...design,layout:{...design.layout,width:design.layout.width*(compact?.76:1)}};
}
export function measureText(text,fontPx){
 let width=0;for(const g of segmentText(text.normalize('NFC'))){width+=(profile.advances[g]??profile.fallback)*fontPx/profile.fontPx;}return width;
}
// All coordinates are in the reference 1920x1080 client. The same output feeds JASS.
// The client-to-UIText transform is measured in the current camera, not universal.
export const textCoordinates=cameraPlane;
export const toUIText=(x,bottom)=>({x:(x-textCoordinates.originX)/textCoordinates.unitX,y:(textCoordinates.originY-bottom)/textCoordinates.unitY});
function wrap(text,width,fontPx){
 const lines=[];
 for(const paragraph of text.replaceAll('\r','').split(/\n|\|n/)){
  let line='';
  for(const word of paragraph.split(/\s+/).filter(Boolean)){
   const candidate=line+(line?' ':'')+word;
   if(measureText(candidate,fontPx)*profile.safety<=width){line=candidate;continue;}
   if(line){lines.push(line);line='';}
   for(const letter of segmentText(word)){
    if(line&&measureText(line+letter,fontPx)*profile.safety>width){lines.push(line);line='';}
    line+=letter;
   }
  }
  lines.push(line);
 }
 return lines;
}
function fragments(text,fontPx,maxWidth,row,start,preferWords=true){
 const out=[];let fragment='',x=0,offset=start;
 const flush=()=>{if(!fragment)return;out.push({text:fragment,x,row,start:offset,end:offset+segmentText(fragment).length,width:measureText(fragment,fontPx)});offset+=segmentText(fragment).length;x+=measureText(fragment,fontPx);fragment='';};
 for(const token of preferWords?(text.match(/\S+\s*|\s+/g)||[]):segmentText(text)){
  if(fragment&&measureText(fragment+token,fontPx)*profile.safety>maxWidth)flush();
  for(const g of segmentText(token)){
   if(fragment&&measureText(fragment+g,fontPx)*profile.safety>maxWidth)flush();
   fragment+=g;
  }
 }
 flush();return out.length>TEXT_POOL.columns&&preferWords?fragments(text,fontPx,maxWidth,row,start,false):out;
}
export function composeMessage(design,message){
 const d=messageDesign(design,message),plane=dialogueProjection(d),compact=message.presentation==='compact';
 const fontHeight=.027*design.layout.font/2.45,fontPx=fontHeight*1080;
 const width=plane.width*19.2*.65,left=(plane.left+plane.width*.25)*19.2,top=(plane.top+plane.height*.675)*10.8;
 const lineHeight=fontPx*1.35,tagLimit=Math.min(profile.tagWidth*fontHeight/.027,width/TEXT_POOL.columns*1.5);
 // A line must fit the pool as well as the frame. Conservative native tag width avoids auto-wrap.
 const lineWidth=Math.min(width,tagLimit*TEXT_POOL.columns/profile.safety);
 const lines=wrap(message.text,lineWidth,fontPx),pages=[];
 for(let i=0;i<lines.length;i+=TEXT_POOL.rows){
  const group=lines.slice(i,i+TEXT_POOL.rows);let offset=0;const chunks=[];
  group.forEach((line,row)=>{const parts=fragments(line,fontPx,tagLimit,row,offset);if(parts.length>TEXT_POOL.columns)throw Error('El renglón excede el pool de texto.');chunks.push(...parts.map((p,col)=>({...p,slot:row*TEXT_POOL.columns+col,left:left+p.x,top:top+row*lineHeight})));offset+=segmentText(line).length+(row<group.length-1?1:0);});
  const text=group.join('\n');pages.push({text,lines:group,fragments:chunks,characters:segmentText(text),fontHeight,fontPx,lineHeight,left,top,width:lineWidth,plane,presentation:compact?'compact':'wide'});
 }
 const unsupported=[...new Set(segmentText(message.text.normalize('NFC')).filter(g=>!['\n','\r'].includes(g)&&profile.advances[g]===undefined))];
 return {pages,warnings:[...(unsupported.length?['Glifos sin métricas Classic comprobadas: '+unsupported.slice(0,8).join(' ')]:[]),...(/\|[cr]/i.test(message.text)?['Los códigos de color se muestran como texto; usa el selector de color.']:[])],profile:profile.id,pool:TEXT_POOL};
}
export function previewGlyphs(text,fontPx){
 let x=0;return segmentText(text).map(g=>{const width=measureText(g,fontPx),ttf=(profile.ttfAdvances[g.normalize('NFC')]??profile.fallback)*fontPx/profile.fontPx,item={text:g,x,width,scale:width/(ttf||width||1)};x+=width;return item;});
}
export function visibleFragments(page,count){return page.fragments.map(f=>({...f,text:segmentText(f.text).slice(0,Math.max(0,count-f.start)).join('')}));}
export function speakerLabel(name,fontPx){
 const letters=segmentText(name.toUpperCase());if(measureText(letters.join(''),fontPx*1.37)<=350)return letters.join('');
 while(letters.length&&measureText(letters.join('')+'…',fontPx*1.37)>350)letters.pop();return letters.join('')+'…';
}
export function compileDialogue(design){
 const pages=design.messages.flatMap((m,index)=>composeMessage(design,m).pages.map(p=>({...p,speaker:m.speaker,message:index,name:speakerLabel(design.portraits[m.speaker].name,p.fontPx),color:m.speaker==='left'?design.layout.leftColor:design.layout.color})));
 const prefixes=pages.reduce((n,p)=>n+p.characters.length+1,0);
 if(prefixes>=8191||pages.length>=8191)throw Error('El capítulo supera 8190 prefijos Classic. Divídelo en conversaciones más cortas.');
 if(pages.some(p=>p.text.includes('|')||p.name.includes('|')))throw Error('Usa el selector de color; no se admiten códigos |c/|r en el diálogo.');
 if(pages.some(p=>p.fragments.some(f=>new TextEncoder().encode(f.text).length>900)))throw Error('Un fragmento excede 900 bytes; revisa los grafemas del texto.');
 if(pages.some(p=>new TextEncoder().encode(p.name).length>200))throw Error('Nombre demasiado largo para el tag Classic.');
 return {pages,prefixes,pool:TEXT_POOL,profile:profile.id};
}
