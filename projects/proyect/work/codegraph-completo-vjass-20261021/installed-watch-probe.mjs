import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createRequire} from 'node:module';import {DatabaseSync} from 'node:sqlite';import {JsonLineMcp} from './mcp-json-client.mjs';
const require=createRequire(import.meta.url),{CodeGraph}=require('/home/snz/Documentos/MCP W3/codegraph-vjass/dist');
const base=path.resolve('installed-watch-probe');assert.ok(!fs.existsSync(base));fs.mkdirSync(base);
const roots=['module','slk','javascript'].map(n=>path.join(base,n));for(const r of roots)fs.mkdirSync(r);
const write=(r,f,s)=>fs.writeFileSync(path.join(r,f),s);
const moduleBody=name=>`module M\nstatic method tick takes nothing returns nothing\ncall ${name}()\nendmethod\nendmodule\n`;
write(roots[0],'defs.j',moduleBody('Ping'));write(roots[0],'main.j','function Ping takes nothing returns nothing\nendfunction\nfunction Pong takes nothing returns nothing\nendfunction\nstruct One extends array\nimplement M\nendstruct\n');
write(roots[1],'main.j',fs.readFileSync('checkout/__tests__/fixtures/jass-conformance/slk.j','utf8')+'\nstatic if DEBUG_MODE then\nfunction DebugBranch takes nothing returns nothing\nendfunction\nelse\nfunction ReleaseBranch takes nothing returns nothing\nendfunction\nendif\n');write(roots[1],'data.slk',fs.readFileSync('checkout/__tests__/fixtures/jass-conformance/data.slk','utf8'));const profile=mode=>JSON.stringify({jass:{mode,dataFiles:['data.slk']}});write(roots[1],'codegraph.json',profile('release'));
write(roots[2],'main.js','export function Ping(){}\nexport function Run(){ Ping(); }\n');
for(const r of roots){const c=await CodeGraph.init(r);await c.indexAll();c.destroy();}
const env={...process.env,CODEGRAPH_NO_DAEMON:'1',CODEGRAPH_NO_UPDATE_CHECK:'1',CODEGRAPH_TELEMETRY:'0'};delete env.CODEGRAPH_NO_WATCH;
const client=new JsonLineMcp({command:'/home/snz/.local/bin/codegraph',args:['serve','--mcp'],cwd:base,env});await client.connect();let stderr='';client.stderr.on('data',d=>stderr+=d);
const query=async(r,q)=>{const x=await client.callTool({name:'codegraph_explore',arguments:{projectPath:r,query:q,maxFiles:3}});assert.ok(!x.isError);return x};
const read=(r,sql)=>{const d=new DatabaseSync(path.join(r,'.codegraph/codegraph.db'),{readOnly:true});try{return d.prepare(sql).all()}finally{d.close()}};
const checks=[];async function awaitDb(r,name,predicate){const at=performance.now();let last;while(performance.now()-at<15000){try{last=predicate();if(last){checks.push({name,ms:performance.now()-at,passed:true,observation:'read-only SQLite polling; no MCP query/sync between write and observation'});return}}catch{}await new Promise(resolve=>setTimeout(resolve,100));}throw new Error('Watcher failed '+name+' last='+JSON.stringify(last));}
const nodeExists=(r,name)=>read(r,`SELECT id FROM nodes WHERE qualified_name='${name}'`).length>0;
try{
 assert.equal(client.getServerVersion().version,'1.6.2+jass-vjass.4');for(const [i,r]of roots.entries())await query(r,['One.tick Ping','Data Compute','Run Ping'][i]);
 write(roots[0],'extra.j','function Added takes nothing returns nothing\nendfunction\n');await awaitDb(roots[0],'JASS add',()=>nodeExists(roots[0],'Added'));
 write(roots[0],'defs.j',moduleBody('Pong'));await awaitDb(roots[0],'unchanged module consumer refresh',()=>read(roots[0],"SELECT t.qualified_name FROM edges e JOIN nodes s ON s.id=e.source JOIN nodes t ON t.id=e.target WHERE s.qualified_name='One.tick' AND e.kind='calls'").some(x=>x.qualified_name==='Pong'));
 fs.unlinkSync(path.join(roots[0],'extra.j'));await awaitDb(roots[0],'JASS delete',()=>!nodeExists(roots[0],'Added'));
 write(roots[1],'data.slk',fs.readFileSync(path.join(roots[1],'data.slk'),'utf8').replace('K"Compute()"','K"OtherCompute()"'));await awaitDb(roots[1],'SLK data-only invalidation',()=>read(roots[1],"SELECT t.name FROM edges e JOIN nodes t ON t.id=e.target WHERE json_extract(e.metadata,'$.resolutionScope')='slk-cell-expression'").some(x=>x.name==='OtherCompute'));
 write(roots[1],'codegraph.json',profile('debug'));await awaitDb(roots[1],'profile-only invalidation',()=>nodeExists(roots[1],'DebugBranch')&&!nodeExists(roots[1],'ReleaseBranch'));
 write(roots[2],'extra.js','export function AddedJS(){}\n');await awaitDb(roots[2],'JS add',()=>read(roots[2],"SELECT id FROM nodes WHERE name='AddedJS'").length>0);
 write(roots[2],'main.js','export function Pong(){}\nexport function Run(){ Pong(); }\n');await awaitDb(roots[2],'JS edit',()=>read(roots[2],"SELECT t.name FROM edges e JOIN nodes s ON s.id=e.source JOIN nodes t ON t.id=e.target WHERE s.name='Run' AND e.kind='calls'").some(x=>x.name==='Pong'));
 fs.unlinkSync(path.join(roots[2],'extra.js'));await awaitDb(roots[2],'JS delete',()=>read(roots[2],"SELECT id FROM nodes WHERE name='AddedJS'").length===0);
 for(const [i,r]of roots.entries())await query(r,['One.tick Pong','Data OtherCompute DebugBranch','Run Pong'][i]);
 fs.writeFileSync('installed-watch-results.json',JSON.stringify({server:client.getServerVersion(),checks,all_passed:true,roots,production_sources_modified:false},null,2));console.log(JSON.stringify(checks));
}finally{await client.close();fs.writeFileSync('installed-watch-stderr.log',stderr)}
