"""Observe MCP-owned live updates using SQLite reads only; clean up own fixtures."""
from pathlib import Path
import json
import os
import sqlite3
import time

OUT = Path(__file__).resolve().parent
ROOTS = [
    Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src'),
    Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration'),
    Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist'),
]
TOKEN = f'CGAutosyncProbe{os.getpid()}'

def observe(root, filename):
    with sqlite3.connect((root / '.codegraph/codegraph.db').as_uri() + '?mode=ro', uri=True) as db:
        return {
            'files': db.execute('select count(*) from files where path = ?', (filename,)).fetchone()[0],
            'names': [row[0] for row in db.execute("select name from nodes where file_path = ? and kind = 'function' order by name", (filename,))],
        }

def wait_for(root, filename, name):
    start = time.monotonic()
    while True:
        found = observe(root, filename)
        ok = found['files'] == 0 and not found['names'] if name is None else found['files'] == 1 and found['names'] == [name]
        if ok or time.monotonic() - start > 15:
            return dict(found, passed=ok, seconds=round(time.monotonic() - start, 3))
        time.sleep(.2)

report = {'method': 'Existing MCP process only. No sync, query or other CodeGraph call during observation; read-only SQLite polling.', 'roots': []}
for root in ROOTS:
    ext = '.js' if root.name == 'dist' else '.j'
    filename = f'cg_autosync_probe_{os.getpid()}{ext}'
    path = root / filename
    row = {'root': str(root), 'fixture': filename, 'writer_before': json.loads((root / '.codegraph/writer.pid').read_text()), 'transitions': {}}
    assert not path.exists()
    def body(name):
        return f'export function {name}() {{ return 1; }}\n' if ext == '.js' else f'function {name} takes nothing returns nothing\nendfunction\n'
    try:
        with path.open('x') as stream:
            stream.write(body(TOKEN + 'A'))
        row['transitions']['create'] = wait_for(root, filename, TOKEN + 'A')
        path.write_text(body(TOKEN + 'B'))
        row['transitions']['modify'] = wait_for(root, filename, TOKEN + 'B')
    finally:
        path.unlink(missing_ok=True)
    row['transitions']['delete'] = wait_for(root, filename, None)
    row['fixture_removed'] = not path.exists()
    row['writer_after'] = json.loads((root / '.codegraph/writer.pid').read_text())
    report['roots'].append(row)
    print(json.dumps(row), flush=True)
report['passed'] = all(t['passed'] for row in report['roots'] for t in row['transitions'].values())
(OUT / 'auto-sync-verification.json').write_text(json.dumps(report, indent=2) + '\n')
assert report['passed'], 'Watcher transition failed; see evidence'
