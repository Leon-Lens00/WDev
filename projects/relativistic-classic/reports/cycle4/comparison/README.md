# Independent comparison evidence — retained, not rerun

The failed V1 and corrected V2 proof below are exclusive byte-for-byte copies
from the two live-S12-authorized roots. Only minimal proof was copied: no workspace,
source/map input copies, caches or home/tmp directories. Both invocations contain
only the nine necessary isolation/control environment names and values; **no
redaction was needed**. Actual argv/cwd/timeout, scripts, stdout/stderr and exit
remain exact. These scripts are evidence, not commands to execute or a CI physics
regression test reading immutable logs.

| Attempt | Observed result | Evidence |
| --- | --- | --- |
| failed-v1 / mvexqx1v-i-bl4g | exit1, empty stdout, optional-freshness KeyError | [invocation](failed-v1/invocation.json), [script](failed-v1/comparison.py), [stdout](failed-v1/stdout.txt), [stderr](failed-v1/stderr.txt), [result/exit](failed-v1/result.json) |
| passed-v2 / mvexzndm-j-5179 | exit0, empty stderr, scoped PASS | [invocation](passed-v2/invocation.json), [script](passed-v2/comparison.py), [stdout](passed-v2/stdout.txt), [stderr](passed-v2/stderr.txt), [result/exit](passed-v2/result.json) |

Each directory also preserves `identities.json` and `git-status-before.txt` /
`git-status-after.txt`. V2 additionally preserves [the only correction](passed-v2/v1-to-v2.patch),
[dynamic differences](passed-v2/dynamic-differences.json), [legacy freshness](passed-v2/legacy-freshness.json)
and [V1 preservation](passed-v2/v1-preservation.json).

Actual corrected invocation (historical evidence, **do not rerun**):

```text
/usr/bin/python3 -B /tmp/wdev-relativistic-fixed03-verify/corrected-a44wAHM5/comparison.py /tmp/wdev-relativistic-fixed03-verify/corrected-a44wAHM5
cwd: /tmp/wdev-relativistic-fixed03-verify/corrected-a44wAHM5/workspace
timeout_seconds: 25
exit_code: 0
stderr: empty
```

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
