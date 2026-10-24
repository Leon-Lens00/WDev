# InventorySys technical probes (ITL)

**Current outcome: Needs your decision — native probes executed with FAILs;
clean GUI unproved (S1 unmet overall); all seven owned games closed.**
See the [technical outcome and evidence](../reports/technical/FINAL.md) and
[machine summary](../reports/technical/summary.json). These summarize retained
results only; no automatic retry or new verification round is authorized.
The commands/contracts below remain the probe procedure, not a claim of success.
[Initial frozen inputs and bounds](../reports/technical/plan.json)
pin the original map, generated JASS, reference WCT, old adapters and tools. Original
map SHA-256: `a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada`.
Preserve all original author credits; this is local evaluation, not redistribution.

## Run order and stop boundary

Use **four disposable maps** built from the same ITL sources: button, picture,
text, then camera. A separate **clean GUI companion** uses the existing manual
recorder with a fresh `techgui01` label only after the parent verifies it is unused.
Do not combine ITL and manual adapters or autorun manual fixtures. The ITL shim is
named `ILM_Log` solely to satisfy the builder's existing insertion whitelist; it
is not the manual recorder or its protocol.

1. Parent: run Python checks, then real classic pJASS and archive-preserving build
   for each unique ID; retain commands, streams, exits and hashes. Assembly alone
   does not produce a playable W3X or establish Validated status.
2. Parent: verify profile, client, unique log absence, exact owned PID/window and
   launch identity. Launch only one owned map at a time. No manual demo input
   during probes. They start two seconds after original initialization.
3. Wait for COMPLETE or the external deadline (maximum 60 seconds per map).
   Collect real logs and screenshot checkpoints. A 4-second independent per-case
   watchdog may finish a failed call from a living runner; it cannot rescue a
   completely frozen VM. Never invent an after marker, timeout error or COMPLETE
   offline. Missing COMPLETE remains invalid/incomplete evidence.
4. **Always close the owned game after every test.** Normal GUI exit first; prove
   the exact owned Warcraft PID and profile session disappeared before the next
   launch. If closure cannot be proved, stop new launches and ask for bounded
   human intervention. Never close unrelated sessions.
5. Membership is always LAST: shared lists may be corrupted. No demo continuation,
   no attempt to repair those lists. Camera is a separate, last, dangerous run;
   never retry its destructor or call APIs using its mutated pools afterward.
6. Use the separate clean GUI companion for actual mouse/keyboard open/close,
   selection and screenshots. Its observations do not certify ITL fixture physics.
   Stop/save its recorder normally, wait for persistence, close it and prove closure.

## Parent build commands

From repository root, with a fresh S3-authorized scratch child and unused run IDs:

```sh
PY=/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python
LAB="$PWD/projects/inventorysys-lab"
WC3=/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3
RUNS=/tmp/wdev-inventorysys-lab/<freshchild>/native
# Execute each in foreground. Stop on the first build failure; no game from assembly alone.
"$PY" -B "$LAB/tools/build.py" build --base "$LAB/baseline/original.w3x" --globals "$LAB/src/technical/globals.j" --early-functions "$LAB/src/technical/early.j" --hooks "$LAB/src/technical/hooks.json" --functions "$LAB/src/technical/functions.j" --entry ITL_Init --run-id itl-button-20261019-01 --output-dir "$RUNS" --wc3 "$WC3"
"$PY" -B "$LAB/tools/build.py" build --base "$LAB/baseline/original.w3x" --globals "$LAB/src/technical/globals.j" --early-functions "$LAB/src/technical/early.j" --hooks "$LAB/src/technical/hooks.json" --functions "$LAB/src/technical/functions.j" --entry ITL_Init --run-id itl-picture-20261019-01 --output-dir "$RUNS" --wc3 "$WC3"
"$PY" -B "$LAB/tools/build.py" build --base "$LAB/baseline/original.w3x" --globals "$LAB/src/technical/globals.j" --early-functions "$LAB/src/technical/early.j" --hooks "$LAB/src/technical/hooks.json" --functions "$LAB/src/technical/functions.j" --entry ITL_Init --run-id itl-text-20261019-01 --output-dir "$RUNS" --wc3 "$WC3"
"$PY" -B "$LAB/tools/build.py" build --base "$LAB/baseline/original.w3x" --globals "$LAB/src/technical/globals.j" --early-functions "$LAB/src/technical/early.j" --hooks "$LAB/src/technical/hooks.json" --functions "$LAB/src/technical/functions.j" --entry ITL_Init --run-id itl-camera-20261019-01 --output-dir "$RUNS" --wc3 "$WC3"
```

