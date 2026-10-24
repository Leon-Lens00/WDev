import { test } from 'node:test'
import assert from 'node:assert/strict'
import { sameEvidence, ViewportReloadBarrier } from '../../frontend/src/viewport-evidence.ts'

test('rendered evidence is order independent but rejects old/reopened/edited sessions', () => {
  const a = { version: 1, loaded: true, path: 'map.w3x', loaded_sha256: 'abc',
    load_generation: 2, revision: 5, dirty: false, io_pending: 0 }
  assert.ok(sameEvidence(a, Object.fromEntries(Object.entries(a).reverse())))
  for (const patch of [{version:0},{load_generation:3},{revision:6},{dirty:true},{io_pending:1},{loaded_sha256:'def'},{identity_error:'save failed'}]) {
    assert.equal(sameEvidence(a,{...a,...patch}),false)
  }
  assert.equal(sameEvidence(a,null),false)
})

function deferred() {
  let resolve!: () => void
  const promise = new Promise<void>(r => { resolve = r })
  return { promise, resolve }
}

test('same-path reload waits for status publication after renderer finishes', async () => {
  const barrier = new ViewportReloadBarrier()
  const renderer = deferred(), status = deferred()
  let published = false, cameraMoved = false
  const reload = barrier.track(async () => {
    await renderer.promise
    await status.promise // asynchronous Wails Status after scene.loadMap
    published = true
  })
  const camera = barrier.wait(Date.now()+1000).then(() => { cameraMoved = true })
  renderer.resolve()
  await Promise.resolve(); await Promise.resolve()
  assert.equal(cameraMoved, false)
  status.resolve()
  await reload; await camera
  assert.equal(published, true)
  assert.equal(cameraMoved, true)
})

test('queued reloads drain, and stuck loads fail instead of certifying stale evidence', async () => {
  const barrier = new ViewportReloadBarrier()
  const first = deferred(), second = deferred()
  const a = barrier.track(() => first.promise)
  const waiting = barrier.wait(Date.now()+1000)
  const b = barrier.track(() => second.promise)
  first.resolve(); await a
  let finished = false
  void waiting.then(() => { finished=true })
  await Promise.resolve()
  assert.equal(finished, false)
  await assert.rejects(barrier.wait(Date.now()+1), /Timed out/)
  second.resolve(); await b; await waiting
  assert.equal(finished, true)
})
