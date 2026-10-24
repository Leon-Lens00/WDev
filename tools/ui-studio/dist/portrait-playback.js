// Full native clip durations; deterministic idle variation, interrupted by speech.
export function portraitPlayback(registry,state,time,talking){
 const variants=registry.idleVariants;
 if(!variants?.length)throw Error('El retrato no declara variantes de reposo.');
 if(state.talking!==talking||!Number.isFinite(state.since)||time<state.since){state.talking=talking;state.since=time;}
 let elapsed=Math.max(0,time-state.since);
 if(talking)return {sequence:registry.talk,elapsed};
 const cycle=variants.reduce((sum,v)=>sum+v.durationMs,0);
 if(!(cycle>0))throw Error('Duración de reposo inválida.');
 elapsed%=cycle;
 for(const v of variants){if(elapsed<v.durationMs)return {sequence:v.index,elapsed};elapsed-=v.durationMs;}
 return {sequence:variants[0].index,elapsed:0};
}
