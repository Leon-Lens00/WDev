#!/usr/bin/env python3
"""Check toolchain structure and fingerprints, not patch provenance or compiler compatibility.

No executable is invoked. PASS means structural checks only; compatibility remains unverified.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any


EXPECTED_TARGET = "Warcraft III 1.27b"
REQUIRED_FILES = ("jasshelper", "pjass", "common", "blizzard")
MODERN_SYMBOL = re.compile(r"\b(?:native|function)\s+(Blz[A-Za-z0-9_]*|FourCC)\b")
# Mask lexical trivia only; this is not a JASS parser or complete API inventory.
TRIVIA = re.compile(r'"(?:\\.|[^"\\])*"|//[^\r\n]*|/\*.*?(?:\*/|\Z)', re.DOTALL)


def code_only(source: str) -> str:
    return TRIVIA.sub(lambda match: re.sub(r"[^\r\n]", " ", match.group()), source)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def resolved_file(value: str, config_dir: Path) -> Path:
    path = Path(value).expanduser()
    if not path.is_absolute():
        path = config_dir / path
    return path.resolve()


def error(code: str, message: str, *, field: str | None = None) -> dict[str, str]:
    finding = {"code": code, "message": message}
    if field:
        finding["field"] = field
    return finding


def inspect_toolchain(config_path: Path) -> dict[str, Any]:
    report: dict[str, Any] = {
        "ok": False,
        "config": str(config_path),
        "target": None,
        "files": {},
        "errors": [],
        "warnings": [error(
            "COMPATIBILITY_UNVERIFIED",
            "Structural checks and SHA-256 fingerprints do not verify 1.27b provenance, "
            "complete API compatibility, compiler capabilities, execution, or in-game behavior.",
        )],
        "compatibility_verified": False,
    }
    try:
        config_path = config_path.expanduser().resolve()
        report["config"] = str(config_path)
        config = json.loads(config_path.read_text(encoding="utf-8-sig"))
    except FileNotFoundError:
        report["errors"].append(error("CONFIG_MISSING", f"config file does not exist: {config_path}"))
        return report
    except json.JSONDecodeError as exc:
        report["errors"].append(error("CONFIG_JSON", f"invalid JSON at line {exc.lineno}, column {exc.colno}"))
        return report
    except UnicodeError:
        report["errors"].append(error("CONFIG_ENCODING", "config must be UTF-8 (optional BOM)"))
        return report
    except (OSError, ValueError, RuntimeError) as exc:
        report["errors"].append(error("CONFIG_READ", str(exc)))
        return report

    if not isinstance(config, dict):
        report["errors"].append(error("CONFIG_TYPE", "toolchain config must be a JSON object"))
        return report

    report["target"] = config.get("target")
    if report["target"] != EXPECTED_TARGET:
        report["errors"].append(
            error("TARGET_MISMATCH", f"expected target '{EXPECTED_TARGET}', got {report['target']!r}", field="target")
        )

    resolved: dict[str, Path] = {}
    sources: dict[str, str] = {}
    for field in REQUIRED_FILES:
        value = config.get(field)
        if not isinstance(value, str) or not value.strip():
            report["errors"].append(error("MISSING_FIELD", f"missing path for {field}", field=field))
            continue
        try:
            path = resolved_file(value, config_path.parent)
            resolved[field] = path
            item: dict[str, Any] = {"path": str(path), "exists": path.is_file()}
            report["files"][field] = item
            if not item["exists"]:
                report["errors"].append(error("MISSING_FILE", f"file does not exist: {path}", field=field))
                continue
            item["size"] = path.stat().st_size
            item["sha256"] = sha256(path)
            if item["size"] == 0:
                report["errors"].append(error("EMPTY_FILE", f"file is empty: {path}", field=field))
            if field in ("common", "blizzard"):
                # Preserve legacy source decoding tolerance; this scan is not provenance evidence.
                sources[field] = path.read_text(encoding="utf-8", errors="replace")
        except (OSError, ValueError, RuntimeError) as exc:
            report["errors"].append(error("FILE_READ", f"cannot inspect {field}: {exc}", field=field))

    jasshelper = resolved.get("jasshelper")
    if (jasshelper and report["files"].get("jasshelper", {}).get("exists")
            and jasshelper.name.lower() != "clijasshelper.exe"):
        report["warnings"].append(
            error("JASSHELPER_FRONTEND", "prefer clijasshelper.exe for deterministic command-line compilation", field="jasshelper")
        )

    for field, source in sources.items():
        path = resolved[field]
        symbols = sorted(set(MODERN_SYMBOL.findall(code_only(source))))
        if symbols:
            report["errors"].append(
                error(
                    "MODERN_API",
                    f"modern API surface in {path.name}: {', '.join(symbols)}",
                    field=field,
                )
            )

    report["ok"] = not report["errors"]
    return report


def print_text(report: dict[str, Any]) -> None:
    status = "PASS (structural checks only; compatibility unverified)" if report["ok"] else "FAIL"
    print(f"{status}: {report['target'] or 'unknown target'}")
    for field in REQUIRED_FILES:
        item = report["files"].get(field)
        if not item:
            print(f"- {field}: not configured")
        elif not item["exists"]:
            print(f"- {field}: missing ({item['path']})")
        elif "sha256" not in item:
            print(f"- {field}: unreadable ({item['path']})")
        else:
            print(f"- {field}: {item['sha256']}  {item['path']}")
    for finding in report["errors"]:
        print(f"ERROR {finding['code']}: {finding['message']}")
    for finding in report["warnings"]:
        print(f"WARNING {finding['code']}: {finding['message']}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("config", type=Path, help="Path to wc3toolchain.json")
    parser.add_argument("--json", action="store_true", help="Emit JSON")
    args = parser.parse_args()

    report = inspect_toolchain(args.config)
    if args.json:
        print(json.dumps(report, indent=2))
    else:
        print_text(report)
    return 0 if report["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
