// Preserve the source's neutral highlight component while changing its hue.
// Source MDX/war3-model colors use the channel order already verified in game.
function teamTint(source,rgb) {
  const peak=Math.max(...source);
  if(peak<=0)return new Float32Array(3);
  const highlight=Math.max(0,Math.min(1,Math.min(...source)/peak));
  return Float32Array.from(rgb,x=>peak*(highlight+(1-highlight)*x/255));
}
module.exports={teamTint};
