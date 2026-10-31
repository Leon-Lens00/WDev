#!/usr/bin/env python3
"""Rebuild TerrainDev Classic from the immutable original and editable sources."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import shutil
import struct
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = Path('/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def integer(n):
    return struct.pack('<i', n)


def cstring(s):
    return s.encode('utf-8') + b'\0'


class Reader:
    def __init__(self, data):
        self.data, self.pos = data, 0

    def take(self, n):
        result = self.data[self.pos:self.pos+n]
        assert len(result) == n
        self.pos += n
        return result

    def int(self):
        return struct.unpack('<i', self.take(4))[0]

    def string(self):
        end = self.data.index(0, self.pos)
        return self.take(end-self.pos+1)


def units(data):
    r = Reader(data)
    assert r.int() == 2, 'Only Classic unit object format v2 is supported'
    tables = []
    for _ in range(2):
        records = []
        for _ in range(r.int()):
            begin = r.pos
            base, new, count = r.take(4), r.take(4), r.int()
            mods = []
            for _ in range(count):
                field, kind = r.take(4), r.int()
                assert kind in (0, 1, 2, 3)
                value = r.string() if kind == 3 else r.take(4)
                mods.append((field, kind, value, r.take(4)))
            records.append({'base': base, 'id': new, 'mods': mods, 'raw': data[begin:r.pos]})
        tables.append(records)
    assert r.pos == len(data)
    # Before editing, prove the parser can reproduce every original byte.
    assert encode_units(tables) == data
    return tables


def encode_record(record):
    return record['base'] + record['id'] + integer(len(record['mods'])) + b''.join(
        field + integer(kind) + value + end for field, kind, value, end in record['mods'])


def encode_units(tables):
    return integer(2) + b''.join(integer(len(t)) + b''.join(encode_record(x) for x in t) for t in tables)


def set_field(record, field, kind, value):
    field = field.encode('ascii')
    value = cstring(value) if kind == 3 else (integer(value) if kind == 0 else struct.pack('<f', value))
    record['mods'] = [m for m in record['mods'] if m[0] != field]
    record['mods'].append((field, kind, value, b'\0'*4))


def triggers(data, names):
    r = Reader(data)
    assert r.take(4) == b'WTG!' and r.int() == 7
    category_count = r.int()
    assert category_count == 1
    start = r.pos
    assert r.int() == 0
    r.string()
    r.int()
    categories = data[start:r.pos]
    middle_start = r.pos
    r.int()
    assert r.int() == 0, 'Base map variables changed; review before rebuilding'
    middle = data[middle_start:r.pos]
    assert r.int() == 2, 'Base map trigger count changed'
    original_records = bytearray(data[r.pos:])
    header = Reader(original_records)
    assert header.string() == b'Melee Initialization\0'
    header.string()
    assert header.int() == 0
    enabled = header.pos
    assert header.int() == 1
    original_records[enabled:enabled+4] = integer(0)
    original_records = bytes(original_records)
    added = b''
    for name in names:
        added += cstring(name) + cstring('TerrainDev foundation; original author credits in code.')
        added += b''.join(integer(v) for v in (0, 1, 1, 0, 0, 1, 0))
    return (b'WTG!' + integer(7) + integer(2) + categories + integer(1) +
            cstring('Project Libraries') + integer(0) + middle + integer(2+len(names)) +
            original_records + added)


def custom_text(data, bodies):
    r = Reader(data)
    assert r.int() == 1
    r.string()
    r.take(r.int())
    header = data[:r.pos]
    assert r.int() == 2
    begin = r.pos
    for _ in range(2):
        r.take(r.int())
    assert r.pos == len(data)
    return header + integer(2+len(bodies)) + data[begin:] + b''.join(
        integer(len(body)+1) + body + b'\0' for body in bodies)


def run(args, log):
    command = [sys.executable, str(LAUNCHER), *map(str, args)]
    result = subprocess.run(command, capture_output=True, text=True)
    log.write_text(json.dumps({'command': command, 'returncode': result.returncode,
                              'stdout': result.stdout, 'stderr': result.stderr}, indent=2))
    if result.returncode:
        raise RuntimeError(f'Command failed; see {log}: {result.stdout} {result.stderr}')
    return result.stdout


def map_script(path):
    """Keep original GUI actions recoverable, disable the melee trigger at runtime."""
    code = path.read_bytes()
    code, count = re.subn(rb'(^[ \t]*call TriggerAddAction\(gg_trg_Melee_Initialization,[^\r\n]+)',
                         rb'\1\n    call DisableTrigger(gg_trg_Melee_Initialization)',code,flags=re.MULTILINE)
    assert count == 1
    # TriggerExecute/ConditionalTriggerExecute can execute disabled triggers.
    # Remove the two explicit initialization calls as well as disabling WTG.
    code, count = re.subn(rb'^[ \t]*call ConditionalTriggerExecute\(gg_trg_Melee_Initialization\)[^\r\n]*',
                         b'    // Melee initialization disabled for the Rapid Fire prototype.',code,flags=re.MULTILINE)
    assert count == 2
    return code


# Megaman X3 physics live in their own isolated test map (profile x3).
X3_LIBRARIES = ('X3Kinematics','X3Buster','X3Charge','X3BusterDemo')


def build(destination=None, profile='main'):
    assert profile in ('main','x3')
    assert profile == 'main' or destination, 'The x3 profile is a test map: pass --output'
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    work = ROOT / 'build' / stamp
    work.mkdir(parents=True)
    report = ROOT / 'reports' / stamp
    report.mkdir()
    original = ROOT / 'maps/originals/TerrainDev.w3x'
    identity = json.loads((ROOT/'reports/original.json').read_text())
    assert digest(original.read_bytes()) == identity['sha256']
    base = work/'base'
    run(['wc3ctl', 'extract', original, '--all', '--out', base, '--json'], report/'extract-base.json')
    manifest = json.loads((ROOT/'libraries.json').read_text())
    names = manifest['order']
    entry = (ROOT/'src/Main.j').read_text()
    imports = re.findall(r'^\s*//! import "libraries/([^"/]+)\.j"\s*$', entry, re.MULTILINE)
    assert imports == names, 'Main.j imports must match the ordered editable WCT library list'
    if profile == 'main':
        names = [n for n in names if n not in X3_LIBRARIES]
    assert all(not line.strip() or line.strip().startswith('//') for line in entry.splitlines()), \
        'Put map code in its own custom-text source and add it to Main.j and libraries.json'
    bodies = [(ROOT/'src/libraries'/f'{name}.j').read_bytes() for name in names]
    source = work/'input.j'
    source.write_bytes(b'\n\n'.join(bodies) + b'\n\n' + map_script(base/'war3map.j'))
    compiled = work/'compiled.j'
    run(['vjass', source, compiled], report/'compile.json')
    tables = units((base/'war3map.w3u').read_bytes())
    from rapid_objects import abilities, encode_abilities, unit_records, ability_record
    assert {x['id'] for x in tables[1]} == {b'n000', b'n001'}
    for rawid in ('dumi', 'dcst'):
        rec = units((ROOT/'assets'/f'{rawid}.w3u').read_bytes())[1][0]
        assert rec['id'] == rawid.encode('ascii')
        tables[1].append(rec)
    additions = unit_records()
    assert not {r['id'] for r in additions} & {r['id'] for r in tables[1]}
    tables[1].extend(additions)
    ability_tables = abilities((base/'war3map.w3a').read_bytes())
    assert {r['id'] for r in ability_tables[1]} == {b'A000'}
    ability_tables[1].append(ability_record())
    if profile == 'x3':
        from x3_objects import ability_records as extra_ability_records
        spells = ('Ax3c','Ax3s','Ax3z')
    else:
        from shots_objects import ability_records as extra_ability_records
        spells = ('Arp1','Arp3')
    ability_tables[1].extend(extra_ability_records())
    controller = next(r for r in tables[1] if r['id'] == b'rfct')
    set_field(controller,'uabi',3,','.join(('Arpf',)+spells+('Avul',)))
    changes = {
        'war3map.j': compiled.read_bytes(),
        'war3map.w3u': encode_units(tables),
        'war3map.w3a': encode_abilities(ability_tables),
        'war3map.wtg': triggers((base/'war3map.wtg').read_bytes(), names),
        'war3map.wct': custom_text((base/'war3map.wct').read_bytes(), bodies),
        'war3mapImported\\dummy.mdx': (ROOT/'assets/dummy.mdx').read_bytes(),
    }
    imp = (base/'war3map.imp').read_bytes()
    assert imp == integer(1)+integer(1)+bytes([8])+cstring('KoboldDigger.mdx')
    x3_assets = json.loads((ROOT/'assets/x3-buster/manifest.json').read_text())
    firebrand_assets = json.loads((ROOT/'assets/firebrand-shots/manifest.json').read_text())
    # Only the Shots copies shifted in X are imported; the unmodified originals in
    # assets/shots-originales are just the input of scripts/shots_ajustados.cjs.
    shifted_assets = json.loads((ROOT/'assets/shots-ajustados/manifest.json').read_text())
    # Windwalk feet effect for artificial motion, one per missile color (scripts/windwalk_colores.cjs).
    windwalk_assets = json.loads((ROOT/'assets/windwalk-colores/manifest.json').read_text())
    profile_assets = x3_assets['imports'] if profile == 'x3' else shifted_assets['imports']
    # The unmodified Firebrand originals load their glow BLP from the map root.
    root_textures = {a['internal'] for a in firebrand_assets['imports'] if '\\' not in a['internal']}
    assert root_textures == {'PsionicGlow.blp','FelGlow.blp','BattlecastGlow.blp','VoidGlow.blp','RadiantGlow.blp'}
    extra_imports = []
    # RapidPair (both profiles) shows Windwalk while in artificial motion.
    for asset in firebrand_assets['imports']+windwalk_assets['imports']+profile_assets:
        path = (ROOT/'assets'/asset['file']).resolve(strict=True)
        assert path.is_relative_to((ROOT/'assets').resolve())
        payload = path.read_bytes()
        assert digest(payload) == asset['sha256'], f'Asset hash changed: {path}'
        internal = asset['internal']
        assert internal.startswith(('ShotsAjustados\\','Windwalk\\','X3Buster\\','FirebrandShots\\')) or internal in root_textures
        assert internal not in changes and not (base/internal.replace('\\','/')).exists()
        changes[internal] = payload
        extra_imports.append(bytes([13])+cstring(internal))
    changes['war3map.imp'] = (integer(1)+integer(2+len(extra_imports))+imp[8:]
                              +bytes([8])+cstring('dummy.mdx')+b''.join(extra_imports))
    current = original
    for index, (internal, payload) in enumerate(changes.items()):
        file = work/f'payload-{index}.bin'
        file.write_bytes(payload)
        output = work/f'stage-{index}.w3x'
        run(['wc3ctl','file','set',current,internal,file,'-o',output,'--json'],report/f'pack-{index}.json')
        current = output
    extracted = work/'verified'
    run(['wc3ctl','extract',current,'--all','--out',extracted,'--json'],report/'extract-final.json')
    checks = []
    for file in base.rglob('*'):
        if not file.is_file() or file.name == '(listfile)':
            continue
        internal = str(file.relative_to(base)).replace('/', '\\')
        expected = changes.get(internal, file.read_bytes())
        actual = (extracted/file.relative_to(base)).read_bytes()
        assert actual == expected, f'Member changed unexpectedly: {internal}'
        checks.append({'member': internal, 'changed': internal in changes, 'sha256': digest(actual)})
    for internal, payload in changes.items():
        assert (extracted/Path(internal.replace('\\','/'))).read_bytes() == payload
    original_bytes = original.read_bytes()
    if original_bytes[:4] == b'HM3W':
        # Native repack must preserve the full game header, not only the MPQ.
        assert current.read_bytes()[:512] == original_bytes[:512]
    run(['pjass',extracted/'war3map.j'],report/'pjass-final.json')
    native = json.loads(run(['wc3ctl','trigger','read',current,'--json'],report/'triggers-final.json'))
    original_triggers = json.loads(run(['wc3ctl','trigger','read',original,'--json'],report/'triggers-base.json'))
    expected_triggers = original_triggers['Triggers']
    expected_triggers[0]['Enabled'] = False
    assert native['Triggers'][:2] == expected_triggers
    assert [t['Name'] for t in native['Triggers'][2:]] == names
    assert all(t['IsCustomText'] and t['Enabled'] for t in native['Triggers'][2:])
    for rawid in ('dumi','dcst','rfex','rfct','rftg','rfm1','rfm2','rfm3','rbs2','rbs3','Arpf')+spells:
        obj = json.loads(run(['wc3ctl','object','get',current,rawid,'--json'],report/f'object-{rawid}.json'))
        assert obj['Found']
    # A candidate output leaves the delivered map and latest-build.json untouched.
    final = Path(destination).resolve() if destination else ROOT/'TerrainDev.w3x'
    assert final != original.resolve()
    final.parent.mkdir(parents=True, exist_ok=True)
    if final.exists():
        shutil.copy2(final, work/'previous-output.w3x')
    shutil.copy2(current, final)
    result = {'map':str(final),'sha256':digest(final.read_bytes()),'original_sha256':identity['sha256'],
              'libraries':names,'library_sha256':{n:digest(b) for n,b in zip(names,bodies)},
              'profile':profile,
              'x3_assets':x3_assets['imports'] if profile == 'x3' else [],
              'shots_shifted_assets':shifted_assets['imports'] if profile == 'main' else [],
              'windwalk_assets':windwalk_assets['imports'],
              'firebrand_assets':firebrand_assets['imports'],
              'checks':checks,'build_directory':str(work),'report_directory':str(report),
              'compiled':True,'pjass':True,'native_trigger_roundtrip':True,
              'game_tested':False,'editor_tested':False,'candidate':bool(destination)}
    (report/'result.json').write_text(json.dumps(result,indent=2))
    if not destination:
        (ROOT/'reports/latest-build.json').write_text(json.dumps(result,indent=2))
    print(json.dumps(result,indent=2))


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', help='write a candidate map here instead of TerrainDev.w3x')
    parser.add_argument('--profile', choices=('main','x3'), default='main',
                        help='main: Firebrand/Shots missiles; x3: isolated Megaman X3 physics test map')
    args = parser.parse_args()
    build(args.output, args.profile)
