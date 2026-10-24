# PREPARED_INSTANT_CONTROLLER — object setup only

New owned base: `base/burst-instant-controller-01.w3x`, SHA256 **`dea9c6cbac7e486d7c4fc11267fc1ed7b17c483d11f6f1025ecad6f45dc5c7ad`**.
Canonical recipe: `base/objects-instant-controller-01.json` (two controller-only overrides).

**Tooling RED→GREEN observed; native casting latency remains unknown.** This setup enables future active-burst recast testing for partial S1/S2/S6, but implements/tests none of those recast rules. PairCore—including its temporary ignored-active-cast behavior—and every RED/GREEN source/harness/plan/map/raw/verification artifact are unchanged. T2 remains open. No recast harness, emitter correction, UI change, compiler or game execution.

## Static metadata decision

Actual registered sources: `/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/classic-assets/Units/`:

| Field | Metadata location/type/schema | Original inherited o001 value | New owned override |
|---|---|---:|---:|
| `ucpt` | UnitMetaData.slk → UnitWeapons.slk `castpt`; Unreal, stored type2; nonleveled unit schema |0.6|0.0|
| `ucbs` | UnitMetaData.slk → UnitWeapons.slk `castbsw`; Unreal, stored type2; nonleveled unit schema |1.4|0.0|

Both metadata bounds are0..10. Unit records serialize **no level/selector words**; the independent reader reports logical level0/pointer0. This is not ability DataA/B indexing. Base05 o001 has only unam/uaen/uabi overrides, parent oshm. UnitWeapons stock oshm provides0.6/1.4. Actor o000 remains byte-identical, including all stats/abilities/weapons/animation/model data; no attack backswing field (`ubs1`/`ubs2`) is touched.

Actual AbilityMetaData maps `acas` to AbilityData `Cast`, Unreal, repeated per level, selector0. Stock ANcl `Cast1=0`, A00G inherits it unchanged (one ability level). Base05 already overrides Channel follow-through `Ncl1` to0; hidden `Ncl3=0` remains SCRIPTED-only. **No ability casting-time/UI change is justified by these static data**, and none was made. Native event timing must still be measured; zero serialized cast point/backswing is not a claim of immediate SPELL_EFFECT or proof that every other engine delay is absent.

Evidence with exact source hashes/rows: `instant-controller-01/metadata.json`, `merged-timing.json`. One initial stdout-only metadata inspection failed with KeyError `(113,1)` on an unkeyed SLK row; one corrected read skipped unkeyed rows. That inspection error is recorded in metadata evidence, not hidden as a successful first query; production metadata parser was not changed.

## Minimal helper extension

`tools/prepare_objects.py` adds only `ucpt`/`ucbs` to its existing optional unit whitelist and explicitly restricts them to **o001**. Existing metadata-derived type/bounds/level validation and byte-preserving serializer/archive guards are reused unchanged. No generic schema/framework/format/flag, unknown-ID authority, new rawcodes or type guessing. Help text documents these optional fields. Existing recipe rows retain the same behavior and ordering.

Before editing, retained old utility bytes NEW `instant-controller-01/baseline/rapid-fire-prototype/tools/prepare_objects.py`, plus the unchanged builder at the matching relative package path. This small retained layout is necessary because the utility computes ROOT/imports relative to `__file__`; it is not a patched baseline. Differential tests take this explicit external baseline path, never git history or a committed fixed baseline dependency.

## Observed public CLI tests and streams

Runner discovered from existing `serializer-green-correction.command.json` / tests: `/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B`.
Every CLI subprocess has a finite timeout; no background, wait/poll, compiler or native test. Exact argv/exits/stdout/stderr are retained in `instant-controller-01/*command.json`, `*.stdout.txt`, `*.stderr.txt`, with per-case streams in the corresponding evidence directories.

