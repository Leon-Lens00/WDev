"""Objects for v12j (Dev Mission title, 30/10/2026): the characters come from H005 of DevMission v0.96.

Tauren is 'h005' and Cairne 'h006': a lowercase rawcode makes them normal units on the 'Hmgd' base. They keep the fields of
H005 except the name, model, icon, abilities and the strings that live in the wts of v0.96. 'otau' stays for the boss bar.
Fails if an id is taken.

Usage: objetos_v12j.py V096_W3U IN_W3U OUT_W3U
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

NONE = b'\0\0\0\0'
DROP = {b'unam', b'umdl', b'uico', b'ussi', b'uabi', b'upro', b'utpr', b'uawt', b'usca'}
FIELDS = [(b'h005', b'Tauren', b'units\\orc\\Tauren\\Tauren.mdl', b'ReplaceableTextures\\CommandButtons\\BTNTauren.blp', 1.1),
          (b'h006', b'Cairne', b'units\\orc\\HeroTaurenChieftainCIN\\HeroTaurenChieftainCIN.mdl',
           b'ReplaceableTextures\\CommandButtons\\BTNHeroTaurenChieftain.blp', 1.)]

if __name__ == '__main__':
    _, source = parse(Path(sys.argv[1]).read_bytes())
    h005 = next(r for t in source for r in t if r[1] == b'H005')
    assert h005[0] == b'Hmgd', h005[0]
    keep = [m for m in h005[2] if m[0] not in DROP]
    assert not any(m[1] == 3 and m[2].startswith(b'TRIGSTR') for m in keep)
    version, tables = parse(Path(sys.argv[2]).read_bytes())
    tables[0] = [r for r in tables[0] if r[0] != b'otau']
    tables[1] = [r for r in tables[1] if r[1] != b'ocai']
    assert not {r[1] for r in tables[1]} & {f[0] for f in FIELDS}, 'id'
    for rid, name, model, icon, scale in FIELDS:
        tables[1].append((b'Hmgd', rid, keep + [(b'unam', 3, name, NONE), (b'umdl', 3, model, NONE), (b'uico', 3, icon, NONE),
                                                (b'usca', 1, struct.pack('<f', scale), NONE)]))
    # The controller mirrors the life of the character, so both need the same maximum.
    life = next(m for m in h005[2] if m[0] == b'uhpm')
    ctrl = next(r for r in tables[1] if r[1] == b'rfct')
    ctrl[2][:] = [life if m[0] == b'uhpm' else m for m in ctrl[2]]
    Path(sys.argv[3]).write_bytes(encode(version, tables))
    print('ok', len(keep) + 4, 'campos')
