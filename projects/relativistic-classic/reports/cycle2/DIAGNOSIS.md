# Cycle 2 closed with missing proof — candidate remains blocked

**Decision:** Authorize logger-cost correction plus ONE native owner-transfer control, or retain the partial/failing candidate without acceptance. Neither option has been executed; no further rounds are queued.

Strongest status: **Tested in map**, limited to the diagnostic scopes below. No delivery or native approval. T5/T6 remain blocked; reporting closes T7 only.

## Control results

| Control | Actual evidence | Meaning |
| --- | --- | --- |
| M45 alone | COMPLETE 1 case / 70 PASS / 0 FAIL / 0 SKIP; reader0 | Only Config differs from maintained src. Original live check passes; context sensitivity, not logger causation. |
| E29 | COMPLETE 1 case / 47 CHECK: 25 PASS / 19 OBS / 2 FAIL / 1 SKIP; reader1 | Original stage8 ownerless withdrawal checks PASS; stage7 owner-transfer/source-transfer checks FAIL. |
| Raw fog | Initially hidden, in-bounds, reveals PASS; rawP2=false | Raw Stop/Destroy control clears; not a native owner-transfer comparison. |
| Delayed withdrawal | rawP2, primaryOldP2, fallbackOldP1 all false at .25..2.25s after stage7 | Missiles remain alive through1.25s; later samples include post-termination state. No fog-latency cause established. |
| M45 logger stress | 700 buffered OBS rows; partial before launch; reader2 `missing COMPLETE` | No prior missile scenarios and identical core. Incomplete negative evidence, not final physics acceptance. |

## Stress capture and limitations

Original log captured once, exclusively, into `RM28-diag2-m45-stress-20261019-01.partial.txt` (78791 bytes). SHA-256: `988af5dc815b791f283abeef804b52c136be1671e83d421afeaff184e77651f8`.

Last persisted record: `RM28|diag2-m45-stress-20261019-01|CHECK|M45|PASS|diagonal-next-y-equation|expected=210.000 actual=210.000 tolerance=0.010`.
Partial snapshot only: 717 CHECK rows, `{'OBS': 700, 'PASS': 17}`. These are not final assertion counts.

Public reader ran **once on the original**, without `--report`:

```sh
python3 -B projects/relativistic-classic/tools/read_logs.py /home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx/drive_c/WarcraftIII/CustomMapData/Logs/RM28-diag2-m45-stress-20261019-01.txt --run-id diag2-m45-stress-20261019-01 --not-before 1792385281.2195556
```

Actual exit **2**; exact stdout/stderr/exit are preserved in `m45-stress-partial-reader.*`. Rejection created no parsed report.

Frozen `lab/Runner.j`: `Delayed -> Next -> StartCase` runs before `TimerStart`. An interrupted cold startup therefore prevents the fresh-thread phase probe from running. No phase value, native VM-operation ceiling or physics failure was observed. Expected complete counts in the preparation manifest are not actual results.

After the runtime interruption, parent observed no jobs and no Warcraft windows. Old job27 output is ENOENT. Stress observer exit/timeout, game28 exit and normal termination method are **unavailable**, not inferred. Earlier map22/map25 game exits0 were observed in conversation. No polling, observer, relaunch or retry was performed.

## Identity and build evidence

Core unchanged in all snapshots and maintained src: `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6`.
Candidate unchanged: `b8b1b9a1e4a072f014a75122a1c96851175c07c7198532f1d900227ee1165859`.
Full fixed02 evidence remains **47 cases / 657 PASS / 124 OBS / 3 FAIL / 1 SKIP; reader1**. The subsets do not replace it.

| Diagnostic map | Map SHA-256 | Generated JASS SHA-256 |
| --- | --- | --- |
| diag2-m45-alone-20261019-01 | `155a3429a130e7d1515099678ad68ded92dfba74be2de6a69f550fcb882bfce6` | `b5e06025fdf7881abeac1b14d0a722d9e807a52e3302dadf52541a5fc9b27e8d` |
| diag2-e29-20261019-01 | `2e16e224bb405695a292b3ba6fbcbf9505bf31ef6685072b1f9ae8d5a47430a5` | `62cf1a60fb0596ae4dfbd9eac8c094f27342ad2217ff8bd37c3b11e02e1ff8e4` |
| diag2-m45-stress-20261019-01 | `dc261c19636422e7ba54c876dd7488d351436c1b7b07c7eb8ccf1d98a364c369` | `21022d003b0ec7e3e56ca93eda13f409e076f3743ee5995dc9baf176cc192d1f` |

All three actual builds (jobs20/23/26) passed JassHelper, pJASS and archive verification with exit0; historical tool notices remain in original build reports. No build was rerun. `diagnosis.json` copies exact per-file input hashes from existing manifests, build command evidence, and log hashes. Original inputs, maps, full-run failures and logs remain untouched.

## Evidence boundaries and missing proof

- **WARNING:** E29 cause and S8 acceptance remain unestablished. Source/compiled lowering is unchanged; prior inspection found no initializer-ordering defect.
- **PERF hypothesis:** cumulative logger work may interrupt startup; isolation and partial stress do not prove logger causation or a VM ceiling.
- Preparation scans are not compilation; compilation and pJASS are not archive or gameplay proof. Archive roundtrip is separate from game assertions.
- The39 Python tests already passed during E29 preparation; not rerun here, and never physics proof. Multiplayer remains SKIP; exhaustion, host integrations and editor save/reopen remain unproven.
- Native assess remains unassessable for untracked files; no approved review or delivery approval.

## Evidence index

- `diagnosis.json`: exact flags/counts, input/map/JASS/log hashes and source locators.
- `../lab-diag2-m45-alone-20261019-01.json`, `../lab-diag2-e29-20261019-01.json`: existing complete controls.
- `RM28-diag2-m45-stress-20261019-01.partial.txt`: one original snapshot, not reconstructed.
- `m45-stress-partial-reader.stdout.json`, `.stderr.txt`, `-exit.json`: actual public-reader rejection.
- `../FINAL.md`: unchanged candidate and remaining human decision.

## Next decision

Authorize logger-cost correction plus ONE native owner-transfer control, or retain the partial/failing candidate without acceptance. Neither option has been executed; no further rounds are queued.
