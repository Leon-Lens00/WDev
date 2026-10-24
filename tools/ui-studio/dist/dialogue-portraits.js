import {portraitPlayback} from './portrait-playback.js';
import {installPortraitBlend} from './portrait-blend.js';
// Actual MDX playback; whole-panel canvas intentionally has no portrait scissor.
let library;
function loadLibrary(){return library??=new Promise((resolve,reject)=>{if(window.ModelViewer)return resolve(window.ModelViewer);const s=document.createElement('script');s.src='assets/dialogue/vendor/mdx-m3-viewer-5.12.js';s.onload=()=>resolve(window.ModelViewer);s.onerror=()=>reject(Error('No se pudo cargar el visor MDX local.'));document.head.append(s);});}
export class PortraitStage{
 constructor(canvas,onStatus){this.canvas=canvas;this.onStatus=onStatus;this.errors=[];this.instances={};this.pending={};this.ready=this.init();this.time=0;}
 async init(){try{const lib=await loadLibrary();this.viewer=new lib.viewer.ModelViewer(this.canvas,{alpha:true,antialias:true,preserveDrawingBuffer:true});this.viewer.addHandler(lib.viewer.handlers.mdx);this.viewer.addHandler(lib.viewer.handlers.blp);this.viewer.on('error',e=>{this.errors.push(e.error||e.message||'recurso');console.error('Portrait resource',e.error,e.fetchUrl,e.reason?.message||String(e.reason));this.onStatus('Error MDX: '+(e.message||e.error));});this.scene=this.viewer.addScene();this.scene.alpha=true;this.scene.camera.ortho(-70,70,-(140*809/1942)/2,(140*809/1942)/2,1,500);this.scene.camera.moveToAndFace([100,0,0],[0,0,0],[0,0,1]);this.registry=await(await fetch('assets/dialogue/portraits/registry.json')).json();for(const id of Object.keys(this.registry))await this.load(id);await this.loadFrame();if(this.errors.length)throw Error('Carga MDX incompleta: '+this.errors.join('; '));this.canvas.dataset.mdxFrame='ready';this.onStatus('MDX reales · encuadre completo, sin recorte rectangular del visor');}catch(e){this.onStatus(e.message);}}
 async loadFrame(){const map={'FrameOpenRed.blp':'FrameOpenRed.blp','FrameOpenBlue.blp':'FrameOpenBlue.blp','Signal.blp':'Signal.blp','PortraitBackground.blp':'PortraitBackground.blp','Line.blp':'Line.blp','Conversation.mdx':'Conversation.mdx'};const m=await this.viewer.load('assets/dialogue/Conversation.mdx',src=>'assets/dialogue/'+map[src.split(/[\\/]/).at(-1)]);if(!m)throw Error('No se pudo cargar el MDX del marco.');this.frame=m.addInstance();this.frame.setScene(this.scene);this.frame.setSequenceLoopMode(0);this.frame.setSequence(0);await this.viewer.whenAllLoaded();}
 async load(id){const model=await this.viewer.load(this.registry[id].preview,src=>{const name=src.split(/[\\/]/).at(-1);return 'assets/dialogue/portraits/'+name;});if(!model)throw Error('No se pudo cargar '+id);this.pending[id]=model;await this.viewer.whenAllLoaded();}
 draw(design,{visible=true,talking=false,speaker='left',time=0,pose='auto',panel={sequence:0,time:0,visible:true}}={}){
  if(!this.viewer||!this.registry)return;
  const H=140*809/1942;
  if(this.frame){const i=this.frame;if(i.sequence!==panel.sequence)i.setSequence(panel.sequence);i.frame=i.model.sequences[panel.sequence].interval[0]+Math.min(panel.time,i.model.sequences[panel.sequence].interval[1]-i.model.sequences[panel.sequence].interval[0]);i.counter=time;i.forced=true;i.setVertexColor([1,1,1,panel.visible?1:0]);}

  for(const [side,center] of [['left',.15],['right',.853]]){
   const p=design.portraits[side],id=p.model;
   let entry=this.instances[side];
   if(entry?.id!==id){if(entry)entry.instance.detach();delete this.instances[side];if(this.pending[id]){const instance=this.pending[id].addInstance();instance.setScene(this.scene);instance.setSequenceLoopMode(2);installPortraitBlend(instance);entry=this.instances[side]={id,instance,sequence:-1,playback:{}};}else continue;}
   if(!entry)continue;
   const i=entry.instance,reg=this.registry[id],isTalk=pose==='talk'||(pose==='auto'&&talking&&speaker===side),sample=portraitPlayback(reg,entry.playback,time,isTalk),sequence=sample.sequence;
   i.portraitPreviewTime=time;
   if(sequence!==entry.sequence){i.setSequence(sequence);entry.sequence=sequence;}
   i.frame=i.model.sequences[sequence].interval[0]+sample.elapsed%(i.model.sequences[sequence].interval[1]-i.model.sequences[sequence].interval[0]);i.forced=true;
   this.canvas.dataset[side+'Sequence']=i.model.sequences[sequence].name;
   i.setLocation([-2,(center-.5)*140+p.offsetX,(.5-(.148+.473)/2)*H+p.offsetY]);i.setScale([p.scale,p.scale,p.scale]);i.setVertexColor(speaker===side?[1,1,1,visible?1:0]:[.65,.65,.65,visible?1:0]);
  }
  if(this.canvas.width!==1120){this.canvas.width=1120;this.canvas.height=Math.round(1120*809/1942);}
  this.scene.viewport.set([0,0,this.canvas.width,this.canvas.height]);this.viewer.update(0);const gl=this.viewer.gl;gl.depthMask(true);gl.clearColor(0,0,0,0);gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);this.viewer.render();
 }
}
