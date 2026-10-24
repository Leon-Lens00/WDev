const fs=require('fs'),path=require('path'),assert=require('assert/strict'),crypto=require('crypto');
const root='/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09';
const c=require(root+'/Personajes-WC3-127b/scripts/fallen_core.cjs');
const Model=require(c.LIB+'/mdx-m3-viewer/dist/cjs/parsers/mdlx/model').default;
const sha=p=>crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex');
const out=path.join(__dirname,'smoke-output');fs.mkdirSync(out,{recursive:true});
const result={node:process.version,library_root:c.LIB,models:[],scope:'Lectura/escritura/relectura MDX800 y comparación numérica; sin render, sin juego, sin FPS.'};
for(const [name,id]of [['Newborn','30235'],['Rangedborn','30119']]){
 const input=root+'/Newborn-WC3-127b/pruebas-editor-v11/TDAU/'+name+'-NPC-'+id+'/TDAU_'+name+'_NPC_'+id+'_Compacto_Prueba.mdx';
 const before=sha(input), m=c.nodes(c.read(input)), bytes=fs.readFileSync(input), independent=new Model();
 independent.loadMdx(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));
 assert.equal(m.Version,800);assert.equal(independent.version,800);
 assert.equal(independent.geosets.length,m.Geosets.length);assert.equal(independent.sequences.length,m.Sequences.length);
 const metricsBefore=c.metrics(m),output=path.join(out,name+'.mdx');assert(!fs.existsSync(output),'Preservar evidencia de ejecución previa');
 const after=c.save(m,output);assert.deepEqual(c.metrics(after),metricsBefore);
 for(const prop of ['Geosets','Materials','Textures','Sequences','PivotPoints'])c.near(m[prop],after[prop],prop);
 assert.equal(m.Bones.length,after.Bones.length);assert.equal(m.Helpers.length,after.Helpers.length);
 for(const n of m.Nodes.filter(Boolean)){const other=after.Nodes[n.ObjectId];assert(other);assert.equal(n.Parent,other.Parent);for(const prop of ['Translation','Rotation','Scaling'])c.near(n[prop],other[prop],n.Name+'.'+prop);}
 const mdl=fs.readFileSync(output.replace(/\.mdx$/,'.mdl'),'utf8'),independentMdl=new Model(); independentMdl.loadMdl(mdl);
 assert.equal(independentMdl.geosets.length,m.Geosets.length);
 const texturePaths=m.Textures.map(t=>t.Image).filter(Boolean).map(t=>({declared:t,path:path.resolve(path.dirname(input),t.replaceAll('\\','/'))}));
 for(const texture of texturePaths)assert(fs.existsSync(texture.path),'Falta textura '+texture.path);
 assert.equal(sha(input),before);
 result.models.push({name,input,input_sha256:before,original_unchanged:true,version:m.Version,bytes:bytes.length,metrics:metricsBefore,output,output_sha256:sha(output),mdl_independently_parsed:true,numeric_structure_comparison:true,texture_paths_present:texturePaths});
}
fs.writeFileSync(path.join(__dirname,'smoke-result.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify(result,null,2));
