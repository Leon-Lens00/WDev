#!/usr/bin/env python3
"""v16e (08/11/2026): el Tauren del tutorial usa las habilidades reales, a petición de Leon tras probar v16d ("de
momento está usando una habilidad que no lanza nada y sólo deja un efecto especial"), y sigue la fase.

- El Tauren es una pareja real (Game_Cuerpo) de un hueco libre Tut_P (0..7, sin jugador): cuerpo h005 y controlador
  en la esquina, como el bot. El guion le da las órdenes de las habilidades al controlador, una por fase:
    "smart" mover · "carrionswarm" Disparo (A) · "stomp" Recarga (F) · "avatar" Escopetas (R) · "shockwave" Dash (D)
  Así salen los proyectiles de verdad (RapidBolt), el movimiento artificial con el Windwalk en los pies al disparar
  mientras camina, la recarga del cargador, el cambio a la escopeta y el dash con su Valiant Charge.
  Si una orden no se acepta, se llama a lo mismo que hace la habilidad (queda en la nota de la prueba).
  Sin hueco libre (8 jugadores) se salta el tutorial. Al terminar se deshace todo: pareja, armas y vidas del hueco.
- HUD del tutorial, el mismo de la partida pero para todos con la cámara del tutorial: vida (hbhr + hbi0 + 100%),
  arma con su icono, nombre y balas (lee las del Tauren: bajan al disparar, "Recargando" al recargar) y oleada.
  El foco pasa por la vida, el arma y la oleada; para eso va a 398, delante del HUD (400) y detrás del panel (396).
- Consola: aparece el botón de Recarga en su sitio (fila 2, columna 2, 'DS1O' BTNLoad) y vuelve a entrar para la
  recarga, el cambio de arma y el dash, con la mano que pulsa cada botón.
Uso: v16e.py ENTRADA.j SALIDA.j (el j de v16d)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def jtexto(t):
    b = t.encode('utf-8')
    m = ''.join('0' if 0x80 <= c < 0xC0 else '1' for c in b)
    assert '"' not in t and '\\' not in t and '|' not in t
    return b.decode('latin-1'), m


def decir(lineas, espera):
    args = []
    for l in (lineas + ['', '', ''])[:3]:
        assert len(l) <= 40, l
        s, m = jtexto(l)
        args += [f'"{s}"', f'"{m}"']
    return f'call Tut_Decir({", ".join(args)}, {espera})'


def tramo(s, ini, fin, nuevo):
    """Sustituye desde ini (único) hasta el primer fin después de él, incluido."""
    assert s.count(ini) == 1, ini
    a = s.index(ini)
    b = s.index(fin, a) + len(fin)
    return s[:a] + nuevo + s[b:]


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s

s = once(s, 'real Tut_ADur= 0.\n', '''real Tut_ADur= 0.
integer Tut_P= -1
unit Tut_Ctrl= null
integer Tut_Luz= 0
real Tut_FocoD= 430.
unit Tut_Vida= null
unit Tut_VidaIcono= null
unit array Tut_ArmaIcono
integer Tut_IconoCat= -1
integer Tut_VidaUI= 0
integer Tut_ArmaUI= 0
integer Tut_BalasUI= 0
integer Tut_RondaUI= 0
integer Tut_CifraUI= 0
boolean Tut_HudVer= false
boolean Tut_HudVisto= false
integer Tut_Clave= -2
''')

N = '\r\n'
# Disparo real: la orden de la habilidad A al controlador, hacia el blanco k.
s = tramo(s, 'function Tut_Disparo takes integer k returns nothing' + N, 'endfunction' + N, '''function Tut_Disparo takes integer k returns nothing
    local boolean ok= IssuePointOrder(Tut_Ctrl, "carrionswarm", Tut_BlancoX[k], Tut_BlancoY[k])
    if not ok then
        call s__RapidPair_castFamily(Game_Pair[Tut_P], Tut_BlancoX[k], Tut_BlancoY[k], Arm_Familia(Arm_Tier[Tut_P * 7 + Arm_Cat[Tut_P]]))
        call Tut_Nota("orden carrionswarm rechazada")
    endif
endfunction
'''.replace('\n', N))

# Funciones nuevas antes de la consola (usan Tut_Nota, Tut_Pieza, Tut_Foto y las de la pareja real).
s = once(s, '// v16d: el Tauren camina por guion a 300 por segundo hasta (x, y).\n', '''// v16e: estado de la pareja real del tutorial (sólo la prueba lo guarda).
function Tut_Estado takes string e returns nothing
    local integer par= Game_Pair[Tut_P]
    local integer i= Tut_P * 7 + Arm_Cat[Tut_P]
    local string a= "0"
    local string w= "0"
    local string d= "0"
    if par == 0 then
        return
    endif
    if s__GroundMotion_artificial[s__RapidPair_motion[par]] then
        set a = "1"
    endif
    if s__RapidPair_walk[par] != null then
        set w = "1"
    endif
    if s__RapidPair_dashEffect[par] != null then
        set d = "1"
    endif
    call Tut_Nota("estado " + e + " t " + R2S(Tut_T) + " xy " + I2S(R2I(GetUnitX(Tut_Tauren))) + " " + I2S(R2I(GetUnitY(Tut_Tauren))) + " tiros " + I2S(s__RapidPair_emitted) + " dashes " + I2S(s__RapidPair_dashes) + " arma " + I2S(Arm_Cat[Tut_P]) + " " + I2S(Arm_Clip[i]) + "/" + I2S(Arm_Rva[i]) + " fin " + R2S(Arm_Fin[Tut_P]) + " art " + a + " pies " + w + " dashfx " + d + " mana " + R2S(GetUnitState(Tut_Ctrl, UNIT_STATE_MANA)))
endfunction

// v16e: mover con la orden de la partida (clic derecho al controlador).
function Tut_Ir takes real x,real y returns nothing
    if not IssuePointOrder(Tut_Ctrl, "smart", x, y) then
        call s__RapidPair_move(Game_Pair[Tut_P], x, y)
        call Tut_Nota("orden smart rechazada")
    endif
endfunction

// v16e: R, Escopetas (Aw04).
function Tut_Escopeta takes nothing returns nothing
    if not IssueImmediateOrder(Tut_Ctrl, "avatar") then
        call Arm_Elegir(Tut_P, 4)
        call Tut_Nota("orden avatar rechazada")
    endif
endfunction

// v16e: F, Recarga (Aw08); si no, lo mismo que Arm_BotonRecarga.
function Tut_Recargar takes nothing returns nothing
    local integer i= Tut_P * 7 + Arm_Cat[Tut_P]
    if not IssueImmediateOrder(Tut_Ctrl, "stomp") then
        call Tut_Nota("orden stomp rechazada")
        if Arm_Cat[Tut_P] != 5 and Arm_Rva[i] > 0 and Arm_Fin[Tut_P] <= 0. and Arm_Clip[i] < Arm_Mag[Arm_W(Tut_P)] then
            call s__RapidPair_finish(Game_Pair[Tut_P], true)
            set Arm_Fin[Tut_P] = TimerGetElapsed(s__RapidPair_clock) + Arm_Rec[Arm_W(Tut_P)]
        endif
    endif
endfunction

// v16e: D, Dash (Ard1) hacia (x, y); el maná del controlador se repone antes para que nunca falte.
function Tut_Dash takes real x,real y returns nothing
    call SetUnitState(Tut_Ctrl, UNIT_STATE_MANA, GetUnitState(Tut_Ctrl, UNIT_STATE_MAX_MANA))
    if not IssuePointOrder(Tut_Ctrl, "shockwave", x, y) then
        call s__RapidPair_dash(Game_Pair[Tut_P], x, y)
        call Tut_Nota("orden shockwave rechazada")
    endif
endfunction

// v16e: hueco libre para la pareja del tutorial, del 7 hacia abajo (el bot coge el primero libre desde 0).
function Tut_Libre takes nothing returns boolean
    local integer p= 7
    set Tut_P = - 1
    loop
        exitwhen p < 0
        if GetPlayerSlotState(Player(p)) != PLAYER_SLOT_STATE_PLAYING and not Game_On[p] then
            set Tut_P = p
            return true
        endif
        set p = p - 1
    endloop
    return false
endfunction

// v16e: el Tauren es una pareja real, como la del bot; con la escopeta T1 además de las armas base.
function Tut_Cuerpo takes nothing returns nothing
    local integer i= Tut_P * 7
    local integer p= 0
    set Arm_Tier[i + 4] = 1
    set Arm_Clip[i + 4] = Arm_Mag[24]
    set Arm_Rva[i + 4] = Arm_Res[24]
    set Tut_Luz = Luz_Nivel[Tut_P]
    if Vidas_Orden == null then
        set Vidas_Orden = CreateTrigger()
        call TriggerAddAction(Vidas_Orden, function Vidas_AlOrdenar)
    endif
    call Game_Cuerpo(Tut_P, Tut_X - 1250., Tut_Y)
    set Tut_Tauren = Game_Hero[Tut_P]
    set Tut_Ctrl = Game_Ctrl[Tut_P]
    call SetUnitInvulnerable(Tut_Tauren, true)
    call SetUnitFacing(Tut_Tauren, 0.)
    // Los colores de los proyectiles, los pies y el dash, los del primer jugador.
    loop
        exitwhen p > 11
        if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            call s__RapidPair_setColor(Game_Pair[Tut_P], GetPlayerColor(Player(p)))
            return
        endif
        set p = p + 1
    endloop
endfunction

// v16e: HUD de la partida para todos con la cámara del tutorial (las piezas de la partida son de un solo jugador).
function Tut_HudCrear takes nothing returns nothing
    set Tut_Vida = Tut_Pieza('hbhr')
    set Tut_VidaIcono = Tut_Pieza('hbi0')
    set Tut_ArmaIcono[1] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_ArmaIcono[1], 108., 54., 400., Cat_Tex[1])
    set Tut_ArmaIcono[4] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_ArmaIcono[4], 108., 54., 400., Cat_Tex[4])
    call ShowUnit(Tut_Vida, false)
    call ShowUnit(Tut_VidaIcono, false)
    call ShowUnit(Tut_ArmaIcono[1], false)
    call ShowUnit(Tut_ArmaIcono[4], false)
    set Tut_VidaUI = s__UIText_create(( 82.8 - 4. * 4.5 - 960. ) / 728., ( 420. - 159. ) / 390., 1.)
    set Tut_ArmaUI = s__UIText_create(0., 0., 1.)
    set Tut_BalasUI = s__UIText_create(0., 0., 1.)
    set Tut_RondaUI = s__UIText_create(0., 0., 1.)
    set Tut_CifraUI = s__UIText_create(0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[Tut_VidaUI], true)
    call SetTextTagPermanent(s__UIText_text[Tut_ArmaUI], true)
    call SetTextTagPermanent(s__UIText_text[Tut_BalasUI], true)
    call SetTextTagPermanent(s__UIText_text[Tut_RondaUI], true)
    call SetTextTagPermanent(s__UIText_text[Tut_CifraUI], true)
    call SetTextTagText(s__UIText_text[Tut_VidaUI], "100%", 0.017)
    call SetTextTagColor(s__UIText_text[Tut_VidaUI], 199, 247, 255, 255)
    call SetTextTagColor(s__UIText_text[Tut_ArmaUI], 199, 247, 255, 255)
    call SetTextTagColor(s__UIText_text[Tut_BalasUI], 255, 255, 255, 255)
    call SetTextTagColor(s__UIText_text[Tut_RondaUI], 255, 48, 48, 255)
    call SetTextTagColor(s__UIText_text[Tut_CifraUI], 255, 255, 255, 255)
    call Ronda_Texto(Tut_RondaUI, "Wave 1", 0.017, Ronda_TITULO_Y)
    call Ronda_Texto(Tut_CifraUI, "30", 0.024, Ronda_CIFRA_Y)
    call s__UIText_show(Tut_VidaUI, false, Tut_Cam)
    call s__UIText_show(Tut_ArmaUI, false, Tut_Cam)
    call s__UIText_show(Tut_BalasUI, false, Tut_Cam)
    call s__UIText_show(Tut_RondaUI, false, Tut_Cam)
    call s__UIText_show(Tut_CifraUI, false, Tut_Cam)
endfunction

// v16e: como Arm_Hud y HealthBarsUpdate, con las balas del Tauren del tutorial.
function Tut_Hud takes nothing returns nothing
    local integer c
    local integer i
    local integer w
    local integer clave
    local string s
    if Tut_HudVer != Tut_HudVisto then
        set Tut_HudVisto = Tut_HudVer
        call ShowUnit(Tut_Vida, Tut_HudVer)
        call ShowUnit(Tut_VidaIcono, Tut_HudVer)
        if Tut_HudVer then
            call SetUnitAnimationByIndex(Tut_Vida, 100)
        elseif Tut_IconoCat >= 0 and Tut_ArmaIcono[Tut_IconoCat] != null then
            call ShowUnit(Tut_ArmaIcono[Tut_IconoCat], false)
        endif
        call s__UIText_show(Tut_VidaUI, Tut_HudVer, Tut_Cam)
        call s__UIText_show(Tut_ArmaUI, Tut_HudVer, Tut_Cam)
        call s__UIText_show(Tut_BalasUI, Tut_HudVer, Tut_Cam)
        call s__UIText_show(Tut_RondaUI, Tut_HudVer, Tut_Cam)
        call s__UIText_show(Tut_CifraUI, Tut_HudVer, Tut_Cam)
        set Tut_IconoCat = - 1
        set Tut_Clave = - 2
    endif
    if not Tut_HudVer or Tut_P < 0 then
        return
    endif
    set c = Arm_Cat[Tut_P]
    set i = Tut_P * 7 + c
    if c != Tut_IconoCat then
        if Tut_IconoCat >= 0 and Tut_ArmaIcono[Tut_IconoCat] != null then
            call ShowUnit(Tut_ArmaIcono[Tut_IconoCat], false)
        endif
        set Tut_IconoCat = c
        if Tut_ArmaIcono[c] != null then
            call ShowUnit(Tut_ArmaIcono[c], true)
        endif
    endif
    call HealthBars__Place(Tut_Vida, Tut_Cam, 24., 48.6, 400.)
    call HealthBars__Place(Tut_VidaIcono, Tut_Cam, 24., 48.6, 401.)
    if Tut_ArmaIcono[c] != null then
        call HealthBars__Place(Tut_ArmaIcono[c], Tut_Cam, 90., 215., 400.)
    endif
    set clave = ( c * 8 + Arm_Tier[i] ) * 1000000 + Arm_Clip[i] * 1000 + Arm_Rva[i]
    if Arm_Fin[Tut_P] > 0 then
        set clave = - 3 - R2I(( Arm_Fin[Tut_P] - TimerGetElapsed(s__RapidPair_clock) ) * 10.)
    endif
    if clave != Tut_Clave then
        set Tut_Clave = clave
        set w = Arm_W(Tut_P)
        call Arm_Texto(Tut_ArmaUI, Arm_Nombre[w] + " " + Arm_TierTexto(Arm_Tier[i]), 0.017, 192.)
        if Arm_Fin[Tut_P] > 0 then
            set s = "Recargando " + R2SW(RMaxBJ(0., Arm_Fin[Tut_P] - TimerGetElapsed(s__RapidPair_clock)), 1, 1)
        else
            set s = I2S(Arm_Clip[i]) + "/" + I2S(Arm_Rva[i])
        endif
        call Arm_Texto(Tut_BalasUI, s, 0.024, 222.)
    endif
endfunction

// v16e: deshace la pareja del tutorial y su HUD; el hueco queda como antes para el bot o la partida.
function Tut_Soltar takes nothing returns nothing
    local integer i= Tut_P * 7
    local integer c= 0
    set Tut_HudVer = false
    call Tut_Hud()
    call RemoveUnit(Tut_Vida)
    call RemoveUnit(Tut_VidaIcono)
    call RemoveUnit(Tut_ArmaIcono[1])
    call RemoveUnit(Tut_ArmaIcono[4])
    call s__UIText_destroy(Tut_VidaUI)
    call s__UIText_destroy(Tut_ArmaUI)
    call s__UIText_destroy(Tut_BalasUI)
    call s__UIText_destroy(Tut_RondaUI)
    call s__UIText_destroy(Tut_CifraUI)
    if Tut_P < 0 then
        return
    endif
    if Game_Pair[Tut_P] != 0 then
        call s__RapidPair_destroy(Game_Pair[Tut_P])
    endif
    if Arm_Cono[Tut_P] != null then
        call DestroyEffect(Arm_Cono[Tut_P])
        set Arm_Cono[Tut_P] = null
    endif
    call RemoveUnit(Game_Hero[Tut_P])
    set Tut_Tauren = null
    set Tut_Ctrl = null
    set Game_Pair[Tut_P] = 0
    set Game_Hero[Tut_P] = null
    set Game_Ctrl[Tut_P] = null
    if Vidas_EnPartida[Tut_P] then
        set Vidas_EnPartida[Tut_P] = false
        set Vidas_EnPie = Vidas_EnPie - 1
    endif
    loop
        exitwhen c > 6
        set Arm_Tier[i + c] = 0
        set Arm_Clip[i + c] = 0
        set Arm_Rva[i + c] = 0
        set Arm_Listo[i + c] = 0.
        set c = c + 1
    endloop
    set Arm_Cat[Tut_P] = 0
    set Arm_Fin[Tut_P] = 0.
    set Arm_Desvio[Tut_P] = 0.
    set Luz_Nivel[Tut_P] = Tut_Luz
    set Tut_P = - 1
endfunction

// v16d: el Tauren camina por guion a 300 por segundo hasta (x, y).
''')

# Consola: botón de Recarga en su sitio (fila 2, columna 2).
s = once(s, "    call Tut_Foto(Tut_Boton[9], 64., 64., 450., 'DS1N')\n", """    call Tut_Foto(Tut_Boton[9], 64., 64., 450., 'DS1N')
    set Tut_Boton[5] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Boton[5], 64., 64., 450., 'DS1O')
