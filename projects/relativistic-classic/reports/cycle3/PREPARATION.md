# Two cycle3 controls prepared; native GREEN pending

**Scope status: Scanned.** This implements only the L30-authorized logger isolation
and prepares ONE E29 native transfer experiment. No compiler, map execution,
review operation, commit, production approval, or task-status transition occurred.
S3/S4 logging and S8/S9 experiment preparation are covered; S8 runtime acceptance
and S5–S7 compiler/game evidence remain parent-owned and pending. The unchanged
fixed02 candidate is still failing/incomplete; historical results are not replaced.

## Parent handoff

1. Compile exactly the two frozen inputs below using each `manifest.json`'s
   explicit `compiler_import_recipe`. Actual JassHelper must verify the private
   initializer name, generated ordering, dependencies and boolean callback type;
   pJASS and final archive checks remain required. Do not compile maintained
   `src` accidentally: its Config still deliberately says `UNCONFIGURED`.
2. Cold-start the corrected stress once. Keep the original Runner and Motion
   probes unchanged. Require all70 original M45 checks, exactly700 padding OBS,
   the retained `diag2-start-progress` OBS, and valid `COMPLETE|1|771|0|0`.
   Missing COMPLETE is incomplete, never a PASS. No Runner repair is included.
3. Execute the single E29 transfer experiment, retaining actual launch time,
   explicit current log, public-reader stdout/stderr/exit and complete JSON.
   Readiness failure is SKIP/inconclusive; multiplayer remains SKIP.
4. Compare ordered non-OBS M45 records (case/name/status, with details retained)
   against the original70 records in the public-reader JSON for
   `diag2-m45-alone-20261019-01`. Exclude only the700 named padding rows and the
   one named phase OBS from the stress check count; never filter FAIL/SKIP or
   synthesize PASS. Inspect any changed detail rather than hiding it. Preserve
   the original assertions and the historical partial stress capture.
5. Stop at the two authorized controls. Parent owns observer/desktop handling,
   evidence disposition and the one independent item3 verification. No more
   map variants, retries or rounds are automatically authorized.

| Control | Frozen input under `projects/relativistic-classic/build/` | Manifest SHA-256 |
|---|---|---|
| Same700OBS M45 stress | `inputs-diag3-logger-stress-20261019-01/` | `ffe61b77da3e2bbad47c7d389d33814820e51d177703833045700020b1b74485` |
| One E29 owner-transfer control | `inputs-diag3-e29-transfer-20261019-01/` | `500257bae52d76a271dbc444289a6631c7d8109d6ac9318ff7a45ecc8c01edb4` |

`preparation.json` and both snapshot manifests contain **every per-file input
hash**, source-before/source-after hashes, fixture identities and recipes.
Preparation executed once via:

```sh
python3 -B projects/relativistic-classic/reports/cycle3/prepare.py
```

Observed exit0, `Scanned`, `readback_verified: true`, `source_unchanged: true`,
`native_green: pending`. The private recipe reused existing `build.guard`,
`write_new`, `json_bytes`, and cycle2's exact-once transformation helper. Both
whole output sets were checked new before the first artifact write. It rejects
existing destinations and symlink redirection and never merges snapshots.
No temporary directories or tool caches were created by preparation.

## Logger: immediate full snapshot, isolated evaluation

Review `logger.patch`, then `stress.patch`. The public `RM_Log(string)` still
appends the same prefixed row and increments `lineCount` once. It then calls
native `TriggerEvaluate` synchronously. A single private trigger is created once
by `LabSupport initializer InitSnapshot requires LabConfig, Missiles`; its single
`Condition(function FlushSnapshot)` runs the unchanged Preload Clear/Start/full
saved-lines loop/End and returns true. No action, wait, timer, periodic batching,
per-record handle allocation, local-player taint, gameplay change or private
missile state access was added. Counters, ordering, COMPLETE construction,
caller arguments and scenario state remain unchanged.

This changes evaluation context, **not total snapshot complexity**. Every record
still rewrites every saved row before returning; there is no intentional loss
window. Whether native evaluation avoids the observed interruption is a
hypothesis until the same native stress completes. Neither a VM ceiling nor
native durability/success under stress has been measured here.

