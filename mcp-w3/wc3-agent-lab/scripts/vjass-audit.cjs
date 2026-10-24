const fs = require('fs'), path = require('path');
const root = path.resolve(__dirname, '..');
const ts = require(path.join(root,'runtime/typescript-js/package/lib/typescript.js'));
require.extensions['.ts']=(mod,file)=>mod._compile(ts.transpileModule(fs.readFileSync(file,'utf8'),{
  compilerOptions:{target:ts.ScriptTarget.ES2020,module:ts.ModuleKind.CommonJS},fileName:file
}).outputText,file);
const {Parser}=require(path.join(root,'sources/jass-language-tools/src/vjass/parser.ts'));
const {analyzeSemanticsWithAllFiles}=require(path.join(root,'sources/jass-language-tools/src/vjass/analyzer.ts'));
const files=process.argv.slice(2).map(p=>path.resolve(p));
if(!files.length){console.error('Usage: vjass-audit SOURCE.j [DEPENDENCY.j ...]');process.exit(2);}
const api='/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/classic-assets/Scripts';
const current={filePath:files[0],content:fs.readFileSync(files[0],'utf8')};
const extra=[...files.slice(1),path.join(api,'common.j'),path.join(api,'Blizzard.j')].map(p=>({filePath:p,content:fs.readFileSync(p,'utf8')}));
const parser=new Parser(current.content,current.filePath);parser.parse();
const result=analyzeSemanticsWithAllFiles(current,extra,{checkUndefinedBehavior:true,checkTypes:true,checkArrayBounds:true});
console.log(JSON.stringify({status:'advisory',file:current.filePath,standardLibraries:extra.slice(-2).map(x=>x.filePath),
  parser:parser.errors,semantic:result.semanticResult,externalSymbols:result.externalSymbols.size,
  limitations:['Not JassHelper/pJASS validation','Pass dependencies explicitly; no implicit workspace scan',
    'The trial parser missed an incomplete assignment; an empty result is not approval',
    'No proof of runtime behavior, MUI, leaks or multiplayer safety']},null,2));
