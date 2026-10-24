from pathlib import Path
import hashlib, importlib.util, json
from mpyq import MPQArchive
R=Path(__file__).parent/'projects/inventorysys-lab'
spec=importlib.util.spec_from_file_location('b',R/'tools/build.py');b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
sha=lambda x:hashlib.sha256(x).hexdigest()
original=(R/'baseline/original.w3x').read_bytes();base=(R/'baseline/members/war3map.j').read_bytes()
rows=[]
for mode in ('button','picture','text','camera'):
 for rev in ('01','02'):
  rid=f'itl-{mode}-20261019-{rev}';run=R/'reports/technical/runs'/rid;f=R/f'reports/technical/inputs-20261019-{rev}'
  a=(run/'assembled.j').read_bytes();m=json.loads((run/'build.json').read_text());data=(run/(rid+'.w3x')).read_bytes()
  assert b.assemble(base,(f/'globals.j').read_bytes(),(f/'functions.j').read_bytes(),'ITL_Init',rid,early=(f/'early.j').read_bytes(),hooks=json.loads((f/'hooks.json').read_text()))==a
  stripped=a
  for s in reversed(m['insertions']):
   assert sha(stripped[s['offset']:s['offset']+s['size']])==s['sha256']
   stripped=stripped[:s['offset']]+stripped[s['offset']+s['size']:]
  assert stripped==base
  p,mm,_=b.read_map(data,MPQArchive);op,om,_=b.read_map(original,MPQArchive)
  assert p==op and mm['war3map.j']==a and all(mm[k]==v for k,v in om.items() if k!='war3map.j')
  assert b.verify_archive_preservation(original,data,MPQArchive)['preserved_identities']==52
  assert sha(data)==m['sha256']
  commands=json.loads((run/'commands.json').read_text());assert [c['returncode'] for c in commands]==[0,0]
  rows.append(dict(run=rid,map_sha256=sha(data),checks='assembly, strip, prefix, named members, 52 identities, recorded commands: OK'))
for n in ('early.j','functions.j','globals.j','hooks.json'):
 assert (R/'src/technical'/n).read_bytes()==(R/'reports/technical/inputs-20261019-02'/n).read_bytes()
a=(R/'reports/technical/inputs-20261019-01/early.j').read_bytes();c=(R/'src/technical/early.j').read_bytes()
assert a.replace(b'string event,',b'string eventName,').replace(b'event +',b'eventName +').replace(b'ITL_Boundary(event,',b'ITL_Boundary(eventName,')==c
assert sha(original)=='a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada'
print(json.dumps(rows,indent=2));print('Current=frozen02; early01->02 parameter rename only; original hash unchanged.')
