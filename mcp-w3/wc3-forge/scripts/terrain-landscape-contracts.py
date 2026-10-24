"""Write the explicit Classic landscape schemas; semantic validation remains in Go."""
import json,copy
from pathlib import Path
repo=Path(__file__).resolve().parents[1]
dest=repo/'examples/terrain'
root=repo.parent/'artifacts/warcraft-terrain/integrated-landscapes-v1/contracts'
S={'type':'string','minLength':1}; N={'type':'integer','minimum':0,'maximum':2147483647}; H={'type':'string','pattern':'^[a-f0-9]{64}$'}
def obj(props,required=None):return dict(type='object',additionalProperties=False,properties=props,required=list(props) if required is None else required)
def arr(item,**kw):return dict(type='array',items=item,**kw)
def schema(id,data):return {'$schema':'https://json-schema.org/draft/2020-12/schema','$id':id,**data}
group=obj(dict(id=S,parent=S,members=arr(S,minItems=1,uniqueItems=True),isolated={'type':'boolean'},reason=S))
relation=obj(dict(id=S,kind={'enum':['same-landmass','near','access','crossing','feeds','shore-attached']},**{'from':S,'to':S},from_port=S,to_port=S,width={'type':'number','minimum':64,'maximum':1024}))
counts=obj({k:{'type':'integer','minimum':0,'maximum':2} for k in ['temple','circle','platform','lagoon','bridge','waterfall']})
brief=schema('urn:wc3-forge:landscape-brief:v1',obj(dict(format={'const':'wc3-landscape-brief-v1'},id={'enum':['D','E','F']},intent=S,counts=counts,seeds=arr(N,minItems=4,maxItems=4,uniqueItems=True),groups=arr(group,minItems=1),relations=arr(relation,minItems=1))))
xy=arr({'type':'number','multipleOf':64},minItems=2,maxItems=2)
module=obj(dict(family=S,name=S,members=arr(N,minItems=1,uniqueItems=True),height_policy={'enum':['absolute-rigid','ground-offset','water-offset','parent-relative']},parent_source_id=N,variant_shifts=arr(arr(xy,minItems=1),minItems=2,maxItems=2)),['family','name','members','height_policy','variant_shifts'])
library=schema('urn:wc3-forge:landscape-library:v3',obj(dict(format={'const':'wc3-composition-library-v3'},base_library=S,base_sha256=H,source_sha256=H,modules=arr(module,minItems=3))))
spec=json.loads((dest/'scene-v3.schema.json').read_text())
spec['$id']='urn:wc3-forge:scene:v4';spec['title']='Classic integrated landscapes, explicit D/E/F profile'
spec['required'].append('landscape');spec['properties']['format']={'const':'wc3-scene-spec-v4'};spec['properties']['mode']={'const':'whole-map-landscape'}
spec['properties']['wfc_tries']['maximum']=8;spec['properties']['wfc_steps']['maximum']=50000
spec['properties']['recompose']['properties']['layout_attempts']['maximum']=128
embedded=copy.deepcopy(brief);embedded.pop('$id');embedded.pop('$schema')
spec['properties']['landscape']=obj(dict(library=S,library_sha256=H,brief=embedded,streams=obj({k:N for k in ['layout','relief','water','variants','materials','vegetation','ornaments']}),vegetation={'enum':['habitat','s-control','bare']}))
for name,value in [('landscape-brief-v1.schema.json',brief),('landscape-library-v3.schema.json',library),('scene-v4.schema.json',spec)]:
 for folder in [dest,root]:
  folder.mkdir(parents=True,exist_ok=True);(folder/name).write_text(json.dumps(value,indent=2)+'\n')
print(root)
