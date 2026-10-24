// Adapt copies of original Classic portrait models; keep all original motion.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const base=path.resolve(__dirname,'../../..'),root=path.resolve(__dirname,'..');
const {read,allNodes,dependency}=require(base+'/ModelEditor/src/model.cjs');
const {vec3}=dependency('gl-matrix');
const Camera=dependency('mdx-m3-viewer/dist/cjs/viewer/handlers/mdx/camera').default;
const {cameraPortrait}=require('./portrait-camera.cjs');
const art='/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/dialogue',registry={};
for(const [id,name,idle,talk] of [['paladin','HeroPaladin',1,4],['tauren','Tauren',1,4]]){
 const input=base+`/work/dialogue-animated-20261022/originals/${name}_portrait.mdx`,m=read(input);
 const repair=id==='tauren'?require('./repair-tauren-totem.cjs').repairTotem(m,base+'/work/dialogue-tauren-hud-20261022/Tauren-original-unit.mdx'):null;
 const original=allNodes(m).map(n=>JSON.stringify(n.animations));
 const idleSources=m.sequences.flatMap((s,i)=>/^(stand|portrait)(?:\s|$)/i.test(s.name)&&!/talk/i.test(s.name)?[i]:[]);
 const selected=[idle,talk,...m.sequences.flatMap((s,i)=>i!==idle&&i!==talk&&(/^(stand|portrait)(?:\s|$)/i.test(s.name))?[i]:[])].sort((a,b)=>m.sequences[a].interval[0]-m.sequences[b].interval[0]);
 const variants=[idle,...idleSources.filter(si=>si!==idle)].map(si=>({index:selected.indexOf(si),sourceIndex:si,name:m.sequences[si].name,durationMs:m.sequences[si].interval[1]-m.sequences[si].interval[0]}));
 // Remove only the replaceable team-glow background, not arms/hands/carried props.
 m.geosets=m.geosets.filter(g=>m.materials[g.materialId].layers.some(l=>m.textures[l.textureId]?.replaceableId!==2));
 for(const [i,n] of allNodes(m).entries())assert.equal(JSON.stringify(n.animations),original[i],'Original bone curves unchanged');
 const c=new Camera(m,m.cameras[0]),p=vec3.clone(c.position),t=vec3.clone(c.targetPosition),a=vec3.create(),b=vec3.create();
 c.getTranslation(a,idle,m.sequences[idle].interval[0],0);c.getTargetTranslation(b,idle,m.sequences[idle].interval[0],0);vec3.add(p,p,a);vec3.add(t,t,b);
 const D=vec3.normalize(vec3.create(),vec3.subtract(vec3.create(),p,t)),R=vec3.normalize(vec3.create(),vec3.cross(vec3.create(),[0,0,1],D)),U=vec3.cross(vec3.create(),D,R);
 const details=cameraPortrait(m,{sequenceIndices:selected,camera:c,idle,talk,p,t,D,R,U,fov:c.fieldOfView,near:c.nearClippingPlane,output:root+`/assets/UI/Dialogue/Portraits/${id}.mdx`,preview:art+`/portraits/${id}.mdx`});
 registry[id]={name,idle:selected.indexOf(idle),talk:selected.indexOf(talk),idleVariants:variants.filter(v=>details.sequenceMotion[v.index]>.0001).map(v=>({...v,sourceName:v.name,name:details.sequenceNames[v.index]})),staticIdleVariants:variants.filter(v=>details.sequenceMotion[v.index]<=.0001),sourceIdle:idle,sourceTalk:talk,file:`UI\\Dialogue\\Portraits\\${id}.mdx`,preview:`assets/dialogue/portraits/${id}.mdx`,rawcode:id==='paladin'?'dpa0':'dta0',bust:true,headOnly:false,retainedBodyParts:'original body, arms, hands and carried props; original motion',frozenBodyNodes:[],totemRepair:repair,source:input,...details};
}
fs.writeFileSync(root+'/evidence/portrait-registry.json',JSON.stringify(registry,null,2));fs.writeFileSync(art+'/portraits/registry.json',JSON.stringify(registry,null,2));
console.log('Two original animated portrait copies adapted; all Stand/Portrait variants exported and independent readback passed.');
