#!/usr/bin/env python3
"""Validate ONE explicit current RM28 Preload log; never searches historical logs.

Exit 0: complete without FAIL (SKIP remains inconclusive); 1: complete with FAIL;
2: invalid/incomplete/mismatched/stale input or unsafe report destination.
Stdout is one JSON object (including invalid-input evidence); rejection also
writes stderr and never creates a report. --not-before includes freshness metadata.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import sys

SAFE_ID = re.compile(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,79}\Z')


def parse(data, run_id):
    records, cases = [], []
    group = None
    complete = False
    # Native PreloadGenEnd wraps payload in JASS. Accept plain payload lines too.
    for line in data.decode('utf-8-sig').splitlines():
        start = line.find('RM28|')
        if start < 0:
            continue
        fields = line[start:].split('"', 1)[0].rstrip().split('|')
        if len(fields) < 3 or fields[1] != run_id:
            raise ValueError('run-id mismatch')
        kind, rest = fields[2], fields[3:]
        if complete:
            raise ValueError('records after COMPLETE')
        if group is None:
            if kind != 'BEGIN' or len(rest) != 1 or not SAFE_ID.fullmatch(rest[0]):
                raise ValueError('expected BEGIN first')
            group = rest[0]
        elif kind == 'CASE':
            if len(rest) != 1 or not SAFE_ID.fullmatch(rest[0]) or rest[0] in cases:
                raise ValueError('invalid CASE')
            cases.append(rest[0])
        elif kind == 'CHECK':
            if (len(rest) != 4 or not cases or rest[0] != cases[-1]
                    or rest[1] not in ('PASS', 'FAIL', 'SKIP', 'OBS') or not rest[2] or not rest[3]):
                raise ValueError('invalid CHECK')
            records.append(dict(zip(('case', 'status', 'name', 'detail'), rest)))
        elif kind == 'COMPLETE':
            expected = [len(cases), len(records), sum(r['status'] == 'FAIL' for r in records),
                        sum(r['status'] == 'SKIP' for r in records)]
            if len(rest) != 4 or not all(re.fullmatch(r'\d+', x) for x in rest) or list(map(int, rest)) != expected:
                raise ValueError('COMPLETE counters mismatch')
            if not cases or not records or any(not any(r['case'] == c for r in records) for c in cases):
                raise ValueError('empty case or suite')
            complete = True
        else:
            raise ValueError('unexpected record')
    if group is None:
        raise ValueError('expected BEGIN first')
    if not complete:
        raise ValueError('missing COMPLETE')
    failures = sum(r['status'] == 'FAIL' for r in records)
    skips = sum(r['status'] == 'SKIP' for r in records)
    return dict(run_id=run_id, group=group, cases=len(cases), checks=len(records),
                failures=failures, skips=skips, observations=sum(r['status'] == 'OBS' for r in records),
                complete=True, status='failed' if failures else ('inconclusive' if skips else 'passed'),
                source_sha256=hashlib.sha256(data).hexdigest(), records=records)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('log', type=Path, help='Explicit current log; read only')
    parser.add_argument('--run-id', required=True, help='Exact unique safe ID embedded in the harness')
    parser.add_argument('--not-before', type=float, help='Reject mtime older than this Unix timestamp; use game launch time')
    parser.add_argument('--report', type=Path, help='Optional NEW JSON report; never overwrite or follow symlinks')
    args = parser.parse_args(argv)
    try:
        if not SAFE_ID.fullmatch(args.run_id):
            raise ValueError('invalid run-id')
        if args.not_before is not None and (not math.isfinite(args.not_before) or args.not_before < 0):
            raise ValueError('invalid not-before')
        mtime = args.log.stat().st_mtime
        if args.not_before is not None and mtime < args.not_before:
            raise ValueError('stale input')
        result = parse(args.log.read_bytes(), args.run_id)
        if args.not_before is not None:
            result['freshness'] = {'mtime': mtime, 'not_before': args.not_before}
        output = json.dumps(result, sort_keys=True) + '\n'
        if args.report:
            if args.report.exists() or args.report.is_symlink():
                raise ValueError('report destination exists')
            if any(p.is_symlink() for p in args.report.parents):
                raise ValueError('symlink report parent')
            with args.report.open('x', encoding='utf-8') as stream:
                stream.write(output)
        print(output, end='')
        return int(result['failures'] > 0)
    except (OSError, ValueError, UnicodeError) as exc:
        print(json.dumps({'status': 'invalid', 'error': str(exc), 'run_id': args.run_id}, sort_keys=True))
        print('error: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
