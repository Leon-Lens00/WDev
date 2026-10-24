#!/usr/bin/env python3
"""Prepare only owned o000/o001/A00G records into a NEW map (no game/compiler).

--base MAP --recipe JSON --out NEW_MAP --evidence NEW_DIR
Recipe rows: kind,id,field,level,value. Types/selectors come from pinned Classic
metadata, never value-shape inference. Optional controller-only unit fields ucpt
(cast point) and ucbs (cast backswing) use metadata Unreal type and level0.
A00G UI: anam (name), ahky (one ASCII hotkey), abpx/abpy (button position),
atp1/aub1 (level-1 tooltips). Channel Ncl3 accepts only 0 (hidden) or 1 (visible).
The inherited icon is retained. --validate-only checks recipes and output guards
without reading/mutating a map or creating evidence. Only declared fields change.
Evidence and outputs must stay inside playable; existing files are never overwritten.
"""
import argparse
import copy
from io import BytesIO
import importlib.util
import json
import math
from pathlib import Path
import re
import struct
import subprocess
import sys
from mpyq import MPQArchive

ROOT = Path(__file__).resolve().parents[1]
ASSETS = Path('/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/classic-assets')
WC3 = '/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3'
spec = importlib.util.spec_from_file_location('baseline_builder', ROOT / 'tools/build.py')
b = importlib.util.module_from_spec(spec)
spec.loader.exec_module(b)
OWNED = {'o000': ('unit', 'oshm'), 'o001': ('unit', 'oshm'), 'A00G': ('ability', 'ANcl')}
FIELDS = {'unit': {'unam', 'uaen', 'uabi', 'ucpt', 'ucbs'}, 'ability': {'anam', 'ahky', 'atp1', 'aub1', 'abpx', 'abpy', 'alev', 'aher', 'acdn', 'amcs', 'aran', *('Ncl'+str(i) for i in range(1, 7))}}
TYPES = {'int':0, 'bool':0, 'attackBits':0, 'channelType':0, 'channelFlags':0,
         'real':1, 'unreal':2, 'string':3, 'char':3, 'abilityList':3, 'orderString':3}
# Pinned Classic profile declarations, not inferred from the supplied value.
UI_META = {'anam': ('Name','string',0), 'ahky': ('Hotkey','char',0),
           'atp1': ('Tip','string',3), 'aub1': ('Ubertip','string',3),
           'abpx': ('Buttonpos','int',0), 'abpy': ('Buttonpos','int',0)}


def metadata(path):
    cells, y = {}, 0
    for line in path.read_text(encoding='cp1252').splitlines():
        m = re.fullmatch(r'\s*C;X(\d+);(?:Y(\d+);)?K(.*)', line)
        if m:
            x, y = int(m[1]), int(m[2]) if m[2] else y
            v = m[3]
            cells[y, x] = v[1:-1] if v.startswith('"') else v
    heads = {x:v for (y,x),v in cells.items() if y == 1}
    rows = {}
    for (y,x), value in cells.items():
        if y > 1:
            rows.setdefault(cells[y,1], {})[heads[x]] = value
    return rows


class Reader:
    def __init__(self, data):
        self.data, self.pos = data, 0

    def take(self, n):
        value = self.data[self.pos:self.pos+n]
        if len(value) != n:
            raise ValueError('truncated object data')
        self.pos += n
        return value

    def integer(self):
        return struct.unpack('<i', self.take(4))[0]

    def count(self):
        n = self.integer()
        if n < 0 or n > len(self.data)//4:
            raise ValueError('invalid object count')
        return n


def transform(data, leveled, changes):
    """Schema walk, retaining every unrelated record/modification as original bytes."""
    r = Reader(data)
    if r.integer() != 2:
        raise ValueError('expected object version2')
    output = bytearray(data[:4])
    seen = set()
    for table in range(2):
        count = r.count()
        output.extend(struct.pack('<i', count))
        for _ in range(count):
            start = r.pos
            old, new = r.take(4), r.take(4)
            n = r.count()
            mods = []
            for _ in range(n):
                begin = r.pos
                field, typ = r.take(4).decode('ascii'), r.integer()
                level, pointer = (r.integer(), r.integer()) if leveled else (0,0)
                if typ == 3:
                    while r.take(1) != b'\0':
                        pass
                elif typ in (0,1,2):
                    r.take(4)
                else:
                    raise ValueError('unknown stored type')
                r.take(4)  # Preserve legacy end token, even if noncanonical.
                mods.append(((field,level), data[begin:r.pos]))
            ident = new.decode('ascii')
            if ident not in changes:
                output.extend(data[start:r.pos])
                continue
            if table != 1 or old.decode('ascii') != OWNED[ident][1] or ident in seen:
                raise ValueError('owned record identity mismatch')
            seen.add(ident)
            pending = dict(changes[ident])
            emitted = set()
            replaced = []
            for key, raw in mods:
                if key in changes[ident]:
                    if key in emitted:
                        raise ValueError('duplicate owned modification')
                    replaced.append(pending.pop(key))
                    emitted.add(key)
                else:
                    replaced.append(raw)
            replaced.extend(pending.values())
            output.extend(old+new+struct.pack('<i',len(replaced))+b''.join(replaced))
    if r.pos != len(data) or seen != set(changes):
        raise ValueError('trailing data or missing owned record')
    return bytes(output)


