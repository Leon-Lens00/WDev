"""Extrae entradas de un VPK de varios archivos (pak01_dir + pak01_NNN). Uso: vpkmulti.py DIR.vpk SALIDA ruta [ruta...]"""
import struct, sys, os
d = sys.argv[1]; f = open(d, 'rb')
sig, ver, tree = struct.unpack('<III', f.read(12)); assert sig == 0x55aa1234
hdr = 28 if ver == 2 else 12
f.seek(hdr); t = f.read(tree)
def cstr(p):
    e = t.index(b'\0', p); return t[p:e].decode('utf-8', 'replace'), e + 1
want = set(sys.argv[3:]); p = 0
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
            pd = t[p:p + pre]; p += pre
            full = path.strip() + '/' + name + '.' + ext
            if full in want:
                g = open(d.replace('_dir.vpk', '_%03d.vpk' % arc), 'rb') if arc != 0x7fff else f
                g.seek(off if arc != 0x7fff else hdr + tree + off); data = pd + g.read(ln)
                o = os.path.join(sys.argv[2], os.path.basename(full)); open(o, 'wb').write(data); print(full, len(data))
