"""Package the reviewed organized collections; verify every archived member."""
from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parents[1]
entries=[]
for slug,count in [('shots-vol-i',36),('shots-vol-ii',18)]:
    folder=ROOT/'exports'/(slug+'-organizados-brillo')
    assert len(list(folder.rglob('*.mdx')))==count
    target=folder.with_suffix('.zip');assert not target.exists(),target
    files=sorted(p for p in folder.rglob('*') if p.is_file())
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
        for p in files:z.write(p,Path(folder.name)/p.relative_to(folder))
    with zipfile.ZipFile(target) as z:
        assert z.testzip() is None
        assert len(z.namelist())==len(files)
        for p in files:assert z.read(str(Path(folder.name)/p.relative_to(folder)))==p.read_bytes()
    entries.append({'zip':str(target),'models':count,'members':len(files),'bytes':target.stat().st_size,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'crcAndBytes':'PASS'})
(ROOT/'evidence/brillo/packages.json').write_text(json.dumps(entries,indent=2)+'\n')
print(json.dumps(entries))
