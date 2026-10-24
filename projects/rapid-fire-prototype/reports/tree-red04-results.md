# Tree04 — scoped fixture FAIL; authorization consumed

**Verdict:** FAIL of the S24 fixture candidate, not a global product FAIL. S24 remains unmet; partial S3 tree collision is unrun/unaccepted. T2 is blocked on a human repair/new-measurement decision. No qualified Tree RED or Core/library defect was demonstrated.

## Saved native evidence

- `RF-rf-burst-tree-red-20261020-04.txt:18-20`: first matching effect at **0.180s**, then `ABORT-fixture` — `incompatible dummy at qualified birth; behavior unqualified, no tree RED inferred`; `COMPLETE|1|15|1|0`.
- Fifteen CHECKs: **1 PASS / 13 OBS / 1 FAIL / 0 SKIP**, one ABORT. Only the native point-order acceptance is PASS. R06 outcome assessment, R07 and the intercase transition were not reached; no absent-positive or tree-collision acceptance.
- `tree-red04-native-reader.exit.json`: exit **1**, empty stderr. `tree-red04-parent-spot.exit.json`: exit **1**, empty stderr. Independent `verification/tree-red04/reader-execution.json`: public reader exit **1**, `reader.stderr` empty. These failed public codes are preserved, not reclassified as successful tests.
- Freshness scope: launch request `1792528906.667707`; native-reader mtime `1792528915.940702`, captured-copy/parent-spot mtime `1792528915.942475`; all after request. Raw SHA256 `ba3a6ed9cd6c996f6fe3bc16a8d3f6547ebd7b6b991f54d715058fe3c4de193c`. Observer5 recorded COMPLETE within its 180s wall budget (`1792528895.4058852`–`1792528915.9927`). This qualifies freshness of the saved ABORT only.
- Actual parent build4 exit **0** (~4s), empty stderr: prior permission blocker is resolved, but both earlier pre-execution denials remain in `tree-red04-execution-blocker.md` and status history. Launcher6 exit **0** after ~33s (`1792528939.7622297`) is wrapper completion, **not** game-closure/profile-availability proof.

## Independent F1 causal chain (source audit, zero new gameplays)

`verification/tree-red04/findings.json` and `source-evidence.txt` identify a candidate-caused fixture bug: the new synchronous guard at `src/prototype/TreeNativeTest.j:421-422` requires native dummy owner `Player(0)` at birth, an unsupported lifecycle assumption. Recycler `projects/relativistic-classic/src/libraries/DummyRecycler.j:117,306,412` supplies neutral-owned paused dummies. `src/prototype/PairCore.j:119-175` sets the missile owner field, launches, then invokes the observer synchronously. `projects/relativistic-classic/src/Missiles.j:1053` schedules launch processing; native owner synchronization occurs later via OnOrient/`refreshVision` (`:374,587,864-881`). Missile owner field assignment is not synchronous native `SetUnitOwner`.

The composite native guard did **not** record its individual predicate values. Thus the actual native dummy owner and the precise failed predicate are **not observed**; the unsupported owner requirement is established by source reasoning, not an invented native-owner observation. Frozen Tree03 lacks the added guard and had R06 four shots/four hits PASS with the same Core/libraries. No library change is justified by this fixture abort.

The bounded transition source audit found no additional critical static issue in scope (`TreeNativeTest.j:610,723,824`): clearance limit 2.5s, polling .03125s, fail closed. That deadline/clearance path was **not reached natively**; no clearance timing proof follows.

## Identity and preservation

Saved build/pins identify:

| Artifact | SHA256 |
|---|---|
| Tree04 plan (saved preparation/status pin) | `832e5f409058dc0cca8ac94ae1a27a14ad0036fb826c0010e38a5015f242651e` |
| TreeNativeTest.j | `b5d0be3d348ae4749973a5758091b96c1be4e669d4c5884b8981504f08108d46` |
| unchanged PairCore.j | `770fd2f5bda5b84e8cdcec1b27074a6d8d572787aaa41ceb201fe137dfaffcc3` |
| compiled war3map.j | `251647f9a808172c2206ab68444f488dfa94e54b0dbc468c2e859b0fca187551` |
| Tree04 map | `c645a256c899cbd498a60f067c1ab144b0e1836493b2e9fe0a9b4df6b4835fb7` |

Independent `pins-preservation.json` retains ten plan-input pins and 32 frozen Tree03 entries, including the intentionally changed current harness versus its preserved frozen predecessor. Archival-only checks preserved 100 original files and all ten independent evidence files byte-for-byte and mtime-for-mtime. `verification/tree-red04/preservation-manifest.json` records source paths, destination SHA/size/mtime and no-overwrite copying from exact scratch `/tmp/wdev-rapid-fire-verify/tree04-independent-wpdw513b`; ten evidence files copied, plus one new manifest. No original was overwritten. Initial archival assertion rejected scratch directories before writes; one correction selected regular evidence files only. Scratch was left intact.

## Remaining proof and authority

Required Tree04 independent audit is **completed FAIL** (source/captured-reader only, **0 new gameplays**), not global T4 completion, native review approval or production acceptance. T1 remains scoped done; T3 global integration pending with the Tree04 attempt completed but failed; T4 global pending; T5 pending; T6 done.

**Proposal only:** align the birth-owner check with its actual pre-processing lifecycle phase and add predicate-specific diagnostics, retaining strict post-termination neutral/recycler clearance and all unknown-unit/placement guards. A repair and any new experiment require human authorization. S24's ONE measurement is consumed; no autorun/retry, new static-evidence unit test, source/Core/library edit, native/GUI/process action or further measurement was performed here. Parent memory159 result/160 blocker already exist; no duplicate observations added. Whole L66 checkpoint mirror uses id57 only.
