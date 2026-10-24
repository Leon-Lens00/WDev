import fs from 'node:fs';import path from 'node:path';import assert from 'node:assert/strict';import {createRequire} from 'node:module';import crypto from 'node:crypto';import {spawn} from 'node:child_process';import {createInterface} from 'node:readline';
const require=createRequire(path.resolve('checkout/package.json'));
const {CodeGraph}=require(path.resolve('checkout/dist/index.js'));
class JsonLineMcp {
 constructor(options){ this.options=options;this.pending=new Map();this.id=0; }
 async connect(){
  this.child=spawn(this.options.command,this.options.args,{cwd:this.options.cwd,env:this.options.env,stdio:['pipe','pipe','pipe']});this.stderr=this.child.stderr;
  this.reader=createInterface({input:this.child.stdout});this.reader.on('line',line=>{let m;try{m=JSON.parse(line)}catch{return};if(m.method&&m.id!==undefined){this.send({jsonrpc:'2.0',id:m.id,result:m.method==='roots/list'?{roots:[]}:{}});return;}const p=this.pending.get(m.id);if(p){clearTimeout(p.timer);this.pending.delete(m.id);m.error?p.reject(new Error(JSON.stringify(m.error))):p.resolve(m.result)}});
  this.child.on('exit',code=>{for(const p of this.pending.values()){clearTimeout(p.timer);p.reject(new Error('MCP exited '+code));}this.pending.clear()});
  const init=await this.request('initialize',{protocolVersion:'2024-11-05',capabilities:{},clientInfo:{name:'vjass-conformance-probe',version:'1.0.0'}});this.version=init.serverInfo;this.send({jsonrpc:'2.0',method:'notifications/initialized'});
 }
 send(value){this.child.stdin.write(JSON.stringify(value)+'\n');}
 request(method,params){const id=++this.id;return new Promise((resolve,reject)=>{const timer=setTimeout(()=>{this.pending.delete(id);reject(new Error('MCP request timed out: '+method));},60000);this.pending.set(id,{resolve,reject,timer});this.send({jsonrpc:'2.0',id,method,params})});}
 callTool(params){return this.request('tools/call',params)}
 getServerVersion(){return this.version}
 async close(){this.child.stdin.end();await new Promise(resolve=>{if(this.child.exitCode!==null)return resolve();const timer=setTimeout(()=>{this.child.kill('SIGTERM');resolve()},2000);this.child.once('exit',()=>{clearTimeout(timer);resolve()})});this.reader.close();}
}
const roots=[
 {name:'small-noise',flows:[['Noise.Noise.octavePerlin2D','Noise.Noise.perlin2D','Noise.Noise.floor'],['Noise.Noise.perlin3D','Noise.Noise.grad3D','Noise.Noise.realTernaryOp'],['Noise.Noise.openSimplex2D','Noise.Noise.extrapolate2D']]},
 {name:'medium-jassjass',flows:[['Jass.assert','Jass.error','Jass.print'],['Jass.Lexer.parseIdent','Jass.isDelim'],['Jass.trace','Jass.print']]},
 {name:'large-nestharus',flows:[['TimerTools.Timer.create','TimerTools.TimerList.add','TimerTools.CreationQueue.add'],['TimerTools.Timer.destroy','TimerTools.TimerPool.recycleTimer'],['TimerTools.Timer.destroy','TimerTools.DestructionQueue.add']]},
];
fs.writeFileSync('corpus-flow-goldens.json',JSON.stringify(roots,null,2));

const env=Object.fromEntries(Object.entries(process.env).filter(([,v])=>v!==undefined));Object.assign(env,{CODEGRAPH_TELEMETRY:'0',CODEGRAPH_NO_UPDATE_CHECK:'1',CODEGRAPH_NO_WATCH:'1',CODEGRAPH_DAEMON_IDLE_TIMEOUT_MS:'5000'});
const client=new JsonLineMcp({command:'/home/snz/.local/share/codegraph-vjass/runtime/node',args:['--liftoff-only','--disable-warning=ExperimentalWarning',path.resolve('checkout/dist/bin/codegraph.js'),'serve','--mcp'],cwd:path.resolve('checkout'),env,stderr:'pipe'});
let stderr='';await client.connect();client.stderr?.on('data',d=>{stderr+=d});const reports=[];
try{
 for(const item of roots){
  const root=path.resolve('corpus-runs',item.name);const cg=await CodeGraph.open(root);await cg.sync();const nodes=cg.getFiles().flatMap(f=>cg.getNodesInFile(f.path));const hashes=()=>Object.fromEntries(cg.getFiles().map(f=>[f.path,crypto.createHash('sha256').update(fs.readFileSync(path.join(root,f.path))).digest('hex')]));const before=hashes();
  const at=name=>{const n=cg.getNodesByQualifiedName(name);assert.equal(n.length,1,'missing/ambiguous '+name);return n[0]};
  const flows=[];
  for(const [i,names] of item.flows.entries()){
   const paths=[];for(let j=1;j<names.length;j++){const route=cg.findPath(at(names[j-1]).id,at(names[j]).id,['calls']);assert.ok(route,`${names[j-1]} must call ${names[j]}`);paths.push(route)}
   const t=performance.now();const result=await client.callTool({name:'codegraph_explore',arguments:{projectPath:root,query:names.join(' '),maxFiles:3}});const ms=performance.now()-t;assert.ok(!result.isError,JSON.stringify(result));const text=result.content.filter(c=>c.type==='text').map(c=>c.text).join('\n');assert.ok(text.includes('Source Code'),'source must be included');const flow=text.slice(0,text.indexOf('**Exploration:'));for(const name of names)assert.ok(flow.includes(at(name).name),`named ${name} missing from flow`);
   const output=`corpus-mcp-${item.name}-${i+1}.json`;fs.writeFileSync(output,JSON.stringify(result,null,2));flows.push({names,paths,ms,chars:text.length,output});console.log(item.name,i+1,Math.round(ms)+'ms',text.length+'chars');
  }
  assert.deepEqual(hashes(),before);reports.push({name:item.name,root,source_hashes_unchanged:true,server:client.getServerVersion(),flows});fs.writeFileSync('corpus-mcp-results.json',JSON.stringify(reports,null,2));cg.destroy();
 }
}finally{await client.close();fs.writeFileSync('corpus-mcp-stderr.log',stderr)}
