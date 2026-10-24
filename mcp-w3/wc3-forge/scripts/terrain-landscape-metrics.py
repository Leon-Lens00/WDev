"""Measure exported forest cohorts, shore/route distances and support transitions."""
import json,math,sys
from pathlib import Path
run=Path(sys.argv[1]).resolve()
def read(p):return json.loads(p.read_text(encoding='utf-8-sig'))
layout=read(run/'layout.json');physical=read(run/'physical-layers.json');ds=read(run/'placements.json');prov={x['creation_id']:x for x in read(run/'placements-provenance.json')}
forest=[d for d in ds if prov[d['CreationNumber']]['role']=='forest']
def quantiles(xs):
 xs=sorted(xs);return [xs[int((len(xs)-1)*q)] for q in [.25,.5,.75,.95]] if xs else []
def xy(i):return [i%193*128-12288,i//193*128-4096]
water=[xy(i) for i,h in enumerate(layout['vertex_habitats']) if h=='water']
routes=[xy for r in layout['routes'] for xy in r['trace']]
groups={}
for d in forest:
 h=prov[d['CreationNumber']]['family'];scale=max(d['Scale'][:2]);bucket='small' if scale<1 else 'medium' if scale<2 else 'large-native-model-scale'
 for name in [h,h+'/'+d['TypeID'],h+'/'+d['TypeID']+'/'+bucket]:groups.setdefault(name,[]).append(d)
cohorts={}
for name,trees in groups.items():
 points=[d['Position'][:2] for d in trees];n=len(points)
 summary=dict(count=n)
 if n>=30 or '/' not in name:
  nearest=[];neighbors=[]
  for k,p in enumerate(points):
   distances=[math.dist(p,q) for j,q in enumerate(points) if k!=j]
   if distances:nearest.append(min(distances));neighbors.append(sum(d<=256 for d in distances))
  summary.update(nearest_quantiles=quantiles(nearest)[:3],neighbors256=sum(neighbors)/n if n else 0)
 if '/' not in name:
  area=sum(h==name and dry for h,dry in zip(layout['vertex_habitats'],physical['dry']))*128**2
  summary.update(valid_area=area,trees_per_million_units=n/max(1,area)*1e6,shore_distance_quantiles=quantiles([min(math.dist(p,q) for q in water) for p in points]),route_distance_quantiles=quantiles([min(math.dist(p,q) for q in routes) for p in points]))
 cohorts[name]=summary
joins={}
for i,k in enumerate(layout['vertex_masks']):
 for j in [i+1,i+193]:
  if j>=len(physical['dry']) or j==i+1 and j//193!=i//193:continue
  other=layout['vertex_masks'][j]
  if k=='transition' or other=='transition':
   name='/'.join(sorted([k,other]));joins.setdefault(name,[]).append(abs(physical['ground_heights'][i]-physical['ground_heights'][j]))
result=dict(map_sha256=physical['map_sha256'],forest=cohorts,support_join_height_delta_per_128={k:dict(count=len(v),quantiles=quantiles(v),maximum=max(v)) for k,v in joins.items()},measurement_notes=['Forest excludes essential source trees; area uses dry semantic habitat vertices.','Shore distances use physical wet vertices; route distances use measured collision-clear traces.','Scale classes report model units, not a comparison of actual crown size between different MDX.','Sharp rigid source features remain intentional; adaptable routes are separately checked with a 32-unit collision radius.'])
(run/'habitat-and-join-metrics.json').write_text(json.dumps(result,indent=2)+'\n')
print(run.name,'forest',len(forest),'profiles',len(cohorts))
