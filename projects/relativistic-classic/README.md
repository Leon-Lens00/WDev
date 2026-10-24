# Relativistic Missiles Classic — isolated regression project

**Status: Tested in map — verified single-client map scope, not production-ready.**
Current fixed03 completed47/808/0/1: **670PASS/137OBS/0FAIL/1multiplayerSKIP**,
reader0/statusinconclusive; E29 34PASS/13OBS/1SKIP, L99 last. Independent comparison
completed **true**, corrected comparison **exit0 / empty stderr**. Native review
approved and production ready remain **false**. No action or in-scope check pending.
See [FINAL](reports/FINAL.md), [cycle4 RESULTS](reports/cycle4/RESULTS.md) and
[exact failed/corrected comparison proof](reports/cycle4/comparison/README.md).
Original maps/installed executables unchanged; maintained outputs remain in WDev.

## Independent assigned-scope gate completed

Inherited source inspector `mvevyvvm-a-ov94` found no introduced fixture defect.
Corrected independent check `mvexzndm-j-5179` actually executed with a25s timeout,
**exit0 and empty stderr**. It closes T6's assigned single-client
S3/S4/S8/S10 evidence/oracle gate and S11 comparison purpose using S12 permission;
this is not native review approval, multiplayer or universal production acceptance.

The first actual probe `mvexqx1v-i-bl4g` exited1 with empty stdout and
`KeyError: 'freshness'` at comparison.py:102. The historical fixed02 report omits
optional freshness (the reader records it only with `--not-before`). Exactly ONE
auxiliary correction allowed absence ONLY there: **historical freshness not
recorded, not reconstructed or accepted as PASS**. All three current freshness
checks remain mandatory; no input, assertion, source or native evidence changed.
V1 remains immutable. Earlier source-only scan and two unlaunched capability
checks remain historical; they are not erased or relabeled as execution.

The corrected command independently checked77 explicit copied inputs, current13
sources, both frozen manifests, Config specializations, sole negative predicate,
compiled/maps/logs/public streams, original before/after hashes and Git state.
All47 case IDs match, L99 last. All70 original M45 records retain exact details
and order. All26 original E29 names/details remain; original assertions PASS
except multiplayer. Non-E29 case/status/name multiplicities are preserved except
exactly intended M45 recovered launch flag and coordinate-fixture-live FAIL to PASS.
**36 dynamic detail differences** in C21/C25/C36–C42 include runtime handles and
C37/C38 matched expected/actual0-vs1 remaining-object swaps, both PASS. This is
not whole-log or universal detail equality. Raw locations are retained in the
copied `dynamic-differences.json`; omitted truncated OBS values are not inferred.

S12/L45's live explicit system-temp permission resolved the earlier no-scratch /
inside-WDev isolation blocks. That authorization was session/purpose-limited,
not standing consent for future outside access. No permission question, action
or in-scope check remains. No engine, test, build, comparison or GUI rerun was
performed for reporting; no source/map/native data changed. Temporary proof and
historical `/tmp/rc-item3-XNICaO` were not modified or deleted.

## Source of truth

- `baseline/original.w3x`: exact original Classic Test 1.27b map, SHA-256
  `c87d5afb56fe36c4e633061d26551951f4d7db68b6ae0953b002e54eab6a4f9c`.
- `baseline/global.j`: exact 1820-line WCT global block; byte-identical to original
  `war3map.j` lines 1599–3418. Global hash:
  `b6b2b05054e8e2f77eded462598350aaff2cde0e031b9d3075c7a1cb802d7cdc`.
- `baseline/{TimerUtils,WorldBounds,DummyRecycler,Missiles}.j`: exact byte slices,
  verified against declarations, end markers and ranges, not just guessed line numbers.
- `src/libraries/*.j` and `src/Missiles.j`: initially byte-identical working copies.
  **Do not fix `baseline/`.** Baseline means immutable by project convention and
  exclusive-create tooling, not filesystem write protection.
- `baseline/original-harness.j`: historical `-rmtest` scope, archived but NOT imported.
- `baseline/members/`: named readable members, retaining original terrain, objects,
  WCT/WTG and dummy model. Full archive remains available in the snapshot.

