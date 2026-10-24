#!/usr/bin/env python3
"""Validate bounded IL141 evidence; exit 0 complete, 1 complete FAIL, 2 invalid.

SKIP/OBS yield inconclusive=true, never an all-passed claim. Input is data, never
executed. Freshness uses filesystem mtime and requires a unique expected run ID.
"""
import argparse
import json
import importlib.util
import math
from pathlib import Path
import re
import sys

_spec = importlib.util.spec_from_file_location('inventory_build_helpers', Path(__file__).with_name('build.py'))
_helpers = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_helpers)
guard, no_symlinks = _helpers.guard, _helpers.no_symlinks

ID = r'[A-Za-z0-9][A-Za-z0-9_-]{0,79}'
PAYLOAD = r'[A-Za-z0-9 _=.,:+-]{1,160}'
ROW = re.compile(r'IL141\|(' + ID + r')\|([1-9][0-9]{0,2})\|([A-Z]+)\|(' + ID + r'|-)\|(' + PAYLOAD + r')')
ENVELOPE = re.compile(r'\s*call Preload\(\s*"(IL141\|[^"\r\n]*)"\s*\)\s*')
STATUSES = ('PASS', 'FAIL', 'OBS', 'SKIP')


def counts(values):
    return ' '.join(s.lower() + '=' + str(values[s]) for s in STATUSES)


def parse(data, run_id):
    if len(data) > 262144 or not data.endswith(b'\n'):
        raise ValueError()
    text = data.decode('utf-8')
    rows = []
    for line in text.split('\n')[:-1]:
        line = line.removesuffix('\r')
        if line.startswith('IL141|'):
            row = line
        elif 'IL141' in line:
            match = ENVELOPE.fullmatch(line)
            if not match:
                raise ValueError()
            row = match[1]
        else:
            # Only the known inert PreloadGen wrapper, not arbitrary injected script.
            if line.strip() not in ('', 'function PreloadFiles takes nothing returns nothing',
                                    'endfunction', 'call PreloadStart()',
                                    'call PreloadEnd( 0.0 )', 'call PreloadEnd( 0 )'):
                raise ValueError()
            continue
        match = ROW.fullmatch(row)
        if not match or match[1] != run_id or int(match[2]) != len(rows) + 1:
            raise ValueError()
        rows.append((match[3], match[4], match[5]))
    if not 4 <= len(rows) <= 512 or rows[0] != ('BEGIN', '-', 'schema=1'):
        raise ValueError()
    total = dict.fromkeys(STATUSES, 0)
    current = None
    seen = set()
    local = {}
    complete = False
    for index, (kind, case, payload) in enumerate(rows[1:], 1):
        if complete:
            raise ValueError()
        if kind == 'CASE' and current is None and case != '-' and case not in seen and payload == 'before':
            current = case
            seen.add(case)
            local = dict.fromkeys(STATUSES, 0)
        elif kind == 'CHECK' and current is not None and case == current:
            pass
        elif kind in STATUSES and current is not None and case == current:
            local[kind] += 1
            total[kind] += 1
        elif kind == 'RESULT' and current is not None and case == current:
            if sum(local.values()) == 0 or payload != counts(local):
                raise ValueError()
            current = None
        elif kind == 'COMPLETE' and current is None and case == '-' and seen:
            if payload != 'cases=' + str(len(seen)) + ' ' + counts(total) or index != len(rows) - 1:
                raise ValueError()
            complete = True
        else:
            raise ValueError()
    if not complete:
        raise ValueError()
    return dict(run_id=run_id, cases=len(seen), inconclusive=bool(total['OBS'] or total['SKIP']),
                **{s.lower(): total[s] for s in STATUSES})


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path, help='Fresh PreloadGen .pld or raw rows; never executed')
    parser.add_argument('--run-id', required=True, help='Exact expected unique run ID')
    parser.add_argument('--not-before', required=True, help='Minimum input mtime, Unix seconds (finite)')
    parser.add_argument('--report', type=Path, help='Optional NEW JSON file; parent must already exist')
    args = parser.parse_args(argv)
    try:
        threshold = float(args.not_before)
        if not math.isfinite(threshold) or not re.fullmatch(ID, args.run_id):
            raise ValueError()
        no_symlinks(args.input, 'input')
        stat = args.input.stat()
        if not args.input.is_file() or stat.st_size > 262144 or stat.st_mtime < threshold:
            raise ValueError()
        # Reuse assembly publication invariants, including hardlink/alias checks.
        guard([args.report] if args.report else [], [args.input])
        report = parse(args.input.read_bytes(), args.run_id)
        output = json.dumps(report, indent=2, sort_keys=True) + '\n'
        if args.report:
            with args.report.open('x', encoding='utf-8') as stream:
                stream.write(output)
        print(output, end='')
        return int(report['fail'] > 0)
    except (OSError, ValueError, UnicodeError):
        print('error: invalid evidence', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
