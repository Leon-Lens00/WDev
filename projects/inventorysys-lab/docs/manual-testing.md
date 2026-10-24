# Manual observation recorder (IL141M)

**Strongest current status: Validated — manual artifact only; runtime writing unverified.**
The delivered [manual map](../maps/InventorySys-Manual-20261019-01.w3x) is a
byte-identical convenience copy of the actual pJASS-validated, packaged artifact.
SHA-256: `26d7faf7953feb98a991222c77bf92c1fed58ffef534e2a874ba8ddd3a8f28fe`.
See [delivery evidence](../reports/manual/FINAL.md) and
[session identity/freshness](../reports/manual/delivery.json).
This is separate from the completed automatic experiment. No manual game or actual
runtime log writing has been observed. T4 awaits the user; nothing launches automatically.

## Human session: 10–15 minutes

Run this existing launcher **yourself**, from the WDev repository root:

```sh
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 play "$PWD/projects/inventorysys-lab/maps/InventorySys-Manual-20261019-01.w3x"
```

The current reserved label is `prueba01`; a read-only check found no matching chunks
at delivery. Build ID: `inv-manual-20261019-01`. Use one recording per launch.
Every restart requires a NEW unused label (for example, have the parent check
`prueba02` and record its identity before another launch); never reuse `prueba01`.
Use only the demo's existing visible controls. No hotkeys or item names are assumed.

1. Enter `-im start prueba01`, then `-im status`. Confirm that recording is active
   for this identity before acting. If status is not recording or shows OVERFLOW,
   stop the test sequence and tell the parent. Overflow stops recording, not gameplay.
2. Enter `-im mark` **before every section below**, and again whenever a problem
   appears. Note the section, visible item names and what you actually observed.
   Pause at least one second between actions for deferred snapshots; this does not
   establish causality between an action and a nearby sample.
3. Pick up several different item types. If full, try another item if practical;
   filling all 150 slots is not required.
4. Open and close the inventory five times.
5. Move through all five pages forward and backward, including wraparound at both ends.
6. Equip and unequip items, watching hero attributes. Attempt a slot conflict and
   note whether it is refused, replaces something, or behaves unexpectedly.
7. Request a drop and cancel; request again and confirm. Pick up the dropped item again.
8. Request a sale and cancel; request again and confirm. Watch and note gold changes.
9. If you find a compatible item and gem, request socketing and cancel, then request
   again and confirm. Otherwise report this section as not attempted; do not create fixtures.
10. Optionally repeat an oddity to describe reproducibility. Use `-im save` for an
    intermediate checkpoint and `-im status` to check recording. Save acknowledgement
    is not proof of successful disk writing.
11. Enter `-im stop`. Wait for the **stopped acknowledgement**, queued on the next
    0.25-second recorder tick, then wait **two more seconds** and exit normally.
    Do not close too soon; even acknowledgement does not guarantee disk persistence.
12. Tell the parent **“terminé” + `prueba01` + visible anomalies** (or none), including
    any skipped section. The parent will read all chunks from the existing profile
    after confirmation; you do not need to paste file contents.

If the game unexpectedly crashes, confirm that and describe what happened; logs
may be partial. There is no need to force continuation or restart using the same label.

## What changes, and what does not

The map starts its **original demo**, with its original hero, items and controls.
There are no fixtures, gameplay orders, stat/gold changes, camera changes or core
fixes. Initialization only installs the recorder chat/clock/persistence triggers.
Recording is initially OFF. Single-client, Player 0 scope only; this adds **no
multiplayer safety claim**. Retained WCT/WTG is unchanged, not editor-save certified.
The old `src/globals.j`, `src/functions.j`, `tools/read_logs.py`, baseline and prior
maps/reports remain independent. Omitting both manual flags preserves automatic
assembly bytes and the original report shape.

`src/manual/hooks.json` pins the full original generated-JASS SHA-256 and each
instrumented function's bytes. Exact anchors, occurrence counts and insertion sides
are mandatory. Drift/missing/ambiguous anchors fail before publication with
`error: invalid manual hooks`. The builder records every final insertion span's
byte offset, size and SHA-256; removing these spans reproduces the original script
exactly. This proves insertion-only byte preservation, **not identical timing**:
logging adds operations and can affect operation-budget/timing-sensitive behavior.
The existing archive identity guard and explicit housekeeping policy still apply.