| Library | WCT lines | Original credit/version evidence |
|---|---|---|
| TimerUtils | 1–275 | Vexorian, TimerUtils 2.0 comments/context |
| WorldBounds | 276–332 | 2.0.0.0; original link to nestharus/JASS |
| DummyRecycler | 333–822 | Flux, 1.25, forced-hashtable variant |
| Missiles | 823–1778 | Chopinski, 2.8; thanks to BPower, Dirac, Vexorian |

Core SHA-256 (both copies initially):
`ff75e5cc9c4805638622ccc553db9dd1e8c19af27333f8e65257d4f706bae05d`.
Original comments and credits are unmodified. User authorization covers local
recovery/modification; no redistribution license is inferred.
`reports/recovery.json` contains origin, member and per-library hashes.

## Recover once

Run from WDev, using the existing workshop Python with reviewed mpyq 0.2.5:

```sh
WC3=/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3
P=projects/relativistic-classic
PYTHONDONTWRITEBYTECODE=1 "$WC3" python -B "$P/tools/build.py" recover \
  --map '/home/snz/Documentos/WarDatsPy/Relativistic Missiles vJASSLUAGUI/Relativistic-Missiles-2.8-Classic-Test-1.27b.w3x' \
  --project "$P" \
  --expected-sha256 c87d5afb56fe36c4e633061d26551951f4d7db68b6ae0953b002e54eab6a4f9c
```

Already recovered: repeating this rejects existing targets before any write. It
never replaces a snapshot or working source. The first recovery attempt exposed
unsupported BLP compression and wrote nothing; the successful implementation
records that member's opaque compressed payload hash through mpyq metadata.
The encrypted `(listfile)` is not decoded. Inventory is explicitly incomplete;
no new MPQ/decompression implementation was introduced.

## Build and run

Use [the complete scenario recipe](docs/scenarios.md) and [the usage guide](docs/USAGE.md).
They list the eight explicit harness imports, `LabRun`, unique configuration IDs,
selected groups and strict log-reader behavior. Do not import a nonexistent
`src/Main.j` or confuse a build run ID with the embedded `RM_RUN_ID`.

Current tested candidate:
`build/fixed-20261019-03/fixed-20261019-03.w3x`, SHA-256
`4490afbf0824a89186faf22e3a948452b27fe0ae1a111f3d960a108228fb2694`.
It is not an approved production delivery. Current coreadc5ffd9/logger56443489
unchanged; Environment0b1c72c2 is the bounded E29 reference fixture. Frozen
negative alone injects a false private readiness predicate; actual reader1 has
one expected timeout at exact2.000, cleanup/restoration PASS, prior expected-negative
validation0. Normal full47 uninjected. Both builds JassHelper/pJASS/archive exit0;
39 tooling tests exit0/0.764s retained, not rerun. All games/observers exited0;
termination methods not established. No more runs are queued or authorized here.

Historical fixed02 remains657PASS/124OBS/3FAIL/1SKIP reader1, map SHA-256
`b8b1b9a1e4a072f014a75122a1c96851175c07c7198532f1d900227ee1165859`;
not the candidate pointer. Old logs/streams/snapshots stay unchanged.
Cycle3 native .25s transfer FAIL justified adapting the oracle, not universal
.5s cadence. Never overwrite an old run; the recipes below are documentation,
not permission to execute.

The builder creates a new `build/<run-id>/` and:

1. Preflights destination/input overlap, symlinks, duplicate/hardlink inputs and
   immutable run identity before writing. Existing runs are never overwritten.
2. Writes `entry.j` with TimerUtils, WorldBounds, DummyRecycler, selected Missiles,
   optional harness sources, a typed public entry call, then MapMain imports.
   It does NOT include the original map script or original demos/XE libraries.
3. Calls `wc3 vjass entry.j compiled.j`: the existing wrapper stages JassHelper,
   config and support files in authorized FrozenThone transient reports, runs
   `--scriptonly`, then native pJASS with installed common/Blizzard. No `+oldpatch`.
4. Calls `wc3 wc3ctl file set BASE war3map.j compiled.j --out injected.w3x --json`.
   Only this reviewed writer mutates a new archive; mpyq is the reader.
5. Restores the exact original HM3W prefix before re-reading the assembled map.
   Verifies compiled JASS bytes, every readable inventoried unchanged member and
   opaque payload metadata/hashes. Checks inputs unchanged; then exclusively
   creates `<run-id>.w3x`. Failure retains diagnostics but publishes no final map.

