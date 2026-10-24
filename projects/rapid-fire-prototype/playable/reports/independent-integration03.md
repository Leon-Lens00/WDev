# Independent integration03 review

Reviewer: `gentle-ai-verify`, task `mvhacot6-y-14lb`. Scope: T4 / S1–S17 / S28, concurrency/lifecycle risk item4. This is an independent source review, not native review authority or a second gameplay execution.

## Result

No severe source defect established. Functional acceptance remained pending when the reviewer inspected evidence. It read the entire feature document and candidate application/vendor sources.

Independently recomputed pins:
- Map: `f7b71361e79d9abc77eb282c66b3a5dd94b20ec91bf5f3c311b60fe31c2a535f`.
- Compiled script: `157fe83ce4049c5ca83ea6f63da4abfdfe43231c3eb92b804d09062f64b4f28f`.
- PairCore: `ea1020eb095391e7731bf8f9a8dd42f59d195efc110cd05afc9bf02b49c52afc`.
- IntegratedTest: `1f6d829facc27a9e2ccde9b0f7de70cb7a76ea7a7346a3236a7b56426c64dd87`.

All13 immutable build-input hashes match the build03 record and current corresponding application files. All seven originals in packaging preparation retain recorded hashes and mtimes. Build exit0 was read, not repeated.

## Findings

Paths refer to build03 `src/`:
- `PairCore.j:326–340`: logical-only anchoring follows deferred cancellation, with epoch checks after both coordinate setters. Visible actor collision checks remain intact.
- `PairCore.j:268–307,384–402`: revision-checked deferred Stop and native Move handoff; no source-level deadlock identified.
- `PairCore.j:449–458,625–666`: epoch guards protect Emit and disposal callbacks against writing into a new pair. Flights retain visible-source snapshots.
- `IntegratedTest.j:402–410,621–650`: aborted scenes remain FAIL; producers are disposed, existing flights drain within3s, then normal cleanup delay runs. They cannot reach behavioral assessment. Deadline/reappearing-flight failures remain terminal.
- Fresh public collection scans avoid dereferencing saved recycled tokens. Local-player branches affect selection/camera only.

## Evidence limits

The current native03 report and copied raw log were absent at the reviewer's single evidence check. It did not poll or run the public reader. No game, compiler, process, GUI, Git or application-closing actions occurred. No scratch artifacts were created. A `wc` glob included a directory and returned1; this was not a product failure.

S1–S8/S10/S11/S13–S17: implemented but native acceptance unverified at this review. S9/S12: rendered appearance unverified. S28: copied implementation/preservation partially met; successful battery and final playable delivery outstanding. S18–S27 are superseded historical grants.

Remaining evidence: native order consumption/anchoring/facing, paused-target HP behavior, integrated outcomes, rendered UI/animation and multiplayer. These are unknowns, not invented source defects. No native approval or blanket prototype acceptance is claimed.
