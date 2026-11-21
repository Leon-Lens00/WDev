#!/usr/bin/env python3
"""v16u (13/11/2026): movimiento de un héroe de D.O.N trasplantado (don_heroe.py) sobre Missile y GroundCollision.

Versión genérica de goku_misil.py para Freezer, Trunks y Naruto (Leon, 13/11/2026: mismo método que Goku). La lógica de
D.O.N no se reescribe:
  - Cada trigger periódico que mueve piezas (su acción alcanza SetUnitPositionLoc*) pierde su temporizador; donde D.O.N
    lo encendía se añade Don_Motor(T, periodo): una instancia de Missile (struct Don_MOT, sin velocidad ni colisión)
    que ejecuta la acción al ritmo original con el reloj de Missile mientras el trigger siga encendido. Si el trigger
    empieza encendido, el motor arranca en <P>_InitDON.
  - Cada SetUnitPositionLoc(u, L) de esas acciones pasa por Don_Pon(u, L): GroundCollision traza desde donde está la
    unidad hasta L (radio 24, sin unidades); en precipicio o árbol la pieza se queda en el último punto libre. Piezas
    por el aire (altura de vuelo >= 150) no chocan.
Los finales de cada habilidad siguen siendo los de D.O.N (distancia o pasos): la pieza bloqueada espera ahí su final.
El código compartido (Don_Motor, Don_Pon) lo pone don_v16u.py.
Uso: don_misil.py PREFIJO FUNCIONES.j [INFORME.txt]  (reescribe FUNCIONES.j)
"""
from pathlib import Path
import re, sys

P, f_path = sys.argv[1:3]
f = Path(f_path).read_text(encoding='latin-1')
fn = {m.group(1): m.group(0) for m in re.finditer(r'^function (\w+) takes.*?^endfunction', f, re.M | re.S)}
init = fn[P + '_InitDON']
calls = {k: {x for x in re.findall(r'\b(\w+)\b', v) if x in fn and x != k} for k, v in fn.items()}


def cierre(fs):
    out, pend = set(), list(fs)
    while pend:
        x = pend.pop()
        if x in out or x not in fn:
            continue
        out.add(x)
        pend += calls[x] - out
    return out


periodo = dict(re.findall(r'call TriggerRegisterTimerEventPeriodic\((\w+),([\d.]+)\)', init))
accion = {}
for t, a in re.findall(r'call TriggerAddAction\((\w+),function (\w+)\)', init):
    accion.setdefault(t, []).append(a)
MUEVE = re.compile(r'call SetUnitPositionLoc(?:FacingBJ|FacingLocBJ)?\(')
movers, tocadas = {}, set()
for t, p in periodo.items():
    c = cierre(accion.get(t, []))
    if any(MUEVE.search(fn[x]) for x in c):
        movers[t] = p
        tocadas |= {x for x in c if MUEVE.search(fn[x])}
assert movers, 'ningún trigger periódico mueve piezas'
inf = [f'{P}: motores ' + ' '.join(f'{t[len(P) + 2:]} {p}' for t, p in sorted(movers.items()))]

# --- colocaciones con choque ---
n = 0
for x in sorted(tocadas):
    cuerpo = fn[x]
    nuevo, k1 = re.subn(r'call SetUnitPositionLoc\(([^\n]+)\)\n', r'call Don_Pon(\1)\n', cuerpo)
    nuevo, k2 = re.subn(r'call SetUnitPositionLocFacingBJ\(([^\n]+)\)\n', r'call Don_PonF(\1)\n', nuevo)
    nuevo, k3 = re.subn(r'call SetUnitPositionLocFacingLocBJ\(([^\n]+)\)\n', r'call Don_PonFL(\1)\n', nuevo)
    assert not MUEVE.search(nuevo), x
    f = f.replace(cuerpo, nuevo)
    n += k1 + k2 + k3
inf.append(f'colocaciones con choque: {n} en {len(tocadas)} funciones')

# --- sin temporizador: los mueve el reloj de Missile ---
for t, p in movers.items():
    reg = f'call TriggerRegisterTimerEventPeriodic({t},{p})\n'
    assert f.count(reg) == 1, reg
    f = f.replace(reg, '')
    en = f'call EnableTrigger({t})\n'
    k = f.count(en)
    f = f.replace(en, en + f'call Don_Motor({t},{p})\n')
    apagado = f'call DisableTrigger({t})\n' in init
    if not apagado:  # empieza encendido: el motor arranca con el héroe
        assert f.endswith('\nendfunction\n')
        f = f[:-len('endfunction\n')] + f'call Don_Motor({t},{p})\nendfunction\n'
    inf.append(f'{t}: {k} encendidos' + ('' if apagado else ', encendido al inicio'))
    assert k or not apagado, f'{t} nunca se enciende'
Path(f_path).write_text(f, encoding='latin-1')
if len(sys.argv) > 3:
    with open(sys.argv[3], 'a') as o:
        o.write('\n'.join(inf) + '\n')
print('; '.join(inf[:2]))