The registered classic common file is
`/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/classic-assets/Scripts/common.j`,
SHA-256 `9cb04da1c75dd30025d96fec12b4302c2f6a1f1a8c864b66d6cf52c65ecde924`.
Read declarations:

```jass
native CreateTrigger takes nothing returns trigger
native Condition takes code func returns conditionfunc
native TriggerAddCondition takes trigger whichTrigger, boolexpr condition returns triggercondition
native TriggerEvaluate takes trigger whichTrigger returns boolean
native CreateFogModifierRadius takes player forWhichPlayer, fogstate whichState, real centerx, real centerY, real radius, boolean useSharedVision, boolean afterUnits returns fogmodifier
native FogModifierStart takes fogmodifier whichFogModifier returns nothing
native FogModifierStop takes fogmodifier whichFogModifier returns nothing
native DestroyFogModifier takes fogmodifier whichFogModifier returns nothing
```

The same file defines `FOG_OF_WAR_VISIBLE = ConvertFogState(4)`.
Signatures establish the declared classic API, not engine behavior. Dependencies
remain `LabConfig` and `Missiles`; scenario libraries require `LabSupport`, and
`LabRunner` requires the scenario libraries. The initializer creates only its
own trigger/condition and reads no external runtime state. Actual compiler
lowering/initializer placement must be checked before game execution.

## Historical RED, unchanged core and preservation

| Artifact | SHA-256 |
|---|---|
| Maintained original Support, also frozen stress after removing only exact prefill | `d733ef12e5e130548a2715209edadb417e465a11582c02b5ec6df5bebdc91708` |
| Historical stress Support including original700prefill | `9640e12e5e44139c6879cabfb9e67ad4f1d5e792b40e497ef25c96456f17b19e` |
| Corrected maintained/E29 Support | `564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d` |
| Corrected stress Support retaining exact old RM_Case/prefill | `918c4a616585e6b4a6b8943567acbd8303d75c8b14fe39ce3412b82661797e7a` |
| Maintained and both frozen cores | `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6` |
| Historical partial native stress capture | `988af5dc815b791f283abeef804b52c136be1671e83d421afeaff184e77651f8` |

The historical RED capture is
`../cycle2/RM28-diag2-m45-stress-20261019-01.partial.txt`:78791bytes,
700 OBS and17 PASS before launch, ending `diagonal-next-y-equation`.
Historical public reader exit2, exact stdout:

```json
{"error": "missing COMPLETE", "run_id": "diag2-m45-stress-20261019-01", "status": "invalid"}
```

Historical stderr is exactly `error: missing COMPLETE\n`. Those saved streams
were read, not rerun. No old map was relaunched. Preparation normalized only
the exact original RM_Case prefill and verified its logger bytes match the
original maintained logger hash. The new stress derives from that entire
frozen tree, changing only Config ID and corrected Support. Motion, Runner,
all70 original assertions/constants and every other JASS file remain identical.
The old700prefill block is byte-identical, not a new per-row flush loop.

## E29: transfer observation separated from withdrawal

Only the frozen E29 Environment changes. Maintained
`src/lab/Environment.j` remains unchanged. P1/P2 below mean the explicit JASS
`Player(1)` / `Player(2)`, not renamed player-slot numbering.

| Stage | Actions and preserved deadlines |
|---|---|
| Start | Bounds-gate the same raw center0,3000/radius200/probe100,3000, including circle extents; require probe initially hidden to BOTH P1/P2. Create/start one P1 modifier with exact `FOG_OF_WAR_VISIBLE, true, false`. |
| 1 | Require positive P1 reveal AND P2 isolation. Invalid initial readiness yields SKIP; a valid fixture that fails reveal/isolation yields FAIL, disabling subsequent raw success claims. |
| 6 | Keep original missile owner=P2 and source `SetUnitOwner(..., P1, false)`. Record explicit before-transfer OBS, actual mutation RM_CLOCK, Stop+Destroy old P1 raw circle, then create/start the same P2 raw circle. Record after-transfer OBS in this checkpoint. |
| 7 | Keep ALL original owner/source-transfer conditions, names and details at the original scheduled .25s. Add raw transfer Check: old P1 false AND new P2 true. OBS distinguishes old-retained from new-not-yet-visible. |
| 8–10 | Continue transfer samples with no withdrawal yet. At END stage10, after its transfer sample, move the exact old stage7 withdrawal actions: cache live public dummy handles/withdrawal clock, Stop+Destroy raw, owner=null, RemoveUnit source, clear RM_U. |
| 11 | Exact original ownerless assertions (conditions/names/details) now .25s after actual withdrawal, NOT a widened deadline. |
| 11–19 | Retain delayed withdrawal samples. Stage15 is1.25s after withdrawal; retain the additional both-withdrawn check and terminate only after sampling/checking. Stage19 restores original alliances/fog/mask and performs original final cleanup assertions. Runner then applies its unchanged cleanup/idle checkpoint. |

