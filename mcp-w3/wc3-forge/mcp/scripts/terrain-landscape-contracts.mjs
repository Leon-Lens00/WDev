import Ajv2020 from 'ajv/dist/2020.js';
import {readFile,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
const root=resolve(process.argv[2]);
const read=async p=>JSON.parse((await readFile(p,'utf8')).replace(/^\uFEFF/,''));
const ajv=new Ajv2020({strict:false,allErrors:true});
const results=[];
for(const [schema,paths] of [
 ['landscape-brief-v1.schema.json',['briefs/D.json','briefs/E.json','briefs/F.json']],
 ['landscape-library-v3.schema.json',['library/library-v3.json']],
 ['scene-v4.schema.json',['experiments/integration/D-14/spec.json','experiments/integration/E-06/spec.json','experiments/integration/F-06/spec.json']]]){
 const validate=ajv.compile(await read(resolve(root,'contracts',schema)));
 for(const path of paths){const passed=validate(await read(resolve(root,path)));results.push({path,passed,errors:validate.errors});}
}
await writeFile(resolve(root,'experiments/schema-validation.json'),JSON.stringify(results,null,2));
console.log(JSON.stringify(results));if(results.some(x=>!x.passed))process.exitCode=1;
