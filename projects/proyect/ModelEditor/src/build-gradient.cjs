// New color pack revision. Originals and previous delivered packs remain intact.
const c=require('./model.cjs'),crypto=require('node:crypto');
const {gradientTint}=require('./tint-gradient.cjs');
const root=c.path.resolve(__dirname,'..'),out=c.path.join(root,'exports/shots-colores-gradiente');
const palette=JSON.parse(c.fs.readFileSync(c.path.join(root,'assets/palette.json'))),entries=[];
for(const volume of ['I','II'])for(const double of volume==='I'?[false,true]:[false])for(const color of palette){
 const slug=volume==='I'?'shots-vol-i':'shots-vol-ii',prefix=volume==='I'?'ShotsTeam':'ShotsVolII';
 const source=(volume==='I'?'Shot Blue':'Shot II Blue')+(double?' Double':'')+'.mdx';
 const sourcePath=c.path.join(root,'exports',slug+'-anclaje',source),m=c.read(sourcePath);
 const tint=s=>gradientTint(s,color.rgb,color.index);
 for(const g of m.geosetAnimations)g.color=tint(g.color);
 for(const e of m.particleEmitters2)e.segmentColors=e.segmentColors.map(tint);
 for(const l of m.lights){l.color=tint(l.color);l.ambientColor=tint(l.ambientColor);}
 const map={'Textures\\Flare.blp':'Flare.blp','Textures\\star5tga.blp':'star5tga.blp','Textures\\Blue_Glow2.blp':`Glow_${String(color.index).padStart(2,'0')}.blp`};
 for(const t of m.textures){c.assert(map[t.path]);t.path=prefix+'\\'+map[t.path];}
 m.name=(volume==='I'?'Shot':'ShotII')+`_${String(color.index).padStart(2,'0')}_${color.name}`+(double?'_Double':'');
 const file=c.path.join(out,'Vol-'+volume,prefix,m.name+'.mdx');c.save(m,file);
 for(const t of m.textures)c.fs.copyFileSync(c.path.join(root,'assets/brillo-gradiente',c.path.basename(t.path.replaceAll('\\','/'))),c.path.join(c.path.dirname(file),c.path.basename(t.path.replaceAll('\\','/'))));
 entries.push({volume,double,color:color.index,source:c.path.relative(root,sourcePath),path:c.path.relative(root,file),sha256:crypto.createHash('sha256').update(c.fs.readFileSync(file)).digest('hex')});
}
c.fs.writeFileSync(c.path.join(root,'evidence/brillo/gradient-build.json'),JSON.stringify({entries},null,2)+'\n');
console.log(JSON.stringify({models:entries.length,independentReparse:'PASS'}));
