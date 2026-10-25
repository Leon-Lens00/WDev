#!/usr/bin/env python3
"""Build an audit with all active libraries, retaining real dependencies.

The generated input adapts the four known InitTrig identifiers (E01) and
disables only the two scenario entry-point initializers. No src file changes.
An optional independently built resource base supplies original objects/imports.
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = Path('/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py')
BASE = Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/maps/originals/TerrainDev.w3x')


def read(path):
    raw = path.read_bytes()
    try:
        return raw.decode('utf-8-sig')
    except UnicodeDecodeError:
        return raw.decode('cp1252')


# E07 audit-only observers; they read the private tables and never write.
TABLE_OBSERVERS = {
    'WaveSysAnAI/AI/IAManager.j': """
    // Generated audit-only observers (E07); no state changes.
    function WaveAuditAIMask takes unit u returns integer
        local integer hid = GetHandleId(u)
        local integer r = 0
        if AIIndexByUnit.has(hid) then
            set r = r + 1
        endif
        if AIUnitThreatWeight.real.has(hid) then
            set r = r + 2
        endif
        if AIUnitTarget.handle.has(hid) then
            set r = r + 4
        endif
        if AIUnitLastOrderX.real.has(hid) or AIUnitLastOrderY.real.has(hid) then
            set r = r + 8
        endif
        return r
    endfunction
    function WaveAuditAICount takes nothing returns integer
        return AIUnitCount
    endfunction
    function WaveAuditAISlotHandle takes integer index returns boolean
        return AIUnitByIndex.handle.has(index)
    endfunction
""",
    'WaveSysAnAI/WaveProjectiles/WaveAuraSkills.j': """
    // Generated audit-only observer (E07): handle entries whose unit is gone or lost its hid entry.
    function WaveAuditAuraStaleSlots takes integer id, integer upto returns integer
        local integer i = 1
        local integer key
        local unit u
        local integer r = 0
        loop
            exitwhen i > upto
            set key = WaveAuraMemberKey(id, i)
            if WaveAuraMemberUnitByKey.handle.has(key) then
                set u = WaveAuraMemberUnitByKey.unit[key]
                if u == null or GetUnitTypeId(u) == 0 or not WaveAuraMemberHidByKey.has(key) then
                    set r = r + 1
                endif
            endif
            set i = i + 1
        endloop
        set u = null
        return r
    endfunction
""",
    'WaveSysAnAI/WaveProjectiles/WavePriestSkills.j': """
    // Generated audit-only observers (E07); no state changes.
    function WaveAuditPriestAuraId takes unit u returns integer
        return WavePriestActiveAuraByUnit[GetHandleId(u)]
    endfunction
    function WaveAuditPriestCount takes integer id returns integer
        return WavePriestMemberCount[id]
    endfunction
    function WaveAuditPriestStaleSlots takes integer id, integer upto returns integer
        local integer i = 1
        local integer key
        local unit u
        local integer r = 0
        loop
            exitwhen i > upto
            set key = WavePriestMemberKey(id, i)
            if WavePriestMemberUnitByKey.handle.has(key) then
                set u = WavePriestMemberUnitByKey.unit[key]
                if u == null or GetUnitTypeId(u) == 0 or not WavePriestMemberHidByKey.has(key) then
                    set r = r + 1
                endif
            endif
            set i = i + 1
        endloop
        set u = null
        return r
    endfunction
