# Run the public-API evaluation without fixing the baseline

**Current status: Tested in map**, Warcraft III 1.27b, single-client bounded scope.
T3 completed whole-script classic pJASS and packaging (both tool exits 0), then the
actual 14-case run: COMPLETE, 16 PASS / 2 FAIL / 6 OBS / 4 SKIP, 166 records.
The public reader exits 1; this is not all-green approval or coverage of every feature.
T4's independent startup/evidence verification completed; its stale-documentation
blocker is addressed here. See [final artifacts and interpretation](../reports/FINAL.md)
and [independent verification](../reports/independent-verification.md).
No fresh vJASS recompile is claimed: the adapter and preserved generated baseline
are plain JASS, so no JassHelper was needed. Python tests alone prove no gameplay.

## Quick path

1. Use the README assembly/build commands with a new run ID; do not reuse evidence.
2. T3 records wall-clock Unix seconds immediately before launching its own copy.
   Do not interact with the hero until the IL141 COMPLETE message (normally seconds).
3. Read `CustomMapData/Logs/IL141-RUN_ID.pld` as **data**, never as executable JASS.
   Require the exact run ID and an mtime at or after the recorded launch threshold.
4. Preserve failures. After automated coverage, restart the map for manual evaluation
   if restoration or any watchdog fails; do not repair the original library.

Example reader invocation (replace the run and freshness values with T3 evidence):

```sh
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/read_logs.py /tmp/wdev-inventorysys-lab/T3_FRESH_CHILD/IL141-inv-001.pld --run-id inv-001 --not-before 1790000000 --report /tmp/wdev-inventorysys-lab/T3_FRESH_CHILD/read-report.json
PYTHONDONTWRITEBYTECODE=1 /home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/python/bin/python -B projects/inventorysys-lab/tools/read_logs.py --help
```

The example does not create a directory, copy a game log, or authorize a game launch.
The report parent must already exist; `--report` is optional and exclusively creates
one new file. Existing input/report files, aliases and symlinks are never overwritten.
Filesystem freshness is not authentication: a copied/touched log can have a new mtime.
Unique assembly run IDs and T3's observed launch/log provenance remain necessary.

## Automated matrix

All cases are independently timer-dispatched into a trigger action. A separate
four-second timer watchdog is armed and its marker persisted before scenario calls.
Calls have before/after CHECK markers. Aborted threads get FAIL, not a fake return;
dependent probes then SKIP. Case 14 still closes the runner, but an OBS explicitly
marks aborted-state restoration unknown. COMPLETE means the runner closed, not that
all APIs returned or passed. Engine crashes can still prevent COMPLETE altogether.

| Case | Attempt / expected public observations |
|---|---|
| 1 | After 2-second delay, native-enumerate exactly one living Player(0) hero; require playing human controller, existing Inventory/Equipment bridges and registered fixture. Never create another per-player inventory: buttons are shared. |
| 2 | Read all 150 public slot identities; require initially empty inventory and fixture count zero. Existing items prevent mutation probes, not deletion of their state. No callable currentPage getter exists; page zero is subsequently inferred from the first insertion at slot zero. |
| 3 | Snapshot all 150 identities/custom IDs, fixture and zero-type counts, all three hero stats; addItem(0) must return false with the entire snapshot unchanged. |
| 4 | Add existing registered `rst1`; require identity at slot 0 and fixture count 1, other slots empty. |
| 5 | Add same registry definition again; require first two identities and type count 2. |
| 6 | Fill current page to 30; require exact first-30 identity layout, type count 30, remaining 120 empty. This is not a 150-item-capacity test. |
| 7 | Snapshot before add 31; require rejection, unchanged 30 identities/custom IDs/type count and remaining 120 empty. |
| 8 | Public setItem(slot 7,0), require count 29/free slot 7; refill and require exact 30-layout/count restored. |
| 9 | Remove only lab-owned fixtures; native CreateItem + UnitAddItem drives the actual pickup event. Require one observed native event, removed physical item, retained public registry identity and positive custom instance ID. Native UnitAddItem return is OBS because removal occurs in the callback. |
| 10 | Snapshot before equip into wrong slot 0; require false and unchanged inventory/counts/all hero stats. |
| 11 | Public equip fixed fixture into slot 8 (source slot 9); require true, strength including bonuses +3, unchanged agility/intelligence and inventory/counts. |
| 12 | Snapshot before re-equipping occupied slot 8; require false, unchanged inventory/counts/all hero stats. |
| 13 | Unequip only the successful lab equip; require true, exact original strength/agility/intelligence and unchanged inventory/counts. |
| 14 | Remove remaining lab-owned fixtures, verify empty public slots/count and original stats; separately compare all initial custom IDs. Emit named interactive SKIPs and observational limitations. |

