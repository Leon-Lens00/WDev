const c=require('./model.cjs'),crypto=require('node:crypto');
const root=c.path.resolve(__dirname,'..');
const sha=p=>crypto.createHash('sha256').update(c.fs.readFileSync(p)).digest('hex');
const built=JSON.parse(c.fs.readFileSync(c.path.join(root,'evidence/brillo/gradient-build.json')));
const verification=c.path.join(root,'evidence/brillo/gradient-verification.json');
for(const volume of ['I','II']){
 const slug=volume==='I'?'shots-vol-i':'shots-vol-ii';
 const old=c.path.join(root,'exports',slug+'-organizados'),out=old+'-brillo';
 c.assert(!c.fs.existsSync(out),'Output already exists; preserve reviewed collections');c.fs.cpSync(old,out,{recursive:true});
 const manifest=JSON.parse(c.fs.readFileSync(c.path.join(out,'manifest.json')));
 for(const e of manifest.entries){if(e.pack!=='Colores-de-jugadores')continue;
  const b=built.entries.find(x=>x.volume===volume&&c.path.basename(x.path)===e.model);c.assert(b,e.model);
  const src=c.path.join(root,b.path),folder=c.path.join(out,e.folder),m=c.read(src),prefix=volume==='I'?'ShotsTeam':'ShotsVolII';
  for(const ext of ['.mdx','.mdl'])c.fs.copyFileSync(src.replace(/\.mdx$/,ext),c.path.join(folder,e.model.replace(/\.mdx$/,ext)));
  const assets=c.path.join(folder,prefix);c.fs.rmSync(assets,{recursive:true});c.fs.mkdirSync(assets,{recursive:true});
  e.textures=[];
  for(const t of m.textures){const path=c.path.join(folder,...t.path.split('\\'));c.fs.copyFileSync(c.path.join(c.path.dirname(src),c.path.basename(t.path.replaceAll('\\','/'))),path);e.textures.push({path:t.path,sha256:sha(path),stock:false});}
  e.sha256=sha(src);
  c.fs.writeFileSync(c.path.join(folder,'IMPORTAR.txt'),[`Shots Vol. ${volume}, ${e.type}, ${e.color}`,'Modelo: '+e.model,'Ruta de importación: '+e.modelImportPath,'Importar también estas tres texturas con sus rutas completas:',...e.textures.map(x=>x.path),'El MDL es fuente editable; no se importa al juego.','Revisión: gradiente original, núcleo claro y color de jugador; anclaje frontal conservado.','Dar crédito a Vinz. Conservar CREDITOS-Vinz.html.',''].join('\n'));
 }
 manifest.revision='brillo-gradiente-2026-10-22';manifest.modelBytesUnchanged=false;manifest.previousCollection=c.path.basename(old);manifest.colorModels=built.entries.filter(x=>x.volume===volume).length;
 c.fs.writeFileSync(c.path.join(out,'manifest.json'),JSON.stringify(manifest,null,2)+'\n');
 c.fs.copyFileSync(verification,c.path.join(out,'Colores-de-jugadores/VERIFICACION.json'));
 const val=c.path.join(out,'Colores-de-jugadores/VALIDACION.md');c.fs.writeFileSync(val,'# Revisión de color y brillo\n\nVer REVISION-BRILLO.md en la raíz. VERIFICACION.json corresponde a la nueva revisión de 36 variantes entre ambos volúmenes. Los colores originales conservan sus bytes y su validación anterior.\n');
 c.fs.writeFileSync(c.path.join(out,'LEEME.txt'),[`Shots Vol. ${volume} — revisión de brillo y gradiente`,'Colores-de-jugadores: doce variantes por tipo, con centro claro y textura glow recoloreada.','Vol. I incluye Misil-simple y Misil-doble; Vol. II conserva únicamente Misil-simple.','Cada carpeta de color incluye MDX, MDL, tres texturas, créditos y rutas de importación.','Colores-originales: derivados de anclaje anteriores, con colores y bytes conservados.','Las colecciones anteriores se conservan para trazabilidad. Usar esta revisión para los colores de jugadores.','El sistema puede seleccionar el modelo con los helpers JASS incluidos; no hay cambio automático de color dentro del MDX.','No modifica la física ni las colisiones del mapa.','Vinz: autor de los modelos originales. Recursos base de Warcraft III Classic.','Ver REVISION-BRILLO.md para cobertura de pruebas y límites.',''].join('\n'));
 c.fs.copyFileSync(c.path.join(root,'REVISION-BRILLO.md'),c.path.join(out,'REVISION-BRILLO.md'));
 for(const name of ['gradient-build.json','gradient-verification.json','gradient-textures.json'])c.fs.copyFileSync(c.path.join(root,'evidence/brillo',name),c.path.join(out,name));
 for(const e of manifest.entries){const folder=c.path.join(out,e.folder);c.assert.equal(sha(c.path.join(folder,e.model)),e.sha256);for(const t of e.textures)c.assert.equal(sha(c.path.join(folder,...t.path.split('\\'))),t.sha256);}
 console.log(JSON.stringify({out,models:manifest.entries.length,players:manifest.colorModels,hashes:'PASS'}));
}
