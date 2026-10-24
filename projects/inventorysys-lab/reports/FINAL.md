# Final evaluation evidence — InventorySys 1.4.1

**Strongest current status: Tested in map.** Target: Warcraft III 1.27b;
one own single-client run, bounded 14-case public-API fixture only. This delivers
an evaluated test, not all-green approval, all-feature coverage or core fixes.

## Artifacts and preservation

- [Executable map](runs/inv-baseline-20261019-02/inv-baseline-20261019-02.w3x)
  SHA-256 `574c634cfa95a075643ec40ea80056c4b6143b1ced23598c4f09d5a405448853`.
- [Assembled JASS](runs/inv-baseline-20261019-02/assembled.j)
  SHA-256 `8235fb554965db9d5b12e49a6609d763833065f304bb1501bec5bbf843afc2c4`.
- Original baseline unchanged: SHA-256
  `a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada`.
  No original library/runtime changes. Three adapter insertions reverse exactly to
  original script bytes, including shared demo/system startup.
- [Build and archive report](runs/inv-baseline-20261019-02/build.json): prefix and
  all recovered named members round-trip; 52 raw identities preserved. Neutral
  `(listfile)` rewrite and `(attributes)` addition are allowed housekeeping;
  encrypted housekeeping contents are **not** claimed semantically equivalent.
- Actual full-script pJASS exit 0 and wc3ctl exit 0:
  [exact argv/stdout/stderr/exits](runs/inv-baseline-20261019-02/commands.json),
  [pJASS](runs/inv-baseline-20261019-02/command-1.json),
  [injection](runs/inv-baseline-20261019-02/command-2.json).
  Plain-JASS adapter plus already-generated baseline required no JassHelper;
  no fresh vJASS recompilation is claimed. [Toolchain provenance](toolchain-provenance.json).

## Actual execution, not synthetic gameplay

- Run `inv-baseline-20261019-02`: COMPLETE, 14 cases, **16 PASS / 2 FAIL / 6 OBS /
  4 SKIP**, 166 records; all 14 cases returned. Observer/reader completed after
  approximately 16 seconds. COMPLETE means closed, not all passed.
- [Copied game log](runs/inv-baseline-20261019-02/IL141-inv-baseline-20261019-02.pld),
  [game result](runs/inv-baseline-20261019-02/game-result.json),
  [reader stdout](runs/inv-baseline-20261019-02/reader.stdout.json),
  [stderr](runs/inv-baseline-20261019-02/reader.stderr.txt) (empty),
  [exit](runs/inv-baseline-20261019-02/reader.exit.txt) (1),
  [launch threshold/map identity](runs/inv-baseline-20261019-02/launch-request.json),
  [COMPLETE screenshot](screens/baseline02-complete.png).
- Case 9: combined pickup oracle FAIL remains inconclusive. GetManipulatedItem is
  compared by an observer after original RemoveItem. Source order establishes a
  hazard, not native causality; individual values were not logged. Neither a
  baseline bug nor a definitively invalid oracle is established.
- Case 14: observed custom-ID metadata retained after setItem(0). getItemId is
  instance metadata, not rawcode; the public contract has no clear-empty metadata
  guarantee. Retain the FAIL as a fixture-restoration limitation, not a proven
  contract violation. **Restart the copied map before manual evaluation.**
- Parent verified its own PID 15991, WINEPREFIX and loadfile map hash above, and
  visually observed COMPLETE. Parent then used normal GUI Alt+F4 followed by the
  visible Salir click, with focus/geometry/cursor verified, then Enter on the same
  confirmed dialog. The window was still present at that historical state check.
  A later authoritative completion event reports **game job 4 exit 0 after 2h 26m**.
  The termination mechanism is not established by the event; no force termination
  was used. This closes process tracking, not the two failing test checks.

## Failed attempt and bounded correction history

First actual build `inv-baseline-20261019-01` failed the archive guard after pJASS 0
and wc3ctl 0. Its [tool streams](runs/inv-baseline-20261019-01/commands.json) and
intermediates remain intact; no game run or successful map is claimed for it.
One guard correction had an actual RED replay, then 17 focused / 33 suite GREEN;
[diagnosis](archive-diagnosis.json). Corrected build 02 exited 0. Parent's subsequent
33-test suite exited 0: [stdout](parent-tests.stdout.txt),
[stderr](parent-tests.stderr.txt), [exit](parent-tests.exit.txt).
These are prior observed results, not rerun by this documentation correction.

[Independent verifier mvfiqxos-7-am74](independent-verification.md) observed 17
focused / 33 suite tests exit 0, actual reader 1, help 0, assembly 0 and five
negative public reader probes exit 2 without input/report mutation. Its only blocker
was stale pending/Scanned documentation; this one bounded correction addresses it.
No source, generated JASS, map, toolchain or native authority was changed.

## S1–S4 outcome and remaining advisories

| Spec | Delivered outcome |
|---|---|
| S1 | Actual in-game public-API scenarios, persistent log, reader and honest failures. |
| S2 | Supplied original/demo preserved; bounded baseline evaluation, no core fixes. |
| S3 | Actual pJASS, injection, archive checks and own single-client execution, with streams. |
| S4 | Authorized isolated temp fixtures/copies and retained independent proof; no unrelated temporary locations. |

Pages, sell/drop, sockets and destructive Camera.destroy remain explicit SKIP.
Multiplayer, long-duration leaks/lifetimes and editor reopen/save remain pending.
Original recursive camera, timer/control lifetime, AllShow indexing, local-player
taint and 100 Hz polling concerns remain evaluation targets, not fixes or certified
bugs from this run. No universal compatibility, synchronization or leak-free claim.

## Correction self-check

`tests/test_actual_run.py` integrates the verifier's two tests without scratch-path
or git-history dependencies: public artifact/evidence preservation passed while
stale-document regression failed (exit 1) before the documentation correction.
Only its targeted two-test command is rerun here; no full suite, compiler, native
launch, rebuild or provenance repetition. See [correction results](final-status.json).
No private process/environment dumps, cookies or credentials were copied.

## Independent limited recheck

Verifier `mvfj04yf-9-hqey` resolved the sole documentation blocker: two targeted
regressions passed (exit 0, empty stdout), all 34 documentation links resolved,
protected inputs unchanged. No full suite or native run was repeated. Exact proof
is retained locally under [verification/recheck](verification/recheck/targeted-command.json);
selected original verification streams are in [verification/initial](verification/initial/suite.json).
No native RDD approval is claimed; assessment was unavailable for the untracked scope.
