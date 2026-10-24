"""Session-only observer: inotify wait, unique raw log, public reader evidence."""
import ctypes
import json
import os
from pathlib import Path
import struct
import subprocess
import sys

run = sys.argv[1]
p = Path('projects/relativistic-classic').resolve()
assert run in ('diag4-e29-timeout-20261019-01', 'fixed-20261019-03') and all(c.isalnum() or c in '_.-' for c in run)
source = Path('/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx/drive_c/WarcraftIII/CustomMapData/Logs') / ('RM28-' + run + '.txt')
launch = p / 'reports/cycle4' / (run + '-launch.json')
raw = p / 'reports' / source.name
report = p / 'reports' / ('lab-' + run + '.json')
assert not source.exists() and not raw.exists() and not report.exists()
libc = ctypes.CDLL(None, use_errno=True)
fd = libc.inotify_init1(os.O_CLOEXEC)
assert fd >= 0, ctypes.get_errno()
assert libc.inotify_add_watch(fd, os.fsencode(source.parent), 0x8 | 0x80 | 0x100) >= 0, ctypes.get_errno()
print('watching ' + source.name, flush=True)
while True:
    events = os.read(fd, 65536)
    pos = 0
    matched = False
    while pos < len(events):
        wd, mask, cookie, size = struct.unpack_from('iIII', events, pos)
        name = events[pos + 16:pos + 16 + size].rstrip(b'\0')
        matched |= name == os.fsencode(source.name)
        pos += 16 + size
    if not matched or not source.exists():
        continue
    data = source.read_bytes()
    if ('RM28|' + run + '|COMPLETE|').encode() in data:
        break
os.close(fd)
with raw.open('xb') as f:
    f.write(data)
metadata = json.loads(launch.read_text())
result = subprocess.run([sys.executable, '-B', str(p / 'tools/read_logs.py'), str(source), '--run-id', run, '--not-before', str(metadata['launch_requested_unix']), '--report', str(report)], capture_output=True)
for suffix, payload in (('.stdout.json', result.stdout), ('.stderr.txt', result.stderr)):
    with (p / 'reports' / ('lab-' + run + suffix)).open('xb') as f:
        f.write(payload)
with (p / 'reports/cycle4' / (run + '-reader-exit.json')).open('x') as f:
    json.dump({'exit_code': result.returncode, 'source_mtime': source.stat().st_mtime, 'launch_requested_unix': metadata['launch_requested_unix']}, f)
print('reader exit=' + str(result.returncode), flush=True)
print(next(line.decode() for line in data.splitlines() if ('RM28|' + run + '|COMPLETE|').encode() in line), flush=True)
if result.stderr:
    print(result.stderr.decode(), flush=True)
# Preserve the real public-check exit code: FAIL is 1, invalid is 2.
sys.exit(result.returncode)
