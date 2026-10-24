"""Versioned, reproducible contracts for the prescribed D/E/F experiments."""
import json, hashlib
from pathlib import Path
workspace=Path(__file__).resolve().parents[2]
root=workspace/'artifacts/warcraft-terrain/integrated-landscapes-v1'
base=workspace/'artifacts/warcraft-terrain/scene-generator-v1/library/library-v2.json'
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p,v):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(v,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
lib=read(base)
modules=[dict(family='barricade-nw',name='five-connected-sections',members=[723,724,725,726,727],height_policy='ground-offset',variant_shifts=[[[0,0]]*5,[[0,0],[-64,-64],[-64,-64],[-64,0],[0,64]]]),
dict(family='temple',name='independent-architectural-perimeter',members=[1975,1979,1985,1986,1989,1990,1991,1977,1987],height_policy='ground-offset',variant_shifts=[[[0,0],[0,0],[0,384],[0,-128],[0,0],[0,0],[0,0],[-960,192],[-384,0]],[[-128,0],[-128,0],[128,384],[-128,-128],[-128,0],[128,0],[-128,0],[-832,256],[-448,64]]])]
modules += [dict(family='waterfall',name='rigid-water-sheets',members=[265,266,274,279,280,319,320,321,322,323,324],height_policy='water-offset',variant_shifts=[[[0,0]]*11]*2),dict(family='temple',name='embedded-central-figure',members=[1997],parent_source_id=1996,height_policy='parent-relative',variant_shifts=[[[0,0]],[[0,0]]])]
write(root/'library/library-v3.json',dict(format='wc3-composition-library-v3',base_library=str(base),base_sha256=sha(base),source_sha256=lib['source_sha256'],modules=modules))
for letter,seed in [('D',52700),('E',53700),('F',54700)]:
 counts=dict(temple=1,circle=1,platform=1,lagoon=1,bridge=1,waterfall=1)
 if letter=='E':counts['platform']=2
 if letter=='F':counts.update(temple=0,platform=0,bridge=0,waterfall=2)
 ids=[f'{f}-{n+1}' for f,k in counts.items() for n in range(k)]+[c['id']+'-1' for c in lib['components'] if c['kind']=='micro']
 isolated=['broken-statue-hill-1','statue-east-1','hut-islet-1']
 members=[i for i in ids if i not in isolated]
 territories=[('shared-mainland','circle-1',members)]
 if letter=='D':
  west=['circle-1','lagoon-1','barricade-nw-1','barricade-se-1','statue-cape-1','huts-pair-1']
  territories=[('western-riverbank','circle-1',west),('eastern-riverbank','temple-1',[i for i in members if i not in west])]
 if letter=='F':
  upper=['circle-1','barricade-nw-1','statue-cape-1']
  territories=[('upper-sanctuary','circle-1',upper),('lower-watershed','waterfall-2',[i for i in members if i not in upper])]
 groups=[dict(id=id,parent=parent,members=members,isolated=False,reason='Scenes share a bank or watershed; water divides the two artistic territories') for id,parent,members in territories]
 for id in isolated:groups.append(dict(id='island-'+id,parent=id,members=[id],isolated=True,reason='Preserve the donor coastal silhouette and water-dependent perimeter of this motif'))
 rel=[]
 def relation(id,kind,a,b,ap='center',bp='center',width=128):rel.append(dict(id=id,kind=kind,**{'from':a,'to':b},from_port=ap,to_port=bp,width=width))
 for i in range(counts['waterfall']):relation(f'watercourse-{i+1}','feeds',f'waterfall-{i+1}','lagoon-1','outlet','inflow',384)
 if counts['bridge']:
  relation('bridge-water-crossing','crossing','bridge-1','waterfall-1','center','outlet',64)
  relation('circle-to-bridge','access','circle-1','bridge-1','access','shore_a',64)
  relation('bridge-to-temple','access','bridge-1','temple-1','shore_b','access',64)
 else:relation('circle-to-monolith','access','circle-1','monolith-1','access','center',64)
 if letter=='E':
  for n in [1,2]:relation(f'temple-platform-{n}','access','temple-1',f'platform-{n}','access','access',64)
 for c in lib['components']:
  i=c['id']+'-1'
  if c['kind']=='micro' and i not in isolated:
   parent=next(g['parent'] for g in groups if i in g['members']);relation('territory-'+i,'same-landmass',parent,i)
 write(root/f'briefs/{letter}.json',dict(format='wc3-landscape-brief-v1',id=letter,intent={'D':'Connected tropical valley','E':'Main island sanctuary','F':'Two waterfalls feeding a shared lagoon'}[letter],counts=counts,seeds=list(range(seed,seed+4)),groups=groups,relations=rel))
write(root/'baseline/criteria-v1.json',dict(status='initial; freeze after local experiments',dry_land=dict(formula='HasWater && WaterZ + Water.slk.height*128 > FinalZ',source_iou_max=.7,pair_iou_max=.8,micros_shared_min=8,isolated_max=3,E_main_share_min=.7),geometry=dict(rigid_height_delta=0,transition_width=896,water_surface=-89.6,channel_width=384,section_step_max=128,section_width_resolution=32,route_collision_radius=32,required_centerline_clearance=64),forest=dict(interior_n_min=30,median_max=160,neighbors256_min=3,source_quantile_tolerance=.25),budgets=dict(layout=128,wfc_tries=8,wfc_steps=50000,wfc_timeout_s=120,objects=6500,import_growth=0)))
write(root/'baseline/recipe-evidence.json',dict(format='terrain-recipe-evidence-v1',research=str(workspace/'docs/warcraft-terrain/INVESTIGACION-TERRAIN-MULTILINGUE.md'),recipes=[dict(id=id,purpose=purpose,sources=sources,conditions=conditions,local_status='pending experiment',evidence=[]) for id,purpose,sources,conditions in [('A','Shared relief and coast',['F01','F02','F05'],'Three relief scales; bare/decorated exact cameras'),('B','Water coupling',['F03','F10'],'Rigid model fall; native constant outlet water; exported cross sections'),('C','Forest interiors and edges',['F01'],'Source cohorts; isolated S/P comparison; measured crowns are proxies'),('D','Architectural assemblies',['F05','F07','F08'],'Monolithic broken statue remains rigid; independent temple perimeter modules'),('E','Material contacts',['F01','F02','F12'],'Preserve palette; review five actual contact contexts'),('F','Effective model and texture resolution',['F09'],'Use existing catalog; no imported growth; do not repair inherited flowers')]]))
print(root)
