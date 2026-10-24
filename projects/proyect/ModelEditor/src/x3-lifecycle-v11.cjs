// Flight and impact are distinct. Origin stays fixed; only local pieces expand.
module.exports=function lifecycle(m,k){
 const {c,track,v3,bone,glow,mesh,quad}=k;
 const remap=t=>Math.round(t<=160?t*300/160:t<=200?300+(t-160)*2.5:t<=1160?t+200:t<=1300?1360+(t-1160):1500+(t-1300)*1000/420);
 const objects=[...m.bones,...m.helpers,...m.particleEmitters2,...m.ribbonEmitters,...m.geosetAnimations,...m.textureAnimations,...m.materials.flatMap(x=>x.layers)];
 for(const obj of objects)for(const a of obj.animations||[])if(a.globalSequenceId===-1)a.frames=Array.from(a.frames,remap);
 [[0,300],[400,1360],[1500,2500]].forEach((v,i)=>m.sequences[i].interval=Uint32Array.from(v));
 m.bones[0].animations=[];
 const flightCount=m.geosets.length,flightEmitters=m.particleEmitters2.length;
 const body=bone(m,'Flight body: Birth extension, no Death contraction',[0,0,0]);
 // Flight emitters follow the same Birth extension, avoiding detached rear dots.
 for(const n of [...m.bones,...m.particleEmitters2,...m.ribbonEmitters])if(n.objectId!==0&&n.objectId!==body&&n.parentId===0)n.parentId=body;
 m.bones.at(-1).animations=[track('Vector3Animation','KGSC',[0,80,180,300,400,1360,1500,2500],[[.12,.35,.35],[.40,.8,.8],[.85,1.05,1.05],[1,1,1],[1,1,1],[1,1,1],[1,1,1],[1,1,1]])];
 for(let i=0;i<flightCount;i++){
  const g=m.geosets[i];g.matrixIndices=Uint32Array.from([body]);
  const ga=m.geosetAnimations[i],a=ga.animations.find(a=>a.name==='KGAO'),frames=[],values=[];
  const peak=Math.max(...a.values.map(v=>v[0]));
  if(i<43){frames.push(0,60,180,300);values.push(0,peak*.7,peak,peak);}
  else {frames.push(0,300);values.push(0,0);}
  for(let j=0;j<a.frames.length;j++)if(a.frames[j]>=400&&a.frames[j]<=1360){frames.push(a.frames[j]);values.push(a.values[j][0]);}
  frames.push(1500,1540,1590,2500);values.push(i<43?peak:0,i<43?peak*.55:0,0,0);
  ga.animations=[track('FloatAnimation','KGAO',frames,values)];
 }
 // Shared geometric flash is deterministic, unlike a burst that may miss a tick.
 const impactBone=bone(m,'Impact expansion centered on tip',[0,0,0]);
 m.bones.at(-1).animations=[track('Vector3Animation','KGSC',[0,1360,1500,1530,1610,1770,2000,2500],[[0,0,0],[0,0,0],[.22,.22,.22],[1,1,1],[1.5,1.5,1.5],[2,2,2],[2.4,2.4,2.4],[2.4,2.4,2.4]])];
 const impactGeosets=[];
 function impactAlpha(start,values){for(let i=start;i<m.geosets.length;i++){impactGeosets.push(i);m.geosetAnimations[i].animations=[track('FloatAnimation','KGAO',[0,300,400,1360,1500,1530,1610,1770,2000,2500],[0,0,0,0,...values])];}}
 let start=m.geosets.length;glow(m,[0,0,0],21,21,[.10,.50,1],.8,impactBone);impactAlpha(start,[.5,.85,.65,.18,0,0]);
 start=m.geosets.length;
 const star=m.materials.length,Material=c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/material').default,Layer=c.dependency('mdx-m3-viewer/dist/cjs/parsers/mdlx/layer').default;
 const mat=new Material(),layer=new Layer();layer.flags=17;layer.filterMode=4;layer.textureId=m.textures.findIndex(t=>t.path.endsWith('star5tga.blp'));mat.layers.push(layer);m.materials.push(mat);
 for(let j=0;j<3;j++){const a=j*Math.PI/3;mesh(m,quad([0,0,0],[24,0,0],[0,24*Math.cos(a),24*Math.sin(a)]),[.65,.88,1],1,star,impactBone);}
 impactAlpha(start,[.8,1,.55,0,0,0]);
 // Original Shot II Death emitters, independently loaded to preserve its ramps.
 const ref=c.path.join(k.root,'../descargas/warcraft3/misiles/vinz/biblioteca-originales/01-Energia-y-plasma/shots-vol-ii.315512/originales/Shots Vol. II/Shot II Blue.mdx');
 const source=c.read(ref),front=bone(m,'Impact forward direction',[0,0,0]);
 m.bones.at(-1).animations=[track('Vector4Animation','KGRT',[0,2500],Array(2).fill([0,Math.SQRT1_2,0,Math.SQRT1_2]))];
 const burstSpecs=[['Stars',.55,.60,90,40,240],['Lumps',.38,.65,65,50,280],['Flashes',.65,.70,75,40,280],['Avante Uno',.50,.55,80,0,160]],bursts=[];
 for(const [name,size,speed,rate,on,off] of burstSpecs){
  const p=source.particleEmitters2.find(p=>p.name===name);c.assert(p,'Reference Death emitter '+name);
  const texture=source.textures[p.textureId].path.split('\\').at(-1);p.textureId=m.textures.findIndex(t=>t.path.split('\\').at(-1)===texture);c.assert(p.textureId>=0);
  p.name='Impact / Shot II '+name;p.objectId=m.pivotPoints.length;p.parentId=name==='Avante Uno'?front:0;p.flags=0x9000;p.width=p.length=0;
  p.segmentScaling=v3(Array.from(p.segmentScaling,x=>x*size));p.segmentAlphas[2]=0;p.speed=Math.fround(p.speed*speed);p.emissionRate=0;
  p.animations=[track('FloatAnimation','KP2E',[0,1360,1500,...(on?[1500+on]:[]),1500+off,2500],[0,0,on?0:rate,...(on?[rate]:[]),0,0],0)];
  m.particleEmitters2.push(p);m.pivotPoints.push(v3([0,0,0]));bursts.push({name:p.name,on,off,lifeMs:p.lifeSpan*1000,size:Array.from(p.segmentScaling),rate});
 }
 // Birth flash establishes a single projectile rather than a miniature impact.
 const birthBone=bone(m,'Birth local corona',[0,0,0]);m.bones.at(-1).animations=[track('Vector3Animation','KGSC',[0,50,150,300,400,2500],[[.15,.15,.15],[1,1,1],[1.4,1.4,1.4],[1.6,1.6,1.6],[0,0,0],[0,0,0]])];
 start=m.geosets.length;glow(m,[0,0,0],11,11,[.40,.70,1],.8,birthBone);
 for(let i=start;i<m.geosets.length;i++)m.geosetAnimations[i].animations=[track('FloatAnimation','KGAO',[0,35,100,220,300,400,1360,1500,2500],[0,.9,.6,0,0,0,0,0,0])];
 return {birthMs:300,standMs:960,deathMs:1000,flightCount,flightEmitters,bodyFadeMs:90,bodyDeathScale:[1,1,1],impactGeosets,bursts,reference:c.path.relative(k.root,ref),root:'fixed at origin in every sequence',death:'flight fades in 90 ms; local flash expands; four reference-derived PE2 bursts decay independently'};
};
