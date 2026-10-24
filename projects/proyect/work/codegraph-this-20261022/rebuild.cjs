const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {CodeGraph}=require('/home/snz/Documentos/MCP W3/codegraph-vjass/dist');
const sources=JSON.parse(fs.readFileSync(path.join(__dirname,'original-production-sources.json'),'utf8'));
(async()=>{
 const results=[];
 for(const row of sources){
  const graph=await CodeGraph.open(row.root);
  try{
   await graph.indexAll();
   const unchanged=Object.entries(row.source_sha256).every(([rel,hash])=>crypto.createHash('sha256').update(fs.readFileSync(path.join(row.root,rel))).digest('hex')===hash);
   if(!unchanged)throw new Error('Original project source changed');
   const spell=graph.getNodesByQualifiedName('RapidFire.RapidPair.spell')[0];
   const callees=spell?graph.getCallees(spell.id).filter(x=>x.edge.kind==='calls').map(x=>x.node.qualifiedName):[];
   if(row.root.endsWith('/TerrainDev/src')&&!callees.includes('RapidFire.RapidPair.cast'))throw new Error('Production cast edge still absent');
   const result={root:row.root,unchanged,callees,stats:graph.getStats()};results.push(result);
   fs.writeFileSync(path.join(__dirname,'production-rebuild-results.json'),JSON.stringify(results,null,2)+'\n');
   process.stdout.write(JSON.stringify({root:row.root,unchanged,callees})+'\n');
  }finally{graph.destroy();}
 }
})().catch(e=>{process.stderr.write(e.stack+'\n');process.exitCode=1;});
