import {createRequire} from 'node:module';import fs from 'node:fs';import path from 'node:path';import {DatabaseSync} from 'node:sqlite';import assert from 'node:assert/strict';import {JsonLineMcp} from './mcp-json-client.mjs';
const B=path.dirname(new URL(import.meta.url).pathname),root=path.join(B,'watch-root');
fs.mkdirSync(root,{recursive:true});const target=path.join(root,'case.j');const positive=fs.readFileSync(path.join(B,'thistype.j'),'utf8');fs.writeFileSync(target,positive);
const {CodeGraph}=createRequire(import.meta.url)('/home/snz/Documentos/MCP W3/codegraph-vjass/dist');const graph=await CodeGraph.init(root);await graph.indexAll();graph.destroy();
const env={...process.env,CODEGRAPH_TELEMETRY:'0',CODEGRAPH_NO_UPDATE_CHECK:'1',CODEGRAPH_NO_DAEMON:'1'};delete env.CODEGRAPH_NO_WATCH;
const client=new JsonLineMcp({command:'/home/snz/.local/bin/codegraph',args:['serve','--mcp'],cwd:B,env});let stderr='';const results=[];
const edgeExists=()=>{const db=new DatabaseSync(path.join(root,'.codegraph/codegraph.db'),{readOnly:true});try{return !!db.prepare("SELECT 1 FROM edges e JOIN nodes s ON e.source=s.id JOIN nodes t ON e.target=t.id WHERE s.qualified_name='Pair.spell' AND t.qualified_name='Pair.cast' AND e.kind='calls'").get();}finally{db.close()}};
try{
 await client.connect();client.stderr.on('data',d=>stderr+=d);assert.equal(client.getServerVersion().version,'1.6.2+jass-vjass.5');
 const r=await client.callTool({name:'codegraph_explore',arguments:{projectPath:root,query:'Pair.spell Pair.cast',maxFiles:1}});assert.ok(!r.isError);assert.ok(edgeExists());
 for(const [label,text,expected]of [['remove-invalid-receiver',positive.replace('local thistype this = 1','local unit this = null'),false],['restore-integer-receiver',positive.replace('local thistype this = 1','local integer this = 1'),true]]){
  fs.writeFileSync(target,text);const start=Date.now();let observed=false;
  while(Date.now()-start<20000){await new Promise(r=>setTimeout(r,200));if(edgeExists()===expected){observed=true;break;}}
  assert.ok(observed,'Watcher did not converge '+label);results.push({label,edge_present:expected,observed_before_any_followup_mcp_or_sync:true,elapsed_ms:Date.now()-start});
 }
 fs.writeFileSync(path.join(B,'watch-this-results.json'),JSON.stringify({passed:true,server:client.getServerVersion(),results},null,2)+'\n');console.log(JSON.stringify(results));
}finally{await client.close();fs.writeFileSync(path.join(B,'watch-this-stderr.log'),stderr)}
