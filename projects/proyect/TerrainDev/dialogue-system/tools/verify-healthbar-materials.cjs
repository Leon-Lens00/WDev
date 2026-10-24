// Verify all delivered BLP mips with two existing independent readers.
const {fs,path,assert,dependency}=require('../../../ModelEditor/src/model.cjs');
const crypto=require('node:crypto');
const {BlpImage}=dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image'),war3=dependency('war3-model');
global.ImageData=class{constructor(width,height){this.width=width;this.height=height;this.data=new Uint8ClampedArray(width*height*4);}};
const root=path.resolve(__dirname,'..'),out=path.join(root,'exports/health-bars-v1');
const manifest=JSON.parse(fs.readFileSync(path.join(out,'manifest.json'))),contract=JSON.parse(fs.readFileSync(path.join(out,'healthbars.json')));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),checks=[];
assert.equal(sha(fs.readFileSync(path.join(root,'TerrainDev-Dialogue.w3x'))),manifest.activeMapSha256);
for(const t of manifest.textures){
 const bytes=fs.readFileSync(t.path);assert.equal(sha(bytes),t.sha256);assert.equal(bytes.length,t.bytes);
 assert.equal(bytes.subarray(0,4).toString(),'BLP1');
 assert.deepEqual([4,8,20,24].map(i=>bytes.readUInt32LE(i)),[1,8,4,1]);
 const array=bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength),a=new BlpImage();a.load(array);const b=war3.decodeBLP(array);
 assert(a.width<=512&&a.height<=512);assert.equal(a.width&(a.width-1),0);assert.equal(a.height&(a.height-1),0);
 assert.equal(a.mipmaps(),Math.floor(Math.log2(Math.max(a.width,a.height)))+1);
 let cursor=1180;
 const levels=[];
 for(let level=0;level<a.mipmaps();level++){
  const w=Math.max(1,a.width>>level),h=Math.max(1,a.height>>level);
  assert.equal(bytes.readUInt32LE(28+level*4),cursor);assert.equal(bytes.readUInt32LE(92+level*4),w*h*2);cursor+=w*h*2;
  const p=a.getMipmap(level),q=war3.getBLPImageData({...b,width:w,height:h,mipmaps:[b.mipmaps[level]]},0);
  assert.deepEqual([p.width,p.height],[w,h]);assert.deepEqual(Buffer.from(p.data),Buffer.from(q.data));
  levels.push({width:w,height:h,rgbaSha256:sha(p.data)});
 }
 assert.equal(cursor,bytes.length);
 for(let level=a.mipmaps();level<16;level++){assert.equal(bytes.readUInt32LE(28+level*4),0);assert.equal(bytes.readUInt32LE(92+level*4),0);}
 if(t.name.startsWith('Frame')){
  const role=t.name==='FrameBlue'?contract.player:contract.enemy,p=a.getMipmap(0);
  const [x,y,w,h]=role.portraitRect;assert.equal(p.data[(Math.floor(y+h/2)*a.width+Math.floor(x+w/2))*4+3],0,'Portrait aperture must be clear');assert.equal(p.data[3],0,'Outside corner must be transparent');
  for(const key of ['lifeRect','portraitRect','readoutRect']){const [x,y,w,h]=role[key];assert(x>=0&&y>=0&&w>0&&h>0&&x+w<=a.width&&y+h<=role.contentRect[3]);}
 }
 checks.push({name:t.name,bytes:bytes.length,levels});
}
assert(contract.enemy.lifeRect[3]>contract.player.lifeRect[3]*2);
assert.equal(contract.enemy.contentVMax,448/512);
const result={textures:checks.length,mips:checks.reduce((s,c)=>s+c.levels.length,0),totalBlpBytes:checks.reduce((s,c)=>s+c.bytes,0),independentReaders:true,activeMapUnchanged:true,nativeTested:false,checks};
fs.writeFileSync(path.join(out,'validation.json'),JSON.stringify(result,null,2));
console.log(JSON.stringify({...result,checks:undefined},null,2));
