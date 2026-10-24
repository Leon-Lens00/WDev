"""Two Classic Channel abilities; no change to Rapid Fire's object contract."""
import copy
from build import cstring, integer
from rapid_objects import ability_record


def ability_records():
    result = []
    for raw, name, key, order, column, tooltip in [
        ('Ax3c', 'Buster cargado', 'W', 'carrionswarm', 1,
         'Pulso cargado recto. Colisiona con terreno, obstaculos y enemigos.'),
        ('Ax3s', 'Cross Buster', 'E', 'shockwave', 2,
         'Orbes giratorios, pulso posterior y fusion por alcance. Cuatro satelites tras la union.')
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
