import fs from 'node:fs';import assert from 'node:assert/strict';import {JsonLineMcp} from './mcp-json-client.mjs';
const env={...process.env,CODEGRAPH_TELEMETRY:'0',CODEGRAPH_NO_UPDATE_CHECK:'1',CODEGRAPH_NO_DAEMON:'1'};delete env.CODEGRAPH_NO_WATCH;
const client=new JsonLineMcp({command:'/home/snz/.local/bin/codegraph',args:['serve','--mcp'],cwd:process.cwd(),env});await client.connect();let stderr='';client.stderr.on('data',d=>stderr+=d);const results=[];
try{assert.equal(client.getServerVersion().version,'1.6.2+jass-vjass.4');for(const [i,args]of JSON.parse(fs.readFileSync('production-probe-queries.json','utf8')).entries()){
 const r=await client.callTool({name:'codegraph_explore',arguments:args});assert.ok(!r.isError);const t=r.content.filter(c=>c.type==='text').map(c=>c.text).join('\n');assert.ok(t.includes('Source Code'));if(i<2)assert.ok(t.includes('compiler-profile static analysis'));assert.ok(!/DISABLED|RECOVERING/.test(t));fs.writeFileSync(`production-mcp-${i}.json`,JSON.stringify(r,null,2));results.push({args,server:client.getServerVersion(),source_returned:true,chars:t.length});}
 fs.writeFileSync('production-mcp-results.json',JSON.stringify(results,null,2));console.log(JSON.stringify(results));
}finally{await client.close();fs.writeFileSync('production-mcp-stderr.log',stderr)}
