import {spawn} from 'node:child_process';import {createInterface} from 'node:readline';
export class JsonLineMcp {
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
