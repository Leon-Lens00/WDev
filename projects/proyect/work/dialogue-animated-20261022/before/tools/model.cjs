// Four billboard quads, MDX800. Text stays outside the model.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const lib='/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/migracion-linux/runtime/node_modules';
const {parseMDX,parseMDL}=require(lib+'/war3-model');
const Model=require(lib+'/mdx-m3-viewer/dist/cjs/parsers/mdlx/model').default;
const root=path.resolve(__dirname,'..'),H=140*809/1942;
const extent=`MinimumExtent { -1, -70, ${-H/2} }, MaximumExtent { 1, 70, ${H/2} }, BoundsRadius 76,`;
const seqs=[['Stand',1,1000],['Stand Alternate',2001,3000],['Birth',4001,4181],['Death',5001,5181]];
let mdl=`Version { FormatVersion 800, }\nModel "Conversation" { NumGeosets 4, NumGeosetAnims 4, BlendTime 0, ${extent} }\nSequences 4 { ${seqs.map(([n,a,b])=>`Anim "${n}" { Interval { ${a}, ${b} }, ${n==='Birth'||n==='Death'?'NonLooping,':''} ${extent} }`).join('\n')} }\n`;
mdl+=`Textures 4 { ${['FrameRed','FrameBlue','PortraitX','PortraitAlia'].map(n=>`Bitmap { Image "UI\\Dialogue\\${n}.blp", }`).join('\n')} }\n`;
mdl+=`Materials 4 { ${[0,1,2,3].map(i=>`Material { PriorityPlane ${i<2?0:1}, Layer { FilterMode Blend, Unshaded, TwoSided, Unfogged, NoDepthTest, NoDepthSet, static TextureID ${i}, static Alpha 1, } }`).join('\n')} }\n`;
const quads=[[0,1,0,1,0],[0,1,0,1,0],[.063,.237,.148,.473,.05],[.766,.940,.148,.473,.05]];
for(let i=0;i<4;i++){
 const [l,r,t,b,x]=quads[i],y1=(l-.5)*140,y2=(r-.5)*140,z1=(.5-t)*H,z2=(.5-b)*H;
 mdl+=`Geoset { Vertices 4 { {${x},${y1},${z1}}, {${x},${y2},${z1}}, {${x},${y2},${z2}}, {${x},${y1},${z2}}, } Normals 4 { {1,0,0}, {1,0,0}, {1,0,0}, {1,0,0}, } TVertices 4 { {0,0}, {1,0}, {1,1}, {0,1}, } VertexGroup { 0,0,0,0, } Faces 1 6 { Triangles { {0,2,1,0,3,2}, } } Groups 1 1 { Matrices {0}, } ${extent} ${seqs.map(()=>`Anim { ${extent} }`).join('\n')} MaterialID ${i}, SelectionGroup 0, }\n`;
 const red=i===0?1:i===1?0:i===2?.55:1,blue=i===0?0:i===1?1:i===2?1:.55;
 const keys=[[1,red],[1000,red],[2001,blue],[3000,blue],[4001,red],[4181,red],[5001,red],[5181,0]];
 mdl+=`GeosetAnim { Alpha ${keys.length} { DontInterp, ${keys.map(([t,a])=>`${t}: ${a},`).join('\n')} } GeosetId ${i}, }\n`;
}
mdl+=`Bone "PanelBillboard" { ObjectId 0, Billboarded, GeosetId Multiple, GeosetAnimId None, Scaling 8 { Linear, 1: {1,1,1},1000:{1,1,1},2001:{1,1,1},3000:{1,1,1},4001:{1,1,0.08},4181:{1,1,1},5001:{1,1,1},5181:{1,1,0.08}, } }\nPivotPoints 1 { {0,0,0}, }\n`;
const out=path.join(root,'assets/UI/Dialogue/Conversation');
const m=new Model();m.loadMdl(mdl);const bytes=Buffer.from(m.saveMdx());
const check=parseMDX(bytes.buffer.slice(bytes.byteOffset,bytes.byteOffset+bytes.byteLength));
const textCheck=parseMDL(mdl);
assert.equal(check.Version,800);assert.equal(check.Geosets.length,4);assert.equal(check.Bones.length,1);
assert.equal(check.Sequences.length,4);assert.equal(check.Textures.length,4);
for(const texture of check.Textures)assert(!texture.Image.includes('\\\\'),'Repeated MPQ separator');
for(let i=0;i<4;i++){assert.deepEqual(check.Geosets[i].Vertices,textCheck.Geosets[i].Vertices);assert.equal(check.Geosets[i].Faces.length,6);}
fs.writeFileSync(out+'.mdl',mdl);fs.writeFileSync(out+'.mdx',bytes);
fs.writeFileSync(path.join(root,'evidence/model.json'),JSON.stringify({version:800,vertices:16,triangles:8,bones:1,sequences:seqs,modelWidth:140,modelHeight:H,bytes:bytes.length,independentRoundtrip:true,textBaked:false},null,2));
console.log('MDX800, 16 vertices, 8 triangles; independent MDX/MDL reads match.');