""")

# Tut_Begin: sin hueco libre no hay tutorial; el Tauren neutral pasa a ser la pareja real.
s = once(s, '''    call DestroyTimer(GetExpiredTimer())
    set Tut_Z = GetLocationZ(l)
''', '''    call DestroyTimer(GetExpiredTimer())
    // v16e: el Tauren es una pareja real de un hueco sin jugador; con los 8 ocupados se entra directo.
    if not Tut_Libre() then
        call RemoveLocation(l)
        call RemoveRect(zona)
        set l = null
        set zona = null
        call TimerStart(CreateTimer(), 0., false, function Tut_Entrar)
        return
    endif
    set Tut_Z = GetLocationZ(l)
''')
s = tramo(s, '    // El Tauren, de nadie', 'call IssueImmediateOrder(Tut_Tauren, "stop")' + N,
          '    // v16e: pareja real (cuerpo y controlador) del hueco Tut_P y HUD del tutorial.' + N +
          '    call Tut_Cuerpo()' + N + '    call Tut_HudCrear()' + N)

# Tick: HUD y profundidad del foco.
s = once(s, '''    call Tut_Andar()
    call Tut_Rejilla()''', '''    call Tut_Hud()
    call Tut_Rejilla()''')
s = once(s, 'call Tut_Escala(Tut_Foco, 64. * r, 64. * r, 430.)', 'call Tut_Escala(Tut_Foco, 64. * r, 64. * r, Tut_FocoD)')
s = once(s, 'call HealthBars__Place(Tut_Foco, Tut_Cam, Tut_PX[1], Tut_PY[1], 430.)',
         'call HealthBars__Place(Tut_Foco, Tut_Cam, Tut_PX[1], Tut_PY[1], Tut_FocoD)')

# Terminar: la pareja y el HUD se deshacen.
s = once(s, '    call RemoveUnit(Tut_Tauren)\n', '    call Tut_Soltar()\n')

# Guion.
s = once(s, '''        call Pres_Black(255, 0, 1.5)
        call Tut_Caminar(Tut_X, Tut_Y)''', '''        call Pres_Black(255, 0, 1.5)
        call Tut_Ir(Tut_X, Tut_Y)''')


def boton(x, y):
    """Foco en un botón de la consola y la mano que va hacia él."""
    return f'''        call Tut_Poner(1, {x}., {y}., 0.)
        call Tut_Poner(2, 260., 0., 0.)
        call Tut_Mover(2, 60., 1., 0.7)
        call ShowUnit(Tut_Foco, true)
        call Tut_Poner(3, 1300., 420., 0.)
        call Tut_Mover(3, {x}., {y}., 0.8)
        call ShowUnit(Tut_Mano, true)
        set Tut_Sig = Tut_T + 0.95'''


def clic(orden, espera):
    return f'''        call Racha_Sonar("Sound\\\\Interface\\\\MouseClick1.wav")
        set Tut_IconoS = 0.86
        {orden}
        call Tut_Estado("clic")
        set Tut_Sig = Tut_T + {espera}'''


def soltar(espera):
    return f'''        set Tut_IconoS = 1.
        call ShowUnit(Tut_Mano, false)
        call Tut_Mover(2, 260., 0., 0.5)
        set Tut_Sig = Tut_T + {espera}'''


fases = [
    # HUD: vida, arma y oleada bajo el foco.
    f'''        call ShowUnit(Tut_Mira, false)
        call Tut_Estado("rafaga")
        set Tut_HudVer = true
        set Tut_FocoD = 398.
        call Tut_Poner(1, 175., 105., 0.)
        call Tut_Poner(2, 420., 0., 0.)
        call Tut_Mover(2, 165., 1., 0.8)
        call ShowUnit(Tut_Foco, true)
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
        {decir(['Arriba a la izquierda está tu vida.', 'Si llega a cero, caes en combate.'], 0.8)}''',
    f'''        call Tut_Mover(1, 205., 205., 0.8)
        call Tut_Mover(2, 135., 1., 0.8)
        {decir(['Debajo, tu arma y sus balas:', 'las del cargador y las de reserva.'], 0.8)}''',
    f'''        call Tut_Mover(1, 385., 84., 0.8)
        call Tut_Mover(2, 75., 1., 0.8)
        {decir(['Y aquí, la oleada en curso y', 'los enemigos que te quedan.'], 0.8)}''',
    '''        call Tut_Mover(2, 420., 0., 0.5)
        set Tut_Sig = Tut_T + 0.55''',
    # Recarga (F).
    f'''        call ShowUnit(Tut_Foco, false)
        set Tut_FocoD = 430.
        set Tut_SinA = false
        set Tut_GModo = 1
        set Tut_GIni = Tut_T
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
        {decir(['Te quedan pocas balas. Con F', 'recargas el cargador con las', 'de reserva.'], 0.3)}''',
    boton(1606, 635),
    clic('call Tut_Recargar()', 0.3),
    soltar(2.3),
    # Moverse mientras dispara: movimiento artificial con el Windwalk en los pies.
    f'''        call ShowUnit(Tut_Foco, false)
        call Tut_Estado("recargado")
        {decir(['Puedes moverte mientras disparas:', 'el disparo no te detiene.'], 0.2)}''',
    '''        call Tut_Ir(Tut_X, Tut_Y + 330.)
        set Tut_Sig = Tut_T + 0.15''',
    '''        call Tut_Disparo(0)
        set Tut_Sig = Tut_T + 0.5''',
    '''        call Tut_Estado("andando")
        set Tut_Sig = Tut_T + 0.35''',
    '''        call Tut_Ir(Tut_X, Tut_Y - 220.)
        set Tut_Sig = Tut_T + 0.15''',
    '''        call Tut_Disparo(2)
        set Tut_Sig = Tut_T + 0.5''',
    '''        call Tut_Estado("andando")
        set Tut_Sig = Tut_T + 0.5''',
    '''        call Tut_Ir(Tut_X, Tut_Y)
        set Tut_Sig = Tut_T + 1.4''',
    # Cambio de arma (R, escopeta) y su disparo.
    f'''        call Tut_Estado("quieto")
        {decir(['Con Q, W, E y R cambias de arma.', 'R saca la escopeta: varios', 'perdigones en cada disparo.'], 0.3)}''',
    boton(1818, 535),
    clic('call Tut_Escopeta()', 0.4),
    soltar(0.5),
    '''        call ShowUnit(Tut_Foco, false)
        call Tut_Disparo(1)
        set Tut_Sig = Tut_T + 1.8''',
    # Dash (D) hacia la derecha y de vuelta.
    f'''        call Tut_Estado("escopeta")
        {decir(['Con D haces un dash: un impulso', 'rápido hacia donde apuntes.', 'Úsalo para esquivar.'], 0.3)}''',
    boton(1818, 635),
    clic('call Tut_Dash(Tut_X + 450., Tut_Y)', 0.15),
    '''        call Tut_Estado("dash")
        set Tut_Sig = Tut_T + 0.55''',
    soltar(0.3),
    '''        call ShowUnit(Tut_Foco, false)
        call Tut_Dash(Tut_X - 450., Tut_Y)
        set Tut_Sig = Tut_T + 0.15''',
    '''        call Tut_Estado("dash")
        set Tut_Sig = Tut_T + 0.75''',
    '''        call Tut_Estado("fin dash")
        set Tut_GModo = 3
        set Tut_GIni = Tut_T
        set Tut_Sig = Tut_T + 0.6''',
]
bloque = ''
for n, f in enumerate(fases):
    k = 14 + n
    bloque += f'''    elseif Tut_Fase == {k} then
        call Tut_Nota("fase {k} " + R2S(Tut_T))
{f}
'''
bloque = bloque.replace('\n', N)
ultimo = 14 + len(fases)
for viejo, nuevo in ((17, ultimo), (18, ultimo + 1), (19, ultimo + 2)):
    s = once(s, f'''    elseif Tut_Fase == {viejo} then
        call Tut_Nota("fase {viejo} " + R2S(Tut_T))
''', f'''    elseif Tut_Fase == {nuevo} then
        call Tut_Nota("fase {nuevo} " + R2S(Tut_T))
''')
s = tramo(s, '    elseif Tut_Fase == 14 then' + N, '        set Tut_Sig = Tut_T + 1.6' + N, bloque)
assert s.count('    elseif Tut_Fase == 14 then') == 1
s = tramo(s, '        call Tut_Decir("Esto es s', N,
          '        ' + decir(['Esto es sólo el comienzo: pronto', 'verás las oleadas y la tienda.', '¡Suerte en la batalla!'], 2.6) + N)
assert 'Tut_Caminar(Tut_X' not in s.split('function Tut_Guion')[1].split('endfunction')[0]
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16e ok, fases 0..', ultimo + 2)
