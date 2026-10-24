# Manual recorder delivery

## Delivered artifact

**Strongest current status: Validated**, Warcraft III 1.27b, manual artifact only.

- [Convenience map](../../maps/InventorySys-Manual-20261019-01.w3x): exclusively created binary copy, source unchanged.
- SHA-256: `26d7faf7953feb98a991222c77bf92c1fed58ffef534e2a874ba8ddd3a8f28fe`.
- [Actual source artifact](runs/inv-manual-20261019-01/inv-manual-20261019-01.w3x) and [build report](runs/inv-manual-20261019-01/build.json).
- Generated JASS SHA-256: `3836c03662507dcc372a9d08a8efc0603cdb0fb78e3e3eddd1edfc0f8c55f418`.
- Retained actual pJASS exit 0 and wc3ctl packaging exit 0: [command records](runs/inv-manual-20261019-01/commands.json).
  No JassHelper required: the original libraries are already compiled plain JASS.
- Separate archive result: original prefix and 17 named non-script members preserved;
  52 identity-bound raw assets preserved, subject only to the existing neutral
  listfile rewrite/attributes addition policy. Independent audit reversed all 36
  insertion spans to the original script bytes. Timing equivalence is not claimed.

No game, GUI, compiler, rebuild or manual-log analysis was launched during this
unit. No original fixes, new core bug conclusions, editor-save or multiplayer
certification. Historical automatic evaluation remains separate: 16 PASS / 2 FAIL /
6 OBS / 4 SKIP, unchanged; it does not establish manual-recorder runtime behavior.

## Human handoff and pending evidence

Follow the [launch command and bounded 10–15 minute action sequence](../../docs/manual-testing.md).
[delivery.json](delivery.json) records build `inv-manual-20261019-01`, unused label
`prueba01`, full external Logs directory and the `time.time()` delivery freshness
floor `1792440879.7859807`. The read-only directory check found no matching chunks.
Expected pattern: `IL141M-inv-manual-20261019-01--prueba01--*.pld`.

One session per launch; every restart requires a new checked label. Stop testing
and notify the parent if recording stops or overflows. After `-im stop`, wait for
the stopped acknowledgement and then two seconds before normal exit; acknowledgement
is not disk proof. Crashes may leave partial evidence: report them without forcing
continuation. The user confirms “terminé”, label and visible anomalies. Only then
will the parent read the full matching chunk set from the existing profile, without
requiring pasted file contents. Do not select a subset manifest.

**T4: awaiting_user. Actual runtime writing remains unknown.** Reader completeness
is only structural; `semantic_certification=false` and
`runtime_writing_verified=false` remain explicit even for a complete synthetic file.

## Independent evidence retained exactly

The accepted independent T2 verification is `mvfoq9rj-c-0qk1`; no new independent
review or native approval is claimed. Minimal byte-exact retained proof:

- [command-summary.json](verification/command-summary.json): original command/result records.
- [audit.stdout](verification/audit.stdout), [audit.stderr](verification/audit.stderr), [audit.exit](verification/audit.exit): audit exit 0, preservation details.
- [isolated-suite.stderr](verification/isolated-suite.stderr), [isolated-suite.stdout](verification/isolated-suite.stdout), [isolated-suite.exit](verification/isolated-suite.exit): adjusted 67-test suite exit 0.
- [edges.stderr](verification/edges.stderr), [edges.stdout](verification/edges.stdout), [edges.exit](verification/edges.exit): one edge test exit 0.

These are the actual available filenames; there were no separate audit.json,
isolated-suite.json or edges.json records. No workspace, caches or environment
snapshot was copied. Original verifier scratch was not changed. The command summary
also records successful assembly-example/help checks; these are syntax evidence,
not native compilation or gameplay. Initial verifier suite: 66 tests, exit 0;
adjusted isolated suite: 67 tests, exit 0; parent suite separately: 66 tests, exit 0.

**Precise process deviation:** initial verifier fixtures were created under the
already user-authorized `/tmp/wdev-inventorysys-lab/` root, but as siblings outside
the narrower parent-required isolated child. Their own automatic teardown cleaned
them. Later verification used an adjusted isolated copy and passed 67 tests. This
was not outside the user's root authorization. The parent accepted the disclosed
deviation; no candidate implementation blocker or source fix remained.

## Delivery self-verification

S6 authorizes exactly the minimal test_build.py/test_logs.py fixture-root changes:
respect supplied TMPDIR, retain the authorized-root fallback, leave all assertions
and public CLI cases unchanged. The imported independent edge regression changes
only temporary-directory selection, not assertions. It covers the 128-row checkpoint
(partial, exit 1), terminal row 129 (complete, exit 0), ignored unrelated session,
invalid continuations/exclusive report (exit 2, exact streams and preserved bytes).
No meaningful new-behavior RED applies to this port/documentation unit.

Both commands ran once, foreground, 30-second timeout, no retries, using this prefix:

```sh
HOME=/tmp/wdev-inventorysys-lab/manual-delivery-y26kx657/home TMPDIR=/tmp/wdev-inventorysys-lab/manual-delivery-y26kx657/tmp XDG_CACHE_HOME=/tmp/wdev-inventorysys-lab/manual-delivery-y26kx657/cache PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B
```

- `-m unittest discover -s projects/inventorysys-lab/tests -p test_manual_protocol_edges.py -v`: exit 0; stdout empty; stderr one test `ok`, `Ran 1 test in 0.240s`, `OK`.
- `-m unittest discover -s projects/inventorysys-lab/tests -v`: exit 0; stdout empty; stderr all 67 tests `ok`, `Ran 67 tests in 2.158s`, `OK`.

All generated fixtures stayed inside that fresh child; tests clean their fixtures.
The empty home/tmp/cache scratch directories remain for parent cleanup. No git-history
differential applies: no command/parser/runtime code changed; the full suite preserves
existing public behavior while only fixture placement changes.

## Spec self-review

- S1: preparation met: exact map, launch instructions and action sequence delivered;
  actual user operation/completion is pending, not fabricated.
- S2: capture design validated and public-reader regression retained; runtime file
  writing and observed human interactions await T4.
- S3: no fixes to original inventory logic; this unit changes no instrumentation,
  hooks, builders, readers, originals or map contents.
- S4: existing workshop/profile only; no install, launcher creation or game launch.
- S5: historical child-location deviation disclosed precisely and accepted; current
  tests isolated inside one fresh authorized child.
- S6: only the two approved helper-root substitutions; original assertions preserved.

## Key learnings

1. Validation and archive preservation do not prove manual gameplay or disk writing.
2. A 128-row checkpoint is partial until a valid terminal arrives in the next chunk.
3. Session labels must be new each launch; acknowledgements cannot guarantee persistence.
4. TMPDIR must govern outer fixture roots, not merely nested subprocess environments.
5. Deferred snapshots are observations, not causal or semantic correctness certificates.
