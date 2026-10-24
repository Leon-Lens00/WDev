#!/usr/bin/env python3
"""Freeze explicit review files (Python 3.10+); no agent/API calls."""
from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path, PurePosixPath

MARKER = ".judgment-day-manifest.json"
MAX_FILE = 4 << 20
MAX_TOTAL = 64 << 20


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def tree_id(files: dict[str, str]) -> str:
    return digest(json.dumps(files, sort_keys=True, separators=(",", ":")).encode())


def inside(root: Path, relative: str) -> Path:
    rel = PurePosixPath(relative)
    if not relative or rel.is_absolute() or ".." in rel.parts or MARKER in rel.parts or rel.as_posix() == ".":
        raise ValueError(f"invalid review path: {relative}")
    current = root
    for part in rel.parts:
        current = current / part
        if current.is_symlink():
            raise ValueError(f"symlink is outside the snapshot contract: {relative}")
    if not current.resolve().is_relative_to(root):
        raise ValueError(f"path escapes scope: {relative}")
    return current


def create(root: Path, destination: Path, relative_files: list[str]) -> dict:
    root = root.resolve(strict=True)
    destination = destination.absolute()
    # Resolve the parent too, so symlinks cannot turn a sibling into recursion.
    destination = destination.parent.resolve(strict=True) / destination.name
    if not root.is_dir() or destination == root or destination.is_relative_to(root):
        raise ValueError("snapshot destination must be outside the source directory")
    if destination.exists() or destination.is_symlink():
        raise ValueError("snapshot destination already exists")
    if not relative_files or len(relative_files) > 2000:
        raise ValueError("select between 1 and 2000 explicit files")
    payloads = {}
    total = 0
    for value in relative_files:
        path = inside(root, value)
        name = path.relative_to(root).as_posix()
        if name in payloads or not path.is_file() or path.stat().st_size > MAX_FILE:
            raise ValueError(f"duplicate, non-file or source larger than 4 MiB: {value}")
        data = path.read_bytes()
        total += len(data)
        if len(data) > MAX_FILE or total > MAX_TOTAL:
            raise ValueError("source exceeds snapshot size limits; narrow the scope")
        payloads[name] = data
    files = {name: digest(data) for name, data in sorted(payloads.items())}
    result = {"format": 1, "source_root": str(root), "files": files, "tree_sha256": tree_id(files)}
    destination.mkdir()
    for name, data in payloads.items():
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        target.chmod(0o444)
    marker = destination / MARKER
    marker.write_text(json.dumps(result, indent=2) + "\n")
    marker.chmod(0o444)
    verify_source(root, destination, result["tree_sha256"])
    return {"snapshot": str(destination), "tree_sha256": result["tree_sha256"], "files": len(files)}


def verify(root: Path, expected: str) -> dict:
    root = root.resolve(strict=True)
    if not re.fullmatch(r"[a-f0-9]{64}", expected):
        raise ValueError("an expected SHA-256 from the parent is required")
    marker = root / MARKER
    if marker.is_symlink():
        raise ValueError("manifest must not be a symlink")
    manifest = json.loads(marker.read_text())
    if not isinstance(manifest, dict):
        raise ValueError("manifest must be a JSON object")
    files = manifest.get("files")
    if manifest.get("format") != 1 or not isinstance(files, dict) or not files or len(files) > 2000:
        raise ValueError("invalid snapshot manifest")
    if any(not isinstance(k, str) or not isinstance(v, str) or not re.fullmatch(r"[a-f0-9]{64}", v) for k, v in files.items()):
        raise ValueError("invalid file identity")
    if tree_id(files) != expected or manifest.get("tree_sha256") != expected:
        raise ValueError("manifest does not match the parent's frozen identity")
    actual = set()
    for path in root.rglob("*"):
        if path.is_symlink():
            raise ValueError("snapshot contains a symlink")
        if not path.is_dir() and path.name != MARKER:
            actual.add(path.relative_to(root).as_posix())
    # Only the root manifest is metadata; nested files with that name are not exempt.
    nested = [p for p in root.rglob(MARKER) if p != marker]
    if nested or actual != set(files):
        raise ValueError("snapshot file set changed")
    total = 0
    for name, sha in files.items():
        path = inside(root, name)
        if not path.is_file() or path.stat().st_size > MAX_FILE:
            raise ValueError(f"file missing or oversized: {name}")
        data = path.read_bytes()
        total += len(data)
        if total > MAX_TOTAL or digest(data) != sha:
            raise ValueError(f"snapshot content changed: {name}")
    return {"verified": True, "tree_sha256": expected, "files": len(files)}


def verify_source(source: Path, snapshot: Path, expected: str) -> dict:
    """Bind the reviewed bytes to the current, explicitly supplied source root."""
    result = verify(snapshot, expected)
    source = source.resolve(strict=True)
    if not source.is_dir():
        raise ValueError("source root must be a directory")
    manifest = json.loads((snapshot / MARKER).read_text())
    for name, sha in manifest["files"].items():
        path = inside(source, name)
        if not path.is_file() or path.stat().st_size > MAX_FILE or digest(path.read_bytes()) != sha:
            raise ValueError(f"original source changed since snapshot: {name}")
    return {**result, "source_matches": True, "source_root": str(source)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="mode", required=True)
    make = sub.add_parser("create")
    make.add_argument("root", type=Path)
    make.add_argument("destination", type=Path)
    make.add_argument("files", nargs="+")
    check = sub.add_parser("verify")
    check.add_argument("snapshot", type=Path)
    check.add_argument("expected_sha256")
    live = sub.add_parser("verify-source")
    live.add_argument("root", type=Path)
    live.add_argument("snapshot", type=Path)
    live.add_argument("expected_sha256")
    args = parser.parse_args()
    try:
        if args.mode == "create":
            result = create(args.root, args.destination, args.files)
        elif args.mode == "verify-source":
            result = verify_source(args.root, args.snapshot, args.expected_sha256)
        else:
            result = verify(args.snapshot, args.expected_sha256)
    except (OSError, ValueError, TypeError) as error:
        print(json.dumps({"error": str(error)}))
        return 1
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