| Check | Actual outcome | Evidence |
|---|---|---|
| New focused test before helper edit | RED exit1: public CLI rejects valid new recipe, exit1/stdout empty/stderr exactly `error: unknown or disallowed field\n`; assertion expected success | `focused-red.*`, `../reports/instant-controller-red01/` |
| Same focused test after minimal extension | GREEN exit0, stdout `PASS: controller-only typed timing fields, public rejection and preservation\n`, stderr empty | `focused-green.*`, `instant-controller-green01/` |
| Existing public CLI suite after fix | Initial exit1: new relative `--evidence` test option made the occupied-output assertion expect a relative path while unchanged CLI guard emits absolute path | `legacy-suite.*`, `instant-controller-legacy01/` |
| One bounded correction | Resolve optional evidence path before testing; fresh suite exit0, exact prior PASS/input-hash stdout, stderr empty. Historical default naming unchanged | `legacy-suite-correction.*`, `instant-controller-legacy02/` |
| Differential frozen old vs new public CLI | Exit0; full old-recipe **output bytes identical**, exact common exit/stdout/stderr identical, no message normalization; new fields intentionally old-reject/new-accept | `differential.*`, `instant-controller-differential01/comparison.json`; baseline package differential-old/new case streams |

`test_instant_controller.py` independently walks object binaries through existing `tests/readback.py`; it never calls production planning/transform internals. It checks exact successful streams/output/evidence creation and public rejection of unknown field/kind/foreign ID/level/type/nonfinite/out-of-bounds/actor-targeted new fields. Rejected input/recipe hashes stay unchanged and no helper output/evidence/counter-bearing object records are created. The existing suite also preserves occupied output and prior values/selectors/levels. The focused old-supported recipe remains idempotent on base05. All intentional test products are retained evidence under allowed report directories, not scratch/cache.

Differential common inputs are the full old recipe plus unknown field/kind/foreign ID/invalid existing-field level/type. It compares exact output bytes for the supported recipe and exact streams/no outputs for rejections. New timing fields alone intentionally differ: frozen old rejects, new succeeds and passes independent typed readback. No historic handles/timestamps or simulated gameplay assertions.

## Owned artifact preparation and independent preservation

Exact already-executed command (do not repeat into existing destinations):

```text
/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/rapid-fire-prototype/tools/prepare_objects.py --base projects/rapid-fire-prototype/base/05-owned-objects.w3x --recipe projects/rapid-fire-prototype/base/objects-instant-controller-01.json --out projects/rapid-fire-prototype/base/burst-instant-controller-01.w3x --evidence projects/rapid-fire-prototype/reports/instant-controller-owned01
```

Observed exit0, stdout `prepared owned object base\n`, stderr empty. Base05 remains SHA `ff34f3fcea03281163c81bdcb11a6f7285f12c289c7160f640d4fa242adfb3b3`. Only war3map.w3u is intentionally managed in this recipe. The existing public CLI guard verifies all gameplay members, opaque assets, HM3W prefix and decoded listfile/unrelated attribute-CRC preservation; its report is `instant-controller-owned01/preservation.json`.

Independent final binary readback verifies **only two new type2/float0 modifications on o001**, exact raw existing o001 modification bytes, every other object record including o000, all abilities, other map members/opaque gameplay blocks and HM3W prefix unchanged. No object-record count/counter or other fields were normalized. `instant-controller-01/final-readback.json` records artifact hashes/readback. 84 protected prior artifacts have zero hash mismatches; all RED/GREEN plan inputs also match. Four Python files passed one AST syntax check without bytecode generation.

Registered War3Net-backed command:

```text
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 wc3ctl object get projects/rapid-fire-prototype/base/burst-instant-controller-01.w3x o001 --kind unit --json
```

Observed exit0, ucpt=0/ucbs=0/map source, existing fields unchanged. It reports `Warcraft III install not found (pass --game-dir <path>)`: this is **map-override parsing only**, not merged installed stock-data or native evidence. Actual stock inheritance above was independently read from pinned Classic tables, not inferred from that diagnostic. No get rerun was needed.

## Next parent boundary

Strongest status **Scanned**, scope: owned object setup/metadata and runnable Python CLI preservation tests. **Not native recast RED/GREEN or instant-effect proof.** The raw owned base is an object-data input, not a newly compiled executable prototype—do not launch it directly. A separate future R03 unit must use it with unchanged PairCore, add public actual SPELL_EFFECT timing/readiness and active-burst recast assertions first, then observe meaningful RED before correcting ignored active casts. Final UI remains deferred. Parent owns checkpoint/mirror reconciliation; this source unit makes no odd/history edits. No required parent background tooling command remains pending for this completed setup unit.
