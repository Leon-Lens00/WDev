"""Classic v2 ability encoding and reproducible local Rapid Fire objects."""
import struct
from build import Reader, integer, cstring, encode_units, set_field


def encode_abilities(tables):
    return integer(2)+b''.join(integer(len(t))+b''.join(
        r['base']+r['id']+integer(len(r['mods']))+b''.join(
            f+integer(k)+integer(l)+integer(p)+v+e for f,k,l,p,v,e in r['mods'])
        for r in t) for t in tables)


def abilities(data):
    r = Reader(data)
    assert r.int() == 2
    tables = []
    for _ in range(2):
        records = []
        for _ in range(r.int()):
            begin = r.pos
            base, new, count = r.take(4), r.take(4), r.int()
            mods = []
            for _ in range(count):
                field, kind, level, pointer = r.take(4), r.int(), r.int(), r.int()
                assert kind in (0,1,2,3)
                value = r.string() if kind == 3 else r.take(4)
                mods.append((field,kind,level,pointer,value,r.take(4)))
            records.append(dict(base=base,id=new,mods=mods,raw=data[begin:r.pos]))
        tables.append(records)
    assert r.pos == len(data) and encode_abilities(tables) == data
    return tables


def unit(rawid, base, fields):
    r = dict(id=rawid.encode(),base=base.encode(),mods=[])
    for field,kind,value in fields:
        set_field(r,field,kind,value)
    return r


def unit_records():
    common = [('uaen',0,0),('uacq',2,0.),('ufle',0,0),('uhpm',0,800),
              ('ucpt',2,0.),('ucbs',2,0.),('uabi',3,''),('ufoo',0,0)]
    return [
        unit('rfex','hrif',common+[('unam',3,'Rapid Fire - Ejecutor'),
             ('umvs',0,350),('ucol',2,24.),('usnd',3,'Rifleman')]),
        unit('rfct','hrif',common+[('unam',3,'Rapid Fire - Controlador (Q)'),
             ('uabi',3,'Arpf,Avul'),('umvs',0,350),('ucol',2,0.),
             ('usid',0,0),('usin',0,0),('uhom',0,1)]),
        unit('rftg','hfoo',common+[('unam',3,'Blanco de prueba'),('uhpm',0,2000),
             ('umvs',0,0),('uabi',3,''),('ucol',2,24.)])]


def ability_record():
    r = dict(base=b'ANcl',id=b'Arpf',mods=[])
    fields = [
        ('anam',3,0,0,'Rapid Fire'),('aher',0,0,0,0),('alev',0,0,0,1),
        ('ahky',3,0,0,'Q'),('aart',3,0,0,'ReplaceableTextures\\CommandButtons\\BTNFireBolt.blp'),
        ('atp1',3,1,0,'Rapid Fire (|cffffcc00Q|r)'),
        ('aub1',3,1,0,'Dispara 6 misiles. Recast repone 6 sin reiniciar el intervalo de 0.25 s. Permite movimiento durante la rafaga.'),
        ('aran',2,1,0,90000.),('acdn',2,1,0,0.),('amcs',0,1,0,0),('acas',2,1,0,0.),
        ('Ncl1',2,1,1,0.),('Ncl2',0,1,2,2),('Ncl3',0,1,3,1),
        ('Ncl4',2,1,4,0.),('Ncl5',0,1,5,0),('Ncl6',3,1,6,'channel')]
    for f,k,l,p,v in fields:
        value = cstring(v) if k == 3 else integer(v) if k == 0 else struct.pack('<f',v)
        r['mods'].append((f.encode(),k,l,p,value,b'\0'*4))
    return r
