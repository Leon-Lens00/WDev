const fs = require('fs'), path = require('path');
const root = path.resolve(__dirname, '..');
const ts = require(path.join(root, 'runtime/typescript-js/package/lib/typescript.js'));
require.extensions['.ts'] = function(mod, file) {
  const result = ts.transpileModule(fs.readFileSync(file, 'utf8'), { compilerOptions: {
    target: ts.ScriptTarget.ES2020, module: ts.ModuleKind.CommonJS
  }, fileName: file });
  mod._compile(result.outputText, file);
};
const src = path.join(root, 'sources/jass-language-tools/src/vjass');
const {Parser} = require(path.join(src,'parser.ts'));
const {analyzeSemanticsWithAllFiles} = require(path.join(src,'analyzer.ts'));
const game = '/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/classic-assets/Scripts';
const libs = ['common.j','Blizzard.j'].map(n=>({filePath:path.join(game,n), content:fs.readFileSync(path.join(game,n),'utf8')}));
let result=[];
for(const name of fs.readdirSync(path.join(root,'fixtures')).filter(n=>n.endsWith('.j'))) {
  const file = path.join(root,'fixtures',name), content = fs.readFileSync(file,'utf8');
  const parser = new Parser(content,file); const ast = parser.parse();
  const sem = analyzeSemanticsWithAllFiles({filePath:file,content},libs,{checkUndefinedBehavior:true,checkTypes:true,checkArrayBounds:true});
  result.push({file:name,parserErrors:parser.errors,semantic:sem.semanticResult,externalSymbolCount:sem.externalSymbols.size});
}
fs.writeFileSync(path.join(root,'reports/vjass-parser-results.json'),JSON.stringify(result,null,2));
for(const x of result) console.log(x.file,JSON.stringify({parseErrors:x.parserErrors.errors.length, semantic:x.semantic,externalSymbolCount:x.externalSymbolCount}));
