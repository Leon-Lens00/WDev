#!/usr/bin/env python3
"""v16t-goku (13/11/2026): Goku de Battle Stadium D.O.N 1.8c trasplantado tal cual a Dev Mission.

Copia del script optimizado de D.O.N 1.8c las funciones de los triggers de Goku y las que alcanzan:
  za/Aa Kamehameha, gu/js Warp Kamehameha (js es el empuje compartido), Yx/Zx Super Dragon Fist,
  aa/Ba/ba Power Up (SSJ), Na/Oa/Pa Spirit Bomb, y del fin de canalización compartido Ca sólo la rama de Goku.
Renombra cada función a GkF_<nombre> y cada global a GkV_<nombre> (por fichas, fuera de cadenas y de los $hex), y
escribe los rawcodes como 'xxxx'. Cambios necesarios para Dev Mission (el resto queda igual):
  - GetHeroStatBJ(0,u,true) -> Gk_Fuerza(u): Goku es una unidad normal; fuerza de Goku 1.8c (25 +3,5 por nivel) al
    nivel de Gk_Nivel (comando -gk N).
  - WB(GetFilterUnit(),UNIT_TYPE_HERO) (a quién le tiembla la cámara) -> Gk_EsCuerpo: los personajes de los jugadores.
  - CameraSetEQNoise/CameraSetTargetNoise/CameraClearNoise -> Gk_Sacude*: el temblor lo hace la cámara lógica del mapa
    (FollowCamera), así la interfaz, que se proyecta desde esa cámara, tiembla con ella y no se desplaza.
  - Los textos flotantes pasan por Gk_TT, con 20 huecos como máximo (presupuesto de 100 texttags del mapa).
  - Je (la fuerza de todos los jugadores en D.O.N) -> bj_FORCE_ALL_PLAYERS.
Escribe también Gk_Init (sonidos, grupos, rects y tablas como en main/mC de D.O.N y los triggers con sus eventos y su
estado inicial) y la lista de rawcodes usados.
Uso: goku_trasplante.py DON18c-war3map.j SALIDA-globales.j SALIDA-funciones.j SALIDA-ids.txt
"""
from pathlib import Path
import collections, re, struct, sys

src, g_out, f_out, ids_out = sys.argv[1:5]
j = Path(src).read_bytes().decode('latin-1').replace('\r\n', '\n').replace('\r', '\n')
fn = {m.group(1): m.group(0) for m in re.finditer(r'^function (\w+) takes.*?^endfunction', j, re.M | re.S)}
orden = list(fn)
gtxt = j[:j.index('\nendglobals\n')]
decl = {}
for l in gtxt.split('\n'):
    m = re.match(r'\s*(?:constant\s+)?\w+\s+(?:array\s+)?(\w+)', l)
    if m and m.group(1) != 'globals':
        decl[m.group(1)] = l.strip()
assert 'ExecuteFunc' not in ''.join(fn.values()), 'el trasplante renombra funciones: ExecuteFunc rompería'

# triggers: eventos, condiciones, acciones (todos se crean en main en 1.8c)
trig = collections.defaultdict(lambda: {'init': []})
for l in fn['main'].split('\n'):
    m = re.match(r'(?:set (\w+)=CreateTrigger\(\)|call (?:TriggerRegister\w+|TriggerAddCondition|TriggerAddAction|DisableTrigger)\((\w+)[,)])', l)
    if m:
        trig[m.group(1) or m.group(2)]['init'].append(l)
calls = {k: {x for x in re.findall(r'\b(\w+)\b', v) if x in fn and x != k} for k, v in fn.items()}


def cierre(fs):
    out, pend = set(), list(fs)
    while pend:
        f = pend.pop()
        if f in out or f not in fn:
            continue
        out.add(f)
        pend += calls[f] - out
    return out


def accion(t, que):
    return [re.search(r'function (\w+)', l).group(1) for l in trig[t]['init'] if que in l]


TR = 'za Aa gu js Yx Zx aa Ba ba Na Oa Pa'.split()
raices = []
for t in TR:
    raices += accion(t, 'TriggerAddCondition') + accion(t, 'TriggerAddAction')