def plan(rows):
    if not isinstance(rows, list) or not rows:
        raise ValueError('invalid recipe')
    metas = {kind:metadata(ASSETS/'Units'/file) for kind,file in [('unit','UnitMetaData.slk'),('ability','AbilityMetaData.slk')]}
    result = {'unit':{}, 'ability':{}}
    for row in rows:
        if not isinstance(row, dict) or set(row) != {'kind','id','field','level','value'}:
            raise ValueError('invalid recipe')
        kind, ident, field, level, value = (row[k] for k in ('kind','id','field','level','value'))
        if not isinstance(ident,str) or ident not in OWNED or kind != OWNED[ident][0]:
            raise ValueError('invalid owned object kind or id')
        if not isinstance(field,str) or field not in FIELDS[kind]:
            raise ValueError('unknown or disallowed field')
        if field in {'ucpt', 'ucbs'} and ident != 'o001':
            raise ValueError('cast timing fields require controller o001')
        meta = metas[kind][field]
        if meta.get('useSpecific', OWNED[ident][1]) != OWNED[ident][1]:
            raise ValueError('field does not apply to base')
        if type(level) is not int or level != (1 if int(meta.get('repeat',0)) > 0 else 0):
            raise ValueError('invalid metadata level')
        if field in UI_META:
            declared = (meta['field'], meta['type'], int(meta['repeat']))
            if declared != UI_META[field] or meta['slk'] != 'Profile' or int(meta['data']) != 0:
                raise ValueError('unexpected Classic UI metadata')
        typ = TYPES[meta['type']]
        valid = type(value) is int if typ == 0 else type(value) in (int,float) if typ in (1,2) else isinstance(value,str) and '\0' not in value
        if not valid or (typ in (1,2) and not math.isfinite(value)):
            raise ValueError('value type does not match metadata')
        if meta['type'] == 'char' and (len(value) != 1 or not value.isascii() or not value.isalnum()):
            raise ValueError('hotkey must be one ASCII letter or digit')
        if meta['type'] == 'bool' and value not in (0,1) or meta['type'] == 'channelType' and value not in range(4) or meta['type'] == 'channelFlags' and value not in (0,1):
            raise ValueError('unverified enum value')
        for bound, op in [('minVal', lambda x:value<x), ('maxVal', lambda x:value>x)]:
            text = meta.get(bound,'')
            if typ != 3 and re.fullmatch(r'-?\d+(\.\d+)?', text) and op(float(text)):
                raise ValueError('value outside metadata bounds')
        payload = struct.pack('<i',value) if typ == 0 else struct.pack('<f',value) if typ in (1,2) else value.encode('utf-8')+b'\0'
        selector = int(meta.get('data',0))
        raw = field.encode('ascii')+struct.pack('<i',typ)
        if kind == 'ability':
            raw += struct.pack('<ii',level,selector)
        raw += payload+b'\0'*4
        mods = result[kind].setdefault(ident,{})
        if (field,level) in mods:
            raise ValueError('duplicate recipe field')
        mods[field,level] = raw
    return result