""",
}

# Negative control: the nine E07 removes as they were before the fix.
E07_REMOVES = {
    'WaveSysAnAI/AI/IAManager.j': [
        ('AIUnitLastOrderX.real.remove(', 'AIUnitLastOrderX.remove(', 1),
        ('AIUnitLastOrderY.real.remove(', 'AIUnitLastOrderY.remove(', 1),
        ('AIUnitTarget.handle.remove(', 'AIUnitTarget.remove(', 1),
        ('AIUnitByIndex.handle.remove(', 'AIUnitByIndex.remove(', 1),
        ('AIUnitThreatWeight.real.remove(', 'AIUnitThreatWeight.remove(', 1)],
    'WaveSysAnAI/WaveProjectiles/WaveAuraSkills.j': [
        ('WaveAuraMemberUnitByKey.handle.remove(', 'WaveAuraMemberUnitByKey.remove(', 3)],
    'WaveSysAnAI/WaveProjectiles/WavePriestSkills.j': [
        ('WavePriestMemberUnitByKey.handle.remove(', 'WavePriestMemberUnitByKey.remove(', 2)],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run-id', required=True)
    parser.add_argument('--fixture', required=True)
    parser.add_argument('--resource-base', action='store_true')
    parser.add_argument('--aura-observers', action='store_true')
    parser.add_argument('--table-observers', action='store_true', help='E07: read-only observers of IA/aura/priest tables')
    parser.add_argument('--revert-e07', action='store_true', help='Expected negative control: generated input only')
    args = parser.parse_args()
    assert re.fullmatch(r'[A-Za-z0-9-]+', args.run_id)
    fixture = (ROOT / args.fixture).resolve(strict=True)
    assert fixture.is_relative_to(ROOT / 'tests')
    out, evidence = ROOT / 'artifacts', ROOT / 'evidence'
    source = out / (args.run_id + '-input.j')
    compiled = out / (args.run_id + '-compiled.j')
    target = out / ('WaveSys-' + args.run_id + '.w3x')
    assert not any(p.exists() for p in [source, compiled, target])

    def run(arguments, step):
        cmd = [sys.executable, str(LAUNCHER), *map(str, arguments)]
        result = subprocess.run(cmd, capture_output=True, text=True)
        log = evidence / (args.run_id + '-' + step + '.json')
        log.write_text(json.dumps(dict(command=cmd, returncode=result.returncode,
                                       stdout=result.stdout, stderr=result.stderr), indent=2))
        if result.returncode:
            raise RuntimeError(f'{step} failed; see {log}')

    base_map = out / 'TerrainDev-WaveResources-v1.w3x' if args.resource_base else BASE
    base = out / 'resource-pack-v1/verified' if args.resource_base else out / 'base-map'
    assert base_map.exists()
    if not (base / 'war3map.j').exists():
        run(['wc3ctl', 'extract', base_map, '--all', '--out', base, '--json'], 'extract')
    mapcode, n = re.subn(r'^\s*call ConditionalTriggerExecute\(gg_trg_Melee_Initialization\)[^\n]*',
                        '\n    // Audit: melee startup disabled.', read(base / 'war3map.j'), flags=re.M)
    assert n == 2
    entries = sorted(e['path'] for e in json.loads((ROOT / 'evidence/original-manifest.json').read_text())
                     if e['active'] and e['path'].endswith('.j'))
    entries = sorted(entries + ['Players/WavePlayerUtils.j'])
    assert len(entries) == 114
    # These are the same map-owned rect symbols used in the first syntax audit.
    rects = read(out / 'full-current-input.j').split('// SOURCE:', 1)[0]
    bodies, hashes, disabled = [], [], []
    for name in entries:
        p = ROOT / 'src' / name
        body = read(p)
        if args.aura_observers and name.endswith('/WaveAuraSkills.j'):
            observers = '''
    // Generated audit-only observers; no state changes.
    function WaveAuditAuraId takes unit u returns integer
        return WaveAuraActiveAuraByUnit[GetHandleId(u)]
    endfunction
    function WaveAuditAuraCount takes integer id returns integer
        return WaveAuraMemberCount[id]
    endfunction
    function WaveAuditAuraAt takes integer id, integer index returns unit
        return WaveAuraMemberUnitByKey.unit[WaveAuraMemberKey(id, index)]
    endfunction
    function WaveAuditAuraOwner takes unit u returns integer
        return WaveAuraUnitOwnerAura[GetHandleId(u)]
    endfunction
'''
            before, after = body.rsplit('endlibrary', 1)
            body = before + observers + 'endlibrary' + after
        if args.table_observers and name in TABLE_OBSERVERS:
            before, after = body.rsplit('endlibrary', 1)
            body = before + TABLE_OBSERVERS[name] + 'endlibrary' + after
        if args.revert_e07 and name in E07_REMOVES:
            for typed, plain, count in E07_REMOVES[name]:
                assert body.count(typed) == count, (name, typed)
                body = body.replace(typed, plain)
        if name in ['InitMap/MapBootstrap.j', 'WaveSysAnAI/SwlsWave/StageExample.j']:
            body, n = re.subn(r'^(library\s+\w+)\s+initializer\s+\w+', r'\1', body, count=1, flags=re.M)
            assert n == 1, name
            disabled.append(name)
        bodies.append('// SOURCE: ' + name + '\n' + body)
        hashes.append(dict(path=name, sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
    code = rects + '\n'.join(bodies)
    names = sorted(set(re.findall(r'\bInitTrig_\w+', code)))
    assert len(names) == 4, names
    for name in names:
        code = re.sub(r'\b' + re.escape(name) + r'\b', 'Audit' + name, code)
    # Map-generated InitTrig functions are legal top-level JASS and stay exact.
    code += '\n' + read(fixture).replace('@RUN@', args.run_id) + '\n' + mapcode
    source.write_text(code)
    run(['vjass', source, compiled], 'compile')
    run(['wc3ctl', 'file', 'set', base_map, 'war3map.j', compiled, '-o', target, '--json'], 'pack')
    verified = out / (args.run_id + '-verified')
    run(['wc3ctl', 'extract', target, '--all', '--out', verified, '--json'], 'reextract')
    assert (verified / 'war3map.j').read_bytes() == compiled.read_bytes()
    for p in base.rglob('*'):
        if p.is_file() and p.name not in ['war3map.j', '(listfile)', '(attributes)']:
            assert p.read_bytes() == (verified / p.relative_to(base)).read_bytes(), p
    assert base_map.read_bytes()[:512] == target.read_bytes()[:512]
    result = dict(map=str(target), sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
                  source_count=len(entries), sources=hashes, fixture=str(fixture),
                  disabled_initializers=disabled, diagnostic_renames={n: 'Audit' + n for n in names},
                  boundaries='15 map rect declarations null; explicit fixture setup; ' + ('DevMission resource overlay, independent terrain' if args.resource_base else 'TerrainDev object data; no survival custom data'),
                  base_map=str(base_map), base_sha256=hashlib.sha256(base_map.read_bytes()).hexdigest(),
                  read_only_aura_observers=args.aura_observers,
                  read_only_table_observers=args.table_observers,
                  negative_control_revert_e07=args.revert_e07,
                  compiled=True, validated=True, reextracted=True, other_members_preserved=True,
                  generated_mpq_metadata_excluded=['(listfile)', '(attributes)'],
                  game_tested=False, full_survival_map_tested=False)
    (evidence / (args.run_id + '-build.json')).write_text(json.dumps(result, indent=2))
    print(json.dumps({k: v for k, v in result.items() if k != 'sources'}, indent=2))


if __name__ == '__main__':
    main()
