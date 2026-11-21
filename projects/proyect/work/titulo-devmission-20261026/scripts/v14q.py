#!/usr/bin/env python3
r"""v14q: alcance por tier, precarga y cadáveres de las oleadas (06/11/2026), sobre v14p.

Pedidos de Leon: que se note más el alcance en las mejoras de armas, y quitar el tirón cuando salen muchas unidades a la
vez y se matan varias de golpe.
- Alcance por tier (armas_v14q.py); la tienda lo pone en azul al principio del renglón de rasgos.
- Precarga en la pantalla de carga (Precarga_Todo, desde la inicialización de las bibliotecas de oleadas):
  · Preload() de cada archivo importado y PreloadEnd, como los .pld de Blizzard: sólo deja los archivos en la caché del
    sistema (lo leen en segundo plano), no crea el modelo.
  · Un efecto creado y destruido lejos de la vista por cada modelo importado y por cada efecto de aparición de las
    oleadas: el primer uso de un modelo es lo que lo carga de verdad.
  · Una unidad creada y quitada por cada tipo de las oleadas (10 normales, 10 élites, 9 jefes), para que el primer tipo
    nuevo de una ronda no cargue su modelo a mitad de la oleada.
  · Las 11 habilidades de vida de las élites ('ALh0'..'ALhA'), añadidas y quitadas a esa misma unidad.
- Cadáveres: las unidades de las oleadas que mueren se quitan del mapa 3,5 s después (cola de 512 con un único reloj de
  0,5 s). Los cadáveres siguen dentro de GroupEnumUnitsInRange, que cada bala usa en cada paso.
Uso: v14q.py ENTRADA.j SALIDA.j IMPORTS.txt
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base
from armas_v14q import ARMAS, TIERS, alcance, rasgo

N = '\r\n'


def u(x):
    return x.encode('utf-8').decode('latin-1')


def once(s, old, new):
    return base.once(s, u(old), u(new))


def funcion(s, cabeza):
    c = cabeza.replace('\n', N)
    assert s.count(c) == 1, cabeza
    a = s.index(c)
    b = s.index(N + ('    ' if cabeza.startswith('    ') else '') + 'endfunction', a)
    return a, s.index(N, b + 2) + 2


def en(s, cabeza, old, new, veces=1):
    a, b = funcion(s, cabeza)
    f = s[a:b]
    o, n = u(old).replace('\n', N), u(new).replace('\n', N)
    assert f.count(o) == veces, (cabeza, old, f.count(o))
    return s[:a] + f.replace(o, n) + s[b:]


def jstr(x):
    return '"' + x.replace('\\', '\\\\').replace('"', '\\"') + '"'


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
imports = [l.split(None, 1)[1].strip() for l in Path(sys.argv[3]).read_text(encoding='utf-8').splitlines()
           if l.startswith('  ok ')]
assert len(imports) > 500, len(imports)

# Alcance y rasgos por tier.
for w, a in enumerate(ARMAS):
    c, t = divmod(w, TIERS)
    t += 1
    s, n = re.subn(rf'    set Arm_Alc\[{w}\] = [0-9.]+\r\n', f'    set Arm_Alc[{w}] = {alcance(c, t)}.\r\n', s)
    assert n == 1, w
    s, n = re.subn(rf'    set Arm_Rasgo\[{w}\] = "[^\r\n]*"\r\n', lambda m: u(f'    set Arm_Rasgo[{w}] = {jstr(rasgo(c, a, t))}\r\n'), s)
    assert n == 1, w

# Precarga.
modelos = [x for x in imports if x.lower().endswith('.mdx')]
lineas = ['// v14q: precarga en la pantalla de carga (v14q.py). Lejos de la vista: esquina suroeste del mapa.',
          'function Precarga_Todo takes nothing returns nothing',
          '    local integer i = 1',
          '    local unit d',
          '    local real x = -13000.',
          '    local real y = -7000.',
          '    // Archivos: a la caché del sistema, leídos en segundo plano.']
lineas += [f'    call Preload({jstr(x)})' for x in imports]
lineas += ['    call PreloadEnd(2.0)',
           '    // Modelos importados y efectos de aparición: el primer uso es lo que carga el modelo.']
lineas += [f'    call DestroyEffect(AddSpecialEffect({jstr(x)}, x, y))' for x in modelos]
lineas += ['    loop',
           '        exitwhen i > WAVE_FX_MAX',
           '        call DestroyEffect(AddSpecialEffect(WaveSpawnFx__WaveFxIn[i], x, y))',
           '        call DestroyEffect(AddSpecialEffect(WaveSpawnFx__WaveFxOut[i], x, y))',
           '        set i = i + 1',
           '    endloop',
           '    // Tipos de las oleadas: normales, élites y jefes.',
           '    set i = 0',
           '    loop',
           '        exitwhen i > 9',
           '        call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), DevWave_TipoN(i), x, y, 0.))',
           "        call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'ne00' + i, x, y, 0.))",
           '        if i >= 2 then',
           '            call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), DevJefe_Tipo(i), x, y, 0.))',
           '        endif',
           '        set i = i + 1',
           '    endloop',
           "    call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), DevJefe_Tipo(10), x, y, 0.))",
           '    // Habilidades de vida de las élites.',
           "    set d = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'ne00', x, y, 0.)",
           '    set i = 0',
           '    loop',
           '        exitwhen i > 10',
           '        call UnitAddAbility(d, DevFuego_Bono(i))',
           '        call UnitRemoveAbility(d, DevFuego_Bono(i))',
           '        set i = i + 1',
           '    endloop',
           '    call RemoveUnit(d)',
           '    set d = null',
           'endfunction',
           '']
cab = 'function DevWave_Inicio takes nothing returns nothing\n'
assert s.count(cab.replace('\n', N)) == 1
s = s.replace(cab.replace('\n', N), u('\n'.join(lineas)).replace('\n', N) + cab.replace('\n', N), 1)
s = en(s, cab, 'call ExecuteFunc("WaveSpawnFx__Init")\n', 'call ExecuteFunc("WaveSpawnFx__Init")\ncall ExecuteFunc("Precarga_Todo")\n')

# Cadáveres.
s = once(s, 'real array Arm_Vel\n', 'real array Arm_Vel\nunit array Cadaver_U\ninteger array Cadaver_T\ninteger Cadaver_I= 0\n'
         'integer Cadaver_F= 0\ninteger Cadaver_Tic= 0\ntimer Cadaver_Reloj= null\n')
s = once(s, 'function DevFuego_Muere takes nothing returns nothing\n', '''// v14q: los cadáveres de las oleadas salen del mapa 3,5 s después de morir (7 latidos de 0,5 s). Cola de 512: si se
// llena, sale antes el más viejo.
function Cadaver_Quitar takes nothing returns nothing
    local unit c = Cadaver_U[ModuloInteger(Cadaver_I, 512)]
    if GetUnitTypeId(c) != 0 and not UnitAlive(c) then
        call RemoveUnit(c)
    endif
    set Cadaver_U[ModuloInteger(Cadaver_I, 512)] = null
    set Cadaver_I = Cadaver_I + 1
    set c = null
endfunction

function Cadaver_Latido takes nothing returns nothing
    set Cadaver_Tic = Cadaver_Tic + 1
    loop
        exitwhen Cadaver_I >= Cadaver_F or Cadaver_T[ModuloInteger(Cadaver_I, 512)] > Cadaver_Tic
        call Cadaver_Quitar()
    endloop
endfunction

function Cadaver_Poner takes unit c returns nothing
    if Cadaver_F - Cadaver_I >= 512 then
        call Cadaver_Quitar()
    endif
    set Cadaver_U[ModuloInteger(Cadaver_F, 512)] = c
    set Cadaver_T[ModuloInteger(Cadaver_F, 512)] = Cadaver_Tic + 7
    set Cadaver_F = Cadaver_F + 1
endfunction

function DevFuego_Muere takes nothing returns nothing
''')
s = en(s, 'function DevFuego_Muere takes nothing returns nothing\n', '''    local integer g
''', '''    local integer g
    if not WaveEventIsRetired and GetWaveEventUnit() != null then
        call Cadaver_Poner(GetWaveEventUnit())
    endif
''')
s = en(s, 'function DevWave_Arrancar takes nothing returns nothing\n', '    call DevWave_IA()\n', '''    call DevWave_IA()
    set Cadaver_Reloj = CreateTimer()
    call TimerStart(Cadaver_Reloj, 0.5, true, function Cadaver_Latido)
''')

Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v14q:', len(imports), 'archivos con Preload,', len(modelos), 'modelos con efecto')
