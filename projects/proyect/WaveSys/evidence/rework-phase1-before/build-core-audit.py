#!/usr/bin/env python3
"""Build isolated native core audit; never edits the copied/original sources."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = Path('/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py')
BASE = Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/maps/originals/TerrainDev.w3x')
OUT = ROOT / 'artifacts'
EVIDENCE = ROOT / 'evidence'

def run(args, name):
    command = [sys.executable, str(LAUNCHER), *map(str, args)]
    p = subprocess.run(command, text=True, capture_output=True)
    (EVIDENCE / (RUN_ID + '-' + name)).write_text(json.dumps(dict(command=command, returncode=p.returncode, stdout=p.stdout, stderr=p.stderr), indent=2))
    if p.returncode:
        raise RuntimeError(f'Failed; see {EVIDENCE / name}')

def read(path):
    raw = path.read_bytes()
    try:
        return raw.decode('utf-8-sig')
    except UnicodeDecodeError:
        return raw.decode('cp1252')

def build():
    base = OUT / 'base-map'
    if not (base / 'war3map.j').exists():
        run(['wc3ctl', 'extract', BASE, '--all', '--out', base, '--json'], 'core-extract.json')
    mapcode = read(base / 'war3map.j')
    mapcode, n = re.subn(r'^\s*call ConditionalTriggerExecute\(gg_trg_Melee_Initialization\)[^\n]*', '\n    // Melee initialization disabled only in audit map.', mapcode, flags=re.M)
    assert n == 2, n
    if SOURCE_SET == 'core':
        sources = ['libraries/Table.j', 'libraries/TimerUtils.j', 'libraries/SwlsMath.j',
                   'WaveSysAnAI/SwlsWave/SwlsWave.j', 'WaveSysAnAI/SwlsWave/WavePointGroups.j']
    else:
        sources = ['Players/WavePlayerUtils.j']
        if SOURCE_SET == 'players-coexist':
            sources.append('libraries/PlayerUtils.j')
    # WaveTest uses this Classic native but obtains its declaration indirectly
    # from SpellIndex in the full build. Declare the same native for isolation.
    boundary = 'native UnitAlive takes unit id returns boolean\nlibrary TheEnd\nfunction endF takes string nextWaveFunc returns nothing\nendfunction\nendlibrary\n'
    if SOURCE_SET != 'core':
        boundary = ''
    bodies = []
    for s in sources:
        body = read(ROOT/'src'/s)
        if BREAK_INVERSE and s.endswith('WavePlayerUtils.j'):
            correct = 'set this.positions[moved] = index + 1'
            assert body.count(correct) == 1
            body = body.replace(correct, '// Negative control: omit moved player inverse update.')
        if INIT_SLOT and s.endswith('SwlsWave.j'):
            start = body.index('private function OnUnitDeath takes')
            prefix, suffix = body[:start], body[start:]
            suffix, n = re.subn(r'local WaveSlot s\b', 'local WaveSlot s = 0', suffix, count=1)
            assert n == 1
            body = prefix + suffix
        bodies.append(body)
    source = OUT / (RUN_ID + '-input.j')
    source.write_text(boundary + '\n'.join(bodies)
                      + read(ROOT/FIXTURE).replace('@RUN@', RUN_ID) + '\n' + mapcode)
    compiled = OUT / (RUN_ID + '-compiled.j')
    assert not compiled.exists(), 'Use a new output for another build'
    run(['vjass', source, compiled], 'core-compile.json')
    target = OUT / ('WaveSys-' + RUN_ID + '.w3x')
    assert not target.exists()
    run(['wc3ctl', 'file', 'set', BASE, 'war3map.j', compiled, '-o', target, '--json'], 'core-pack.json')
    verify = OUT / (RUN_ID + '-verified')
    run(['wc3ctl', 'extract', target, '--all', '--out', verify, '--json'], 'core-reextract.json')
    assert (verify/'war3map.j').read_bytes() == compiled.read_bytes()
    for p in base.rglob('*'):
        if p.is_file() and p.name not in {'war3map.j', '(listfile)'}:
            assert p.read_bytes() == (verify / p.relative_to(base)).read_bytes(), str(p)
    assert BASE.read_bytes()[:512] == target.read_bytes()[:512]
    result = dict(map=str(target), sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
                  base=str(BASE), base_sha256=hashlib.sha256(BASE.read_bytes()).hexdigest(),
                  sources=sources, boundary='TheEnd.endF no-op; empty callbacks in every test' if SOURCE_SET == 'core' else 'None: real player library and Classic APIs only',
                  fixture=FIXTURE,
                  diagnostic_change=('Omit moved inverse update (expected negative control)' if BREAK_INVERSE else
                                     'OnUnitDeath local slot initialized to zero' if INIT_SLOT else 'None: exact sources'),
                  purpose='Isolated '+SOURCE_SET+' integration in real Classic engine; no full survival map coverage',
                  jass_sha256=hashlib.sha256(compiled.read_bytes()).hexdigest(), compiled=True, validated=True,
                  reextracted=True, other_members_preserved=True, game_tested=False)
    (EVIDENCE/(RUN_ID + '-build.json')).write_text(json.dumps(result, indent=2))
    print(json.dumps(result, indent=2))

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--run-id', required=True)
    parser.add_argument('--initialize-death-slot', action='store_true')
    parser.add_argument('--fixture', default='tests/CoreAudit.j')
    parser.add_argument('--source-set', choices=['core', 'players', 'players-coexist'], default='core')
    parser.add_argument('--break-roster-inverse', action='store_true', help='Expected negative control; generated input only')
    args = parser.parse_args()
    assert re.fullmatch(r'[a-zA-Z0-9-]+', args.run_id)
    RUN_ID, INIT_SLOT = args.run_id, args.initialize_death_slot
    FIXTURE = args.fixture
    SOURCE_SET, BREAK_INVERSE = args.source_set, args.break_roster_inverse
    assert not INIT_SLOT or SOURCE_SET == 'core'
    assert not BREAK_INVERSE or SOURCE_SET != 'core'
    assert (ROOT/FIXTURE).resolve().is_relative_to(ROOT/'tests')
    build()
