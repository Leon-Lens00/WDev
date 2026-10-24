import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';
import { performance } from 'node:perf_hooks';
const require = createRequire(import.meta.url);
const {CodeGraph} = require('./checkout/dist/index.js');
const result=[];
for(const name of ['corpus-runs/small-noise','corpus-runs/medium-jassjass','corpus-runs/large-nestharus']) {
  const root=path.resolve(name);const t=performance.now();const cg=await (fs.existsSync(path.join(root,'.codegraph','codegraph.db')) ? CodeGraph.recreate(root) : CodeGraph.init(root)); const indexed=await cg.indexAll();
  const files=cg.getFiles();const nodes=files.flatMap(f=>cg.getNodesInFile(f.path));const errors=files.flatMap(f=>(f.errors??[]).map(e=>({file:f.path,...e})));
  const item={name,indexMs:performance.now()-t,rss:process.memoryUsage().rss,files:files.length,lines:files.reduce((n,f)=>n+fs.readFileSync(path.join(root,f.path),'utf8').split('\n').length,0),nodes:nodes.length,stats:indexed,errors};
  result.push(item);fs.writeFileSync('corpus-profiled-results.json',JSON.stringify(result,null,2));fs.writeFileSync(name.replaceAll('/', '-')+'-symbols.json',JSON.stringify(nodes.map(n=>({name:n.qualifiedName,file:n.filePath,line:n.startLine,kind:n.kind})),null,2));
  cg.destroy();console.log(name,JSON.stringify({indexMs:item.indexMs,rss:item.rss,files:item.files,lines:item.lines,nodes:item.nodes,errors:errors.length}));
}
