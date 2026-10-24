"""Package the accepted Tropical S0-S9 delivery; never creates review approval.

Usage: python scripts/terrain-scene-package.py ARTIFACT_ROOT
Requires the existing workspace, reviewed finalist files and passing test records.
"""
import datetime
import hashlib
import html
import json
import pathlib
import shutil
import sys

r = pathlib.Path(sys.argv[1]).resolve()
repo = pathlib.Path(__file__).resolve().parents[1]
workspace = repo.parent
release = r / 'release'
finals = {'A': 42700, 'B': 43702, 'C': 44700}


def read(p):
    return json.loads(p.read_text(encoding='utf-8-sig'))


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False), encoding='utf-8')


def copy(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def require_review(p):
    d = read(p)
    assert d['accepted'] is True, p
    for name, expected in d['reviewed_inputs'].items():
        assert sha(pathlib.Path(name)) == expected, (p, name, 'review stale')


require_review(r / 'discovery/accepted-review.json')
require_review(r / 'library/accepted-review.json')
assert read(r / 'experiments/check-results.json')['test'] == 0
assert read(r / 'experiments/check-results.json')['vet'] == 0
assert read(r / 'experiments/pjass.json')['passed']
assert read(r / 'reproduction/forest-seed-independence.json')['accepted']
assert read(r / 'baseline/session-after.json')['restored']
assert read(r / 'experiments/forest-ab.json')['criteria_frozen_before_batch']

preserved = []
for item in read(r / 'baseline/preservation-before.json'):
    p = (workspace / item['path']).resolve()
    actual = sha(p)
    assert actual == item['sha256'], p
    preserved.append(dict(path=str(p), sha256=actual, unchanged=True))
write(r / 'baseline/preservation-after.json', preserved)

batch = read(r / 'experiments/batch-acceptance.json')
maps = []
for brief, seed in finals.items():
    run = r / f'runs/{brief}/batch-v1/{seed}'
    require_review(run / 'visual-review.json')
    require_review(r / f'editor/{brief}-review.json')
    case = next(c for c in batch['cases'] if c['seed'] == seed)
    assert all(c['passed'] for c in case['cohorts'])
    source = run / f'Tropical-Scene-{seed}.w3x'
    reproduced = r / f'reproduction/final-{brief}/Tropical-Scene-{seed}.w3x'
    assert sha(source) == sha(reproduced)
    dest = release / f'Tropical-{brief}-{seed}.w3x'
    copy(source, dest)
    for p in run.iterdir():
        if p.is_file() and p.suffix == '.json':
            copy(p, release / 'finals' / brief / p.name)
    shutil.copytree(run / 'visual', release / 'finals' / brief / 'visual', dirs_exist_ok=True)
    shutil.copytree(run / 'engine', release / 'finals' / brief / 'engine', dirs_exist_ok=True)
    maps.append(dict(brief=brief, seed=seed, file=dest.name, sha256=sha(dest),
                     status='Validated', source_iou=case['source_iou'],
                     forest=case['forest'], objects=read(run/'report.json')['added_objects']))

native = [('A', 'Tropical-Scene-final-check.w3x', 'final-check-audit.json', 'final-check-native.jpg'),
          ('B', 'Tropical-B-43702-native.w3x', 'B-audit.json', 'B-native.jpg'),
          ('C', 'Tropical-C-44700-native.w3x', 'C-audit.json', 'C-native.jpg')]
for b, filename, audit, screenshot in native:
    assert not read(r / 'editor' / audit)['failures']
    copy(r / 'editor' / filename, release / 'editor' / f'Tropical-{b}-native.w3x')
    for name in [audit, screenshot, f'{b}-review.json']:
        copy(r / 'editor' / name, release / 'editor' / name)
    copy(r / f'editor/extracted-{b}/war3map.j', release / 'editor' / f'{b}-native.j')

for folder in ['discovery', 'library', 'briefs']:
    for p in (r / folder).rglob('*'):
        if p.is_file() and 'source-data' not in p.relative_to(r/folder).parts:
            copy(p, release / p.relative_to(r))
for p in (r / 'experiments').iterdir():
    if p.is_file() and p.suffix in ['.json', '.log']:
        copy(p, release / 'evidence' / p.name)
for folder in ['compact-final', 'control-final']:
    shutil.copytree(r / 'experiments' / folder / 'visual', release / 'comparison' / folder, dirs_exist_ok=True)
for folder in ['source-comparison', 'r8-comparison']:
    shutil.copytree(r / 'experiments' / folder, release / 'comparison' / folder, dirs_exist_ok=True)
for p in (r / 'baseline').iterdir():
    if p.is_file(): copy(p, release / 'baseline' / p.name)
for p in (r / 'reproduction').iterdir():
    if p.is_file(): copy(p, release / 'reproduction' / p.name)
for p in (repo / 'examples/terrain').glob('scene*.schema.json'):
    copy(p, release / 'schemas' / p.name)

# Capture relevant code with a delta against the pre-task snapshot. The repository
# had existing uncommitted work; this is not a claim that the whole diff is new.
before = {v['path']:v['sha256'] for v in read(r / 'baseline/code-before.json')}
sources = set((repo / 'internal/terrainproc').glob('*.go'))
sources.update((repo/'scripts').glob('terrain-scene-*.py'))
sources.update([repo/'scripts/test_terrain_scene_run.py', repo/'cmd/terrain-gen/main.go',
                repo/'mcp/scripts/terrain-preview.mjs', repo/'mcp/scripts/terrain-restore-session.mjs'])
delta = []
for p in sorted(sources):
    rel = p.relative_to(repo).as_posix()
    copy(p, release / 'code' / rel)
    delta.append(dict(path=rel, before=before.get(rel), after=sha(p),
                      changed=before.get(rel) != sha(p)))
write(release/'code/stage-files.json', delta)
tool_paths = [repo/'build/bin/terrain-gen-scene.exe', repo/'build/bin/wc3-forge-camera.exe',
              repo/'generators/markovjunior-host/bin/Release/net10.0/Host.dll',
              repo/'.tools/dotnet/dotnet.exe', pathlib.Path('C:/Program Files/Go/bin/go.exe'),
              pathlib.Path(sys.executable), pathlib.Path(shutil.which('node')),
              pathlib.Path('C:/Users/Leon/Documents/W3/build/HiveWE-reference/data/tools/pjass.exe')]
write(release/'tools.json', [dict(path=str(p), sha256=sha(p)) for p in tool_paths])
write(release/'maps.json', maps)

gallery = []
for b, seed in finals.items():
    gallery.append(f'<section><h2>{b} · {seed}</h2><a href="Tropical-{b}-{seed}.w3x">Mapa editable</a> · <a href="editor/Tropical-{b}-native.w3x">Copia guardada en World Editor</a><div class="gallery">')
    for p in sorted((release/'finals'/b/'visual').glob('*.png')):
        link = p.relative_to(release).as_posix()
        gallery.append(f'<figure><a href="{link}"><img loading="lazy" src="{link}"></a><figcaption>{html.escape(p.stem)}</figcaption></figure>')
    gallery.append('</div></section>')
(release/'index.html').write_text('''<!doctype html><meta charset="utf-8"><title>Escenas Tropical S0–S9</title>
<style>body{font:16px system-ui;background:#12251e;color:#e5eede;margin:32px}a{color:#a5e4c5}p{max-width:900px}.gallery{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}figure{margin:0}img{width:100%}section{margin-top:32px}@media(max-width:900px){.gallery{grid-template-columns:1fr}}</style>
<h1>Generador de escenas Tropical</h1><p>Validated · Tres mapas editables, repetibles y revisados. A: completo. B: isla dominante con dos plataformas. C: dos cascadas sin templo, plataforma ni puente. Sombras y juego excluidos.</p>
<p><a href="README.md">Guía de entrega</a> · <a href="discovery/index.html">Atlas de 32 sectores y complementos</a> · <a href="evidence/batch-review.json">Decisiones de las doce semillas</a> · <a href="evidence/forest-ab.json">Comparativa forestal</a> · <a href="manifest.json">Hashes</a></p>'''+''.join(gallery),encoding='utf-8')

# README is authored separately; packaging never fabricates visual observations.
assert (release/'README.md').is_file(), 'Write the delivery guide before packaging'
files = {p.relative_to(release).as_posix():sha(p) for p in sorted(release.rglob('*'))
         if p.is_file() and p != release/'manifest.json'}
write(release/'manifest.json', dict(format='wc3-scene-release-v1', status='Validated',
    generated_at=datetime.datetime.now(datetime.timezone.utc).isoformat(), maps=maps,
    files=files, source_preserved=True, runtime_tested=False, shadows='omit; SHD complete and zero',
    dependencies='This local delivery references the existing ZXDev workspace and Classic installation.'))
print(json.dumps(dict(files=len(files), maps=maps), ensure_ascii=False))
