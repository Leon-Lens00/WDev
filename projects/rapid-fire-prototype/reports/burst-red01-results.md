# B01+B02 — RED_OBSERVED_VALID_FIXTURE

Actual parent native `rf-burst-red-20261019-01` completed **`COMPLETE|2|19|7|0` = 4 PASS / 8 OBS / 7 FAIL / 0 SKIP**; public reader **EXIT1**, report `failed`. All seven expected behavioral failures occurred with a **valid fixture**, not readiness ABORT. This establishes meaningful RED, **not validation acceptance, implementation success or Game GREEN**.

## Native readiness and failure evidence

- Calibration: one native damage event10.000, source visible actor (parent-reported source check); native HP335.000→325.007. Calibration is excluded from burst events.
- Actual point order accepted; one matching A00G spell effect/source/actual target point. Observation horizon is3s after that native event.
- Stub produced **0 shots / 0 hits**. Target and paired control both325.180→325.930; differential0.000. Shared regeneration did not fabricate burst damage. Control undamaged and both units alive passed.
- Six B01 FAILs: four shot notifications, four real public projectiles, four native hits, native ten-per-hit, visible damage source, paired native HP differential40. B02 FAIL: missing four shot pulses/three cadence intervals.

## Saved proof — unchanged

- [Raw](RF-rf-burst-red-20261019-01.txt), [public report](native-rf-burst-red-20261019-01.json).
- `burst-red01-native-reader.{exit.json,stderr.txt,stdout.json}`; launch request/stdout/stderr remain preserved.
- Reader freshness: launch/not-before1792457505.4549522, source mtime1792457518.11079. Saved report raw SHA `e46e52f822f5271a5965dd3e167bba539e3ef10cd840a2699a67028931775288`; not rehashed here.
- Parent build23 map `89281148a4e02089d2b4dead55a1f96644850c294fce1fbb389f4df95f3c0c8d`; compiled script `8a8f3096260b8b2bef557ee0edc669ab1e41951be945f0ff7790be1d853d238e`.
- **Launcher25 exit unreported**; no game closure/profile availability inferred. Launcher exit would be wrapper evidence only.

## Next phase, not yet implemented

T1 remains **done SCOPED** prerequisites only. T2 in_progress(observedRED_B01_B02_minimalGreenpending), T3–T5 pending; Specs unchanged. Parent continues minimal B01/B02 GREEN under original T2 authorization, **no scope question needed**. Keep RED source/plan/raw/streams/map immutable; use new Core/new run plan and `rf-burst-green-20261019-01`. No GREEN implementation/run exists yet, and this bookkeeping worker starts/queues none.

Only partial S1/S4/S5/S10/S11 count/cadence/native4hit10/source/pairedHP coverage; other rules deferred. No mover/recast/obstacle/animation/UI/MP/full-prototype acceptance follows. Independent Risk4/T4 remains after actual implementation. Only passive saved-JSON/path/checkpoint readback occurred here; no functional check or native rerun.
