#!/usr/bin/env python3
"""Read IL141M data, NEVER execute it. Exit 0 observation_complete, 1 partial,
2 invalid (stderr exactly 'error: invalid manual evidence'). No semantic PASS
certification. INPUT is a log directory or JSON manifest {"chunks":[basenames]}.

Recorder commands: -im start <label>, -im status, -im mark, -im save, -im stop.
A NEW label is required each launch; the game cannot check existing log files.
"""
import argparse
import importlib.util
import json
import math
from pathlib import Path
import re
import sys

_spec = importlib.util.spec_from_file_location('manual_build_helpers', Path(__file__).with_name('build.py'))
_helpers = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_helpers)
ID = r'[A-Za-z0-9][A-Za-z0-9_-]{0,79}'
SESSION = r'[A-Za-z0-9][A-Za-z0-9_-]{0,31}'
ROW = re.compile(r'IL141M\|(' + ID + r')\|(' + SESSION +
                 r')\|(0|[1-9][0-9]?)\|([1-9][0-9]{0,3})\|(0|[1-9][0-9]{0,9})'
                 r'\|([a-z][a-z0-9_]{0,31})\|([A-Z][A-Z0-9_]{0,31})\|([A-Za-z0-9 _=.,:+-]{1,160})')
ENVELOPE = re.compile(r'call Preload\(\s*"(IL141M\|[^"\r\n]*)"\s*\)')
TERMINAL = re.compile(r'reason=(USER_STOP|OVERFLOW) rows=([1-9][0-9]{0,3}) dropped=(0|[1-9][0-9]{0,3})')
MAX_FILE = 65536


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError()
        result[key] = value
    return result


def chunk_rows(data):
    if not data or len(data) > MAX_FILE or not data.endswith(b'\n'):
        raise ValueError()
    lines = [line.strip(' \t\r') for line in data.decode('ascii').split('\n') if line.strip(' \t\r')]
    if not lines:
        raise ValueError()
    if lines[0] == 'function PreloadFiles takes nothing returns nothing':
        if lines[-1] != 'endfunction':
            raise ValueError()
        lines = lines[1:-1]
        if lines and lines[0] == 'call PreloadStart()':
            lines = lines[1:]
        if lines and lines[-1] in ('call PreloadEnd( 0.0 )', 'call PreloadEnd( 0 )'):
            lines = lines[:-1]
        result = []
        for line in lines:
            match = ENVELOPE.fullmatch(line)
            if not match:
                raise ValueError()
            result.append(match[1])
    else:
        result = lines
    if not 1 <= len(result) <= 128:
        raise ValueError()
    return result


