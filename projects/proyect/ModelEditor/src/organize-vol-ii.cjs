const c=require('./model.cjs'),v=require('./vol-ii.cjs');
const {spawnSync}=require('node:child_process');
const output=c.path.join(v.root,'exports/shots-vol-ii-organizados');
const build=JSON.parse(c.fs.readFileSync(c.path.join(v.evidence,'build-manifest.json')));
const labels=['Rojo','Azul','Cian','Purpura','Amarillo','Naranja','Verde','Rosa','Gris-claro','Azul-claro','Verde-oscuro','Marron'];
const originalLabels={Blue:'Azul',Green:'Verde',Orange:'Naranja',Purple:'Purpura',Red:'Rojo',Yellow:'Amarillo'};
const game='/home/snz/Documentos/ChatGPT/FrozenThone/games/WarcraftIII-1.27b';
const cli='/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py';
const cache=c.path.join(v.root,'assets/recursos-originales');
c.assert(!c.fs.existsSync(output),'Choose a new destination instead of overwriting a reviewed collection');
function copy(src,dst){c.fs.mkdirSync(c.path.dirname(dst),{recursive:true});c.fs.copyFileSync(src,dst);c.assert.equal(v.sha(src),v.sha(dst));}
const resources=[];
function stock(internal) {
  const target=c.path.join(cache,...internal.split('\\'));
  if(c.fs.existsSync(target))return target;
  c.fs.mkdirSync(c.path.dirname(target),{recursive:true});
  for(const name of ['War3Patch.mpq','War3xlocal.mpq','War3x.mpq','war3.mpq']) {
    const archive=c.path.join(game,name);if(!c.fs.existsSync(archive))continue;
    const r=spawnSync('python',[cli,'wc3ctl','extract',archive,internal,'-o',target,'--json'],{encoding:'utf8'});
    if(r.status===0&&c.fs.existsSync(target)){resources.push({internal,archive,sha256:v.sha(target)});return target;}
  }
  throw new Error('Missing Classic texture '+internal);
}
const entries=[];
for(const entry of build.entries) {
  const players=entry.pack==='players',pack=players?'Colores-de-jugadores':'Colores-originales';
  const color=players?`${String(entry.color).padStart(2,'0')}-${labels[entry.color]}`:originalLabels[entry.source.match(/^Shot II (\w+)/)[1]];
  const folder=c.path.join(output,pack,'Misil-simple',color),file=c.path.join(v.root,entry.path),name=c.path.basename(file);
  c.assert.equal(v.sha(file),entry.sha256);copy(file,c.path.join(folder,name));copy(file.replace(/\.mdx$/,'.mdl'),c.path.join(folder,name.replace(/\.mdx$/,'.mdl')));
  const m=c.read(file),textures=[];
  for(const t of m.textures) {
    c.assert.equal(t.replaceableId,0);const src=players?c.path.join(v.players,...t.path.split('\\')):stock(t.path);
    const target=c.path.join(folder,...t.path.split('\\'));copy(src,target);
    textures.push({path:t.path,sha256:v.sha(target),stock:!players});
  }
  copy(c.path.join(v.source,'readme.html'),c.path.join(folder,'CREDITOS-Vinz.html'));
  const modelImportPath=(players?'ShotsVolII':'ShotsVolIIOriginales')+'\\'+name;
  c.fs.writeFileSync(c.path.join(folder,'IMPORTAR.txt'),[
    'Shots Vol. II de Vinz — Classic 1.27b / MDX800','',
    'Forma simple, conservada según la elección del usuario. Punta geométrica frontal en X=0.',
    'Modelo: '+name,'Ruta sugerida del modelo: '+modelImportPath,'',
    players?'Importar las tres BLP con estas rutas exactas:':'Texturas internas de Warcraft incluidas para edición local (el juego ya las aporta):',
    ...textures.map(t=>'  '+t.path),'',
    'Conservar las rutas ShotsVolII/Textures según corresponda. Para varios colores basta una copia de cada textura por ruta en el mapa.',
    'MDL = fuente editable opcional; no hace falta importarlo al mapa.',
    'El sonido se resuelve mediante las tablas internas del juego; el MDX no declara un WAV externo.',
    'Los halos/partículas pueden expandirse alrededor del origen. La colisión depende del sistema del mapa.',
    'Dar crédito al autor original Vinz. Fuente: https://www.hiveworkshop.com/threads/shots-vol-ii.315512/',''].join('\n'));
  entries.push({pack,color,type:'Misil-simple',folder:c.path.relative(output,folder),model:name,modelImportPath,sha256:v.sha(file),textures});
}
c.assert.equal(entries.length,18);c.assert.equal(entries.filter(e=>e.pack==='Colores-de-jugadores').length,12);
const helper=['// Shots Vol. II by Vinz. Classic 1.27b. Resolve at launch by assigned player color.','function ShotsVolIIPath takes playercolor color returns string'];
for(const color of v.palette)helper.push(`    if color == ConvertPlayerColor(${color.index}) then`,`        return "ShotsVolII\\\\ShotII_${String(color.index).padStart(2,'0')}_${color.name}.mdx"`,'    endif');
helper.push('    return "ShotsVolII\\\\ShotII_08_LightGray.mdx"','endfunction','','function ShotsVolIIPlayerPath takes player owner returns string','    return ShotsVolIIPath(GetPlayerColor(owner))','endfunction','');
c.fs.writeFileSync(c.path.join(output,'Colores-de-jugadores/ShotsVolIIPaths.j'),helper.join('\n'));
copy(c.path.join(v.root,'assets/palette.json'),c.path.join(output,'Colores-de-jugadores/palette.json'));
for(const pack of ['Colores-de-jugadores','Colores-originales'])copy(c.path.join(v.evidence,'verification.json'),c.path.join(output,pack,'VERIFICACION.json'));
c.fs.writeFileSync(c.path.join(output,'LEEME.txt'),[
  'Shots Vol. II — modelos organizados','',
  'Colores-originales/Misil-simple: 6 colores originales con anclaje frontal ajustado.',
  'Colores-de-jugadores/Misil-simple: 12 colores Classic, derivados del mismo Blue ajustado.',
  'Cada color incluye MDX, MDL, texturas, créditos y rutas de importación.',
  'Vol. II publica sólo forma simple. Se conservó esa forma por elección expresa del usuario.',
  'El pack de jugadores usa rutas exclusivas ShotsVolII para coexistir con Vol. I.',
  'Helper opcional: ShotsVolIIPlayerPath(GetOwningPlayer(caster)) devuelve la ruta a usar al lanzar.',
  'No se integró con un sistema de colisiones ni se usan APIs Blz. Neutral desconocido: gris claro.',
  'Los originales descargados están intactos en descargas/warcraft3/misiles/vinz/shots-vol-ii.',
  'Autor original: Vinz. Darle crédito. https://www.hiveworkshop.com/threads/shots-vol-ii.315512/',''].join('\n'));
c.fs.writeFileSync(c.path.join(output,'manifest.json'),JSON.stringify({source:v.manifest.source,models:entries.length,onlySimple:true,entries,newStockExtractions:resources},null,2)+'\n');
console.log(JSON.stringify({output,models:18,originalColors:6,playerColors:12,textureCopies:entries.reduce((n,e)=>n+e.textures.length,0),hashes:'PASS'}));
