#!/usr/bin/env python3
"""v16u (13/11/2026): trasplante genérico de un héroe de Battle Stadium D.O.N 1.8c a Dev Mission.

Generaliza goku_trasplante.py (no confundir con don_trasplante.py, el trasplante de v16t-don) (método en skills/claude/mapa-dev-mission/references/importar-heroes-don.md):
  - triggers: los principales del héroe (los que reaccionan a sus habilidades) y, por cierre, todos los que estos
    encienden, apagan, ejecutan o consultan; las funciones que alcanzan sus condiciones y acciones;
  - fin de canalización compartido (Ca/BA7): sólo las ramas que apagan un trigger del héroe;
  - inicio: sonidos de main; de main y de los triggers de arranque (mC, Pq, LB) las asignaciones de las globales que
    usa el héroe; los grupos de bucle sólo en los índices constantes que usa (o el bucle entero si usa uno variable);
  - renombrado por fichas a <P>F_/<P>V_ fuera de cadenas y $hex; rawcodes de 10 cifras a 'xxxx'.
Cambios para Dev Mission, cada uno comprobado (no queda el original):
  - GetHeroStatBJ(k,u,true) -> <P>_Stat(k): el personaje es una unidad normal; atributos del héroe al nivel Gk_Nivel;
  - IsUnitType(..., UNIT_TYPE_HERO) por WB -> Gk_EsCuerpo(...): los personajes de los jugadores;
  - ruido de cámara -> Gk_Sacude*; textos flotantes -> Gk_TT (anillo de 20); Je -> bj_FORCE_ALL_PLAYERS;
  - kb (destructibles en círculo) vacía: no tala árboles (Leon, 13/11).
  - SelectUnitForPlayerSingle fuera: seleccionaría el cuerpo y el jugador manda con el controlador;
  - ids de unidad del héroe en condiciones -> filas de Dev Mission (REMAPEO "H01A=hNar,H0D9=hNaK").
Uso: don_heroe.py DON.j PREFIJO "TRIGGERS" SALIDA-glob.j SALIDA-func.j SALIDA-ids.txt [SALIDA-informe.txt [REMAPEO]]
"""
from pathlib import Path
import collections, re, struct, sys

src, P, prim, g_out, f_out, ids_out = sys.argv[1:7]
inf_out = sys.argv[7] if len(sys.argv) > 7 else None
remapeo = dict(x.split('=') for x in sys.argv[8].split(',')) if len(sys.argv) > 8 and sys.argv[8] else {}
prim = prim.split()
j = Path(src).read_bytes().decode('latin-1').replace('\r\n', '\n').replace('\r', '\n')
fn = {m.group(1): m.group(0) for m in re.finditer(r'^function (\w+) takes.*?^endfunction', j, re.M | re.S)}
orden = list(fn)
gtxt = j[:j.index('\nendglobals\n')]
decl = {}
for l in gtxt.split('\n'):
    m = re.match(r'\s*(?:constant\s+)?\w+\s+(?:array\s+)?(\w+)', l)
    if m and m.group(1) != 'globals':
        decl[m.group(1)] = l.strip()
informe = []

trig = collections.defaultdict(list)
for l in fn['main'].split('\n'):
    m = re.match(r'(?:set (\w+)=CreateTrigger\(\)|call (?:TriggerRegister\w+|TriggerAddCondition|TriggerAddAction|DisableTrigger)\((\w+)[,)])', l)
    if m:
        trig[m.group(1) or m.group(2)].append(l)
calls = {k: {x for x in re.findall(r'\b(\w+)\b', v) if x in fn and x != k} for k, v in fn.items()}
fun = lambda l: re.findall(r'function (\w+)', l)


def cierre(fs):
    out, pend = set(), list(fs)
    while pend:
        f = pend.pop()
        if f in out or f not in fn:
            continue
        out.add(f)
        pend += calls[f] - out
    return out


TR, pend = [], list(prim)
while pend:
    t = pend.pop(0)
    if t in TR:
        continue
    assert t in trig, t
    TR.append(t)
    body = '\n'.join(fn[f] for f in cierre([f for l in trig[t] for f in fun(l)]))
    pend += [u for u in re.findall(r'(?:EnableTrigger|DisableTrigger|TriggerExecute|TriggerEvaluate|IsTriggerEnabled)\((\w+)\)', body)
             if u in trig and u != 'Ca']
raices = [f for t in TR for l in trig[t] for f in fun(l)]

# --- fin de canalización compartido: ramas de BA7 que apagan un trigger del héroe ---
ba7 = fn['BA7'].split('\n')[1:-1]
ramas, i = [], 0
while i < len(ba7):
    m = re.match(r'if\((\w+)\(\)\)then$', ba7[i])
    if m:
        k = i + 1
        while not (ba7[k] == 'else' or ba7[k] == 'endif'):
            k += 1
        ramas.append((m.group(1), ba7[i + 1:k]))
        i = k
    i += 1