raices += ['Bz7', 'By7']  # rama de Goku del fin de canalización compartido (Ca/BA7)
funcs = cierre(raices)
assert 'main' not in funcs
cuerpo = '\n'.join(fn[k] for k in orden if k in funcs)

# rama de Goku de BA7 (Ca): hasta el primer else
ba7 = fn['BA7'].split('\n')
assert ba7[1] == 'if(Bz7())then' and ba7[11] == 'else', ba7[:12]
rama = ba7[2:11]
assert all('Ba' in x or '$B1' in x or 'By7' in x for x in rama[:1]), rama
fin_carga = 'function Gk_FinCarga takes nothing returns nothing\nif(Bz7())then\n' + '\n'.join(rama) + '\nendif\nendfunction'

texto_init_globales = []
usa = lambda t, g: re.search(r'(?<![\w$])' + re.escape(g) + r'(?![\w])', t)
glob = sorted(g for g in decl if usa(cuerpo + fin_carga, g)) + [t for t in TR if t in decl]
glob = sorted(set(glob))
sonidos = [g for g in glob if decl[g].startswith('sound ')]

# sonidos: el bloque de main de cada uno
init = []
mlines = fn['main'].split('\n')
for s in sonidos:
    i = next(k for k, l in enumerate(mlines) if l.startswith('set ' + s + '=CreateSound('))
    init.append(mlines[i])
    k = i + 1
    while k < len(mlines) and re.match(r'call \w+\(' + re.escape(s) + r'[,)]', mlines[k]):
        init.append(mlines[k]); k += 1
# grupos, rects y tablas usados (main y mC de D.O.N 1.8c)
init += ['set B[0]=CreateGroup()', 'set B[1]=CreateGroup()', 'set D[0]=CreateGroup()', 'set D[1]=CreateGroup()',
         'set y[0]=CreateGroup()', 'set y[1]=CreateGroup()', 'set T9[43]=CreateGroup()', 'set T9[120]=CreateGroup()',
         'set Vd[55]=CreateGroup()', 'set Vd[56]=CreateGroup()', 'set Y4=CreateGroup()', 'set d7=CreateGroup()',
         'set Pg=Rect(-3584.,-2784.,832.,1984.)', 'set rk=Rect(-128.,5120.,352.,5600.)',
         'set te[$B]=1747994690', 'set te[27]=1747993939', 'set Je=bj_FORCE_ALL_PLAYERS',
         'set n8[$B18]=1', 'set n8[4415]=1']
for l in ['set Pg=Rect(-3584.,-2784.,832.,1984.)', 'set rk=Rect(-128.,5120.,352.,5600.)', 'set te[$B]=1747994690',
          'set te[27]=1747993939']:
    assert l in j, l
for g in ['B', 'D', 'y', 'T9', 'Vd', 'Y4', 'd7', 'Pg', 'rk', 'te', 'Je', 'n8']:
    assert g in glob, g
for t in TR:
    init += trig[t]['init']
init.append('set Ca=CreateTrigger()')
init.append('call TriggerRegisterAnyUnitEventBJ(Ca,EVENT_PLAYER_UNIT_SPELL_ENDCAST)')
init.append('call TriggerAddAction(Ca,function Gk_FinCarga)')
glob.append('Ca')
decl['Ca'] = 'trigger Ca=null'

nombres = {f: 'GkF_' + f for f in funcs} | {g: 'GkV_' + g for g in glob}
FICHA = re.compile(r'"(?:[^"\\]|\\.)*"|\'[^\']*\'|\$[0-9A-Fa-f]+|\d+\.\d*|\.\d+|\d+|[A-Za-z_]\w*|.', re.S)


