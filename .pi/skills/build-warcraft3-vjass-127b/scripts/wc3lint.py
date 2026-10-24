#!/usr/bin/env python3
"""Conservative static checks for Warcraft III 1.27b JASS/vJASS sources."""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path


@dataclass(frozen=True)
class Finding:
    severity: str
    rule: str
    path: str
    line: int
    message: str


SIMPLE_RULES = (
    ("ERROR", "WC127-BLZ", re.compile(r"\bBlz[A-Za-z0-9_]*\b"), "Blz API is not vanilla Warcraft III 1.27b."),
    ("ERROR", "WC127-FOURCC", re.compile(r"\bFourCC\s*\("), "Use a verified four-character rawcode literal for 1.27b."),
    ("WARNING", "WAIT-IMPRECISE", re.compile(r"\b(?:TriggerSleepAction|PolledWait)\s*\("), "Waits are imprecise; review whether a timer/scheduler is required."),
    ("WARNING", "EXECUTEFUNC", re.compile(r"\bExecuteFunc\s*\("), "String callbacks need exact generated names and minification review."),
    ("WARNING", "UNIT-USERDATA-WRITE", re.compile(r"\bSetUnitUserData\s*\("), "Only the authorized UnitIndexer should write unit user data."),
    ("ERROR", "FOREIGN-ARRAY-SYNTAX", re.compile(r"\b(?:integer|real|boolean|string|unit|timer|group)\s*\[\s*\]"), "Foreign array syntax is not classic vJASS syntax."),
    ("ERROR", "INVALID-METHOD-SIGNATURE", re.compile(r"\bmethod\s+(?:integer|real|boolean|string|unit|nothing)\s+[A-Za-z_]\w*\s*\("), "Use `method Name takes ... returns ...` syntax."),
)

HANDLE_FACTORIES = re.compile(
    r"\b(?:CreateTimer|CreateTrigger|CreateGroup|CreateForce|CreateUnit|CreateItem|"
    r"AddSpecialEffect|AddLightning|CreateTextTag|Location|Rect|Condition|Filter)\s*\("
)
LOCAL_GAMEPLAY = re.compile(
    r"\b(?:Destroy\w+|RemoveUnit|RemoveItem|SetUnit\w+|UnitAddAbility|UnitRemoveAbility|"
    r"Issue\w+Order|CreateUnit|CreateItem)\s*\("
)
LOCAL_RNG = re.compile(r"\b(?:GetRandomInt|GetRandomReal)\s*\(")
BJ_CALL = re.compile(r"\b([A-Za-z_]\w*BJ)\s*\(")
SET_VAR = re.compile(r"^\s*set\s+([A-Za-z_]\w*)\s*=")
ARRAY_STRUCT = re.compile(r"^\s*(?:private\s+|public\s+)?struct\s+([A-Za-z_]\w*)\s+extends\s+array\b", re.I)
STRUCT_PARENT = re.compile(r"^\s*(?:private\s+|public\s+)?struct\s+([A-Za-z_]\w*)\s+extends\s+([A-Za-z_]\w*)\b", re.I)
LOCAL_LOCATION = re.compile(r"^\s*local\s+location\s+([A-Za-z_]\w*)(?:\s*=.*)?$", re.I)
SET_LOCATION = re.compile(r"^\s*set\s+([A-Za-z_]\w*)\s*=\s*(?:Get\w+Loc|Location)\s*\(", re.I)
REMOVE_LOCATION = re.compile(r"\bRemoveLocation\s*\(\s*([A-Za-z_]\w*)\s*\)", re.I)
GROUP_ALIAS = re.compile(r"^\s*set\s+([A-Za-z_]\w*)\s*=\s*([A-Za-z_]\w*)\s*$", re.I)
FIRST_OF_GROUP = re.compile(r"\bFirstOfGroup\s*\(\s*([A-Za-z_]\w*)\s*\)", re.I)
BOOL_ASSIGN = re.compile(r"^\s*set\s+([A-Za-z_]\w*)\s*=\s*(?:Condition|Filter)\s*\(", re.I)
BOOL_ADD = re.compile(r"\bTriggerAddCondition\s*\([^,]+,\s*([A-Za-z_]\w*)\s*\)", re.I)
BOOL_DESTROY = re.compile(r"\bDestroyBoolExpr\s*\(\s*([A-Za-z_]\w*)\s*\)", re.I)


