#!/usr/bin/env python3
"""Create a read-only inventory of an extracted Warcraft III map directory."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
import sys
from pathlib import Path


LIBRARY = re.compile(r"^\s*library(?:_once)?\s+([A-Za-z_]\w*)(.*)$", re.I | re.M)
STRUCT = re.compile(r"^\s*(?:private\s+|public\s+)?struct\s+([A-Za-z_]\w*)(?:\s+extends\s+([A-Za-z_]\w*))?", re.I | re.M)
MODULE = re.compile(r"^\s*(?:private\s+|public\s+)?module\s+([A-Za-z_]\w*)", re.I | re.M)
INTERFACE = re.compile(r"^\s*(?:private\s+|public\s+)?interface\s+([A-Za-z_]\w*)", re.I | re.M)
KEYWORD = re.compile(r"^\s*(?:private\s+|public\s+)?keyword\s+([A-Za-z_]\w*)", re.I | re.M)
FUNCTION = re.compile(r"^\s*(?:private\s+|public\s+|constant\s+)?function\s+([A-Za-z_]\w*)", re.I | re.M)
TEXTMACRO = re.compile(r"//!\s*textmacro\s+([A-Za-z_]\w*)", re.I)
RUN_TEXTMACRO = re.compile(r"//!\s*runtextmacro\s+([A-Za-z_]\w*)", re.I)
RAWCODE = re.compile(r"'([^'\r\n]{4})'")
IMPORT = re.compile(r"//!\s*import\s+\"([^\"]+)\"", re.I)


KNOWN_FILES = {
    "war3map.j": "compiled_or_source_jass",
    "war3map.lua": "lua_script",
    "war3map.w3e": "terrain",
    "war3mapunits.doo": "placed_units",
    "war3map.doo": "placed_doodads",
    "war3map.w3u": "unit_objects",
    "war3map.w3t": "item_objects",
    "war3map.w3a": "ability_objects",
    "war3map.w3b": "destructable_objects",
    "war3map.w3d": "doodad_objects",
    "war3map.w3q": "upgrade_objects",
    "war3map.w3h": "buff_objects",
    "war3map.w3i": "map_info",
    "war3map.imp": "imports_manifest",
    "war3map.wts": "trigger_strings",
    "war3map.wtg": "gui_triggers",
    "war3map.wct": "custom_trigger_text",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def dependencies(tail: str) -> list[str]:
    match = re.search(r"\b(?:requires|uses|needs)\b\s+(.+?)(?:\binitializer\b|$)", tail, re.I)
    if not match:
        return []
    modifiers = {"optional"}
    return sorted(
        {
            part.strip()
            for part in re.split(r"\s*,\s*|\s+", match.group(1))
            if re.match(r"^[A-Za-z_]\w*$", part.strip()) and part.strip().lower() not in modifiers
        }
    )


def analyze_jass_text(text: str, source: str) -> dict[str, object]:
    libraries = [{"name": match.group(1), "requires": dependencies(match.group(2))} for match in LIBRARY.finditer(text)]
    return {
        "path": source,
        "libraries": libraries,
        "structs": [{"name": m.group(1), "extends": m.group(2)} for m in STRUCT.finditer(text)],
        "modules": sorted(set(MODULE.findall(text))),
        "interfaces": sorted(set(INTERFACE.findall(text))),
        "keywords": sorted(set(KEYWORD.findall(text))),
        "functions": sorted(set(FUNCTION.findall(text))),
        "textmacros": sorted(set(TEXTMACRO.findall(text))),
        "runtextmacros": sorted(set(RUN_TEXTMACRO.findall(text))),
        "imports": sorted(set(IMPORT.findall(text))),
        "rawcodes": sorted(set(RAWCODE.findall(text))),
        "blz_calls": sorted(set(re.findall(r"\b(Blz[A-Za-z0-9_]*)\s*\(", text))),
        "get_local_player_count": len(re.findall(r"\bGetLocalPlayer\s*\(", text)),
    }


def analyze_jass(path: Path, root: Path) -> dict[str, object]:
    text = path.read_text(encoding="utf-8", errors="replace")
    return analyze_jass_text(text, path.relative_to(root).as_posix())


class WctReader:
    def __init__(self, data: bytes):
        self.data = data
        self.offset = 0

    def read_int32(self, signed: bool = True) -> int:
        if self.offset + 4 > len(self.data):
            raise ValueError("truncated WCT integer")
        value = int.from_bytes(self.data[self.offset : self.offset + 4], "little", signed=signed)
        self.offset += 4
        return value

    def read_cstring(self) -> str:
        end = self.data.find(b"\0", self.offset)
        if end < 0:
            raise ValueError("truncated WCT null-terminated string")
        value = decode_warcraft_text(self.data[self.offset:end])
        self.offset = end + 1
        return value

    def read_custom_text(self) -> str:
        length = self.read_int32()
        if length < 0:
            raise ValueError("invalid negative WCT custom-text length")
        if length == 0:
            return ""
        end = self.offset + length
        if end > len(self.data):
            raise ValueError("truncated WCT custom-text block")
        block = self.data[self.offset:end]
        self.offset = end
        if not block.endswith(b"\0"):
            raise ValueError("invalid WCT custom-text terminator")
        return decode_warcraft_text(block[:-1])


def decode_warcraft_text(data: bytes) -> str:
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        return data.decode("cp1252", errors="replace")


def analyze_wct_bytes(data: bytes, source: str = "war3map.wct") -> dict[str, object]:
    reader = WctReader(data)
    first_word = reader.read_int32(signed=False)
    wrapper_magic = None
    if first_word == 0x80000004:
        wrapper_magic = "0x80000004"
        version = reader.read_int32()
    else:
        version = first_word
    if version not in (0, 1):
        raise ValueError(f"unsupported WCT version: {version}")

    comment = ""
    global_script = ""
    if version == 1:
        comment = reader.read_cstring()
        global_script = reader.read_custom_text()

    triggers = []
    if wrapper_magic:
        while reader.offset < len(data):
            index = len(triggers)
            text = reader.read_custom_text()
            triggers.append(
                {
                    "index": index,
                    "text": text,
                    "vjass": analyze_jass_text(text, f"{source}#trigger-{index}"),
                }
            )
        trigger_count = len(triggers)
    else:
        trigger_count = reader.read_int32(signed=False)
        if trigger_count > (len(data) - reader.offset) // 4:
            raise ValueError("truncated WCT trigger table")
        for index in range(trigger_count):
            text = reader.read_custom_text()
            triggers.append(
                {
                    "index": index,
                    "text": text,
                    "vjass": analyze_jass_text(text, f"{source}#trigger-{index}"),
                }
            )

    return {
        "path": source,
        "wrapper_magic": wrapper_magic,
        "version": version,
        "comment": comment,
        "global_custom_script": global_script,
        "global_vjass": analyze_jass_text(global_script, f"{source}#global"),
        "trigger_count": trigger_count,
        "non_empty_trigger_count": sum(bool(trigger["text"].strip()) for trigger in triggers),
        "triggers": triggers,
        "trailing_bytes": len(data) - reader.offset,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--hash", action="store_true", help="Hash every extracted file")
    args = parser.parse_args()
    root = args.directory.expanduser().resolve()
    if not root.is_dir():
        parser.error(f"not a directory: {root}")

    files = []
    for path in sorted(p for p in root.rglob("*") if p.is_file()):
        relative = path.relative_to(root).as_posix()
        entry: dict[str, object] = {
            "path": relative,
            "size": path.stat().st_size,
            "kind": KNOWN_FILES.get(path.name.lower(), "import_or_unknown"),
        }
        if args.hash:
            entry["sha256"] = sha256(path)
        files.append(entry)

    wct_files = sorted(path for path in root.rglob("*") if path.is_file() and path.name.lower() == "war3map.wct")
    report = {
        "root": str(root),
        "files": files,
        "jass": [analyze_jass(path, root) for path in sorted(root.rglob("*.j")) if path.is_file()],
        "custom_text_triggers": [
            analyze_wct_bytes(path.read_bytes(), path.relative_to(root).as_posix()) for path in wct_files
        ],
        "limitations": [
            "war3map.wct can preserve editable JASS/vJASS, but external //! import file contents may still be absent.",
            "war3map.wtg metadata and GUI ECA trees require a separate trigger-data-aware parser.",
            "Protected or optimized maps may remove WTG/WCT and leave only compiled war3map.j.",
            "Binary object and terrain data require a separate reviewed translator.",
        ],
    }
    payload = json.dumps(report, indent=2, ensure_ascii=False)
    if args.output:
        args.output = args.output.expanduser().resolve()
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(payload + "\n", encoding="utf-8")
    else:
        print(payload)
    return 0


if __name__ == "__main__":
    sys.exit(main())
