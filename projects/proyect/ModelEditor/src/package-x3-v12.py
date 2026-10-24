"""Package final model, local resources, previews and validation; preserve older release."""
from pathlib import Path
import json,hashlib,zipfile
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'exports/megaman-x3-buster-v12';EV=ROOT/'evidence/x3-v12'
sha=lambda b:hashlib.sha256(b).hexdigest()
for p,h in json.loads((EV/'v11-preservada.json').read_text()).items():
 path=Path(p);path=path if path.is_absolute() else ROOT.parent/path
 assert sha(path.read_bytes())==h,path
native=json.loads((EV/'native-validation.json').read_text());assert native['closed']['exitCode']==0
assert sha((OUT/'A-Buster/X3_Buster_Cargado.mdx').read_bytes())==native['modelSHA256']
files=sorted(p for p in OUT.rglob('*') if p.is_file() and p.name!='manifest.json')
manifest={'modelSHA256':native['modelSHA256'],'files':{str(p.relative_to(OUT)):sha(p.read_bytes()) for p in files}}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
archive=OUT.with_suffix('.zip');assert not archive.exists(),'Final ZIP already exists'
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED) as z:
 for p in sorted(OUT.rglob('*')):
  if p.is_file():z.write(p,str(Path(OUT.name)/p.relative_to(OUT)))
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 for p in OUT.rglob('*'):
  if p.is_file():assert z.read(str(Path(OUT.name)/p.relative_to(OUT)))==p.read_bytes()
 report={'path':str(archive),'sha256':sha(archive.read_bytes()),'bytes':archive.stat().st_size,'files':len(z.namelist()),'reextraction':'all bytes equal','olderRelease':'37 entries preserved'}
(EV/'package.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