def code_part(line: str, block_comment: list[bool] | None = None) -> str:
    """Mask non-code without shifting columns; share block state across lines."""
    if block_comment is None:
        block_comment = [False]
    result = list(line)
    quote = ""
    index = 0
    while index < len(line):
        pair = line[index:index + 2]
        char = line[index]
        if block_comment[0]:
            result[index] = " "
            if pair == "*/":
                result[index:index + 2] = "  "
                block_comment[0] = False
                index += 2
                continue
        elif quote:
            result[index] = " "
            if char == "\\" and index + 1 < len(line):
                result[index + 1] = " "
                index += 2
                continue
            if char == quote:
                quote = ""
        elif pair == "//":
            result[index:] = " " * (len(line) - index)
            break
        elif pair == "/*":
            block_comment[0] = True
            result[index:index + 2] = "  "
            index += 2
            continue
        elif char in {'"', "'"}:
            quote = char
            result[index] = " "
        index += 1
    return "".join(result)


def ignored(line: str, rule: str) -> bool:
    marker = re.search(r"wc3lint:\s*ignore\s+([A-Z0-9_-]+)\s+--\s+\S", line, re.I)
    return bool(marker and marker.group(1).upper() in {rule.upper(), "ALL"})


def source_files(target: Path) -> list[Path]:
    if target.is_file():
        return [target] if target.suffix.lower() == ".j" else []
    return sorted(p for p in target.rglob("*.j") if p.is_file())


def add(findings: list[Finding], severity: str, rule: str, path: Path, line: int, message: str, raw: str) -> None:
    if not ignored(raw, rule):
        findings.append(Finding(severity, rule, str(path), line, message))


