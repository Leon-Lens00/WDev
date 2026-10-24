import {Client} from '/home/snz/Documentos/MCP W3/wc3-forge/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js';
import {StdioClientTransport} from '/home/snz/Documentos/MCP W3/wc3-forge/mcp/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js';
import {DatabaseSync} from 'node:sqlite';
import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
const base = path.dirname(new URL(import.meta.url).pathname);
const transport = new StdioClientTransport({command:'/home/snz/.local/bin/codegraph', args:['serve','--mcp'], cwd:'/home/snz/Documentos/ChatGPT/Proyect', stderr:'pipe'});
const client = new Client({name:'vjass-revision2-verification', version:'1.0.0'});
let stderr=''; transport.stderr.on('data', chunk => {stderr += chunk.toString();});
const report={roots:[]};
const sleep=ms=>new Promise(resolve=>setTimeout(resolve,ms));
async function observe(root,file,expected) {
  const started=performance.now();
  while(performance.now()-started<15000) {
    const db=new DatabaseSync(path.join(root,'.codegraph/codegraph.db'),{readOnly:true});
    let names;
    try {names=db.prepare("select name from nodes where file_path=? and kind='function'").all(file).map(n=>n.name);} finally {db.close();}
    if(JSON.stringify(names)===JSON.stringify(expected)) return {passed:true,ms:Math.round(performance.now()-started)};
    await sleep(200);
  }
  throw new Error(`Auto-sync failed: ${root} ${expected}`);
}
try {
  await client.connect(transport);
  report.server=client.getServerVersion();
  assert.equal(report.server.version,'1.6.2+jass-vjass.2');
  assert.deepEqual((await client.listTools()).tools.map(t=>t.name),['codegraph_explore']);
  for (const [label,query,extension] of [['missiles','RapidFire.RapidPair.emit RapidFire.RapidPair.face','.j'],['inventory','TerrainInventory Inventory','.j'],['ui-studio','screenToUI uiToScreen','.js']]) {
    const root=path.join(base,'real-'+label);
    const response=await client.callTool({name:'codegraph_explore',arguments:{query,projectPath:root,maxFiles:2}});
    assert.ok(!response.isError);
    const text=response.content.map(c=>c.text??'').join('\n');
    assert.ok(text.includes('Source Code'));
    if(extension==='.j')assert.ok(text.includes('JASS/vJASS local support'));
    fs.writeFileSync(path.join(base,label+'-mcp.json'),JSON.stringify(response,null,2));
    const file='revision2_live_probe'+extension, fixture=path.join(root,file);
    assert.ok(!fs.existsSync(fixture));
    const body=name=>extension==='.js'?`export function ${name}(){ return 1; }\n`:`function ${name} takes nothing returns nothing\nendfunction\n`;
    const transitions={};
    try {
      fs.writeFileSync(fixture,body('RevisionTwoA'),{flag:'wx'});
      transitions.create=await observe(root,file,['RevisionTwoA']);
      fs.writeFileSync(fixture,body('RevisionTwoB'));
      transitions.modify=await observe(root,file,['RevisionTwoB']);
    } finally {fs.rmSync(fixture,{force:true});}
    transitions.delete=await observe(root,file,[]);
    report.roots.push({root,query,transitions});
  }
  report.passed=true;
} finally {
  await client.close();
  fs.writeFileSync(path.join(base,'mcp-verification.json'),JSON.stringify(report,null,2));
  fs.writeFileSync(path.join(base,'mcp-stderr.log'),stderr);
}
console.log(JSON.stringify(report));
