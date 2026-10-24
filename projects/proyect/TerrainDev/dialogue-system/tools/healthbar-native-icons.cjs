// Resolve native Art by rawcode, preserving Classic patch/expansion/base order.
const {fs,path,assert,dependency}=require('../../../ModelEditor/src/model.cjs');
const {spawnSync}=require('node:child_process'),crypto=require('node:crypto');
const {BlpImage}=dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image');
global.ImageData=class{constructor(w,h){this.width=w;this.height=h;this.data=new Uint8ClampedArray(w*h*4);}};
const root=path.resolve(__dirname,'..'),out=path.join(root,'exports/health-bars-horizontal-v1/sources/native');fs.mkdirSync(out,{recursive:true});
const game='/home/snz/Documentos/ChatGPT/FrozenThone/games/WarcraftIII-1.27b',cli='/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py';
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function resource(internal){
 const file=path.join(out,internal.replaceAll('\\','_'));
 for(const archive of ['War3Patch.mpq','War3xlocal.mpq','War3x.mpq','war3.mpq']){
  const source=path.join(game,archive);if(!fs.existsSync(source))continue;
  const r=spawnSync('python3',[cli,'wc3ctl','extract',source,internal,'-o',file,'--json'],{encoding:'utf8'});
  if(r.status===0&&fs.existsSync(file))return {file,archive:source,internal,sha256:sha(fs.readFileSync(file))};
 }
 throw Error('Native resource absent: '+internal);
}
const registry={};
for(const [id,rawcode,table,name] of [['paladin','Hpal','Human','Paladín'],['tauren','otau','Orc','Tauren']]){
 const data=resource('Units\\'+table+'UnitFunc.txt'),text=fs.readFileSync(data.file,'utf8');
 const section=text.split('['+rawcode+']')[1]?.split('[')[0];assert(section,rawcode);
 const internal=section.match(/^Art=(.+)$/m)[1].trim().split(',')[0],icon=resource(internal),bytes=fs.readFileSync(icon.file),a=new BlpImage();
 a.load(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));const mip=a.getMipmap(0);assert(a.width<=512&&a.height<=512);
 const texture='Native'+(id==='paladin'?'Paladin':'Tauren'),raw=path.join(out,texture+'.rgba'),png=path.join(out,texture+'.png');fs.writeFileSync(raw,mip.data);
 const python=path.resolve(root,'../../work/shots-vol-i-origen-20261022/plot-env/bin/python');
 const r=spawnSync(python,['-c','from PIL import Image; import sys; Image.frombytes("RGBA",(int(sys.argv[1]),int(sys.argv[2])),open(sys.argv[3],"rb").read()).save(sys.argv[4])',String(mip.width),String(mip.height),raw,png],{encoding:'utf8'});assert.equal(r.status,0,r.stderr);
 registry[id]={name,rawcode,texture,nativePath:internal,width:a.width,height:a.height,png,icon,objectData:data};
}
fs.writeFileSync(path.join(out,'icons.json'),JSON.stringify(registry,null,2)+'\n');console.log(JSON.stringify(registry,null,2));