def parse(chunks, run_id, session):
    observations = []
    last_time = -1
    terminal = None
    for chunk_index, data in enumerate(chunks):
        rows = chunk_rows(data)
        if chunk_index < len(chunks) - 1 and len(rows) != 128:
            raise ValueError()
        for text in rows:
            match = ROW.fullmatch(text)
            if not match or terminal is not None:
                raise ValueError()
            build, label, chunk, seq, stamp, source, event, payload = match.groups()
            seq, stamp = int(seq), int(stamp)
            if (build != run_id or label != session or int(chunk) != chunk_index
                    or seq != len(observations) + 1 or seq > 8192 or stamp < last_time
                    or stamp > 2147483647):
                raise ValueError()
            if seq == 1:
                if (source, event, payload) != ('recorder', 'BEGIN', 'schema=1'):
                    raise ValueError()
            elif event == 'BEGIN':
                raise ValueError()
            if event == 'TERMINAL':
                end = TERMINAL.fullmatch(payload)
                if (source != 'recorder' or not end or int(end[2]) != seq
                        or (end[1] == 'USER_STOP' and int(end[3]) != 0)
                        or (end[1] == 'OVERFLOW' and int(end[3]) != 1)):
                    raise ValueError()
                terminal = {'reason': end[1], 'rows': seq, 'dropped': int(end[3])}
            observations.append({'sequence': seq, 'time_ms': stamp, 'source': source,
                                 'event': event, 'data': payload})
            last_time = stamp
    complete = terminal is not None and terminal['reason'] == 'USER_STOP'
    return {'schema': 'IL141M/1', 'run_id': run_id, 'session': session,
            'status': 'observation_complete' if complete else 'partial',
            'semantic_certification': False, 'runtime_writing_verified': False,
            'limitations': ['Observed data only; no gameplay PASS certification.',
                            'Public samples are deferred/coalesced, not causal proof.',
                            'Filesystem freshness cannot prove game/runtime provenance.',
                            'OVERFLOW counts the first refused row only; later coverage is unknown.'],
            'chunks': len(chunks), 'rows': len(observations), 'terminal': terminal,
            'observations': observations}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path, help='Directory, or JSON manifest beside its chunk files')
    parser.add_argument('--run-id', required=True, help='Exact build ID (1-80 safe ASCII characters)')
    parser.add_argument('--session', required=True, help='Exact NEW launch label (1-32 safe ASCII characters)')
    parser.add_argument('--not-before', required=True, help='Finite minimum Unix mtime for every input, including manifest')
    parser.add_argument('--report', type=Path, help='Optional NEW exclusive JSON output; parent must exist')
    args = parser.parse_args(argv)
    try:
        threshold = float(args.not_before)
        if (not math.isfinite(threshold) or not re.fullmatch(ID, args.run_id)
                or not re.fullmatch(SESSION, args.session)):
            raise ValueError()
        _helpers.no_symlinks(args.input, 'input')
        prefix = 'IL141M-' + args.run_id + '--' + args.session + '--'
        filename = re.compile(re.escape(prefix) + r'([0-9]+)\.pld')
        manifest_inputs = []
        if args.input.is_dir():
            paths = [p for p in args.input.iterdir() if filename.fullmatch(p.name)]
        else:
            manifest_inputs = [args.input]
            _helpers.guard([], manifest_inputs)
            stat = args.input.stat()
            if not args.input.is_file() or stat.st_size > 16384 or stat.st_mtime < threshold:
                raise ValueError()
            manifest_data = args.input.read_bytes()
            manifest = json.loads(manifest_data, object_pairs_hook=unique_object)
            if (not isinstance(manifest, dict) or set(manifest) != {'chunks'}
                    or not isinstance(manifest['chunks'], list) or not 1 <= len(manifest['chunks']) <= 64
                    or any(not isinstance(n, str) or not filename.fullmatch(n) for n in manifest['chunks'])):
                raise ValueError()
            paths = [args.input.parent / n for n in manifest['chunks']]
        if not 1 <= len(paths) <= 64:
            raise ValueError()
        indexed = []
        for path in paths:
            index = filename.fullmatch(path.name)[1]
            if str(int(index)) != index or int(index) > 63:
                raise ValueError()
            indexed.append((int(index), path))
        indexed.sort()
        if [index for index, _ in indexed] != list(range(len(paths))):
            raise ValueError()
        paths = [path for _, path in indexed]
        inputs = manifest_inputs + paths
        if args.report and not args.report.parent.is_dir():
            raise ValueError()
        _helpers.guard([args.report] if args.report else [], inputs)
        chunks = []
        for path in paths:
            stat = path.stat()
            if not path.is_file() or stat.st_size > MAX_FILE or stat.st_mtime < threshold:
                raise ValueError()
            chunks.append(path.read_bytes())
        report = parse(chunks, args.run_id, args.session)
        if any(path.read_bytes() != data for path, data in zip(paths, chunks)):
            raise ValueError()
        if manifest_inputs and args.input.read_bytes() != manifest_data:
            raise ValueError()
        output = _helpers.json_bytes(report)
        if args.report:
            _helpers.write_new(args.report, output)
        print(output.decode('ascii'), end='')
        return 0 if report['status'] == 'observation_complete' else 1
    except (OSError, ValueError, UnicodeError, TypeError, OverflowError):
        print('error: invalid manual evidence', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
