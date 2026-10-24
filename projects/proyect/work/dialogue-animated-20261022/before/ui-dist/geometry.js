import {previewGeometry,previewValue} from './projection.js';
import {round} from './core.js';

export function selectionBounds(elements){
 if(!elements.length)return null;
 const x=Math.min(...elements.map(e=>e.x)),y=Math.max(...elements.map(e=>e.y));
 return {x,y,w:Math.max(...elements.map(e=>e.x+e.w))-x,h:y-Math.min(...elements.map(e=>e.y-e.h))};
}

// Clamp one shared delta, so a selection keeps its spacing at the limits.
export function moveSelection(elements,dx,dy){
 if(!elements.length)return [];
 const minX=Math.min(...elements.map(e=>e.x)),maxX=Math.max(...elements.map(e=>e.x));
 const minY=Math.min(...elements.map(e=>e.y)),maxY=Math.max(...elements.map(e=>e.y));
 dx=Math.max(-4-minX,Math.min(4-maxX,dx));dy=Math.max(-4-minY,Math.min(4-maxY,dy));
 return elements.map(e=>({...e,x:round(e.x+dx),y:round(e.y+dy)}));
}

// Opposite edge/corner stays fixed. Groups and model frames keep proportions.
export function resizeSelection(elements,handle,dx,dy,keepRatio=false){
 const b=selectionBounds(elements);if(!b)return [];
 let sx=handle.includes('e')?1+dx/b.w:handle.includes('w')?1-dx/b.w:1;
 let sy=handle.includes('n')?1+dy/b.h:handle.includes('s')?1-dy/b.h:1;
 const minX=Math.max(...elements.map(e=>.005/e.w)),minY=Math.max(...elements.map(e=>.005/e.h));
 const maxX=Math.min(...elements.map(e=>4/e.w)),maxY=Math.min(...elements.map(e=>4/e.h));
 const uniform=keepRatio||elements.length>1||elements.some(e=>e.type==='panel');
 if(uniform){
  const factor=handle==='n'||handle==='s'?sy:handle==='e'||handle==='w'?sx:Math.abs(sx-1)>=Math.abs(sy-1)?sx:sy;
  const texts=elements.length>1?elements.filter(e=>e.type==='text'&&Number.isFinite(e.font)):[];
  const minFont=Math.max(0,...texts.map(e=>1/e.font)),maxFont=Math.min(Infinity,...texts.map(e=>40/e.font));
  sx=sy=Math.max(minX,minY,minFont,Math.min(maxX,maxY,maxFont,factor));
 }else{sx=Math.max(minX,Math.min(maxX,sx));sy=Math.max(minY,Math.min(maxY,sy));}
 const newW=b.w*sx,newH=b.h*sy;
 const x=handle.includes('w')?b.x+b.w-newW:handle.includes('e')?b.x:b.x+(b.w-newW)/2;
 const y=handle.includes('n')?b.y-b.h+newH:handle.includes('s')?b.y:b.y+(newH-b.h)/2;
 const transformed=elements.map(e=>({...e,x:round(x+(e.x-b.x)*sx),y:round(y+(e.y-b.y)*sy),w:round(e.w*sx),h:round(e.h*sy),...(elements.length>1&&e.type==='text'&&Number.isFinite(e.font)?{font:round(e.font*sx)}:{})}));
 // Reject the gesture outside the import/export contract instead of distorting it.
 return transformed.some(e=>Math.abs(e.x)>4||Math.abs(e.y)>4)?elements.map(e=>({...e})):transformed;
}

export function displayGeometry(e,viewport,units='px'){
 if(units==='ui')return {x:e.x,y:e.y,w:e.w,h:e.h};
 const values=previewGeometry(e,viewport,{textBaseline:false});
 return Object.fromEntries(Object.entries(values).map(([k,n])=>[k,Math.round(n*100)/100]));
}
export function geometryValue(key,value,viewport,units='px'){
 if(units==='ui')return value;
 return round(previewValue(key,value,viewport));
}
