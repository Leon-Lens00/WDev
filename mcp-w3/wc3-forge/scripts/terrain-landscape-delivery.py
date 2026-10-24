"""Verify/stage P artifacts. Final packaging requires actual reviewed native saves.

Commands: check, stage, native-gate, package. Never creates a visual approval.
"""
import hashlib, html, json, shutil, subprocess, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]; REPO=ROOT/'wc3-forge'
P=ROOT/'artifacts/warcraft-terrain/integrated-landscapes-v1'
S=ROOT/'artifacts/warcraft-terrain/scene-generator-v1'
CASES=[('D',52700),('E',53700),('F',54700)]
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,j):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(j,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
def copy(a,b):b.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(a,b)
def tree(a,b):shutil.copytree(a,b,dirs_exist_ok=True)
def verify_review(p):
    j=read(p); assert j.get('accepted',j.get('preview_accepted')) is True,p
    for name,h in j.get('reviewed_inputs',{}).items():assert sha(Path(name))==h,(p,name)
    return j

def check():
    frozen=read(P/'baseline/freeze-v2.json')['hashes']
    for name,h in frozen.items():assert sha(Path(name))==h,('frozen input changed',name)
    original=read(P/'baseline/preservation-before.json');preserved={}
    for name,value in original.items():
        path=ROOT/name; h=sha(path);assert h==value['sha256'],('preserved file changed',name)
        preserved[name]={'sha256':h,'unchanged':True}
    write(P/'baseline/preservation-after-v2.json',{'passed':True,'count':len(preserved),'files':preserved})
    checks=read(P/'experiments/check-results-06.json');assert checks['test_exit']==0 and checks['vet_exit']==0
    for name in ['reproduction/determinism-v2.json','reproduction/pjass-v2/generated.json','reproduction/seed-isolation-v2/audit.json','experiments/landform-finals-v2/isolation.json']:
        assert read(P/name)['accepted'],name
    for name in ['experiments/habitats-04/visual-review.json','experiments/materials-03/visual-review.json']:
        verify_review(P/name)
    selections=read(P/'runs/selection-v2.json');assert len(selections['batch'])==12
    for c in selections['batch']:
        run=P/f"runs/{c['brief']}/batch-v2/{c['seed']}"
        assert read(run/'validation.json')['passed']
        assert sha(run/'overview/top.png')==c['overview_sha256']
        assert sha(run/'validation.json')==c['validation_sha256']
        assert sha(run/f"Tropical-{c['brief']}-{c['seed']}.w3x")==c['map_sha256']
    for b,s in CASES:
        run=P/f'runs/{b}/batch-v2/{s}';r=verify_review(run/'visual-review.json')
        assert r['map_sha256']==sha(run/f'Tropical-{b}-{s}.w3x')
        assert selections['selected'][b]['visual_review_sha256']==sha(run/'visual-review.json')
        for name,h in r['inputs'].items():assert sha(ROOT/name)==h,name
        for name,v in r['images'].items():
            assert v['examined'] and sha(run/name)==v['sha256']
            assert sha((run/name).with_suffix('.json'))==v['metadata_sha256']
    # These reports were measured from the same current files, not old batches.
    for name,h in read(P/'reproduction/seed-isolation-v2/audit.json')['inputs'].items():assert sha(P/name)==h,name
    pair=read(P/'experiments/landform-finals-v2/visual-review.json')
    assert pair['preview_accepted'] and pair['isolation_sha256']==sha(P/'experiments/landform-finals-v2/isolation.json')
    for case in pair['cases']:
        for v in case['views']:
            for side in ['bare','decorated']:assert sha(P/v[side+'_png'])==v[side+'_sha256']
            for name,h in v['metadata'].items():assert sha(P/name)==h
    # Preserve attribution of prior dirty work; compare against start of P.
    before={Path(name).as_posix():v for name,v in read(P/'baseline/code-before.json').items()}; paths={REPO/name for name in before}
    paths.update(Path(name) for name in frozen if Path(name).is_relative_to(REPO))
    for folder,pattern in [('scripts','terrain-landscape*'),('internal/terrainproc','landscape*.go'),('examples/terrain','*landscape*'),('cmd/terrain-landscape','*.go')]:
        paths.update((REPO/folder).glob(pattern))
    after={q.relative_to(REPO).as_posix():sha(q) for q in sorted(paths) if q.is_file()}
    changes=[]
    for name,h in after.items():
        old=before.get(name);oldhash=old['sha256'] if isinstance(old,dict) else old
        if h!=oldhash:changes.append({'path':name,'before_sha256':oldhash,'after_sha256':h,'change':'modified' if old else 'not-in-baseline'})
    write(P/'baseline/code-after-v2.json',{'files':after,'changes_since_P_start':changes,'note':'Previous dirty files are the baseline, not upstream HEAD. Files absent from that code snapshot, especially binaries/runtimes, are not proof that P created them.'})
    write(P/'reproduction/pre-native-checks.json',{'passed':True,'status':'Compiled','preserved_files':len(preserved),'frozen_inputs':len(frozen),'reviewed_finalist_images':139,'native_final_saves':False,'tests_sha256':sha(P/'experiments/check-results-06.json'),'inputs':{name:sha(P/name) for name in ['runs/selection-v2.json','reproduction/determinism-v2.json','reproduction/seed-isolation-v2/audit.json','reproduction/pjass-v2/generated.json','experiments/habitats-04/visual-review.json','experiments/materials-03/visual-review.json','experiments/landform-finals-v2/visual-review.json']}})
    print('Current evidence, freeze and preservation verified; native saves not included.')

def native_gate(require_audits=False):
    missing=[]
    for b,s in CASES:
        folder=P/f'editor/{b}'; native=folder/f'Tropical-{b}-native.w3x'; review=folder/'visual-review.json'
        for q in [native,review]:
            if not q.is_file():missing.append(str(q.relative_to(P)))
        if not native.is_file() or not review.is_file():continue
        j=verify_review(review)
        assert j.get('native_editor') is True and j['saved_map_sha256']==sha(native)
        assert j['generated_map_sha256']==sha(P/f'runs/{b}/batch-v2/{s}/Tropical-{b}-{s}.w3x')
        assert j.get('reviewed_inputs'), 'native review must bind real screenshots and maps'
        assert any(Path(n).suffix.lower() in ('.png','.jpg') for n in j['reviewed_inputs'])
        if require_audits:
            a=read(folder/'audit.json');assert a['passed'] and not a['failures']
            assert a['saved_sha256']==sha(native) and a['source_sha256']==j['generated_map_sha256']
    report={'passed':not missing,'missing':missing,'no_synthetic_saves':True,'reason':'Windows control runtime fails before JS execution: failed to write kernel assets (os error 3). World Editor restored by Leon; final native saves have not occurred.' if missing else 'Actual native records present.'}
    write(P/'editor/native-gate.json',report)
    if missing:raise RuntimeError('Native World Editor stage pending: '+', '.join(missing))
    if require_audits:assert read(P/'reproduction/pjass-v2/native.json')['accepted']

def package(final=False):
    check()
    if final:
        native_gate(True)
        session=read(P/'baseline/session-after-v2.json')
        assert session['world_editor_restored'] and session['forge_closed'],'session restoration pending'
    out=P/('release' if final else 'staged');out.mkdir(exist_ok=True)
    status='Validated' if final else 'Compiled'
    for folder in ['briefs','contracts','library','baseline']:tree(P/folder,out/folder)
    for b,s in CASES:
        run=P/f'runs/{b}/batch-v2/{s}';copy(run/f'Tropical-{b}-{s}.w3x',out/f'Tropical-{b}-{s}.w3x')
        tree(run,out/f'finals/{b}')
        if final:tree(P/f'editor/{b}',out/f'editor/{b}')
    for b,start in CASES:
        for s in range(start,start+4):
            run=P/f'runs/{b}/batch-v2/{s}'
            for name in ['validation.json','report.json','spec.json','overview/top.png','overview/top.json']:copy(run/name,out/f'batch/{b}/{s}/{name}')
    for name in ['selection-v2.json','p8-rejection-v1.json']:copy(P/'runs'/name,out/'evidence'/name)
    for folder in ['habitats-04','materials-03','landform-finals-v2']:
        tree(P/'experiments'/folder,out/'experiments'/folder)
    for q in (P/'experiments').glob('*'):
        if q.is_file() and q.suffix in ('.log','.json') and any(t in q.name for t in ['test','check','vet','frontend','wails','mcp']):copy(q,out/'tests'/q.name)
    for folder in ['pjass-v2','seed-isolation-v2']:tree(P/'reproduction'/folder,out/'reproduction'/folder)
    for name in ['determinism-v2.json','pre-native-checks.json','acceptance-pipeline-v2.json','acceptance-pipeline-v2.state.json']:copy(P/'reproduction'/name,out/'reproduction'/name)
    for q in (REPO/'scripts').glob('terrain-landscape*.py'):copy(q,out/'code/scripts'/q.name)
    copy(REPO/'scripts/terrain-scene-run.py',out/'code/scripts/terrain-scene-run.py')
    for q in (REPO/'internal/terrainproc').glob('landscape*.go'):copy(q,out/'code/internal/terrainproc'/q.name)
    for q in [REPO/'cmd/terrain-gen/main.go',REPO/'asset_cliff_alias_test.go',REPO/'asset_handler.go']:copy(q,out/'code'/q.relative_to(REPO))
    tree(S/'library',out/'library/source-S')
    tree(S/'release/discovery',out/'source-atlas')
    comparison=[]
    for old,(b,s) in zip('ABC',CASES):
        origin=S/f'release/finals/{old}/visual/top.png';copy(origin,out/f'comparison/S-{old}.png');copy(origin.with_suffix('.json'),out/f'comparison/S-{old}.json')
        ca=read(origin.with_suffix('.json'))['camera'];cb=read(P/f'runs/{b}/batch-v2/{s}/acceptance-views/top.json')['camera']
        assert all(ca[k]==cb[k] for k in ['x','y','z','yaw','pitch','ortho_height','projection'])
        comparison.append({'S':old,'P':b,'source_image_sha256':sha(origin),'same_scale_and_angle':True,'note':'Orthographic camera distance differs only for clipping. Different landscapes and renderer builds; use isolated habitats-04 for causal forest comparison.'})
    write(out/'comparison/context.json',comparison)
    for name in ['PAISAJES-INTEGRADOS.md','STATUS-PAISAJES-INTEGRADOS.md','INVESTIGACION-TERRAIN-MULTILINGUE.md','PLAN-PAISAJES-INTEGRADOS.md']:
        copy(ROOT/'docs/warcraft-terrain'/name,out/'docs'/name)
    guide=out/'docs/PAISAJES-INTEGRADOS.md'
    guide.write_text(guide.read_text(encoding='utf-8').replace('../../artifacts/warcraft-terrain/integrated-landscapes-v1/staged/','../'),encoding='utf-8')
    tools={n:sha(Path(n)) for n in read(P/'baseline/freeze-v2.json')['hashes']}
    write(out/'dependencies.json',{'workspace_required':str(ROOT),'installation':'C:/Users/Leon/Downloads/Warcraft III 1.27','frozen_inputs':tools,'note':'Reproduction uses the pinned local workspace/toolchain and source libraries. No asset download or installation change is required.'})
    cards=[]
    for b,s in CASES:
        r=out/f'finals/{b}';rv=read(r/'visual-review.json')
        gallery=''.join(f'<figure><a href="finals/{b}/{html.escape(n)}"><img loading="lazy" src="finals/{b}/{html.escape(n)}" alt="{html.escape(Path(n).stem)}"></a><figcaption>{html.escape(Path(n).stem)}</figcaption></figure>' for n in rv['images'])
        observations=''.join('<li>'+html.escape(t)+'</li>' for t in rv['observations'])
        cards.append(f'<section id="{b}"><h2>{b} · {s}</h2><p><a href="Tropical-{b}-{s}.w3x">Mapa W3X</a> · <a href="finals/{b}/visual-review.json">Revisión y hashes</a></p><img class="overview" src="finals/{b}/acceptance-views/top.png" alt="Vista aérea {b}"><details><summary>Observaciones y todas las vistas</summary><ul>{observations}</ul><div class="grid">{gallery}</div></details></section>')
    htmlpage='<!doctype html><html lang="es"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Paisajes tropicales · D/E/F</title><style>body{margin:0;background:#101b19;color:#e3ede5;font:17px/1.55 system-ui}main{max-width:1250px;margin:auto;padding:35px}h1,h2{color:#addec2}a{color:#8fd2ee}nav{display:flex;gap:25px}section{margin:45px 0;border-top:1px solid #496258;padding-top:20px}.overview{width:100%}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:12px}figure{margin:0}img{max-width:100%}summary{cursor:pointer;padding:15px;background:#243d34}li{margin:10px 0}.state{padding:14px;border:1px solid #c8aa66}</style><main><h1>Paisajes tropicales integrados</h1><p class="state">'+status+(' · Tres guardados nativos auditados.' if final else ' · Candidatos reproducibles. Pendientes los tres guardados finales en World Editor; no son una entrega Validated.')+'</p><nav><a href="#D">Valle D</a><a href="#E">Santuario E</a><a href="#F">Dos cascadas F</a><a href="docs/PAISAJES-INTEGRADOS.md">Guía</a></nav>'+''.join(cards)+'<section><h2>Comparación con S</h2><p>Mismo ángulo y escala ortográfica. La prueba aislada de vegetación está en <a href="experiments/habitats-04/comparison.json">habitats-04</a>.</p><div class="grid">'+''.join(f'<figure><img src="comparison/S-{b}.png" alt="Base S {b}"><figcaption>S {b}</figcaption></figure>' for b in 'ABC')+'</div><p><a href="experiments/landform-finals-v2/visual-review.json">Parejas sin/con decoración</a> · <a href="experiments/materials-03/visual-review.json">Contactos de materiales</a> · <a href="manifest.json">Manifiesto SHA256</a></p></section></main></html>'
    (out/'index.html').write_text(htmlpage,encoding='utf-8')
    (out/'README.md').write_text('# Paisajes integrados D/E/F\n\nEstado: **'+status+'**. Abre `index.html` para el atlas y `docs/PAISAJES-INTEGRADOS.md` para comandos y límites.\n\n'+('Los tres guardados nativos y seis pJASS están acreditados.\n' if final else 'Estos tres candidatos ya tienen reproducción exacta, revisión en Forge y tres pJASS generados. Faltan los guardados nativos D/E/F, sus revisiones/auditorías, tres pJASS nativos y restaurar la sesión del editor. La conexión de control Windows falló antes de ejecutar código; no se simularon guardados.\n')+'\nClassic 1.27b, 192 × 96, SHD a cero, sin pruebas dentro del juego. Conserva el workspace indicado en dependencies.json para reproducir.\n',encoding='utf-8')
    files={str(q.relative_to(out)):sha(q) for q in sorted(out.rglob('*')) if q.is_file() and q.name!='manifest.json'}
    write(out/'manifest.json',{'status':status,'native_complete':final,'maps':{b:{'file':f'Tropical-{b}-{s}.w3x','sha256':sha(out/f'Tropical-{b}-{s}.w3x')} for b,s in CASES},'files':files})
    assert all(sha(out/name)==h for name,h in files.items())
    print(out,'files',len(files),'status',status)

if __name__=='__main__':
    command=sys.argv[1]
    if command=='check':check()
    elif command=='native-gate':native_gate()
    elif command=='stage':package()
    elif command=='package':package(True)
    else:raise SystemExit('Expected check, stage, native-gate or package')
