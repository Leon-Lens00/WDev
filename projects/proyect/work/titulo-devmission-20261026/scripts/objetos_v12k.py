"""Objects for v12k (Dev Mission title, 30/10/2026): SilenceEx method to hide the controller's move buttons.

Copies from DevMission v0.96 what SILENCE_TESTUNIT_AMOV needs: 'Amov' with mana cost 1, 'AS00' Soul Burn, 'AS01' Mana Flare,
'IS00' powerup and 'HDHD' channel with order smart. The strings of 'HDHD' live in the wts of v0.96, so its name becomes plain
text and its tooltips go away (it is hidden). Fails if an id is taken.

Usage: objetos_v12k.py V096_W3A V096_W3T IN_W3A OUT_W3A IN_W3T OUT_W3T IN_W3U OUT_W3U
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode

NONE = b'\0\0\0\0'
ABILITIES = [b'Amov', b'AS00', b'AS01', b'HDHD']
TOOLTIPS = {b'aub1', b'atp1'}
SIGHT = 300


def parse_w3a(b):
    """Same layout as parse, with the level and data columns of ability files."""
    i, tables = 4, []
    for _ in range(2):
        n = struct.unpack_from('<I', b, i)[0]; i += 4
        rows = []
        for _ in range(n):
            base, new = b[i:i + 4], b[i + 4:i + 8]; i += 8
            m = struct.unpack_from('<I', b, i)[0]; i += 4
            mods = []
            for _ in range(m):
                mid, ty, level, data = b[i:i + 4], *struct.unpack_from('<III', b, i + 4); i += 16
                if ty == 3:
                    j = b.index(b'\0', i); v = b[i:j]; i = j + 1
                else:
                    v = b[i:i + 4]; i += 4
                mods.append((mid, ty, level, data, v, b[i:i + 4])); i += 4
            rows.append((base, new, mods))
        tables.append(rows)
    assert i == len(b), (i, len(b))
    return struct.unpack_from('<I', b, 0)[0], tables


def encode_w3a(version, tables):
    out = [struct.pack('<I', version)]
    for rows in tables:
        out.append(struct.pack('<I', len(rows)))
        for base, new, mods in rows:
            out.append(base + new + struct.pack('<I', len(mods)))
            for mid, ty, level, data, v, end in mods:
                out.append(mid + struct.pack('<III', ty, level, data) + (v + b'\0' if ty == 3 else v) + end)
    return b''.join(out)


def row_id(r):
    return r[1] if r[1] != NONE else r[0]


if __name__ == '__main__':
    a096, t096, a_in, a_out, t_in, t_out, u_in, u_out = sys.argv[1:9]
    _, source = parse_w3a(Path(a096).read_bytes())
    version, tables = parse_w3a(Path(a_in).read_bytes())
    assert not {row_id(r) for t in tables for r in t} & set(ABILITIES), 'id'
    for n, rows in enumerate(source):
        for base, new, mods in rows:
            if row_id((base, new)) not in ABILITIES:
                continue
            if new == b'HDHD':
                assert all(m[0] in TOOLTIPS or m[0] == b'anam' or not m[4].startswith(b'TRIGSTR') for m in mods)
                mods = [(m[0], m[1], m[2], m[3], b'Smart Hide', m[5]) if m[0] == b'anam' else m for m in mods if m[0] not in TOOLTIPS]
            tables[n].append((base, new, mods))
    assert sum(1 for t in tables for r in t if row_id(r) in ABILITIES) == 4
    Path(a_out).write_bytes(encode_w3a(version, tables))

    _, items = parse(Path(t096).read_bytes())
    version, tables = parse(Path(t_in).read_bytes())
    assert not any(r[1] == b'IS00' for t in tables for r in t), 'IS00'
    tables[1].append(next(r for t in items for r in t if r[1] == b'IS00'))
    Path(t_out).write_bytes(encode(version, tables))

    # The dummy and the controller must see each other, and 'rfct' had no sight.
    version, tables = parse(Path(u_in).read_bytes())
    ctrl = next(r for r in tables[1] if r[1] == b'rfct')
    sight = struct.pack('<i', SIGHT)
    ctrl[2][:] = [(m[0], m[1], sight, m[3]) if m[0] in (b'usid', b'usin') else m for m in ctrl[2]]
    Path(u_out).write_bytes(encode(version, tables))
    print('ok')
