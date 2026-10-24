"""Inspect real native saves by field/region and compile their JASS, never run WC3."""
from pathlib import Path
from collections import Counter,defaultdict
import json,hashlib,subprocess,struct,importlib.util
ROOT=Path(__file__).resolve().parents[2];R=ROOT/'wc3-forge';T=ROOT/'artifacts/warcraft-terrain/contextual-materials-v1'
CLI=R/'build/bin/terrain-gen-materials.exe';INSTALL=Path('C:/Users/Leon/Downloads/Warcraft III 1.27')
PJASS=Path('C:/Users/Leon/Documents/W3/build/HiveWE-reference/data/tools/pjass.exe');JASS=ROOT/'artifacts/warcraft-terrain/tropical-v1/game-test-v3'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2)+'\n')
def extract(mp,name,out):
 with out.with_suffix(out.suffix+'.log').open('w') as log:subprocess.run([str(CLI),'resource','-map',str(mp),'-install',str(INSTALL),'-resource',name,'-out',str(out)],cwd=R,stdout=log,stderr=subprocess.STDOUT,check=True)
spec=importlib.util.spec_from_file_location('stats',R/'scripts/terrain-materials-statistics.py');stats=importlib.util.module_from_spec(spec);spec.loader.exec_module(stats)
report={'accepted':False,'game_executed':False,'compiler_sha256':sha(PJASS),'common_sha256':sha(JASS/'common.j'),'blizzard_sha256':sha(JASS/'blizzard.j'),'cases':[]}
for b,seed in [('D',52700),('E',53700),('F',54700)]:
 generated=T/f'runs/{b}/{seed}/Tropical-{b}-{seed}-materials.w3x';native=T/f'editor/{b}/Tropical-{b}-{seed}-materials-editor.w3x';out=T/f'editor/{b}/fields';out.mkdir(parents=True,exist_ok=True)
 for mode,mp in [('generated',generated),('native',native)]:
  for name in ['war3map.wpm','war3map.w3e','war3map.j']:extract(mp,name,out/f'{mode}-{name}')
 script=out/'native-war3map.j'
 with (out/'pjass.log').open('w') as log:subprocess.run([str(PJASS),str(JASS/'common.j'),str(JASS/'blizzard.j'),str(script)],cwd=R,stdout=log,stderr=subprocess.STDOUT,check=True)
 a=(out/'generated-war3map.wpm').read_bytes();z=(out/'native-war3map.wpm').read_bytes();assert a[:16]==z[:16] and len(a)==len(z)
 w,h=struct.unpack_from('<II',a,8);assert (w,h)==(768,384)
 palette,pts=stats.terrain(out/'native-war3map.w3e');layout=read(T/f'runs/{b}/{seed}/layout.json');features=read(T/f'runs/{b}/{seed}/materials.json')['features']
 fields={};regions=defaultdict(Counter)
 for bit in [1,2,4,8,16,32,64,128]:
  fields[str(bit)]={'set':sum(not(x&bit) and bool(y&bit) for x,y in zip(a[16:],z[16:])),'cleared':sum(bool(x&bit) and not(y&bit) for x,y in zip(a[16:],z[16:]))}
 for i,(x,y) in enumerate(zip(a[16:],z[16:])):
  if x==y:continue
  v=i%w//4+(i//w//4)*193
  group=f"{layout['vertex_masks'][v]}/{features[v]['context']}/{palette[pts[v]['tex']]}"
  regions[group][f'{x}->{y}']+=1
 data={'generated_sha256':sha(generated),'native_sha256':sha(native),'same_terrain':sha(out/'generated-war3map.w3e')==sha(out/'native-war3map.w3e'),'wpm_dimensions':[w,h],'bits_changed':fields,'region_transitions':dict(regions),'region_key':'layout mask/context ID/texture at SW terrain vertex; aggregated 4x4 pathing cells','movement_acceptance':'separate native route audit with object pathing and collision radius 32; this field inventory alone does not grant approval'}
 write(out/'pathing.json',data)
 report['cases'].append({'brief':b,'native_sha256':sha(native),'native_script_sha256':sha(script),'generated_script_sha256':sha(out/'generated-war3map.j'),'exit_code':0,'pjass_log_sha256':sha(out/'pjass.log'),'fields_sha256':sha(out/'pathing.json')})
base=T/'experiments/native-base-D/Tropical-D-52700-before-editor.w3x'
if base.exists():
 out=base.parent;extract(base,'war3map.wpm',out/'war3map.wpm');a=(out/'war3map.wpm').read_bytes();b=(T/'editor/D/fields/native-war3map.wpm').read_bytes();assert a[:16]==b[:16]
 diff={str(bit):sum(bool(x&bit)!=bool(y&bit) for x,y in zip(a[16:],b[16:])) for bit in [1,2,4,8,16,32,64,128]}
 write(out/'comparison.json',{'before_map_sha256':sha(base),'after_map_sha256':sha(T/'editor/D/Tropical-D-52700-materials-editor.w3x'),'changed_by_bit':diff,'same_walkability':diff['2']==0,'same_flyability':diff['4']==0})
report['accepted']=True;write(T/'reproduction/pjass-native.json',report)
print('Three native scripts compile. Field/region inventories written; route approval remains separate.')
