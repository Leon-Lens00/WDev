import struct,sys,json
m=open('/home/snz/Descargas/PC_PVZ-Fusion-4.1/PlantsVsZombiesRH_Data/il2cpp_data/Metadata/global-metadata.dat','rb').read()
h=struct.unpack_from('<'+'I'*64,m,0)
P=lambda i:(h[2+2*i],h[3+2*i])
so,ss=P(2)
def S(i):
    e=m.index(b'\0',so+i); return m[so+i:e].decode('utf-8','replace')
to,ts=P(19); fo,fs=P(11)
print('typedef size check',ts%88,ts//88, 'fields',fs%12)
types=[]
for k in range(ts//88):
    v=struct.unpack_from('<16i8H2I',m,to+88*k)
    types.append(v)
def fields(v):
    out=[]
    for j in range(v[18]):
        n,t,tok=struct.unpack_from('<iiI',m,fo+12*(v[8]+j)); out.append(S(n))
    return out
want=sys.argv[1:]
for v in types:
    nm=S(v[0])
    if any(w==nm for w in want):
        print('==',S(v[1]),nm,'fields',v[18],'methods',v[16]); print(' | '.join(fields(v)))
mo,ms=P(5)
if '-m' in sys.argv:
  for v in types:
    if S(v[0]) in want:
        print('MET',S(v[0]),' | '.join(S(struct.unpack_from('<i',m,mo+36*(v[9]+j))[0]) for j in range(v[16])))
