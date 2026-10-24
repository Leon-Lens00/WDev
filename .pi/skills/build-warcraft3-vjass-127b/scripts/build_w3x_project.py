#!/usr/bin/env python3
"""Build a modular vJASS project and inject verified artifacts into a copied W3X."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path, PureWindowsPath
from typing import Any, Callable


EXPECTED_TARGET = "Warcraft III 1.27b"
WCT_BEGIN = "// wc3project: begin managed import"
WCT_END = "// wc3project: end managed import"
SCRIPT_DIR = Path(__file__).resolve().parent
MPQ_MAGIC = b"MPQ\x1a"
MAX_HEADER_SCAN = 1024 * 1024


def load_sibling(name: str):
    path = SCRIPT_DIR / f"{name}.py"
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load sibling tool: {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules.setdefault(name, module)
    spec.loader.exec_module(module)
    return module


check_toolchain = load_sibling("check_toolchain")
map_inventory = load_sibling("map_inventory")


class BuildError(RuntimeError):
    """A deterministic build or verification failure."""


@dataclass(frozen=True)
class ArchiveFile:
    source: Path
    target: str


@dataclass(frozen=True)
class Project:
    name: str
    target: str
    manifest: Path
    root: Path
    base_map: Path
    entrypoint: Path
    source_root: Path
    toolchain: Path
    mpqeditor: Path
    output_map: Path
    build_dir: Path
    report: Path
    sync_wct: bool
    wct_import: str
    archive_files: tuple[ArchiveFile, ...]


def resolve_from(root: Path, value: str) -> Path:
    path = Path(value).expanduser()
    if not path.is_absolute():
        path = root / path
    return path.resolve()


def paths_alias(left: Path, right: Path) -> bool:
    return left.resolve() == right.resolve() or (
        left.exists() and right.exists() and left.samefile(right)
    )


def paths_overlap(left: Path, right: Path) -> bool:
    left, right = left.resolve(), right.resolve()
    return left == right or left in right.parents or right in left.parents


def source_dependencies(entrypoint: Path) -> set[Path]:
    """Protect literal file imports only; not a JASS preprocessor/search-path resolver."""
    pending, seen = [entrypoint], set()
    pattern = re.compile(r'^\s*//!\s+import\s+(?:(?:jass|vjass|zinc)\s+)?"([^"\r\n]+)"', re.MULTILINE)
    while pending:
        path = pending.pop().resolve()
        if path in seen:
            continue
        seen.add(path)
        if not path.is_file():
            continue
        text = map_inventory.decode_warcraft_text(path.read_bytes())
        pending.extend(resolve_from(path.parent, name) for name in pattern.findall(text))
    return seen


def validate_destinations(destinations: list[Path], inputs: set[Path]) -> None:
    for index, destination in enumerate(destinations):
        for source in sorted(inputs):
            if paths_alias(destination, source) or paths_overlap(destination, source):
                raise ValueError(f"destination must not overwrite input (path collision): {destination} / {source}")
        for other in destinations[:index]:
            if paths_alias(destination, other) or paths_overlap(destination, other):
                raise ValueError(f"destination paths overlap: {destination} / {other}")


def require_string(config: dict[str, Any], field: str) -> str:
    value = config.get(field)
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"missing non-empty string: {field}")
    return value


def validate_mpq_target(target: str) -> str:
    normalized = target.replace("/", "\\").strip()
    path = PureWindowsPath(normalized)
    if (
        not normalized
        or path.is_absolute()
        or path.drive
        or normalized.startswith("\\")
        or any(part in {"", ".", ".."} for part in path.parts)
    ):
        raise ValueError(f"unsafe MPQ target: {target!r}")
    return str(path)


def load_project(manifest_path: Path) -> Project:
    manifest_path = manifest_path.expanduser().resolve()
    try:
        config = json.loads(manifest_path.read_text(encoding="utf-8-sig"))
    except FileNotFoundError as exc:
        raise ValueError(f"project manifest does not exist: {manifest_path}") from exc
    except json.JSONDecodeError as exc:
        raise ValueError(f"invalid project JSON at line {exc.lineno}, column {exc.colno}") from exc
    if not isinstance(config, dict):
        raise ValueError("project manifest must be a JSON object")

    root = manifest_path.parent
    name = require_string(config, "name")
    target = require_string(config, "target")
    base_map = resolve_from(root, require_string(config, "base_map"))
    entrypoint = resolve_from(root, require_string(config, "entrypoint"))
    source_root = resolve_from(root, config.get("source_root", str(entrypoint.parent)))
    toolchain = resolve_from(root, require_string(config, "toolchain"))
    mpqeditor = resolve_from(root, require_string(config, "mpqeditor"))
    output_map = resolve_from(root, require_string(config, "output_map"))
    build_dir = resolve_from(root, config.get("build_dir", "build"))
    report = resolve_from(root, config.get("report", str(build_dir / "build-report.json")))

    if base_map == output_map:
        raise ValueError("output_map must not overwrite base_map")
    if target != EXPECTED_TARGET:
        raise ValueError(f"expected target '{EXPECTED_TARGET}', got {target!r}")

    sync_wct = config.get("sync_wct", True)
    if not isinstance(sync_wct, bool):
        raise ValueError("sync_wct must be boolean")
    wct_import = config.get("wct_import")
    if wct_import is None:
        wct_import = os.path.relpath(entrypoint, output_map.parent).replace("/", "\\")
    if not isinstance(wct_import, str) or not wct_import.strip() or any(char in wct_import for char in "\"\r\n"):
        raise ValueError("wct_import must be a non-empty quote-free path")

    archive_files: list[ArchiveFile] = []
    raw_archive_files = config.get("archive_files", [])
    if not isinstance(raw_archive_files, list):
        raise ValueError("archive_files must be a list")
    for index, item in enumerate(raw_archive_files):
        if not isinstance(item, dict):
            raise ValueError(f"archive_files[{index}] must be an object")
        source = resolve_from(root, require_string(item, "source"))
        target_name = validate_mpq_target(require_string(item, "target"))
        if target_name.lower() in {"war3map.j", "war3map.wct"}:
            raise ValueError(f"archive_files[{index}] targets builder-managed member: {target_name}")
        if any(item.target.casefold() == target_name.casefold() for item in archive_files):
            raise ValueError(f"duplicate MPQ target: {target_name}")
        archive_files.append(ArchiveFile(source=source, target=target_name))

    for field, path in (
        ("base_map", base_map),
        ("entrypoint", entrypoint),
        ("toolchain", toolchain),
        ("mpqeditor", mpqeditor),
    ):
        if not path.is_file():
            raise ValueError(f"{field} does not exist: {path}")
    if not source_root.is_dir():
        raise ValueError(f"source_root does not exist: {source_root}")
    for item in archive_files:
        if not item.source.is_file():
            raise ValueError(f"archive source does not exist: {item.source}")

    project = Project(
        name=name,
        target=target,
        manifest=manifest_path,
        root=root,
        base_map=base_map,
        entrypoint=entrypoint,
        source_root=source_root,
        toolchain=toolchain,
        mpqeditor=mpqeditor,
        output_map=output_map,
        build_dir=build_dir,
        report=report,
        sync_wct=sync_wct,
        wct_import=wct_import,
        archive_files=tuple(archive_files),
    )
    validate_project_paths(project)
    return project


def validate_project_paths(project: Project) -> None:
    inputs = {project.manifest, project.base_map, project.entrypoint, project.toolchain, project.mpqeditor}
    inputs.update(item.source for item in project.archive_files)
    # Reuse toolchain path resolution, without treating identification as patch certification.
    try:
        config = json.loads(project.toolchain.read_text(encoding="utf-8-sig"))
    except json.JSONDecodeError:
        config = {}  # inspect_toolchain reports malformed configs before any writes.
    if isinstance(config, dict):
        for field in check_toolchain.REQUIRED_FILES:
            value = config.get(field)
            if isinstance(value, str) and value.strip():
                inputs.add(check_toolchain.resolved_file(value, project.toolchain.parent))
    inputs.update(path.resolve() for path in project.source_root.rglob("*")
                  if path.is_symlink() and path.is_dir())
    sources = {project.entrypoint}
    sources.update(path for path in project.source_root.rglob("*.j")
                   if not (project.source_root == project.root and project.build_dir != project.root
                           and project.build_dir in path.parents))
    for source in sources:
        inputs.update(source_dependencies(source))
    validate_destinations([project.output_map, project.report], inputs)
    for source in sorted(inputs):
        if paths_overlap(project.build_dir, source):
            raise ValueError(f"build_dir overlaps input: {project.build_dir} / {source}")
    if project.source_root != project.root:
        for destination in (project.build_dir, project.output_map, project.report):
            if paths_overlap(destination, project.source_root):
                raise ValueError(f"destination overlaps source tree: {destination}")
    artifacts = [project.build_dir / name for name in (
        "base-archive.mpq", "compiler-input.j", "war3map.wct", "war3map.compiled.j",
        "compile-report.json", "output-archive.mpq", "base-extract", "verify", "final-extract",
    )]
    validate_destinations(artifacts, inputs | {project.output_map, project.report})
    # Existing extraction trees must not redirect writes through aliases, even to
    # another build artifact. Fresh staging alone would not protect these paths.
    for path in project.build_dir.rglob("*"):
        if path.is_symlink():
            raise ValueError(f"build tree symlink collision: {path}")
        protected = inputs | {project.output_map, project.report}
        if path.is_file() and any(path.resolve() != source.resolve() and paths_alias(path, source)
                                  for source in protected):
            raise ValueError(f"build artifact must not overwrite input/output: {path}")


def render_compiler_input(entrypoint: Path, base_script: str) -> str:
    path = str(entrypoint.resolve())
    if any(char in path for char in "\"\r\n"):
        raise ValueError(f"entrypoint path cannot be embedded safely: {path}")
    return f'//! import "{path}"\n\n{base_script}'


def validate_source_tree(source_root: Path) -> None:
    sources = [source_root] if source_root.is_file() else sorted(source_root.rglob("*.j"))
    for source in sources:
        payload = source.read_bytes()
        if payload.startswith(b"\xef\xbb\xbf"):
            relative = source.name if source_root.is_file() else source.relative_to(source_root)
            raise BuildError(
                f"{relative} has a UTF-8 BOM; save JASS sources as UTF-8 without BOM "
                "because classic JassHelper treats the marker as source text"
            )
        try:
            payload.decode("utf-8")
        except UnicodeDecodeError as exc:
            relative = source.name if source_root.is_file() else source.relative_to(source_root)
            raise BuildError(f"{relative} is not valid UTF-8: {exc}") from exc


def wct_layout(source: bytes) -> tuple[int, int, int]:
    if len(source) < 9:
        raise ValueError("truncated WCT")
    version = struct.unpack_from("<I", source, 0)[0]
    if version != 1:
        raise ValueError(f"unsupported WCT version: {version}")
    comment_end = source.find(b"\0", 4)
    if comment_end < 0:
        raise ValueError("truncated WCT comment")
    length_offset = comment_end + 1
    if length_offset + 4 > len(source):
        raise ValueError("truncated WCT global-script length")
    length = struct.unpack_from("<i", source, length_offset)[0]
    script_start = length_offset + 4
    script_end = script_start + length
    if length < 0 or script_end > len(source):
        raise ValueError("invalid WCT global-script length")
    return length_offset, script_start, script_end


def read_wct_global_script(source: bytes) -> str:
    _, script_start, script_end = wct_layout(source)
    payload = source[script_start:script_end]
    if payload.endswith(b"\0"):
        payload = payload[:-1]
    return map_inventory.decode_warcraft_text(payload)


def replace_wct_global_script(source: bytes, script: str) -> bytes:
    length_offset, _, script_end = wct_layout(source)
    encoded = script.encode("utf-8") + b"\0"
    return source[:length_offset] + struct.pack("<i", len(encoded)) + encoded + source[script_end:]


def upsert_wct_import(source: bytes, import_path: str) -> bytes:
    if not import_path or any(char in import_path for char in "\"\r\n"):
        raise ValueError("unsafe WCT import path")
    length_offset, script_start, script_end = wct_layout(source)
    payload = source[script_start:script_end]
    script = payload[:-1] if payload.endswith(b"\0") else payload
    try:
        script.decode("utf-8")
        encoding = "utf-8"
    except UnicodeDecodeError:
        encoding = "cp1252"
    block = f'{WCT_BEGIN}\n//! import "{import_path}"\n{WCT_END}'.encode(encoding)
    pattern = re.compile(re.escape(WCT_BEGIN.encode()) + b".*?" + re.escape(WCT_END.encode()), re.DOTALL)
    if pattern.search(script):
        script = pattern.sub(lambda _: block, script)
    else:
        script += (b"\n\n" if script else b"") + block + b"\n"
    encoded = script + b"\0"
    return source[:length_offset] + struct.pack("<i", len(encoded)) + encoded + source[script_end:]


def mpq_extract_command(mpqeditor: Path, archive: Path, target: str, destination: Path) -> list[str]:
    return [str(mpqeditor), "extract", str(archive), validate_mpq_target(target), str(destination), "/fp"]


def mpq_add_command(mpqeditor: Path, archive: Path, source: Path, target: str) -> list[str]:
    return [str(mpqeditor), "add", str(archive), str(source), validate_mpq_target(target), "/c"]


def mpq_compact_command(mpqeditor: Path, archive: Path) -> list[str]:
    return [str(mpqeditor), "compact", str(archive)]


def disk_path_for_mpq(root: Path, target: str) -> Path:
    return root.joinpath(*PureWindowsPath(validate_mpq_target(target)).parts)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def prepare_base_archive(base_map: Path, build_dir: Path) -> tuple[Path, bytes]:
    with base_map.open("rb") as source:
        sample = source.read(MAX_HEADER_SCAN)
    offset = sample.find(MPQ_MAGIC)
    if offset < 0:
        raise BuildError(f"MPQ header not found in first {MAX_HEADER_SCAN} bytes: {base_map}")
    if offset == 0:
        return base_map, b""
    if not sample.startswith(b"HM3W"):
        raise BuildError(f"unexpected data before MPQ header at offset {offset}: {base_map}")

    prefix = sample[:offset]
    staged = build_dir / "base-archive.mpq"
    staged.parent.mkdir(parents=True, exist_ok=True)
    with base_map.open("rb") as source, staged.open("wb") as destination:
        source.seek(offset)
        shutil.copyfileobj(source, destination, length=1024 * 1024)
    return staged, prefix


def assemble_headered_map(prefix: bytes, archive: Path, output_map: Path) -> None:
    with output_map.open("wb") as destination, archive.open("rb") as source:
        destination.write(prefix)
        shutil.copyfileobj(source, destination, length=1024 * 1024)


Runner = Callable[..., subprocess.CompletedProcess[str]]


def execute(
    command: list[str],
    *,
    stage: str,
    cwd: Path,
    runner: Runner,
    command_log: list[dict[str, Any]],
) -> subprocess.CompletedProcess[str]:
    result = runner(command, cwd=cwd, text=True, capture_output=True, check=False)
    command_log.append(
        {
            "stage": stage,
            "command": command,
            "returncode": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
        }
    )
    if result.returncode != 0:
        detail = (result.stderr or result.stdout).strip()
        raise BuildError(f"{stage} failed with exit code {result.returncode}: {detail}")
    return result


def extract_member(
    project: Project,
    archive: Path,
    target: str,
    destination: Path,
    *,
    stage: str,
    runner: Runner,
    command_log: list[dict[str, Any]],
) -> Path:
    destination.mkdir(parents=True, exist_ok=True)
    disk_path = disk_path_for_mpq(destination, target)
    if disk_path.exists():
        disk_path.unlink()
    execute(
        mpq_extract_command(project.mpqeditor, archive, target, destination),
        stage=stage,
        cwd=project.root,
        runner=runner,
        command_log=command_log,
    )
    if not disk_path.is_file():
        raise BuildError(f"{stage} did not extract {target} to {disk_path}")
    return disk_path


def build_project(project: Project, runner: Runner = subprocess.run) -> dict[str, Any]:
    validate_project_paths(project)
    validate_source_tree(project.source_root)
    if project.entrypoint.parent != project.source_root:
        validate_source_tree(project.entrypoint)
    toolchain_report = check_toolchain.inspect_toolchain(project.toolchain)
    if not toolchain_report["ok"]:
        raise BuildError(f"toolchain validation failed: {toolchain_report['errors']}")
    project.output_map.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".wc3-", dir=project.output_map.parent) as temporary:
        return _build_project(project, runner, toolchain_report, Path(temporary) / "output.w3x")


def _build_project(project: Project, runner: Runner, toolchain_report: dict[str, Any], staged_map: Path) -> dict[str, Any]:
    project.build_dir.mkdir(parents=True, exist_ok=True)
    project.output_map.parent.mkdir(parents=True, exist_ok=True)
    project.report.parent.mkdir(parents=True, exist_ok=True)
    command_log: list[dict[str, Any]] = []

    base_archive, map_prefix = prepare_base_archive(project.base_map, project.build_dir)
    extract_root = project.build_dir / "base-extract"
    base_script_path = extract_member(
        project,
        base_archive,
        "war3map.j",
        extract_root,
        stage="extract base war3map.j",
        runner=runner,
        command_log=command_log,
    )
    base_script = map_inventory.decode_warcraft_text(base_script_path.read_bytes()).lstrip("\ufeff")
    compiler_input = project.build_dir / "compiler-input.j"
    compiler_input.write_text(
        render_compiler_input(project.entrypoint, base_script),
        encoding="utf-8",
        newline="\n",
    )

    updated_wct: Path | None = None
    if project.sync_wct:
        base_wct_path = extract_member(
            project,
            base_archive,
            "war3map.wct",
            extract_root,
            stage="extract base war3map.wct",
            runner=runner,
            command_log=command_log,
        )
        updated_wct = project.build_dir / "war3map.wct"
        updated_wct.write_bytes(upsert_wct_import(base_wct_path.read_bytes(), project.wct_import))

    execute(
        [sys.executable, str(SCRIPT_DIR / "wc3lint.py"), str(project.source_root), "--json"],
        stage="lint source",
        cwd=project.root,
        runner=runner,
        command_log=command_log,
    )

    tool_files = toolchain_report["files"]
    compiled_jass = project.build_dir / "war3map.compiled.j"
    compile_log = project.build_dir / "compile-report.json"
    execute(
        [
            sys.executable,
            str(SCRIPT_DIR / "compile_vjass.py"),
            "--jasshelper",
            tool_files["jasshelper"]["path"],
            "--pjass",
            tool_files["pjass"]["path"],
            "--common",
            tool_files["common"]["path"],
            "--blizzard",
            tool_files["blizzard"]["path"],
            "--input",
            str(compiler_input),
            "--output",
            str(compiled_jass),
            "--log",
            str(compile_log),
        ],
        stage="compile and validate",
        cwd=project.root,
        runner=runner,
        command_log=command_log,
    )
    if not compiled_jass.is_file():
        raise BuildError(f"compiler did not produce {compiled_jass}")

    working_archive = project.build_dir / "output-archive.mpq"
    shutil.copy2(base_archive, working_archive)

    managed_files: list[tuple[Path, str]] = [(compiled_jass, "war3map.j")]
    if updated_wct:
        managed_files.append((updated_wct, "war3map.wct"))
    managed_files.extend((item.source, item.target) for item in project.archive_files)

    for source, target in managed_files:
        execute(
            mpq_add_command(project.mpqeditor, working_archive, source, target),
            stage=f"inject {target}",
            cwd=project.root,
            runner=runner,
            command_log=command_log,
        )
    execute(
        mpq_compact_command(project.mpqeditor, working_archive),
        stage="compact output map",
        cwd=project.root,
        runner=runner,
        command_log=command_log,
    )

    assemble_headered_map(map_prefix, working_archive, staged_map)
    final_archive, final_prefix = prepare_base_archive(staged_map, project.build_dir / "final-extract")
    if final_prefix != map_prefix or sha256(final_archive) != sha256(working_archive):
        raise BuildError("final assembled map header/archive mismatch")

    verification: list[dict[str, Any]] = []
    verify_root = project.build_dir / "verify"
    for index, (source, target) in enumerate(managed_files):
        extracted = extract_member(
            project,
            final_archive,
            target,
            verify_root / f"{index:03d}",
            stage=f"verify {target}",
            runner=runner,
            command_log=command_log,
        )
        source_hash = sha256(source)
        extracted_hash = sha256(extracted)
        if source_hash != extracted_hash:
            raise BuildError(f"round-trip mismatch for {target}: {source_hash} != {extracted_hash}")
        verification.append(
            {
                "target": target,
                "source": str(source),
                "sha256": source_hash,
                "size": source.stat().st_size,
            }
        )

    staged_map.replace(project.output_map)
    report = {
        "ok": True,
        "name": project.name,
        "target": project.target,
        "manifest": str(project.manifest),
        "base_map": {"path": str(project.base_map), "sha256": sha256(project.base_map)},
        "output_map": {
            "path": str(project.output_map),
            "sha256": sha256(project.output_map),
            "size": project.output_map.stat().st_size,
        },
        "entrypoint": str(project.entrypoint),
        "map_header_size": len(map_prefix),
        "sync_wct": project.sync_wct,
        "wct_import": project.wct_import if project.sync_wct else None,
        "verification": verification,
        "toolchain": toolchain_report,
        "commands": command_log,
        "verification_state": "Validated",
        "remaining_tests": ["Open copied map in World Editor", "Test in Warcraft III 1.27b", "Run two-client test for sync claims"],
    }
    project.report.write_text(json.dumps(report, indent=2), encoding="utf-8")
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path, help="Path to wc3project.json")
    args = parser.parse_args()
    try:
        project = load_project(args.manifest)
        report = build_project(project)
    except (ValueError, BuildError, OSError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