`command-*.json`, `commands.json`, `build.json`, compiler output and injection
intermediates remain in the new run directory. Wrapper stdout identifies its
external compiler report. No game launch, profile map copy or process control is
performed. Run actual builds under the parent's long-running-command procedure;
never retry a timeout automatically. Filesystem preflight is not a sandbox against
malicious tools or concurrent path replacement.

## Bootstrap and editor boundary

`src/MapMain.j` preserves actual original `config`, player-slot and ally-priority
function bodies, plus original main's environment/camera setup. It initializes
Blizzard, defines `RC_TEST_REGION = Rect(-1024,-1024,1024,1024)`, centers the camera
and calls the generated harness wrapper. No original units/items/demo triggers
are instantiated. Scenario setup belongs to the next harness worker.

Terrain and objects stay in the archive unchanged. The original unit object
`e000` derives from `ewsp`, references `war3mapImported\\dummy.mdl`, and the IMP
member imports `dummy.mdx` under `war3mapImported`; original binary model is
retained byte-for-byte (MDL reference / MDX archive naming is historical).

**Executable-test maps only.** WCT/WTG remain original, NOT synchronized with the
new executable script. External sources are authoritative. Do not open-and-save
these outputs in World Editor expecting tests to survive: no editor-save
certification, self-contained editable package, or WTG schema mutation is claimed.

## Tool identity and verification limits

`reports/toolchain.json` fingerprints actual launcher/wrappers, JassHelper and
support files, native pJASS, wc3ctl, Python/mpyq, native API and game/profile binaries.
Native hashes match both registered expected values. Native provenance attributes
Scripts to War3Patch.mpq; that extraction was not independently repeated.
Installed manual title is JassHelper 2012-02-07, changelog starts 2014-03-10;
this is dated distribution evidence, not an authenticated compiler fork/version.
Game and profile `war3.exe` / `game.dll` match and expose fixed-file metadata
`1.27.1.7085`. No executable was launched to obtain identity.

Re-identify to a **new** report path (never overwrite existing evidence):

```sh
PYTHONDONTWRITEBYTECODE=1 "$WC3" python -B "$P/tools/identify.py" \
  --root /home/snz/Documentos/ChatGPT/FrozenThone \
  --config /home/snz/Documentos/WarDatsPy/Taller-WC3/Documentacion/Configuracion.json \
  --launcher "$WC3" --report "$P/reports/toolchain-next.json"
```

Deterministic tests, no installed tools/maps, all fixtures in system temp:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -B -m unittest discover -s projects/relativistic-classic/tests -p test_build.py -v
```

Synthetic tests establish CLI rejection/no-write rules, import construction,
byte-preserving recovery, fake compiler/injector handling and archive-reader
protocol checks. They are **not** real MPQ-writer, JassHelper, pJASS or game proof.
Actual compiler/writer/game runs and independent review are now recorded.
Assigned independent non-E29 multiplicity/M45/provenance gate completed by
corrected executed comparison; exact failed V1 and passed V2 proof retained.
S3/S4/S8/S10 scoped single-client evidence met, not universal acceptance. Native assessment unassessable/untracked, no approval/receipt. Diagnostic
OBS tails truncate: omitted values not proved, named assertions retained; no new
fixture defect inferred. No screenshots accessed/referenced/embedded; ambiguous
captures excluded. Historical `/tmp/rc-item3-XNICaO` untouched; no new reporting scratch.
Risk: item3 verified for assigned scope; this unit docs/evidence only. T5/T6/T8
done; T7 closes after reporting-only metadata/copy readback, all eight then done.
Multiplayer, performance/exhaustion, arbitrary integration, universal production
and editor-save remain uncertified; circular revelation is not unit occlusion.

## Scoped reporting closure

The single foreground reporting-only readback exited0 with empty stderr:
3 JSON reports,7 Markdown reports and20 exact proof-file copies checked;
copied scripts parsed for syntax only, never executed. No redaction required.
[Readback evidence](reports/cycle4/comparison/reporting-readback.json).
This supersedes the pre-readback T7 checkpoint above: **T1–T8 all done for scoped
work**, T6 assigned verification complete, T7 reporting complete. No action or
in-scope check pending. Native approval/production readiness remain false;
multiplayer/editor-save/exhaustion/arbitrary integration remain out of scope.