assert len(ramas) == 8, len(ramas)
mias = [(c, b) for c, b in ramas if re.match(r'call DisableTrigger\((\w+)\)', b[0]).group(1) in TR]
fin_carga = ''
if mias:
    fin_carga = 'function Don_FinCarga takes nothing returns nothing\n' + ''.join(
        f'if({c}())then\n' + '\n'.join(b) + '\nendif\n' for c, b in mias) + 'endfunction'
    for c, b in mias:
        raices += [c] + [x for x in re.findall(r'\b(\w+)\b', '\n'.join(b)) if x in fn]
funcs = cierre(raices)
assert 'main' not in funcs and 'BA7' not in funcs
cuerpo = '\n'.join(fn[k] for k in orden if k in funcs)
assert 'ExecuteFunc' not in cuerpo, 'el renombrado rompería ExecuteFunc'
informe.append(f'triggers {" ".join(TR)}; fin de canalización: {" ".join(c for c, _ in mias) or "-"}')

usa = lambda t, g: re.search(r'(?<![\w$])' + re.escape(g) + r'(?![\w])', t)
todo = cuerpo + '\n' + fin_carga
glob = sorted(set([g for g in decl if usa(todo, g)] + [t for t in TR if t in decl]))
sonidos = [g for g in glob if decl[g].startswith('sound ')]

init = []
mlines = fn['main'].split('\n')
for s in sonidos:
    i = next(k for k, l in enumerate(mlines) if l.startswith('set ' + s + '=CreateSound('))
    init.append(mlines[i])
    k = i + 1
    while k < len(mlines) and re.match(r'call \w+\(' + re.escape(s) + r'[,)]', mlines[k]):
        init.append(mlines[k]); k += 1

CONST = r'(?:\$[0-9A-Fa-f]+|\d+)'


def indices(g):
    """Índices con los que el héroe usa la global g: lista de constantes, o None si usa alguno variable."""
    out = []
    for m in re.finditer(r'(?<![\w$])' + re.escape(g) + r'\[([^\[\]]*(?:\[[^\]]*\][^\[\]]*)*)\]', todo):
        x = m.group(1)
        if not re.fullmatch(CONST, x):
            return None
        out.append(x)
    return sorted(set(out), key=lambda v: int(v[1:], 16) if v[0] == '$' else int(v))


arranque = ['main'] + [x for t in ('Up', 'Pq', 'LB') for l in trig[t] if 'TriggerAddAction' in l for x in fun(l)]
assert 'mC' in arranque, arranque
for f in arranque:
    L = fn[f].split('\n')
    k = 0
    while k < len(L):
        l = L[k]
        if l == 'loop' and k + 1 < len(L) and re.match(r'exitwhen\(i>(' + CONST + r')\)$', L[k + 1]):
            fin = re.match(r'exitwhen\(i>(' + CONST + r')\)$', L[k + 1]).group(1)
            e = k + 2
            while L[e] != 'endloop':
                e += 1
            for x in L[k + 2:e]:
                m = re.match(r'set (\w+)\[i\]=(.*)$', x)
                if m and m.group(1) in glob and m.group(1) not in TR:
                    g, v = m.groups()
                    if v in ('0', 'false', '0.', 'null'):
                        continue  # valor por defecto del array
                    ix = indices(g)
                    if ix is None:
                        init += ['set i=0', 'loop', f'exitwhen(i>{fin})', x, 'set i=i+1', 'endloop']
                        informe.append(f'{f}: bucle entero de {g} (índice variable), hasta {fin}')
                    else:
                        init += [f'set {g}[{n}]={v}' for n in ix]
                        informe.append(f'{f}: {g} en {" ".join(ix) or "ningún índice"} = {v}')
            k = e
        else:
            m = re.match(r'set (\w+)(\[' + CONST + r'\])?=(.*)$', l)
            if m and m.group(2):
                ix = indices(m.group(1)) if m.group(1) in glob else []
                if ix is not None and m.group(2)[1:-1] not in ix:
                    m = None  # índice que el héroe no usa
            if m and m.group(1) in glob and m.group(1) not in TR and m.group(1) != 'Je' and not m.group(3).startswith('CreateSound('):
                if not re.search(r'\b(?:Get\w+|bj_\w+|GetTriggerUnit|GetEnteringUnit)\b', m.group(3)) or 'Rect(' in m.group(3):
                    init.append(l)
                    informe.append(f'{f}: {l[:100]}')
                else:
                    informe.append(f'{f}: OMITIDA {l[:100]}')
        k += 1
if 'Je' in glob:
    init.append('set Je=bj_FORCE_ALL_PLAYERS')
for t in TR:
    init += trig[t]
if fin_carga:
    glob.append('Ca')
    decl['Ca'] = 'trigger Ca=null'
    init += ['set Ca=CreateTrigger()', 'call TriggerRegisterAnyUnitEventBJ(Ca,EVENT_PLAYER_UNIT_SPELL_ENDCAST)',
             'call TriggerAddAction(Ca,function Don_FinCarga)']
uses_i = any(x == 'set i=0' for x in init)

