from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import hashlib,json,shutil,sqlite3,os,time
B=Path(__file__).resolve().parent;S=B/'checkout';A=Path('/home/snz/Documentos/MCP W3/codegraph-vjass')
base=json.loads((B/'baseline.json').read_text())
conflicts=[r for r,h in base.items() if hashlib.sha256((A/r).read_bytes()).hexdigest()!=h]
assert not conflicts,conflicts
assert '6093 passed | 36 skipped' in (B/'regression.log').read_text()
assert 'dist/ engine intact' in (B/'build.log').read_text()
changes=json.loads((B/'changed-files.json').read_text())
backup=B/('production-backup-'+datetime.now(ZoneInfo('America/Lima')).strftime('%Y%m%d-%H%M%S'));backup.mkdir()
preimages=[]
for rel in changes:
 p=A/rel;preimages.append({'path':rel,'existed':p.exists()})
 if p.exists():dst=backup/'source'/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
shutil.copytree(A/'dist',backup/'dist')
roots=[Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src'),Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration'),Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist')]
sources=[]
for i,root in enumerate(roots):
 with sqlite3.connect((root/'.codegraph/codegraph.db').as_uri()+'?mode=ro',uri=True) as db:
  with sqlite3.connect(backup/f'index-{i}.sqlite') as dst:db.backup(dst)
  files=[r[0] for r in db.execute('SELECT path FROM files')]
 sources.append({'root':str(root),'source_sha256':{r:hashlib.sha256((root/r).read_bytes()).hexdigest() for r in files}})
 cfg=root/'codegraph.json'
 if cfg.exists():shutil.copy2(cfg,backup/f'codegraph-{i}.json')
for i,root in enumerate(roots[:2]):assert not (root/'codegraph-api').exists()
(backup/'manifest.json').write_text(json.dumps({'source_preimages':preimages,'original_project_sources':sources},indent=2)+'\n')
stopped=[]
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:args=(p/'cmdline').read_bytes().split(b'\0')
 except (OSError,ProcessLookupError):continue
 if str(A/'dist/bin/codegraph.js').encode() in args and b'serve' in args and b'--mcp' in args:
  try:os.kill(int(p.name),15);stopped.append(int(p.name))
  except ProcessLookupError:pass
deadline=time.monotonic()+3
while any(Path('/proc',str(pid)).exists() for pid in stopped) and time.monotonic()<deadline:time.sleep(.1)
for rel in changes:
 dst=A/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(S/rel,dst)
# The exact build that passed validation is installed, preserving the old dist in backup.
shutil.copytree(S/'dist',A/'dist',dirs_exist_ok=True)
for label,root in zip(['missiles','inventory'],roots):
 profile=B/('profile-'+label)
 shutil.copytree(profile/'codegraph-api',root/'codegraph-api')
 shutil.copy2(profile/'codegraph.json',root/'codegraph.json')
assert all(hashlib.sha256((A/r).read_bytes()).hexdigest()==hashlib.sha256((S/r).read_bytes()).hexdigest() for r in changes)
assert all(hashlib.sha256((Path(row['root'])/r).read_bytes()).hexdigest()==h for row in sources for r,h in row['source_sha256'].items())
(B/'original-production-sources.json').write_text(json.dumps(sources,indent=2)+'\n')
(B/'promotion.json').write_text(json.dumps({'identity':'1.6.2+jass-vjass.5','extraction':32,'schema':12,'backup':str(backup),'changes':changes,'stopped_pids':stopped,'installed_validated_build':True,'original_sources_unchanged':True,'production_indexes':'pending','app_reload':'pending'},indent=2)+'\n')
print('INSTALLED .5; stopped',stopped,'backup',backup,flush=True)
