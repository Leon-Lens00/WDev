import struct, sys
ct = [0]*0x500
seed = 0x00100001
for i in range(0x100):
    idx = i
    for j in range(5):
        seed = (seed*125+3) % 0x2AAAAB; t1 = (seed & 0xFFFF) << 16
        seed = (seed*125+3) % 0x2AAAAB; t2 = seed & 0xFFFF
        ct[idx] = t1 | t2; idx += 0x100
def h(s, t):
    s1, s2 = 0x7FED7FED, 0xEEEEEEEE
    for c in s.upper().replace('/', '\\').encode('latin-1'):
        s1 = (ct[(t<<8)+c] ^ (s1+s2)) & 0xFFFFFFFF
        s2 = (c + s1 + s2 + (s2<<5) + 3) & 0xFFFFFFFF
    return s1
def dec(data, key):
    out = []; s2 = 0xEEEEEEEE
    for i in range(0, len(data), 4):
        s2 = (s2 + ct[0x400 + (key & 0xFF)]) & 0xFFFFFFFF
        v = struct.unpack_from('<I', data, i)[0]
        r = (v ^ (key + s2)) & 0xFFFFFFFF
        out.append(r)
        key = ((~key << 0x15) + 0x11111111 | (key >> 0x0B)) & 0xFFFFFFFF
        s2 = (r + s2 + (s2 << 5) + 3) & 0xFFFFFFFF
    return out
class Mpq:
    def __init__(self, path):
        b = open(path, 'rb').read()
        o = b.find(b'MPQ\x1a')
        while o >= 0 and o % 512: o = b.find(b'MPQ\x1a', o+1)
        hs, ar, ver, bs, hpos, bpos, hn, bn = struct.unpack_from('<IIHHIIII', b, o+4)
        self.o = o
        hn &= 0xFFFFFFFF
        # protected maps often lie about sizes; clamp to file
        n = hn
        t = dec(b[o+hpos:o+hpos+16*n], h('(hash table)', 3))
        self.ht = [t[i*4:i*4+4] for i in range(n)]
        self.hn = n
    def find(self, name):
        a, b2, idx = h(name, 1), h(name, 2), h(name, 0) % self.hn
        for k in range(self.hn):
            e = self.ht[(idx+k) % self.hn]
            if e[3] == 0xFFFFFFFF: return None
            if e[0] == a and e[1] == b2: return e[3]
        return None
if __name__ == '__main__':
    m = Mpq(sys.argv[1])
    print('hash entries', m.hn)
    for n in sys.argv[2:]:
        print(n, m.find(n))
