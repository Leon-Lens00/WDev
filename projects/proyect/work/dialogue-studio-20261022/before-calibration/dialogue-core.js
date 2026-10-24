// Conversation designs are separate from the InventorySys layout contract.
export const dialoguePreset=()=>({format:'wc3-dialogue-studio',version:1,name:'Conversación · enlace de misión',target:'1.27b',viewport:'cinema',background:'terrain',lettersPerSecond:30,punctuationPause:true,layout:{width:84.6,bottom:6,font:2.45,color:'#e78691',leftColor:'#81c8e2'},portraits:{left:{name:'X',image:'reference-x'},right:{name:'ALIA',image:'reference-alia'}},messages:[{id:'message-1',speaker:'right',text:'Sé que has trabajado sin descanso.\nLos incidentes no dejan de llegar...'}, {id:'message-2',speaker:'left',text:'Lo sé, Alia. Pero no podemos detenernos.\n¿Has encontrado la fuente de la señal?'},{id:'message-3',speaker:'right',text:'Sí. Proviene del bosque, al otro lado del río.\nTen cuidado. Estaremos en contacto.'}]});
export const graphemes=text=>typeof Intl.Segmenter==='function'?[...new Intl.Segmenter('es',{granularity:'grapheme'}).segment(text)].map(x=>x.segment):Array.from(text);
export function validateDialogue(value){
 if(!value||value.format!=='wc3-dialogue-studio'||value.version!==1)throw Error('Este archivo no es un diálogo de UI Studio v1.');
 const d=JSON.parse(JSON.stringify(value));
 if(typeof d.name!=='string'||!d.name.trim()||d.name.length>100)throw Error('Nombre del diálogo inválido.');
 if(d.target!=='1.27b'||!['cinema','16:9','4:3'].includes(d.viewport)||!['terrain','neutral'].includes(d.background))throw Error('Vista del diálogo inválida.');
 if(!Number.isFinite(d.lettersPerSecond)||d.lettersPerSecond<5||d.lettersPerSecond>80||typeof d.punctuationPause!=='boolean')throw Error('Velocidad inválida.');
 const l=d.layout;if(l&&l.leftColor===undefined)l.leftColor='#81c8e2';if(!l||!Number.isFinite(l.width)||l.width<60||l.width>100||!Number.isFinite(l.bottom)||l.bottom<0||l.bottom>15||!Number.isFinite(l.font)||l.font<1.8||l.font>3.2||(!/^#[a-f\d]{6}$/i.test(l.color)||!/^#[a-f\d]{6}$/i.test(l.leftColor)))throw Error('Diseño del diálogo inválido.');
 for(const side of ['left','right']){const p=d.portraits?.[side];if(!p||typeof p.name!=='string'||p.name.length>40||typeof p.image!=='string'||!(['reference-x','reference-alia'].includes(p.image)||(/^data:image\/(png|jpeg|webp);base64,[A-Za-z\d+/]+=*$/.test(p.image)&&p.image.length<=3e6)))throw Error('Retrato inválido: usa una imagen local PNG, JPEG o WebP.');}
 if(!Array.isArray(d.messages)||d.messages.length<1||d.messages.length>80)throw Error('El diálogo debe tener entre 1 y 80 mensajes.');
 const ids=new Set();for(const m of d.messages){if(!m||typeof m.id!=='string'||!/^[A-Za-z][A-Za-z\d_-]{0,79}$/.test(m.id)||ids.has(m.id)||!['left','right'].includes(m.speaker)||typeof m.text!=='string'||m.text.length>4000)throw Error('Mensaje inválido o repetido.');ids.add(m.id);}
 return d;
}
// Fixed lines prevent words jumping to another line as their letters appear.
export function dialoguePages(text,columns=36,rows=3){
 const lines=[];for(const paragraph of text.replaceAll('\r','').split('\n')){
  let line='';for(const word of paragraph.split(/\s+/).filter(Boolean)){
   const parts=graphemes(word);if(graphemes(line).length+(line?1:0)+parts.length<=columns){line+=(line?' ':'')+word;continue;}
   if(line){lines.push(line);line='';}while(parts.length>columns)lines.push(parts.splice(0,columns).join(''));line=parts.join('');
  }lines.push(line);
 }
 const groups=[];for(let i=0;i<lines.length;i+=rows)groups.push(lines.slice(i,i+rows));const last=groups.at(-1),previous=groups.at(-2);if(rows>1&&previous?.length>1&&last.length===1&&graphemes(last[0]).length<columns/2)last.unshift(previous.pop());const pages=groups.map(group=>group.join('\n'));return pages.length?pages:[''];
}
export class DialoguePlayer{
 constructor(design,now=0,index=0){this.design=design;this.message=index;this.page=0;this.finished=false;this.paused=false;this.begin(now);}
 begin(now){this.pages=dialoguePages(this.design.messages[this.message].text,Math.max(28,Math.floor(36*2.45/this.design.layout.font)));this.characters=graphemes(this.pages[this.page]||'');this.count=0;this.nextAt=now+1000/this.design.lettersPerSecond;}
 get text(){return this.characters.slice(0,this.count).join('');}
 get complete(){return this.count>=this.characters.length;}
 update(now){if(this.paused||this.finished)return;while(!this.complete&&now>=this.nextAt){const c=this.characters[this.count++];this.nextAt+=(1000/this.design.lettersPerSecond)*(this.design.punctuationPause&&/[,.!?…:;]/.test(c)?6:1);}}
 advance(now){if(this.paused)this.resume(now);if(this.finished)return 'finished';if(!this.complete){this.count=this.characters.length;return 'complete';}if(this.page+1<this.pages.length){this.page++;this.begin(now);return 'page';}if(this.message+1<this.design.messages.length){this.message++;this.page=0;this.begin(now);return 'message';}this.finished=true;return 'finished';}
 pause(now){if(!this.paused){this.paused=true;this.pausedAt=now;}}
 resume(now){if(this.paused){this.nextAt+=now-this.pausedAt;this.paused=false;}}
}
export function dialogueNotes(d){return `DIÁLOGO · ${d.name}\n\nPrototipo de conversación para diseñar en UI Studio. No modifica el W3X.\nEscritura: ${d.lettersPerSecond} caracteres por segundo; pausa de puntuación: ${d.punctuationPause?'sí':'no'}.\nClic/Enter: completar la página y después avanzar.\n\nLa copia de prueba Classic 1.27b está en /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system/. El marco MDX800 y las texturas BLP1 están preparados; el texto se escribe mediante un temporizador JASS. Este JSON es un diseño separado: editarlo o descargarlo no recompila el W3X. El perfil probado es local, de un jugador; otras resoluciones y multijugador requieren su comprobación. Los retratos de Mega Man proceden de la referencia suministrada y son provisionales. El PNG del marco fue preparado con ImageGen a partir de esa referencia. Los recursos convertidos y sus fuentes se conservan en esa carpeta de prueba.\n\nLos datos de inventario son una referencia técnica independiente; no forman parte de esta escena.\n`;
}
