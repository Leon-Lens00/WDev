// Copy verified models into per-type/per-color folders, preserving binary paths.
const c=require('./model.cjs');
const crypto=require('node:crypto');
const {spawnSync}=require('node:child_process');
const root=c.path.resolve(__dirname,'..');
const output=c.path.join(root,'exports/shots-vol-i-organizados');
const cache=c.path.join(root,'assets/recursos-originales');
const game='/home/snz/Documentos/ChatGPT/FrozenThone/games/WarcraftIII-1.27b';
const cli='/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py';
const sha=file=>crypto.createHash('sha256').update(c.fs.readFileSync(file)).digest('hex');
const manifest=JSON.parse(c.fs.readFileSync(c.path.join(root,'evidence/build-manifest.json')));
const palette=JSON.parse(c.fs.readFileSync(c.path.join(root,'assets/palette.json')));
const labels=['Rojo','Azul','Cian','Purpura','Amarillo','Naranja','Verde','Rosa','Gris-claro','Azul-claro','Verde-oscuro','Marron'];
const originals={Blue:'Azul',Green:'Verde',Orange:'Naranja',Purple:'Purpura',Red:'Rojo',Yellow:'Amarillo'};
const entries=[],stock=[];
c.assert(!c.fs.existsSync(output),'Use a new output directory; do not overwrite a reviewed collection');
for(const entry of manifest.entries)c.assert.equal(sha(c.path.join(root,entry.path)),entry.sha256);
function stockTexture(internal) {
  const file=c.path.join(cache,...internal.split('\\'));
  if(c.fs.existsSync(file))return file;
  c.fs.mkdirSync(c.path.dirname(file),{recursive:true});
  // Match Classic patch/expansion/base precedence; a missing member is a normal fallback.
  for(const name of ['War3Patch.mpq','War3xlocal.mpq','War3x.mpq','war3.mpq']) {
    const archive=c.path.join(game,name);
    if(!c.fs.existsSync(archive))continue;
    const r=spawnSync('python',[cli,'wc3ctl','extract',archive,internal,'-o',file,'--json'],{encoding:'utf8'});
    if(r.status===0&&c.fs.existsSync(file)) {
      stock.push({internal,archive,sha256:sha(file)});return file;
    }
  }
  throw new Error('Texture not found in the Classic installation: '+internal);
}
function copy(source,target) {
  c.fs.mkdirSync(c.path.dirname(target),{recursive:true});
  c.fs.copyFileSync(source,target);c.assert.equal(sha(source),sha(target));
}
for(const entry of manifest.entries) {
  const source=c.path.join(root,entry.path),name=c.path.basename(source);
  const players=entry.pack==='players',double=players?entry.double:name.includes(' Double');
  const color=players?`${String(entry.color).padStart(2,'0')}-${labels[entry.color]}`:originals[name.match(/^Shot (\w+)/)[1]];
  const pack=players?'Colores-de-jugadores':'Colores-originales';
  const type=double?'Misil-doble':'Misil-simple';
  const folder=c.path.join(output,pack,type,color);
  copy(source,c.path.join(folder,name));
  copy(source.replace(/\.mdx$/,'.mdl'),c.path.join(folder,name.replace(/\.mdx$/,'.mdl')));
  const model=c.read(source),textures=[];
  c.assert.equal(model.particleEmitters.length,0,'PE1 model dependencies need a separate inventory');
  for(const texture of model.textures) {
    c.assert.equal(texture.replaceableId,0,'Replaceable texture needs special handling');
    const internal=texture.path;
    c.assert(internal&&!internal.split(/[\\/]/).includes('..'));
    const resource=players?c.path.join(root,'exports/shots-vol-i-jugadores',...internal.split('\\')):stockTexture(internal);
    const target=c.path.join(folder,...internal.split('\\'));
    copy(resource,target);
    textures.push({path:internal,sha256:sha(target),stock:!players});
  }
  const modelPath=(players?'ShotsTeam':'ShotsOriginales')+'\\'+name;
  const note=[`Shots Vol. I / ${type} / ${color}`,'','Modelo para importar: '+name,'Ruta sugerida del modelo en el mapa: '+modelPath,'',
    players?'Importar también las tres BLP de ShotsTeam con las rutas siguientes:':'Estas texturas son internas de Warcraft III 1.27b. Se incluyen copias locales para edición; el juego ya las aporta:',
    ...textures.map(t=>'  '+t.path),'',
    'Las carpetas ShotsTeam/Textures contienen los recursos del modelo. Conservar sus rutas internas.',
    'Las mismas texturas aparecen en otros colores: al importar varios modelos al mismo mapa basta una copia por ruta.',
    'El MDL es fuente editable; no es necesario importarlo al juego.',
    'El evento de sonido usa las tablas internas de Warcraft, sin un archivo de audio externo declarado en el MDX.',
    'Autor original: Vinz. Darle crédito. Derivados con anclaje frontal; MDX800 / Classic 1.27b.',
    'Fuente: https://www.hiveworkshop.com/threads/shots-vol-i.315258/',''];
  c.fs.writeFileSync(c.path.join(folder,'IMPORTAR.txt'),note.join('\n'));
  copy(c.path.join(root,'exports',players?'shots-vol-i-jugadores':'shots-vol-i-anclaje','ORIGINAL-Vinz-readme.html'),c.path.join(folder,'CREDITOS-Vinz.html'));
  entries.push({pack,type,color,folder:c.path.relative(output,folder),model:name,modelImportPath:modelPath,sha256:sha(source),textures});
}
c.assert.equal(entries.filter(e=>e.pack==='Colores-de-jugadores'&&e.type==='Misil-simple').length,12);
c.assert.equal(entries.filter(e=>e.pack==='Colores-de-jugadores'&&e.type==='Misil-doble').length,12);
c.assert.equal(entries.filter(e=>e.pack==='Colores-originales'&&e.type==='Misil-simple').length,6);
c.assert.equal(entries.filter(e=>e.pack==='Colores-originales'&&e.type==='Misil-doble').length,6);
copy(c.path.join(root,'exports/shots-vol-i-jugadores/ShotsTeamPaths.j'),c.path.join(output,'Colores-de-jugadores/ShotsTeamPaths.j'));
copy(c.path.join(root,'assets/palette.json'),c.path.join(output,'Colores-de-jugadores/palette.json'));
for(const pack of ['Colores-de-jugadores','Colores-originales']) {
  const sourcePack=pack==='Colores-de-jugadores'?'shots-vol-i-jugadores':'shots-vol-i-anclaje';
  for(const name of ['VALIDACION.md','VERIFICACION.json'])copy(c.path.join(root,'exports',sourcePack,name),c.path.join(output,pack,name));
}
c.fs.writeFileSync(c.path.join(output,'LEEME.txt'),[
  'Shots Vol. I — colección organizada por tipo y color','',
  'Colores-de-jugadores: 12 colores en Misil-simple y los mismos 12 en Misil-doble.',
  'Colores-originales: 6 colores de Vinz en Misil-simple y los mismos 6 en Misil-doble.',
  'Cada carpeta de color incluye MDX, MDL, sus texturas y rutas de importación.',
  'Se conservaron los bytes de los modelos ya verificados. Esta operación organiza/copias recursos; no cambia geometría, color ni animación.',
  'Los paquetes planos anteriores se conservan como base reproducible. Esta es la colección recomendada para navegar y elegir.',
  'Autor original: Vinz. Fuente: https://www.hiveworkshop.com/threads/shots-vol-i.315258/',''].join('\n'));
c.fs.writeFileSync(c.path.join(output,'manifest.json'),JSON.stringify({models:entries.length,modelBytesUnchanged:true,entries,stock},null,2)+'\n');
console.log(JSON.stringify({output,models:entries.length,playerColorsPerType:12,originalColorsPerType:6,resources:entries.reduce((n,e)=>n+e.textures.length,0),checks:'model/source hashes, resource hashes and counts PASS'}));
