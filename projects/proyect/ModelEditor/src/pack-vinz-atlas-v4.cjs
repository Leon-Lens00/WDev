const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),base=c.path.join(root,'../descargas/warcraft3/misiles/vinz/biblioteca-originales');
const out=c.path.join(root,'viewer/vinz-study-v4'),ev=c.path.join(root,'evidence/x3-v4/study');
for(const dir of ['models','textures'])c.fs.mkdirSync(c.path.join(out,dir),{recursive:true});
const audit=JSON.parse(c.fs.readFileSync(c.path.join(ev,'all-models.json'))),stock=JSON.parse(c.fs.readFileSync(c.path.join(ev,'resources.json')));const textures={};
const norm=p=>p.toLowerCase().replaceAll('\\','/');const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function add(file){const b=c.fs.readFileSync(file),name=sha(b)+'.blp',dest=c.path.join(out,'textures',name);if(!c.fs.existsSync(dest))c.fs.writeFileSync(dest,b);return 'textures/'+name;}
for(const t of stock)if(t.file)textures[norm(t.path)]=add(c.path.join(root,t.file));
// Transparent diagnostic resource, explicitly labelled whenever used; originals never changed.
const blank=Buffer.alloc(1182);blank.write('BLP1');[1,8,1,1,4,1].forEach((v,i)=>blank.writeUInt32LE(v,4+i*4));blank.writeUInt32LE(1180,28);blank.writeUInt32LE(2,92);for(let i=0;i<256;i++)blank.set([i,i,i,255],156+i*4);c.fs.writeFileSync(c.path.join(out,'textures/missing.blp'),blank);
const items=[];
for(const e of audit.entries){
 const file=c.path.join(base,e.file),folder=c.path.dirname(file),packRoot=c.path.join(base,e.file.split('/').slice(0,2).join('/')),resourceMap={...textures},missing=[],aliases=[];
 for(const t of e.textures){if(!t.path)continue;const key=norm(t.path);let p=c.path.join(folder,...t.path.split('\\'));if(c.fs.existsSync(p)){resourceMap[key]=add(p);continue;}
 const candidates=t.packedCandidates.map(p=>c.path.join(packRoot,p));if(candidates.length){const unique=new Set(candidates.map(p=>sha(c.fs.readFileSync(p))));if(unique.size===1){resourceMap[key]=add(candidates[0]);if(t.path.startsWith('_hd.'))aliases.push({path:t.path,source:c.path.relative(base,candidates[0]),kind:'provided sibling texture with same filename'});continue;}}
 if(!resourceMap[key]){resourceMap[key]='textures/missing.blp';missing.push({path:t.path,used:t.used});}
 }
 const mdx='models/'+e.id+'.mdx';c.fs.copyFileSync(file,c.path.join(out,mdx));c.assert.equal(sha(c.fs.readFileSync(c.path.join(out,mdx))),e.sha256);
 items.push({id:e.id,label:e.label,pack:e.pack,mdx,resources:resourceMap,missing,aliases,geometry:e.geometry,sequences:e.sequences,pe2:e.pe2.length,ribbons:e.ribbonDetails.length,triangles:e.triangles,sha256:e.sha256});
}
c.fs.writeFileSync(c.path.join(out,'data.js'),'window.STUDY='+JSON.stringify(items)+';');
c.fs.copyFileSync(c.path.join(require('./runtime.cjs').modules,'mdx-m3-viewer/dist/umd/viewer.min.js'),c.path.join(out,'viewer.min.js'));
c.fs.copyFileSync(c.path.join(root,'src/vinz-atlas-v4.html'),c.path.join(out,'index.html'));c.fs.copyFileSync(c.path.join(root,'src/vinz-atlas-v4.js'),c.path.join(out,'app.js'));
c.fs.writeFileSync(c.path.join(ev,'atlas-resources.json'),JSON.stringify(items.map(({id,label,missing,aliases})=>({id,label,missing,aliases})),null,2));console.log(JSON.stringify({models:items.length,complete:items.filter(e=>!e.missing.some(t=>t.used)).length,partial:items.filter(e=>e.missing.some(t=>t.used)).map(e=>({id:e.id,label:e.label,missing:e.missing.filter(t=>t.used)}))}));
