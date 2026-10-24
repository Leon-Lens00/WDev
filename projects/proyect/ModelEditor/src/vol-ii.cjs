// Shots Vol. II pipeline. Keeps Vol. I tooling and exports unchanged.
const c=require('./model.cjs');
const {anchor}=require('./anchor.cjs');
const crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..'),project=c.path.dirname(root);
const input=c.path.join(project,'descargas/warcraft3/misiles/vinz/shots-vol-ii');
const source=c.path.join(input,'originales/Shots Vol. II');
const evidence=c.path.join(root,'evidence/vol-ii');
const anchored=c.path.join(root,'exports/shots-vol-ii-anclaje');
const players=c.path.join(root,'exports/shots-vol-ii-jugadores');
const manifest=JSON.parse(c.fs.readFileSync(c.path.join(input,'manifest.json')));
const palette=JSON.parse(c.fs.readFileSync(c.path.join(root,'assets/palette.json')));
const sha=file=>crypto.createHash('sha256').update(c.fs.readFileSync(file)).digest('hex');
function checkOriginals(){for(const e of manifest.files)c.assert.equal(sha(c.path.join(input,e.path)),e.sha256);}
function flightOffset(m,delta) {
  const original=m.helpers.find(n=>n.name==='Avante');c.assert(original&&original.parentId===3);
  const targets=m.particleEmitters2.filter(n=>['Atras Uno','Atras Dos Sq Tails'].includes(n.name));
  c.assert.equal(targets.length,2);c.assert(targets.every(n=>n.parentId===original.objectId));
  const Helper=original.constructor;
  const Vector3=c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/animations').Vector3Animation;
  const offset=new Helper(),clone=new Helper();
  offset.objectId=m.pivotPoints.length;offset.parentId=3;offset.name='Anclaje estelas vuelo';
  const tr=new Vector3();tr.name='KGTR';tr.interpolationType=0;
  const keys=m.sequences.flatMap(s=>Array.from(s.interval).map(t=>({t,v:s.name==='Death'?[0,0,0]:delta}))).sort((a,b)=>a.t-b.t);
  tr.frames=keys.map(k=>k.t);tr.values=keys.map(k=>Float32Array.from(k.v));offset.animations=[tr];
  m.pivotPoints.push(new Float32Array(3));
  clone.objectId=m.pivotPoints.length;clone.parentId=offset.objectId;clone.name='Avante estelas vuelo';clone.flags=original.flags;
  // Unchanged rotation tracks are shared read-only while writing, then reparsed.
  clone.animations=original.animations;
  m.pivotPoints.push(Float32Array.from(m.pivotPoints[original.objectId]));
  m.helpers.push(offset,clone);
  for(const emitter of targets)emitter.parentId=clone.objectId;
  return {flightTrailIds:targets.map(n=>n.objectId),addedHelperIds:[offset.objectId,clone.objectId]};
}
function build() {
  checkOriginals();c.fs.mkdirSync(evidence,{recursive:true});const entries=[];
  for(const file of manifest.files.filter(f=>f.path.endsWith('.mdx'))) {
    const name=c.path.basename(file.path),m=c.read(c.path.join(source,name));
    const transform=anchor(m);Object.assign(transform,flightOffset(m,transform.delta));
    const output=c.path.join(anchored,name);c.save(m,output);
    entries.push({pack:'anchor',source:name,path:c.path.relative(root,output),sha256:sha(output),transform});
  }
  for(const color of palette) {
    const m=c.read(c.path.join(anchored,'Shot II Blue.mdx'));
    const tint=old=>Float32Array.from(color.rgb,x=>x/255*Math.max(...old));
    for(const g of m.geosetAnimations){c.assert(!g.animations.some(a=>a.name==='KGAC'));g.color=tint(g.color);}
    for(const e of m.particleEmitters2)e.segmentColors=e.segmentColors.map(tint);
    for(const l of m.lights){c.assert(!l.animations.some(a=>['KLAC','KLBC'].includes(a.name)));l.color=tint(l.color);l.ambientColor=tint(l.ambientColor);}
    const replacements={'Textures\\Flare.blp':'ShotFlareNeutral.blp','Textures\\star5tga.blp':'ShotStarNeutral.blp','Textures\\Blue_Glow2.blp':'ShotGlowNeutral.blp'};
    for(const texture of m.textures){c.assert(replacements[texture.path]);texture.path='ShotsVolII\\'+replacements[texture.path];}
    m.name=`ShotII_${String(color.index).padStart(2,'0')}_${color.name}`;
    const output=c.path.join(players,'ShotsVolII',m.name+'.mdx');c.save(m,output);
    entries.push({pack:'players',source:'Shot II Blue.mdx',color:color.index,path:c.path.relative(root,output),sha256:sha(output)});
  }
  for(const file of ['ShotFlareNeutral.blp','ShotStarNeutral.blp','ShotGlowNeutral.blp'])c.fs.copyFileSync(c.path.join(root,'assets',file),c.path.join(players,'ShotsVolII',file));
  for(const folder of [anchored,players])c.fs.copyFileSync(c.path.join(source,'readme.html'),c.path.join(folder,'CREDITOS-Vinz.html'));
  c.fs.writeFileSync(c.path.join(players,'palette.json'),JSON.stringify(palette,null,2)+'\n');
  c.fs.writeFileSync(c.path.join(evidence,'build-manifest.json'),JSON.stringify({target:'Warcraft III Classic 1.27b / MDX800',source:manifest.source,originalsVerified:manifest.files.length,entries},null,2)+'\n');
  console.log(JSON.stringify({originals:6,anchored:6,playerColors:12,models:entries.length,sourceHashes:'PASS'}));
}
if(require.main===module)build();
module.exports={root,project,input,source,evidence,anchored,players,manifest,palette,sha,checkOriginals,flightOffset,build};
