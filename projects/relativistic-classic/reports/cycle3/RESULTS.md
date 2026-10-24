# Needs your decision — logger GREEN, E29 temporal control FAIL

**Strongest status: Tested in map, bounded controls only.** L30's "si" scope is
finished as T8. Authorize **bounded native-update-aware E29 fixture correction
and ONE full47 acceptance run**, or retain the partial/failing candidate. This is
a recommendation for a new human decision, not permission to execute. No more
controls, arbitrary .5s deadline, core patch or automatic assertion widening.

## Actual outcomes

| Artifact | COMPLETE cases/checks/FAIL/SKIP | Record counts | Public reader |
|---|---|---|---|
| Corrected logger stress | 1/771/0/0 | 70 PASS, 701 OBS | 0, empty stderr |
| ONE native E29 transfer control | 1/60/3/1 | 25 PASS, 31 OBS, 3 FAIL, 1 SKIP | 1, empty stderr |
| Historical fixed02 full map, unchanged | 47/785/3/1 | 657 PASS, 124 OBS, 3 FAIL, 1 SKIP | 1 |
| Historical cycle2 stress, incomplete | no COMPLETE | 17 PASS, 700 OBS (717 CHECKs) | 2, `error: missing COMPLETE\n` |

CHECK totals include OBS/SKIP, not just assertions. Both cycle3 builds passed
JassHelper, pJASS and archive verification (parent job1 exit0). Existing tooling
39 Python tests passed once this cycle (0.792s); not rerun here. Compilation and
Python checks do not replace native evidence.

## Logger: bounded correction verified

Maintained `src/lab/Support.j` SHA-256:
`564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d`.
Only Support changed in maintained source (+16/-5), plus documentation; the
core and maintained Environment remain unchanged. This working logger is **not
in the old fixed02 full47 map**. Neither control is a full-release candidate.

Immediate append/counters/order and synchronous persistence are preserved using
one private `TriggerEvaluate` context; no waits, timers, deferred batch or
per-record handle allocation. Compiled initialization occurs after InitBlizzard
and before LabRun. Total cumulative snapshot complexity remains unchanged;
no native VM instruction ceiling was measured.

Stress contains exactly700 `diag2-log-padding-1` through `-700` OBS and one
`diag2-start-progress` OBS:
`phase=5 periods=10 allocated=true launched=true paused=false finished=false`.
All70 original M45 case/status/name/detail/order tuples match the isolation run,
including `coordinate-fixture-live` PASS. No FAIL/SKIP was filtered away.
Independent item3 verifier `mvethryx-3-qxpn` executed one deterministic standard-
library comparison (30s timeout), exit0, blank stderr; exact returned normalized
stdout and comparison boundaries are in [independent-verification.json](independent-verification.json).
Its heredoc body is unavailable and has not been fabricated or rerun. Raw
normalized evidence matches after only identity/provenance,701 named OBS and
COMPLETE771→70 normalization; saved reader report/stdout bytes match, freshness
and input hashes are valid, and the historical first17 assertions match.
S3 scoped PASS, S4 logger-only bounded PASS, S9 scope PASS; S8 runtime was pending
at verifier time. The verifier did **not** accept the later E29 or full feature.

## E29: compare native transfer before separate withdrawal

Readiness OBS: `bounds=true hiddenBoth=true`; positive raw reveal/isolation
`diag2-raw-reveals` PASS. P1/P2 denote JASS Player(1)/Player(2).

| Since stage6 transfer (clock1.500) | Stage / clock | Raw P1/P2 | Primary P1/P2 | Fallback P1/P2 |
|---|---|---|---|---|
| .25s | 7 /1.750 | true/true | true/true | true/true |
| .50s | 8 /2.000 | false/true | false/true | true/false |
| .75s | 9 /2.250 | false/true | false/true | true/false |
| 1.00s | 10 /2.500 | false/true | false/true | true/false |

Exactly three FAILs, preserving public-reader names/details:

- `vision-owner-transfer`: `no cross-player lingering reveal`
- `vision-source-transfer`: `effective source owner changed`
- `diag3-raw-owner-transfer`: `old owner1 loses reveal and new owner2 gains reveal at scheduled0.25s; OBS separates old-retained from new-not-yet-visible`

At .25s the **old owner retains vision while the new owner has gained vision**.
The same scheduled .25s oracle fails the raw native control in this run; this is
not a Missiles-specific diagnosis. Observed convergence by .5s is not a universal
.5s cadence/deadline/guarantee and does not prove all historical withdrawal
failures share a cause. Original .25s assertions were not weakened.