nombres = {f: P + 'F_' + f for f in funcs} | {g: P + 'V_' + g for g in glob} | {'Don_FinCarga': P + '_FinCarga'}
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


f = renombrar(todo)
gi = renombrar('\n'.join(init))

# --- cambios para Dev Mission ---
n = len(re.findall(r'GetHeroStatBJ\(', f))
f = re.sub(r'GetHeroStatBJ\(([012]),((?:\w|\[[^\]]*\])+),true\)', lambda m: f'{P}_Stat({m.group(1)})', f)
assert 'GetHeroStatBJ' not in f, 'GetHeroStatBJ sin cambiar'
informe.append(f'GetHeroStatBJ: {n}')
n = len(re.findall(P + r'F_WB\(([^(),]+(?:\(\))?),UNIT_TYPE_HERO\)', f))
f = re.sub(P + r'F_WB\(([^(),]+(?:\(\))?),UNIT_TYPE_HERO\)', r'Gk_EsCuerpo(\1)', f)
assert 'UNIT_TYPE_HERO' not in f, [l for l in f.split('\n') if 'UNIT_TYPE_HERO' in l][:3]
informe.append(f'UNIT_TYPE_HERO: {n}')
for a, b in [('CameraSetEQNoiseForPlayer(', 'Gk_SacudeEQ('), ('CameraSetTargetNoiseForPlayer(', 'Gk_SacudeBlanco('),
             ('CameraClearNoiseForPlayer(', 'Gk_SacudeQuitar(')]:
    f = f.replace(a, b)
assert not re.search(r'Camera\w*Noise', f), 'ruido de cámara sin cambiar'
TT = re.compile(r'call CreateTextTagUnitBJ\((.*),(GetEnumUnit\(\)|GetTriggerUnit\(\)|\w+V_\w+(?:\[[^\]]*\])?),([^,()]+),([^,()]+),([^,()]+),([^,()]+),([^,()]+),([^,()]+)\)\n'
                r'call SetTextTagVelocityBJ\(bj_lastCreatedTextTag,([^,]+),(.*)\)\n'
                r'call SetTextTagPermanentBJ\(bj_lastCreatedTextTag,false\)\n'
                r'call SetTextTagLifespanBJ\(bj_lastCreatedTextTag,(.*)\)\n')
n = len(TT.findall(f))
f = TT.sub(lambda m: 'call Gk_TT(' + ','.join(m.groups()) + ')\n', f)
assert 'TextTag' not in f.replace('Gk_TT', ''), [l for l in f.split('\n') if 'TextTag' in l][:3]
informe.append(f'texttags: {n}')
f, n = re.subn(r'call SelectUnitForPlayerSingle\([^\n]*\)\n', '', f)
informe.append(f'SelectUnitForPlayerSingle quitadas: {n}')
for a, b in remapeo.items():
    n = f.count(f"'{a}'")
    assert n, a
    f = f.replace(f"'{a}'", f"'{b}'")
    informe.append(f'{a} -> {b}: {n}')
kb = P + 'F_kb'
if 'function ' + kb + ' ' in f:
    f, k = re.subn(r'function ' + kb + r' takes real mb,location nb,code ob returns nothing\n.*?\nendfunction',
                   'function ' + kb + ' takes real mb,location nb,code ob returns nothing\nendfunction', f, count=1, flags=re.S)
    assert k == 1
assert not re.search(r'EnumDestructables|GetSpellTargetDestructable', f), 'otro camino a destructibles'
for x in ['SelectUnit', 'GetLocalPlayer', 'ClearSelection', 'SetCamera', 'PanCamera', 'SetUnitOwner', 'DialogDisplay',
          'Multiboard', 'Leaderboard', 'SetHeroLevel', 'ReplaceUnit', 'ShowInterface', 'EnableUserControl']:
    if x in f:
        informe.append(f'REVISAR {x}: ' + ' / '.join(l for l in f.split('\n') if x in l)[:300])

ids = sorted(set(re.findall(r"'([A-Za-z0-9]{4})'", f + gi)))
Path(ids_out).write_text('\n'.join(ids) + '\n')
g = []
for x in sorted(glob):
    d = decl[x]
    m = re.match(r'(\s*(?:constant\s+)?\w+\s+(?:array\s+)?)(\w+)(.*)$', d)
    ini = m.group(3)
    if re.search(r'\w+\(', ini):
        ini = ''
    g.append(m.group(1) + P + 'V_' + m.group(2) + ini)
Path(g_out).write_text('\n'.join(g) + '\n', encoding='latin-1')
loc = 'local integer i=0\n' if uses_i else ''
Path(f_out).write_text(f + f'\nfunction {P}_InitDON takes nothing returns nothing\n' + loc + gi + '\nendfunction\n', encoding='latin-1')
if inf_out:
    Path(inf_out).write_text('\n'.join(informe) + '\n')
print(f'{P}: {len(funcs)} funciones, {len(glob)} globales, {len(sonidos)} sonidos, {len(ids)} rawcodes, {len(TR)} triggers')
