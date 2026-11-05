"""Objects for v12i (Dev Mission title, 30/10/2026): RapidFire controller, its three abilities and its models.

'rfct' and Arpf, Arp1, Arp3 come from TerrainDev (rapid_objects.py, shots_objects.py; abilities as docs/importar-rapid-fire.md
lists them). Imports keep the internal paths of each manifest. Fails if an id or path is already used, or a file does not
match its manifest.

Usage: objetos_v12i.py IN_W3U OUT_W3U IN_W3A OUT_W3A IN_IMP OUT_IMP LIST_OUT
"""
from pathlib import Path
import hashlib
import json
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

TD = Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev')
sys.path.insert(0, str(TD / 'scripts'))
from rapid_objects import abilities, ability_record, encode_abilities
from shots_objects import ability_records

NONE = b'\0\0\0\0'
real = lambda v: struct.pack('<f', v)
num = lambda v: struct.pack('<i', v)
CONTROLLER = [(b'unam', 3, b'Personaje', NONE), (b'uabi', 3, b'Arpf,Arp1,Arp3,Avul', NONE), (b'uaen', 0, num(0), NONE),
              (b'uacq', 2, real(0.), NONE), (b'ufle', 0, num(0), NONE), (b'uhpm', 0, num(800), NONE),
              (b'ucpt', 2, real(0.), NONE), (b'ucbs', 2, real(0.), NONE), (b'ufoo', 0, num(0), NONE),
              (b'umvs', 0, num(350), NONE), (b'ucol', 2, real(0.), NONE), (b'usid', 0, num(0), NONE),
              (b'usin', 0, num(0), NONE), (b'uhom', 0, num(1), NONE)]
NO_FLEE = (b'ufle', 0, num(0), NONE)
GROUPS = ['firebrand-shots', 'shots-ajustados', 'windwalk-colores']

if __name__ == '__main__':
    src = Path(sys.argv[1]).read_bytes()
    version, tables = parse(src)
    assert encode(version, tables) == src, 'round trip differs'
    assert not any(r[1] == b'rfct' for t in tables for r in t), 'rfct'
    tables[1].append((b'hrif', b'rfct', CONTROLLER))
    # Without a weapon the characters would run from whoever hits them.
    assert not any(r[0] == b'otau' for r in tables[0]), 'otau'
    tables[0].append((b'otau', NONE, [NO_FLEE]))
    row = next(r for r in tables[1] if r[1] == b'ocai')
    assert not any(m[0] == b'ufle' for m in row[2]), 'ocai'
    row[2].append(NO_FLEE)
    Path(sys.argv[2]).write_bytes(encode(version, tables))

    src = Path(sys.argv[3]).read_bytes()
    groups = abilities(src)
    new = [ability_record()] + ability_records()
    assert not {r['id'] for t in groups for r in t} & {r['id'] for r in new}, 'ability id'
    groups[1].extend(new)
    Path(sys.argv[4]).write_bytes(encode_abilities(groups))

    imp = Path(sys.argv[5]).read_bytes()
    iv, n = struct.unpack_from('<II', imp, 0)
    assert iv == 1
    i, names = 8, set()
    for _ in range(n):
        j = imp.index(b'\0', i + 1)
        names.add(imp[i + 1:j].decode('utf-8').lower())
        i = j + 1
    assert i == len(imp)
    files, extra = [], b''
    for g in GROUPS:
        for e in json.loads((TD / 'assets' / g / 'manifest.json').read_text())['imports']:
            p = TD / 'assets' / e['file']
            assert hashlib.sha256(p.read_bytes()).hexdigest() == e['sha256'], e['file']
            if p.suffix == '.blp':
                w, h = struct.unpack_from('<II', p.read_bytes(), 12)
                assert w == h or (w & (w - 1) == 0 and h & (h - 1) == 0), e['file']
                assert max(w, h) <= 512 and w & (w - 1) == 0 and h & (h - 1) == 0, (e['file'], w, h)
            assert e['internal'].lower() not in names, e['internal']
            names.add(e['internal'].lower())
            extra += bytes([13]) + e['internal'].encode() + b'\0'
            files.append([e['internal'], str(p)])
    Path(sys.argv[6]).write_bytes(struct.pack('<II', 1, n + len(files)) + imp[8:] + extra)
    Path(sys.argv[7]).write_text(json.dumps(files))
    print('ok', len(new), 'habilidades', len(files), 'archivos')
