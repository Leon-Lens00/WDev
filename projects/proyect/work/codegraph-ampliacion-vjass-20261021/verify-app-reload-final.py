from pathlib import Path
import json, time, os, sqlite3, hashlib

BASE = Path(__file__).resolve().parent
PROJECT = BASE.parents[1]
BUILD = Path('/home/snz/Documentos/MCP W3/codegraph-vjass/dist/mcp/tools.js')
OLD = {r['pid'] for r in json.loads((BASE/'final-old-mcp-pids.json').read_text())}
SOURCES = json.loads((BASE/'real-sources.json').read_text())
started = time.time()
btime = next(int(l.split()[1]) for l in Path('/proc/stat').read_text().splitlines() if l.startswith('btime '))
ticks = os.sysconf('SC_CLK_TCK')
report = {'expected_identity': '1.6.2+jass-vjass.3', 'method': 'App-managed MCP process started after the final compiled modules; independent MCP protocol and watcher verification are in mcp-final-verification.json.', 'old_pids': sorted(OLD), 'current_chat_tool_call_after_reload': False}
while time.time()-started < 60:
    found = []
    for p in Path('/proc').iterdir():
        if not p.name.isdigit() or int(p.name) in OLD: continue
        try:
            args = (p/'cmdline').read_bytes().split(b'\0')
            if b'/home/snz/Documentos/MCP W3/codegraph-vjass/dist/bin/codegraph.js' not in args or b'--mcp' not in args: continue
            if (p/'cwd').resolve() != PROJECT: continue
            fields = (p/'stat').read_text().split(') ', 1)[1].split()
            parent = Path('/proc')/fields[1]
            if b'app-server' not in (parent/'cmdline').read_bytes(): continue
            birth = btime + int(fields[19])/ticks
            if birth < BUILD.stat().st_mtime: continue
            found.append({'pid': int(p.name), 'parent': int(fields[1]), 'started_after_build': True})
        except (OSError, ValueError): continue
    if found:
        report['app_mcp_processes'] = found
        report['old_processes_exited'] = all(not Path('/proc',str(pid)).exists() for pid in OLD)
        report['source_hashes_unchanged'] = all(hashlib.sha256((Path(r['root'])/f).read_bytes()).hexdigest()==h for r in SOURCES for f,h in r['files'].items())
        report['indexes'] = []
        for item in SOURCES:
            with sqlite3.connect((Path(item['root'])/'.codegraph/codegraph.db').as_uri()+'?mode=ro',uri=True) as db:
                report['indexes'].append({'root':item['root'], 'integrity':db.execute('pragma quick_check').fetchone()[0], 'metadata':dict(db.execute("select key,value from project_metadata where key in ('indexed_with_version','indexed_with_extraction_version','index_state')"))})
        report['passed'] = report['old_processes_exited'] and report['source_hashes_unchanged'] and all(r['integrity']=='ok' and r['metadata'].get('indexed_with_version')=='1.6.2+jass-vjass.3' and r['metadata'].get('indexed_with_extraction_version')=='30' for r in report['indexes'])
        break
    time.sleep(.5)
report.setdefault('passed', False)
report['elapsed_seconds'] = round(time.time()-started, 2)
(BASE/'app-reload-final-verification.json').write_text(json.dumps(report, indent=2))