def renombrar(t):
    out = []
    for m in FICHA.finditer(t):
        s = m.group(0)
        if s[0] == '"':
            s = re.sub(r'(?i)(war3mapImported\\\\)(NewMassiveEX|NuclearExplosion)(\.md[lx])', r'\1DON_\2\3', s)
        elif s[0].isalpha() or s[0] == '_':
            s = nombres.get(s, s)
        elif s.isdigit() and len(s) == 10:
            c = struct.pack('>i', int(s)) if int(s) < 2 ** 31 else b''
            if c and re.fullmatch(rb'[A-Za-z0-9]{4}', c):
                s = "'" + c.decode() + "'"
        out.append(s)
    return ''.join(out)


f = renombrar(cuerpo + '\n' + fin_carga.replace('function Gk_FinCarga', 'function Gk_FinCarga'))
gi = renombrar('\n'.join(init))

# --- cambios para Dev Mission ---
n = len(re.findall(r'GetHeroStatBJ\(0,', f))
f = re.sub(r'GetHeroStatBJ\(0,((?:\w|\[[^\]]*\])+),true\)', r'Gk_Fuerza(\1)', f)
assert n == 9 and 'GetHeroStatBJ' not in f, n
n = f.count('GkF_WB(GetFilterUnit(),UNIT_TYPE_HERO)')
f = f.replace('GkF_WB(GetFilterUnit(),UNIT_TYPE_HERO)', 'Gk_EsCuerpo(GetFilterUnit())')
assert n >= 4 and 'UNIT_TYPE_HERO' not in f, n
for a, b in [('CameraSetEQNoiseForPlayer(', 'Gk_SacudeEQ('), ('CameraSetTargetNoiseForPlayer(', 'Gk_SacudeBlanco('),
             ('CameraClearNoiseForPlayer(', 'Gk_SacudeQuitar(')]:
    assert a in f
    f = f.replace(a, b)
TT = re.compile(r'call CreateTextTagUnitBJ\((.*),(GetEnumUnit\(\)|GkV_\w+\[[^\]]*\]),([^,()]+),([^,()]+),([^,()]+),([^,()]+),([^,()]+),([^,()]+)\)\n'
                r'call SetTextTagVelocityBJ\(bj_lastCreatedTextTag,([^,]+),(.*)\)\n'
                r'call SetTextTagPermanentBJ\(bj_lastCreatedTextTag,false\)\n'
                r'call SetTextTagLifespanBJ\(bj_lastCreatedTextTag,(.*)\)\n')
n = len(TT.findall(f))
f = TT.sub(lambda m: 'call Gk_TT(' + ','.join(m.groups()) + ')\n', f)
assert n == 4 and 'TextTag' not in f.replace('Gk_TT', ''), n
assert 'GkV_Je' in f
# Leon (13/11/2026): las habilidades de Goku no destruyen árboles. Todo daño a destructibles de Goku pasa por kb
# (enumerar destructibles en un círculo); se deja vacía y se comprueba que no queda otro camino.
n = f.count('call GkF_kb(')
f, k = re.subn(r'function GkF_kb takes real mb,location nb,code ob returns nothing\n.*?\nendfunction',
               'function GkF_kb takes real mb,location nb,code ob returns nothing\nendfunction', f, count=1, flags=re.S)
assert n == 11 and k == 1 and not re.search(r'EnumDestructables|GetSpellTargetDestructable', f), n

# rawcodes de objetos usados (unidades, habilidades, buffs) para objetos_goku.py
ids = sorted(set(re.findall(r"'([A-Za-z0-9]{4})'", f + gi)))
Path(ids_out).write_text('\n'.join(ids) + '\n')

g = []
for x in sorted(glob):
    d = decl[x]
    m = re.match(r'(\s*(?:constant\s+)?\w+\s+(?:array\s+)?)(\w+)(.*)$', d)
    ini = m.group(3)
    if re.search(r'\w+\(', ini):
        ini = ''
    g.append(m.group(1) + 'GkV_' + m.group(2) + ini)
Path(g_out).write_text('\n'.join(g) + '\n', encoding='latin-1')
Path(f_out).write_text(f + '\nfunction Gk_InitDON takes nothing returns nothing\n' + gi + '\nendfunction\n', encoding='latin-1')
print(f'goku: {len(funcs)} funciones, {len(glob)} globales, {len(sonidos)} sonidos, {len(ids)} rawcodes')
