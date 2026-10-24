// One elongated meridian shared by the pink envelope and interior lightning.
const profile=[[0,0],[-4,5],[-10,11],[-22,20],[-38,26],[-52,24],[-69,17],[-86,8],[-107,0]];
function radius(x){for(let i=1;i<profile.length;i++){const [a,ra]=profile[i-1],[b,rb]=profile[i];if(x>=b)return ra+(rb-ra)*(x-a)/(b-a);}return 0;}
module.exports={profile,radius};
