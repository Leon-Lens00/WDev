"""Two Channel abilities sharing Rapid Fire's burst: Shots Vol. I and Vol. II."""
import copy
from build import cstring, integer
from rapid_objects import ability_record


def ability_records():
    result = []
    for raw, name, key, order, column, tooltip in [
        ('Arp1', 'Shots Vol. I', 'W', 'carrionswarm', 1,
         'Rafaga de 6 misiles Shots Vol. I de Vinz por color. Escala 1, radio de colision 6.'),
        ('Arp3', 'Shots Vol. II', 'R', 'breathoffire', 2,
         'Rafaga de 6 misiles Shots Vol. II de Vinz por color. Escala 1, radio de colision 18 (verde 16).')
    ]:
        rec = copy.deepcopy(ability_record())
        rec['id'] = raw.encode('ascii')
        replacements = {
            b'anam': cstring(name), b'ahky': cstring(key),
            b'atp1': cstring(f'{name} (|cffffcc00{key}|r)'),
            b'aub1': cstring(tooltip), b'Ncl6': cstring(order),
        }
        rec['mods'] = [(f,k,l,p,replacements.get(f,v),e)
                       for f,k,l,p,v,e in rec['mods']]
        rec['mods'].extend([(b'abpx',0,0,0,integer(column),b'\0'*4),
                            (b'abpy',0,0,0,integer(2),b'\0'*4)])
        result.append(rec)
    return result
