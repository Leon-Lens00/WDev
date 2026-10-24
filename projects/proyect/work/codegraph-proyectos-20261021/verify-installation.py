"""Audit the prepared scopes against upstream and the preserved source hashes."""
from pathlib import Path
import subprocess
import json
import sqlite3
import hashlib
import datetime
import tomllib

BASE = Path(__file__).resolve().parent
REPO = Path('/home/snz/Documentos/MCP W3/codegraph-vjass')
rows = json.loads((BASE / 'verification.json').read_text())['indexes']
report = {
    'timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'upstream_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=REPO, text=True).strip(),
    'checks': {}, 'indexes': [],
}
for rel in ['src/mcp/engine.ts', 'src/mcp/project-lifecycle.ts', 'src/mcp/writer-lock.ts',
            'src/sync/watcher.ts', 'src/installer/targets/codex.ts', 'src/installer/instructions-template.ts']:
    report['checks'][rel] = {'identical_to_upstream': subprocess.check_output(['git', 'show', 'HEAD:' + rel], cwd=REPO) == (REPO / rel).read_bytes()}
for row in rows:
    root = Path(row['root'])
    result = subprocess.run(['/home/snz/.local/bin/codegraph', 'status', str(root), '--json'], capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    status = json.loads(result.stdout)
    (BASE / (row['label'] + '-audit-status.json')).write_text(result.stdout)
    current = {'label': row['label'], 'root': str(root), 'status_exit': result.returncode, 'status': status}
    with sqlite3.connect((root / '.codegraph/codegraph.db').as_uri() + '?mode=ro', uri=True) as db:
        current['sqlite_quick_check'] = db.execute('pragma quick_check').fetchall()
        current['counts'] = {t: db.execute('select count(*) from ' + t).fetchone()[0] for t in ['files', 'nodes', 'edges']}
        current['probe_files_remaining'] = db.execute("select path from files where path like 'cg_autosync_probe_%'").fetchall()
        current['probe_symbols_remaining'] = db.execute("select name from nodes where name like 'CGAutosyncProbe%'").fetchall()
        if row['label'] == 'inventory':
            paths = [x[0] for x in db.execute('select path from files')]
            current['excluded_paths_remaining'] = [p for p in paths if p.split('/')[0] in ['build', 'evidence', 'runtime-isolated', 'source-demo', 'upstream', 'studio-before', '__pycache__']]
    current['fixture_files_remaining'] = [str(p) for p in root.glob('cg_autosync_probe_*')]
    writer = root / '.codegraph/writer.pid'
    current['writer'] = json.loads(writer.read_text()) if writer.exists() else None
    report['indexes'].append(current)
originals = json.loads((BASE / 'before.json').read_text())
report['source_map_hash_check'] = {
    'files': len(originals),
    'changed': [p for p, h in originals.items() if not Path(p).exists() or hashlib.sha256(Path(p).read_bytes()).hexdigest() != h],
}
report['automatic_update'] = json.loads((BASE / 'auto-sync-verification.json').read_text())
test_log = (BASE / 'upstream-audit-tests.log').read_text()
assert 'Test Files  6 passed (6)' in test_log and 'Tests  92 passed (92)' in test_log
report['tests'] = {'files_passed': 6, 'cases_passed': 92, 'skipped': 0, 'log': 'upstream-audit-tests.log'}
report['runtime'] = subprocess.check_output(['/home/snz/.local/share/codegraph-vjass/runtime/node', '--version'], text=True).strip()
report['mcp_entry'] = tomllib.loads(Path('/home/snz/.codex/config.toml').read_text())['mcp_servers']['codegraph']
report['other_chats_messaged'] = False
report['checks_passed'] = (
    all(v['identical_to_upstream'] for v in report['checks'].values())
    and report['automatic_update']['passed'] and not report['source_map_hash_check']['changed']
    and all(r['status_exit'] == 0 and r['sqlite_quick_check'] == [('ok',)]
            and not r['probe_files_remaining'] and not r['probe_symbols_remaining']
            and not r['fixture_files_remaining'] and not r.get('excluded_paths_remaining')
            for r in report['indexes'])
)
(BASE / 'audit-verification.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({
    'checks_passed': report['checks_passed'], 'sources_maps': report['source_map_hash_check'],
    'indexes': [{'root': r['root'], 'counts': r['counts'], 'sqlite': r['sqlite_quick_check'],
                 'status': r['status']} for r in report['indexes']],
}, indent=2))
assert report['checks_passed']
