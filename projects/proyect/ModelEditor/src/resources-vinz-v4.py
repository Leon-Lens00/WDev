"""Resolve only real, byte-identical local resources; retain missing dependency records."""
from pathlib import Path
import json,hashlib,subprocess,concurrent.futures
ROOT=Path(__file__).resolve().parents[1];EV=ROOT/'evidence/x3-v4/study';OUT=ROOT/'assets/vinz-study-v4';OUT.mkdir(parents=True,exist_ok=True)
FROZEN=Path('/home/snz/Documentos/ChatGPT/FrozenThone');GAME=FROZEN/'games/WarcraftIII-1.27b';CLI=FROZEN/'scripts/wc3.py'
paths=json.loads((EV/'stock-paths.json').read_text());known={}
cache=ROOT/'assets/recursos-originales'
for p in cache.rglob('*.blp'):known[str(p.relative_to(cache)).replace('/','\\').lower()]=p
# Include team resources requested by the native MDX renderer.
paths += [f'ReplaceableTextures\\TeamColor\\TeamColor{i:02}.blp' for i in range(28)]+[f'ReplaceableTextures\\TeamGlow\\TeamGlow{i:02}.blp' for i in range(28)]
paths=sorted(set(paths),key=str.lower)
def resolve(internal):
 target=OUT/(hashlib.sha256(internal.lower().encode()).hexdigest()[:20]+'.blp')
 if target.exists():return dict(path=internal,file=str(target.relative_to(ROOT)),sha256=hashlib.sha256(target.read_bytes()).hexdigest(),source='cached extraction')
 p=known.get(internal.lower())
 if p:
  target.write_bytes(p.read_bytes());return dict(path=internal,file=str(target.relative_to(ROOT)),sha256=hashlib.sha256(target.read_bytes()).hexdigest(),source=str(p.relative_to(ROOT)))
 if internal.startswith('_hd.') or any(f'{i:02}.blp' in internal for i in range(12,28)) and internal.startswith('ReplaceableTextures\\Team'):
  return dict(path=internal,file=None,reason='Requires post-Classic game assets; not installed')
 for name in ['War3Patch.mpq','War3xlocal.mpq','War3x.mpq','war3.mpq']:
  archive=GAME/name
  r=subprocess.run(['python',str(CLI),'wc3ctl','extract',str(archive),internal,'-o',str(target),'--json'],capture_output=True,text=True)
  if r.returncode==0 and target.exists():return dict(path=internal,file=str(target.relative_to(ROOT)),sha256=hashlib.sha256(target.read_bytes()).hexdigest(),source=str(archive))
 return dict(path=internal,file=None,reason='Absent from installed Classic MPQ chain')
with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:records=list(pool.map(resolve,paths))
(EV/'resources.json').write_text(json.dumps(records,indent=2)+'\n');print(json.dumps({'requested':len(records),'resolved':sum(bool(x['file']) for x in records),'unresolved':[x['path'] for x in records if not x['file']]}))
