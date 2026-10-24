import fs from 'node:fs';import path from 'node:path';import {createRequire} from 'node:module';
const require=createRequire(import.meta.url),{CodeGraph}=require('./checkout/dist/index.js'),{ToolHandler}=require('./checkout/dist/mcp/tools.js');
for(const [name,query] of [['small-noise','Noise.Noise.perlin3D Noise.Noise.grad3D Noise.Noise.realTernaryOp Noise.Noise.openSimplex2D Noise.Noise.extrapolate2D'],['medium-jassjass','Jass.Lexer.parseIdent Jass.Parser.expression Jass.mkOp Jass.isLetter Jass.isDigit Jass.trace Jass.print'],['large-nestharus','TimerTools.Timer.create TimerTools.Timer.destroy TimerTools.CreationQueue.add TimerTools.DestructionQueue.add TimerTools.TimerPool.getTimer TimerTools.TimerPool.recycleTimer']]) {
 const root=path.resolve('corpus-runs',name),cg=await CodeGraph.open(root),handler=new ToolHandler(cg);const result=await handler.execute('codegraph_explore',{projectPath:root,query,maxFiles:3});
 fs.writeFileSync('corpus-explore-'+name+'.json',JSON.stringify(result,null,2));console.log(name,'error',result.isError??false, result.content.filter(c=>c.type==='text').map(c=>c.text).join('\n').slice(0,22000));cg.destroy();
}
