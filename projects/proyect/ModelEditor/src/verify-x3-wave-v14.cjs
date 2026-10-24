// Validate actual exported animation tracks, including the global clock.
module.exports=(k,build)=>{
 const {c}=k,e=build.entries.find(e=>e.name==='X3_Cross_Buster'),m=c.read(c.path.join(k.root,e.path)),before=c.read(build.sourceCross.path);
 const w=build.details.X3_Cross_Buster.waves;
 c.assert.deepEqual(m.globalSequences,[400]);
 for(let i=0;i<61;i++){
  for(const key of ['vertices','faces','uvSets','materialId'])c.assert.deepEqual(c.plain(m.geosets[i][key]),c.plain(before.geosets[i][key]),'preserved body '+key+' '+i);
  c.assert.deepEqual(c.plain(m.geosetAnimations[i]),c.plain(before.geosetAnimations[i]),'preserved body/impact opacity '+i);
 }
 for(const n of before.bones.filter(b=>b.name!=='Fused green loops local roll')){
  const b=m.bones.find(b=>b.name===n.name);c.assert(b);c.assert.deepEqual(c.plain(b.animations),c.plain(n.animations));c.assert.deepEqual(m.pivotPoints[b.objectId],before.pivotPoints[n.objectId]);
 }
 function scalar(o,key,si,time,clock){const v=new Float32Array(1);new c.Generic(m,o,0).getScalarValue(v,key,si,time,clock,1);return v[0];}
 const waves=w.records.map(r=>({...r,node:m.bones.find(b=>b.name===r.boneName)}));
 function state(wave,clock){const g=new c.Generic(m,wave.node,0),p=new Float32Array(3),s=new Float32Array(3);g.getTranslation(p,1,600,clock);g.getScale(s,1,600,clock);const mat=m.materials[m.geosets[wave.geosets[0]].materialId];return {x:p[0],r:s[1],alpha:scalar(mat.layers[0],'KMTA',1,600,clock)};}
 const timeline=[];
 for(let t=0;t<=400;t+=5){
  const a=state(waves[0],t),b=state(waves[1],t+200);for(const key of ['x','r','alpha'])c.assert(Math.abs(a[key]-b[key])<1e-4,'200ms phase shift '+key);
  timeline.push({t,...a});
  for(let si=0;si<3;si++){
   const frame=si===0?180:si===1?600:1650,p=c.pose(m,si,frame,t);c.assert.deepEqual(p.anchors[0],[0,0,0]);
   for(const wave of waves)for(const id of wave.geosets){for(const v of p.points[id]){c.assert(v[0]<=.001,'wave passes tip');for(let d=0;d<3;d++)c.assert(v[d]>=m.extent.min[d]&&v[d]<=m.extent.max[d]);}if(si===2)c.assert.equal(scalar(m.geosetAnimations[id],'KGAO',si,frame,t),0);}
  }
 }
 c.assert(state(waves[0],0).r<state(waves[0],80).r);c.assert(state(waves[0],80).r>state(waves[0],260).r);
 c.assert.equal(state(waves[0],300).alpha,0);c.assert(state(waves[0],300).r>5,'fade before closure');
 for(let t=5;t<300;t+=5)c.assert(state(waves[0],t).x<state(waves[0],t-5).x);
 const copied=build.entries.filter(e=>e.preservedV13);c.assert.equal(copied.length,5);
 c.fs.writeFileSync(c.path.join(k.ev,'wave-verification.json'),JSON.stringify({status:'PASS',bodyGeosetsUnchanged:61,unchangedOtherModels:copied.length,wavesEveryMs:200,globalClockMs:400,rootFixed:true,fadeBeforeClosure:true,radiusAtFade:state(waves[0],300).r,globalPosesChecked:243,timeline},null,2));
};
