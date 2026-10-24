# Cycle4 timeout — actual negative control

**Tested in map**, Warcraft III 1.27b, E29 timeout-control scope only.
S3/S4/S10 evidence is preserved; S8 and full-feature acceptance remain unproved.

`diag4-e29-timeout-20261019-01`: COMPLETE **1/47/1/1**, **28 PASS / 17 OBS / 1 FAIL / 1 multiplayer SKIP**.
Negative-control expectation: PASS. Actual public reader: **exit 1**, status `failed`, stderr exactly empty; its result remains negative.

Only FAIL: `vision-reference-timeout` — `phase=8 wait=native-reference deadline=2.000 elapsed=2.000`.
Reference bounds/hidden eligibility and both actual eligibility flags were true; positive native reveal/isolation PASS.
Eight phase8 checkpoints cover elapsed .250 through 2.000; clock3.750 reports the timeout. Phase13 abort cleanup clears at clock4.000, elapsed .250.
Original cleanup/fallback cleanup, both alliance/fog restoration checks, each onRemove=1, each individual idle=1, and runner idle total=2 PASS.
Unreached original rules are explicitly OBS, not acceptance. No other FAIL or readiness SKIP exists.

## Artifacts and command metadata

`timeout-result.json` stores the normalized public result, exact original reader stdout/stderr, exit/freshness/launch metadata, reader argv recipe (observer interpreter not independently captured), full verification argv/command/exit/stdout/stderr, map/build identities and all evidence hashes.
The public reader was NOT rerun. Its command was reconstructed from the saved observer recipe; its real exit remains 1.

Current JSON SHA-256 after late closure metadata update: `abdc5efdc21ee138b2fc31e3af3b743ef8d2e4326244b6c97001d8b407a62650`

One foreground stdlib verifier (`python3 -B -c <source>`; exact source/argv in JSON), timeout25s: **exit0**, stderr exactly empty. Stdout is the exact normalized proof embedded in JSON. This is evidence consistency, not native GREEN.

### Evidence SHA-256

- `projects/relativistic-classic/build/diag4-e29-timeout-20261019-01/diag4-e29-timeout-20261019-01.w3x` — `caec96f8546846b9e6ca9aef64bf1732a79cf9bf4981998e8be7767d5d8f1182` (307180 bytes)
- `projects/relativistic-classic/build/fixed-20261019-03/fixed-20261019-03.w3x` — `4490afbf0824a89186faf22e3a948452b27fe0ae1a111f3d960a108228fb2694` (307179 bytes)
- `projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/Missiles.j` — `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6` (40740 bytes)
- `projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Environment.j` — `d7fcc7fefbddd724a6bf23f252ede1c46030e020b9f6542023375cab5f9e85b3` (28203 bytes)
- `projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/lab/Support.j` — `564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d` (6371 bytes)
- `projects/relativistic-classic/build/inputs-diag4-e29-timeout-20261019-01/manifest.json` — `fc8793e0c188295d3ea291dbcc8405f2784924d8a2cd2d96d53ce4cf7b1682ef` (11971 bytes)
- `projects/relativistic-classic/reports/RM28-diag4-e29-timeout-20261019-01.txt` — `05501175a865d872e5d645d6942f7572f28d206b59ff223dde3e7e9d57506e07` (8699 bytes)
- `projects/relativistic-classic/reports/cycle4/diag4-e29-timeout-20261019-01-build.stderr.txt` — `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes)
- `projects/relativistic-classic/reports/cycle4/diag4-e29-timeout-20261019-01-build.stdout.json` — `f62585f059543b3befb04b286557cc6bb5f00953d071967bb72dacd739c0706e` (5027 bytes)
- `projects/relativistic-classic/reports/cycle4/diag4-e29-timeout-20261019-01-launch.json` — `d690698802b466aa5a704820bd61b339cf645c3d7c8470e41d55e582baa12b20` (324 bytes)
- `projects/relativistic-classic/reports/cycle4/diag4-e29-timeout-20261019-01-reader-exit.json` — `53f34e83e65af085f0b15c8850e9ce1288d803e48ccafa9d5519972111bbfb88` (97 bytes)
- `projects/relativistic-classic/reports/cycle4/fixed-20261019-03-build.stderr.txt` — `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes)
- `projects/relativistic-classic/reports/cycle4/fixed-20261019-03-build.stdout.json` — `436e6065232ed33e8bc35a68a8e1cf7f8e0eae498c70afd1c05901cfd4d16f59` (4847 bytes)
- `projects/relativistic-classic/reports/cycle4/preparation.json` — `ee074ac718cda930409a442f65e13bebebc36f3bf390423187ce9cfe16df6e0b` (15762 bytes)
- `projects/relativistic-classic/reports/cycle4/tooling-tests.exit.txt` — `9a271f2a916b0b6ee6cecb2426f0b3206ef074578be55d9bc94f6f3fe3ab86aa` (2 bytes)
- `projects/relativistic-classic/reports/cycle4/tooling-tests.stderr.txt` — `41784b854f169fd254f64286cfb0a7fb04f72fbf05a6bccd4a968f746e875104` (3784 bytes)
- `projects/relativistic-classic/reports/cycle4/tooling-tests.stdout.txt` — `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes)
- `projects/relativistic-classic/reports/lab-diag4-e29-timeout-20261019-01.json` — `e6b1e3da986aa652f79ceef53fe45db2734905ab02c83b1bc8985600a4bd6b49` (8232 bytes)
- `projects/relativistic-classic/reports/lab-diag4-e29-timeout-20261019-01.stderr.txt` — `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes)
- `projects/relativistic-classic/reports/lab-diag4-e29-timeout-20261019-01.stdout.json` — `e6b1e3da986aa652f79ceef53fe45db2734905ab02c83b1bc8985600a4bd6b49` (8232 bytes)

## Preserved build evidence and pending work

Both actual JassHelper/pJASS/archive builds exited0 (parent-observed); 39 existing Python tests exited0. These were read only, not rerun.
Core `adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6` and verified logger `564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d` match the frozen negative input. No core/logger edits.
**fixed-20261019-03 ONE already-authorized full47 launched by parent**, gamejob10/observerjob9; outcomes **PENDING**, followed by ONE independent fixture verifier. Compiled map SHA-256 `4490afbf0824a89186faf22e3a948452b27fe0ae1a111f3d960a108228fb2694` unchanged.
Late authoritative event: **gamejob8 EXIT0 observed after10m19s**; owned negative profile released. Termination method is not established or assumed. Initial negative proof and verification streams remain unchanged.
L35 already authorized full47; parent resumed after observed exit without new consent. No GUI input or process/job query occurred here.
Parent checkpoint T5 in_progress; T6/T7 pending, T8 unchanged. No task status changed here. Do not infer full-candidate PASS or production readiness.
Multiplayer, editor-save, exhaustion and arbitrary integration remain unproved. Retained `/tmp/rc-item3-XNICaO` untouched; no new scratch, reruns, extra variants, native authority or commits.

## Key Learnings
1. The actual reader failure remains authoritative negative evidence.
2. Injected pending transfer reaches the precise bounded deadline.
3. Abort cleanup restores flags and alliances before completion.
4. Individual removal counters remain unchanged during idle checks.
5. Full acceptance still requires the authorized forty-seven cases.
