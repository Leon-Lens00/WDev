const crypto=require('node:crypto');
const c=require('./model.cjs');
const {anchor}=require('./anchor.cjs');
const root=c.path.resolve(__dirname,'..'),project=c.path.dirname(root);
const input=c.path.join(project,'descargas/warcraft3/misiles/vinz/shots-vol-i');
const originals=c.path.join(input,'originales/Shots Vol. I');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
const manifests=JSON.parse(c.fs.readFileSync(c.path.join(input,'manifest.json')));
const palette=JSON.parse(c.fs.readFileSync(c.path.join(root,'assets/palette.json')));
const anchored=c.path.join(root,'exports/shots-vol-i-anclaje');
const colors=c.path.join(root,'exports/shots-vol-i-jugadores');
const entries=[];
for(const e of manifests.files) c.assert.equal(sha(c.fs.readFileSync(c.path.join(input,e.path))),e.sha256,'Original modified');
function emit(model,file,meta) {
  const written=c.save(model,file);
  entries.push({...meta,path:c.path.relative(root,file),sha256:sha(c.fs.readFileSync(file)),bytes:c.fs.statSync(file).size});
  return written;
}
for(const e of manifests.files.filter(e=>e.path.endsWith('.mdx'))) {
  const name=c.path.basename(e.path),m=c.read(c.path.join(originals,name));
  const transform=anchor(m);
  emit(m,c.path.join(anchored,name),{pack:'anchor',source:name,transform});
}
const tint=(old,rgb)=>Float32Array.from(rgb,x=>x/255*Math.max(...old));
for(const double of [false,true]) for(const color of palette) {
  const source='Shot Blue'+(double?' Double':'')+'.mdx';
  const m=c.read(c.path.join(anchored,source));
  for(const g of m.geosetAnimations) {
    c.assert(!g.animations.some(a=>a.name==='KGAC'));
    g.color=tint(g.color,color.rgb);
  }
  for(const p of m.particleEmitters2) p.segmentColors=p.segmentColors.map(s=>tint(s,color.rgb));
  for(const light of m.lights) {
    c.assert(!light.animations.some(a=>['KLAC','KLBC'].includes(a.name)));
    light.color=tint(light.color,color.rgb);
    light.ambientColor=tint(light.ambientColor,color.rgb);
  }
  const replacements={'Textures\\Flare.blp':'ShotFlareNeutral.blp','Textures\\star5tga.blp':'ShotStarNeutral.blp','Textures\\Blue_Glow2.blp':'ShotGlowNeutral.blp'};
  for(const texture of m.textures) {c.assert(replacements[texture.path]);texture.path='ShotsTeam\\'+replacements[texture.path];}
  const name=`Shot_${String(color.index).padStart(2,'0')}_${color.name}${double?'_Double':''}`;
  m.name=name;
  emit(m,c.path.join(colors,'ShotsTeam',name+'.mdx'),{pack:'players',source,color:color.index,double});
}
c.fs.mkdirSync(c.path.join(colors,'ShotsTeam'),{recursive:true});
for(const file of ['ShotFlareNeutral.blp','ShotStarNeutral.blp','ShotGlowNeutral.blp']) c.fs.copyFileSync(c.path.join(root,'assets',file),c.path.join(colors,'ShotsTeam',file));
c.fs.writeFileSync(c.path.join(colors,'palette.json'),JSON.stringify(palette,null,2)+'\n');
for(const folder of [anchored,colors]) c.fs.copyFileSync(c.path.join(originals,'readme.html'),c.path.join(folder,'ORIGINAL-Vinz-readme.html'));
c.fs.writeFileSync(c.path.join(root,'evidence/build-manifest.json'),JSON.stringify({target:'Warcraft III Classic 1.27b, MDX800',originalsVerified:manifests.files.length,source:manifests.source,entries},null,2)+'\n');
console.log(JSON.stringify({models:entries.length,anchor:12,playerColors:12,playerModels:24,originals:'PASS'}));
