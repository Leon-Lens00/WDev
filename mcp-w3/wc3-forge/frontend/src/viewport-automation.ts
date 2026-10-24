import type { SceneAPI } from './scene-instances'
import { frameBounds, type Bounds, type CameraPose, type Projection, type ViewPreset } from './camera-pose'

export type ViewportRequest = { id: number; operation: string; args: Record<string, unknown>; deadline: number; expected_evidence?: Record<string, unknown> }

export async function runViewportRequest(scene: SceneAPI, request: ViewportRequest) {
  if (Date.now() >= request.deadline) throw new Error('Viewport request expired')
  const camera = scene.getCamera()
  const args = request.args ?? {}
  // Wait for loadMap's own framing to finish before applying an agent pose.
  await scene.waitForFrame(request.deadline)
  if (Date.now() >= request.deadline) throw new Error('Viewport request expired')
  if (request.operation === 'camera.set_state') {
    const allowed = new Set(['x','y','z','yaw','pitch','distance','projection','ortho_height','fov'])
    if (Object.keys(args).some(k => !allowed.has(k))) throw new Error('Unknown camera state field')
    camera.setPose(args as Partial<CameraPose>)
    await scene.waitForFrame(request.deadline)
  } else if (request.operation === 'camera.frame') {
    const bounds = args.bounds as Bounds | undefined
    if (!bounds) throw new Error('bounds are required')
    const aspect = camera.getAspect()
    camera.setPose(frameBounds(camera.getPose(), bounds, aspect,
      args.view as ViewPreset | undefined, args.projection as Projection | undefined,
      args.padding === undefined ? 1.15 : args.padding as number))
    await scene.waitForFrame(request.deadline)
  } else if (request.operation === 'viewport.screenshot') {
    const maxWidth = args.max_width ?? 1600
    if (!Number.isInteger(maxWidth) || (maxWidth as number) < 256 || (maxWidth as number) > 4096) throw new Error('max_width must be 256..4096')
    return scene.captureViewport(maxWidth as number, request.deadline)
  } else if (request.operation !== 'camera.get_state') {
    throw new Error('Unknown viewport operation')
  }
  return { ok: true, state: camera.getPose(), frame: scene.getDiagnostics().frame }
}
