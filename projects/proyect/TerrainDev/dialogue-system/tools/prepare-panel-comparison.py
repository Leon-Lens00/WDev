#!/usr/bin/env python3
"""Prepare isolated A/B maps, changing only the two active frame textures."""
from pathlib import Path
import datetime
import hashlib
import importlib.util
import json
import shutil

ROOT = Path(__file__).resolve().parents[1]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    spec = importlib.util.spec_from_file_location('dialogue_builder', ROOT / 'build.py')
    builder = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(builder)
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    work = ROOT / 'build' / ('panel-comparison-' + stamp)
    work.mkdir(parents=True)
    out = ROOT / 'exports' / ('panel-comparison-' + stamp)
    out.mkdir(parents=True)
    baseline = json.loads((ROOT / 'latest-build.json').read_text())
    source = Path(baseline['map'])
    assert sha(source) == baseline['sha256']
    candidates = json.loads((ROOT / 'evidence/panel-textures-512/manifest.json').read_text())
    assert sha(source) == candidates['activeMapSha256']
    run = lambda args, label: builder.f.run(args, work / (label + '.json'))
    before = out / 'TerrainDev-Dialogue-Panel-Antes.w3x'
    after = out / 'TerrainDev-Dialogue-Panel-512.w3x'
    shutil.copy2(source, before)
    run(['wc3ctl', 'extract', before, '--all', '--out', work / 'before', '--json'], 'extract-before')
    current = before
    expected = {}
    for i, texture in enumerate(candidates['textures']):
        choice = next(c for c in texture['candidates'] if c['size'] == '512x256')
        payload = Path(choice['path'])
        assert sha(payload) == choice['sha256']
        member = 'UI\\Dialogue\\' + texture['name']
        extracted = work / 'before' / member.replace('\\', '/')
        assert sha(extracted) == texture['sourceSha256']
        stage = work / ('stage-' + str(i) + '.w3x')
        run(['wc3ctl', 'file', 'set', current, member, payload, '-o', stage, '--json'], 'pack-' + str(i))
        expected[member.replace('\\', '/')] = choice['sha256']
        current = stage
    shutil.copy2(current, after)
    run(['wc3ctl', 'extract', after, '--all', '--out', work / 'after', '--json'], 'extract-after')
    def members(folder):
        return {str(p.relative_to(folder)): sha(p) for p in folder.rglob('*')
                if p.is_file() and p.name not in ('(listfile)', '(attributes)')}
    old, new = members(work / 'before'), members(work / 'after')
    assert old.keys() == new.keys()
    changed = {name: new[name] for name in old if old[name] != new[name]}
    assert changed == expected, changed
    assert before.read_bytes()[:512] == after.read_bytes()[:512]
    run(['pjass', work / 'after/war3map.j'], 'pjass')
    assert sha(source) == baseline['sha256']
    result = dict(before=str(before), after=str(after), beforeSha256=sha(before),
                  afterSha256=sha(after), beforeBytes=before.stat().st_size,
                  afterBytes=after.stat().st_size, changedMembers=changed,
                  verifiedMembers=len(old), scriptUnchanged=True, headerUnchanged=True,
                  pjass=True, activeMapUnchanged=True, nativeTested=False, work=str(work))
    (out / 'comparison.json').write_text(json.dumps(result, indent=2) + '\n')
    (ROOT / 'evidence/panel-textures-512/latest-map-comparison.json').write_text(json.dumps(result, indent=2) + '\n')
    (out / 'LEEME.txt').write_text('Comparación del panel de diálogo\n\n'
        'Antes: texturas originales 1024x512.\n512: texturas 512x256 (mip1 original).\n'
        'Sólo cambian FrameOpenRed.blp y FrameOpenBlue.blp.\n'
        'Comandos: -dialogo, -siguiente, -reiniciardialogo, -patrullardialogo, -cerrardialogo.\n'
        'Esc: completar texto o avanzar página. -misiles: ocultar diagnóstico heredado.\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
