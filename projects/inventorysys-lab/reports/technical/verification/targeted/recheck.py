from pathlib import Path
import hashlib, importlib.util, json, difflib
from mpyq import MPQArchive
S=Path(__file__).parent;R=S/'projects/inventorysys-lab';sha=lambda b:hashlib.sha256(b).hexdigest()
spec=importlib.util.spec_from_file_location('build',R/'tools/build.py');b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
f02=R/'reports/technical/inputs-20261019-02';f03=R/'reports/technical/inputs-20261019-03'
old=(f02/'functions.j').read_bytes();new=(f03/'functions.j').read_bytes()
assert old.count(b'Player(13)')==3
expected=old.replace(b'Player(13)',b'CAMERA_DUMMY_PLAYER').replace(b'local boolean ready = ITL_Clicks > 0 and ITL_Acquired > 0 and ITL_Beat > ITL_StartBeat',b'local boolean ready = ITL_Clicks > 0 and ITL_Acquired > 0 and ITL_Beat > ITL_StartBeat and ITL_ExpiredCount > 0')
assert expected==new, 'unexpected source difference'
for n in ('early.j','globals.j','hooks.json'):assert (f02/n).read_bytes()==(f03/n).read_bytes()
for n in ('early.j','globals.j','hooks.json','functions.j'):assert (R/'src/technical'/n).read_bytes()==(f03/n).read_bytes()
(S/'source.diff').write_text(''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile='frozen02/functions.j',tofile='frozen03/functions.j')))
# Exact bounded diff establishes unchanged FAIL/SKIP, raw telemetry, cleanup and one-unit gate.
original=(R/'baseline/original.w3x').read_bytes();base=(R/'baseline/members/war3map.j').read_bytes();assert sha(original)=='a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada'
rows=[]
for mode in ('button','picture','text','camera'):
 rid=f'itl-{mode}-20261019-03';run=R/'reports/technical/runs'/rid;meta=json.loads((run/'build.json').read_text());a=(run/'assembled.j').read_bytes();data=(run/(rid+'.w3x')).read_bytes()
 assert b.assemble(base,(f03/'globals.j').read_bytes(),new,'ITL_Init',rid,early=(f03/'early.j').read_bytes(),hooks=json.loads((f03/'hooks.json').read_text()))==a
 stripped=a
 for span in reversed(meta['insertions']):
  assert sha(stripped[span['offset']:span['offset']+span['size']])==span['sha256']
  stripped=stripped[:span['offset']]+stripped[span['offset']+span['size']:]
 assert stripped==base
 prefix,members,_=b.read_map(data,MPQArchive);op,om,_=b.read_map(original,MPQArchive)
 assert prefix==op and members['war3map.j']==a
 assert all(members[k]==v for k,v in om.items() if k!='war3map.j')
 preservation=b.verify_archive_preservation(original,data,MPQArchive);assert preservation['preserved_identities']==52
 assert sha(data)==meta['sha256'] and sha(a)==meta['assembled_sha256']
 commands=json.loads((run/'commands.json').read_text());assert [c['returncode'] for c in commands]==[0,0]
 for i,c in enumerate(commands,1):assert json.loads((run/f'command-{i}.json').read_text())==c
 rows.append(dict(run=rid,map_sha256=sha(data),script_sha256=sha(a),preserved_identities=52,recorded_commands=commands))
report=dict(source_change='exactly three owner substitutions and expiry readiness prerequisite',source_sha256=sha(new),maps=rows,original_sha256=sha(original))
(S/'proof.json').write_text(json.dumps(report,indent=2)+'\n')
print('Exact source delta: OK; remaining original adapter bytes unchanged.')
for row in rows:print(row['run'],row['map_sha256'],row['script_sha256'],'assembly/strip/prefix/members/52identities OK; recorded native exits 0,0')
print('Original map hash:',sha(original))