A slot identity is the public `InvItem` registry reference; repeated types intentionally
share that reference. Per-slot custom IDs distinguish native pickup instances. The
fixture-count checks cover the only inserted type, `rst1`; zero-type count is also
snapshotted for rejection. They are **not** private itemCount or arbitrary-type-table
inspection. Equipment fields have no callable generated getters: occupied state is
observed through equip rejection, subsequent unequip and native stat restoration,
not a direct all-equipment-slot snapshot. No stronger state claim is made.

### Fixture and restoration rules

`baseline/wct/trigger-014.j` registers `rst1`, icon `B00K`, cost 100, no inventory
ability, equipment slot 9, exactly one fixed BONUS_STRENGTH +3 and maxSockets 1.
No random-range or custom socket bonus is introduced. Direct API probes use this
unmodified registered definition, not new fake item definitions or private wrappers.
Pickup obtains its custom ID through the original native event handler, not by
fabricating InvEvent globals. No Socket methods are invoked: they require context
that has no public lowered callable setter.

Ownership is marked before mutation at expected initially empty slots. Cleanup checks
the current identity before removing anything; it never wipes all 150 slots or
unequips an item unless the adapter's own equip succeeded. Unexpected preexisting
inventory causes explicit SKIPs. Do not manually change pages, move/equip items or
change hero stats while the automated run is active. Concurrent user changes are not
transactionally protected. Never claim cleanup after an aborted mutation is known.

**Observed fixture-restoration limitation:** case 14 retained custom-ID metadata
after setItem(index,0), even though visible inventory/stats restored. Public getItemId
returns instance metadata, not an item rawcode; the public contract does not guarantee
that clearing an empty slot also clears metadata. This FAIL is not a proven contract
violation. There is no callable public tempCustomId setter or clear-custom-ID method.
The adapter does not access private storage or fabricate a setter to make the check
pass. Restart the copied map before further evaluation. Full metadata restoration
cannot be guaranteed under the allowed baseline/public API; this is a fixture
limitation, not core-fix authorization.

**Case 9 remains inconclusive:** the combined pickup assertion compares
GetManipulatedItem in an observer after the original handler's RemoveItem. Source
ordering establishes an oracle hazard, not native causality. Individual comparison
values were not logged, so neither a core bug nor a definitively invalid oracle is
established. Retain the FAIL and reader exit 1; do not reinterpret it as PASS.

## Public source to generated mapping

References are exact recovered ORIGINAL bytes, not a newly compiled approximation.
The structural tests pin these signatures to `baseline/members/war3map.j`.

| WCT public source | Actual lowered callable signature |
|---|---|
| WCT 1 Inventory[u] | `s__Inventory__staticgetindex(unit u) -> integer` |
| WCT 8 Equipment[u] | `s__Equipment__staticgetindex(unit u) -> integer` |
| WCT 1 getItem(index) | `s__Inventory_getItem(integer this,integer index) -> integer` |
| WCT 1 getItemId(index) | `s__Inventory_getItemId(integer this,integer index) -> integer` |
| WCT 1 itemsOfType(id) | `s__Inventory_itemsOfType(integer this,integer id) -> integer` |
| WCT 1 setItem(index,itm) | `s__Inventory_setItem(integer this,integer index,integer itm) -> nothing` |
| WCT 1 findFreeSlot(page) | `s__Inventory_findFreeSlot(integer this,integer page) -> integer` |
| WCT 1 addItem(itm) | `s__Inventory_addItem(integer this,integer itm) -> boolean` |
| WCT 8 equip(itm,slot) | `s__Equipment_equip(integer this,integer itm,integer equipSlot) -> boolean` |
| WCT 8 unequip(itm,slot) | `s__Equipment_unequip(integer this,integer itm,integer slot) -> boolean` |
| WCT 2 GetInvItem(id) | `GetInvItem(integer id) -> integer` |

The original pickup implementation is WCT 17, `AcquireItem___Actions` in generated
JASS; it is **never manually invoked**. Native observer registration only counts real
`EVENT_PLAYER_UNIT_PICKUP_ITEM`. WCT 0 creates the demo and its mappings. No
PlayerHero, library internal arrays, allocators, event callbacks or tables are read
or written by the adapter. The builder preserves original main, including shared
system/demo initialization, and adds only the delayed IL_Start hook at the end.

## Evidence grammar and reader outcomes

Every row is ASCII with exactly six fields:

```text
IL141|RUN_ID|SEQUENCE|KIND|CASE_ID|PAYLOAD
```

