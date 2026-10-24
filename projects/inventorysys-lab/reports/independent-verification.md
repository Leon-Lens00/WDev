# Independent verification and bounded documentation correction

Verifier: `mvfiqxos-7-am74`. This report summarizes retained prior independent
observations. The original bounded correction was subsequently rechecked by
`mvfj04yf-9-hqey`, as recorded below; no new full review was performed.
Strongest current artifact status: **Tested in map**, bounded single-client scope
only; see [final report](FINAL.md) for map/hash and actual failing game outcomes.

## Retained independent evidence

Proof root: `/tmp/wdev-inventorysys-lab/verify-Jpktho/` (authorized temp root;
retained, not required by committed tests). Exact argument arrays and exits are in
the named JSON files; adjacent `.stdout` and `.stderr` files retain exact streams.
All Python invocations use workshop Python
`/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B`.
Paths below abbreviate that proof root only for readability, not executable commands.

| Evidence file | Actual command scope | Observed result |
|---|---|---|
| `focused.json`, `focused.stdout`, `focused.stderr` | unittest discover in copied project/tests, `-p test_build.py -v` | 17 tests, exit 0 |
| `suite.json`, `suite.stdout`, `suite.stderr` | unittest discover in copied project/tests, `-v` | 33 tests, exit 0 |
| `reader.json`, `reader.stdout`, `reader.stderr` | public reader, copied actual log, exact run ID, `--not-before 1792430180.0629613`, new actual-report.json | exit 1, complete 16/2/6/4 result, empty stderr |
| `build-help.json`, `reader-help.json` and matching streams | public build/reader `--help` | exit 0 each |
| `assemble.json`, `assemble.stdout`, `assemble.stderr` | public assemble, copied baseline/globals/functions, entry IL_Start, run ID inv-001, fresh assembly output | exit 0 |
| `probes.json`, `probes/*.stdout`, `probes/*.stderr` | wrong-ID, stale, truncated, bad-counter, existing-report public CLI probes | five exits 2; stdout empty; exact stderr `error: invalid evidence\n`; inputs/existing report unchanged |

`independent-structure.json` records original/map/assembled hashes, exact reversal
of three insertions, 18 named members, 47 WCT slots, 52 preserved raw identities,
166 log rows and all 14 cases returned. `final-integrity.json` records unchanged
original and 101 protected copied files, workspace/copy agreement and probe exits.
Housekeeping exceptions do not establish encrypted-content semantic equivalence.

## Disposition of the only blocker

The verifier's artifact/public-evidence regression passed. Its stale-documentation
regression failed (exit 1): README and evaluation still described T3 as pending and
current status as Scanned despite actual execution. The exact supplied
`regression-test-content.txt` was integrated into
[project-relative tests](../tests/test_actual_run.py), preserving both assertions
and artifact checks, without a dependency on this temp root or git history.
The correction worker independently observed the same RED before editing docs.

This bounded correction changes documentation/evidence and tests only. It preserves
both game FAILs and reader exit 1, interprets case 9 as inconclusive and case 14 as a
fixture-restoration limitation, and does not repair baseline internals. Final
correction-only command/results are in [final-status.json](final-status.json).
Independent verification's 17/33 counts exclude these two newly integrated tests;
no new full-suite result is claimed.

Parent-provided execution provenance: own PID 15991/WINEPREFIX/loadfile verified,
COMPLETE screenshot observed; normal GUI Alt+F4, visible Salir click and Enter with
focus/geometry/cursor verified. The window remained present at that historical
check. A later authoritative event reports game job 4 exit 0 after 2h 26m; its
termination mechanism is not established. No force termination was used.
Pages, sell/drop, sockets and destructive camera are SKIP; multiplayer, leak lifetime
and editor-save remain untested. No private dumps or credentials were copied.

## Limited recheck — PASS

`mvfj04yf-9-hqey` ran only the two targeted regressions in a fresh authorized
isolated directory: exit 0, empty stdout, two tests OK; all 34 local documentation
links resolved. The original documentation blocker is closed. Exact command and
streams are copied to [verification/recheck](verification/recheck/targeted-command.json);
selected initial proof is in [verification/initial](verification/initial/suite.json).
Original protected inputs remained unchanged. No further correction was requested.
