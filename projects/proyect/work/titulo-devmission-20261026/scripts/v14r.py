#!/usr/bin/env python3
"""v14r: relámpagos y truenos de Storm v1.3.1 (OVOgenez, Hive 356042) durante las oleadas. Parte del j de v14q.

Storm es una unidad con 180 animaciones (Ldummy) que lleva pegado un modelo con luz direccional: el giro de la unidad
fija el ángulo horizontal y la animación el vertical. Durante el destello aclara la niebla y luego suena el trueno.

Cambios respecto del original (copiado del j compilado de su mapa de ejemplo, fuentes/storm-1.3.1/ej):
- El original lleva la unidad a GetCameraTargetPositionX/Y, que es distinto en cada cliente. Aquí cada jugador tiene su
  propia tormenta en la posición de su Camera_DummyUnit (sincronizada); sólo el efecto y el sonido son locales (ruta
  vacía para los demás, como hace el original con su modo local).
- La unidad se quita con RemoveUnit en lugar de KillUnit: sin evento de muerte para los sistemas del mapa.
- Rawcode 'h00S' (StormDummy) y rutas en war3mapImported (StormDummy, StormL1..3, StormT1..3).
- La niebla base es la del mapa (SetTerrainFogEx de main: estilo 0, 1700, 8000, 0,15, color 1 1 0).
- Storm_Tick lanza una tormenta cada 15–40 s mientras la ronda está activa y fuera del descanso (Storm_Rayo).
- Precarga: la unidad, los tres modelos de luz y los tres truenos (con volumen 0: el autor avisa de que el primer trueno
  no suena sin precargar).

Uso: v14r.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

N = '\r\n'


def u(x):
    return x.encode('utf-8').decode('latin-1')


def once(s, old, new):
    return base.once(s, u(old), u(new))


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert 'Storm_' not in s

GLOBALS = '''// v14r: Storm v1.3.1 (OVOgenez).
constant integer Storm__DUMMY_ID= 'h00S'
constant integer Storm_VAR_COUNT= 3
string array Storm__LightningPath
string array Storm__ThunderPath
boolean Storm_TF= true
integer Storm_TF_style= 0
real Storm_TF_zstart= 1700.0
real Storm_TF_zend= 8000.0
real Storm_TF_density= 0.15
real Storm_TF_red= 1.0
real Storm_TF_green= 1.0
real Storm_TF_blue= 0.0
boolean Storm__USE_zstart= false
boolean Storm__USE_zend= false
boolean Storm__USE_density= false
boolean Storm__USE_color= true
real array Storm__L_intensity
real array Storm__L_red
real array Storm__L_green
real array Storm__L_blue
integer si__Storm__TStorm_F=0
integer si__Storm__TStorm_I=0
integer array si__Storm__TStorm_V
integer array s__Storm__TStorm_ARRAY
integer s__Storm__TStorm_SIZE= 0
integer array s__Storm__TStorm_INDEX
constant real s__Storm__TStorm_PERIOD= 0.03125
integer array s__Storm__TStorm_Variant
integer array s__Storm__TStorm_Count
integer array s__Storm__TStorm_Current
integer array s__Storm__TStorm_LIndex
integer array s__Storm__TStorm_TIndex
integer array s__Storm__TStorm_Owner
boolean s__Storm__TStorm_TempTF= true
integer s__Storm__TStorm_TempTF_style= 0
real s__Storm__TStorm_TempTF_zstart= 1700.0
real s__Storm__TStorm_TempTF_zend= 8000.0
real s__Storm__TStorm_TempTF_density= 0.15
real s__Storm__TStorm_TempTF_red= 1.0
real s__Storm__TStorm_TempTF_green= 1.0
real s__Storm__TStorm_TempTF_blue= 0.0
timer s__Storm__TStorm_Timer= null
timer Storm_Reloj= null
integer Storm_Lanzadas= 0
unit array s__Storm__TStorm_Unit
effect array s__Storm__TStorm_Effect
real array s__Storm__TStorm_Time
boolean array s__Storm__TStorm_Mode
boolean array s__Storm__TStorm_Local
'''

FUNCS = r'''// v14r: Storm v1.3.1 de OVOgenez (Hive 356042), del j compilado de su mapa de ejemplo. Cada jugador tiene su tormenta
// en su Camera_DummyUnit (posición sincronizada); el efecto y el trueno sólo se crean con ruta para ese jugador.
function s__Storm__TStorm__allocate takes nothing returns integer
    local integer this= si__Storm__TStorm_F
    if this != 0 then
        set si__Storm__TStorm_F = si__Storm__TStorm_V[this]
    else
        set si__Storm__TStorm_I = si__Storm__TStorm_I + 1
        set this = si__Storm__TStorm_I
    endif
    if this > 8190 then
        return 0
    endif
    set s__Storm__TStorm_INDEX[this] = 0
    set si__Storm__TStorm_V[this] = -1
    return this
endfunction

function s__Storm__TStorm_deallocate takes integer this returns nothing
    if this == 0 or si__Storm__TStorm_V[this] != -1 then
        return
    endif
    set si__Storm__TStorm_V[this] = si__Storm__TStorm_F
    set si__Storm__TStorm_F = this
endfunction

function Storm__Init takes nothing returns nothing
    set Storm__LightningPath[1] = "war3mapImported\\StormL1.mdx"
    set Storm__LightningPath[2] = "war3mapImported\\StormL2.mdx"
    set Storm__LightningPath[3] = "war3mapImported\\StormL3.mdx"
    set Storm__ThunderPath[1] = "war3mapImported\\StormT1.wav"
    set Storm__ThunderPath[2] = "war3mapImported\\StormT2.wav"
    set Storm__ThunderPath[3] = "war3mapImported\\StormT3.wav"
    set Storm__L_intensity[1] = 0.4
    set Storm__L_intensity[2] = 0.8
    set Storm__L_intensity[3] = 1.2
    set Storm__L_red[1] = 0.5
    set Storm__L_red[2] = 0.5
    set Storm__L_red[3] = 0.5
    set Storm__L_green[1] = 0.75
    set Storm__L_green[2] = 0.75
    set Storm__L_green[3] = 0.75
    set Storm__L_blue[1] = 1.0
    set Storm__L_blue[2] = 1.0
    set Storm__L_blue[3] = 1.0
endfunction

function s__Storm__TStorm_remove takes integer this returns nothing
    if s__Storm__TStorm_INDEX[this] != 0 then
        set s__Storm__TStorm_INDEX[s__Storm__TStorm_ARRAY[s__Storm__TStorm_SIZE]] = s__Storm__TStorm_INDEX[this]
        set s__Storm__TStorm_ARRAY[s__Storm__TStorm_INDEX[this]] = s__Storm__TStorm_ARRAY[s__Storm__TStorm_SIZE]
        set s__Storm__TStorm_ARRAY[s__Storm__TStorm_SIZE] = 0
        set s__Storm__TStorm_INDEX[this] = 0
        set s__Storm__TStorm_SIZE = s__Storm__TStorm_SIZE - 1
    endif
endfunction

function s__Storm__TStorm_add takes integer this returns nothing
    if s__Storm__TStorm_INDEX[this] == 0 then
        set s__Storm__TStorm_SIZE = s__Storm__TStorm_SIZE + 1
        set s__Storm__TStorm_INDEX[this] = s__Storm__TStorm_SIZE
        set s__Storm__TStorm_ARRAY[s__Storm__TStorm_SIZE] = this
    endif
endfunction

// Con la cámara del jugador (sincronizada), no con GetCameraTargetPosition del cliente.
function s__Storm__TStorm_toCamera takes integer this returns nothing
    local unit c = Camera_DummyUnit[s__Storm__TStorm_Owner[this]]
    if c != null then
        call SetUnitX(s__Storm__TStorm_Unit[this], GetUnitX(c))
        call SetUnitY(s__Storm__TStorm_Unit[this], GetUnitY(c))
    endif
    set c = null
endfunction

function s__Storm__TStorm_destroy takes integer this returns nothing
    call s__Storm__TStorm_remove(this)
    if s__Storm__TStorm_Effect[this] != null then
        call DestroyEffect(s__Storm__TStorm_Effect[this])
    endif
    call RemoveUnit(s__Storm__TStorm_Unit[this])
    set s__Storm__TStorm_Effect[this] = null
    set s__Storm__TStorm_Unit[this] = null
    call s__Storm__TStorm_deallocate(this)
endfunction

function s__Storm__TStorm_Function takes integer this returns nothing
    local sound s
    local integer v = s__Storm__TStorm_Variant[this]
    call s__Storm__TStorm_toCamera(this)
    set s__Storm__TStorm_Time[this] = s__Storm__TStorm_Time[this] - s__Storm__TStorm_PERIOD
    if s__Storm__TStorm_Time[this] <= 0 then
        if s__Storm__TStorm_Current[this] > 0 and s__Storm__TStorm_Current[this] <= s__Storm__TStorm_Count[this] then
            if not s__Storm__TStorm_Mode[this] then
                set s__Storm__TStorm_Mode[this] = true
                set s__Storm__TStorm_Time[this] = GetRandomInt(2, 4) * s__Storm__TStorm_PERIOD
                set s__Storm__TStorm_LIndex[this] = v
                if s__Storm__TStorm_Local[this] then
                    set s__Storm__TStorm_Effect[this] = AddSpecialEffectTarget(Storm__LightningPath[v], s__Storm__TStorm_Unit[this], "origin")
                else
                    set s__Storm__TStorm_Effect[this] = AddSpecialEffectTarget("", s__Storm__TStorm_Unit[this], "origin")
                endif
            else
                set s__Storm__TStorm_Mode[this] = false
                set s__Storm__TStorm_Time[this] = GetRandomInt(1, 3) * s__Storm__TStorm_PERIOD
                set s__Storm__TStorm_Current[this] = s__Storm__TStorm_Current[this] + 1
                if s__Storm__TStorm_Current[this] > s__Storm__TStorm_Count[this] then
                    set s__Storm__TStorm_Current[this] = 0
                    set s__Storm__TStorm_Time[this] = (10 * (Storm_VAR_COUNT * Storm_VAR_COUNT - v * v) + GetRandomInt(0, 10)) * s__Storm__TStorm_PERIOD
                endif
                call DestroyEffect(s__Storm__TStorm_Effect[this])
                set s__Storm__TStorm_Effect[this] = null
            endif
        elseif s__Storm__TStorm_Current[this] == 0 then
            set s__Storm__TStorm_TIndex[this] = v
            if s__Storm__TStorm_Local[this] then
                set s = CreateSound(Storm__ThunderPath[v], false, false, false, 10, 10, "DoodadsEAX")
                call SetSoundChannel(s, 10)
            else
                set s = CreateSound("", false, false, false, 10, 10, "")
                call SetSoundChannel(s, -1)
            endif
            call SetSoundVolume(s, GetRandomInt(102, 127))
            call SetSoundPitch(s, GetRandomReal(0.9, 1.1))
            call StartSound(s)
            call KillSoundWhenDone(s)
            set s = null
            call s__Storm__TStorm_destroy(this)
        endif
    endif
endfunction

function s__Storm__TStorm_Periodic takes nothing returns nothing
    local real li
    local real zs = Storm_TF_zstart
    local real ze = Storm_TF_zend
    local real d = Storm_TF_density
    local real r = Storm_TF_red
    local real g = Storm_TF_green
    local real b = Storm_TF_blue
    local integer i = s__Storm__TStorm_SIZE
    local integer t
    loop
        exitwhen i <= 0
        set t = s__Storm__TStorm_ARRAY[i]
        call s__Storm__TStorm_Function(t)
        if Storm_TF and s__Storm__TStorm_ARRAY[i] == t and s__Storm__TStorm_Current[t] > 0 and s__Storm__TStorm_Mode[t] and s__Storm__TStorm_Local[t] then
            set li = Storm__L_intensity[s__Storm__TStorm_LIndex[t]]
            if Storm__USE_zstart then
                set zs = RMaxBJ(zs, Storm_TF_zstart * (1 + li))
            endif
            if Storm__USE_zend then
                set ze = RMaxBJ(ze, Storm_TF_zend * (1 + li))
            endif
            if Storm__USE_density then
                set d = RMinBJ(d, Storm_TF_density / (1 + li))
            endif
            if Storm__USE_color then
                set r = RMinBJ(1, r + Storm__L_red[s__Storm__TStorm_LIndex[t]] * li)
                set g = RMinBJ(1, g + Storm__L_green[s__Storm__TStorm_LIndex[t]] * li)
                set b = RMinBJ(1, b + Storm__L_blue[s__Storm__TStorm_LIndex[t]] * li)
            endif
        endif
        set i = i - 1
    endloop
    if Storm_TF then
        if s__Storm__TStorm_TempTF != Storm_TF or s__Storm__TStorm_TempTF_style != Storm_TF_style or s__Storm__TStorm_TempTF_zstart != zs or s__Storm__TStorm_TempTF_zend != ze or s__Storm__TStorm_TempTF_density != d or s__Storm__TStorm_TempTF_red != r or s__Storm__TStorm_TempTF_green != g or s__Storm__TStorm_TempTF_blue != b then
            set s__Storm__TStorm_TempTF_style = Storm_TF_style
            set s__Storm__TStorm_TempTF_zstart = zs
            set s__Storm__TStorm_TempTF_zend = ze
            set s__Storm__TStorm_TempTF_density = d
            set s__Storm__TStorm_TempTF_red = r
            set s__Storm__TStorm_TempTF_green = g
            set s__Storm__TStorm_TempTF_blue = b
            call SetTerrainFogEx(Storm_TF_style, zs, ze, d, r, g, b)
        endif
    elseif s__Storm__TStorm_TempTF != Storm_TF then
        call ResetTerrainFog()
    endif
    set s__Storm__TStorm_TempTF = Storm_TF
endfunction

function s__Storm__TStorm_create takes integer p, integer variant, integer count, integer azimuth, integer zenith returns integer
    local integer this = s__Storm__TStorm__allocate()
    local unit c = Camera_DummyUnit[p]
    if this == 0 then
        set c = null
        return 0
    endif
    set s__Storm__TStorm_Owner[this] = p
    set s__Storm__TStorm_Variant[this] = variant
    set s__Storm__TStorm_Count[this] = count
    set s__Storm__TStorm_Current[this] = 1
    set s__Storm__TStorm_Local[this] = GetLocalPlayer() == Player(p)
    set s__Storm__TStorm_Time[this] = 0
    set s__Storm__TStorm_Mode[this] = false
    set s__Storm__TStorm_Unit[this] = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), Storm__DUMMY_ID, GetUnitX(c), GetUnitY(c), azimuth)
    call SetUnitAnimationByIndex(s__Storm__TStorm_Unit[this], zenith + 90)
    call s__Storm__TStorm_add(this)
    set c = null
    return this
endfunction

// Una tormenta para cada jugador con cámara: variante 1..3, 2..4 destellos, ángulos al azar (iguales para todos).
function Storm_Rayo takes integer variant returns nothing
    local integer count = GetRandomInt(2, 4)
    local integer azimuth = GetRandomInt(-180, 180)
    local integer zenith = GetRandomInt(-90, -30)
    local integer p = 0
    if variant < 1 or variant > Storm_VAR_COUNT then
        set variant = GetRandomInt(1, Storm_VAR_COUNT)
    endif
    loop
        exitwhen p > 11
        if Camera_DummyUnit[p] != null and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            call s__Storm__TStorm_create(p, variant, count, azimuth, zenith)
        endif
        set p = p + 1
    endloop
    set Storm_Lanzadas = Storm_Lanzadas + 1
endfunction

// Una tormenta cada 15–40 s durante la oleada.
function Storm_Tick takes nothing returns nothing
    if Ronda_Activa and not Ronda_Descanso then
        call Storm_Rayo(0)
    endif
    call TimerStart(Storm_Reloj, GetRandomReal(15., 40.), false, function Storm_Tick)
endfunction

function Storm_Iniciar takes nothing returns nothing
    call Storm__Init()
    set s__Storm__TStorm_Timer = CreateTimer()
    call TimerStart(s__Storm__TStorm_Timer, s__Storm__TStorm_PERIOD, true, function s__Storm__TStorm_Periodic)
    set Storm_Reloj = CreateTimer()
    call TimerStart(Storm_Reloj, GetRandomReal(15., 40.), false, function Storm_Tick)
endfunction

'''

PRECARGA = '''    // v14r: Storm (unidad, luces y truenos con volumen 0).
    call RemoveUnit(CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'h00S', x, y, 0.))
    set i = 1
    loop
        exitwhen i > 3
        call DestroyEffect(AddSpecialEffect("war3mapImported\\\\StormL" + I2S(i) + ".mdx", x, y))
        call Preload("war3mapImported\\\\StormT" + I2S(i) + ".wav")
        set s = CreateSound("war3mapImported\\\\StormT" + I2S(i) + ".wav", false, false, false, 10, 10, "DoodadsEAX")
        call SetSoundVolume(s, 0)
        call StartSound(s)
        call KillSoundWhenDone(s)
        set i = i + 1
    endloop
    set s = null
    set d = null
endfunction
'''

s = once(s, 'unit array Cadaver_U\n', GLOBALS + 'unit array Cadaver_U\n')
s = once(s, 'function Precarga_Todo takes nothing returns nothing\n', FUNCS + 'function Precarga_Todo takes nothing returns nothing\n')
s = once(s, 'function Precarga_Todo takes nothing returns nothing\n    local integer i = 1\n    local unit d\n',
         'function Precarga_Todo takes nothing returns nothing\n    local integer i = 1\n    local unit d\n    local sound s\n')
s = once(s, '    call RemoveUnit(d)\n    set d = null\nendfunction\nfunction DevWave_Inicio', '    call RemoveUnit(d)\n' + PRECARGA + 'function DevWave_Inicio')
s = once(s, 'call ExecuteFunc("Precarga_Todo")\n', 'call ExecuteFunc("Precarga_Todo")\ncall ExecuteFunc("Storm_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v14r: Storm añadido')
