const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..');
const base=c.path.join(root,'../descargas/warcraft3/misiles/vinz/biblioteca-originales/01-Energia-y-plasma');
const paths=[
 'shots-vol-ii.315512/originales/Shots Vol. II/Shot II Blue.mdx',
 'psionic-shots.319594/originales/Psionic Shots/Psionic Shot Blue/Psionic Shot Blue.mdx',
 'firebrand-shots.319649/originales/Firebrand Shots/Firebrand Shot Blue/Firebrand Shot Blue.mdx'
];
const report=[];
for(const path of paths){
 const file=c.path.join(base,path),m=c.read(file),death=m.sequences.find(s=>s.name==='Death');
 const deathEmitters=[];
 for(const p of m.particleEmitters2){
  const tracks=p.animations.filter(a=>a.name==='KP2E');
  if(!tracks.some(a=>a.frames.some((t,i)=>t>=death.interval[0]&&t<=death.interval[1]&&a.values[i][0]>0)))continue;
  const emission=tracks.map(a=>({interpolationType:a.interpolationType,global:a.globalSequenceId,keys:a.frames.map((t,i)=>({msFromDeath:t-death.interval[0],rate:a.values[i][0]}))}));
  deathEmitters.push({name:p.name,texture:m.textures[p.textureId].path,lifeSpan:p.lifeSpan,speed:p.speed,latitude:p.latitude,size:Array.from(p.segmentScaling),alpha:Array.from(p.segmentAlphas),emission});
 }
 report.push({path:c.path.relative(root,file),sha256:crypto.createHash('sha256').update(c.fs.readFileSync(file)).digest('hex'),sequences:c.plain(m.sequences),deathEmitters});
}
c.fs.writeFileSync(c.path.join(root,'evidence/x3-v11/reference-study.json'),JSON.stringify(report,null,2)+'\n');
console.log(report.map(r=>({path:r.path,emitters:r.deathEmitters.length})));
