"""Measure donor W3E grids exported by cmd/landform-reference; no MPQ writes.

Produces candidate windows and numeric cross sections, never claims visual review.
Only Python's standard library is required. SVGs are measured plots, not renders.
"""
from pathlib import Path
import argparse, collections, hashlib, html, json, math, statistics

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False)+"\n", encoding="utf-8")

def quantiles(values):
    s=sorted(values)
    return {str(p):round(s[round((len(s)-1)*p/100)],4) for p in (0,10,25,50,75,90,100)} if s else {}

def measure(root, biome, original):
    folder=root/'source-atlas'/biome
    gridpath=folder/'grid.json'; g=json.loads(gridpath.read_text())
    W,H=g['width'],g['height']; z=g['ground_z']; w=g['water_z']; flags=g['flags']; origin=g['origin']
    wet=[bool(f&4) and a<b for a,b,f in zip(z,w,flags)]
    def idx(x,y): return y*W+x
    def pos(x,y): return [origin[0]+x*128,origin[1]+y*128]
    def ids(x,y,r): return [idx(a,b) for b in range(y-r,y+r+1) for a in range(x-r,x+r+1)]
    rigid_boxes=[('ruins-west',[-3200,896],[-1664,2688]),('ruins-center',[768,-1536],[2240,0])] if biome=='ashenvale' else [(c['id'],c['source']['min'],c['source']['max']) for c in json.loads((root.parent/'integrated-landscapes-v1/staged/source-atlas/source-library.json').read_text())['compositions']]
    def architecture(x,y):
        p=pos(x,y)
        # Historical reviewed Ashenvale architectural supports; avoid treating them as natural slopes.
        return any(lo[0]-512<=p[0]<=hi[0]+512 and lo[1]-512<=p[1]<=hi[1]+512 for _,lo,hi in rigid_boxes)
    candidates=collections.defaultdict(list)
    all_grad=[]
    for y in range(9,H-9):
        for x in range(9,W-9):
            i=idx(x,y)
            if architecture(x,y): continue
            gx=(z[idx(x+1,y)]-z[idx(x-1,y)])/2
            gy=(z[idx(x,y+1)]-z[idx(x,y-1)])/2
            grad=math.hypot(gx,gy)
            local=ids(x,y,4); heights=[z[j] for j in local]
            minimum,maximum=min(heights),max(heights); spread=maximum-minimum
            wetfrac=sum(wet[j] for j in local)/len(local)
            rel=z[i]-w[i]
            if not wet[i]: all_grad.append(grad)
            data=(x,y,grad,minimum,maximum,wetfrac)
            crossing=any(wet[j] for j in ids(x,y,1)) and not all(wet[j] for j in ids(x,y,1))
            if crossing and 5<=grad<=40 and 50<=spread<=260 and .15<=wetfrac<=.85:
                candidates['shallow-shore'].append((abs(grad-20)+abs(rel)*.2, data))
            if .05<wetfrac<.7 and 65<=grad<=160 and abs(rel)<200 and spread>180:
                candidates['steep-bank'].append((abs(grad-90)+abs(rel)*.15, data))
            if wetfrac==0 and 25<=grad<=80 and 180<=spread<=500 and rel>90:
                candidates['slope'].append((abs(grad-42)+abs(spread-280)*.03, data))
            ring=[z[idx(x+dx,y+dy)] for dx,dy in ((-4,0),(4,0),(0,-4),(0,4))]
            if min(ring)>z[i]+30 and spread>=70 and 0<=wetfrac<.95:
                candidates['depression'].append((-min(ring)+z[i]+abs(wetfrac-.3)*10, data))
            if wetfrac==0 and spread<=35 and grad<8 and rel>30:
                candidates['flat'].append((spread+grad,data))
    windows=[]; contexts=[]; cameras=[]
    for context in ('shallow-shore','steep-bank','slope','depression','flat'):
        selected=[]
        for score,d in sorted(candidates[context],key=lambda q:(q[0],q[1][1],q[1][0])):
            if all(math.hypot(d[0]-p[0],d[1]-p[1])>=12 for p in selected):
                selected.append(d)
                if len(selected)==2: break
        contexts.append({'context':context,'candidate_centers':len(candidates[context]),'selected_windows':len(selected),'status':'available-candidate' if selected else 'not-observed-under-detector','detector_limitation':'Morphometric candidate only; architectural/visual classification requires the linked Forge views.'})
        # The tropical donor has one compact architectural flat, not a broad
        # natural flat. Keep the exception explicit instead of learning it as nature.
        if context=='flat' and not selected and biome=='tropical':
            x,y=161,28; local=ids(x,y,2); heights=[z[j] for j in local]
            selected=[(x,y,0,min(heights),max(heights),0)]
            contexts[-1]['selected_windows']=1
            contexts[-1]['status']='architectural-exception-only'
            contexts[-1]['detector_limitation']='No natural 1024-wide flat under this detector. Compact 512-wide temple support is recorded separately and cannot define natural terrain.'
        for n,(x,y,grad,mn,mx,wf) in enumerate(selected,1):
            name=f'{context}-{n}'; local=ids(x,y,4); p=pos(x,y)
            radius=2 if context=='flat' and biome=='tropical' else 4
            local=ids(x,y,radius)
            sections=[]
            for axis,dx,dy in [('west-east',1,0),('south-north',0,1)]:
                points=[]
                for step in range(-radius,radius+1):
                    xx,yy=x+dx*step,y+dy*step; j=idx(xx,yy)
                    points.append({'distance':step*128,'position':pos(xx,yy),'ground_z':z[j],'water_z':w[j], 'relative_to_water':round(z[j]-w[j],4),'water_flag':bool(flags[j]&4),'physically_submerged':wet[j],'cliff_layer':g['cliff_layers'][j],'tile':g['tiles'][j]})
                dz=[abs(b['ground_z']-a['ground_z']) for a,b in zip(points,points[1:])]
                sections.append({'axis':axis,'sample_spacing':128,'length':radius*256,'max_delta_per_128':max(dz),'median_delta_per_128':statistics.median(dz),'samples':points})
            ds=[w[j]-z[j] for j in local if wet[j]]
            lo,hi=pos(x-radius,y-radius),pos(x+radius,y+radius)
            item={'id':name,'context':context,'review_status':'candidate-unreviewed','reference_kind':'architectural-support-exception' if radius==2 else 'natural-candidate','vertex_center':[x,y],'world_center':p,'window_world':[lo,hi],'window_vertices':[[x-radius,y-radius],[x+radius,y+radius]],'window_size':radius*256,'measurement':{'ground_min':mn,'ground_max':mx,'height_range':mx-mn,'gradient_per_128':round(grad,4),'gradient_angle_degrees':round(math.degrees(math.atan(grad/128)),3),'submerged_fraction':round(wf,4),'water_depth_quantiles':quantiles(ds),'materials':dict(collections.Counter(g['tiles'][j] for j in local))},'sections':sections,'proposed_scale_interval':{'horizontal':[.75,1.5],'vertical':[.75,1.25]},'scale_status':'design-proposal-not-measured-or-visually-approved'}
            windows.append(item)
            cameras.append({'name':name,'bounds':{'min':lo+[min(mn,w[0])-64],'max':hi+[max(mx,w[0])+220]},'projection':'orthographic','yaw':.35,'pitch':.92})
            plot_section(folder/(name+'.svg'),item,w[0])
    source=(original.resolve())
    if sha(source)!=g['source_sha256']: raise ValueError(f'source mismatch {biome}')
    relevant=[z[i]-w[i] for i in range(len(z)) if not wet[i]]
    proposed={
       'shallow-shore':{'transition_width_world':[384,768],'above_water_height_world':[16,96]},
       'steep-bank':{'transition_width_world':[256,512],'above_water_height_world':[96,220]},
       'slope':{'rise_world':[120,280],'run_world':[768,1536]},
       'depression':{'depth_relative_to_surround_world':[64,180],'span_world':[768,1792]},
       'flat':{'max_delta_per_128':16,'minimum_span_world':384},
    }
    profile={'format':'wc3-landform-profile-v1','id':biome+'-landform-profile-v1','review_status':'numeric-candidates-pending-visual-review','donor':{'path':str(source),'sha256':sha(source),'w3e_path':str((folder/'war3map.w3e').resolve()),'w3e_sha256':g['w3e_sha256']},'material_reference':{'path':str((root.parent/'reusable-biomes-v1/profiles'/biome/'material-profile-v1.json').resolve())},'geometry':{'width':W,'height':H,'origin':origin,'step':128},'water':{'absolute_source_levels':sorted(set(w)),'slk_offset':g['water_slk_offset'],'source_resource':'TerrainArt\\Water.slk','resource_sha256':'8c5b8580da80d00380db8c144ae8eb64730a07975de99eb11fa3222639bdf699','note':'WaterZ + SLK offset; submerged requires water flag AND ground below physical water surface.'},'measurement_method':{'ground':'W3E FinalZ = (raw - 8192)/4 + (LayerHeight-2)*128','section_spacing':128,'window_vertices':9,'selection':'deterministic morphometric scoring; two centers at least 1536 apart per observed context','thresholds':'See scripts/terrain-landform-reference.py; candidate != accepted artistic reference.','source_map_not_modified':True},'measured_ranges':{'dry_vertex_gradient_per_128':quantiles(all_grad),'dry_vertex_relative_height':quantiles(relevant),'submerged_depth':quantiles([w[i]-z[i] for i in range(len(z)) if wet[i]]),'all_ground':quantiles(z),'cliff_layer_distribution':dict(collections.Counter(g['cliff_layers']))},'contexts':contexts,'windows':windows,'proposed_ranges':proposed,'accepted_parameters':{},'limitations':['No automatic semantic claim that a depression is a closed lake.','Architectural cores must retain their separate source geometry.','Proposed ranges are restrained design choices informed by measurements, not learned numerical distributions.','Candidate SVGs are data plots; visual acceptance requires actual Forge source captures.']}
    profile['material_reference']['sha256']=sha(Path(profile['material_reference']['path']))
    out=root/'profiles'/(biome+'-landform-profile-v1.json'); save(out,profile)
    save(folder/'views.json',cameras)
    save(folder/'candidate-index.json',{'format':'wc3-landform-source-atlas-v1','profile_path':str(out.resolve()),'profile_sha256':sha(out),'review_status':'pending','contexts':contexts,'views_file':'views.json'})
    plot_map(folder/'height-atlas.svg',g,windows)
    print(biome,sha(out),json.dumps(contexts))

