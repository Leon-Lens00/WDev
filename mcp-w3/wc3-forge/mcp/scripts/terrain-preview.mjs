// Capture the exported scene, then restore the viewport pose. No map writes.
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { readFile, mkdir, writeFile } from 'node:fs/promises';
import { resolve, join } from 'node:path';
const [exe,pid,mapPath,specPath,output,viewsPath] = process.argv.slice(2);
if(!output) throw Error('terrain-preview.mjs editor.exe PID map.w3x spec.json output');
const spec=JSON.parse(await readFile(specPath,'utf8'));
const out=resolve(output);await mkdir(out,{recursive:true});
const client=new Client({name:'terrain-preview',version:'1'});
const transport=new StdioClientTransport({command:resolve(exe),args:['--mcp'],stderr:'pipe'});
const text = r => JSON.parse(r.content.find(c=>c.type==='text').text);
async function call(name,args={}){const r=await client.callTool({name,arguments:args});if(r.isError)throw Error(name+': '+JSON.stringify(r.content));return r;}
let before;
try{
 await client.connect(transport);await call('session_select',{pid:Number(pid)});
 const oldGeneration=text(await call('diagnostics_get')).diagnostics.scene.loadGeneration;
 await call('map_open',{path:resolve(mapPath)});
 let loaded=false;
 for(let attempt=0;attempt<100;attempt++){
  const d=text(await call('diagnostics_get')).diagnostics;
  if(d.scene.loadGeneration>oldGeneration&&!d.scene.loadingMap){loaded=true;break;}
  await new Promise(r=>setTimeout(r,200));
 }
 if(!loaded)throw Error('Frontend did not acknowledge the newly opened map');
 before=text(await call('camera_get_state')).state;
 const c=spec.waterfall,box={min:[...spec.edit.min,-200],max:[...spec.edit.max,800]};
 const views=viewsPath?JSON.parse(await readFile(viewsPath,'utf8')):[
  {name:'top',bounds:box,view:'top',projection:'orthographic'},
  {name:'perspective',bounds:box,view:'isometric',projection:'perspective'},
  {name:'opposite',bounds:box,projection:'perspective',yaw:3.9,pitch:0.75},
  {name:'waterfall',bounds:{min:[c.source.min[0]+c.offset[0]-100,c.source.min[1]+c.offset[1]-100,-180],max:[c.source.max[0]+c.offset[0]+100,c.source.max[1]+c.offset[1]+100,650]},projection:'perspective',yaw:0.7,pitch:0.8},
  {name:'waterfall-side',bounds:{min:[c.source.min[0]+c.offset[0],c.source.min[1]+c.offset[1],-180],max:[c.source.max[0]+c.offset[0],c.source.max[1]+c.offset[1],650]},projection:'orthographic',yaw:1.5708,pitch:0.3},
  {name:'forest-path',bounds:{min:[300,1500,0],max:[2800,3500,800]},projection:'perspective',yaw:0.4,pitch:1.0},
 ];
 for(const v of views){
  if(process.env.TERRAIN_VIEWS && !process.env.TERRAIN_VIEWS.split(',').includes(v.name))continue;
  if(v.yaw!==undefined)await call('camera_set_state',{yaw:v.yaw,pitch:v.pitch});
  await call('camera_frame',{bounds:v.bounds,view:v.view,projection:v.projection,padding:1.08});
  // Orthographic scale is independent of eye distance. Keep foreground behind the near plane.
  if(v.projection==='orthographic'){
   const pose=text(await call('camera_get_state')).state;
   await call('camera_set_state',{distance:pose.distance*3});
  }
  const r=await call('viewport_screenshot',{max_width:1600});const meta=text(r);const image=r.content.find(c=>c.type==='image');
  if(!image || meta.map.path.toLowerCase()!==resolve(mapPath).toLowerCase())throw Error('Wrong map or missing PNG');
  await writeFile(join(out,v.name+'.png'),Buffer.from(image.data,'base64'));await writeFile(join(out,v.name+'.json'),JSON.stringify(meta,null,2));
  console.log(JSON.stringify({view:v.name,frame:meta.frame,diagnostics:meta.diagnostics}));
 }
}finally{try{if(before)await call('camera_set_state',before);}finally{await client.close();}}
