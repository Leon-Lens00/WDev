#!/usr/bin/env python3
"""v22b (22/11/2026): Vegeta de Battle Stadium D.O.N 2.1a (H00P) trasplantado a Dev Mission (copia de nk21_trasplante.py).

Mismo método que goku21_trasplante.py y mismo prefijo G2 (los dos kits comparten en 2.1a las mismas variables udg_ con
índices distintos). Cambios respecto al de Goku:
  - EXISTENTE: el war3map.j de la versión base. Funciones, globales, triggers, sonidos y rects que ya están (Homing,
    slider, Missile[...]) no se repiten ni se vuelven a iniciar; si un trigger ya movido por Don_Motor se enciende en
    el código nuevo, se le añade su Don_Motor con el periodo que tiene en la base.
  - WAVE (motor de ondas compartido de 2.1a, 1609 líneas con ramas de muchos héroes) no se trae: v21n.py pone uno propio
    para las ondas de Freezer (Death Saucer y el polvo de la Golden Form) con las mismas variables Wave*.
  - El inicio va en G2X_InitDON (G2_InitDON Goku, G2Z_InitDON Freezer, G2Y_InitDON Trunks). Fuera también attacked4 (pasiva Ashura) y Unit_die_2 (muertes de 2.1a).
Uso: fz21_trasplante.py DON21a-war3map.j EXISTENTE.j SALIDA-glob.j SALIDA-func.j SALIDA-ids.txt SALIDA-informe.txt [REMAPEO]
"""
from pathlib import Path
import re, struct, sys

src, ex_path, g_out, f_out, ids_out, inf_out = sys.argv[1:7]
remapeo = dict(x.split('=') for x in sys.argv[7].split(',')) if len(sys.argv) > 7 and sys.argv[7] else {}
ex = Path(ex_path).read_bytes().decode('latin-1').replace('\r\n', '\n')
EXF = set(re.findall(r'^function (\w+) takes', ex, re.M))
EXG = set(re.findall(r'^\s*(?:constant\s+)?\w+\s+(?:array\s+)?(G2[VTSR]_\w+)', ex[:ex.index('\nendglobals\n')], re.M))
MOTOR = dict(re.findall(r'call Don_Motor\((G2T_\w+),([\d.]+)\)', ex))
P = 'G2'
PRIM = 'bigbang_attack galick_gun FinalFlashBasic Angry_Explosion_vegeta Saian_Bejita'.split()
FUERA = {'WAVE', 'attacked4', 'Unit_die_2'}
j = Path(src).read_bytes().decode('latin-1').replace('\r\n', '\n').replace('\r', '\n')
fn = {m.group(1): m.group(0) for m in re.finditer(r'^function (\w+) takes.*?^endfunction', j, re.M | re.S)}
orden = list(fn)
calls = {k: {x for x in re.findall(r'\b(\w+)\b', v) if x in fn and x != k} for k, v in fn.items()}
informe = []

# --- triggers por cierre ---
TR, pend = [], list(PRIM)
funcs = set()
while pend:
    t = pend.pop(0)
    if t in TR or t in FUERA:
        continue
    assert 'InitTrig_' + t in fn, t
    TR.append(t)
    sub, q = set(), ['InitTrig_' + t]
    while q:
        f = q.pop()
        if f in sub or f not in fn:
            continue
        sub.add(f)
        q += calls[f] - sub
    funcs |= sub
    pend += [u for u in re.findall(r'\bgg_trg_(\w+)', '\n'.join(fn[f] for f in sub)) if u not in TR]
assert 'main' not in funcs and 'InitGlobals' not in funcs
nf = lambda f: P + ('I_' + f[9:] if f.startswith('InitTrig_') else 'F_' + (f[5:] if f.startswith('Trig_') else f))
ya_f = {f for f in funcs if nf(f) in EXF}
TR_ya = [t for t in TR if 'G2T_' + t in EXG]
assert all(('Trig_' + t + '_Actions') in ya_f for t in TR_ya), TR_ya
informe.append(f'ya en la base: triggers {" ".join(TR_ya)}; funciones {len(ya_f)}')
funcs -= ya_f
TR_todos, TR = TR, [t for t in TR if t not in TR_ya]
cuerpo = '\n'.join(fn[k] for k in orden if k in funcs and not k.startswith('InitTrig_'))  # van dentro de InitDON
assert 'ExecuteFunc' not in cuerpo, 'el renombrado rompería ExecuteFunc'
informe.append(f'triggers ({len(TR)}): {" ".join(TR)}')
informe.append(f'funciones: {len(funcs)}')

