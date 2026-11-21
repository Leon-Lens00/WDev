"""Lector mínimo de VPK v2 de un solo archivo (datos en el propio .vpk). Uso: vpk2.py VPK list | VPK extract SALIDA EXT,EXT"""
import struct, sys, os
f = open(sys.argv[1], 'rb')
sig, ver, tree = struct.unpack('<III', f.read(12))
assert sig == 0x55aa1234, hex(sig)
hdr = 28 if ver == 2 else 12
f.seek(hdr); t = f.read(tree)
def cstr(p):
    e = t.index(b'\0', p); return t[p:e].decode('utf-8', 'replace'), e + 1
p = 0; out = []
while True:
    ext, p = cstr(p)
    if not ext: break
    while True:
        path, p = cstr(p)
        if not path: break
        while True:
            name, p = cstr(p)
            if not name: break
            crc, pre, arc, off, ln, term = struct.unpack('<IHHIIH', t[p:p + 18]); p += 18
            pdata = t[p:p + pre]; p += pre
            full = (path.strip() + '/' if path.strip() else '') + name + '.' + ext
            out.append((full, arc, off, ln, pdata))
if sys.argv[2] == 'list':
    for full, arc, off, ln, pd in out: print(ln + len(pd), arc, full)
else:
    dst, exts = sys.argv[3], tuple('.' + e for e in sys.argv[4].split(','))
    for full, arc, off, ln, pd in out:
        if not full.endswith(exts): continue
        assert arc == 0x7fff, full
        f.seek(hdr + tree + off); data = pd + f.read(ln)
        o = os.path.normpath(os.path.join(dst, full)); assert o.startswith(os.path.normpath(dst))
        os.makedirs(os.path.dirname(o), exist_ok=True); open(o, 'wb').write(data)
