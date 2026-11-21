#!/usr/bin/env python3
"""v20c (20/11/2026): fase 8 segunda parte (modelos del MVP y de quien menos puntos) y rachas más difíciles.
- Modelos: al fijarse el resultado aparece en el cuadro MVP una copia del personaje del MVP y, con 2 o más jugadores,
  en el de menos puntos la de quien menos hizo. Son unidades del mismo tipo que el personaje (como el controlador),
  del jugador de cámara, sin selección (Locust), invulnerables, sin ataque, con forma voladora para la altura. Una por
  jugador y cuadro, cerca de su cámara (HealthBars__Place a distancia 360, x 1345) y sólo visible para él (alfa).
  Con GoodJob.wav el MVP hace la animación de ataque y vuelve a stand; con QuestFailed.wav el otro hace la de muerte y
  a los 1,2 s se congela (sin cadáver ni sonido de muerte de unidad). Se quitan al acabar el cuadro.
  Los nombres siguen pasando rápido durante los 2,5 s; los modelos no (una unidad por jugador, cuadro y personaje).
- Rachas más difíciles (en la prueba de v20a hubo 3 pulls extra en cada oleada, casi todo por multi-kill):
  - multi-kill 15 / 28 / 45 / 70 (antes 12 / 22 / 35 / 55);
  - el multi-kill sólo da punto de racha la primera vez que se alcanza cada tier en la oleada (antes cada ráfaga);
  - un pull extra cada 3 puntos (antes 2), máximo 2.
- Prueba: registro "mvp modelos ronda N gana T pierde T" con los tipos de unidad.
Uso: v20c.py ENTRADA.j SALIDA.j [prueba]   (normal de v20b; prueba de v20b-prueba)
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


# --- globales ---
cambia('integer array Racha_Pts\n', '''integer array Racha_Pts
// v20c: mejor tier de multi-kill de la oleada (sólo da punto la primera vez) y modelos del cuadro MVP.
integer array Racha_MultiOla
unit array Mvp_Mod
integer Mvp_ModEst = 0
constant real MVP_MOD_ESCALA = 0.40
constant real MVP_MOD_X = 1345.
constant real MVP_MOD_RANGO = 360.
constant real MVP_MOD_GIRO = 290.
''')

# --- rachas ---
for k, viejo, nuevo in ((1, 12, 15), (2, 22, 28), (3, 35, 45), (4, 55, 70)):
    cambia('set Racha_MultiUmbral[%d] = %d\n' % (k, viejo), 'set Racha_MultiUmbral[%d] = %d\n' % (k, nuevo))
cambia('''        if Ronda_Activa and not Ronda_Descanso then
            set Racha_Pts[p] = Racha_Pts[p] + 1
            set Racha_Max[p] = IMaxBJ(Racha_Max[p], t)
        endif
        set Racha_MultiTier[p] = t''', '''        if Ronda_Activa and not Ronda_Descanso and t > Racha_MultiOla[p] then
            set Racha_Pts[p] = Racha_Pts[p] + 1
            set Racha_Max[p] = IMaxBJ(Racha_Max[p], t)
            set Racha_MultiOla[p] = t
        endif
        set Racha_MultiTier[p] = t''')
cambia('set e = IMinBJ(2, Racha_Pts[p] / 2)', 'set e = IMinBJ(2, Racha_Pts[p] / 3)')
cambia('''            set Racha_Pts[p] = 0
            set Racha_Max[p] = 0
''', '''            set Racha_Pts[p] = 0
            set Racha_Max[p] = 0
            set Racha_MultiOla[p] = 0
''')

# --- modelos: quitar (antes de Punt_TxQuitar) ---
cambia('''function Punt_TxQuitar takes nothing returns nothing
    local integer p = 0
    local integer k
''', '''// v20c: quita los modelos del cuadro MVP / menos puntos.
function Mvp_ModQuitar takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 23
        if Mvp_Mod[i] != null then
            call RemoveUnit(Mvp_Mod[i])
            set Mvp_Mod[i] = null
        endif
        set i = i + 1
    endloop
    set Mvp_ModEst = 0
endfunction

function Punt_TxQuitar takes nothing returns nothing
    local integer p = 0
    local integer k
    call Mvp_ModQuitar()
''')

# --- modelos: crear y animar (antes de Mvp_Tick) ---
cambia('''function Mvp_Tick takes nothing returns nothing
''', '''// v20c: copia del personaje h para el cuadro de p (igual en todos los clientes; sólo p la ve).
function Mvp_Modelo takes integer p, unit h returns unit
    local unit u
    local integer alfa = 0
    if h == null or GetUnitTypeId(h) == 0 then
        return null
    endif
    set u = CreateUnit(CAMERA_DUMMY_PLAYER, GetUnitTypeId(h), 0., 0., MVP_MOD_GIRO)
    call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, 'Aatk')
    call UnitRemoveAbility(u, 'AInv')
    call SetUnitInvulnerable(u, true)
    call SetUnitAcquireRange(u, 0.)
    call SetUnitScale(u, MVP_MOD_ESCALA, MVP_MOD_ESCALA, MVP_MOD_ESCALA)
    call SetUnitFacing(u, MVP_MOD_GIRO)
    if GetLocalPlayer() == Player(p) then
        set alfa = 255
    endif
    call SetUnitVertexColor(u, 255, 255, 255, alfa)
    call ShowUnit(u, false)
    call SetUnitAnimation(u, "stand")
    set bj_lastCreatedUnit = u
    set u = null
    return bj_lastCreatedUnit
endfunction

// v20c: al fijarse el resultado, los modelos; con GoodJob, ataque del MVP; con QuestFailed, muerte del otro.
function Mvp_ModTick takes nothing returns nothing
    local integer p = 0
    if Mvp_N <= 0 or Mvp_Gana < 0 then
        return
    endif
    if Mvp_ModEst == 0 and Punt_T >= Mvp_Fija then
        set Mvp_ModEst = 1
        loop
            exitwhen p > 11
            if Punt_Ok[p] and Game_On[p] then
                set Mvp_Mod[p * 2] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Gana]])
                if Mvp_Pierde >= 0 then
                    set Mvp_Mod[p * 2 + 1] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Pierde]])
                endif
            endif
            set p = p + 1
        endloop
    elseif Mvp_ModEst == 1 and Punt_T >= Mvp_Fija + 0.5 then
        set Mvp_ModEst = 2
        loop
            exitwhen p > 11
            if Mvp_Mod[p * 2] != null then
                call SetUnitAnimation(Mvp_Mod[p * 2], "attack")
                call QueueUnitAnimation(Mvp_Mod[p * 2], "stand")
            endif
            set p = p + 1
        endloop
    elseif Mvp_ModEst == 2 and Punt_T >= Mvp_Fija + 2. then
        set Mvp_ModEst = 3
        loop
            exitwhen p > 11
            if Mvp_Mod[p * 2 + 1] != null then
                call SetUnitAnimation(Mvp_Mod[p * 2 + 1], "death")
            endif
            set p = p + 1
        endloop
    elseif Mvp_ModEst == 3 and Punt_T >= Mvp_Fija + 3.2 then
        set Mvp_ModEst = 4
        loop
            exitwhen p > 11
            if Mvp_Mod[p * 2 + 1] != null then
                call SetUnitTimeScale(Mvp_Mod[p * 2 + 1], 0.)
            endif
            set p = p + 1
        endloop
    endif
endfunction

function Mvp_Tick takes nothing returns nothing
''')
cambia('''    if Punt_T < 0. or Mvp_N <= 0 then
        return
    endif
    set b = R2I(Punt_T / 0.06)''', '''    if Punt_T < 0. or Mvp_N <= 0 then
        return
    endif
    call Mvp_ModTick()
    set b = R2I(Punt_T / 0.06)''')

# --- modelos: colocar con el cuadro (Punt_Hud, cámara de p) ---
cambia('''    call HealthBars__Place(Punt_Lado[p], cam, 1265.0, 380.0 + dy, 412.)
''', '''    call HealthBars__Place(Punt_Lado[p], cam, 1265.0, 380.0 + dy, 412.)
    // v20c: modelos con los pies cerca del borde de abajo de cada cuadro (MVP y menos puntos).
    if Mvp_Mod[p * 2] != null then
        call HealthBars__Place(Mvp_Mod[p * 2], cam, MVP_MOD_X, 352.0 + dy, MVP_MOD_RANGO)
        call Hud_Ver(Mvp_Mod[p * 2], true)
    endif
    if Mvp_Mod[p * 2 + 1] != null then
        call HealthBars__Place(Mvp_Mod[p * 2 + 1], cam, MVP_MOD_X, 585.0 + dy, MVP_MOD_RANGO)
        call Hud_Ver(Mvp_Mod[p * 2 + 1], true)
    endif
''')
# Al ocultarse el cuadro (tienda o pantalla abierta) también los modelos.
cambia('''    if not shown then
        return
    endif
    call HealthBars__Place(Punt_Cuadro[p], cam, 805.0, 380.0 + dy, 412.)''', '''    if not shown then
        call Hud_Ver(Mvp_Mod[p * 2], false)
        call Hud_Ver(Mvp_Mod[p * 2 + 1], false)
        return
    endif
    call HealthBars__Place(Punt_Cuadro[p], cam, 805.0, 380.0 + dy, 412.)''')

if prueba:
    # Bolsa_Anotar va más abajo en el script que Mvp_Tick: el registro sale de Mvp_Preparar.
    cambia('''    call Bolsa_Anotar(nom)
endfunction''', '''    call Bolsa_Anotar(nom)
    // v20c-prueba: tipos de unidad de los modelos.
    if Mvp_Gana >= 0 then
        set nom = "mvp modelos ronda " + I2S(Ronda_Numero) + " gana " + I2S(GetUnitTypeId(Game_Hero[Mvp_Fila[Mvp_Gana]]))
        if Mvp_Pierde >= 0 then
            set nom = nom + " pierde " + I2S(GetUnitTypeId(Game_Hero[Mvp_Fila[Mvp_Pierde]]))
        endif
        call Bolsa_Anotar(nom)
    endif
endfunction''')
    for viejo, nuevo in (('lat\\\\v20b-', 'lat\\\\v20c-'), ('v20b-don.txt', 'v20c-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20c', 'prueba' if prueba else 'normal')
