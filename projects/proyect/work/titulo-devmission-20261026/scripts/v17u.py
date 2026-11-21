#!/usr/bin/env python3
"""v17u (14/11/2026): cuadros pulidos y súper élite al azar (fase 2 de devmission-mejoras-darkmoon.md).

Leon: "pullir y avanzar la siguiente fase". Lo visto en el vídeo de v17t (14/11 22:55):
- La descripción salía pequeña (0,016) y la mitad de abajo del cuadro quedaba vacía: cuadro de 480 de alto en vez de
  560, icono de 190, nombre 0,025 y descripción 0,021; el botón sube a 610 con su zona de clic.
- "Elegir" caía en el borde de abajo del botón: el texto se dibuja ~25 px por debajo de su punto, se sube.
- El pie se partía en 2 líneas: texto más corto.
- Los avisos "(aún sin efecto)" tapaban los cuadros y seguían en la tienda: ya no se muestran al elegir; lo elegido se
  resume en un solo aviso al empezar la oleada.

Súper élite (Dark Moon, holdout_game_boost_creeps.lua, valores nightmare para probar):
- Durante la oleada, la primera a los 6 s y luego cada 20-30 s al azar (2 s de reintento si no hay candidatos).
- Un enemigo común vivo al azar (los 10 tipos de oleada; nunca élite 'ne0*', jefe 'nj0*' ni otra súper élite).
- Vida y daño × (1,25 + 0,05 × (ronda − 1)), máximo × 2,25. La vida con 'Sp0L' (mismo truco que DevFuego_Aparece),
  el daño con 'Sp0M' sobre el daño medio del tipo (dados de UnitWeapons.slk de 1.27b; el mapa no los cambia).
- 2 mejoras de estadística distintas de 7 (daño, armadura, robo de vida, velocidad de ataque, evasión, regeneración,
  velocidad de movimiento): base 28/30/32/34 al azar + 2 por ronda, × tramo de ronda (1-3, 4-6, 7-11, 12+): daño
  0,75/1,5/2,5/4; velocidad de ataque 0,75/1/1,25/1,5; movimiento 1,5; armadura, robo de vida, evasión y
  regeneración 1/3, 0,5, 0,65, 0,8 (los tres últimos los decidí yo: el plan sólo da ejemplos). Evasión hasta 50 %.
- 2 pasivas distintas de 7 habilidades de WC3 sin auras: Golpe aplastante 'AIbx', Golpe crítico 'AIcs', Piel
  endurecida 'Assk', Caparazón espinoso 'ANth', Ataque hendiente 'ACce', Orbe de escarcha 'AIob', Veneno lento
  'AIsz' (los dos orbes no van juntos).
- Marca: calavera roja de Frenesí profano sobre la cabeza.
- HUD: 4 tarjetas a la izquierda (2 de estadística con icono y valor, 2 de habilidad con icono y nombre) y una
  cabecera, de la súper élite más reciente que siga viva; se ocultan con la tienda o los cuadros abiertos.
Prueba (tercer argumento "prueba"): cada súper élite, sus valores y niveles reales en lat\\v17u-super.txt; el
registro de los cuadros pasa a lat\\v17u-cuadros.txt.
Uso: v17u.py v17t/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


# ---------------------------------------------------------------- cuadros
una('''    call Cua_Centro(p, Cua_TPie, "Esc: salir (lo elegido se guarda hasta que empiece la oleada)", 960, 790, 0.018)''',
    '''    call Cua_Centro(p, Cua_TPie, "Esc: salir (se guarda hasta la oleada)", 960, 700, 0.018)''')
una('''            call Cua_Centro(p, Cua_TN[c], Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 380, 0.022)
            call Cua_Izq(p, Cua_TD[c], Cua_Des[Cua_Item(p, c)], Cua_PX(s) - 140, 440, 0.016)
            call Cua_Centro(p, Cua_TB[c], "Elegir", Cua_PX(s), 690, 0.02)''',
    '''            call Cua_Centro(p, Cua_TN[c], Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 392, 0.025)
            call Cua_Izq(p, Cua_TD[c], Cua_Des[Cua_Item(p, c)], Cua_PX(s) - 150, 440, 0.021)
            call Cua_Centro(p, Cua_TB[c], "Elegir", Cua_PX(s), 586, 0.022)''')
una('''            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 430, 330, 560, 430, 'DS01')
            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 690, 170, 56, 399, 'DS0A')''',
    '''            set Cua_Bg[s] = Cua_Pic(Cua_PX(s), 410, 330, 480, 430, 'DS01')
            set Cua_Bt[s] = Cua_Pic(Cua_PX(s), 610, 170, 56, 399, 'DS0A')''')
una('''                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 250, 150, 150, 405, 'DC00')
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(s), 690, 40 + s)''',
    '''                    set Cua_Ico[p * 9 + s] = Cua_Pic(Cua_PX(s), 275, 190, 190, 405, 'DC00')
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitBtn.mdx", Cua_PX(s), 610, 40 + s)''')
una('''    if Cua_Paso[p] < 3 then
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 6, "|cffff5064Mutación Evo|r: " + Cua_Nom[x] + " (aún sin efecto)")
    else
        call DisplayTimedTextToPlayer(Player(p), 0, 0, 6, "|cff78f08cMejora del héroe|r: " + Cua_Nom[x] + " (aún sin efecto)")
    endif''', '''    // v17u: sin aviso al elegir (tapaba los cuadros y seguía en la tienda); se resume al empezar la oleada.
    if StringLength(Cua_Resumen[p]) > 0 then
        set Cua_Resumen[p] = Cua_Resumen[p] + ", "
    endif
    if Cua_Paso[p] < 3 then
        set Cua_Resumen[p] = Cua_Resumen[p] + "|cffff5064" + Cua_Nom[x] + "|r"
    else
        set Cua_Resumen[p] = Cua_Resumen[p] + "|cff78f08c" + Cua_Nom[x] + "|r"
    endif''')

# ---------------------------------------------------------------- súper élite
globales = '''string array Cua_Resumen
constant integer Sup_MAX = 16
boolean Sup_Listo = false
timer Sup_Reloj = null
group Sup_G = null
unit array Sup_U
effect array Sup_Fx
real array Sup_M
integer array Sup_St
integer array Sup_Val
integer array Sup_Pa
integer Sup_N = 0
integer Sup_Vista = -1
integer Sup_Ver = 0
integer array Sup_StHab
string array Sup_StNom
integer array Sup_PaId
string array Sup_PaNom
integer array Sup_Tex
boolean array Sup_HudOk
integer array Sup_Visto
unit array Sup_Bg
unit array Sup_Ico
integer array Sup_TT
'''
if prueba:
    globales += '''integer Sup_LN = 0
string array Sup_L
timer Sup_LT = null
timer Sup_Tiempo = null
'''
una('''unit array Menu_Ancla
''', '''unit array Menu_Ancla
''' + globales)

registro = '''// v17u-prueba: cada súper élite en CustomMapData\\\\lat\\\\v17u-super.txt, 1 s después del último evento.
function Sup_Escribir takes nothing returns nothing
    local integer i = 0
    call PreloadGenClear()
    loop
        exitwhen i >= Sup_LN
        call Preload(Sup_L[i])
        set i = i + 1
    endloop
    call PreloadGenEnd("lat\\\\v17u-super.txt")
endfunction

function Sup_Anotar takes string s returns nothing
    if Sup_Tiempo == null then
        set Sup_Tiempo = CreateTimer()
        call TimerStart(Sup_Tiempo, 100000., false, null)
        set Sup_LT = CreateTimer()
    endif
    if Sup_LN >= 200 then
        return
    endif
    set Sup_L[Sup_LN] = R2S(TimerGetElapsed(Sup_Tiempo)) + " " + s
    set Sup_LN = Sup_LN + 1
    call TimerStart(Sup_LT, 1., false, function Sup_Escribir)
endfunction

''' if prueba else ''

anotar_crear = '''    call Sup_Anotar("r" + I2S(r) + " super " + I2S(i) + " " + UnitId2String(id) + " de " + I2S(n) + " candidatos; x" + R2SW(m, 1, 2) + " vida " + R2SW(hp, 1, 0) + "->" + R2SW(GetUnitState(u, UNIT_STATE_MAX_LIFE), 1, 0) + " (" + R2SW(GetWidgetLife(u), 1, 0) + ") dano+" + I2S(GetUnitAbilityLevel(u, 'Sp0M')) + " | " + Sup_StNom[Sup_St[i * 2]] + " " + I2S(Sup_Val[i * 2]) + " nivel " + I2S(GetUnitAbilityLevel(u, Sup_StHab[Sup_St[i * 2]])) + " | " + Sup_StNom[Sup_St[i * 2 + 1]] + " " + I2S(Sup_Val[i * 2 + 1]) + " nivel " + I2S(GetUnitAbilityLevel(u, Sup_StHab[Sup_St[i * 2 + 1]])) + " | " + Sup_PaNom[Sup_Pa[i * 2]] + " " + I2S(GetUnitAbilityLevel(u, Sup_PaId[Sup_Pa[i * 2]])) + " | " + Sup_PaNom[Sup_Pa[i * 2 + 1]] + " " + I2S(GetUnitAbilityLevel(u, Sup_PaId[Sup_Pa[i * 2 + 1]])))
''' if prueba else ''
anotar_muere = '''            call Sup_Anotar("muere super " + I2S(i) + "; se muestra " + I2S(Sup_Vista))
''' if prueba else ''
anotar_parar = '''    call Sup_Anotar("fin de oleada r" + I2S(Ronda_Numero))
''' if prueba else ''
anotar_reintento = '''        call Sup_Anotar("sin candidatos, reintento en 2 s")
''' if prueba else ''
anotar_pintar = '''    call Sup_Anotar("tarjetas: super " + I2S(Sup_Vista) + ", iconos " + I2S(c))
''' if prueba else ''

bloque = registro + '''// v17u: súper élite (Dark Moon). Daño medio de los 10 tipos comunes (UnitWeapons.slk 1.27b: base + dados ×
// (caras + 1) / 2); 0 para lo demás, que así no puede ser elegido.
function Sup_Base takes integer id returns real
    if id == 'nmcf' or id == 'nlpr' then
        return 10.5
    elseif id == 'ntrh' then
        return 6.5
    elseif id == 'nmtw' then
        return 14.5
    elseif id == 'nmsn' then
        return 8.5
    elseif id == 'nlds' then
        return 9.5
    elseif id == 'nmmu' then
        return 15.
    elseif id == 'nnsw' then
        return 7.5
    elseif id == 'ntrg' then
        return 19.
    elseif id == 'ntrd' then
        return 32.5
    endif
    return 0.
endfunction

// Tarjetas: quita los iconos de todos y crea los de la súper élite que se muestra. La textura sólo prende al crear
// el dummy (Arm_HudCrear), así que se recrean; código común (muerte, temporizador, fin de oleada).
function Sup_Pintar takes nothing returns nothing
    local integer p = 0
    local integer k
    local integer c = 0
    local integer i = Sup_Vista
    local integer tex
    local unit u
    set Sup_Ver = Sup_Ver + 1
    loop
        exitwhen p > 11
        if Sup_HudOk[p] then
            set k = 0
            loop
                exitwhen k > 3
                if Sup_Ico[p * 4 + k] != null then
                    call RemoveUnit(Sup_Ico[p * 4 + k])
                    set Sup_Ico[p * 4 + k] = null
                endif
                if i >= 0 then
                    if k < 2 then
                        set tex = Sup_Tex[Sup_St[i * 2 + k]]
                    else
                        set tex = Sup_Tex[7 + Sup_Pa[i * 2 + k - 2]]
                    endif
                    set u = HealthBars__Dummy('uidb', p)
                    call UnitAddAbility(u, s__Interface_LOCUST_ID)
                    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
                    call Arm_Foto(u, 46., 46., tex)
                    call ShowUnit(u, false)
                    set Sup_Ico[p * 4 + k] = u
                    set c = c + 1
                endif
                set k = k + 1
            endloop
        endif
        set p = p + 1
    endloop
''' + anotar_pintar + '''    set u = null
endfunction

function Sup_Muere takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer i = 0
    local integer k
    local integer j
    if GetUnitAbilityLevel(u, 'Sp0M') == 0 then
        set u = null
        return
    endif
    loop
        exitwhen i >= Sup_MAX
        if Sup_U[i] == u then
            call DestroyEffect(Sup_Fx[i])
            set Sup_Fx[i] = null
            set Sup_U[i] = null
            if i == Sup_Vista then
                // La más reciente que siga viva.
                set Sup_Vista = -1
                set k = 1
                loop
                    exitwhen k > Sup_MAX or Sup_Vista >= 0
                    set j = ModuloInteger(Sup_N - k + Sup_MAX, Sup_MAX)
                    if Sup_U[j] != null and UnitAlive(Sup_U[j]) then
                        set Sup_Vista = j
                    endif
                    set k = k + 1
                endloop
                call Sup_Pintar()
            endif
''' + anotar_muere + '''        endif
        set i = i + 1
    endloop
    set u = null
endfunction

function Sup_Init takes nothing returns nothing
    if Sup_Listo then
        return
    endif
    set Sup_Listo = true
    set Sup_G = CreateGroup()
    set Sup_StHab[0] = 'Sp0D'
    set Sup_StNom[0] = " de daño"
    set Sup_StHab[1] = 'Sp0A'
    set Sup_StNom[1] = " de armadura"
    set Sup_StHab[2] = 'Sp0V'
    set Sup_StNom[2] = "% de robo de vida"
    set Sup_StHab[3] = 'Sp0S'
    set Sup_StNom[3] = "% vel. de ataque"
    set Sup_StHab[4] = 'Sp0E'
    set Sup_StNom[4] = "% de evasión"
    set Sup_StHab[5] = 'Sp0R'
    set Sup_StNom[5] = " de vida por segundo"
    set Sup_StHab[6] = 'Sp0O'
    set Sup_StNom[6] = " vel. de movimiento"
    set Sup_PaId[0] = 'AIbx'
    set Sup_PaNom[0] = "Golpe aplastante"
    set Sup_PaId[1] = 'AIcs'
    set Sup_PaNom[1] = "Golpe crítico"
    set Sup_PaId[2] = 'Assk'
    set Sup_PaNom[2] = "Piel endurecida"
    set Sup_PaId[3] = 'ANth'
    set Sup_PaNom[3] = "Caparazón espinoso"
    set Sup_PaId[4] = 'ACce'
    set Sup_PaNom[4] = "Ataque hendiente"
    set Sup_PaId[5] = 'AIob'
    set Sup_PaNom[5] = "Orbe de escarcha"
    set Sup_PaId[6] = 'AIsz'
    set Sup_PaNom[6] = "Veneno lento"
    set Sup_Tex[0] = 'DE00'
    set Sup_Tex[1] = 'DE01'
    set Sup_Tex[2] = 'DE02'
    set Sup_Tex[3] = 'DE03'
    set Sup_Tex[4] = 'DE04'
    set Sup_Tex[5] = 'DE05'
    set Sup_Tex[6] = 'DE06'
    set Sup_Tex[7] = 'DE07'
    set Sup_Tex[8] = 'DE08'
    set Sup_Tex[9] = 'DE09'
    set Sup_Tex[10] = 'DE0A'
    set Sup_Tex[11] = 'DE0B'
    set Sup_Tex[12] = 'DE0C'
    set Sup_Tex[13] = 'DE0D'
    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function Sup_Muere)
endfunction

// Valor de la mejora t en la ronda r: base nightmare 28/30/32/34 + 2 por ronda, por el tramo de ronda; hacia abajo.
function Sup_Valor takes integer t, integer r returns integer
    local real v = I2R(28 + 2 * GetRandomInt(0, 3) + 2 * (r - 1))
    local integer f = 0
    if r >= 12 then
        set f = 3
    elseif r >= 7 then
        set f = 2
    elseif r >= 4 then
        set f = 1
    endif
    if t == 0 then
        if f == 0 then
            set v = v * 0.75
        elseif f == 1 then
            set v = v * 1.5
        elseif f == 2 then
            set v = v * 2.5
        else
            set v = v * 4.
        endif
    elseif t == 3 then
        set v = v * (0.75 + 0.25 * f)
    elseif t == 6 then
        set v = v * 1.5
    elseif f == 0 then
        set v = v / 3.
    elseif f == 1 then
        set v = v * 0.5
    elseif f == 2 then
        set v = v * 0.65
    else
        set v = v * 0.8
    endif
    return R2I(v)
endfunction

function Sup_Vale takes unit u returns boolean
    return UnitAlive(u) and not IsUnitHidden(u) and GetUnitAbilityLevel(u, 'Sp0M') == 0 and Sup_Base(GetUnitTypeId(u)) > 0.
endfunction

// Elige al azar entre todos los candidatos (uno a uno, con probabilidad 1/n) y le da todo. Código común.
function Sup_Crear takes nothing returns boolean
    local integer o = WAVE_DEFAULT_OWNER_MIN
    local integer n = 0
    local integer r = IMaxBJ(1, Ronda_Numero)
    local integer i
    local integer k
    local integer t
    local integer v
    local integer b
    local integer id
    local real m
    local real hp
    local real vida
    local unit u
    local unit e = null
    loop
        exitwhen o > WAVE_DEFAULT_OWNER_MAX
        call GroupEnumUnitsOfPlayer(Sup_G, Player(o), null)
        loop
            set u = FirstOfGroup(Sup_G)
            exitwhen u == null
            call GroupRemoveUnit(Sup_G, u)
            if Sup_Vale(u) then
                set n = n + 1
                if GetRandomInt(1, n) == 1 then
                    set e = u
                endif
            endif
        endloop
        set o = o + 1
    endloop
    if e == null then
        return false
    endif
    set u = e
    set id = GetUnitTypeId(u)
    set i = Sup_N
    set Sup_N = ModuloInteger(Sup_N + 1, Sup_MAX)
    if Sup_Fx[i] != null then
        call DestroyEffect(Sup_Fx[i])
    endif
    set m = RMinBJ(2.25, 1.25 + 0.05 * (r - 1))
    set Sup_M[i] = m
    // Vida: 'Sp0L' nivel b + 2 da 2^b; al quitarla se resta el nivel 1, que es 0. Se conserva la proporción.
    set hp = GetUnitState(u, UNIT_STATE_MAX_LIFE)
    set vida = GetWidgetLife(u)
    set v = R2I(hp * (m - 1.) + 0.5)
    set b = 0
    loop
        exitwhen v <= 0 or b > 13
        if ModuloInteger(v, 2) == 1 then
            call UnitAddAbility(u, 'Sp0L')
            call SetUnitAbilityLevel(u, 'Sp0L', b + 2)
            call UnitRemoveAbility(u, 'Sp0L')
        endif
        set v = v / 2
        set b = b + 1
    endloop
    call SetWidgetLife(u, vida * GetUnitState(u, UNIT_STATE_MAX_LIFE) / hp)
    call UnitAddAbility(u, 'Sp0M')
    call SetUnitAbilityLevel(u, 'Sp0M', IMaxBJ(1, IMinBJ(60, R2I(Sup_Base(id) * (m - 1.) + 0.5))))
    // 2 mejoras de estadística distintas.
    set Sup_St[i * 2] = GetRandomInt(0, 6)
    set t = GetRandomInt(0, 5)
    if t >= Sup_St[i * 2] then
        set t = t + 1
    endif
    set Sup_St[i * 2 + 1] = t
    set k = 0
    loop
        exitwhen k > 1
        set t = Sup_St[i * 2 + k]
        set v = Sup_Valor(t, r)
        if t == 0 then
            set v = IMaxBJ(1, IMinBJ(100, v / 2))
            set Sup_Val[i * 2 + k] = 2 * v
        else
            if t == 4 then
                set v = IMinBJ(50, v)
            endif
            set v = IMaxBJ(1, IMinBJ(100, v))
            set Sup_Val[i * 2 + k] = v
        endif
        call UnitAddAbility(u, Sup_StHab[t])
        call SetUnitAbilityLevel(u, Sup_StHab[t], v)
        set k = k + 1
    endloop
    // 2 pasivas distintas; los dos orbes (5 y 6) no van juntos.
    set Sup_Pa[i * 2] = GetRandomInt(0, 6)
    loop
        set t = GetRandomInt(0, 6)
        exitwhen t != Sup_Pa[i * 2] and not (t >= 5 and Sup_Pa[i * 2] >= 5)
    endloop
    set Sup_Pa[i * 2 + 1] = t
    call UnitAddAbility(u, Sup_PaId[Sup_Pa[i * 2]])
    call UnitAddAbility(u, Sup_PaId[t])
    set Sup_Fx[i] = AddSpecialEffectTarget("Abilities\\\\Spells\\\\Undead\\\\UnholyFrenzy\\\\UnholyFrenzyTarget.mdl", u, "overhead")
    set Sup_U[i] = u
    set Sup_Vista = i
''' + anotar_crear + '''    call Sup_Pintar()
    set u = null
    set e = null
    return true
endfunction

function Sup_Tick takes nothing returns nothing
    if not Ronda_Activa or Ronda_Descanso then
        return
    endif
    if Sup_Crear() then
        call TimerStart(Sup_Reloj, GetRandomReal(20., 30.), false, function Sup_Tick)
    else
''' + anotar_reintento + '''        call TimerStart(Sup_Reloj, 2., false, function Sup_Tick)
    endif
endfunction

// Al lanzar cada oleada (Ronda_Lanzar): primera a los 6 s; resumen de lo elegido en los cuadros.
function Sup_Ronda takes nothing returns nothing
    local integer p = 0
    call Sup_Init()
    if Sup_Reloj == null then
        set Sup_Reloj = CreateTimer()
    endif
    call TimerStart(Sup_Reloj, 6., false, function Sup_Tick)
    loop
        exitwhen p > 11
        if StringLength(Cua_Resumen[p]) > 0 then
            call DisplayTimedTextToPlayer(Player(p), 0, 0, 8, "Elegido para esta oleada (aún sin efecto): " + Cua_Resumen[p])
            set Cua_Resumen[p] = ""
        endif
        set p = p + 1
    endloop
endfunction

// Al acabar la oleada: sin temporizador ni tarjetas.
function Sup_Parar takes nothing returns nothing
    local integer i = 0
    if Sup_Reloj != null then
        call PauseTimer(Sup_Reloj)
    endif
    loop
        exitwhen i >= Sup_MAX
        if Sup_Fx[i] != null then
            call DestroyEffect(Sup_Fx[i])
            set Sup_Fx[i] = null
        endif
        set Sup_U[i] = null
        set i = i + 1
    endloop
    if Sup_Vista >= 0 then
        set Sup_Vista = -1
        call Sup_Pintar()
    endif
''' + anotar_parar + '''endfunction

// Fondos (cuadro de racha 'DS18', dorado o violeta) y 5 textos locales por jugador; los iconos, en Sup_Pintar.
function Sup_HudCrear takes integer p returns nothing
    local integer k = 0
    local integer a = 0
    local unit u
    call Sup_Init()
    if GetLocalPlayer() == Player(p) then
        set a = 255
    endif
    loop
        exitwhen k > 3
        set u = HealthBars__Dummy('uidb', p)
        call UnitAddAbility(u, s__Interface_LOCUST_ID)
        call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
        call Arm_Foto(u, 300., 56., 'DS18')
        if k < 2 then
            call SetUnitVertexColor(u, 255, 200, 110, a)
        else
            call SetUnitVertexColor(u, 190, 140, 255, a)
        endif
        call ShowUnit(u, false)
        set Sup_Bg[p * 4 + k] = u
        set Sup_Ico[p * 4 + k] = null
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 4
        set Sup_TT[p * 5 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
        call SetTextTagPermanent(s__UIText_text[Sup_TT[p * 5 + k]], true)
        if k == 0 then
            call JefeTx_Color(Sup_TT[p * 5], s__UIText_text[Sup_TT[p * 5]], 255, 90, 90)
        elseif k < 3 then
            call JefeTx_Color(Sup_TT[p * 5 + k], s__UIText_text[Sup_TT[p * 5 + k]], 255, 220, 140)
        else
            call JefeTx_Color(Sup_TT[p * 5 + k], s__UIText_text[Sup_TT[p * 5 + k]], 210, 180, 255)
        endif
        set k = k + 1
    endloop
    set Sup_Visto[p] = -1
    set Sup_HudOk[p] = true
    set u = null
endfunction

function Sup_Texto takes integer ui, string s, real x, real y, real size returns nothing
    call s__UIText_setPosition(ui, (x - 960.) / 728., (420. - y) / 390.)
    call JefeTx_Texto(ui, s__UIText_text[ui], s, size)
endfunction

// En el tick del HUD, como Arm_Hud: tarjetas a la izquierda, debajo del arma (y 345 + 62 por tarjeta).
function Sup_Hud takes integer p, integer cam returns nothing
    local boolean shown
    local integer k = 0
    local integer i = Sup_Vista
    local real y
    local unit u
    if not Sup_HudOk[p] then
        return
    endif
    set shown = i >= 0 and HealthBars__Visible and Game_On[p] and not Shop_Open[p]
    call s__UIText_show(Sup_TT[p * 5], shown, cam)
    loop
        exitwhen k > 3
        set y = 345. + 62. * k
        set u = Sup_Ico[p * 4 + k]
        call Hud_Ver(Sup_Bg[p * 4 + k], shown)
        call Hud_Ver(u, shown and u != null)
        call s__UIText_show(Sup_TT[p * 5 + 1 + k], shown, cam)
        if shown then
            call HealthBars__Place(Sup_Bg[p * 4 + k], cam, 180., y, 400.)
            if u != null then
                call HealthBars__Place(u, cam, 60., y, 398.)
            endif
        endif
        set k = k + 1
    endloop
    if shown and Sup_Visto[p] != Sup_Ver then
        set Sup_Visto[p] = Sup_Ver
        call Sup_Texto(Sup_TT[p * 5], "Súper élite: vida y daño ×" + R2SW(Sup_M[i], 1, 2), 30., 296., 0.017)
        set k = 0
        loop
            exitwhen k > 3
            set y = 345. + 62. * k - 11.
            if k < 2 then
                call Sup_Texto(Sup_TT[p * 5 + 1 + k], "+" + I2S(Sup_Val[i * 2 + k]) + Sup_StNom[Sup_St[i * 2 + k]], 92., y, 0.017)
            else
                call Sup_Texto(Sup_TT[p * 5 + 1 + k], Sup_PaNom[Sup_Pa[i * 2 + k - 2]], 92., y, 0.017)
            endif
            set k = k + 1
        endloop
    endif
    set u = null
endfunction

'''
una('''// Inversa de win2World con la cámara lógica del jugador''', bloque + '''// Inversa de win2World con la cámara lógica del jugador''')
una('''            call Arm_Hud(p , cam)
''', '''            call Arm_Hud(p , cam)
            call Sup_Hud(p , cam)
''')
una('''    call Arm_HudCrear(p)
''', '''    call Arm_HudCrear(p)
    call Sup_HudCrear(p)
''')
una('''    call DevWave_Start(Ronda_Numero)
    call Ronda_TemaEmpezar()
''', '''    call DevWave_Start(Ronda_Numero)
    call Ronda_TemaEmpezar()
    call Sup_Ronda()
''')
una('''        call ExecuteFunc("Cua_Sortear")
''', '''        call ExecuteFunc("Cua_Sortear")
        call Sup_Parar()
''')
if prueba:
    una('call PreloadGenEnd("lat\\\\v17t-cuadros.txt")', 'call PreloadGenEnd("lat\\\\v17u-cuadros.txt")')

Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17u: cuadros pulidos + súper élite' + (' + registro' if prueba else ''))
