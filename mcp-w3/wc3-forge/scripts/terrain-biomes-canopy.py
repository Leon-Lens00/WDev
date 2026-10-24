"""Measure cohort canopy proxies and gap components from actual Classic DOO bytes.

Diagnostic, not a visual approval or exact mesh measurement. No map writes.
"""
import argparse, collections, hashlib, json, math, struct, subprocess
from pathlib import Path

def read_doo(raw):
    magic, version, sub, count = struct.unpack_from('<4sIII', raw)
    assert magic == b'W3do' and version in (7, 8) and sub == 9
    result = {}; off = 16
    for _ in range(count):
        family, variation, x, y, z, angle, sx, sy, sz = struct.unpack_from('<4sI7f', raw, off)
        off += 36
        assert raw[off] < 32, 'Classic records only; skin field unsupported'
        off += 2
        if version == 8:
            _, sets = struct.unpack_from('<II', raw, off); off += 8
            for _ in range(sets):
                n, = struct.unpack_from('<I', raw, off); off += 4 + n * 8
        ident, = struct.unpack_from('<I', raw, off); off += 4
        result[ident] = dict(family=family.decode('ascii'), xy=(x,y), scale=sx)
    assert struct.unpack_from('<II', raw, off) == (0,0) and off+8 == len(raw)
    return result

def measure(trees, box):
    nx=round((box['max'][0]-box['min'][0])/64); ny=round((box['max'][1]-box['min'][1])/64)
    empty=set()
    for y in range(ny):
        for x in range(nx):
            point=(box['min'][0]+(x+.5)*64,box['min'][1]+(y+.5)*64)
            if not any(math.dist(point,t['xy']) <= 144*t['scale'] for t in trees): empty.add((x,y))
    coverage=1-len(empty)/(nx*ny); components=[]
    while empty:
        seed=min(empty); empty.remove(seed); todo=[seed]; group=[]
        while todo:
            x,y=todo.pop();group.append((x,y))
            for p in [(x-1,y),(x+1,y),(x,y-1),(x,y+1)]:
                if p in empty: empty.remove(p);todo.append(p)
        components.append(dict(area=len(group)*4096,touches_window_edge=any(x in (0,nx-1) or y in (0,ny-1) for x,y in group)))
    return dict(trees=len(trees),canopy_union_fraction=coverage,uncovered_components=components)

def rotate(p,q):
    x,y=p
    return [(x,y),(-y,x),(-x,-y),(y,-x)][q]

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('artifacts',type=Path);ap.add_argument('--cli',required=True,type=Path);a=ap.parse_args()
    b=a.artifacts.resolve();exe=a.cli.resolve();out=b/'runs/canopy-final-v1';out.mkdir(exist_ok=True)
    read=lambda p:json.loads(p.read_text(encoding='utf-8-sig'))
    source={v['id']:dict(xy=v['xy'],scale=v['placement']['Scale'][0]) for v in read(b/'discovery/ashenvale/inventory.json')}
    cohorts={v['id']:v for v in read(b/'libraries/ashenvale-final.json')['forest_cohorts']}
    source_stats={k:measure([source[i] for i in c['source_ids']],c['bounds']) for k,c in cohorts.items()}
    outputs=[]
    for rp in sorted((b/'runs/cohorts-final-v3').glob('*/*/run.json')):
        run=read(rp);rawpath=out/f'{rp.parent.parent.name}-{run["seed"]}.doo'
        recipe=read(Path(run['recipe']));profile=read(Path(recipe['profile']['path']))
        subprocess.run([str(exe),'resource','-install',profile['install'],'-map',run['map'],'-resource','war3map.doo','-out',str(rawpath)],check=True,capture_output=True)
        placed=read_doo(rawpath.read_bytes());groups=collections.defaultdict(list)
        for p in run['placements']:
            if p['role']=='forest':groups[p['instance']].append(p)
        rows=[]
        for instance, members in sorted(groups.items()):
            cohort=cohorts[instance.rsplit('-',1)[0]]
            p0=members[0];src0=source[p0['source_id']]['xy'];dst0=placed[p0['creation_id']]['xy']
            transforms=[]
            for q in range(4):
                r0=rotate(src0,q);shift=[dst0[i]-r0[i] for i in range(2)]
                if all(math.dist([rotate(source[p['source_id']]['xy'],q)[i]+shift[i] for i in range(2)],placed[p['creation_id']]['xy'])<.001 for p in members):transforms.append((q,shift))
            assert transforms,instance
            q,shift=transforms[0]
            # Map back to source coordinates: exact same window/grid as calibration.
            trees=[]
            for p in members:
                d=placed[p['creation_id']];xy=rotate([d['xy'][i]-shift[i] for i in range(2)],(-q)%4)
                assert abs(d['scale']-source[p['source_id']]['scale'])<1e-6
                trees.append(dict(xy=xy,scale=d['scale']))
            metrics=measure(trees,cohort['bounds']);base=source_stats[cohort['id']]
            rows.append(dict(instance=instance,cohort=cohort['id'],retained=len(members),source_count=len(cohort['source_ids']),clipped=len(members)<len(cohort['source_ids']),metrics=metrics,source_coverage=base['canopy_union_fraction'],coverage_excess=max(0,metrics['canopy_union_fraction']-base['canopy_union_fraction'])))
        outputs.append(dict(recipe=rp.parent.parent.name,seed=run['seed'],map_sha256=hashlib.sha256(Path(run['map']).read_bytes()).hexdigest(),forest=run['forest'],groups=rows))
    report=dict(method='64-unit cells; circular proxy radius144 times source ScaleX; four-connected uncovered cells; each cohort measured in original source window after inverse quarter rotation',mesh_exact=False,source=source_stats,cases=outputs,interpretation='Clipped groups can have lower coverage; the recipe intentionally separates habitats and reserves routes. Original relative positions and scales are preserved. These measurements do not certify exact canopy shape or visual quality.')
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
    print('Measured',sum(len(c['groups']) for c in outputs),'groups in',len(outputs),'maps')

if __name__=='__main__':main()
