import { cameraBasis, defaultPose, frameBounds, normalizePose, type CameraPose, type ViewPreset } from './camera-pose'

export type PreviewSource = {
  paths: string[]; kind: string; id?: number; type_id?: string; variation?: number
  position?: number[]; scale: number[]; rotation: number[]
  team_color: number; vertex_color?: number[]; transform: 'placed' | 'normalized'
  warnings: string[]
}
type Placement = { creation_number: number; type_id: string; position: number[]; rotation: number; scale: number[]; variation?: number; player?: number }
type Definition = { file: string; num_var?: number; model_scale?: number; max_pitch?: number; max_roll?: number; red?: number; green?: number; blue?: number }

export function keys(args: Record<string, unknown>, allowed: string[]) {
  for (const k of Object.keys(args)) if (!allowed.includes(k)) throw new Error('Unknown model preview argument: '+k)
}
export function finite(value: unknown, name: string, min: number, max: number): number {
  if (typeof value !== 'number' || !Number.isFinite(value) || value < min || value > max) throw new Error(name+' must be '+min+'..'+max)
  return value
}
export function imageSize(value: unknown = 768): number {
  const n = finite(value, 'image dimension', 128, 2048)
  if (!Number.isInteger(n)) throw new Error('image dimension must be an integer')
  return n
}
export function modelPaths(file: string, variation?: number, count = 1): string[] {
  const path = file.replace(/\\/g, '/')
  if (!path || path.startsWith('/') || path.includes(':') || path.split('/').includes('..')) throw new Error('model_path must be a map/game asset path, not a URL or disk path')
  const ext = path.match(/\.(mdx|mdl)$/i)?.[0] ?? '.mdx'
  const stem = /\.(mdx|mdl)$/i.test(path) ? path.slice(0,-4) : path
  const other = ext.toLowerCase() === '.mdx' ? '.mdl' : '.mdx'
  const v = variation !== undefined && count > 1 ? Math.min(Math.max(0,variation), count-1) : undefined
  return [...new Set([...(v === undefined ? [] : [stem+v+ext]), stem+ext, stem+other, ...(v === undefined ? [] : [stem+v+other])])]
}
function multiply(a: number[], b: number[]): number[] {
  const [x,y,z,w]=a, [X,Y,Z,W]=b
  return [w*X+x*W+y*Z-z*Y, w*Y-x*Z+y*W+z*X, w*Z+x*Y-y*X+z*W, w*W-x*X-y*Y-z*Z]
}
export function resolvePreviewSource(args: Record<string, unknown>, placements: Placement[], definitions: Record<string, Definition>): PreviewSource {
  keys(args, ['kind','id','model_path','transform','width','height'])
  const transform = args.transform ?? 'placed'
  if (transform !== 'placed' && transform !== 'normalized') throw new Error('invalid transform')
  if (args.model_path !== undefined) {
    if (args.kind !== undefined || args.id !== undefined || typeof args.model_path !== 'string') throw new Error('Use model_path OR kind and id')
    return {paths:modelPaths(args.model_path), kind:'asset', scale:[1,1,1], rotation:[0,0,0,1], team_color:0, transform:'normalized', warnings:[]}
  }
  if (!['doodad','unit'].includes(args.kind as string) || !Number.isInteger(args.id)) throw new Error('Specify kind (doodad/unit) and id (creation_number), or model_path')
  const p = placements.find(p=>p.creation_number === args.id)
  if (!p) throw new Error('Placed element not found')
  const d = definitions[p.type_id]
  if (!d?.file) throw new Error('Selected element has no resolved model definition')
  const normalized = transform === 'normalized'
  let q = normalized ? [0,0,0,1] : [0,0,Math.sin(p.rotation/2),Math.cos(p.rotation/2)]
  if (!normalized && (d.max_pitch ?? 0) < 0) q=multiply(q,[0,Math.sin(-d.max_pitch!/2),0,Math.cos(-d.max_pitch!/2)])
  if (!normalized && (d.max_roll ?? 0) < 0) q=multiply(q,[Math.sin(-d.max_roll!/2),0,0,Math.cos(-d.max_roll!/2)])
  const scale = normalized ? [1,1,1] : p.scale.map(s=>(s || 1)*(d.model_scale || 1))
  if (scale.length!==3 || [...scale,...q].some(n=>!Number.isFinite(n))) throw new Error('Invalid placement transform')
  return {paths:modelPaths(d.file,p.variation,d.num_var),kind:args.kind as string,id:p.creation_number,type_id:p.type_id,
    variation:p.variation,position:[...p.position],scale,rotation:q,team_color:p.player??0,transform,
    vertex_color:args.kind==='unit'?[d.red??255,d.green??255,d.blue??255]:undefined,
    warnings:(d.max_pitch??0)>0 || (d.max_roll??0)>0 ? ['Terrain-dependent tilt is not reproduced by this isolated preview.'] : []}
}
export function transformedBounds(bounds: {x?:number;y?:number;z?:number;r?:number}, source: PreviewSource) {
  const r = bounds?.r && Number.isFinite(bounds.r) && bounds.r>0 ? bounds.r : 200
  const c = [bounds?.x??0,bounds?.y??0,bounds?.z??0].map((v,i)=>v*source.scale[i])
  const q=source.rotation, p=multiply(multiply(q,[...c,0]),[-q[0],-q[1],-q[2],q[3]])
  const radius = r*Math.max(...source.scale.map(Math.abs))
  return {min:p.slice(0,3).map(v=>v-radius),max:p.slice(0,3).map(v=>v+radius)}
}
export function previewCamera(current: CameraPose, args: Record<string, unknown>, bounds: {min:number[];max:number[]}, aspect:number) {
  keys(args,['x','y','z','yaw','pitch','distance','projection','ortho_height','fov','view','fit'])
  if (args.fit !== undefined && typeof args.fit !== 'boolean') throw new Error('fit must be boolean')
  const {view,fit,...patch}=args
  let next = normalizePose(current,patch as Partial<CameraPose>)
  if (view !== undefined || fit === true) {
    if (view !== undefined && (args.yaw!==undefined || args.pitch!==undefined)) throw new Error('Use view OR yaw/pitch')
    next=frameBounds(next,bounds,aspect,view as ViewPreset|undefined)
    // Exact zoom/target may intentionally refine the fit.
    next=normalizePose(next,patch as Partial<CameraPose>)
  }
  return next
}
export {cameraBasis, defaultPose, frameBounds}
export type {CameraPose}

