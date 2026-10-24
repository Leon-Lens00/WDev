// Preview of the 200 ms native actor blend, for camera-baked translation-only bones.
// Keep the last displayed pose when interrupted; a rewind starts a fresh sample.
export function blendPortraitPose(state,sequence,time,target,duration=200){
 const reset=!state.last||target.length!==state.last.length||time<state.time;
 if(reset){state.sequence=sequence;state.from=null;}
 else if(sequence!==state.sequence){state.from=state.last.map(v=>Array.from(v));state.started=time;state.sequence=sequence;}
 const alpha=state.from?Math.min(1,Math.max(0,(time-state.started)/duration)):1;
 const result=target.map((v,i)=>Array.from(v,(x,j)=>state.from?state.from[i][j]+(x-state.from[i][j])*alpha:x));
 if(alpha===1)state.from=null;
 state.last=result;state.time=time;return result;
}
export function installPortraitBlend(instance){
 const update=instance.updateNodes.bind(instance),state={};
 instance.updateNodes=function(dt,forced){
  update(dt,forced);
  const nodes=this.sortedNodes,positions=blendPortraitPose(state,this.sequence,this.portraitPreviewTime??0,nodes.map(n=>n.localLocation));
  for(let i=0;i<nodes.length;i++){nodes[i].localLocation.set(positions[i]);nodes[i].recalculateTransformation(this);}
 };
}
