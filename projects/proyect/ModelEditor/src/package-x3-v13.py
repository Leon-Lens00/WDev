from pathlib import Path
import json,hashlib,zipfile
root=Path(__file__).resolve().parents[1];out=root/'exports/megaman-x3-buster-v13';dest=out.with_suffix('.zip');ev=root/'evidence/x3-v13'
assert not dest.exists(),'Never silently replace a released ZIP'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
build=json.loads((ev/'build.json').read_text());verification=json.loads((ev/'verification.json').read_text());native=json.loads((ev/'native-validation.json').read_text())
assert verification['status']=='PASS' and native['state']=='Tested in map'
for e in build['entries']:assert sha(root/e['path'])==e['sha256']
for path,h in json.loads((ev/'bases-preservadas.json').read_text()).items():assert sha(Path(path))==h
files={str(p.relative_to(out)):sha(p) for p in sorted(out.rglob('*')) if p.is_file()}
(out/'manifest.json').write_text(json.dumps({'revision':'V13','models':build['entries'],'files':files,'previousFilesPreserved':verification['preservedFiles'],'gameTest':'Classic 1.27b SP / YDWE / screen 3','worldTrajectory':False},indent=2))
with zipfile.ZipFile(dest,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for p in sorted(out.rglob('*')):
  if p.is_file():z.write(p,p.relative_to(out.parent))
with zipfile.ZipFile(dest) as z:
 assert z.testzip() is None
 for p in out.rglob('*'):
  if p.is_file():assert z.read(str(p.relative_to(out.parent)))==p.read_bytes()
result={'zip':str(dest),'sha256':sha(dest),'bytes':dest.stat().st_size,'members':len(z.namelist()),'reextractedBytesMatch':True,'preservedFiles':verification['preservedFiles']}
(ev/'package.json').write_text(json.dumps(result,indent=2));print(json.dumps(result))
