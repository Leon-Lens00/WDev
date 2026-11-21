import sys,struct,collections,json; sys.path.insert(0,'.')
from w3b_titulo import parse
P='''h002 h00A h00E h00F h00G h00H h00J h00M h00T h00V h01B h01E h01J h01M h01N h01R h01S h01T h02G h02J h039 h03A
h03I h03L h03M h04N h052 h054 h056 h05B h05E h05F h05H h05J h05X h061 h064 h065 h06E h06F h06G h070 h07B h07D h07H h07I
h080 h087 h08L h091 h092 h09N h09P h09T h0A4 h0A5 h0A7 h0BB h0BI h0BO h0CA h0CB h0CH h0CI h0D2 h0D3 h0DH h0DI h0DL
h0DM h0DN h0E2 h0EN h0ES h0ET h0EV h0EY h0F3 h0FB h0FI h0FW h0G1 h0GB h0GE h0GF h0GG h0GH h0GY h0H0 h0H1 h0H2 h0HH'''.split()
rows={};cur=None
for l in open(sys.argv[2],encoding='latin-1'):
    p=l.rstrip('\n').split(';')
    if p[0]!='C':continue
    x=k=None
    for f in p[1:]:
        if f[:1]=='X':x=int(f[1:])
        elif f[:1]=='Y':cur=int(f[1:])
        elif f[:1]=='K':k=f[1:]
    if k is not None: rows.setdefault(cur,{})[x]=k.strip('"')
ci={v:k for k,v in rows[1].items()}
slk={r.get(1):(r.get(ci['death']), r.get(ci['deathType'])) for y,r in rows.items() if y!=1}
v,t=parse(open(sys.argv[1],'rb').read())
info={}
for tab in t:
  for base,rid,mods in tab:
    r=rid.decode('latin-1')
    if r in P:
      d={m[0]:m for m in mods}
      b=base.decode()
      dt=struct.unpack('<f',d[b'udtm'][2])[0] if b'udtm' in d else float(slk[b][0])
      dty=struct.unpack('<i',d[b'udea'][2])[0] if b'udea' in d else int(slk[b][1])
      info[r]=(b,round(dt,2),dty)
assert set(info)==set(P),set(P)-set(info)
print(collections.Counter(info.values()))
json.dump(info,open(sys.argv[3],'w'))
