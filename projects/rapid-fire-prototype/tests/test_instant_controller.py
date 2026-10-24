#!/usr/bin/env python3
"""Public CLI timing-field regression; retained evidence only, no game simulation.

Run with the existing registered Python interpreter, -B, --evidence NEW_DIR.
--tool optionally selects an externally retained utility copy, never git history.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import subprocess
import sys
from readback import records
from mpyq import MPQArchive

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('builder', ROOT.parent/'relativistic-classic/tools/build.py')
b = importlib.util.module_from_spec(spec)
spec.loader.exec_module(b)
TIMING = [dict(kind='unit', id='o001', field=f, level=0, value=0.) for f in ('ucpt','ucbs')]
SUCCESS = (0, b'prepared owned object base\n', b'')


class Session:
    def __init__(self, directory, tool):
        self.directory, self.tool = directory.resolve(), tool.resolve()
        b.guard([self.directory], [self.tool, ROOT/'base/05-owned-objects.w3x'])
        self.directory.mkdir(parents=True)
        self.base = self.directory/'owned-input.w3x'
        self.before = (ROOT/'base/05-owned-objects.w3x').read_bytes()
        b.write_new(self.base, self.before)

    def invoke(self, label, rows):
        recipe = self.directory/(label+'.recipe.json')
        output = self.directory/(label+'.w3x')
        details = self.directory/(label+'-details')
        b.write_new(recipe, b.json_bytes(rows))
        saved_recipe = recipe.read_bytes()
        argv = [sys.executable, '-B', str(self.tool), '--base', str(self.base),
                '--recipe', str(recipe), '--out', str(output), '--evidence', str(details)]
        proc = subprocess.run(argv, capture_output=True, timeout=12)
        b.write_new(self.directory/(label+'.stdout.txt'), proc.stdout)
        b.write_new(self.directory/(label+'.stderr.txt'), proc.stderr)
        b.write_new(self.directory/(label+'.command.json'), b.json_bytes(dict(argv=argv, exit=proc.returncode)))
        assert self.base.read_bytes() == self.before and recipe.read_bytes() == saved_recipe
        return (proc.returncode, proc.stdout, proc.stderr), output, details


def opaque_inventory(archive, excluded):
    """Independent raw gameplay blocks, including names the builder omits.

    Exclude only managed unit data and generated MPQ bookkeeping; the existing
    CLI preservation guard separately checks decoded listfile/attribute semantics.
    """
    excluded = {(archive._hash(n,'HASH_A'), archive._hash(n,'HASH_B')) for n in excluded}
    result = {}
    for e in archive.hash_table:
        if e.block_table_index >= len(archive.block_table) or (e.hash_a,e.hash_b) in excluded:
            continue
        block = archive.block_table[e.block_table_index]
        if not block.flags & 0x80000000:
            continue
        archive.file.seek(archive.header['offset']+block.offset)
        raw = archive.file.read(block.archived_size)
        result[str((e.hash_a,e.hash_b,e.locale,e.platform))] = (block.size,block.flags,hashlib.sha256(raw).hexdigest())
    return result


def preserved(before, after):
    prefix, left, la = b.read_map(before, MPQArchive)
    new_prefix, right, ra = b.read_map(after, MPQArchive)
    assert prefix == new_prefix and la.opaque_members == ra.opaque_members
    assert {k:v for k,v in left.items() if k != 'war3map.w3u'} == {k:v for k,v in right.items() if k != 'war3map.w3u'}
    assert opaque_inventory(la, {'war3map.w3u','(listfile)','(attributes)'}) == opaque_inventory(ra, {'war3map.w3u','(listfile)','(attributes)'})
    old, new = records(left['war3map.w3u'], False), records(right['war3map.w3u'], False)
    assert [(r['table'],r['old'],r['new']) for r in old] == [(r['table'],r['old'],r['new']) for r in new]
    for a,z in zip(old,new):
        if a['new'] != 'o001':
            assert a['raw'] == z['raw']  # Includes every byte of actor o000.
        else:
            assert z['mods'][:len(a['mods'])] == a['mods']
            assert z['raw'][12:12+len(a['raw'])-12] == a['raw'][12:]
            expected = [dict(field=f,type=2,level=0,pointer=0,value=0.,end='\0'*4) for f in ('ucpt','ucbs')]
            assert z['mods'][len(a['mods']):] == expected
            added = b''.join(f.encode()+struct.pack('<if',2,0.)+b'\0'*4 for f in ('ucpt','ucbs'))
            assert z['raw'] == a['raw'][:8]+struct.pack('<i',len(a['mods'])+2)+a['raw'][12:]+added
    return dict(hm3w_preserved=True, only_o001_fields_added=['ucpt','ucbs'], actor_and_other_records_byte_identical=True,
                ability_and_other_members_identical=True, opaque_gameplay_blocks_identical=True)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--evidence', type=Path, required=True)
    p.add_argument('--tool', type=Path, default=ROOT/'tools/prepare_objects.py')
    a = p.parse_args()
    s = Session(a.evidence, a.tool)
    result, output, details = s.invoke('valid', TIMING)
    assert result == SUCCESS, 'controller timing recipe must succeed: '+repr(result)
    assert output.is_file() and (details/'preservation.json').is_file()
    verification = preserved(s.before, output.read_bytes())
    report = json.loads((details/'preservation.json').read_text())
    assert report['hm3w_preserved'] and report['base_sha256'] == hashlib.sha256(s.before).hexdigest()
    # One existing supported recipe through exactly the same validator/serializer.
    old_recipe = json.loads((ROOT/'base/objects.json').read_text())
    result, old_output, _ = s.invoke('previous-recipe', old_recipe)
    assert result == SUCCESS
    assert b.read_map(old_output.read_bytes(),MPQArchive)[1] == b.read_map(s.before,MPQArchive)[1]
    for label, change, message in [
        ('unknown', {'field':'xxxx'}, 'unknown or disallowed field'),
        ('kind', {'kind':'ability'}, 'invalid owned object kind or id'),
        ('foreign-id', {'id':'o999'}, 'invalid owned object kind or id'),
        ('level', {'level':1}, 'invalid metadata level'),
        ('type', {'value':'0'}, 'value type does not match metadata'),
        ('nonfinite', {'value':float('inf')}, 'value type does not match metadata'),
        ('bound', {'value':-1.}, 'value outside metadata bounds'),
        ('actor', {'id':'o000'}, 'cast timing fields require controller o001')]:
        result, rejected, rejected_details = s.invoke(label, [dict(TIMING[0],**change)])
        assert result == (1,b'',('error: '+message+'\n').encode()), (label,result)
        assert not rejected.exists() and not rejected_details.exists()
    b.write_new(s.directory/'readback.json', b.json_bytes(verification))
    assert (ROOT/'base/05-owned-objects.w3x').read_bytes() == s.before
    print('PASS: controller-only typed timing fields, public rejection and preservation')


if __name__ == '__main__':
    main()
