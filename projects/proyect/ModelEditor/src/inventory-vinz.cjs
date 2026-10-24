// Read-only inventory. Parsing is not a claim of Classic runtime compatibility.
const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),base=c.path.resolve(root,'../descargas/warcraft3/misiles/vinz/biblioteca-originales');
const library=JSON.parse(c.fs.readFileSync(c.path.join(base,'manifest.json'))),models=[],errors=[];
const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');
for(const pack of library.entries){const folder=c.path.join(base,pack.folder);c.assert.equal(sha(c.path.join(folder,pack.zip)),pack.zipSha256);
 for(const f of pack.files){const file=c.path.join(folder,f.path);c.assert.equal(sha(file),f.sha256);if(!f.path.toLowerCase().endsWith('.mdx'))continue;
  try{const m=c.read(file),tex=m.textures.map(t=>{const name=t.path.replaceAll('\\','/').split('/').pop().toLowerCase();const local=pack.files.filter(f=>f.path.replaceAll('\\','/').split('/').pop().toLowerCase()===name);return{path:t.path,replaceableId:t.replaceableId,packedCandidates:local.map(f=>f.path),resolution:t.replaceableId?'replaceable':local.length?'included':'external-or-game-unverified'};});
   models.push({pack:pack.title,category:pack.category,file:c.path.relative(base,file),sha256:f.sha256,name:m.name,version:m.version,sequences:m.sequences.map(s=>({name:s.name,interval:Array.from(s.interval)})),geosets:m.geosets.length,vertices:m.geosets.reduce((n,g)=>n+g.vertices.length/3,0),triangles:m.geosets.reduce((n,g)=>n+g.faces.length/3,0),particleEmitters2:m.particleEmitters2.length,ribbons:m.ribbonEmitters.length,lights:m.lights.length,textures:tex,emitterModelPaths:m.particleEmitters.map(p=>p.path),declaredModern:/1\.32/.test(pack.title),testedIn127b:false});
  }catch(error){errors.push({pack:pack.title,file:f.path,error:error.message});}
 }
}
const result={packages:library.entries.length,models:models.length,errors,checks:'ZIP and extracted file SHA256 verified; read only; game dependencies unverified',entries:models};
c.fs.writeFileSync(c.path.join(base,'inventario-modelos.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({packages:result.packages,models:result.models,errors,pe2:models.reduce((n,m)=>n+m.particleEmitters2,0),ribbons:models.reduce((n,m)=>n+m.ribbons,0)}));
if(errors.length)process.exitCode=1;
