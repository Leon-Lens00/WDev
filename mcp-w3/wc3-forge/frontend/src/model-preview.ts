// Dedicated offscreen WebGL scene. No selection, placement, map camera or map writes.
// Shares the same loader/parser as AssetPreview and the map renderer.
import * as MV_ns from 'mdx-m3-viewer'
import { pathSolver } from './scene-instances'
import { patchMdxParser } from './mdx-parser-patch'
import { cameraBasis, defaultPose, frameBounds, finite, imageSize, keys, previewCamera, transformedBounds, type CameraPose, type PreviewSource } from './model-preview-contract'

const MV:any = (MV_ns as any).default ?? MV_ns
export class ModelPreview {
  private canvas: HTMLCanvasElement | null = null
  private viewer:any
  private scene:any
  private model:any
  private instance:any
  private source: PreviewSource | null = null
  private chosenPath=''
  private pose:CameraPose={...defaultPose}
  private bounds={min:[-200,-200,-200],max:[200,200,200]}
  private sequence=-1
  private paused=true
  private loop=true
  private lastTime=0
  private frame=0
  private errors:string[]=[]
  private generation=0
  private liveRevision: number | undefined
  close() {
    this.generation++
    this.instance?.detach()
    this.viewer?.gl?.getExtension('WEBGL_lose_context')?.loseContext()
    this.canvas=null; this.viewer=null; this.scene=null; this.model=null; this.instance=null; this.source=null
    return {ok:true,opened:false}
  }
  private async bounded<T>(promise:Promise<T>,deadline:number, generation:number):Promise<T> {
    let timer:ReturnType<typeof setTimeout> | undefined
    try {
      const result=await Promise.race([promise,new Promise<never>((_,reject)=>{
        timer=setTimeout(()=>reject(new Error('Model preview timed out')),Math.max(0,deadline-Date.now()))
      })])
      if (generation!==this.generation || Date.now()>=deadline) throw new Error('Model preview expired or map changed')
      return result
    } finally { if(timer) clearTimeout(timer) }
  }
  async open(source:PreviewSource, args:Record<string,unknown>, reforged:boolean, revision:number|undefined, deadline:number) {
    const width=imageSize(args.width),height=imageSize(args.height)
    this.close()
    const generation=this.generation
    this.source=source; this.liveRevision=revision; this.errors=[]; this.frame=0
    this.canvas=document.createElement('canvas'); this.canvas.width=width; this.canvas.height=height
    patchMdxParser()
    try {
      const v=MV.viewer
      this.viewer=new v.ModelViewer(this.canvas,{alpha:false,antialias:true,preserveDrawingBuffer:true})
      this.viewer.on('error',(...details:any[])=>{
        if(generation!==this.generation) return
        const resource=details.find(d=>d && typeof d==='object' && ('fetchUrl' in d || 'path' in d))
        this.errors.push(String(resource?.fetchUrl ?? resource?.path ?? details.find(d=>typeof d==='string') ?? 'Resource load error'))
      })
      for(const h of [v.handlers.blp,v.handlers.dds,v.handlers.tga]) this.viewer.addHandler(h)
      this.viewer.addHandler(v.handlers.mdx,pathSolver,reforged)
      v.handlers.mdx.loadTeamTextures(this.viewer)
      this.scene=this.viewer.addScene(); this.scene.color=[0.07,0.07,0.09]
      this.scene.viewport[2]=width; this.scene.viewport[3]=height
      for (const path of source.paths) {
        let model:any
        try { model=await this.bounded(this.viewer.load(path,pathSolver),deadline,generation) }
        catch(e) { if(generation!==this.generation || Date.now()>=deadline) throw e; continue }
        if (model && typeof model.addInstance==='function') { this.model=model; this.chosenPath=path; break }
      }
      if(!this.model) throw new Error('Model could not load: '+source.paths.join(' / '))
      this.bounds=transformedBounds(this.model.bounds,source)
      this.pose=frameBounds({...defaultPose,distance:400,ortho_height:400},this.bounds,width/height,'isometric','perspective')
      this.sequence=this.model.sequences.findIndex((s:any)=>/^\s*stand/i.test(s.name))
      if(this.sequence<0 && this.model.sequences.length) this.sequence=0
      this.paused=true; this.loop=true
      this.resetInstance()
      await this.bounded(this.viewer.whenAllLoaded(),deadline,generation)
      this.render(0)
      // Give particle/effect models a small initial simulation. Animation is paused afterwards.
      for(let elapsed=0;elapsed<240;elapsed+=16) this.render(16)
      await this.bounded(this.viewer.whenAllLoaded(),deadline,generation)
      this.render(0); this.fitSilhouette(); this.lastTime=performance.now()
      return this.state()
    } catch(e) {
      if(generation===this.generation) this.close()
      throw e
    }
  }
  private resetInstance() {
    this.instance?.detach()
    const s=this.source!
    this.instance=this.model.addInstance()
    this.instance.setScene(this.scene)
    this.instance.setLocation([0,0,0])
    this.instance.setRotation(s.rotation)
    this.instance.setScale(s.scale)
    this.instance.setTeamColor(s.team_color)
    if(s.vertex_color) this.instance.setVertexColor(s.vertex_color)
    this.instance.setSequenceLoopMode(this.loop?2:1)
    this.instance.setSequence(this.sequence)
  }
  private requireOpen(revision:number|undefined) {
    if(!this.instance || !this.canvas) throw new Error('Open a model preview first')
    if(this.liveRevision!==revision) {this.close();throw new Error('Map revision changed; reopen model preview')}
  }
  private render(dt:number) {
    const c=this.canvas!, p=this.pose, aspect=c.width/c.height
    const {offset,up}=cameraBasis(p.yaw,p.pitch,p.distance)
    const near=Math.max(0.1,p.distance*0.0001),far=Math.max(50000,p.distance*10,p.ortho_height*4)
    if(p.projection==='orthographic') {
      const h=p.ortho_height/2; this.scene.camera.ortho(-h*aspect,h*aspect,-h,h,near,far)
    } else this.scene.camera.perspective(p.fov,aspect,near,far)
    this.scene.camera.moveToAndFace([p.x+offset[0],p.y+offset[1],p.z+offset[2]],[p.x,p.y,p.z],up)
    this.scene.camera.update()
    if(this.viewer.gl.isContextLost()) throw new Error('Model preview WebGL context lost')
    this.viewer.updateAndRender(dt)
    const glError=this.viewer.gl.getError()
    if(glError!==this.viewer.gl.NO_ERROR) throw new Error('Model preview WebGL error '+glError)
    this.frame++
  }
  private advance() {
    const now=performance.now()
    // Demand-rendered preview: bound particle catch-up after a long idle period.
    if(!this.paused) {
      const elapsed=Math.min(1000,Math.max(0,now-this.lastTime))
      for(let t=0;t<elapsed;t+=16) this.render(Math.min(16,elapsed-t))
    }
    this.lastTime=now
  }
  // Imported MDX files often carry placeholder extents. Refine the conservative
  // initial fit against the actually rendered silhouette, including its animation.
  private fitSilhouette() {
    const c=this.canvas!, gl=this.viewer.gl
    for(let attempt=0;attempt<4;attempt++) {
      this.render(0)
      const pixels=new Uint8Array(c.width*c.height*4)
      gl.readPixels(0,0,c.width,c.height,gl.RGBA,gl.UNSIGNED_BYTE,pixels)
      let left=c.width,right=-1,bottom=c.height,top=-1
      for(let y=0;y<c.height;y++) for(let x=0;x<c.width;x++) {
        const k=(y*c.width+x)*4
        if(Math.max(Math.abs(pixels[k]-pixels[0]),Math.abs(pixels[k+1]-pixels[1]),Math.abs(pixels[k+2]-pixels[2]))>8) {
          left=Math.min(left,x);right=Math.max(right,x);bottom=Math.min(bottom,y);top=Math.max(top,y)
        }
      }
      if(right<left || top<bottom) return // Invisible/emitter-only model: keep metadata bounds and expose diagnostics.
      const p=this.pose, {up}=cameraBasis(p.yaw,p.pitch,1),rightAxis=[Math.cos(p.yaw),-Math.sin(p.yaw),0]
      const span=p.projection==='orthographic'?p.ortho_height:2*p.distance*Math.tan(p.fov/2)
      const dx=((left+right)/2-(c.width-1)/2)*span/c.height
      const dy=((bottom+top)/2-(c.height-1)/2)*span/c.height
      const coverage=Math.max((right-left+1)/c.width,(top-bottom+1)/c.height)
      const clipped=left<3 || right>c.width-4 || bottom<3 || top>c.height-4
      const ratio=clipped?1.3:Math.max(.1,Math.min(2,coverage/.78))
      this.pose={...p,x:p.x+dx*rightAxis[0]+dy*up[0],y:p.y+dx*rightAxis[1]+dy*up[1],z:p.z+dy*up[2],
        distance:Math.max(1,p.distance*ratio),ortho_height:Math.max(1,p.ortho_height*ratio)}
      if(!clipped && Math.abs(coverage-.78)<.02 && Math.hypot(dx,dy)<span*.01) break
    }
    this.render(0)
  }
  state() {
    if(!this.instance) return {ok:true,opened:false}
    const sequences=this.model.sequences.map((s:any,index:number)=>({index,name:s.name,interval:Array.from(s.interval)}))
    return {ok:true,opened:true,source:this.source,resolved_model_path:this.chosenPath,
      camera:{...this.pose},bounds:this.bounds,width:this.canvas!.width,height:this.canvas!.height,frame:this.frame,
      animation:{sequence:this.sequence,paused:this.paused,loop:this.loop,time_ms:this.sequence<0?0:this.instance.frame-this.model.sequences[this.sequence].interval[0]},
      sequences,diagnostics:{resource_errors:[...this.errors],geosets:this.model.geosets?.length??0},
      map_revision:this.liveRevision}
  }
  async run(operation:string,args:Record<string,unknown>,revision:number|undefined,deadline:number) {
    if(operation==='model_preview.close') {keys(args,[]); return this.close()}
    if(operation==='model_preview.get_state' && !this.instance) {keys(args,[]); return this.state()}
    this.requireOpen(revision)
    if(Date.now()>=deadline) throw new Error('Model preview request expired')
    if(operation==='model_preview.set_camera') {
      const next=previewCamera(this.pose,args,this.bounds,this.canvas!.width/this.canvas!.height)
      this.advance(); this.pose=next; this.render(0)
      if((args.view!==undefined || args.fit===true) && !['x','y','z','distance','ortho_height'].some(k=>args[k]!==undefined)) this.fitSilhouette()
    } else if(operation==='model_preview.set_animation') {
      keys(args,['sequence','time_ms','paused','loop'])
      const seq=args.sequence??this.sequence
      if(!Number.isInteger(seq) || (seq as number)<-1 || (seq as number)>=this.model.sequences.length) throw new Error('Invalid animation sequence index')
      if(args.paused!==undefined && typeof args.paused!=='boolean') throw new Error('paused must be boolean')
      if(args.loop!==undefined && typeof args.loop!=='boolean') throw new Error('loop must be boolean')
      const duration=(seq as number)<0?0:this.model.sequences[seq as number].interval[1]-this.model.sequences[seq as number].interval[0]
      const seek=args.time_ms===undefined?undefined:finite(args.time_ms,'time_ms',0,duration)
      if((seq as number)<0 && seek!==undefined && seek!==0) throw new Error('No sequence to seek')
      this.advance()
      if(args.loop!==undefined) this.loop=args.loop as boolean
      if(args.paused!==undefined) this.paused=args.paused as boolean
      if(args.sequence!==undefined || seek!==undefined) {
        this.sequence=seq as number;this.resetInstance()
        // Direct pose seek. Particle history is reset; replay is not a deterministic physics simulation.
        if(this.sequence>=0 && seek!==undefined) {
          this.instance.frame=this.model.sequences[this.sequence].interval[0]+seek
          this.instance.counter=seek;this.instance.forced=true
        }
      }
      this.instance.setSequenceLoopMode(this.loop?2:1)
      this.render(0); this.lastTime=performance.now()
    } else if(operation==='model_preview.screenshot' || operation==='model_preview.get_state') {
      keys(args,operation==='model_preview.screenshot'?['width','height']:[])
      const w=imageSize(args.width??this.canvas!.width),h=imageSize(args.height??this.canvas!.height)
      this.advance()
      if(w!==this.canvas!.width || h!==this.canvas!.height) {
        this.canvas!.width=w;this.canvas!.height=h;this.scene.viewport[2]=w;this.scene.viewport[3]=h
      }
      const generation=this.generation
      await this.bounded(this.viewer.whenAllLoaded(),deadline,generation)
      this.render(0)
      if(operation==='model_preview.screenshot') {
        const png=this.canvas!.toDataURL('image/png')
        if(!png.startsWith('data:image/png;base64,')) throw new Error('PNG capture failed')
        return {...this.state(),mime_type:'image/png',bytes_base64:png.slice('data:image/png;base64,'.length),captured_at:new Date().toISOString()}
      }
    } else throw new Error('Unknown model preview operation')
    return this.state()
  }
}
