#!/usr/bin/env python3
"""Frozen Classic binary helpers; preserve both baseline GUI triggers unchanged."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import shutil
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = Path('/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def integer(n):
    return struct.pack('<i', n)


def cstring(s):
    return s.encode('utf-8') + b'\0'


class Reader:
    def __init__(self, data):
        self.data, self.pos = data, 0

    def take(self, n):
        result = self.data[self.pos:self.pos+n]
        assert len(result) == n
        self.pos += n
        return result

    def int(self):
        return struct.unpack('<i', self.take(4))[0]

    def string(self):
        end = self.data.index(0, self.pos)
        return self.take(end-self.pos+1)


def units(data):
    r = Reader(data)
    assert r.int() == 2, 'Only Classic unit object format v2 is supported'
    tables = []
    for _ in range(2):
        records = []
        for _ in range(r.int()):
            begin = r.pos
            base, new, count = r.take(4), r.take(4), r.int()
            mods = []
            for _ in range(count):
                field, kind = r.take(4), r.int()
                assert kind in (0, 1, 2, 3)
                value = r.string() if kind == 3 else r.take(4)
                mods.append((field, kind, value, r.take(4)))
            records.append({'base': base, 'id': new, 'mods': mods, 'raw': data[begin:r.pos]})
        tables.append(records)
    assert r.pos == len(data)
    # Before editing, prove the parser can reproduce every original byte.
    assert encode_units(tables) == data
    return tables


def encode_record(record):
    return record['base'] + record['id'] + integer(len(record['mods'])) + b''.join(
        field + integer(kind) + value + end for field, kind, value, end in record['mods'])


def encode_units(tables):
    return integer(2) + b''.join(integer(len(t)) + b''.join(encode_record(x) for x in t) for t in tables)


def set_field(record, field, kind, value):
    field = field.encode('ascii')
    value = cstring(value) if kind == 3 else (integer(value) if kind == 0 else struct.pack('<f', value))
    record['mods'] = [m for m in record['mods'] if m[0] != field]
    record['mods'].append((field, kind, value, b'\0'*4))


def triggers(data, names):
    r = Reader(data)
    assert r.take(4) == b'WTG!' and r.int() == 7
    category_count = r.int()
    assert category_count == 1
    start = r.pos
    assert r.int() == 0
    r.string()
    r.int()
    categories = data[start:r.pos]
    middle_start = r.pos
    r.int()
    assert r.int() == 0, 'Base map variables changed; review before rebuilding'
    middle = data[middle_start:r.pos]
    assert r.int() == 2, 'Base map trigger count changed'
    original_records = data[r.pos:]
    added = b''
    for name in names:
        added += cstring(name) + cstring('TerrainDev foundation; original author credits in code.')
        added += b''.join(integer(v) for v in (0, 1, 1, 0, 0, 1, 0))
    return (b'WTG!' + integer(7) + integer(2) + categories + integer(1) +
            cstring('Project Libraries') + integer(0) + middle + integer(2+len(names)) +
            original_records + added)


def custom_text(data, bodies):
    r = Reader(data)
    assert r.int() == 1
    r.string()
    r.take(r.int())
    header = data[:r.pos]
    assert r.int() == 2
    begin = r.pos
    for _ in range(2):
        r.take(r.int())
    assert r.pos == len(data)
    return header + integer(2+len(bodies)) + data[begin:] + b''.join(
        integer(len(body)+1) + body + b'\0' for body in bodies)


def run(args, log):
    command = [sys.executable, str(LAUNCHER), *map(str, args)]
    result = subprocess.run(command, capture_output=True, text=True)
    log.write_text(json.dumps({'command': command, 'returncode': result.returncode,
                              'stdout': result.stdout, 'stderr': result.stderr}, indent=2))
    if result.returncode:
        raise RuntimeError(f'Command failed; see {log}: {result.stdout} {result.stderr}')
    return result.stdout

