#!/usr/bin/env python3
"""v14d: disparo rápido nativo en todas las armas, mínimo cuatro tiros por segundo, más enemigos, cámara más alta,
diez canciones de DevTest6 y vida en la tienda.

Sale el botón F y el giro previo de v14c: cada cast suelta su ráfaga con movimiento artificial, cuchillo incluido.
Ataque al 400 %. La cámara sube 1000 sin cambiar su inclinación; la tienda conserva la suya.

Uso: v14d.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import math, re, sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base

# Índice de arma: disparos por minuto, cargador, reserva. Las que no están ya cumplían.
ARMAS = {0: (240, 12, 72), 1: (270, 15, 90), 2: (300, 18, 108), 9: (240, 6, 60), 10: (240, 8, 80), 11: (270, 10, 100),
         12: (240, 6, 60), 13: (240, 8, 80), 14: (270, 10, 100), 15: (240, 0, 0), 16: (270, 0, 0), 17: (300, 0, 0),
         18: (240, 6, 36), 19: (240, 6, 48), 20: (240, 8, 64)}
ENEMIGOS = 1.75
CAMARA = 1000.
VIDA = 500
# Canciones nuevas: llegan a -8.5 LUFS, como las otras, con el volumen al tope.
TEMAS = (7, 8, 9, 10)


def u(t):
    return t.encode('utf-8').decode('latin-1')


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')


def antes(marca, texto):
    global s
    s = base.once(s, marca, u(texto) + marca)


def fuera(ini, fin):
    """Quita desde ini hasta justo antes de fin."""
    global s
    ini, fin = ini.replace('\n', '\r\n'), fin.replace('\n', '\r\n')
    assert s.count(ini) == 1, ini
    a = s.index(ini)
    b = s.index(fin, a)
    s = s[:a] + s[b:]


def dato(campo, i, valor):
    global s
    s, n = re.subn(rf'(set {campo}\[{i}\] = )[\d.]+', rf'\g<1>{valor}', s)
    assert n == 1, (campo, i)


# Datos de armas
for i, (rpm, mag, res) in ARMAS.items():
    dato('Arm_Int', i, f'{60. / rpm:.4f}')
    dato('Arm_Mag', i, mag)
    dato('Arm_Res', i, res)
s = base.once(s, u('"Una bala cada seis segundos, y cada una cuenta."'), u('"Bala larga y sin dispersión: cada una cuenta."'))
s = base.once(s, u('"Un disparo, sin dispersión"'), u('"Sin dispersión"'))
s = base.once(s, u('"Palanca, un perdigón más y cinco tiros seguidos."'), u('"Palanca rápida y un perdigón más."'))

# Sin modo manual ni botón F
s = base.once(s, 'boolean array Arm_Rapido\n', '')
s = base.once(s, 'boolean array Arm_Gira\n', '')
fuera('    function Arm_Automatica takes integer p returns boolean\n', '    function Arm_Puede takes integer this returns boolean\n')
fuera(u('    // Gira hasta tener delante el punto del cast y entonces dispara.\n'), '    function s__RapidPair_cast takes')
fuera(u('        // Sin disparo rápido: se detiene y gira.'), '        if s__RapidPair_firing[this] then\n            set s__RapidPair_remaining=s__RapidPair_remaining + 6 - ')
s = base.once(s, '''                if Arm_Gira[this] then
                    call Arm_Girar(this)
                endif
''', '')
s = base.once(s, '''        set Arm_Fin[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))]=0.
        set Arm_Gira[this]=false
''', '''        set Arm_Fin[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))]=0.
''')
for linea in ('                set Arm_Gira[this]=false\n', '            set Arm_Gira[Game_Pair[p]]=false\n',
              '    set Arm_Gira[this] = false\n', '    set Arm_Gira[Game_Pair[p]] = false\n'):
    s = base.once(s, linea, '')
s = base.once(s, '''        if Arm_Rapido[p] then
            call UnitAddAbility(u, 'Aw09')
        else
            call UnitAddAbility(u, 'Aw07')
        endif
''', '')
s = base.once(s, '''                if Arm_Automatica(p) then
                    call s__RapidPair_showWalk(this)
                    set s__RapidPair_nextShot[this]=RMaxBJ((TimerGetElapsed(s__RapidPair_clock)), Arm_Listo[p * 7 + c])
                else
                    call s__RapidPair_finish(this,true)
                endif
''', '''                call s__RapidPair_showWalk(this)
                set s__RapidPair_nextShot[this]=RMaxBJ((TimerGetElapsed(s__RapidPair_clock)), Arm_Listo[p * 7 + c])
''')
fuera('    function Arm_BotonRapido takes nothing returns nothing\n', '    function Arm_BotonRecarga takes')
s = base.once(s, """        call RegisterSpellEffectEvent('Aw07' , function Arm_BotonRapido)
        call RegisterSpellEffectEvent('Aw09' , function Arm_BotonRapido)
