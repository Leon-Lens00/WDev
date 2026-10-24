export type Projection = 'perspective' | 'orthographic'
export type ViewPreset = 'top' | 'bottom' | 'north' | 'south' | 'east' | 'west' | 'isometric'
export type CameraPose = {
  x: number; y: number; z: number; distance: number; yaw: number; pitch: number
  projection: Projection; ortho_height: number; fov: number
}
export type Bounds = { min: number[]; max: number[] }
export const defaultPose: CameraPose = {
  x: 0, y: 0, z: 0, distance: 6000, yaw: 0, pitch: Math.PI / 3,
  projection: 'perspective', ortho_height: 6000, fov: Math.PI / 3,
}

export function normalizePose(current: CameraPose, patch: Partial<CameraPose>): CameraPose {
  const next = { ...current, ...patch }
  for (const key of ['x','y','z','distance','yaw','pitch','ortho_height','fov'] as const) {
    if (typeof next[key] !== 'number' || !Number.isFinite(next[key])) throw new Error(`${key} must be finite`)
  }
  if (!['perspective','orthographic'].includes(next.projection)) throw new Error('invalid projection')
  if (next.distance < 1 || next.distance > 1000000) throw new Error('distance must be 1..1000000')
  if (next.ortho_height < 1 || next.ortho_height > 1000000) throw new Error('ortho_height must be 1..1000000')
  if (Math.abs(next.pitch) > Math.PI / 2) throw new Error('pitch must be -pi/2..pi/2 radians')
  if (next.fov < 0.05 || next.fov > 2.8) throw new Error('fov must be 0.05..2.8 radians')
  return next
}

// A camera-local up vector remains defined at both poles (world Z does not).
export function cameraBasis(yaw: number, pitch: number, distance: number) {
  const cy = Math.cos(yaw), sy = Math.sin(yaw), cp = Math.cos(pitch), sp = Math.sin(pitch)
  return {
    offset: [-sy * cp * distance, -cy * cp * distance, sp * distance],
    up: [sy * sp, cy * sp, cp],
  }
}

export function frameBounds(current: CameraPose, bounds: Bounds, aspect: number,
  view?: ViewPreset, projection?: Projection, padding = 1.15): CameraPose {
  if (!bounds || !Array.isArray(bounds.min) || !Array.isArray(bounds.max) || bounds.min.length !== 3 || bounds.max.length !== 3 ||
    ![...bounds.min, ...bounds.max].every(Number.isFinite) || bounds.min.some((n, i) => n > bounds.max[i])) throw new Error('invalid XYZ bounds')
  if (!Number.isFinite(aspect) || aspect <= 0 || !Number.isFinite(padding) || padding < 1 || padding > 4) throw new Error('invalid aspect or padding')
  const presets: Record<ViewPreset, [number, number]> = {
    top: [0, Math.PI / 2], bottom: [0, -Math.PI / 2], north: [Math.PI, 0], south: [0, 0],
    east: [-Math.PI / 2, 0], west: [Math.PI / 2, 0], isometric: [Math.PI / 4, Math.atan(1 / Math.sqrt(2))],
  }
  if (view !== undefined && !presets[view]) throw new Error('invalid view preset')
  const [yaw, pitch] = view ? presets[view] : [current.yaw, current.pitch]
  const center = bounds.min.map((n, i) => (n + bounds.max[i]) / 2)
  const half = bounds.min.map((n, i) => (bounds.max[i] - n) / 2)
  const { offset, up } = cameraBasis(yaw, pitch, 1)
  const right = [Math.cos(yaw), -Math.sin(yaw), 0]
  const extent = (axis: number[]) => half.reduce((n, h, i) => n + h * Math.abs(axis[i]), 0)
  const h = Math.max(1, extent(up), extent(right) / aspect) * padding
  const depth = extent(offset)
  return normalizePose(current, {
    x: center[0], y: center[1], z: center[2], yaw, pitch,
    projection: projection ?? current.projection, ortho_height: 2 * h,
    distance: depth + h / Math.tan(current.fov / 2) + 32,
  })
}
