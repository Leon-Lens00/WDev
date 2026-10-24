import fs from 'node:fs';import path from 'node:path';import {createRequire} from 'node:module';import assert from 'node:assert/strict';import {execFileSync} from 'node:child_process';
const require=createRequire(import.meta.url);const engines=[require('/home/snz/Documentos/MCP W3/codegraph-vjass/dist/index.js').CodeGraph,require('./checkout/dist/index.js').CodeGraph];
const base=path.resolve('corpus-control-express'), snapshots=[];
for(let i=0;i<2;i++){
 const root=path.resolve('control-runs-final',i?'candidate':'active-baseline');fs.mkdirSync(path.dirname(root),{recursive:true});
 assert.ok(!fs.existsSync(root),'fresh control root required');fs.cpSync(base,root,{recursive:true,filter:p=>!['.git','.codegraph','node_modules'].includes(path.basename(p))});
 const cg=await engines[i].init(root);await cg.indexAll();const files=cg.getFiles();const nodes=files.flatMap(f=>cg.getNodesInFile(f.path));const keys=new Map(nodes.map(n=>[n.id,`${n.filePath}:${n.startLine}:${n.kind}:${n.qualifiedName}`]));
 const canonicalNodes=nodes.map(({id,updatedAt,...n})=>JSON.parse(JSON.stringify(n))).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b)));
 const edges=nodes.flatMap(n=>cg.getOutgoingEdges(n.id)).map(e=>({...e,id:undefined,source:keys.get(e.source),target:keys.get(e.target)})).sort((a,b)=>JSON.stringify(a).localeCompare(JSON.stringify(b)));
 snapshots.push({nodes:canonicalNodes,edges,files:files.map(f=>({path:f.path,language:f.language,errors:f.errors})).sort((a,b)=>a.path.localeCompare(b.path))});cg.destroy();console.log(i,files.length,nodes.length,edges.length);
}
fs.writeFileSync('control-modern-snapshots.json',JSON.stringify(snapshots));assert.deepEqual(snapshots[1],snapshots[0]);fs.writeFileSync('control-modern-results.json',JSON.stringify({repository:'https://github.com/expressjs/express',revision:execFileSync('git',['rev-parse','HEAD'],{cwd:base,encoding:'utf8'}).trim(),equivalent:true,files:snapshots[0].files.length,nodes:snapshots[0].nodes.length,edges:snapshots[0].edges.length,comparison:'fresh independent roots; source locations/signatures/semantic metadata and canonicalized edges match exactly'},null,2));
