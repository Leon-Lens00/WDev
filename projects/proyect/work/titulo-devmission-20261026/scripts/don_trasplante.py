#!/usr/bin/env python3
"""Trasplante fiel del código DBZ de Battle Stadium D.O.N 2.1a (Valkemiere) a Dev Mission (v16t-don).

Copia los triggers de la familia DBZ (don_familia.py) tal cual, con estos renombres para no chocar con el mapa:
  Trig_X / InitTrig_X -> DonF_X / DonI_X,  gg_trg_X -> DonT_X,  udg_V -> DonV_V,  gg_snd_S -> DonS_S,  gg_rct_R -> DonR_R
y los rawcodes escritos como entero (unidades, habilidades, buffs) por la tabla de objetos_don.py, escritos como
'xxxx'. Genera también Don_Init (vía ExecuteFunc): inicializa las variables usadas como en InitGlobals de DON, los
sonidos como en InitSounds, las regiones como en CreateRegions, las tablas de Trig_Quest_Actions y llama a cada DonI_.
El movimiento sigue siendo el de DON en esta etapa; el cambio a Missile se hace por personaje después.
Uso: don_trasplante.py EXTRAIDO_DON rawcodes-fase1.txt IDS-objetos_don.txt SALIDA-globales.j SALIDA-funciones.j
"""
from pathlib import Path
import re, struct, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import don_familia

E, fase1, ids_path, g_out, f_out = sys.argv[1:6]
E = Path(E)
fam = don_familia.cargar(str(E / 'j.j'), fase1)
j = fam['j']
MAP = dict(l.split() for l in open(ids_path))
NUM = {str(struct.unpack('>i', k.encode())[0]): v for k, v in MAP.items()}


def renombrar(t):
    t = re.sub(r'\bInitTrig_(\w+)', r'DonI_\1', t)
    t = re.sub(r'\bTrig_(\w+)', r'DonF_\1', t)
    t = re.sub(r'\bgg_trg_(\w+)', r'DonT_\1', t)
    t = re.sub(r'\bgg_snd_(\w+)', r'DonS_\1', t)
    t = re.sub(r'\bgg_rct_(\w+)', r'DonR_\1', t)
    t = re.sub(r'\budg_(\w+)', r'DonV_\1', t)
    # rawcodes: sólo enteros que son ids de la tabla; fuera de cadenas
    partes = re.split(r'("(?:[^"\\]|\\.)*")', t)
    for i in range(0, len(partes), 2):
        partes[i] = re.sub(r'(?<![\w$.])(1[0-9]{9})(?![\w.])',
                           lambda m: "'" + NUM[m.group(1)] + "'" if m.group(1) in NUM else m.group(1), partes[i])
    return ''.join(partes)


def limpio(t):
    return re.sub(r'\n\s*\n', '\n', t.replace('\r\n', '\n'))


cuerpo = ''.join(fam['fn'][k] + '\n' for k in fam['funcs'])
usa_v = set(re.findall(r'\budg_(\w+)', cuerpo + '\n'.join(fam['tablas'])))
usa_s = set(re.findall(r'\bgg_snd_(\w+)', cuerpo))
usa_r = set(re.findall(r'\bgg_rct_(\w+)', cuerpo))

# --- globales ---
g = j[j.index('globals') + 7:j.index('endglobals')]
dec = []
for l in g.splitlines():
    m = re.match(r'\s*(?:constant\s+)?(\w+)\s+(array\s+)?udg_(\w+)\s*(=.*)?$', l)
    if m and m.group(3) in usa_v:
        ini = m.group(4) or ''
        if ini and re.search(r'\w+\(', ini):
            ini = ''  # una llamada no puede ir en la declaración de un mapa grande; se repite en Don_Init
        dec.append(f'{m.group(1)} {m.group(2) or ""}DonV_{m.group(3)}{" " + ini if ini else ""}'.replace('  ', ' '))
faltan = usa_v - {re.search(r'DonV_(\w+)', x).group(1) for x in dec}
assert not faltan, faltan
dec += [f'trigger DonT_{t} = null' for t in fam['todo']]
dec += [f'sound DonS_{s} = null' for s in sorted(usa_s)]
dec += [f'rect DonR_{r} = null' for r in sorted(usa_r)]

# --- InitGlobals: sólo lo de las variables usadas, respetando los bucles ---
ig = limpio(re.search(r'^function InitGlobals takes.*?^endfunction', j, re.M | re.S).group(0)).splitlines()[1:-1]
init_g, bloque, en_bucle = [], [], False
for l in ig:
    s = l.strip()
    if s == 'loop':
        en_bucle, bloque = True, [l]
    elif s == 'endloop':
        bloque.append(l)
        if any(re.search(r'\budg_(\w+)', x) for x in bloque):
            init_g += bloque
        en_bucle = False
    elif en_bucle:
        m = re.search(r'set udg_(\w+)', s)
        if not m or m.group(1) in usa_v:
            bloque.append(l)
    else:
        m = re.search(r'set udg_(\w+)', s)
        if s.startswith('local') or s == 'set i=0' or (m and m.group(1) in usa_v):
            init_g.append(l)
# bucles que sólo conservan su contador no hacen falta
init_txt = '\n'.join(init_g)
init_txt = re.sub(r'loop\nexitwhen\(i>[^\n]*\)\nset i=i\+1\nendloop\n?', '', init_txt)

# --- InitSounds y CreateRegions ---
snd = limpio(re.search(r'^function InitSounds takes.*?^endfunction', j, re.M | re.S).group(0)).splitlines()[1:-1]
init_s = [l for l in snd if (m := re.search(r'gg_snd_(\w+)\b', l)) and m.group(1) in usa_s]
reg = limpio(re.search(r'^function CreateRegions takes.*?^endfunction', j, re.M | re.S).group(0)).splitlines()[1:-1]
init_r = [l for l in reg if (m := re.search(r'gg_rct_(\w+)\b', l)) and m.group(1) in usa_r]
assert len([l for l in init_r if '=Rect(' in l]) == len(usa_r), init_r

out = ['// Trasplante fiel de Battle Stadium D.O.N 2.1a (Valkemiere): familia DBZ, generado por don_trasplante.py.',
       f'// {len(fam["todo"])} triggers, {len(fam["funcs"])} funciones. No editar a mano: regenerar.']
for k in fam['funcs']:
    out.append(renombrar(limpio(fam['fn'][k])))
init = ['function Don_Init takes nothing returns nothing']
loc = [l for l in init_txt.splitlines() if l.strip().startswith('local')]
init += loc
init += [l for l in init_txt.splitlines() if not l.strip().startswith('local')]
init += init_s + init_r
init += [l for l in fam['tablas']]
init += [f'call InitTrig_{t}()' for t in fam['todo']]
init.append('endfunction')
out.append(renombrar('\n'.join(init)))
Path(g_out).write_text('\n'.join(dec) + '\n', encoding='latin-1')
Path(f_out).write_text('\n'.join(out) + '\n', encoding='latin-1')
print('globales', len(dec), 'funciones', len(fam['funcs']), 'sonidos', len(usa_s), 'regiones', len(usa_r),
      'lineas', sum(x.count('\n') + 1 for x in out))