def plot_section(path,item,water):
    samples=[p for s in item['sections'] for p in s['samples']]
    minimum=min([p['ground_z'] for p in samples]+[water])-30; maximum=max([p['ground_z'] for p in samples]+[water])+30
    scale=lambda z:round(280-(z-minimum)/(maximum-minimum)*220,2)
    color=['#c9902f','#2976bf']
    svg=['<svg xmlns="http://www.w3.org/2000/svg" width="780" height="360" viewBox="0 0 780 360">','<rect width="780" height="360" fill="#f9fafb"/>',f'<text x="32" y="25" font-family="sans-serif" font-size="17">{html.escape(item["id"])}: measured W3E cross sections (not a render)</text>',f'<path d="M50 {scale(water)} H740" stroke="#16a5cf" stroke-dasharray="5,4"/>']
    for i,s in enumerate(item['sections']):
        length=s['length']
        points=' '.join(f'{50+(p["distance"]+length/2)/length*690:.2f},{scale(p["ground_z"])}' for p in s['samples'])
        svg += [f'<polyline points="{points}" fill="none" stroke="{color[i]}" stroke-width="3"/>',f'<text x="{50+i*340}" y="325" fill="{color[i]}" font-family="sans-serif">{s["axis"]}; max step {s["max_delta_per_128"]}</text>']
    svg += [f'<text x="32" y="350" font-family="sans-serif" font-size="12">X: {-length/2:.0f} to {length/2:.0f} WC3 units; ground Z: {minimum:.1f}..{maximum:.1f}; water: {water:.2f}</text>','</svg>']
    path.write_text('\n'.join(svg),encoding='utf-8')