def scan_file(path: Path) -> list[Finding]:
    text = path.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    findings: list[Finding] = []
    block_comment = [False]
    code_lines = [code_part(raw, block_comment) for raw in lines]
    array_structs = {m.group(1) for code in code_lines if (m := ARRAY_STRUCT.match(code))}
    declared_fourcc = any(re.match(r"^\s*(?:(?:private|public|static)\s+)*function\s+FourCC\s+takes\b", code)
                          for code in code_lines)

    local_stack: list[bool] = []
    local_tainted: set[str] = set()
    location_live: dict[str, bool] = {}
    group_aliases: dict[str, str] = {}
    boolexprs: dict[str, set[str]] = {}

    for number, (raw, code) in enumerate(zip(lines, code_lines), 1):
        stripped = code.strip()
        if not stripped:
            continue

        for severity, rule, pattern, message in SIMPLE_RULES:
            if rule == "WC127-FOURCC" and declared_fourcc:
                continue
            if pattern.search(code):
                add(findings, severity, rule, path, number, message, raw)

        parent_match = STRUCT_PARENT.match(code)
        if parent_match and parent_match.group(2) in array_structs:
            add(findings, "ERROR", "ARRAY-STRUCT-PARENT", path, number, "A normal child should not inherit from an array struct.", raw)

        for name in array_structs:
            if re.search(rf"\b{re.escape(name)}\.(?:create|allocate|destroy|deallocate)\s*\(", code):
                add(findings, "WARNING", "ARRAY-STRUCT-LIFECYCLE", path, number, f"`{name}` extends array; verify a custom lifecycle instead of assuming normal allocation.", raw)

        begins_if = bool(re.match(r"^\s*if\b.*\bthen\s*$", code, re.I))
        if begins_if:
            local_stack.append("GetLocalPlayer" in code or (bool(local_stack) and any(local_stack)))
        elif re.match(r"^\s*elseif\b.*\bthen\s*$", code, re.I) and local_stack:
            parent_local = any(local_stack[:-1])
            local_stack[-1] = local_stack[-1] or parent_local or "GetLocalPlayer" in code

        in_local = any(local_stack)
        if "GetLocalPlayer" in code:
            add(findings, "WARNING", "SYNC-LOCAL-PLAYER", path, number, "Trace all local-only writes and later uses; local safety is not proven by the branch alone.", raw)

        if in_local:
            match = SET_VAR.match(code)
            if match:
                local_tainted.add(match.group(1))
            if HANDLE_FACTORIES.search(code):
                add(findings, "ERROR", "SYNC-LOCAL-HANDLE", path, number, "Do not allocate gameplay handles in a local-player branch.", raw)
            if LOCAL_RNG.search(code):
                add(findings, "ERROR", "SYNC-LOCAL-RNG", path, number, "Do not consume synchronized RNG in a local-player branch.", raw)
            if LOCAL_GAMEPLAY.search(code):
                add(findings, "ERROR", "SYNC-LOCAL-GAMEPLAY", path, number, "Local-only gameplay mutation can desynchronize clients.", raw)
            if (match := BJ_CALL.search(code)):
                add(findings, "WARNING", "SYNC-LOCAL-BJ", path, number, f"Inspect `{match.group(1)}` in Blizzard.j before allowing it locally.", raw)
        elif local_tainted and LOCAL_GAMEPLAY.search(code):
            for name in sorted(local_tainted):
                if re.search(rf"\b{re.escape(name)}\b", code):
                    add(findings, "ERROR", "LOCAL-TAINT", path, number, f"`{name}` was assigned locally and later reaches gameplay state.", raw)

        if HANDLE_FACTORIES.search(code) and not in_local:
            add(findings, "WARNING", "HANDLE-FACTORY", path, number, "Document owner, lifetime, and cleanup or intentional persistence.", raw)

        if (match := LOCAL_LOCATION.match(code)):
            location_live[match.group(1)] = "=" in code
        if (match := REMOVE_LOCATION.search(code)):
            location_live[match.group(1)] = False
        if (match := SET_LOCATION.match(code)):
            name = match.group(1)
            if location_live.get(name, False):
                add(findings, "WARNING", "LOCATION-OVERWRITE", path, number, f"`{name}` may lose its previous location before `RemoveLocation`.", raw)
            location_live[name] = True

        if (match := GROUP_ALIAS.match(code)) and match.group(1) != match.group(2):
            group_aliases[match.group(1)] = match.group(2)
        if (match := FIRST_OF_GROUP.search(code)) and match.group(1) in group_aliases:
            add(findings, "WARNING", "GROUP-ALIAS-CONSUME", path, number, f"Consuming `{match.group(1)}` also mutates aliased group `{group_aliases[match.group(1)]}`.", raw)

        if (match := BOOL_ASSIGN.match(code)):
            boolexprs.setdefault(match.group(1), set()).add("created")
        if (match := BOOL_ADD.search(code)):
            boolexprs.setdefault(match.group(1), set()).add("attached")
        if (match := BOOL_DESTROY.search(code)):
            if "attached" in boolexprs.get(match.group(1), set()):
                add(findings, "WARNING", "BOOLEXPR-PREMATURE-DESTROY", path, number, f"`{match.group(1)}` may still be owned by a trigger condition.", raw)

        if re.match(r"^\s*module\b", code, re.I):
            boolexprs["__module__"] = {"active"}
        if "__module__" in boolexprs and re.search(r"\bmethod\s+onInit\b", code, re.I):
            add(findings, "WARNING", "INIT-ORDER", path, number, "Module `onInit` has special priority; verify runtime dependencies, not only `requires`.", raw)
        if re.match(r"^\s*endmodule\b", code, re.I):
            boolexprs.pop("__module__", None)

        if re.match(r"^\s*endif\b", code, re.I) and local_stack:
            local_stack.pop()

        if re.match(r"^\s*(?:endfunction|endmethod)\b", code, re.I):
            local_stack.clear()
            location_live.clear()
            group_aliases.clear()
            boolexprs.clear()
            local_tainted.clear()

    return findings


def main() -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        epilog="This is a conservative lexical scan, not compatibility or multiplayer certification. "
               "See references/lint-limitations.md for scope and remaining checks.",
    )
    parser.add_argument("path", type=Path, help="A .j file or directory")
    parser.add_argument("--json", action="store_true", help="Emit JSON")
    args = parser.parse_args()

    if not args.path.exists():
        parser.error(f"path does not exist: {args.path}")
    files = source_files(args.path)
    findings = [finding for path in files for finding in scan_file(path)]
    findings.sort(key=lambda f: (f.path, f.line, f.severity, f.rule))

    if args.json:
        print(json.dumps({"files": len(files), "findings": [asdict(f) for f in findings]}, indent=2))
    else:
        for finding in findings:
            print(f"{finding.severity} {finding.rule} {finding.path}:{finding.line} {finding.message}")
        errors = sum(f.severity == "ERROR" for f in findings)
        warnings = sum(f.severity == "WARNING" for f in findings)
        print(f"Scanned {len(files)} file(s): {errors} error(s), {warnings} warning(s).")

    return 1 if any(f.severity == "ERROR" for f in findings) else 0


if __name__ == "__main__":
    sys.exit(main())