""", '')
s = base.once(s, '''    if c == 1 or c == 2 then
        set s = I2S(R2I(60. / Arm_Int[w] + 0.5)) + " rpm  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s"
    else
        set s = "Manual"
    endif
''', '''    set s = I2S(R2I(60. / Arm_Int[w] + 0.5)) + " rpm  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s"
''')

# Ataque al 400 %
s = base.once(s, 'call SetUnitTimeScale(s__RapidPair_actor[this], 3.)', 'call SetUnitTimeScale(s__RapidPair_actor[this], 4.)')


# Más enemigos, y más a la vez: dificultad 1 dejaba 5 por dueño.
def mas(m):
    return f"{m.group(1)}{math.ceil(int(m.group(2)) * ENEMIGOS)}{m.group(3)}"


s, n = re.subn(r"(call DevWave_Reparto\(w , '\w{4}' , )(\d+)( , AI_PROFILE)", mas, s)
assert n == 55, n
s = base.once(s, 'set WaveDifficulty__CapByLevel[level]=5 * level', 'set WaveDifficulty__CapByLevel[level]=10 * level')

# Cámara: se aleja por la misma línea de vista hasta quedar 1000 más alta. Las distancias salen de estas posiciones.
s = base.once(s, 's__VECTOR3_New_1(0.0 , - 922.668 , Camera__DeltaZ + 1367.912)',
              f's__VECTOR3_New_1(0.0 , - {922.668 * (1367.912 + CAMARA) / 1367.912:.3f} , Camera__DeltaZ + {1367.912 + CAMARA})')

# Música: una canción por ronda
temas = ''
for n in TEMAS:
    temas += f'''    set Ronda_Tema[{n}] = CreateSound("war3mapImported\\\\OleadaTema{n}.mp3", true, false, false, 12700, 12700, "")
    call SetSoundPitch(Ronda_Tema[{n}], 1.07)
    call SetSoundChannel(Ronda_Tema[{n}], 0)
    call SetSoundVolume(Ronda_Tema[{n}], 127)
'''
s = base.once(s, '    call SetSoundVolume(Ronda_Tema[6], 127)\n', '    call SetSoundVolume(Ronda_Tema[6], 127)\n' + temas)
s = base.once(s, 'set Ronda_TemaActual = Ronda_Tema[ModuloInteger(Ronda_Numero - 1, 6) + 1]', 'set Ronda_TemaActual = Ronda_Tema[Ronda_Numero]')

# Vida en la tienda, sobre el botón de munición
s = base.once(s, 'unit Shop_RecOn= null\n', f'unit Shop_RecOn= null\nunit Shop_VidaOn= null\nconstant integer Shop_VIDA = {VIDA}\n')
s = base.once(s, "    set Shop_RecOn = Shop_Pic(1601, 773, 366, 62, 398.5, 'DS09')\n", """    set Shop_RecOn = Shop_Pic(1601, 773, 366, 62, 398.5, 'DS09')
    call Shop_Pic(1601, 706, 366, 62, 399, 'DS0A')
    set Shop_VidaOn = Shop_Pic(1601, 706, 366, 62, 398.5, 'DS09')
""")
s = base.once(s, '        exitwhen i > 18\n', '        exitwhen i > 19\n')
s = base.once(s, 'call Shop_Tag(1424, 678, 0.024, 0, "Oro")', 'call Shop_Tag(1424, 610, 0.024, 0, "Oro")')
s = base.once(s, 'I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)), 1490, 672, 0.026)\n',
              '''I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)), 1490, 604, 0.026)
    call Shop_Centro(p, Shop_T[19], "Vida: " + I2S(Shop_VIDA) + " oro  (tienes " + I2S(Vidas_Actual[p]) + ")", 1601, 691, 0.021)
    call Shop_Luz(p, Shop_VidaOn, GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) >= Shop_VIDA)
''')
antes('function Shop_Clic takes nothing returns nothing\n', '''function Shop_Vida takes integer p returns nothing
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    if oro < Shop_VIDA then
        call UI_Error(p)
        return
    endif
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - Shop_VIDA)
    set Vidas_Actual[p] = Vidas_Actual[p] + 1
    // En la última vida el cuerpo ya no lleva reencarnación.
    if GetUnitAbilityLevel(Game_Hero[p], 'Arei') == 0 then
        call UnitAddAbility(Game_Hero[p], 'Arei')
    endif
    call UI_Click(p)
    call Shop_Refrescar(p)
endfunction

''')
s = base.once(s, '''    elseif k == 21 then
        call Shop_Balas(p)
''', '''    elseif k == 21 then
        call Shop_Balas(p)
    elseif k == 23 then
        call Shop_Vida(p)
''')
s = base.once(s, '            call Shop_Pista(p, "war3mapImported\\\\ShopHitBtn.mdx", 1601, 773, 21)\n',
              '            call Shop_Pista(p, "war3mapImported\\\\ShopHitBtn.mdx", 1601, 773, 21)\n'
              '            call Shop_Pista(p, "war3mapImported\\\\ShopHitBtn.mdx", 1601, 706, 23)\n')

Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
