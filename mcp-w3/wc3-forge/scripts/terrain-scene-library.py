"""Compile reviewed annotations into an explicit, complete source library.

Usage: python scripts/terrain-scene-library.py ARTIFACT_ROOT
No image is approved by this script: review.json is a required human/agent record.
"""
import sys, json, hashlib, math, html
from pathlib import Path

root = Path(sys.argv[1]).resolve()
dis = root / 'discovery'
libdir = root / 'library'
libdir.mkdir(exist_ok=True)
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def write(p, v): p.write_text(json.dumps(v, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def inside(d, r): return all(r['min'][k] <= d['xy'][k] <= r['max'][k] for k in range(2))
review = read(dis/'review.json')
assert review['complete'] and review['reviewed_sectors'] == 32
items = read(dis/'inventory.json')
by = {d['id']:d for d in items}
annotations = read(dis/'component-annotations.json')
previous = read(dis/'source-library.json')
groups, components, recipes, coverage = [], [], [], {}
optional = {'D000','D002','D003','D004','D005','D006','ZPfw','ZPsh','ZPms','ZPvp','APbs'}
trees = {'B000','B001','B002','B003','B004','ZTtc'}
for old in previous['compositions']:
    c = {k:old[k] for k in ['id','source','blend','anchors','rotations']}
    if old.get('adjustments'): c['adjustments'] = old['adjustments']
    c.update(kind='main', habitat='annotated-support', evidence=[str(dis/'sectors'/f"{by[old['pieces'][0]['CreationNumber']]['sector']}.png")])
    ids = [d['CreationNumber'] for d in old['pieces']]
    c['required'] = [n for n in ids if by[n]['rawcode'] not in optional]
    c['optional'] = [n for n in ids if by[n]['rawcode'] in optional]
    components.append(c)
    for n in ids: assert n not in coverage; coverage[n] = c['id']
for a in annotations:
    # Conservative support snapped outwards onto the donor vertex grid.
    r = dict(min=[math.floor(x/128)*128 for x in a['source']['min']], max=[math.ceil(x/128)*128 for x in a['source']['max']])
    ids = [d['id'] for d in items if d['id'] not in coverage and inside(d,r)]
    assert set(a['required_anchors']).issubset(ids), a['id']
    c = dict(id=a['id'], source=r, blend=a['blend'], rotations=a['rotations'], kind='micro',
             anchors={f'anchor-{n}':by[n]['xy'] for n in a['required_anchors']}, habitat='annotated-support',
             required=[n for n in ids if by[n]['rawcode'] not in optional],
             optional=[n for n in ids if by[n]['rawcode'] in optional],
             evidence=[str(dis/'details'/f"{a['id']}-{v}.png") for v in ['context','detail']])
    components.append(c)
    for n in ids: assert n not in coverage; coverage[n] = c['id']
for c in components:
    # Shared subgroups may be referenced more than once; expansion deduplicates IDs.
    for role in ['required','optional']:
        groups.append(dict(id=c['id']+'/'+role, members=c[role]))
    groups.append(dict(id=c['id']+'/all', members=[],children=[c['id']+'/required',c['id']+'/optional']))
    c['groups']=[c['id']+'/all']
for raw in sorted({d['rawcode'] for d in items if d['id'] not in coverage}):
    ids=[d['id'] for d in items if d['rawcode']==raw and d['id'] not in coverage]
    habitat = 'forest' if raw in trees else 'land'
    if raw in {'ZWbg','ZWsw','ZWsf'}: habitat='shallow-water'
    if raw in {'ZOsh','ZPru'}: habitat='shore'
    if raw in {'ZRrs','ZRrk','ZRsp','ARrk','ZRbs','ZRbd'}: habitat='rocky'
    recipe=dict(id='environment-'+raw,source_ids=ids,habitat=habitat,
                height_policy='water-offset' if raw in {'ZWbg','ZWsw'} else 'ground-offset',density=1.0)
    recipes.append(recipe)
    for n in ids: coverage[n]=recipe['id']
cohorts=[]
for name,coords,sectors in [('interior-central',[-1152,0,1024,1664],['sector-2-4','sector-2-5']),
                            ('palmeral-southern',[-768,-3072,1408,-1664],['sector-1-4','sector-1-5']),
                            ('slope-eastern',[9472,4096,11264,6400],['sector-3-8','sector-4-8'])]:
    r=dict(min=coords[:2],max=coords[2:])
    ids=[d['id'] for d in items if d['rawcode'] in trees and inside(d,r)]
    assert len(ids)>=30
    cohorts.append(dict(id=name,bounds=r,source_ids=ids,evidence=[str(dis/'sectors'/f'{s}.png') for s in sectors],
        minimum_spacing=64,close_pair_spacing=90 if name=='interior-central' else 64,
        thin_close_pairs=name=='interior-central',anchor_neighbor_max=65 if name=='palmeral-southern' else 0))
assert len(coverage)==len(items) and len({by[n]['rawcode'] for n in coverage})==65
library=dict(format='wc3-composition-library-v2',source_sha256=previous['source_sha256'],components=components,
             groups=groups,recipes=recipes,forest_cohorts=cohorts,coverage=coverage,
             review=str(dis/'review.json'),review_sha256=sha(dis/'review.json'))
write(libdir/'library-v2.json',library)
write(dis/'coverage.json',dict(source_sha256=previous['source_sha256'],assigned=len(coverage),types=65,unassigned=[],owners=coverage))
decisions=[]
for c in read(dis/'candidates.json'):
    owners=sorted({coverage[n] for n in c['anchors']})
    c.update(status='resolved',owners=owners,decision='Reviewed with complete sectors and motif/environment context; explicit membership in library.')
    decisions.append(c)
write(dis/'discovery.json',dict(candidates=decisions,pending=[],review=str(dis/'review.json')))
profile=[]
for c in cohorts:
    pts=[by[n]['xy'] for n in c['source_ids']]
    nearest=sorted(min(math.dist(a,b) for j,b in enumerate(pts) if i!=j) for i,a in enumerate(pts))
    neighbors=sum(sum(i!=j and math.dist(a,b)<=256 for j,b in enumerate(pts)) for i,a in enumerate(pts))/len(pts)
    profile.append(dict(**c,n=len(pts),nn_quantiles=[nearest[int((len(nearest)-1)*p)] for p in [.25,.5,.75]],neighbors256=neighbors))
write(libdir/'forest-profile-v1.json',dict(format='wc3-forest-profile-v1',cohorts=profile,
    canopy=dict(method='annotated visual envelopes; approximate, independent of pathing',radii_at_scale_one={'B000':175,'B001':260,'B002':155,'B003':155,'B004':165,'ZTtc':210},
                evidence='Original sectors and oblique details show interlocking crowns; envelope coverage is only a proxy.'),
    criteria=dict(min_cohort=30,interior_nn_median_max=160,neighbors256_min=3,quantile_relative_tolerance=.25),
    sampling='Free generated trees only. Interior grouped patches; edges and beach clearings reported separately.'))
rows=[]
for d in items:
    owner=coverage[d['id']]
    rows.append(f"<tr><td>{d['id']}</td><td>{html.escape(d['rawcode'])}</td><td>{html.escape(d['model'])}</td><td>{d['xy']}</td><td>{owner}</td><td><a href='sectors/{d['sector']}.png'>{d['sector']}</a></td></tr>")
gallery=''.join(f"<figure><a href='sectors/{r['id']}.png'><img loading='lazy' src='sectors/{r['id']}.png'></a><figcaption>{r['id']}: {html.escape(r['notes'])}</figcaption></figure>" for r in read(dis/'sector-review.json')['reviews'])
details=''.join(f"<figure><a href='details/{p.name}'><img loading='lazy' src='details/{p.name}'></a><figcaption>{p.stem}</figcaption></figure>" for p in sorted((dis/'details').glob('*.png')))
(dis/'index.html').write_text('''<!doctype html><meta charset="utf-8"><title>Atlas Tropical completo</title><style>body{font:16px system-ui;background:#13231e;color:#e7f0dc;margin:24px}a{color:#9cdec0}.gallery{display:grid;grid-template-columns:repeat(3,1fr);gap:12px}figure{margin:0}img{width:100%}table{border-collapse:collapse;font-size:13px}td{padding:6px;border-bottom:1px solid #43564d}input{padding:12px;width:60%;position:sticky;top:0}summary{cursor:pointer}</style><h1>Atlas del donante Tropical</h1><p>32 sectores revisados, 3.203 objetos / 65 tipos asignados. Ningún pendiente. Imágenes reales sin modificar.</p><p><a href="review.json">Registro de revisión</a> · <a href="discovery.json">100 propuestas resueltas</a> · <a href="sector-views.json">Cámaras de sectores</a> · <a href="detail-views.json">Cámaras de detalle</a> · <a href="../library/library-v2.json">Miembros, grupos y soportes</a></p><details open><summary>Sectores</summary><div class="gallery">'''+gallery+'</div></details><details><summary>Motivos y hábitats</summary><div class="gallery">'+details+'''</div></details><h2>Objetos y tratamiento</h2><input id="q" placeholder="Buscar rawcode, modelo, ID, propietario o coordenadas"><table><thead><tr><th>ID</th><th>Tipo</th><th>Modelo efectivo</th><th>XY</th><th>Tratamiento</th><th>Imagen</th></tr></thead><tbody>'''+''.join(rows)+'''</tbody></table><script>q.oninput=()=>{for(const r of document.querySelectorAll('tbody tr'))r.hidden=!r.textContent.toLowerCase().includes(q.value.toLowerCase())}</script>''',encoding='utf-8')
print(json.dumps(dict(components=len(components),recipes=len(recipes),coverage=len(coverage),cohorts=[(c['id'],c['n']) for c in profile])))

