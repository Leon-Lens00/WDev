import { createRequire } from 'node:module';
const require = createRequire('/home/snz/Documentos/MCP W3/codegraph-vjass/package.json');
const { CodeGraph } = require('./dist');
const cg = await CodeGraph.recreate('/home/snz/Documentos/ChatGPT/Proyect/work/codegraph-ampliacion-vjass-20261021/block-array-probe');
try { await cg.indexAll();
const main = cg.getNodesByQualifiedName('main')[0];
console.log(JSON.stringify({callees:cg.getCallees(main.id).map(c=>c.node.qualifiedName),binding:cg.getNodesByName('values').map(n=>n.signature),expectedCompilerCall:'S.tick'}));
} finally {cg.destroy();}
