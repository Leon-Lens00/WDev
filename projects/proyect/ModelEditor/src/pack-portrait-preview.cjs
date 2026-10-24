const {fs,path,read}=require('./model.cjs');
const root=path.resolve(__dirname,'..'),out=path.join(root,'viewer/portraits-optimized'),evidence=path.join(root,'evidence/portrait-keys-20261022');
fs.mkdirSync(path.join(out,'models'),{recursive:true});fs.mkdirSync(path.join(out,'textures'),{recursive:true});
const manifest=JSON.parse(fs.readFileSync(path.join(evidence,'metrics.json')));
for(const m of manifest.models){fs.copyFileSync(path.join(evidence,'baseline',m.id+'.mdx'),path.join(out,'models',m.id+'-before.mdx'));for(const c of m.candidates.filter(c=>[.02,.05,.1].includes(c.tolerance)))fs.copyFileSync(c.path,path.join(out,'models',m.id+'-'+c.tolerance+'.mdx'));}
for(const t of manifest.textures)fs.copyFileSync(path.join(root,'../TerrainDev/dialogue-system/assets',t.path),path.join(out,'textures',path.basename(t.path)));
for(const file of ['viewer.min.js','grid.js','LICENSE-mdx-m3-viewer.txt'])fs.copyFileSync(path.join(root,'viewer/x3',file),path.join(out,file));
fs.copyFileSync(path.join(__dirname,'portrait-preview.html'),path.join(out,'index.html'));fs.copyFileSync(path.join(__dirname,'portrait-preview.js'),path.join(out,'app.js'));
fs.copyFileSync(path.join(evidence,'metrics.json'),path.join(out,'metrics.json'));
fs.writeFileSync(path.join(out,'LEEME.md'),'# Comparación de retratos\n\nServir esta carpeta: `python -m http.server 8765 --bind 127.0.0.1`. Abrir http://127.0.0.1:8765/. Arrastrar para orbitar, rueda para zoom, selector de secuencias y tolerancias. MDX/BLP reales; izquierda adaptación actual, derecha candidata. Tabla con bytes del original Warcraft. Sin prueba de motor. No modifica mapa ni UI Studio.\n');
console.log(out);
