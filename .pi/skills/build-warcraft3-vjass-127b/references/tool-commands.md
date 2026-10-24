# Bundled tool commands

Paths below are relative to the skill directory; run from that directory or resolve them explicitly. Python 3.10+ is required. Forms reflect the current argparse help, not evidence of real compiler execution. Bracketed items are optional syntax, not literal shell arguments.

## Read-only audit

```text
python3 -B scripts/check_toolchain.py CONFIG [--json]
python3 -B scripts/wc3lint.py PATH [--json]
python3 -B scripts/map_inventory.py EXTRACTED_DIR [--hash] [--output REPORT]
```

- Checker: verifies the target label, required nonempty files, resolved paths, sizes/hashes and a narrow modern-declaration scan. `ok` means only these structural checks passed; `compatibility_verified` is always `false`. It invokes no executables. See [prerequisites](toolchain-requirements.md).
- Linter: conservative lexical scan only, not all functions, imports or dataflow; see [limitations](lint-limitations.md).
- Inventory: reads an already extracted tree, inventories files and editable WCT blocks. It does not extract MPQ, decode WTG ECA trees or validate library APIs. `--hash` fingerprints every file. Omit `--output` for stdout-only audit: that option creates directories/writes a JSON report and requires write authorization. Its source detection is regex-based; inspect enabled WTG/WCT entries manually.

## Authorized implementation only

Review [build safety](build-safety.md) and the host/distribution requirements before these commands. The scripts do not provide a sandbox or automatically invoke Wine.

```text
python3 -B scripts/compile_vjass.py --jasshelper EXE --pjass EXE --common FILE --blizzard FILE --input FILE --output FILE [--debug] [--no-optimize] [--dry-run] [--log FILE]
python3 -B scripts/build_w3x_project.py MANIFEST
```

The compiler plans JassHelper `--scriptonly COMMON BLIZZARD INPUT OUTPUT`, adding `--debug` and/or `--nooptimize` as requested, followed by `pjass COMMON BLIZZARD OUTPUT`. It runs JassHelper from the input directory and pJASS from the staged output directory; publish requires both success and generated output. `--dry-run` prints the command plan only, creates no files/logs, and proves no compilation. Input existence/path checks still apply. `--log` writes compiler results; output/log must not overlap each other or protected inputs. No automatic pJASS patch switches are supplied: review the chosen build's grammar/options, not a guessed `+oldpatch`.

The builder accepts only a manifest positional argument (no dry-run option). It composes imports with the base script, scans, compiles, checks pJASS, updates the managed WCT block, injects into a copy, compacts and verifies managed-member hashes from the assembled final map before publication. It does not deduplicate project code already compiled into the base or regenerate WTG. Review all manifest paths and tool directives before execution.

## Templates and evidence

Use [project manifest](../assets/project-template/wc3project.example.json), [toolchain manifest](../assets/project-template/wc3toolchain.example.json) and [project rules](../assets/project-template/AGENTS.md) only after creation authorization. Replace placeholder paths and supply an authorized base map; the template contains no map or compiler installation. Keep `src/Main.j` as the only project entrypoint and preserve its relative `//! import` structure, not regex concatenation.

Follow [testing definitions](testing-matrices.md) for status, scope, final-map hashes, editor reopening and game/multiplayer checks. A Python test-suite pass exercises scripts/fixtures, not an actually compiled or playable map.
