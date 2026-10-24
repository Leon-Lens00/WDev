import { test } from 'node:test'
import assert from 'node:assert/strict'
import { resolvePreviewSource, modelPaths, transformedBounds, previewCamera, defaultPose, imageSize } from '../../frontend/src/model-preview-contract.ts'

const tree={creation_number:7,type_id:'TREE',position:[500,-700,128],rotation:Math.PI/2,scale:[2,1,3],variation:2}
const types={TREE:{file:'Custom/Tree.mdl',num_var:4,model_scale:0.5,max_pitch:-Math.PI/2}}

test('placed preview resolves actual variation and preserves transform without mutating source',()=>{
  const original=JSON.stringify(tree)
  const s=resolvePreviewSource({kind:'doodad',id:7},[tree],types)
  assert.equal(s.paths[0],'Custom/Tree2.mdl')
  assert.deepEqual(s.scale,[1,.5,1.5])
  assert.deepEqual(s.position,tree.position)
  assert.ok(Math.abs(Math.hypot(...s.rotation)-1)<1e-10)
  assert.notDeepEqual(s.rotation,[0,0,0,1])
  assert.equal(JSON.stringify(tree),original)
})
test('normalized preview explicitly removes placement scale and orientation',()=>{
  const s=resolvePreviewSource({kind:'doodad',id:7,transform:'normalized'},[tree],types)
  assert.deepEqual(s.scale,[1,1,1])
  assert.deepEqual(s.rotation,[0,0,0,1])
  assert.equal(s.variation,2)
})
test('unknown objects and ambiguous or external asset paths fail rather than loading a different resource',()=>{
  assert.throws(()=>resolvePreviewSource({kind:'doodad',id:8},[tree],types),/not found/)
  assert.throws(()=>resolvePreviewSource({kind:'doodad',id:7,model_path:'Tree.mdx'},[tree],types),/OR/)
  for(const p of ['https://example.com/a.mdx','C:/models/a.mdx','../a.mdx','/a.mdx']) assert.throws(()=>modelPaths(p))
  assert.deepEqual(modelPaths('Custom\\Tree.mdx',1,2),['Custom/Tree1.mdx','Custom/Tree.mdx','Custom/Tree.mdl','Custom/Tree1.mdl'])
})
test('bounds are recentered in model coordinates with transformed model center and conservative scale',()=>{
  const source=resolvePreviewSource({kind:'doodad',id:7},[tree],{TREE:{file:'tree',model_scale:1}})
  const b=transformedBounds({x:10,y:0,z:0,r:20},source)
  const center=b.min.map((v,i)=>(v+b.max[i])/2)
  assert.ok(Math.abs(center[0])<1e-8)
  assert.ok(Math.abs(center[1]-20)<1e-8)
  assert.equal(b.max[2]-b.min[2],120)
  assert.ok(b.max[0]<500,'placement world translation must not leak into isolated bounds')
})
test('isolated views support exact poles, zoom and atomic input rejection',()=>{
  const original={...defaultPose}
  const bounds={min:[-100,-100,0],max:[100,100,600]}
  const pose=previewCamera(original,{view:'top',projection:'orthographic'},bounds,1)
  assert.equal(pose.pitch,Math.PI/2)
  assert.equal(pose.projection,'orthographic')
  assert.ok(pose.ortho_height>=200)
  assert.throws(()=>previewCamera(original,{view:'top',yaw:1},bounds,1),/OR/)
  assert.throws(()=>previewCamera(original,{distance:0},bounds,1))
  assert.throws(()=>previewCamera(original,{unexpected:1},bounds,1))
  assert.deepEqual(original,defaultPose)
  assert.throws(()=>imageSize(4096))
  assert.throws(()=>imageSize(200.5))
})

