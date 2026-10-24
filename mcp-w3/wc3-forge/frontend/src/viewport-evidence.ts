// Compare data, not JSON property insertion order (Wails may construct classes).
export function sameEvidence(a: Record<string, unknown> | null | undefined,
  b: Record<string, unknown> | null | undefined): boolean {
  if (!a || !b || a.version !== 1 || b.version !== 1) return false
  return ['version', 'loaded', 'path', 'loaded_sha256', 'load_generation',
    'revision', 'dirty', 'io_pending', 'identity_error'].every(k => a[k] === b[k])
}

// scene.waitForFrame covers the renderer's asset load, but App.reloadMap also
// fetches status before/after that load. A frame can be ready before the final
// evidence publication. Track the WHOLE reload, including queued same-path
// opens, so camera moves and captures cannot slip through that asynchronous gap.
export class ViewportReloadBarrier {
  private pending = new Set<Promise<unknown>>()

  track<T>(run: () => Promise<T>): Promise<T> {
    const task = Promise.resolve().then(run)
    this.pending.add(task)
    void task.then(() => this.pending.delete(task), () => this.pending.delete(task))
    return task
  }

  async wait(deadline: number): Promise<void> {
    while (this.pending.size > 0) {
      if (Date.now() >= deadline) throw new Error('Timed out waiting for map reload evidence')
      let timer: ReturnType<typeof setTimeout> | undefined
      try {
        await Promise.race([
          Promise.all([...this.pending]),
          new Promise<never>((_, reject) => {
            timer = setTimeout(() => reject(new Error('Timed out waiting for map reload evidence')), deadline - Date.now())
          }),
        ])
      } finally {
        if (timer !== undefined) clearTimeout(timer)
      }
    }
  }
}
