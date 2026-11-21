#!/usr/bin/env python3
"""v14zo (07/11/2026): fase 6 de docs/planes/devmission-armas-rachas-v14zj.md (rachas, anuncios, voces y marcador).
Parte del j de v14zn. Módulo propio (Racha_*) sobre las muertes que ya cuenta Oro_Muerte; umbrales, cola y sonidos
tomados de WaveStreaks.j de WaveSys como referencia, sin sus 5 bibliotecas.

- Cuenta: cada enemigo de oleada (dueños 8..13) muerto por una unidad de un jugador (0..7) suma una baja a ese jugador:
  total, racha (hasta que el personaje cae) y multikill (bajas con menos de 3 s entre una y la siguiente).
- Primera sangre: la primera baja de cada oleada.
- Rachas: un escalón cada 25 bajas sin caer (25 … 200: Killing Spree … Beyond Godlike); en el último se repite cada 25.
  Multikill: 8, 15, 25 y 40 bajas seguidas (Double, Triple, Ultra, Rampage); en Rampage se repite cada 15.
  Al caer con 25 o más: «perdió su racha».
- Cola global: un anuncio cada vez. Suena la voz del locutor; al acabar (duración medida de cada archivo, fija: no se
  lee del archivo en el juego para que todos los clientes creen los sonidos en el mismo momento) suena una voz al azar
  del personaje autor (Tauren: TaurenYesAttack1..3 y TaurenWarcry1; Cairne: CairneYesAttack1..4 y CairneWarcry1, del
  juego). Si llega otro anuncio del mismo tipo del mismo jugador antes de salir, sustituye al pendiente (sale sólo el
  escalón más alto).
- Anuncio arriba al centro, bajo el contador de la oleada: 3 filas por jugador (UIText de cada jugador, como el
  título de la ronda); el nuevo entra abajo y los anteriores suben; cada uno dura 5 s. Se ocultan con la tienda abierta.
- Marcador: multiboard «Marcador» con jugador (nombre y color), muertes causadas, racha actual y vidas. Se repinta
  cada 0,5 s sólo en las celdas que cambian. Cada cliente lo oculta mientras su tienda está abierta (sólo visual).

Uso: v14zo.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def u8(t):
    return t.encode('utf-8').decode('latin-1')


ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

from v14zo_datos import RACHA, MULTI, SONIDOS, VOCES


def jstr(t):
    return '"%s"' % t.replace('\\', '\\\\')


s = once(s, 'integer Calor_Vivos= 0\n', '''integer Calor_Vivos= 0
integer array Racha_Total
integer array Racha_N
integer array Racha_Tier
integer array Racha_TierN
integer array Racha_Multi
integer array Racha_MultiTier
integer array Racha_MultiN
real array Racha_MultiFin
integer Racha_PrimeraRonda= 0
string array Racha_Nombre
string array Racha_Son
real array Racha_Dur
integer array Racha_MultiUmbral
string array Racha_Voz
string array Racha_ColaTexto
string array Racha_ColaSon
real array Racha_ColaDur
integer array Racha_ColaPid
integer array Racha_ColaTipo
integer Racha_ColaN= 0
real Racha_Espera= 0.
integer Racha_VozPid= -1
real Racha_VozEn= 0.
string array Racha_Fila
real array Racha_FilaFin
integer Racha_Ver= 0
integer array Racha_VerVisto
integer array Racha_UI
boolean array Racha_UIOk
timer Racha_Reloj= null
integer Racha_Pasos= 0
multiboard Racha_Tabla= null
integer array Racha_TablaFila
boolean array Racha_EnTabla
integer Racha_TablaN= 0
string array Racha_Celda
boolean array Racha_TablaVista
''')

datos = []
for t, (n, f, d) in enumerate(RACHA, 1):
    datos.append('        set Racha_Nombre[%d] = "%s"\n        set Racha_Son[%d] = "war3mapImported\\\\%s"\n        set Racha_Dur[%d] = %.2f\n' % (t, n, t, f, t, d))
for t, (n, f, d, k) in enumerate(MULTI, 11):
    datos.append('        set Racha_Nombre[%d] = "%s"\n        set Racha_Son[%d] = "war3mapImported\\\\%s"\n        set Racha_Dur[%d] = %.2f\n        set Racha_MultiUmbral[%d] = %d\n' % (t, n, t, f, t, d, t - 10, k))
voces = ''.join('        set Racha_Voz[%d] = %s\n' % (i, jstr(v)) for i, v in enumerate(VOCES['h005'])) + \
        ''.join('        set Racha_Voz[%d] = %s\n' % (10 + i, jstr(v)) for i, v in enumerate(VOCES['h006']))
assert len(VOCES['h005']) == 4 and len(VOCES['h006']) == 5

modulo = u8('''// v14zo: rachas, anuncios y marcador (ver v14zo.py).
function Racha_NombreJ takes integer p returns string
    return PlayerUtils___OriginalHex[GetHandleId(GetPlayerColor(Player(p)))] + GetPlayerName(Player(p)) + "|r"
endfunction

// Caracteres visibles (sin |cAARRGGBB ni |r), para centrar el texto.
function Racha_Largo takes string s returns integer
    local integer i= 0
    local integer n= 0
    local integer l= StringLength(s)
    loop
        exitwhen i >= l
        if SubString(s, i, i + 2) == "|c" then
            set i = i + 10
        elseif SubString(s, i, i + 2) == "|r" then
            set i = i + 2
        else
            set n = n + 1
            set i = i + 1
        endif
    endloop
    return n
endfunction

function Racha_Sonar takes string f returns nothing
    local sound x= CreateSound(f, false, false, false, 10, 10, "")
    call SetSoundVolume(x, 127)
    call StartSound(x)
    call KillSoundWhenDone(x)
    set x = null
endfunction

// Tipo 1 primera sangre, 2 racha, 3 multikill, 4 racha perdida. Las de tipo 2 y 3 sustituyen a la pendiente del mismo
// jugador y tipo.
function Racha_Poner takes string texto,string son,real dur,integer p,integer tipo returns nothing
    local integer i= 0
    if tipo == 2 or tipo == 3 then
        loop
            exitwhen i >= Racha_ColaN
            if Racha_ColaPid[i] == p and Racha_ColaTipo[i] == tipo then
                set Racha_ColaTexto[i] = texto
                set Racha_ColaSon[i] = son
                set Racha_ColaDur[i] = dur
                return
            endif
            set i = i + 1
        endloop
    endif
    if Racha_ColaN >= 12 then
        return
    endif
    set Racha_ColaTexto[Racha_ColaN] = texto
    set Racha_ColaSon[Racha_ColaN] = son
    set Racha_ColaDur[Racha_ColaN] = dur
    set Racha_ColaPid[Racha_ColaN] = p
    set Racha_ColaTipo[Racha_ColaN] = tipo
    set Racha_ColaN = Racha_ColaN + 1
endfunction

// Fila nueva abajo; si ya hay 3, la más vieja sale por arriba.
function Racha_Anunciar takes string texto returns nothing
    local integer i= 0
    if Racha_Fila[2] != "" then
        set Racha_Fila[0] = Racha_Fila[1]
        set Racha_FilaFin[0] = Racha_FilaFin[1]
        set Racha_Fila[1] = Racha_Fila[2]
        set Racha_FilaFin[1] = Racha_FilaFin[2]
        set Racha_Fila[2] = ""
    endif
    loop
        exitwhen Racha_Fila[i] == ""
        set i = i + 1
    endloop
    set Racha_Fila[i] = texto
    set Racha_FilaFin[i] = 5.
    set Racha_Ver = Racha_Ver + 1
endfunction

function Racha_VozDe takes integer p returns nothing
    if GetUnitTypeId(Game_Hero[p]) == 'h006' then
        call Racha_Sonar(Racha_Voz[10 + GetRandomInt(0, 4)])
    else
        call Racha_Sonar(Racha_Voz[GetRandomInt(0, 3)])
    endif
endfunction

function Racha_Celdas takes integer fila,integer col,string v returns nothing
    local multiboarditem it= MultiboardGetItem(Racha_Tabla, fila, col)
    call MultiboardSetItemValue(it, v)
    call MultiboardReleaseItem(it)
    set it = null
endfunction

function Racha_Pintar takes nothing returns nothing
    local integer p= 0
    local string v
    loop
        exitwhen p > 7
        if Racha_EnTabla[p] then
            set v = I2S(Racha_Total[p])
            if v != Racha_Celda[p * 4 + 1] then
                set Racha_Celda[p * 4 + 1] = v
                call Racha_Celdas(Racha_TablaFila[p], 1, v)
            endif
            set v = I2S(Racha_N[p])
            if v != Racha_Celda[p * 4 + 2] then
                set Racha_Celda[p * 4 + 2] = v
                call Racha_Celdas(Racha_TablaFila[p], 2, v)
            endif
            set v = I2S(IMaxBJ(0, Vidas_Actual[p]))
            if not Game_On[p] then
                set v = "|cff808080-|r"
            endif
            if v != Racha_Celda[p * 4 + 3] then
                set Racha_Celda[p * 4 + 3] = v
                call Racha_Celdas(Racha_TablaFila[p], 3, v)
            endif
        endif
        set p = p + 1
    endloop
endfunction

function Racha_Paso takes nothing returns nothing
    local integer i= 0
    if Racha_VozPid >= 0 then
        set Racha_VozEn = Racha_VozEn - 0.05
        if Racha_VozEn <= 0. then
            call Racha_VozDe(Racha_VozPid)
            set Racha_VozPid = -1
        endif
    endif
    if Racha_Espera > 0. then
        set Racha_Espera = Racha_Espera - 0.05
    elseif Racha_ColaN > 0 then
        call Racha_Anunciar(Racha_ColaTexto[0])
        call Racha_Sonar(Racha_ColaSon[0])
        if Racha_ColaTipo[0] == 4 then
            set Racha_Espera = Racha_ColaDur[0] + 0.3
        else
            set Racha_VozPid = Racha_ColaPid[0]
            set Racha_VozEn = Racha_ColaDur[0] - 0.2
            set Racha_Espera = Racha_ColaDur[0] + 1.9
        endif
        set Racha_ColaN = Racha_ColaN - 1
        loop
            exitwhen i >= Racha_ColaN
            set Racha_ColaTexto[i] = Racha_ColaTexto[i + 1]
            set Racha_ColaSon[i] = Racha_ColaSon[i + 1]
            set Racha_ColaDur[i] = Racha_ColaDur[i + 1]
            set Racha_ColaPid[i] = Racha_ColaPid[i + 1]
            set Racha_ColaTipo[i] = Racha_ColaTipo[i + 1]
            set i = i + 1
        endloop
    endif
    set i = 0
    loop
        exitwhen i > 2
        if Racha_Fila[i] != "" then
            set Racha_FilaFin[i] = Racha_FilaFin[i] - 0.05
        endif
        set i = i + 1
    endloop
    if Racha_Fila[0] != "" and Racha_FilaFin[0] <= 0. then
        set Racha_Fila[0] = Racha_Fila[1]
        set Racha_FilaFin[0] = Racha_FilaFin[1]
        set Racha_Fila[1] = Racha_Fila[2]
        set Racha_FilaFin[1] = Racha_FilaFin[2]
        set Racha_Fila[2] = ""
        set Racha_Ver = Racha_Ver + 1
    endif
    set Racha_Pasos = Racha_Pasos + 1
    if ModuloInteger(Racha_Pasos, 10) == 0 then
        call Racha_Pintar()
    endif
endfunction

// Una baja del jugador p.
function Racha_Muerte takes integer p returns nothing
    local integer t
    local real ahora= TimerGetElapsed(s__RapidPair_clock)
    if p < 0 or p > 7 or not Game_On[p] then
        return
    endif
    set Racha_Total[p] = Racha_Total[p] + 1
    set Racha_N[p] = Racha_N[p] + 1
    if Ronda_Activa and not Ronda_Descanso and Ronda_Numero != Racha_PrimeraRonda then
        set Racha_PrimeraRonda = Ronda_Numero
        call Racha_Poner(Racha_NombreJ(p) + " |cffff3333FIRST BLOOD|r (Wave " + I2S(Ronda_Numero) + ")", "war3mapImported\\\\announcer_1stblood_01.wav", 1.75, p, 1)
    endif
    set t = IMinBJ(8, Racha_N[p] / 25)
    if t > Racha_Tier[p] or ( t == 8 and Racha_N[p] >= Racha_TierN[p] + 25 ) then
        set Racha_Tier[p] = t
        set Racha_TierN[p] = Racha_N[p]
        call Racha_Poner(Racha_NombreJ(p) + " |cffffff00" + Racha_Nombre[t] + "|r (" + I2S(Racha_N[p]) + ")", Racha_Son[t], Racha_Dur[t], p, 2)
    endif
    if ahora <= Racha_MultiFin[p] then
        set Racha_Multi[p] = Racha_Multi[p] + 1
    else
        set Racha_Multi[p] = 1
        set Racha_MultiTier[p] = 0
        set Racha_MultiN[p] = 0
    endif
    set Racha_MultiFin[p] = ahora + 3.
    set t = 4
    loop
        exitwhen t == 0 or Racha_Multi[p] >= Racha_MultiUmbral[t]
        set t = t - 1
    endloop
    if t > Racha_MultiTier[p] or ( t == 4 and Racha_Multi[p] >= Racha_MultiN[p] + 15 ) then
        set Racha_MultiTier[p] = t
        set Racha_MultiN[p] = Racha_Multi[p]
        call Racha_Poner(Racha_NombreJ(p) + " |cff66ccff" + Racha_Nombre[10 + t] + "|r (" + I2S(Racha_Multi[p]) + ")", Racha_Son[10 + t], Racha_Dur[10 + t], p, 3)
    endif
endfunction

// El personaje de p cayó: pierde la racha y el multikill.
function Racha_Romper takes integer p returns nothing
    if Racha_N[p] >= 25 then
        call Racha_Poner(Racha_NombreJ(p) + " |cffff6666perdió su racha|r (" + I2S(Racha_N[p]) + ")", "war3mapImported\\\\RDK_RompeRacha.mp3", 1.64, p, 4)
    endif
    set Racha_N[p] = 0
    set Racha_Tier[p] = 0
    set Racha_TierN[p] = 0
    set Racha_Multi[p] = 0
    set Racha_MultiTier[p] = 0
    set Racha_MultiN[p] = 0
    set Racha_MultiFin[p] = 0.
endfunction

function Racha_Texto takes integer ui,string s,real size,real y returns nothing
    call s__UIText_setPosition(ui,( 960. - I2R(Racha_Largo(s)) * 4.5 * size / 0.017 - 960. ) / 728. , ( 420. - y ) / 390.)
    call SetTextTagText(s__UIText_text[ui], s, size)
endfunction

// En cada repaso del HUD: filas del anuncio y marcador de p (oculto con su tienda abierta).
function Racha_Hud takes integer p,integer cam returns nothing
    local boolean shown= HealthBars__Visible and Game_On[p] and not Shop_Open[p]
    local integer i= 0
    if not Racha_UIOk[p] then
        return
    endif
    loop
        exitwhen i > 2
        call s__UIText_show(Racha_UI[p * 3 + i],shown and Racha_Fila[i] != "" , cam)
        set i = i + 1
    endloop
    if Racha_VerVisto[p] != Racha_Ver then
        set Racha_VerVisto[p] = Racha_Ver
        set i = 0
        loop
            exitwhen i > 2
            call Racha_Texto(Racha_UI[p * 3 + i] , Racha_Fila[i] , 0.013 , 116. + 22. * i)
            set i = i + 1
        endloop
    endif
    if shown != Racha_TablaVista[p] then
        set Racha_TablaVista[p] = shown
        if GetLocalPlayer() == Player(p) then
            call MultiboardDisplay(Racha_Tabla, shown)
            if shown then
                call MultiboardMinimize(Racha_Tabla, false)
            endif
        endif
    endif
endfunction

// Al entrar p en la partida.
function Racha_Alta takes integer p returns nothing
    local integer i= 0
    if Racha_Tabla == null then
''' + ''.join(datos) + voces + '''        set Racha_Fila[0] = ""
        set Racha_Fila[1] = ""
        set Racha_Fila[2] = ""
        set Racha_Tabla = CreateMultiboard()
        call MultiboardSetColumnCount(Racha_Tabla, 4)
        call MultiboardSetRowCount(Racha_Tabla, 1)
        call MultiboardSetTitleText(Racha_Tabla, "Marcador")
        call MultiboardSetItemsStyle(Racha_Tabla, true, false)
        call MultiboardSetItemsWidth(Racha_Tabla, 0.04)
        call Racha_Celdas(0, 0, "|cffffcc00Jugador|r")
        call Racha_Celdas(0, 1, "|cffffcc00Muertes|r")
        call Racha_Celdas(0, 2, "|cffffcc00Racha|r")
        call Racha_Celdas(0, 3, "|cffffcc00Vidas|r")
        set Racha_Reloj = CreateTimer()
        call TimerStart(Racha_Reloj, 0.05, true, function Racha_Paso)
    endif
    if not Racha_UIOk[p] then
        loop
            exitwhen i > 2
            set Racha_UI[p * 3 + i] = s__UIText_createEx(Player(p) , 0. , 0. , 1.)
            call SetTextTagPermanent(s__UIText_text[Racha_UI[p * 3 + i]], true)
            call SetTextTagColor(s__UIText_text[Racha_UI[p * 3 + i]], 255, 255, 255, 255)
            set i = i + 1
        endloop
        set Racha_UIOk[p] = true
        set Racha_VerVisto[p] = -1
    endif
    if not Racha_EnTabla[p] then
        set Racha_TablaN = Racha_TablaN + 1
        set Racha_TablaFila[p] = Racha_TablaN
        set Racha_EnTabla[p] = true
        call MultiboardSetRowCount(Racha_Tabla, Racha_TablaN + 1)
        call Racha_Celdas(Racha_TablaN, 0, Racha_NombreJ(p))
        set i = 0
        loop
            exitwhen i > 3
            set Racha_Celda[p * 4 + i] = ""
            set i = i + 1
        endloop
    endif
    // El nombre es la única columna ancha.
    set i = 0
    loop
        exitwhen i > Racha_TablaN
        set Racha_Celda[63] = ""
        call Racha_Ancho(i)
        set i = i + 1
    endloop
    call Racha_Pintar()
endfunction

''')
# Ancho por fila (MultiboardSetItemsWidth fija todas a 0,04; la columna del nombre, más ancha).
modulo = modulo.replace('''function Racha_Celdas takes integer fila,integer col,string v returns nothing''', '''function Racha_Ancho takes integer fila returns nothing
    local multiboarditem it= MultiboardGetItem(Racha_Tabla, fila, 0)
    call MultiboardSetItemWidth(it, 0.10)
    call MultiboardReleaseItem(it)
    set it = null
endfunction

function Racha_Celdas takes integer fila,integer col,string v returns nothing''')
modulo = modulo.replace('        set Racha_Celda[63] = ""\n', '')
s = once(s, 'function Ronda_Hud takes integer p,integer cam returns nothing\n', modulo + 'function Ronda_Hud takes integer p,integer cam returns nothing\n')

s = once(s, '''            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 5.)) * (2 + Ronda_Numero) / 3)
''', '''            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 5.)) * (2 + Ronda_Numero) / 3)
            call Racha_Muerte(k)
''')
s = once(s, '''    set Vidas_Actual[p] = Vidas_Actual[p] - 1
    call DisplayTimedTextToPlayer(Player(p), 0., 0., 3., "Vidas: " + I2S(Vidas_Actual[p]))
''', '''    set Vidas_Actual[p] = Vidas_Actual[p] - 1
    call DisplayTimedTextToPlayer(Player(p), 0., 0., 3., "Vidas: " + I2S(Vidas_Actual[p]))
    call Racha_Romper(p)
''')
s = once(s, '''    call HealthBarsBindPlayer(p , Game_Cam[p] , Game_Hero[p] , icon)
''', '''    call HealthBarsBindPlayer(p , Game_Cam[p] , Game_Hero[p] , icon)
    call Racha_Alta(p)
''')
s = once(s, '''            call Ronda_Hud(p , cam)
''', '''            call Ronda_Hud(p , cam)
            call Racha_Hud(p , cam)
''')
pre = ''.join('    call Preload("war3mapImported\\\\%s")\n' % f for f in SONIDOS) + \
      ''.join('    call Preload(%s)\n' % jstr(v) for v in VOCES['h005'] + VOCES['h006'])
s = once(s, '    call Preload("war3mapImported\\\\InterceptorShell6.mdx")\n', '    call Preload("war3mapImported\\\\InterceptorShell6.mdx")\n' + pre)
for a, b in (('function Racha_Ancho takes', 'function Racha_Alta takes'), ('function Racha_Muerte takes', 'function Oro_Muerte takes'),
             ('function Racha_Romper takes', 'function s__RapidPair_fall takes'), ('function Racha_Hud takes', 'function Ronda_Hud takes'),
             ('function Racha_Alta takes', 'function Game_Enter takes')):
    assert s.index(a) < s.index(b), (a, b)
Path(sal).write_text(s, encoding='latin-1', newline='')
print('sonidos', len(SONIDOS))