| Real execution site | Observation, not a semantic verdict |
| --- | --- |
| `AcquireItem___Actions` | Native item type/user data copied from original locals before removal; PRE_ADD and actual ADD_TRUE/ADD_FALSE branch. No later native-pickup observer guessing about removed items. |
| `InventoryCore___LClickItemSlot` / `RClickItemSlot` | Actual callback entry; left entry includes original button identity. Not every entry passes the original validation. |
| Original page branches | Requested direction and page before change; normalized page after the original `show`. Both wrap directions retain original behavior. |
| `Equipment.equip` / `unequip` | Entry item/type/custom ID/slot and every literal Boolean return (10 equip paths, 2 unequip paths). No changed return expression. Nested callbacks may revert state before bonus application; RETURN value=1 is **not final equip success**. |
| Sell/Drop/Socket Actions and OnAgree | Actual request and actual agreement-callback entry using the already-valid original locals, never a fabricated invocation. Sell includes cost; socket includes gem/target identities, types, cost, capacity and actual ADD_TRUE branch. No socket-private getter or new tempCustomId write. |
| Existing `YesNoDialog___OnClick` | Actual clicked dialog/button/player IDs and comparison with its existing Yes button. yes=0 means non-Yes, not an invented cancellation callback. No added dialog/gameplay state. |

Early hooks after `endglobals`, before original functions, depend only on natives
and recorder globals. They enqueue bounded strings/copied primitives; they never
create handles, run RNG, flush files, invoke private callbacks, fabricate InvEvent
context or reconstruct private inventory/equipment/socket storage. The dialog's
explicit Yes comparison reuses its existing Yes-button array at its original click
site. Public fields are copied **inside their original execution sites**. Later functions before `main` use the existing public
150-slot inventory/custom-ID getters and native hero strength/agility/intelligence
and gold getters. No external equipment-array reconstruction is attempted.

## Session command contract

These exact forms also appear on screen and in reader `--help`:

| Command | Effect |
| --- | --- |
| `-im start <label>` | Explicit start only. Label: 1–32 ASCII letters/digits/underscore/hyphen, first alphanumeric. Invalid label or second start in the same launch is refused without resetting recorder counters/state. Requires original single-player Player 0 hero/inventory. |
| `-im status` | Shows READY/not recording, recording identity/counters, or stopped reason. Does not create observations. |
| `-im mark` | Adds a numbered/time-stamped manual marker; no arbitrary text accepted. |
| `-im save` | Samples public deltas and requests a checkpoint of the current chunk. Does not stop. Acknowledgement is not a filesystem success claim. |
| `-im stop` | Samples deltas and queues the terminal record. Stops **only recording**, never gameplay. No restart this launch. |

After stop/overflow, mark/save/stop are explicitly refused and status says gameplay
continues **unrecorded**; start is refused even after stop. Stop/overflow persistence
runs on the next recorder tick (0.25 seconds), not in the original handler. A
pending save/stop must not be confused with an already-verified file. Wait for the stopped acknowledgement and then two additional seconds before
exiting normally; acknowledgement is not a disk-write guarantee.

**Use a NEW label for every launch. Never reuse or overwrite an earlier session.**
The engine has no native file-exists guarantee, and PreloadGen can overwrite an
existing filename. Build ID plus human label is an identity, not atomic filesystem
uniqueness enforcement. The parent must check the actual files, labels and mtimes
before analysis; no in-game acknowledgement certifies that files were written.
The user retains ownership of the original bag/equipment controls and action order.

## Bounded protocol and uncertainty

Files requested under the game's existing CustomMapData log root are:

```text
Logs\IL141M-<build-id>--<label>--<chunk-index>.pld
```

Indices are canonical decimal **0–63**, without leading zeroes. Each chunk has
1–128 rows; every non-last chunk must contain exactly 128. Only the current chunk
is buffered/checkpointed; sealed chunks are never rewritten. A separate 256-row
bounded pending queue decouples original hooks from persistence. The queue reserves
one row for TERMINAL, as does the 8192-row total capacity (128 × 64). No wraparound
reuses a chunk or claims new success. A full queue or total capacity refuses the
next row, stops recording, and appends an OVERFLOW terminal. `dropped=1` counts the
first refused row; actions after shutdown have **unknown/unbounded missing
coverage**, not an invented exact count. Gameplay is unaffected by recorder stop.

```text
IL141M|build-id|label|chunk|sequence|time-ms|source|event|data
```

Sequence starts at 1 and is contiguous. Time is monotonic milliseconds since
recorder initialization in that map launch (not wall clock or command causality).
Source/event are bounded 1–32 ASCII identifiers; data is 1–160 ASCII characters
from letters/digits/space/`_=.,:+-`. No pipes, quotes, slashes, escapes or arbitrary
user text enter data. Labels/build IDs are similarly restricted. A row cannot
be interpreted as script/shell code by this reader.

The first row is `recorder|BEGIN|schema=1`. Initial inventory cache defaults to
empty item/custom-ID zero; initial nonzero values and subsequent changes produce
`sample|SLOT|slot=N item=N cid=N`. Stats are sampled at start and on change.
Dirty events coalesce to at most one sample per 0.25 seconds; a once/second poll
also catches changes outside these hooks. No 150-row dump occurs for every click.
Samples can miss transient states and coalesce unrelated actions; timestamps and
nearby events imply **no causal attribution**. Custom IDs may remain after an item
is cleared. The recorder reports that observation without deciding PASS/FAIL.
Private socket contents and final equipment layout have no added public oracle.