def internal_bytes(archive, name):
    """Decode known encrypted MPQ bookkeeping using mpyq's existing cipher/reader.

    MPQ v0 fixed-key rule and sector key schedule; decrypt does not change the
    unaligned tail. Unknown encrypted gameplay assets remain opaque/raw-checked.
    """
    entry = archive.get_hash_table_entry(name)
    block = archive.block_table[entry.block_table_index]
    archive.file.seek(archive.header['offset']+block.offset)
    data = archive.file.read(block.archived_size)
    key = archive._hash(name, 'TABLE')
    if block.flags & 0x20000:
        key = ((key+block.offset)^block.size)&0xffffffff
    def decrypt(value, k):
        return archive._decrypt(value,k&0xffffffff)+value[len(value)//4*4:]
    if block.flags & 0x10000:
        if block.flags & 0x1000000:
            data = decrypt(data,key)
        else:
            sectors = block.size//(512 << archive.header['sector_size_shift'])+1
            n = (sectors+1)*4
            table = decrypt(data[:n],key-1)
            offsets = struct.unpack('<'+'I'*(sectors+1),table)
            data = table+b''.join(decrypt(data[offsets[i]:offsets[i+1]],key+i) for i in range(sectors))
    view = copy.copy(archive)
    view.file = BytesIO(data)
    view.header = dict(archive.header, offset=0)
    view.block_table = [block._replace(offset=0,flags=block.flags & ~0x30000)]
    view.get_hash_table_entry = lambda ignored:entry._replace(block_table_index=0)
    return view.read_file(name)


def archive_inventory(archive, excluded):
    """Compare all gameplay entries, plus semantic generated MPQ bookkeeping.

    CLI saves regenerate encrypted listfile ordering and attributes CRCs. Verify
    identical name SET and all unrelated CRCs, not offset-dependent ciphertext.
    """
    internals = {'(listfile)', '(attributes)'}
    excluded_hashes = {(archive._hash(n,'HASH_A'), archive._hash(n,'HASH_B')) for n in excluded|internals}
    names = internal_bytes(archive,'(listfile)').decode('utf-8').splitlines()
    attrs = internal_bytes(archive,'(attributes)')
    version, flags = struct.unpack_from('<II',attrs)
    if (version,flags) != (100,1) or len(attrs) != 8+4*len(archive.block_table):
        raise ValueError('unsupported MPQ attributes schema')
    crcs = struct.unpack_from('<'+'I'*len(archive.block_table),attrs,8)
    result = {'listfile_names': sorted(names)}
    lookup = archive.get_hash_table_entry
    try:
        for entry in archive.hash_table:
            if entry.block_table_index >= len(archive.block_table):
                continue
            if (entry.hash_a,entry.hash_b) in excluded_hashes:
                continue
            block = archive.block_table[entry.block_table_index]
            if not block.flags & 0x80000000:
                continue
            archive.get_hash_table_entry = lambda name, e=entry:e
            try:
                value = archive.read_file('unneeded-name-for-unencrypted-block')
                mode = 'decoded'
            except (RuntimeError,NotImplementedError):
                archive.file.seek(archive.header['offset']+block.offset)
                value = archive.file.read(block.archived_size)
                mode = 'opaque'
            key = str((entry.hash_a,entry.hash_b,entry.locale,entry.platform))
            result[key] = dict(mode=mode,size=block.size,sha256=b.digest(value or b''),flags=block.flags,crc32=crcs[entry.block_table_index])
    finally:
        archive.get_hash_table_entry = lookup
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('base','recipe','out','evidence'):
        p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--validate-only', action='store_true', help='Validate recipe and output guards only; create no files and launch no tools')
    a = p.parse_args()
    try:
        for path in (a.out,a.evidence):
            if ROOT not in path.resolve().parents:
                raise ValueError('output outside owned project')
        b.guard([a.out,a.evidence],[a.base,a.recipe])
        if a.out.resolve() in a.evidence.resolve().parents or a.evidence.resolve() in a.out.resolve().parents:
            raise ValueError('overlapping outputs')
        rows = json.loads(a.recipe.read_text())
        changes = plan(rows)  # Reject every recipe error before creating output/evidence.
        if a.validate_only:
            print('validated owned object recipe')
            return 0
        before = a.base.read_bytes()
        recipe_before = a.recipe.read_bytes()
        prefix, members, original = b.read_map(before, MPQArchive)
        modified = {}
        for kind,name in [('unit','war3map.w3u'),('ability','war3map.w3a')]:
            if changes[kind]:
                modified[name] = transform(members[name],kind=='ability',changes[kind])
        inventory = archive_inventory(original,set(modified))
        a.evidence.mkdir(parents=True)
        current = a.base
        commands = []
        for i,(name,data) in enumerate(modified.items()):
            member = a.evidence/name
            b.write_new(member,data)
            staged = a.evidence/('stage-'+str(i)+'.w3x')
            argv = [WC3,'wc3ctl','file','set',str(current),name,str(member),'--out',str(staged),'--json']
            proc = subprocess.run(argv,capture_output=True,timeout=10)
            result = dict(argv=argv,exit=proc.returncode,stdout=proc.stdout.decode(),stderr=proc.stderr.decode())
            commands.append(result)
            b.write_new(a.evidence/('command-'+str(i)+'.json'),b.json_bytes(result))
            if proc.returncode:
                raise ValueError('archive tool failed; evidence retained')
            current = staged
        data = current.read_bytes()
        final = prefix+data[b.mpq_offset(data):]
        final_prefix, final_members, final_archive = b.read_map(final,MPQArchive)
        if final_prefix != prefix or final_members != dict(members,**modified) or archive_inventory(final_archive,set(modified)) != inventory:
            raise ValueError('archive preservation failed')
        if a.base.read_bytes()!=before or a.recipe.read_bytes()!=recipe_before:
            raise ValueError('input changed during preparation')
        report = dict(base_sha256=b.digest(before),out_sha256=b.digest(final),recipe=rows,
                      all_nonowned_members=inventory,hm3w_preserved=True,commands=commands,
                      metadata_sha256={str(ASSETS/'Units'/n):b.digest((ASSETS/'Units'/n).read_bytes()) for n in ('AbilityMetaData.slk','UnitMetaData.slk')})
        b.write_new(a.evidence/'preservation.json',b.json_bytes(report))
        b.write_new(a.out,final)
        print('prepared owned object base')
        return 0
    except (OSError,ValueError,KeyError,TypeError,struct.error,subprocess.TimeoutExpired) as exc:
        print('error: '+str(exc),file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