Use an isolated HOME/TMPDIR/XDG_CACHE_HOME under that scratch child as authorized
by the parent; do not change profile configuration or install tools. Replace
`<freshchild>` with the actual approved child, not a literal shell redirection.
`assemble` uses the same arguments without `--wc3`, produces only assembled JASS
and metadata, and runs no compiler/game. Native build is parent-only.

Mode is chosen by exact case-sensitive prefix `itl-button-`, `itl-picture-`,
`itl-text-`, `itl-camera-`; unknown prefix records FAIL without fixture calls.
The builder substitutes `@RUN_ID@` in new sources only. No regex namespace rewrite,
WCT compilation or duplicate library import. Its legacy metadata says "manual
observational recorder" whenever hooks are supplied; that tool label does not
change this adapter's explicitly destructive, disposable technical-test scope.
Strip all reported insertion spans to recover every original JASS byte exactly.

## Cases and public oracles

| Cases | Meaning and observable evidence |
| --- | --- |
| 1, each UI class | One public Camera.create/setPosition fixture, not a player/shared camera. Enumerate native group difference around one synchronous constructor; require exactly one new neutral-extra `uidm`, positive public control ID, and direct update moving native X/Y after camera translation. Hide before destroy to avoid early list contamination. |
| 2–17 | Sixteen separately scheduled hidden constructor/destroy/recreate pairs. Each native GetUnitTypeId must become 0 after public destroy. Record failure before owned native RemoveUnit cleanup. With **no intervening same-class allocation**, immediate public ID should be reused under the pinned freelist-first allocator/deallocation-push contract. Record actual IDs, counts and harness-inclusive elapsed seconds as OBS. |
| 18 | show(true) twice, move dedicated camera, updateAll vs independent direct update on native coordinates; hide(false) twice, then re-show/direct update. UIButton/Picture hide moves unit to origin; UIText hide keeps its dummy position (text visibility is not inferred from coordinates). Stable native type is required. |
| Button 19 | Native SelectUnit of owned button and public clickPeriodicSelect (also original periodic poll remains running). Require actual clickL entry/acquisition, reject a second selection at 0.1 seconds during delay, reaccept at 0.8 only after actual expiry, settle until approximately 1.5 seconds. Capture heartbeat, acquisitions, expiries and public retirement counts. |
| Button 20 | One real pending click, hide/destroy at 0.1 seconds outside click callback, settle until 0.8 seconds for original 0.6 callback. Record actual callback/heartbeat and retirement deficit before harness cleanup. No new button allocation until this case closes. |
| UI LAST: button 21, picture/text 19 | Show A/B/C; destroy A **visible**; create/show D (overwrites extra traversal slot). Translate dedicated camera; compare bulk positions of typed B/C/D against each independent public direct update on the same camera. Require living three units and positive direct movement before interpreting changed/missing counts. Mere destroy without D can miss the bug because updateAll traverses an extra slot. Native-clean only owned units, report shared membership unrestored, stop. |
| Camera 1 | One standalone public create/setPosition; independent watchdog armed **before persistence and first dangerous call**; log before destroy; invoke destroy once; after marker exists only if it really returned. Source recursively calls itself. No destructor loop, allocator probes or pool restoration claim. |

Source anchors: original lowered `s__UIButton_create/destroy/show/update/updateAll/
clickPeriodicSelect`, `s__UIPicture_create/createEx/destroy/show/update/updateAll`,
`s__UIText_create/createEx/destroy/show/update/updateAll`,
`s__Camera_create/setPosition/destroy`, `NewTimerEx(value) returns timer`,
`ReleaseTimer(timer) returns nothing`. WCT 025/029/032 document the original API.
Fixtures use ordinary create methods, texture 0 (no skin/destructable required),
exact existing `uidm`, and the public `CAMERA_DUMMY_PLAYER` constant used by the
original constructors (Neutral Extra, Player(14) in the recorded Classic inputs).
The fixture does not hardcode a player index. No invented
`uiwn` object, backing-array oracle, private getter or TimerUtils pool scan.
No SetUnitUserData ownership is taken. createEx signatures are pinned in tests,
not claimed as separately exercised game cases.

### Timer boundary ownership

