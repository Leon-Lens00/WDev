// Isolated portrait photograph inputs; replace engine-generated team textures only.
const {fs,path,read,save}=require('../../../ModelEditor/src/model.cjs');
const crypto=require('node:crypto');
const root=path.resolve(__dirname,'..'),out=path.join(root,'exports/health-bars-v1');
const studio='/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/healthbars/source';
fs.mkdirSync(studio,{recursive:true});
const provenance=[];
for(const [id,name] of [['paladin','HeroPaladin'],['tauren','Tauren']]){
 const source=path.resolve(studio,'../../dialogue/source',name+'_portrait.mdx');
 const bytes=fs.readFileSync(source),model=read(source);
 for(const t of model.textures){
  if(t.replaceableId===1)t.path='PortraitTeamColor.blp';
  else if(t.replaceableId===2)t.path='Black.blp';
  else t.path=t.path.split(/[\\/]/).at(-1);
  t.replaceableId=0;
 }
 save(model,path.join(studio,id+'.mdx'));
 provenance.push({id,source,sha256:crypto.createHash('sha256').update(bytes).digest('hex'),changes:'Only TEXS replaceable IDs/paths. TeamColor uses existing red; TeamGlow uses black (additive zero). Geometry, animation and cameras retained.'});
}
for(const n of ['Heropaladin','Minotaur'])fs.copyFileSync(path.join(root,'assets/UI/Dialogue/Portraits',n+'.blp'),path.join(studio,n+'.blp'));
fs.copyFileSync(path.join(root,'assets/UI/Dialogue/PortraitTeamColor.blp'),path.join(studio,'PortraitTeamColor.blp'));
fs.mkdirSync(path.join(out,'sources'),{recursive:true});
fs.writeFileSync(path.join(out,'sources/portrait-provenance.json'),JSON.stringify(provenance,null,2));
console.log('Original camera/rig copies ready for static photographs.');