The terminal is the final row, from `recorder`, event `TERMINAL`, with exact data:

```text
reason=USER_STOP rows=<final-sequence> dropped=0
reason=OVERFLOW rows=<final-sequence> dropped=1
```

A crash/exit before final persistence leaves incomplete evidence. Checkpointing
bounds losses but cannot guarantee successful runtime writing or retained coverage.
Capacity is intended for a bounded 10–15 minute manual exploration, not unlimited
capture; high interaction rates may exhaust it earlier. No filesystem or gameplay
success has yet been observed for this manual path.

## Parent-only assembly/build reference

Use workshop Python with `-B`; fresh scratch only below
`/tmp/wdev-inventorysys-lab/`. Set HOME/TMPDIR/XDG_CACHE_HOME inside that fresh child.
The following is **assembly syntax**, not a request for the user to run it:

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/build.py assemble --base projects/inventorysys-lab/baseline/original.w3x --globals projects/inventorysys-lab/src/manual/globals.j --early-functions projects/inventorysys-lab/src/manual/early.j --functions projects/inventorysys-lab/src/manual/functions.j --hooks projects/inventorysys-lab/src/manual/hooks.json --entry ILM_Init --run-id inv-manual-001 --output-dir /tmp/wdev-inventorysys-lab/NEW_MANUAL_CHILD
```

Both `--early-functions` and `--hooks` are optional **together**, on `assemble` and
`build` only. Supplying just one fails with
`error: manual mode requires --early-functions and --hooks together`.
The actual delivered package already passed validation and packaging. For a future
parent-authorized package only, replace `assemble` with `build`, use a NEW
run/output directory, and add
`--wc3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3-taller.py`.
The parent validates the existing plain JASS with classic pJASS, **not** JassHelper:
recompiling the already-compiled libraries/WCT would duplicate them. Packaging must
retain the existing 52 identity-bound assets and documented housekeeping policy.

## Strict reader reference (analysis after user confirmation)

`tools/read_manual_logs.py` is separate from the unchanged automatic-schema reader.
INPUT is either a directory containing chunks, or a UTF-8 JSON manifest beside its
chunks with exactly `{"chunks":["IL141M-inv-manual-001--fresh_label--0.pld"]}`.
Manifest entries must be canonical chunk **basenames**, not relative paths. Input
order is irrelevant: indices are naturally sorted and must be contiguous from 0.
In directory mode only the exact requested build/session filename pattern is
selected; other sessions/builds and unrelated filenames are ignored. A manifest
is an explicit selection, not a way to discover omitted higher chunks; the parent
must check the directory for the session's full set before selecting it.

CLI shape (the parent supplies the exact directory, build, label and freshness floor):

```text
read_manual_logs.py INPUT --run-id BUILD --session LABEL --not-before UNIX_SECONDS [--report NEW_JSON]
```

For this delivery, after user confirmation, read the directory directly so **all**
matching chunks are selected, not a subset manifest:

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/read_manual_logs.py /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx/drive_c/WarcraftIII/CustomMapData/Logs --run-id inv-manual-20261019-01 --session prueba01 --not-before 1792440879.7859807
```

This `time.time()` floor was captured at delivery, not inferred from recorder time.
If another launch is arranged, first record its new label and floor; do not silently
reuse this command for another session. No reader execution on human logs occurs
until confirmation. Inspect the full matching directory set before using any manifest.

All three identity/freshness options are required. `--not-before` is a finite Unix
mtime floor for **every** chunk and manifest. Symlinks, hardlinks, aliased inputs,
existing/overlapping report paths, oversized chunks (>65536 bytes), oversized
manifests (>16384 bytes), missing/duplicate/noncanonical/trailing chunks, row or
chunk identity mismatches, sequence gaps, reversed timestamps, unsafe wrappers,
invalid terminals and counter mismatches are rejected. Rejection preserves all
input and existing-report bytes. The report parent directory must already exist;
new reports use exclusive creation and never overwrite. Directory mode and a
manifest cannot authenticate runtime origin or defeat concurrent hostile changes.

The reader accepts ASCII raw rows with final newline or the inert, bounded
PreloadFiles/Preload wrapper, optional PreloadStart/PreloadEnd lines only in their
proper positions. It **never executes** any log. Outputs are JSON observations:

- **0**: `status=observation_complete`, contiguous evidence ending USER_STOP.
  `semantic_certification=false`; this does **not** certify correct gameplay.
- **1**: `status=partial`, missing terminal or OVERFLOW. Never clean coverage.
- **2**: rejected evidence; stdout is empty and stderr is exactly
  `error: invalid manual evidence` plus newline. No report is created.

Python/static fixtures verify tooling/protocol/insertion conformance, not gameplay.
Compilation, archive packaging, independent verification and user-operated runtime
writing/actions remain separate evidence gates. Wait for the user's explicit
completion confirmation before interpreting a manual report.
