"""Package existing, manually reviewed material results; never creates review approvals."""
from pathlib import Path
import hashlib
import html
import json
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[2]
R = ROOT / 'wc3-forge'
T = ROOT / 'artifacts/warcraft-terrain/contextual-materials-v1'
P = ROOT / 'artifacts/warcraft-terrain/integrated-landscapes-v1'
OUT = T / 'release'


def read(p):
    return json.loads(p.read_text(encoding='utf-8-sig'))


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def write(p, value):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')


def copy(src, relative):
    dest = OUT / relative
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dest)
    return dest


def tree(src, relative, suffixes=None):
    for f in sorted(src.rglob('*')):
        if f.is_file() and (suffixes is None or f.suffix.lower() in suffixes):
            copy(f, Path(relative) / f.relative_to(src))


def main():
    exact = read(T / 'reproduction/exact.json')
    for case in exact:
        b = case['brief']
        assert read(T / f'visual/{b}/visual-review.json')['accepted']
        assert read(T / f'editor/{b}/visual-review.json')['accepted']
        assert read(T / f'editor/{b}/' / ('audit.json' if b == 'F' else 'audit-v2.json'))['passed']
        assert case['repaint_exact'] and case['integrated_exact']
    assert read(T / 'baseline/preservation-after.json')['passed']
    assert read(T / 'reproduction/pjass-native.json')['accepted']
    cases = []
    for b, seed in [('D', 52700), ('E', 53700), ('F', 54700)]:
        generated = T / f'runs/{b}/{seed}/Tropical-{b}-{seed}-materials.w3x'
        native = T / f'editor/{b}/Tropical-{b}-{seed}-materials-editor.w3x'
        copy(generated, f'maps/generated/{generated.name}')
        copy(native, f'maps/editor/{native.name}')
        base = P / f'runs/{b}/batch-v2/{seed}'
        copy(base / f'Tropical-{b}-{seed}.w3x', f'inputs/{b}/Tropical-{b}-{seed}.w3x')
        copy(base / 'layout.json', f'inputs/{b}/layout.json')
        copy(base / 'placements-provenance.json', f'inputs/{b}/placements-provenance.json')
        for name in ['materials.json', 'validation.json', 'statistics.json', 'layout.json', 'placements-provenance.json']:
            copy(T / f'runs/{b}/{seed}/{name}', f'evidence/finals/{b}/{name}')
        tree(T / f'editor/{b}', f'evidence/editor/{b}', {'.json', '.jpg', '.log'})
        cases.append({'brief': b, 'seed': seed, 'generated_sha256': sha(generated), 'editor_sha256': sha(native)})
    copy(ROOT / 'artifacts/warcraft-terrain/tropical-v1/input/tropical-original.w3x', 'inputs/donor.w3x')
    tree(T / 'config', 'config')
    for name in ['profile-v3.json', 'criteria-frozen.json', 'source-statistics.json']:
        copy(T / 'profile' / name, 'profile/' + name)
    for f in R.glob('examples/terrain/material-*.schema.json'):
        copy(f, 'profile/' + f.name)
    for name in ['terrain-gen-materials.exe', 'terrain-gen-materials-audit-v2.exe']:
        copy(R / 'build/bin' / name, 'bin/' + name)
    copy(R / 'scripts/terrain-materials-reproduce-portable.py', 'reproduce.py')
    tree(T / 'visual', 'atlas/visual', {'.png', '.json'})
    for folder in ['visual-v3', 'bare-visual']:
        tree(T / 'source-atlas' / folder, 'atlas/source/' + folder, {'.png', '.json'})
    for name in ['visual-review.json', 'views.json', 'selections.json']:
        copy(T / 'source-atlas' / name, 'atlas/source/' + name)
    tree(T / 'reproduction', 'evidence/reproduction', {'.json', '.log'})
    for f in (T / 'runs').glob('*/*/validation.json'):
        copy(f, Path('evidence/batch') / f.relative_to(T / 'runs'))
    for f in (T / 'baseline').glob('*'):
        if f.is_file():
            copy(f, 'evidence/baseline/' + f.name)
    for folder in ['native-base-D']:
        tree(T / 'experiments' / folder, 'evidence/experiments/' + folder, {'.json', '.jpg', '.log'})
    # Keep full libraries and their original provenance for the integrated recipe.
    spec = read(T / 'config/D-integrated.json')
    for key in ['scene', 'landscape']:
        lib = Path(spec[key]['library'])
        copy(lib, f'inputs/libraries/{key}-library.json')
        data = read(lib)
        if 'review' in data:
            copy(Path(data['review']), f'inputs/libraries/{key}-review.json')
    # Current sources include the bounded native-auditor correction; frozen repaint CLI is separate.
    OUT.mkdir(parents=True, exist_ok=True)
    files = [R / 'go.mod', R / 'go.sum', R / 'LICENSE']
    for folder in ['cmd/terrain-gen', 'internal', 'scripts', 'examples/terrain', 'generators/markovjunior-host']:
        files.extend(f for f in (R / folder).rglob('*') if f.is_file()
                     and not any(part in {'bin', 'obj', '__pycache__'} for part in f.relative_to(R).parts)
                     and f.suffix.lower() not in {'.exe', '.dll', '.pdb', '.w3x'})
    with zipfile.ZipFile(OUT / 'source.zip', 'w', zipfile.ZIP_DEFLATED) as z:
        for f in sorted(set(files)):
            z.write(f, f.relative_to(R).as_posix())
    copy(R / 'LICENSE', 'LICENSE-wc3-forge.txt')
    inputs = {}
    for folder in ['inputs', 'profile', 'config', 'bin']:
        for f in sorted((OUT / folder).rglob('*')):
            if f.is_file():
                inputs[f.relative_to(OUT).as_posix()] = sha(f)
    write(OUT / 'reproduction-inputs.json', {'format': 'wc3-material-release-inputs-v1', 'inputs': inputs, 'cases': cases})
    # Portable atlas uses raw, already-reviewed images and links to exact capture metadata.
    parts = ['<!doctype html><html lang="es"><meta charset="utf-8"><title>Materiales contextuales — D/E/F</title>',
             '<style>body{font:16px system-ui;background:#18201b;color:#edf3ed;max-width:1450px;margin:30px auto;padding:0 20px}a{color:#acdcb9}nav{display:flex;gap:20px;flex-wrap:wrap}section{margin:44px 0}figure{margin:0}img{width:100%;height:auto}figcaption{padding:8px} .pair{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin:20px 0}h2{border-top:1px solid #6a7e70;padding-top:20px}@media(max-width:850px){.pair{grid-template-columns:1fr}}</style>',
             '<h1>El mismo paisaje, con el suelo corregido</h1><p>Capturas reales revisadas. Izquierda: base P. Derecha: materiales contextuales. Cámaras emparejadas; los objetos, agua y relieve se conservan. Sin evaluación de sombras ni pruebas dentro del juego.</p>',
             '<nav><a href="#D">D · 52700</a><a href="#E">E · 53700</a><a href="#F">F · 54700</a><a href="#source">Original</a><a href="#native">World Editor</a><a href="../README.md">Guía y reproducción</a></nav>']

    def figure(path, label):
        return f'<figure><a href="{html.escape(path)}"><img loading="lazy" src="{html.escape(path)}" alt="{html.escape(label)}"></a><figcaption>{html.escape(label)}</figcaption></figure>'

    names = {'top': 'General', 'forest': 'Bosque', 'edge-clearing': 'Borde y claro', 'coast': 'Costa', 'rock-isolated': 'Roca aislada', 'rock-slope': 'Roquedo', 'scene-access': 'Escena y acceso'}
    for case in cases:
        b = case['brief']
        parts.append(f'<section id="{b}"><h2>{b} · {case["seed"]}</h2><p>SHA256 generado: <code>{case["generated_sha256"]}</code></p>')
        for name, label in names.items():
            parts.append('<div class="pair">' + figure(f'visual/{b}/before/{name}.png', label + ' · antes') + figure(f'visual/{b}/after/{name}.png', label + ' · después') + '</div>')
        for f in sorted((OUT / f'atlas/visual/{b}/bare').glob('*.png')):
            parts.append(figure(f.relative_to(OUT / 'atlas').as_posix(), 'Diagnóstico sin objetos · ' + f.stem))
        extra = OUT / f'atlas/visual/{b}/coast-extra'
        if extra.exists():
            parts.append('<div class="pair">' + ''.join(figure(f.relative_to(OUT / 'atlas').as_posix(), 'Costa mutable · ' + f.parent.name) for f in sorted(extra.rglob('*.png'), reverse=True)) + '</div>')
        parts.append('</section>')
    parts.append('<section id="source"><h2>Ejemplos del mapa original</h2><p>Regiones distintas a igual escala de inspección; no son parejas espaciales antes/después.</p><div class="pair">')
    for f in sorted((OUT / 'atlas/source/visual-v3').glob('*.png')):
        parts.append(figure(f.relative_to(OUT / 'atlas').as_posix(), f.stem))
    for f in sorted((OUT / 'atlas/source/bare-visual').glob('*.png')):
        parts.append(figure(f.relative_to(OUT / 'atlas').as_posix(), 'Suelo original despejado · ' + f.stem))
    parts.append('</div></section><section id="native"><h2>Guardados y reaperturas reales en World Editor</h2>')
    for b in ['D', 'E', 'F']:
        parts.append(f'<h3>{b}</h3><div class="pair">')
        for name in ['overview', 'forest', 'rock-coast', 'scene-access']:
            parts.append(figure(f'../evidence/editor/{b}/{name}.jpg', f'{b} · {name}'))
        parts.append('</div>')
    parts.append('</section></html>')
    (OUT / 'atlas/index.html').write_text('\n'.join(parts), encoding='utf-8')
    print('Prepared package:', OUT, flush=True)


if __name__ == '__main__':
    main()
