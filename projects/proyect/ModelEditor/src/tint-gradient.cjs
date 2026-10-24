// Transfer player hue while retaining original saturation gradients and highlights.
function hsv(rgb){const max=Math.max(...rgb),min=Math.min(...rgb),d=max-min;let h=0;if(d){const i=rgb.indexOf(max);h=(i===0?(rgb[1]-rgb[2])/d:i===1?(rgb[2]-rgb[0])/d+2:(rgb[0]-rgb[1])/d+4)*60;if(h<0)h+=360;}return [h,max?d/max:0,max];}
function hueRgb(h){h=((h%360)+360)%360;const x=1-Math.abs(h/60%2-1);return h<60?[1,x,0]:h<120?[x,1,0]:h<180?[0,1,x]:h<240?[0,x,1]:h<300?[x,0,1]:[1,0,x];}
function gradientTint(source,target,index){const [h,s,v]=hsv(Array.from(source)),[th,ts,tv]=hsv(target.map(x=>x/255));if(!v)return new Float32Array(3);const floor=v*(1-s),chroma=v*s;if(index===1)return Float32Array.from(source);const rgb=hueRgb(th);return Float32Array.from(rgb,x=>floor+chroma*tv*((1-ts)+ts*x));}
module.exports={gradientTint};
