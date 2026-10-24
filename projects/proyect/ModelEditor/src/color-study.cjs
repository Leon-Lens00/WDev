// Diagnostic candidates only; do not overwrite either delivered color pack.
const c=require('./model.cjs');
const {teamTint}=require('./team-tint.cjs');
const root=c.path.resolve(__dirname,'..'),out=c.path.join(root,'exports/candidatos-brillo');
const palette=JSON.parse(c.fs.readFileSync(c.path.join(root,'assets/palette.json')));
const entries=[],stats=[];
for(const volume of ['I','II']) {
  const folder=volume==='I'?'shots-vol-i-anclaje':'shots-vol-ii-anclaje';
  const name=volume==='I'?'Shot Blue.mdx':'Shot II Blue.mdx';
  const source=c.path.join(root,'exports',folder,name);
  const prefix=volume==='I'?'ShotsTeam':'ShotsVolII';
  for(const color of palette) {
    const m=c.read(source),oldGeo=Array.from(m.geosetAnimations[0].color);
    for(const g of m.geosetAnimations)g.color=teamTint(g.color,color.rgb);
    for(const p of m.particleEmitters2)p.segmentColors=p.segmentColors.map(s=>teamTint(s,color.rgb));
    for(const l of m.lights){l.color=teamTint(l.color,color.rgb);l.ambientColor=teamTint(l.ambientColor,color.rgb);}
    const textures={'Textures\\Flare.blp':'ShotFlareNeutral.blp','Textures\\star5tga.blp':'ShotStarNeutral.blp','Textures\\Blue_Glow2.blp':'ShotGlowNeutral.blp'};
    for(const t of m.textures){c.assert(textures[t.path]);t.path=prefix+'\\'+textures[t.path];}
    const basename=volume==='I'?`Shot_${String(color.index).padStart(2,'0')}_${color.name}`:`ShotII_${String(color.index).padStart(2,'0')}_${color.name}`;
    m.name=basename;
    const file=c.path.join(out,'Vol-'+volume,prefix,basename+'.mdx');c.save(m,file);
    entries.push({volume,color:color.index,path:c.path.relative(root,file)});
    stats.push({volume,color:color.name,originalGeo:oldGeo,flatGeo:color.rgb.map(x=>x/255*Math.max(...oldGeo)),highlightGeo:Array.from(m.geosetAnimations[0].color)});
  }
  for(const t of ['ShotFlareNeutral.blp','ShotStarNeutral.blp','ShotGlowNeutral.blp'])c.fs.copyFileSync(c.path.join(root,'assets',t),c.path.join(out,'Vol-'+volume,prefix,t));
}
c.fs.mkdirSync(c.path.join(root,'evidence/brillo'),{recursive:true});
c.fs.writeFileSync(c.path.join(root,'evidence/brillo/candidates.json'),JSON.stringify({entries,stats},null,2)+'\n');
console.log(JSON.stringify({candidateModels:entries.length,whiteSourceRemainsWhite:Array.from(teamTint([1,1,1],[255,3,3])),red:stats.find(x=>x.volume==='I'&&x.color==='Red')}));
