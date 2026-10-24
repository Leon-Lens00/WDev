"""Measure actual exported W3X terrain and emit an auditable comparison (stdlib only)."""
import argparse
import collections
import hashlib
import itertools
import json
import math
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--batch', type=Path, required=True)
parser.add_argument('--out', type=Path, required=True)
args = parser.parse_args()
repo = Path(__file__).resolve().parents[1]
batch, out = args.batch.resolve(), args.out.resolve()
out.mkdir(parents=True, exist_ok=True)
data = json.loads((batch / 'batch.json').read_text(encoding='utf-8'))
records, masks = [], {}

def components(mask):
    left = {i for i, v in enumerate(mask) if v}
    sizes = []
    while left:
        start = left.pop()
        queue = collections.deque([start])
        size = 0
        while queue:
            i = queue.popleft()
            size += 1
            x, y = i % 192, i // 192
            for dx, dy in [(1,0),(-1,0),(0,1),(0,-1)]:
                xx, yy = x+dx, y+dy
                n = xx + yy*192
                if 0 <= xx < 192 and 0 <= yy < 96 and n in left:
                    left.remove(n)
                    queue.append(n)
        sizes.append(size)
    return sorted(sizes, reverse=True)

for report in data['reports']:
    seed = report['seed']
    run = batch / str(seed)
    path = run / f'Tropical-Recomposed-{seed}.w3x'
    extracted = out / str(seed)
    subprocess.run([str(repo/'build/bin/terrain-gen.exe'), 'inspect', '--map', str(path), '--out', str(extracted)], check=True, cwd=repo)
    terrain = json.loads((extracted/'terrain.json').read_text(encoding='utf-8'))
    layout = json.loads((run/'layout.json').read_text(encoding='utf-8'))
    heights = [(t['GroundHeight']-8192)/4+(t['LayerHeight']-2)*128 for t in terrain['Tiles']]
    mask = [heights[x+y*193] >= -89.6 for y in range(96) for x in range(192)]
    masks[seed] = mask
    delta = [{'id':p['id'], 'distance':math.hypot(*p['offset']), 'offset':p['offset'], 'destination':p['center']} for p in layout['placements']]
    comp = components(mask)
    records.append({'seed':seed, 'map_sha256':hashlib.sha256(path.read_bytes()).hexdigest(), 'source_land_iou':layout['source_land_iou'], 'source_land_cells':layout['source_land_cells'], 'output_land_cells':sum(mask), 'land_components_cells':comp, 'major_land_components_over_100_cells':sum(n>100 for n in comp), 'height_range':[min(heights),max(heights)], 'displacements':delta, 'changed_distance_pairs':layout['changed_distance_pairs'], 'layout_attempt':layout['attempt'], 'composition_pieces':report['composition_pieces'], 'new_decoration':report['added_objects']-report['composition_pieces']})
    # Actual land-cell silhouette, then explicit graph and routes. No fabricated render.
    svg=['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1920 960"><rect width="1920" height="960" fill="#12445c"/>']
    for i, land in enumerate(mask):
        if land: svg.append(f'<rect x="{i%192*10}" y="{(95-i//192)*10}" width="10" height="10" fill="#477453"/>')
    def point(p):return ((p[0]+12288)/12.8,(8192-p[1])/12.8)
    for edge in layout['land_connections']:
        pts=' '.join(f'{x:.1f},{y:.1f}' for x,y in map(point,edge['points']))
        svg.append(f'<polyline points="{pts}" fill="none" stroke="#f3c26e" stroke-width="5" stroke-dasharray="10 5"/>')
    for r in layout['routes']:
        # Each segment's stored BFS trace is reversed; points mark the required waypoints.
        for p in r['points']:
            x,y=point(p);svg.append(f'<circle cx="{x}" cy="{y}" r="5" fill="#c9f6ee"/>')
    for p in layout['placements']:
        x,y=point(p['center']);svg.append(f'<circle cx="{x}" cy="{y}" r="8" fill="#fff"/><text x="{x+14}" y="{y+6}" font-family="sans-serif" font-size="24" fill="white">{p["id"]}</text>')
    svg.append('</svg>')
    (extracted/'graph.svg').write_text(''.join(svg),encoding='utf-8')

pairs=[]
for a,b in itertools.combinations(sorted(masks),2):
    both=sum(x and y for x,y in zip(masks[a],masks[b]));either=sum(x or y for x,y in zip(masks[a],masks[b]))
    pairs.append({'seeds':[a,b],'land_iou':both/max(1,either),'under_080':both/max(1,either)<=.8})
result={'format':'wc3-recompose-comparison-v1','records':records,'pairs':pairs,'water_surface_z':-89.6,'mask_rule':'same vertex FinalZ >= tropical water surface; 192x96 lower-left corners','visual_acceptance':'separate explicit image review required'}
(out/'comparison.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'evaluated':len(records),'pair_count':len(pairs),'max_pair_iou':max(x['land_iou'] for x in pairs)},indent=2))

