// Independent BLP readers verify every candidate mip without changing active assets.
const {fs,path,assert,dependency}=require('../../../ModelEditor/src/model.cjs');
const crypto=require('node:crypto');
const {BlpImage}=dependency('mdx-m3-viewer/dist/cjs/parsers/blp/image');
const war3=dependency('war3-model');
// CPU pixel container used by the unmodified readers; no canvas/WebGL simulation.
global.ImageData=class{constructor(width,height){this.width=width;this.height=height;this.data=new Uint8ClampedArray(width*height*4);}};
const root=path.resolve(__dirname,'..'),evidence=path.join(root,'evidence/panel-textures-512');
const manifest=JSON.parse(fs.readFileSync(path.join(evidence,'manifest.json')));
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
function readers(bytes){const array=bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength),mdx=new BlpImage();mdx.load(array);return {mdx,other:war3.decodeBLP(array)};}
const checks=[];
for(const t of manifest.textures){
 const active=fs.readFileSync(t.source);assert.equal(sha(active),t.sourceSha256);
 const before=readers(active);
 for(const c of t.candidates){
  const data=fs.readFileSync(c.path);assert.equal(sha(data),c.sha256);
  const {mdx,other}=readers(data);assert(mdx.width<=512&&mdx.height<=512);assert.equal(mdx.alphaBits,8);
  assert.equal(mdx.mipmaps(),Math.floor(Math.log2(Math.max(mdx.width,mdx.height)))+1);
  const levels=[];
  for(let level=0;level<mdx.mipmaps();level++){
   const w=Math.max(1,mdx.width>>level),h=Math.max(1,mdx.height>>level),pixels=mdx.getMipmap(level);
   assert.equal(pixels.width,w);assert.equal(pixels.height,h);
   // war3-model does not clamp rectangular terminal dimensions. Decode the
   // already parsed subresource at its actual dimensions rather than a fraction.
   const otherPixels=war3.getBLPImageData({...other,width:w,height:h,mipmaps:[other.mipmaps[level]]},0);
   assert.deepEqual(Buffer.from(pixels.data),Buffer.from(otherPixels.data),'Independent RGBA mismatch');
   if(c.size==='512x256')assert.deepEqual(Buffer.from(pixels.data),Buffer.from(before.mdx.getMipmap(level+1).data),'Promoted mip changed');
   levels.push({width:w,height:h,rgbaSha256:sha(pixels.data)});
  }
  assert.deepEqual([levels.at(-1).width,levels.at(-1).height],[1,1]);
  checks.push({name:t.name,size:c.size,bytes:data.length,levels,independentReaders:true});
 }
}
const result={checks,allActiveTexturesUnchanged:true,gameTested:false};
fs.writeFileSync(path.join(evidence,'validation.json'),JSON.stringify(result,null,2));
console.log(JSON.stringify({candidates:checks.length,mips:checks.reduce((s,c)=>s+c.levels.length,0),...result,checks:undefined},null,2));