Each transfer/withdrawal visibility sample includes actual `RM_CLOCK`, stage,
since-transfer/since-withdrawal clock deltas, rawP1/rawP2, primaryP1/primaryP2
and fallbackP1/fallbackP2. Its paired public-state row includes the same sample
clock plus source native type IDs and public dummy owners/positions. Before
withdrawal it reads live public dummy handles; afterwards it uses the same
cached public handles, which may be moved/reowned by the recycler. Post-termination
public owner/source fields can reset; no private state is inspected.

The before-transfer sample precedes assignment of the mutation clock, so its
`sinceTransfer` value is not an elapsed-transfer measurement; use its absolute
clock and the subsequent after-transfer sample. Likewise `sinceWithdrawal`
before withdrawal is not a withdrawal interval. Sampling occurs in the existing
.25s runner, with no extra timer. Core reconciliation occurs on its own visit;
no simultaneous core-visit, zero wall-time, or exact real-time deadline is assumed.
The original scheduled .25s assertions are intentionally not relaxed. OBS records
are measurements, never replacement assertions. A valid raw control does not
establish the missile implementation, a latency cause or multiplayer correctness.

`e29.patch` exposes all fixture changes. Preparation checked every maintained
Environment assertion/record call survives byte-for-byte. It did not simulate
fog, physics, scheduler, VM budgets or successful native checks in Python.

## Ordinary tooling verification (not native GREEN)

Executed exactly once, foreground,30s tool timeout:

```sh
python3 -B -m unittest discover -s projects/relativistic-classic/tests -v
```

Observed exit0; stdout is exactly empty. Exact stderr is preserved in
`tooling-tests.stderr.txt` (all39 named tests `... ok`), ending:

```text
----------------------------------------------------------------------
Ran 39 tests in 0.792s

OK
```

`tooling-tests.stdout.txt` preserves the empty stdout and
`tooling-tests.exit.txt` contains exactly `0\n`. The shell used exclusive
redirection (`noclobber`) only to these new cycle3 evidence files. Tests create
and clean their system-temp fixtures; no repository scratch/cache was introduced.
No new Python physics/static-text tests were invented. Behavior-level RED is the
historical native capture; GREEN/PRESERVE native runs and the70-check differential
are pending the parent's two authorized map executions. This is the explicit
native-runner exception to a locally runnable RED/GREEN cycle.

## Risks and review focus

- **WARNING — item3 shared persisted-log contract:** synchronous trigger evaluation
  is the narrow semantic change. Verify generated initialization before any
  RM_Log use, immediate full persistence, unchanged counters and caller progress
  in actual stress; a declaration/hash check is not native GREEN.
- **PERF:** full snapshots retain cumulative total work and classic array limits.
  No total asymptotic improvement or measured instruction ceiling is claimed.
- **WARNING — native control readiness/latency:** hidden probes, bounds and positive
  reveal/isolation must be observed; invalid readiness is never success. Raw
  control visibility and missile visibility may stabilize differently. Compare
  actual clocks, scheduled stages and both owners before attributing a cause.
- No S8 acceptance, multiplayer PASS, native review approval, task completion,
  production readiness or additional-round authorization follows from this report.

## Key Learnings
1. Synchronous snapshots preserve the existing persisted evidence contract.
2. Native trigger isolation leaves total snapshot work unchanged.
3. Historical stress bytes identify the original incomplete failure precisely.
4. Transfer sampling must precede a separately timed withdrawal mutation.
5. Public dummy observations can include subsequent recycler ownership changes.
