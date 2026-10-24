// Rounded leading meridian, open curved wake; opacity closes the tail, not geometry.
function radius(x){
 const s=Math.max(0,-x),peak=29,r=22;
 if(s<=peak)return r*Math.sqrt(Math.max(0,1-((s-peak)/peak)**2));
 return r*Math.exp(-.62*((s-peak)/90)**2);
}
const profile=[0,-1,-3,-6,-10,-16,-23,-29,-38,-48,-60,-72].map(x=>[x,radius(x)]);
module.exports={profile,radius};