The four function hashes and anchors in `src/technical/hooks.json` fail closed.
Insertions are only `call ILM_Log(...)`; all original statements, conditions and
return expressions remain intact. Only recorder state is mutated by early hooks:

- Before NewTimerEx's **existing return**, copy its actual typed return timer and
  primitive `value` through `ITL_Capture`. The return expression is not replaced.
  Matching positive owned button ID and generation gates tracking (8 slots max).
  That return expression's existing pool syntax is a public return-boundary copy,
  never a separate pool lookup or private storage oracle.
- Actual public clickL entry records its original primitive `this`. No private
  callback is manually invoked. Explicit public polling follows native selection;
  this is a technical selection-path probe, not a mouse-input simulation.
- At actual enableButtonCallback body entry, capture native GetExpiredTimer;
  no GetTimerData/private hashtable read by the harness.
- ReleaseTimer's successful push and native DestroyTimer branch record retirement
  **after** success. Null/double-release early returns are not retirement. The
  separate native destruction site belongs to an unrelated timer subsystem, not
  this callback path. Expiration and pause are not release.

No actual owned click/acquisition/expiry/heartbeat means readiness FAIL plus dependent SKIP,
not a timer-bug verdict. Positive readiness plus a deficit is retained baseline
FAIL. Only unretired tracked owned timers receive one harness ReleaseTimer after
recording the deficit; hooks tag that cleanup separately. Never double release
or infer ownership from integer handle reuse. Harness scheduling uses native
CreateTimer, not TimerUtils. The known missing release is in **UIButton's**
enableButtonCallback; InventoryCore_GracePeriod explicitly DOES ReleaseTimer.

## Logging and expected outcomes

The existing strict `tools/read_logs.py` is reused unchanged:

```text
Logs\IL141-<unique-run-id>.pld
IL141|run-id|sequence|kind|case-id|payload
```

512 rows maximum, contiguous decimal sequence starting at 1, ASCII payload of
1–160 characters from letters/digits/space/`_=.,:+-`. CASE has payload `before`;
CHECK records actual before/after sites. PASS/FAIL/OBS/SKIP counters are exact:
RESULT is `pass=N fail=N obs=N skip=N`; COMPLETE is
`cases=N pass=N fail=N obs=N skip=N`. Case IDs `case-1` onward are arbitrary valid
reader IDs. Button normally has 21 cases, picture/text 19 each, camera 1. Early
readiness/timeout stops can truthfully complete fewer cases. Scheduled slices,
separate validator and persistence condition budgets avoid cumulative case work;
three bounded harness triggers are retained until map shutdown.

Each class map retains one fixture camera until shutdown (known unsafe destroy).
At last membership, live UIText texttags are also bounded (3) and retained until
shutdown instead of dangerous shared-list cleanup. Fixture-native cleanup touches
only proven newly created handles, never demo controls/items or saved data.

Reader example (parent substitutes actual log path and recorded launch epoch):

```sh
"$PY" -B "$LAB/tools/read_logs.py" /actual/log/IL141-itl-button-20261019-01.pld --run-id itl-button-20261019-01 --not-before LAUNCH_EPOCH
```

Reader exit 0 = structurally complete without FAIL, 1 = structurally complete with
actual FAIL, 2 = invalid/stale/incomplete. OBS/SKIP remains inconclusive even on
exit 0. Expected original-baseline FAILs are unreclaimed struct IDs, UIText live
dummy after destroy, missing visible-list member after A/D replacement, owned
button timer retirement deficit, and camera nonreturn. These are **predictions**
until actual runs, not offline fabricated results. Never fix core code or relabel
FAIL to make this evaluation green. Record any unexpected failure separately.

## Evidence limits

Immediate nonreuse supports unreclaimed struct slots under the pinned allocator;
it is **not RSS**, process-memory or complete resource-leak measurement. Short,
16-pair timing is harness-inclusive PERF OBS, not an arbitrary frame-rate threshold,
long-match stability or session-leak-free certification. Native unit position
checks cannot establish visual text visibility, texture correctness or mouse UX.

**Multiplayer: explicitly untested gap.** No two-client/LAN framework is built;
local-player source review and a single client do not certify synchronization.
Original WCT/WTG bytes and author credits stay unchanged, not editor-save-certified.
Native pJASS, preserved archive bytes, actual game behavior, clean GUI evidence,
owned-process closure and one independent verification are distinct parent gates.
