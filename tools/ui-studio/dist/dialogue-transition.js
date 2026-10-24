// Shared milliseconds, quantized to the native 10ms clock at validation.
export const transitionPreset=()=>({lineOpen:150,unfold:200,acquire:300,loss:300,fold:150,lineClose:150});
export function validateTransition(value){const out={...transitionPreset(),...value};for(const [k,v] of Object.entries(out)){if(!(k in transitionPreset())||!Number.isFinite(v)||v<10||v>2000||v%10)throw Error('Tiempo de transición inválido: '+k);}return out;}
const clamp=x=>Math.max(0,Math.min(1,x));
export function openingSample(t,c=transitionPreset()){
 const full=c.lineOpen+c.unfold,end=full+c.acquire;
 return {phase:t<c.lineOpen?'Línea de apertura':t<full?'Despliegue':t<end?'Adquiriendo señal':'Diálogo',line: t<c.lineOpen?clamp(t/c.lineOpen):0,panel:clamp((t-c.lineOpen)/c.unfold),noise:1-clamp((t-full)/c.acquire),portraits:t>=full,text:t>=full,done:t>=end};
}
export function closingSample(t,c=transitionPreset(),from=0){
 const foldAt=c.loss,lineAt=foldAt+c.fold,end=lineAt+c.lineClose;
 return {phase:t<foldAt?'Pérdida de señal':t<lineAt?'Plegado':t<end?'Línea de cierre':'Cerrado',line:t>=lineAt?1-clamp((t-lineAt)/c.lineClose):0,panel:t<foldAt?1:1-clamp((t-foldAt)/c.fold),noise:from+(1-from)*clamp(t/c.loss),portraits:t<foldAt,text:false,done:t>=end};
}
export class DialogueTransition{
 constructor(config=transitionPreset(),now=0){this.config=validateTransition(config);this.open(now);}
 open(now){this.started=now;this.closedAt=null;this.requested=false;this.pausedAt=null;this.noiseFrom=0;}
 sample(now){const t=(this.pausedAt??now)-this.started;const out=this.closedAt===null||t<this.closedAt?openingSample(t,this.config):closingSample(t-this.closedAt,this.config,this.noiseFrom);if(this.requested)out.text=false;return out;}
 close(now){if(this.requested)return;const elapsed=(this.pausedAt??now)-this.started;this.closedAt=Math.max(elapsed,this.config.lineOpen+this.config.unfold+this.config.acquire);this.noiseFrom=openingSample(this.closedAt,this.config).noise;this.requested=true;}
 pause(now){if(this.pausedAt===null)this.pausedAt=now;}
 resume(now){if(this.pausedAt!==null){this.started+=now-this.pausedAt;this.pausedAt=null;}}
}
export const portraitPreset=(side,image='')=>({model:image.startsWith('data:')?'image':side==='left'?'paladin':'tauren',scale:1,offsetX:0,offsetY:0});
export function validatePortrait(p,side){const fit={...portraitPreset(side,p.image),...p};if(!['image','paladin','tauren'].includes(fit.model))throw Error('Modelo de retrato inválido.');for(const [k,min,max] of [['scale',.5,1.4],['offsetX',-5,5],['offsetY',-5,5]])if(!Number.isFinite(fit[k])||fit[k]<min||fit[k]>max)throw Error('Encuadre de retrato inválido: '+k);return fit;}