# --- globales usadas ---
gtxt = j[:j.index('\nendglobals\n')]
decl = {}
for l in gtxt.split('\n'):
    m = re.match(r'\s*(?:constant\s+)?\w+\s+(?:array\s+)?(\w+)', l)
    if m and m.group(1) != 'globals':
        decl[m.group(1)] = l.strip()
usa = lambda t, g: re.search(r'(?<![\w$])' + re.escape(g) + r'(?![\w])', t)
glob_usa = sorted(g for g in decl if g.startswith(('udg_', 'gg_')) and (usa(cuerpo, g) or g in ['gg_trg_' + t for t in TR]))
assert all(g in decl for g in ['gg_trg_' + t for t in TR])
pre = lambda g: next(P + b + g[len(a):] for a, b in [('udg_', 'V_'), ('gg_trg_', 'T_'), ('gg_snd_', 'S_'), ('gg_rct_', 'R_')] if g.startswith(a))
glob = [g for g in glob_usa if g == 'udg_AllPlayer' or pre(g) not in EXG]
informe.append('globales ya en la base: ' + ' '.join(g for g in glob_usa if g not in glob))

# --- inicio ---
init = []
ig = fn['InitGlobals'].split('\n')[1:-1]
k = 0
while k < len(ig):
    l = ig[k]
    if l == 'loop':
        e = k
        while ig[e] != 'endloop':
            e += 1
        bloque = ig[k:e + 1]
        dentro = [x for x in bloque[2:-2] if re.match(r'set (udg_\w+)\[i\]=', x) and re.match(r'set (udg_\w+)', x).group(1) in glob]
        dentro = [x for x in dentro if x.split('=', 1)[1] not in ('0', 'false', '0.', '.0', 'null', '""')]
        if dentro:
            init += ['set i=0', bloque[1]] + dentro + ['set i=i+1', 'endloop']
            init.insert(len(init) - len(dentro) - 3, 'loop')
            informe.append('InitGlobals bucle: ' + ' / '.join(dentro))
        k = e + 1
        continue
    m = re.match(r'set (udg_\w+)(\[[^\]]*\])?=(.*)$', l)
    if m and m.group(1) in glob and m.group(3) not in ('0', 'false', '0.', '.0', 'null', '""'):
        init.append(l)
        informe.append('InitGlobals: ' + l)
    k += 1
uses_i = 'set i=0' in init
snd = fn['InitSounds'].split('\n')[1:-1]
init += [l for l in snd if (m := re.search(r'\b(gg_snd_\w+)\b', l)) and m.group(1) in glob]
reg = fn['CreateRegions'].split('\n')[1:-1]
rects = [l for l in reg if (m := re.search(r'\b(gg_rct_\w+)\b', l)) and m.group(1) in glob]
assert len([l for l in rects if '=Rect(' in l]) == len([g for g in glob if g.startswith('gg_rct_')]), rects
init += rects
# tablas de arranque que el kit lee y nunca escribe (comprobado con g2_anal.py)
TABLAS = {('Trig_Quest_Actions', 'udg_Missile', '$B'), ('Trig_Quest_Actions', 'udg_Missile', '27'),
          ('Trig_Quest_Actions', 'udg_Missile', '64'), ('Trig_Quest_Actions', 'udg_Missile', '77')}
for f_, g_, i_ in sorted(TABLAS if 'udg_Missile' in glob else ()):
    ls = [l for l in fn[f_].split('\n') if l.startswith(f'set {g_}[{i_}]=')]
    assert len(ls) == 1, (f_, g_, i_, ls)
    init.append(ls[0])
    informe.append(f'{f_}: {ls[0]}')
if usa(cuerpo, 'udg_Missile[31]') and 'udg_Missile' in glob:
    ls = [l for l in fn['Trig_final_kamehameha_vegito_Actions'].split('\n') if l.startswith('set udg_Missile[31]=')]
    assert len(set(ls)) == 1, ls
    init.append(ls[0])
    informe.append('Vegito: ' + ls[0])
