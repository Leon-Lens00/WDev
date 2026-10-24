#!/usr/bin/env python3
"""Public CLI regression, retaining explicit owned evidence (not scratch/cache)."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
from mpyq import MPQArchive
from readback import records

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('baseline_builder', ROOT.parent / 'relativistic-classic/tools/build.py')
b = importlib.util.module_from_spec(spec)
spec.loader.exec_module(b)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--phase', choices=('red', 'green'), required=True)
    p.add_argument('--attempt', choices=('initial','correction'), default='initial')
    p.add_argument('--evidence', type=Path, help='New retained evidence directory; default keeps historical naming')
    a = p.parse_args()
    evidence = (a.evidence or ROOT / ('reports/tests-' + a.phase + ('-correction' if a.attempt == 'correction' else ''))).resolve()
    b.guard([evidence], [ROOT / 'base/04-ncl2-schema-probe.w3x'])
    evidence.mkdir()
    base = ROOT / 'base/04-ncl2-schema-probe.w3x'
    before = base.read_bytes()
    recipe = json.loads((ROOT / 'base/objects.json').read_text())

    def invoke(label, rows, source=base, target=None):
        r = evidence / (label + '.recipe.json')
        b.write_new(r, b.json_bytes(rows))
        out = target or evidence / (label + '.w3x')
        argv = [sys.executable, '-B', str(ROOT / 'tools/prepare_objects.py'), '--base', str(source),
                '--recipe', str(r), '--out', str(out), '--evidence', str(evidence / (label + '-details'))]
        proc = subprocess.run(argv, capture_output=True, timeout=12)
        for suffix, data in [('stdout.txt', proc.stdout), ('stderr.txt', proc.stderr),
                             ('command.json', b.json_bytes(dict(argv=argv, exit=proc.returncode)))]:
            b.write_new(evidence / (label + '.' + suffix), data)
        assert source.read_bytes() == (before if source == base else source_before)
        return proc, out

    proc, out = invoke('valid', recipe)
    assert (proc.returncode, proc.stdout, proc.stderr) == (0, b'prepared owned object base\n', b'')
    prefix, old, old_archive = b.read_map(before, MPQArchive)
    new_prefix, new, new_archive = b.read_map(out.read_bytes(), MPQArchive)
    channel = next(x for x in records(new['war3map.w3a'], True) if x['new'] == 'A00G')
    ncl2 = next(m for m in channel['mods'] if m['field'] == 'Ncl2')
    assert ncl2['pointer'] == 2, 'Ncl2 diagnostic selector remains0; metadata requires2'
    assert prefix == new_prefix and old_archive.opaque_members == new_archive.opaque_members
    assert {k:v for k,v in old.items() if k not in ('war3map.w3u', 'war3map.w3a')} == {k:v for k,v in new.items() if k not in ('war3map.w3u', 'war3map.w3a')}
    owned = {'o000', 'o001', 'A00G'}
    for name, leveled in [('war3map.w3u', False), ('war3map.w3a', True)]:
        left, right = records(old[name], leveled), records(new[name], leveled)
        assert [x['raw'] for x in left if x['new'] not in owned] == [x['raw'] for x in right if x['new'] not in owned]
        for row in recipe:
            if (row['kind'] == 'ability') != leveled:
                continue
            obj = next(x for x in right if x['new'] == row['id'])
            mod = next(m for m in obj['mods'] if (m['field'], m['level']) == (row['field'], row['level']))
            assert abs(mod['value'] - row['value']) < 0.00001 if isinstance(row['value'], float) else mod['value'] == row['value']
            expected_type = {'Ncl1':2,'Ncl2':0,'Ncl3':0,'Ncl4':2,'Ncl5':0,'Ncl6':3,
                             'unam':3,'uabi':3,'uaen':0,'anam':3,'alev':0,'aher':0,
                             'acdn':2,'amcs':0,'aran':2}[row['field']]
            assert mod['type'] == expected_type
            if row['field'].startswith('Ncl'):
                assert mod['pointer'] == int(row['field'][-1])
            else:
                assert mod['pointer'] == 0
    source_before = out.read_bytes()
    # PRESERVE: reapplying the same declared recipe keeps all member payloads.
    again, again_out = invoke('preserve', recipe, source=out)
    assert (again.returncode, again.stdout, again.stderr) == (0, b'prepared owned object base\n', b'')
    assert b.read_map(again_out.read_bytes(), MPQArchive)[1] == new
    for label, change, message in [
        ('unknown', {'field':'xxxx'}, 'unknown or disallowed field'),
        ('kind', {'kind':'item'}, 'invalid owned object kind or id'),
        ('level', {'level':0}, 'invalid metadata level'),
        ('type', {'value':'2'}, 'value type does not match metadata')]:
        rows = [dict(recipe[13], **change)]
        rejected, rejected_out = invoke(label, rows)
        assert (rejected.returncode, rejected.stdout, rejected.stderr) == (1, b'', ('error: '+message+'\n').encode())
        assert not rejected_out.exists() and not (evidence / (label+'-details')).exists()
    # Existing output preservation exercises the unchanged reused guard.
    sentinel = evidence / 'occupied.w3x'
    b.write_new(sentinel, b'KEEP')
    rejected, _ = invoke('occupied', recipe, target=sentinel)
    assert rejected.returncode == 1 and rejected.stdout == b''
    assert rejected.stderr == ('error: destination already exists: '+str(sentinel)+'\n').encode()
    assert sentinel.read_bytes() == b'KEEP' and base.read_bytes() == before
    print('PASS: public CLI selector/type/level rejection and preservation')
    print('input_sha256=' + hashlib.sha256(before).hexdigest())


if __name__ == '__main__':
    main()