Withdrawal occurred separately at the end of stage10 (clock2.500), after the
positive transfer hold. Every raw/primary/fallback P1/P2 probe was false from
+.25s (stage11) through +2.25s (stage19). Original
`vision-neutral-transfer-clears` and `vision-source-removal-clears` PASS at +.25s;
`diag2-both-withdrawn-at-1.25s` PASS before termination, missiles alive through
+1.25s. These are diagnostic results, not universal S8 or full-feature acceptance.
The one SKIP is `multiplayer`: `single client cannot establish synchronization; repeat with two 1.27b clients`.

## Artifact identities and reproducible provenance

All paths below are relative to `projects/relativistic-classic/`.
[results.json](results.json) records launch times, freshness, per-control paths,
map/input/JASS/public-log hashes, saved stdout/stderr and reader exits. Immutable
[preparation.json](preparation.json) plus each manifest retains all13 input hashes;
its pending claims describe preparation time, superseded by these actual results.

| Control | Map | Map SHA-256 |
|---|---|---|
| Logger | [diag3-logger-stress-20261019-01.w3x](../../build/diag3-logger-stress-20261019-01/diag3-logger-stress-20261019-01.w3x) | `49ab6761f916c381940bf7833fbd8b9fdef2f4e42a589966fe3cd5ffddcc6763` |
| E29 | [diag3-e29-transfer-20261019-01.w3x](../../build/diag3-e29-transfer-20261019-01/diag3-e29-transfer-20261019-01.w3x) | `dc7f288c19055eb9ebfe2af9adfd947be67efd9a5b23676edb750b43b4734d70` |

| Evidence | Logger | E29 |
|---|---|---|
| Manifest SHA-256 | `ffe61b77da3e2bbad47c7d389d33814820e51d177703833045700020b1b74485` | `500257bae52d76a271dbc444289a6631c7d8109d6ac9318ff7a45ecc8c01edb4` |
| Compiled JASS SHA-256 | `7ec245735fbec6d71f9c569a5283f409434ca44563305810e3295c1c6f852da3` | `0ffff85ad5ec670934f589a37ef105d74d22171985206d9c29ec5af9ced05ce2` |
| Public log SHA-256 | `a60e9c710c363be9a707fb7cc32283a7b722486ad734a777bd3db1b9691aa43b` | `2c2bd7cbe38dd5c1d425d8a9432222ce6d9b48266a99bbdd30eb03fc31e30271` |

Core `src/Missiles.j` and both frozen cores:
`adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6`.
Maintained Environment: `021a504533130ffb3e3922f1ca2bca8f37e4209bc51e64906bceca5646e7e41f`.
Historical fixed02 map: `b8b1b9a1e4a072f014a75122a1c96851175c07c7198532f1d900227ee1165859`.
Historical partial stress: `988af5dc815b791f283abeef804b52c136be1671e83d421afeaff184e77651f8`,
78791 bytes. Previous reports, source preparations, inputs and raw streams stay immutable.

## Operational boundaries and remaining proof

Logger gamejob3 exited0 after human close. Parent stopped GUI inputs after
focus/geometry uncertainty; ambiguous images are excluded from evidence. E29
monitorjob4 exited1 (actual reader FAIL). A late authoritative tool event received
by parent reports gamejob5 `wc3 play diag3-e29-transfer-20261019-01` exit0
after11m37s (L34); termination method is not established. No further GUI inputs,
process handling or retries by this reporting unit; assertion results unchanged.

**Risk: item3 shared logger independently verified within bounded scope;
this unit changes documentation/evidence artifacts only.** Native assessment
was unassessable for the untracked candidate, not approval. Verifier scratch
`/tmp/rc-item3-XNICaO` is reported retained; parent/reporting worker did not read
or remove it. No source/test/compiler/game rerun, additional control, commit,
cleanup outside project or review ceremony was performed here.

T5/T6 remain blocked; S8/full47 acceptance with corrected logger is pending a
new human authorization. Multiplayer remains SKIP; editor-save, exhaustion,
performance, arbitrary integration and multiplayer certification remain absent.
S5–S7 provenance is recorded, not freshly executed by this writer. S6 local
preservation and S9 bounded reporting scope are respected.

## Key Learnings
1. Corrected synchronous logging completed the identical native stress workload.
2. All seventy original missile assertions retained their ordered details.
3. Native owner transfer also failed the scheduled quarter-second oracle.
4. Separate withdrawal cleared all probes before missile termination.
5. Diagnostic controls cannot replace full candidate acceptance evidence.
