#!/usr/bin/env python3
"""Compile vJASS with JassHelper --scriptonly, then validate with pJASS."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


def existing_file(value: str) -> Path:
    path = Path(value).expanduser().resolve()
    if not path.is_file():
        raise argparse.ArgumentTypeError(f"file does not exist: {path}")
    return path


def command_plan(args: argparse.Namespace) -> tuple[list[str], list[str]]:
    jasshelper = [str(args.jasshelper)]
    if args.debug:
        jasshelper.append("--debug")
    if args.no_optimize:
        jasshelper.append("--nooptimize")
    jasshelper.extend(["--scriptonly", str(args.common), str(args.blizzard), str(args.input), str(args.output)])
    pjass = [str(args.pjass), str(args.common), str(args.blizzard), str(args.output)]
    return jasshelper, pjass


def run(command: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=cwd, text=True, capture_output=True, check=False)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--jasshelper", required=True, type=existing_file, help="Prefer clijasshelper.exe")
    parser.add_argument("--pjass", required=True, type=existing_file)
    parser.add_argument("--common", required=True, type=existing_file)
    parser.add_argument("--blizzard", required=True, type=existing_file)
    parser.add_argument("--input", required=True, type=existing_file)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--debug", action="store_true")
    parser.add_argument("--no-optimize", action="store_true")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without executing")
    parser.add_argument("--log", type=Path, help="Optional JSON log path")
    args = parser.parse_args()

    args.output = args.output.expanduser().resolve()
    if args.output == args.input:
        parser.error("output must not overwrite input")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    jh_command, pj_command = command_plan(args)

    report: dict[str, object] = {
        "jasshelper_command": jh_command,
        "pjass_command": pj_command,
        "compiled": False,
        "validated": False,
    }
    if args.dry_run:
        print(json.dumps(report, indent=2))
        return 0

    if args.output.exists():
        args.output.unlink()
    jh = run(jh_command, args.input.parent)
    report["jasshelper"] = {"returncode": jh.returncode, "stdout": jh.stdout, "stderr": jh.stderr}
    report["compiled"] = jh.returncode == 0 and args.output.is_file()
    if not report["compiled"]:
        print(jh.stdout, end="")
        print(jh.stderr, end="", file=sys.stderr)
        print("JassHelper did not produce the requested output.", file=sys.stderr)
        if args.log:
            args.log.parent.mkdir(parents=True, exist_ok=True)
            args.log.write_text(json.dumps(report, indent=2), encoding="utf-8")
        return 1

    pj = run(pj_command, args.output.parent)
    report["pjass"] = {"returncode": pj.returncode, "stdout": pj.stdout, "stderr": pj.stderr}
    report["validated"] = pj.returncode == 0
    print(jh.stdout, end="")
    print(jh.stderr, end="", file=sys.stderr)
    print(pj.stdout, end="")
    print(pj.stderr, end="", file=sys.stderr)
    if args.log:
        args.log.parent.mkdir(parents=True, exist_ok=True)
        args.log.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return 0 if report["validated"] else 1


if __name__ == "__main__":
    sys.exit(main())

