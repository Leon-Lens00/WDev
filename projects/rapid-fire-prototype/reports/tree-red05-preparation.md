# Tree05 — birth-guard correction prepared

**Scanned only. Compiled / Native GREEN pending parent.** T2 covers S25 fixture preparation; S3 collision and S24 intercase clearance remain unproven. ONE parent measurement `rf-burst-tree-red-20261020-05` remains unconsumed. No autorun or retry.

## Correction and evidence

Tree04 produced effect at 0.180s then fixture ABORT (`COMPLETE|1|15|1|0`), not collision RED. Independent `verification/tree-red04/findings.json` F1 identifies unsupported Player(0) native ownership at synchronous birth. Actual predicate values were not observed in Tree04.

Pinned PairCore.spawn assigns logical missile owner, Emit launches then synchronously invokes the observer. Missiles.create borrows a neutral recycler dummy; launch schedules processing only. Native ownership sync occurs later in OnOrient/refreshVision. Thus birth must require **Player(PLAYER_NEUTRAL_PASSIVE)**, not logical missile owner Player(0). No owner allowlist, ignored ownership, or dummy mutation is introduced.

Only this new birth-owner predicate changes. Type e000, life > .405 and paused checks retain their order and semantics. `birth-dummy-contract` now logs actual native owner/type/life/pause/handle/time and `firstFailed=type|owner|life|pause|none`; failure ABORT also names the first predicate. Values are captured at callback time, not inferred from the logical missile owner. Logging successful births permits the upcoming native run to establish actual values.

Identity uniqueness, source/public projectile guards, scan, damage/cadence/lifetime oracles, 2.5s intercase deadline, .03125 polling, unknown-unit/corner guards and original strict readiness remain unchanged. PairCore770 and libraries are untouched. No CLI/API change; no new collision callback.

## Preservation and verification boundary

`frozen-tree-red04/manifest.json` records 54 source/plan/input/build/native/verification artifacts with original SHA256, size and mtime_ns. Copies are exclusive-created with metadata preserved; old evidence is never overwritten. Tree04 frozen harness is b5d0be3d348ae4749973a5758091b96c1be4e669d4c5884b8981504f08108d46.

`tree-red05-preparation.json` records the one bounded static check, exact check source/stdout/stderr/exit, diff and fresh hashes. No deterministic native runner is authorized for this worker: no meaningful behavior RED/GREEN can be observed here. Saved Tree04 ABORT is failing fixture evidence only. Static preservation is not compilation or engine proof. No CLI differential run applies; the callback is native-only, and build/game execution belongs to parent.

## Parent-only next steps

Use `build-plan-tree-red05.json` **argv/shell** for compilation, then verify all fresh pins and compiled/archive outputs. Perform exact-profile preflight/log absence before ONE protected measurement. `parent_play_argv`, fresh `log`, `reader_argv_template` and `output_map` are in the plan. Replace `PARENT_RECORDED_LAUNCH_UNIX_SECONDS` only with the actual launch timestamp; reader report is `reports/tree-red05-native-reader.json`, never a Tree04 output. Plan pending statuses are preparation snapshots, not current Tree04 results.

After that measurement, parent owns targeted F1 verification: inspect actual birth values and firstFailed; preserve any ABORT, confirm R06 qualifies, then evaluate unchanged intercase and R07 gates. No native correction, qualified collision RED, S3 acceptance, or global integration is claimed until observed.
