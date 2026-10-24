from pathlib import Path
import json,hashlib,shutil,sqlite3,os,subprocess,datetime
B=Path(__file__).resolve().parent; S=B/'checkout'; A=Path('/home/snz/Documentos/MCP W3/codegraph-vjass')
base=json.loads((B/'baseline.json').read_text());conflicts=[]
for f,h in base.items():
 p=A/f
 if not p.is_file() or hashlib.sha256(p.read_bytes()).hexdigest()!=h:conflicts.append(f)
if conflicts:raise RuntimeError('Active baseline changed: '+repr(conflicts))
subprocess.run(['python3','/home/snz/.codex/skills/judgment-day/scripts/snapshot.py','verify-source',str(S),str(B/'review-r2'),'d3daa5f81f8254d5fe8f3ae59d506fd9dd638e847b73e559d4bf66cf3c660846'],check=True)
# Require the complete final A/B, not abandoned preflight cells.
measured=json.loads((B/'agent-ab/results.json').read_text())
if len(measured)!=36 or any(x['exit'] or not x['source_hashes_unchanged'] for x in measured):raise RuntimeError('Final eval incomplete or failed')
files=json.loads((B/'review-r2-files.json').read_text());changes=[f for f in files if not (A/f).exists() or (S/f).read_bytes()!=(A/f).read_bytes()]
backup=B/('production-backup-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'));backup.mkdir();preimages=[]
for f in changes:
 p=A/f;preimages.append({'path':f,'existed':p.exists(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest() if p.exists() else None})
 if p.exists():dst=backup/'source'/f;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
shutil.copytree(A/'dist',backup/'dist')
roots=[Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src'),Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration'),Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist')]
for i,r in enumerate(roots):
 source=sqlite3.connect('file:'+str(r/'.codegraph/codegraph.db')+'?mode=ro',uri=True);dest=sqlite3.connect(backup/('index-'+str(i)+'.sqlite'));source.backup(dest);dest.close();source.close()
(backup/'manifest.json').write_text(json.dumps({'preimages':preimages,'index_roots':list(map(str,roots))},indent=2))
# Stop only old production CodeGraph stdio processes, never other MCP services.
stopped=[]
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:args=(p/'cmdline').read_bytes().split(b'\0')
 except (FileNotFoundError,PermissionError,ProcessLookupError):continue
 if str(A/'dist/bin/codegraph.js').encode() in args and b'serve' in args and b'--mcp' in args:
  try:os.kill(int(p.name),15);stopped.append(int(p.name))
  except ProcessLookupError:pass
for f in changes:
 dst=A/f;dst.parent.mkdir(parents=True,exist_ok=True);tmp=dst.with_name(dst.name+'.cg-stage');shutil.copy2(S/f,tmp);os.replace(tmp,dst)
# Preserve a reconstructable deployment record even if a later build fails.
(B/'promotion.json').write_text(json.dumps({'backup':str(backup),'changed_files':changes,'stopped_pids':stopped,'source_copied':True,'build':'pending'},indent=2))
print('COPIED',len(changes),'BACKUP',backup,'STOPPED',stopped,flush=True)
