# Rapid Fire packaging preparation (Classic 1.27b)

Status: **Scanned**, not compiled or tested in map by this preparation unit.
Run commands from the WDev repository root. Never overwrite an existing output.

## Prepare the visible ability base

The parent integration run can execute this exact command once:

```sh
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 python -B projects/rapid-fire-prototype/playable/tools/prepare_objects.py --base projects/rapid-fire-prototype/playable/base/owned-original.w3x --recipe projects/rapid-fire-prototype/playable/base/objects-playable.json --out projects/rapid-fire-prototype/playable/base/playable-01.w3x --evidence projects/rapid-fire-prototype/playable/reports/objects-playable-01
```

This command **mutates only new map copies** through the registered `wc3ctl`.
It was not executed during packaging preparation. Both destinations must be new.
The helper validates every recipe row before creating output or evidence; rejects
symlink destinations, overlapping inputs/outputs, duplicates and unknown fields;
and retains metadata-selected types, levels and Data selectors. It reuses the
copied builder's guards and exclusive-create writer. Arguments use an argv list,
never a shell. Failed archive operations retain fresh evidence; do not reuse it.

For recipe-only checks, append `--validate-only` to the same command. This checks
recipe validation and destination guards without opening the MPQ, launching tools,
or creating output/evidence. `--help` lists the supported UI fields.

## Overlay and provenance

`owned-original.w3x` is byte-identical to the preserved
`../base/burst-instant-controller-01.w3x` (SHA-256
`dea9c6cbac7e486d7c4fc11267fc1ed7b17c483d11f6f1025ecad6f45dc5c7ad`).
The overlay changes only owned `A00G`, parent `ANcl`:

| Field | Storage / level | Value |
| --- | --- | --- |
| Ncl3 | channelFlags integer / 1, Data C selector 3 | 1: visible (0 hidden remains supported) |
| anam | Profile Name string / 0 | Rapid Fire |
| ahky | Profile Hotkey char, serialized string / 0 | Q |
| abpx / abpy | Profile Buttonpos integer / 0 | 0 / 2 |
| atp1 / aub1 | Profile Tip / Ubertip string / 1 | English title and controls/shot description |

Declarations were read from the installed Classic `AbilityMetaData.slk`;
`WorldEditStrings.txt` lists Visible as the first Channel flag
(`WESTRING_UE_CHANNELFLAGS_VISIBLE`). The local TFT-v1.27b enum schema lists the
Channel flag entries. Only the requested hidden/visible values 0/1 are allowed,
not other flag combinations. UI declarations are checked against their exact
Profile field/type/repeat/data declarations before serialization. Hotkeys are
limited to one ASCII letter or digit. No general unknown-type fallback exists.

No icon asset was independently verified: the inherited Channel icon is retained,
and no arbitrary icon-path field was added. Verify its actual button appearance in
Classic. The recipe does not alter unit IDs, abilities, cast points, damage,
cadence, terrain or W3I. Existing o000/o001 settings remain in the copied base;
Q fires, native S stops and native right-click moves (integration must implement
and verify the proxy behavior).

`src/vendor/{TimerUtils,WorldBounds,DummyRecycler,Missiles}.j` are byte-exact copies
of the selected `projects/relativistic-classic/src` snapshots, including comments,
credits and existing configuration. Copying is authorized for this local project;
no broader redistribution license is inferred. `tools/build.py` is an unchanged
copy of that project's builder. Pass explicit Classic tool/library/bootstrap
arguments supplied by the integration plan; the builder's CLI is unchanged.
Hashes, original mtimes and verification command results are recorded in
`reports/packaging-preparation.json`.

## Compiler-free verification

```sh
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 python -B projects/rapid-fire-prototype/playable/tools/prepare_objects.py --help
/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3 python -B projects/rapid-fire-prototype/playable/tests/tooling/verify_prepare.py
```

The finite public CLI checks cover visible/new and hidden/old recipes, existing
controller timing fields, invalid enum/kind/type/level/bounds/hotkey, repeated and
unknown fields, actor timing rejection, no-overwrite, evidence freshness and
symlink rejection. Rejected recipes run without `--validate-only` to prove they
fail before archive mutation/output. All assert exact exit/stdout/stderr,
unchanged input and absent newly requested output/evidence. Fixtures live only in
fresh temporary children of `tests/tooling/`, cleaned by `TemporaryDirectory`.
`-B` prevents bytecode caches. Separate RED is waived by S28.

Still required: prepare the new base, re-extract/read back its typed A00G records
(including Ncl3 selector 3, hotkey and tooltips), verify all unrelated archive bytes
through the helper's preservation report, compile the integrated sources, and
check actual selection/button/icon, targeting, S/right-click and gameplay in
Classic 1.27b. No editor-save or multiplayer certification is implied.
