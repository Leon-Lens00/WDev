#!/usr/bin/env python3
"""Observe one fresh RF log through inotify (180s default), then run the public reader.
Usage: observe_native.py RUN_ID REPORT_TAG [BUDGET_SECONDS]
Never launches, closes, or polls a game; preserves the reader's exit code.
"""
import ctypes
import json
import os
from pathlib import Path
import re
import select
import struct
import subprocess
import sys
import time

root = Path(__file__).resolve().parents[1]
run, tag = sys.argv[1:3]
assert re.fullmatch(r'[A-Za-z0-9_-]+', run) and re.fullmatch(r'[A-Za-z0-9_-]+', tag)
budget = int(sys.argv[3]) if len(sys.argv) == 4 else 180
assert 1 <= budget <= 180
reports = root / 'reports'
source = Path('/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx/drive_c/WarcraftIII/CustomMapData/Logs') / ('RF-' + run + '.txt')
raw = reports / source.name
launch = reports / (tag + '-native-launch.json')
report = reports / (tag + '-native-reader.json')
summary = reports / (tag + '-observer.json')
stdout = reports / (tag + '-native-reader.stdout.txt')
stderr = reports / (tag + '-native-reader.stderr.txt')
for path in (raw, report, summary, stdout, stderr):
    assert not path.exists(), str(path)
start = time.time()
deadline = time.monotonic() + budget
libc = ctypes.CDLL(None, use_errno=True)
fd = libc.inotify_init1(os.O_CLOEXEC | os.O_NONBLOCK)
assert fd >= 0, ctypes.get_errno()
assert libc.inotify_add_watch(fd, os.fsencode(source.parent), 0x8 | 0x80 | 0x100) >= 0, ctypes.get_errno()
marker = ('RM28|' + run + '|COMPLETE|').encode()
print('watching ' + source.name, flush=True)
data = b''
try:
    while True:
        if source.exists():
            data = source.read_bytes()
            if marker in data:
                break
        remaining = deadline - time.monotonic()
        if remaining <= 0 or not select.select([fd], [], [], remaining)[0]:
            summary.write_text(json.dumps({'status': 'TIMEOUT', 'started_unix': start, 'ended_unix': time.time(), 'budget_seconds': budget, 'exit': 124}, indent=2) + '\n')
            sys.exit(124)
        events = os.read(fd, 65536)
        pos = 0
        while pos < len(events):
            _, _, _, size = struct.unpack_from('iIII', events, pos)
            pos += 16 + size
finally:
    os.close(fd)
metadata = json.loads(launch.read_text())
assert source.stat().st_mtime >= metadata['launch_requested_unix'], 'stale native log'
with raw.open('xb') as f:
    f.write(data)
stat = source.stat()
os.utime(raw, ns=(stat.st_atime_ns, stat.st_mtime_ns))
reader = root.parents[1] / 'relativistic-classic/tools/read_logs.py'
argv = [sys.executable, '-B', str(reader), str(source), '--run-id', run, '--not-before', str(metadata['launch_requested_unix']), '--report', str(report)]
result = subprocess.run(argv, capture_output=True, timeout=30)
stdout.write_bytes(result.stdout)
stderr.write_bytes(result.stderr)
summary.write_text(json.dumps({'status': 'COMPLETE_OBSERVED', 'started_unix': start, 'ended_unix': time.time(), 'budget_seconds': budget, 'reader_argv': argv, 'reader_exit_code': result.returncode, 'source_mtime': stat.st_mtime}, indent=2) + '\n')
print(next(line.decode() for line in data.splitlines() if marker in line), flush=True)
print('reader exit=' + str(result.returncode), flush=True)
if result.stderr:
    sys.stderr.buffer.write(result.stderr)
sys.exit(result.returncode)
