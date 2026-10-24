import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import assert from 'node:assert/strict';import {createRequire} from 'node:module';import {DatabaseSync} from 'node:sqlite';
const require=createRequire(import.meta.url),{CodeGraph}=require('/home/snz/Documentos/MCP W3/codegraph-vjass/dist');
const roots=['/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src','/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration','/home/snz/Documentos/WarDatsPy/ui-studio/dist'];
const result=[],queries=[];
for(const [i,root]of roots.entries()){
 const db=new DatabaseSync(path.join(root,'.codegraph/codegraph.db'),{readOnly:true});const oldFiles=db.prepare('SELECT path FROM files').all().map(r=>r.path);db.close();
 const hash=file=>{try{return crypto.createHash('sha256').update(fs.readFileSync(path.join(root,file))).digest('hex')}catch{return null}};const before=Object.fromEntries(oldFiles.map(f=>[f,hash(f)]));
 const c=await CodeGraph.recreate(root);const stats=await c.indexAll();const files=c.getFiles(),nodes=files.flatMap(f=>c.getNodesInFile(f.path));
 const changed=Object.keys(before).filter(f=>before[f]!==hash(f));assert.deepEqual(changed,[],'Indexed source changed while rebuilding; investigate concurrent edits, do not overwrite them');
 const errors=files.flatMap(f=>(f.errors??[]).map(e=>({file:f.path,...e})));const mainNames=i===0?'RapidFire.RapidBolt':i===1?nodes.find(n=>['namespace','struct'].includes(n.kind)&&/Inventory/i.test(n.name))?.qualifiedName: nodes.find(n=>n.kind==='function'&&n.name.length>4)?.qualifiedName;
 assert.ok(mainNames,'Need concrete probe symbol');queries.push({projectPath:root,query:mainNames,maxFiles:2});
 result.push({root,files:files.length,nodes:nodes.length,stats,errors,source_hashes_unchanged:true,source_sha256:before});fs.writeFileSync('production-rebuild-results.json',JSON.stringify(result,null,2));fs.writeFileSync('production-probe-queries.json',JSON.stringify(queries,null,2));console.log(root,files.length,nodes.length,'errors',errors.filter(e=>e.severity==='error').length,'warnings',errors.filter(e=>e.severity!=='error').length);c.destroy();
}