if 'udg_SFLife' in glob and not any(l.startswith('set udg_SFLife=') for l in init):
    init.append('set udg_SFLife=CreateGroup()')
for t in TR:
    init += fn['InitTrig_' + t].split('\n')[1:-1]

# --- renombrado ---
nombres = {}
for f in funcs:
    if f.startswith('InitTrig_'):
        nombres[f] = P + 'I_' + f[9:]
    elif f.startswith('Trig_'):
        nombres[f] = P + 'F_' + f[5:]
    else:
        nombres[f] = P + 'F_' + f
for g in glob_usa:
    for a, b in [('udg_', 'V_'), ('gg_trg_', 'T_'), ('gg_snd_', 'S_'), ('gg_rct_', 'R_')]:
        if g.startswith(a):
            nombres[g] = P + b + g[len(a):]
            break
    else:
        raise SystemExit('global sin prefijo conocido: ' + g)
for g in glob_usa:
    nombres.setdefault(g, pre(g))
for t in TR_ya:
    nombres['gg_trg_' + t] = 'G2T_' + t
assert len(set(nombres.values())) == len(nombres)
FICHA = re.compile(r'"(?:[^"\\]|\\.)*"|\'[^\']*\'|\$[0-9A-Fa-f]+|\d+\.\d*|\.\d+|\d+|[A-Za-z_]\w*|.', re.S)


def renombrar(t):
    out = []
    for m in FICHA.finditer(t):
        s = m.group(0)
        if s[0].isalpha() or s[0] == '_':
            s = nombres.get(s, s)
        elif s.isdigit() and len(s) == 10:
            c = struct.pack('>i', int(s)) if int(s) < 2 ** 31 else b''
            if c and re.fullmatch(rb'[A-Za-z0-9]{4}', c):
                s = "'" + c.decode() + "'"
        out.append(s)
    return ''.join(out)


f = renombrar(cuerpo)
gi = renombrar('\n'.join(init))

# --- cambios para Dev Mission ---
n = len(re.findall(r'GetHeroStatBJ\(', f))
n12 = len(re.findall(r'GetHeroStatBJ\([12],', f))  # ramas de otros héroes en Homing (no se activan aquí)
f = re.sub(r'GetHeroStatBJ\([012],((?:\w|\[[^\]]*\])+),true\)', r'Gk_Fuerza(\1)', f)
assert 'GetHeroStatBJ' not in f, 'GetHeroStatBJ sin cambiar'
informe.append(f'GetHeroStatBJ -> Gk_Fuerza: {n} ({n12} de agilidad o inteligencia, en ramas ajenas de Homing)')
f, n = re.subn(r'return\(IsUnitType\(GetFilterUnit\(\),UNIT_TYPE_HERO\)\)!=null', 'return Gk_EsCuerpo(GetFilterUnit())', f)
assert 'UNIT_TYPE_HERO' not in f, [l for l in f.split('\n') if 'UNIT_TYPE_HERO' in l][:3]
informe.append(f'UNIT_TYPE_HERO -> Gk_EsCuerpo: {n}')
for a, b in [('CameraSetEQNoiseForPlayer(', 'Gk_SacudeEQ('), ('CameraSetTargetNoiseForPlayer(', 'Gk_SacudeBlanco('),
             ('CameraClearNoiseForPlayer(', 'Gk_SacudeQuitar(')]:
    informe.append(f'{a} -> {b} {f.count(a)}')
    f = f.replace(a, b)
assert not re.search(r'Camera\w*Noise', f), 'ruido de cámara sin cambiar'
TT = re.compile(r'call CreateTextTagUnitBJ\((.*),(GetEnumUnit\(\)|GetTriggerUnit\(\)|\w+V_\w+(?:\[[^\]]*\])?),([^,()]+),([^,()]+),([^,()]+),([^,()]+),([^,()]+),([^,()]+)\)\n'
                r'call SetTextTagVelocityBJ\(bj_lastCreatedTextTag,([^,]+),(.*)\)\n'
                r'call SetTextTagPermanentBJ\(bj_lastCreatedTextTag,false\)\n'
                r'call SetTextTagLifespanBJ\(bj_lastCreatedTextTag,(.*)\)\n')
