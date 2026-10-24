const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),manifest=JSON.parse(c.fs.readFileSync(c.path.join(root,'evidence/brillo/gradient-build.json')));
let poses=0,textures=0;
function strip(model){const m=c.plain(model);delete m.name;for(const g of m.geosetAnimations)delete g.color;for(const p of m.particleEmitters2)delete p.segmentColors;for(const l of m.lights){delete l.color;delete l.ambientColor;}for(const t of m.textures)delete t.path;return m;}
function canonical(model){const a=c.plain(model);for(const n of a.lights)n.flags&=~512;for(const n of a.particleEmitters2)n.flags&=~4096;function sort(o){if(!o||typeof o!=='object')return;if(o.animations)o.animations.sort((a,b)=>a.name.localeCompare(b.name));Object.values(o).forEach(sort);}sort(a);return a;}
function near(a,b){if(typeof a==='number'){c.assert(Math.abs(a-b)<=0.00002,`${a} != ${b}`);return;}if(a&&typeof a==='object'){c.assert.deepEqual(Object.keys(a),Object.keys(b));for(const k of Object.keys(a))near(a[k],b[k]);}else c.assert.equal(a,b);}
for(const e of manifest.entries){const file=c.path.join(root,e.path),m=c.read(file),s=c.read(c.path.join(root,e.source));
 c.assert.equal(crypto.createHash('sha256').update(c.fs.readFileSync(file)).digest('hex'),e.sha256);
 c.assert.deepEqual(strip(m),strip(s),'Only color, texture path and model name may change');
 const mdl=new c.Model();mdl.loadMdl(c.fs.readFileSync(file.replace(/\.mdx$/,'.mdl'),'utf8'));near(canonical(m),canonical(mdl));
 for(let seq=0;seq<m.sequences.length;seq++)for(const time of c.frames(m,seq,10)){c.assert.deepEqual(c.pose(m,seq,time),c.pose(s,seq,time));poses++;}
 for(const t of m.textures){const path=c.path.join(c.path.dirname(c.path.dirname(file)),...t.path.split('\\'));c.assert(c.fs.existsSync(path),path);textures++;}
 // A blue revision retains the reference's actual color fields, not merely its peak.
 if(e.color===1){near(c.plain(m.geosetAnimations),c.plain(s.geosetAnimations));for(let i=0;i<m.particleEmitters2.length;i++)near(c.plain(m.particleEmitters2[i].segmentColors),c.plain(s.particleEmitters2[i].segmentColors));}
}
for(const slug of ['shots-vol-i','shots-vol-ii']){const dir=c.path.join(root,'../descargas/warcraft3/misiles/vinz',slug),src=JSON.parse(c.fs.readFileSync(c.path.join(dir,'manifest.json')));for(const e of src.files)c.assert.equal(crypto.createHash('sha256').update(c.fs.readFileSync(c.path.join(dir,e.path))).digest('hex'),e.sha256);}
const result={models:manifest.entries.length,poses,textureReferences:textures,nonColorStructure:'exact',poseAndEmitterAnchors:'exact',mdl:'PASS',blueSourceColorFields:'preserved',originalHashes:'PASS',game:'separate evidence'};
c.fs.writeFileSync(c.path.join(root,'evidence/brillo/gradient-verification.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result));
