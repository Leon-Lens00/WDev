// Real MCP acceptance check. Never edits/saves the map or changes its selection/camera.
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { mkdir, writeFile, readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { resolve, join } from 'node:path';
import assert from 'node:assert/strict';

const [exe,pid,output]=process.argv.slice(2);
if(!output) throw new Error('Usage: node model-preview-smoke.mjs editor.exe GUI-PID output-directory');
await mkdir(output,{recursive:true});
const client=new Client({name:'model-preview-acceptance',version:'1'});
const transport=new StdioClientTransport({command:resolve(exe),args:['--mcp'],stderr:'pipe'});
const data=r=>JSON.parse(r.content.find(c=>c.type==='text').text);
async function call(name,args={}) {
  const r=await client.callTool({name,arguments:args});
  if(r.isError) throw new Error(name+': '+JSON.stringify(r.content));
  return r;
}
const checks=[],failures=[];
let before, camera, selection, history, hash;
const sha=async path=>createHash('sha256').update(await readFile(path)).digest('hex');
try {
  await client.connect(transport);
  const names=(await client.listTools()).tools.map(t=>t.name);
  for(const suffix of ['open','get_state','set_camera','set_animation','screenshot','close']) assert.ok(names.includes('model_preview_'+suffix));
  await call('session_select',{pid:Number(pid)});
  before=data(await call('map_status')); assert.equal(before.loaded,true);
  hash=await sha(before.path);
  camera=data(await call('camera_get_state')).state;
  selection=data(await call('selection_get'));history=data(await call('history_list'));
  const all=data(await call('doodads_list')).doodads;
  const candidates=[...new Map(all.map(d=>[d.type_id,d])).values()];
  await writeFile(join(output,'candidates.json'),JSON.stringify(candidates,null,2));
  // A mix of actual placed models; missing dependencies must remain explicit.
  for(const d of candidates.slice(0,16)) {
    let opened;
    try {opened=data(await call('model_preview_open',{kind:'doodad',id:d.creation_number,width:768,height:768}));}
    catch(e) {failures.push({id:d.creation_number,type:d.type_id,error:String(e)});continue;}
    assert.equal(opened.opened,true); assert.equal(opened.source.id,d.creation_number);
    assert.equal(opened.source.transform,'placed');
    await call('model_preview_set_animation',{paused:true});
    const base='model-'+d.creation_number;
    for(const view of ['isometric','top','south']) {
      const posed=data(await call('model_preview_set_camera',{view,projection:view==='top'?'orthographic':'perspective'}));
      const capture=await call('model_preview_screenshot');
      const image=capture.content.find(c=>c.type==='image');
      assert.equal(image?.mimeType,'image/png');
      const bytes=Buffer.from(image.data,'base64'),meta=data(capture);
      assert.equal(bytes.subarray(1,4).toString(),'PNG');
      assert.equal(meta.width,768);assert.equal(meta.height,768);
      assert.deepEqual(meta.camera,posed.camera);
      assert.ok(meta.frame>posed.frame);
      if(view==='top') assert.equal(meta.camera.pitch,Math.PI/2);
      await writeFile(join(output,base+'-'+view+'.png'),bytes);
      await writeFile(join(output,base+'-'+view+'.json'),JSON.stringify(meta,null,2));
      checks.push({id:d.creation_number,type:d.type_id,view,path:meta.resolved_model_path,bytes:bytes.length,errors:meta.diagnostics.resource_errors});
    }
    const state=data(await call('model_preview_get_state'));
    const bad=await client.callTool({name:'model_preview_set_camera',arguments:{distance:-1}});
    assert.equal(bad.isError,true);
    assert.deepEqual(data(await call('model_preview_get_state')).camera,state.camera);
    if(state.sequences.length) {
      const s=state.sequences[0],time=Math.min(50,(s.interval[1]-s.interval[0])/2);
      const animated=data(await call('model_preview_set_animation',{sequence:0,time_ms:time,paused:true,loop:false}));
      assert.equal(animated.animation.sequence,0);
      assert.ok(Math.abs(animated.animation.time_ms-time)<.01);
      const capture=await call('model_preview_screenshot',{width:640,height:480});
      await writeFile(join(output,base+'-animation.png'),Buffer.from(capture.content.find(c=>c.type==='image').data,'base64'));
      const resumed=data(await call('model_preview_set_animation',{paused:false}));
      assert.equal(resumed.animation.paused,false);
      await call('model_preview_set_animation',{paused:true});
    }
    const normalized=data(await call('model_preview_open',{kind:'doodad',id:d.creation_number,transform:'normalized'}));
    assert.deepEqual(normalized.source.scale,[1,1,1]);assert.deepEqual(normalized.source.rotation,[0,0,0,1]);
    console.log(JSON.stringify({id:d.creation_number,type:d.type_id,path:opened.resolved_model_path,sequences:opened.sequences.length}));
    if(checks.length>=9) break;
  }
  assert.ok(checks.length>=6,'Need at least two models successfully rendered');
  // The direct path route must resolve a model already proven to exist in this map.
  const direct=data(await call('model_preview_open',{model_path:checks[0].path}));
  assert.equal(direct.source.kind,'asset');
  const badSequence=await client.callTool({name:'model_preview_set_animation',arguments:{sequence:99999}});
  assert.equal(badSequence.isError,true);
  const missing=await client.callTool({name:'model_preview_open',arguments:{model_path:'NoSuchFolder/no-such-model.mdx'}});
  assert.equal(missing.isError,true);
  assert.equal(data(await call('model_preview_get_state')).opened,false);
  await call('model_preview_close');
  const closed=await client.callTool({name:'model_preview_screenshot',arguments:{}});
  assert.equal(closed.isError,true);
  assert.deepEqual(data(await call('camera_get_state')).state,camera);
  assert.deepEqual(data(await call('selection_get')),selection);
  assert.deepEqual(data(await call('history_list')),history);
  assert.deepEqual(data(await call('map_status')).evidence,before.evidence);
  assert.equal(await sha(before.path),hash);
  await writeFile(join(output,'report.json'),JSON.stringify({passed:true,checks,failed_candidates:failures,
    preserved:['map archive SHA256','map evidence/revision/dirty','map camera','selection','undo history'],
    map:before.path,sha256:hash,visually_reviewed:false},null,2));
  console.log('PASS: model previews and capture; map/camera/selection/history unchanged');
} finally {
  try {await call('model_preview_close');} catch {}
  await client.close();
}