- Run IDs: 1–80 ASCII alphanumeric/underscore/hyphen, first alphanumeric; unique per
  assembly/run. Sequence starts at 1 and increases by one without duplicates/gaps.
- Payload: 1–160 characters from `[A-Za-z0-9 _=.,:+-]`; no pipes, quotes, escapes,
  control characters or script. Runtime callers supply fixed ASCII literals and
  integer formatting only, with defensive delimiter/length checks. Maximum 512
  records, 262144 input bytes. Logger overflow/unsafe data prevents valid completion.
- BEGIN: case `-`, payload `schema=1`, exactly first.
- CASE: unique non-`-` case ID, payload `before`; no nested/reopened cases.
- CHECK: progress/before/after markers, not a passing assertion.
- PASS/FAIL/OBS/SKIP: outcomes inside current case, increment their own counters.
- RESULT: closes a nonempty case with exact ordered payload
  `pass=N fail=N obs=N skip=N`, computed from that case's outcomes.
- COMPLETE: case `-`, exactly last, exact ordered payload
  `cases=N pass=N fail=N obs=N skip=N`, checked against all closed cases.

Raw rows and the inert PreloadGen wrapper are accepted; malformed rows containing
IL141 and unknown wrapper/script lines are rejected. UTF-8 with LF or CRLF and final
newline is required. The reader never executes the preload file. Cumulative snapshots
are regenerated through a separate trigger-condition, following the proven
`projects/relativistic-classic/src/lab/Support.j` pattern, not one giant case thread.

| Exit | Exact CLI effect |
|---|---|
| 0 | Complete, zero FAIL; stdout is sorted, indented JSON plus newline; stderr empty. OBS/SKIP set `inconclusive: true`, never `all_passed`. |
| 1 | Genuine complete FAIL, same JSON/stdout/report contract; stderr empty. |
| 2 | Wrong ID, stale/missing/truncated/malformed evidence, bad counters, unsafe/duplicate rows, unsafe destinations or report creation errors: stdout empty; stderr `error: invalid evidence` plus newline; no existing report/input modified. Argument syntax errors use argparse usage/exit 2. |

JSON fields are `cases`, `fail`, `inconclusive`, `obs`, `pass`, `run_id`, `skip`.
An optional new report receives the exact stdout JSON bytes, including on exit 1.
The reader enforces structural completeness, not a cryptographic guarantee or a
specific 14-case manifest; T3 must compare the case matrix and built run provenance.

## Interactive / observational work that remains

Automated output must not imply these passed:

- **Pages:** open the demo bag ability; insert distinct items, click both page arrows
  across all five pages and wrap boundaries; check displayed slots and per-page
  placement. addItem scans only the current 30-cell page.
- **Sell/drop:** select a real item, click Sell/Drop; test both Yes and No, item/currency
  effects, physical drop location, reacquisition and inventory retention on cancel.
- **Sockets:** obtain one gem and socketable equipment in the demo; select the gem
  then target, confirm/cancel. Observe custom-ID-specific bonuses, max socket boundary,
  equip/unequip restoration. Never fabricate click/dialog event context.
- **Camera/control lifetime:** repeat open/close/click sequences and inspect visuals.
  The optional destructive Camera.destroy probe is deliberately disabled (SKIP), not
  a PASS. No recursion call can suppress earlier cases. No timer/live-instance leak
  counters are publicly available; no absence-of-leaks claim is possible here.
- **Synchronization:** original local-player-dependent display/texture paths reach
  unit transforms and object allocation. Single-client runs do not establish safe
  multiplayer behavior; two-client and long-duration tests remain unperformed.

Keep original findings (recursive Camera.destroy, timer/control lifetime, AllShow
indexing, local-player taint and 100 Hz polling) as evaluation targets, not fixes.

## Self-review / next evidence

- S1: actual persistent log and strict reader delivered; COMPLETE and both FAILs retained.
- S2: original generated script and WCT APIs/fixture preserved; no original core fixes.
- S3: actual pJASS 0, injection 0, corrected build 0 and own-game execution delivered;
  no JassHelper recompile, multiplayer or editor-save claim.
- S4: prior fixture/copy verification used authorized isolated temp children. This
  documentation correction's two tests only read project-relative retained artifacts.
- Independent verification observed 17 focused and 33 suite tests passing, reader 1,
  help 0 and assembly 0. This correction reruns only `test_actual_run.py`, not those
  checks or native tools. Structural reversal of the three insertions preserves the
  original shared startup bytes; it does not alone prove engine behavior.
- Pages, sell/drop, sockets and destructive camera remain SKIP; multiplayer, leak
  lifetime and editor-save checks remain pending. Restart before manual evaluation.
  See [final report](../reports/FINAL.md) for exact artifact/stream links.
