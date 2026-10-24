import { test } from 'node:test'
import assert from 'node:assert/strict'
import { cameraBasis, normalizePose, frameBounds, defaultPose } from '../../frontend/src/camera-pose.ts'

test('exact poles have a finite orthogonal up vector', () => {
  for (const pitch of [-Math.PI / 2, 0, Math.PI / 2]) {
    const { offset, up } = cameraBasis(0.7, pitch, 1000)
    assert.ok([...offset, ...up].every(Number.isFinite))
    assert.ok(Math.abs(offset.reduce((n, x, i) => n + x * up[i], 0)) < 1e-8)
    assert.ok(Math.abs(Math.hypot(...up) - 1) < 1e-8)
  }
})
test('pose validation is atomic and preserves explicit zeroes', () => {
  assert.throws(() => normalizePose(defaultPose, { distance: -1 }))
  assert.throws(() => normalizePose(defaultPose, { yaw: NaN }))
  assert.throws(() => normalizePose(defaultPose, { projection: 'invalid' } as any))
  const next = normalizePose(defaultPose, { x: 0, z: 0, pitch: Math.PI / 2, projection: 'orthographic' })
  assert.equal(next.pitch, Math.PI / 2)
  assert.equal(next.z, 0)
  assert.deepEqual(defaultPose, normalizePose(defaultPose, {}))
})
test('frame fits wide bounds at portrait aspect and restores from state', () => {
  const next = frameBounds(defaultPose, { min: [-1000,-100,0], max: [1000,100,200] }, 0.5, 'top', 'orthographic', 1.1)
  assert.equal(next.pitch, Math.PI / 2)
  assert.ok(next.ortho_height >= 4400)
  assert.equal(next.x, 0)
  assert.equal(next.z, 100)
  assert.deepEqual(normalizePose(defaultPose, next), next)
  assert.throws(() => frameBounds(defaultPose, { min: [1,0,0], max: [0,1,1] }, 1))
})