def plot_map(path,g,windows):
    W,H=g['width'],g['height']; z=g['ground_z']; minimum,maximum=min(z),max(z); s=5
    svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{W*s+340}" height="{H*s+50}">','<rect width="100%" height="100%" fill="#f9fafb"/>']
    for y in range(H):
        for x in range(W):
            i=y*W+x; t=(z[i]-minimum)/(maximum-minimum)
            color='#39697e' if (g['flags'][i]&4) and z[i]<g['water_z'][i] else f'rgb({round(80+t*160)},{round(96+t*142)},{round(50+t*166)})'
            svg.append(f'<rect x="{x*s}" y="{(H-y-1)*s}" width="5" height="5" fill="{color}"/>')
    for n,a in enumerate(windows,1):
        x,y=a['vertex_center']; radius=a['window_size']/256
        svg += [f'<rect x="{(x-radius)*s}" y="{(H-y-radius-1)*s}" width="{radius*10}" height="{radius*10}" stroke="#ff4050" fill="none" stroke-width="2"/>',f'<text x="{x*s}" y="{(H-y)*s}" fill="white" font-family="sans-serif" font-weight="bold">{n}</text>',f'<text x="{W*s+10}" y="{n*28}" font-family="sans-serif" font-size="14">{n}: {html.escape(a["id"])}</text>']
    svg += [f'<text x="10" y="{H*s+30}" font-family="sans-serif">W3E measurements, not terrain render; ground Z {minimum}..{maximum}</text>','</svg>']
    path.write_text('\n'.join(svg),encoding='utf-8')

if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__); ap.add_argument('--root',type=Path,required=True); a=ap.parse_args()
    measure(a.root,'ashenvale',a.root.parent/'reusable-biomes-v1/donors/forestwalk-original.w3m')
    measure(a.root,'tropical',a.root.parent/'tropical-v1/input/tropical-original.w3x')
