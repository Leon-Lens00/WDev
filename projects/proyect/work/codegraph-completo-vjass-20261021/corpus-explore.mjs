import fs from 'node:fs';import path from 'node:path';import {createRequire} from 'node:module';
const require=createRequire(import.meta.url),{CodeGraph}=require('./checkout/dist/index.js'),{ToolHandler}=require('./checkout/dist/mcp/tools.js');
for(const [name,query] of [['small-noise','Noise perlin2D floor fade lerp octavePerlin2D'],['medium-jassjass','Jass assert error print cons parse'],['large-nestharus','StringHash TimerUtils BinaryHeap T32']]) {
 const root=path.resolve('corpus-runs',name),cg=await CodeGraph.open(root),handler=new ToolHandler(cg);const result=await handler.execute('codegraph_explore',{projectPath:root,query,maxFiles:3});
 fs.writeFileSync('corpus-explore-'+name+'.json',JSON.stringify(result,null,2));console.log(name,'error',result.isError??false, result.content.filter(c=>c.type==='text').map(c=>c.text).join('\n').slice(0,10500));cg.destroy();
}
