const fs = require('node:fs');
const path = require('node:path');
const {CodeGraph} = require('./checkout/dist');
(async () => {
 const results=[];
 for (const label of ['missiles','inventory']) {
  const root=path.join(__dirname,'profile-root-'+label);
  const graph=await CodeGraph.init(root);
  try {
   const indexed=await graph.indexAll();
   const spell=graph.getNodesByQualifiedName('RapidFire.RapidPair.spell')[0];
   const calls=spell?graph.getCallees(spell.id).filter(x=>x.edge.kind==='calls').map(x=>x.node.qualifiedName):[];
   const api=graph.getNodesByName('GetSpellTargetX').map(n=>({name:n.name,file:n.filePath,api:n.semanticData?.api}));
   const row={label,files:graph.getStats().totalFiles,calls,api};
   if(label==='missiles'&&!calls.includes('RapidFire.RapidPair.cast')) throw new Error('Missing corrected cast edge');
   if(api.length!==1||api[0].api!==true) throw new Error('API inputs missing/ambiguous');
   results.push(row);fs.writeFileSync(path.join(__dirname,'profile-probe-results.json'),JSON.stringify(results,null,2)+'\n');
   process.stdout.write(JSON.stringify(row)+'\n');
  } finally {graph.destroy();}
 }
})().catch(e=>{process.stderr.write(e.stack+'\n');process.exitCode=1;});