n = len(TT.findall(f))
f = TT.sub(lambda m: 'call Gk_TT(' + ','.join(m.groups()) + ')\n', f)
assert 'TextTag' not in f.replace('Gk_TT', ''), [l for l in f.split('\n') if 'TextTag' in l][:3]
informe.append(f'texttags -> Gk_TT: {n}')
f, n = re.subn(r'call EnumDestructablesInCircleBJ\([^\n]*\)\n', '', f)
assert not re.search(r'EnumDestructables|GetSpellTargetDestructable', f), 'otro camino a destructibles'
informe.append(f'EnumDestructablesInCircleBJ quitadas: {n}')
f, n = re.subn(r'call SelectUnitForPlayerSingle\([^\n]*\)\n', '', f)
informe.append(f'SelectUnitForPlayerSingle quitadas: {n}')
n = f.count('G2V_AllPlayer') + gi.count('G2V_AllPlayer')
f = f.replace('G2V_AllPlayer', 'bj_FORCE_ALL_PLAYERS')
gi = '\n'.join(l for l in gi.split('\n') if not l.startswith('set G2V_AllPlayer='))
assert 'G2V_AllPlayer' not in gi
glob.remove('udg_AllPlayer')
for t in TR_ya:
    T = 'G2T_' + t
    k = f.count(f'call EnableTrigger({T})\n')
    if T in MOTOR:
        f = f.replace(f'call EnableTrigger({T})\n', f'call EnableTrigger({T})\ncall Don_Motor({T},{MOTOR[T]})\n')
    informe.append(f'{T}: {k} encendidos en el código nuevo, motor {MOTOR.get(T)}')
mis = sorted(set(re.findall(r'G2V_Missile\[([^\]]+)\]', f)))
informe.append('Missile usados: ' + ' '.join(mis))
assert set(mis) <= set(re.findall(r'set G2V_Missile\[([^\]]+)\]=', ex + gi)) | {'94'}, mis
informe.append(f'AllPlayer -> bj_FORCE_ALL_PLAYERS: {n}')
for a, b in remapeo.items():
    n = f.count(f"'{a}'") + gi.count(f"'{a}'")
    assert n, a
    f = f.replace(f"'{a}'", f"'{b}'")
    gi = gi.replace(f"'{a}'", f"'{b}'")
    informe.append(f'{a} -> {b}: {n}')
for x in ['SelectUnit', 'GetLocalPlayer', 'ClearSelection', 'SetCamera', 'PanCamera', 'SetUnitOwner', 'DialogDisplay',
          'Multiboard', 'Leaderboard', 'SetHeroLevel', 'ReplaceUnit', 'ShowInterface', 'EnableUserControl', 'KillDestructable']:
    if x in f:
        informe.append(f'REVISAR {x}: ' + ' / '.join(l for l in f.split('\n') if x in l)[:300])

ids = sorted(set(re.findall(r"'([A-Za-z0-9]{4})'", f + gi)))
Path(ids_out).write_text('\n'.join(ids) + '\n')
g = []
for x in glob:
    d = decl[x]
    m = re.match(r'(\s*(?:constant\s+)?\w+\s+(?:array\s+)?)(\w+)(.*)$', d)
    ini = m.group(3)
    if re.search(r'\w+\(', ini):
        ini = ''
    g.append(m.group(1) + nombres[x] + ini)
Path(g_out).write_text('\n'.join(g) + '\n', encoding='latin-1')
loc = 'local integer i=0\n' if uses_i else ''
Path(f_out).write_text(f + f'\nfunction {P}W_InitDON takes nothing returns nothing\n' + loc + gi + '\nendfunction\n',
                       encoding='latin-1')
modelos = sorted(set(re.findall(r'"([^"]*\.(?:md[lx]|blp|wav|mp3))"', f + gi, re.I)))
informe.append('rutas: ' + ' | '.join(modelos))
Path(inf_out).write_text('\n'.join(informe) + '\n')
print(f'{P}: {len(funcs)} funciones, {len(glob)} globales, {len(ids)} rawcodes, {len(TR)} triggers')
