// Empirical view from TerrainDev / Classic 1.27b / RenderEdge, 1920x1080.
// Coordinates remain UserInterface coordinates; this is a preview transform only.
export function projectionRect(view){
 if(view.projection!=='classic-127b')return {x:0,y:0,w:view.width,h:view.height};
 const w=Math.min(view.width,view.height*4/3);
 return {x:(view.width-w)/2,y:view.height*.04,w,h:view.height*.72};
}
export function previewGeometry(e,view,{textBaseline=true}={}){
 const r=projectionRect(view);
 const textOffset=textBaseline&&e.type==='text'?(e.font*.0023+.0065)*view.height:0;
 return {x:r.x+(e.x+1)*r.w/2,y:r.y+(1-e.y)*r.h/2-textOffset,w:e.w*r.w/2,h:e.h*r.h/2};
}
export function previewValue(key,value,view){
 const r=projectionRect(view);
 return key==='x'?(value-r.x)*2/r.w-1:key==='y'?1-(value-r.y)*2/r.h:value*2/(key==='w'?r.w:r.h);
}
export function previewDelta(dx,dy,view){const r=projectionRect(view);return {x:dx*2/r.w,y:-dy*2/r.h};}

// Match the original callbacks: tooltips follow the selected slot at runtime.
export function tooltipPreview(elements,selectedId){
 const slot=elements.find(e=>e.id===selectedId);
 const background=elements.find(e=>e.id==='tooltip.background');
 if(!slot||!background||!/^inventory\.slot\.|^equipment\.slot\./.test(slot.id))return elements;
 const tx=slot.x-.4,ty=slot.group==='equipment'?slot.y-slot.h-.08:slot.y+.4;
 // Reconstruct the original createEx anchor from its visible model bounds.
 const scale=background.w*.544*(100.2+background.z)/338.6934;
 const oldX=background.x+background.w/2-120*scale/(2*.544*(100.2+background.z));
 const oldY=background.y-background.h/2+60*scale/(2*.302*(100.2+background.z));
 return elements.map(e=>e.group==='tooltip'?{...e,x:e.x+tx-oldX,y:e.y+ty-oldY}:e);
}
