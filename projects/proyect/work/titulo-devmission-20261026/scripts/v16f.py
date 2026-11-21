#!/usr/bin/env python3
"""v16f (08/11/2026): pedido de Leon tras el vídeo de v16e.
- Más tiempo para leer: cada texto del narrador se queda 0,6 s + 0,025 s por carácter además de su espera.
- Recarga: el foco pasa del botón F al texto de las balas ("Recargando"). Se muestra dos veces: tras la primera, el
  Tauren vacía el cargador con tres ráfagas seguidas (foco sobre las balas que bajan) y vuelve a recargar.
- Foco del arma corregido a (150, 212, r125): en v16e el icono quedaba en el borde y salía en penumbra.
- Fase de oleadas (siguiente del plan): 5 enemigos de la oleada 1 ('nmcf', del jugador neutral hostil, fuera de las
  oleadas 8..11 y del oro) entran desde la derecha; foco en el contador de enemigos; el Tauren dispara de verdad hasta
  limpiar la oleada y el contador baja. Luego el jefe de la oleada 2 ('nj02') aparece fuera de la pantalla con su
  indicador en el borde ('hbj2' y la esfera 'ubj0', para todos), entra, llama refuerzos (animación, Bondage Blue y
  "llamando refuerzos", como DevJefe_Llamar) y salen 3 enemigos. El Tauren acaba con todos.
  Los enemigos tienen poca vida para que caigan con pocas balas; si uno sigue vivo 3,5 s tras apuntarle, se remata
  (queda en la nota de la prueba). Al terminar se borran todos con la pareja.
Uso: v16f.py ENTRADA.j SALIDA.j (el j de v16e)
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


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s
N = '\r\n'

s = once(s, 'integer Tut_Clave= -2\n', '''integer Tut_Clave= -2
unit array Tut_Enem
integer Tut_NEnem= 0
unit Tut_Nuevo= null
unit Tut_Jefe= null
unit Tut_JefeIcono= null
unit Tut_JefeEsfera= null
effect Tut_JefeFx= null
boolean Tut_MarcaVer= false
real Tut_MarcaX= 0.
real Tut_MarcaY= 0.
boolean Tut_Combate= false
integer Tut_Obj= -1
real Tut_ObjT= 0.
real Tut_ProxTiro= 0.
integer Tut_CifraN= 5
''')

# Más tiempo de lectura.
s = once(s, '    set Tut_Hold = espera\n', '''    // v16f: tiempo de lectura, 0,6 s + 0,025 s por carácter, además de la espera del guion.
    set Tut_Hold = espera + 0.6 + 0.025 * I2R(StringLength(a) + StringLength(b) + StringLength(c))
''')

# El contador de la oleada del tutorial empieza en 5.
s = once(s, 'call Ronda_Texto(Tut_CifraUI, "30", 0.024, Ronda_CIFRA_Y)', 'call Ronda_Texto(Tut_CifraUI, "5", 0.024, Ronda_CIFRA_Y)')

# Limpieza de la oleada con la pareja.
s = once(s, '    call RemoveUnit(Tut_ArmaIcono[4])\n', '''    call RemoveUnit(Tut_ArmaIcono[4])
    // v16f: enemigos, jefe e indicador de la oleada del tutorial.
    loop
        exitwhen Tut_NEnem <= 0
        set Tut_NEnem = Tut_NEnem - 1
        call RemoveUnit(Tut_Enem[Tut_NEnem])
        set Tut_Enem[Tut_NEnem] = null
    endloop
    set Tut_Combate = false
    set Tut_Jefe = null
    if Tut_JefeFx != null then
        call DestroyEffect(Tut_JefeFx)
        set Tut_JefeFx = null
    endif
    if Tut_JefeIcono != null then
        call RemoveUnit(Tut_JefeIcono)
        call RemoveUnit(Tut_JefeEsfera)
        set Tut_JefeIcono = null
        set Tut_JefeEsfera = null
    endif
''')

s = once(s, '// v16d: el Tauren camina por guion a 300 por segundo hasta (x, y).\n', '''// v16f: enemigo de la oleada del tutorial, del jugador neutral hostil (no es de las oleadas 8..11 ni da oro).
function Tut_Enemigo takes integer raw,real x,real y,real vida returns nothing
    set Tut_Nuevo = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), raw, x, y, 180.)
    call RemoveGuardPosition(Tut_Nuevo)
    call UnitAddSleep(Tut_Nuevo, false)
    call UnitWakeUp(Tut_Nuevo)
    call SetUnitState(Tut_Nuevo, UNIT_STATE_LIFE, RMinBJ(vida, GetUnitState(Tut_Nuevo, UNIT_STATE_MAX_LIFE)))
    set Tut_Enem[Tut_NEnem] = Tut_Nuevo
    set Tut_NEnem = Tut_NEnem + 1
endfunction

// v16f: disparo real hacia una unidad.
function Tut_DispararA takes unit u returns nothing
    local real x= GetUnitX(u)
    local real y= GetUnitY(u)
    if not IssuePointOrder(Tut_Ctrl, "carrionswarm", x, y) then
        call s__RapidPair_castFamily(Game_Pair[Tut_P], x, y, Arm_Familia(Arm_Tier[Tut_P * 7 + Arm_Cat[Tut_P]]))
        call Tut_Nota("orden carrionswarm rechazada")
    endif
endfunction

// v16f: contador de enemigos vivos y combate: dispara al último que entró, recarga al vaciar y remata a los 3,5 s.
function Tut_Pelea takes nothing returns nothing
    local integer k
    local integer n= 0
    local integer obj= - 1
    local integer i
    if Tut_NEnem == 0 then
        return
    endif
    set k = Tut_NEnem - 1
    loop
        exitwhen k < 0
        if GetWidgetLife(Tut_Enem[k]) > 0.405 then
            set n = n + 1
            if obj < 0 then
                set obj = k
            endif
        endif
        set k = k - 1
    endloop
    if n != Tut_CifraN then
        set Tut_CifraN = n
        call Ronda_Texto(Tut_CifraUI, I2S(n), 0.024, Ronda_CIFRA_Y)
        call Tut_Nota("quedan " + I2S(n) + " t " + R2S(Tut_T))
    endif
    if not Tut_Combate then
        return
    endif
    if n == 0 then
        set Tut_Combate = false
        set Tut_Sig = Tut_T + 0.9
        call Tut_Nota("oleada limpia " + R2S(Tut_T))
        return
    endif
    if obj != Tut_Obj then
        set Tut_Obj = obj
        set Tut_ObjT = Tut_T
    elseif Tut_T > Tut_ObjT + 3.5 then
        call KillUnit(Tut_Enem[obj])
        call Tut_Nota("remate " + I2S(obj))
        return
    endif
    if Tut_T < Tut_ProxTiro or Arm_Fin[Tut_P] > 0. then
        return
    endif
    set i = Tut_P * 7 + Arm_Cat[Tut_P]
    if Arm_Clip[i] <= 0 then
        call Tut_Recargar()
        set Tut_ProxTiro = Tut_T + 0.5
        return
    endif
    call Tut_DispararA(Tut_Enem[obj])
    set Tut_ProxTiro = Tut_T + 0.6
endfunction

// v16f: indicador del jefe para todos, como DevJefe_Poner: en el borde de la vista mientras el jefe está fuera.
function Tut_Marca takes nothing returns nothing
    local real dx
    local real dy
    local real t
    local boolean ver= false
    if Tut_Jefe != null and GetWidgetLife(Tut_Jefe) > 0.405 then
        call Tut_Pantalla(GetUnitX(Tut_Jefe), GetUnitY(Tut_Jefe), Tut_Z + 80.)
        set ver = not ( Tut_PuntoX >= 0. and Tut_PuntoX <= 1920. and Tut_PuntoY >= 0. and Tut_PuntoY <= 864. )
    endif
    if ver then
        set dx = Tut_PuntoX - 961.
        set dy = Tut_PuntoY - 432.323669
        set t = 1000000.
        if dx > 0.01 then
            set t = RMinBJ(t, ( 1895. - 961. ) / dx)
        elseif dx < - 0.01 then
            set t = RMinBJ(t, ( 25. - 961. ) / dx)
        endif
        if dy > 0.01 then
            set t = RMinBJ(t, ( 803. - 432.323669 ) / dy)
        elseif dy < - 0.01 then
            set t = RMinBJ(t, ( 63. - 432.323669 ) / dy)
        endif
        set Tut_MarcaX = 961. + dx * t
        set Tut_MarcaY = 432.323669 + dy * t
        call HealthBars__Place(Tut_JefeIcono, Tut_Cam, Tut_MarcaX, Tut_MarcaY, 397.)
        call HealthBars__Place(Tut_JefeEsfera, Tut_Cam, Tut_MarcaX, Tut_MarcaY, 397.)
    endif
    if ver != Tut_MarcaVer then
        set Tut_MarcaVer = ver
        call ShowUnit(Tut_JefeIcono, ver)
        call ShowUnit(Tut_JefeEsfera, ver)
        if ver then
            call SetUnitAnimation(Tut_JefeEsfera, "birth")
            call QueueUnitAnimation(Tut_JefeEsfera, "stand")
            call Tut_Nota("marca " + R2S(Tut_MarcaX) + " " + R2S(Tut_MarcaY) + " t " + R2S(Tut_T))
        else
            call Tut_Nota("marca oculta t " + R2S(Tut_T))
        endif
    endif
endfunction

// v16f: el jefe de la oleada 2 fuera de la pantalla, con su indicador.
function Tut_JefeCrear takes nothing returns nothing
    call Tut_Enemigo('nj02', Tut_X + 1600., Tut_Y, 250.)
    set Tut_Jefe = Tut_Nuevo
    set Tut_JefeIcono = Tut_Pieza('hbj2')
    set Tut_JefeEsfera = Tut_Pieza('ubj0')
    call SetUnitScale(Tut_JefeEsfera, 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ))
    call ShowUnit(Tut_JefeIcono, false)
    call ShowUnit(Tut_JefeEsfera, false)
    set Tut_MarcaVer = false
endfunction

// v16f: como DevJefe_Llamar, para la muestra.
function Tut_Llamar takes nothing returns nothing
    local texttag t
    call IssueImmediateOrder(Tut_Jefe, "stop")
    call SetUnitAnimation(Tut_Jefe, "attack")
    call QueueUnitAnimation(Tut_Jefe, "stand")
    call PauseUnit(Tut_Jefe, true)
    set Tut_JefeFx = AddSpecialEffectTarget("war3mapImported\\\\Bondage Blue SD.mdx", Tut_Jefe, "origin")
    set t = CreateTextTag()
    call SetTextTagText(t, "llamando refuerzos", 0.020)
    call SetTextTagPosUnit(t, Tut_Jefe, 120.)
    call SetTextTagVelocity(t, 0., 0.0125)
    call SetTextTagPermanent(t, false)
    call SetTextTagLifespan(t, 3.)
    call SetTextTagFadepoint(t, 2.25)
    set t = null
endfunction

// v16f: como DevJefe_Aplicar: llegan 3 enemigos junto al jefe y van hacia el Tauren.
function Tut_Refuerzos takes nothing returns nothing
    local integer k= 0
    if Tut_JefeFx != null then
        call DestroyEffect(Tut_JefeFx)
        set Tut_JefeFx = null
    endif
    call PauseUnit(Tut_Jefe, false)
    call DestroyEffect(AddSpecialEffectTarget("Abilities\\\\Spells\\\\Human\\\\Resurrect\\\\ResurrectTarget.mdl", Tut_Jefe, "origin"))
    loop
        exitwhen k > 2
        call Tut_Enemigo('nmcf', GetUnitX(Tut_Jefe) + 150., GetUnitY(Tut_Jefe) - 220. + 220. * k, 45.)
        call IssuePointOrder(Tut_Nuevo, "move", Tut_X + 430., Tut_Y - 170. + 170. * k)
        set k = k + 1
    endloop
endfunction

// v16d: el Tauren camina por guion a 300 por segundo hasta (x, y).
''')

# Tick: indicador y combate antes del guion.
s = once(s, '''    call Tut_Hud()
    call Tut_Rejilla()
    call Tut_Guion()''', '''    call Tut_Hud()
    call Tut_Marca()
    call Tut_Pelea()
    call Tut_Rejilla()
    call Tut_Guion()''')


def boton(x, y, mano=True):
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


def a_balas(espera, texto=''):
    """Del botón al texto de las balas del HUD (foco delante del HUD)."""
    return f'''        set Tut_IconoS = 1.
        call ShowUnit(Tut_Mano, false)
        set Tut_FocoD = 398.
        call Tut_Mover(1, 215., 222., 0.6)
        call Tut_Mover(2, 115., 1., 0.6)
        call Tut_Estado("recargando")
''' + (f'        {texto}' if texto else f'        set Tut_Sig = Tut_T + {espera}')


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
    f'''        call Tut_Mover(1, 150., 212., 0.8)
        call Tut_Mover(2, 125., 1., 0.8)
        {decir(['Debajo, tu arma y sus balas:', 'las del cargador y las de reserva.'], 0.8)}''',
    f'''        call Tut_Mover(1, 385., 84., 0.8)
        call Tut_Mover(2, 75., 1., 0.8)
        {decir(['Y aquí, la oleada en curso y', 'los enemigos que te quedan.'], 0.8)}''',
    '''        call Tut_Mover(2, 420., 0., 0.5)
        set Tut_Sig = Tut_T + 0.55''',
    # Recarga (F), primera vez.
    f'''        call ShowUnit(Tut_Foco, false)
        set Tut_FocoD = 430.
        set Tut_SinA = false
        set Tut_GModo = 1
        set Tut_GIni = Tut_T
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
        {decir(['Te quedan pocas balas. Con F', 'recargas el cargador con las', 'de reserva.'], 0.3)}''',
    boton(1606, 635),
    clic('call Tut_Recargar()', 0.3),
    a_balas(0, decir(['Mientras recargas, aquí ves', 'los segundos que faltan.'], 0.4)),
    # Vaciar el cargador deprisa (foco sobre las balas) y recargar otra vez.
    f'''        call Tut_Estado("recargado")
        {decir(['Si gastas el cargador deprisa,', 'tendrás que recargar de nuevo.'], 0.2)}''',
    '''        call Tut_Disparo(0)
        set Tut_Sig = Tut_T + 1.3''',
    '''        call Tut_Disparo(1)
        set Tut_Sig = Tut_T + 1.3''',
    '''        call Tut_Disparo(2)
        set Tut_Sig = Tut_T + 1.8''',
    '''        call Tut_Estado("vacio")
        set Tut_FocoD = 430.
        call Tut_Mover(1, 1606., 635., 0.6)
        call Tut_Mover(2, 60., 1., 0.6)
        call Tut_Poner(3, 1300., 420., 0.)
        call Tut_Mover(3, 1606., 635., 0.8)
        call ShowUnit(Tut_Mano, true)
        set Tut_Sig = Tut_T + 0.95''',
    clic('call Tut_Recargar()', 0.3),
    a_balas(2.7),
    '''        call Tut_Mover(2, 420., 0., 0.5)
        set Tut_Sig = Tut_T + 0.6''',
    # Moverse mientras dispara: movimiento artificial con el Windwalk en los pies.
    f'''        call ShowUnit(Tut_Foco, false)
        set Tut_FocoD = 430.
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
    # Oleadas: 5 enemigos entran desde la derecha; vuelve el subfusil con el cargador lleno.
    f'''        call Tut_Estado("fin dash")
        set Tut_GModo = 3
        set Tut_GIni = Tut_T
        call Arm_Elegir(Tut_P, 1)
        set Arm_Clip[Tut_P * 7 + 1] = Arm_Mag[6]
        set Arm_Rva[Tut_P * 7 + 1] = Arm_Res[6]
        set Tut_CifraN = - 1
        call Tut_Enemigo('nmcf', Tut_X + 1300., Tut_Y - 240., 45.)
        call IssuePointOrder(Tut_Nuevo, "move", Tut_X + 560., Tut_Y - 240.)
        call Tut_Enemigo('nmcf', Tut_X + 1400., Tut_Y - 120., 45.)
        call IssuePointOrder(Tut_Nuevo, "move", Tut_X + 640., Tut_Y - 120.)
        call Tut_Enemigo('nmcf', Tut_X + 1300., Tut_Y, 45.)
        call IssuePointOrder(Tut_Nuevo, "move", Tut_X + 560., Tut_Y)
        call Tut_Enemigo('nmcf', Tut_X + 1400., Tut_Y + 120., 45.)
        call IssuePointOrder(Tut_Nuevo, "move", Tut_X + 640., Tut_Y + 120.)
        call Tut_Enemigo('nmcf', Tut_X + 1300., Tut_Y + 240., 45.)
        call IssuePointOrder(Tut_Nuevo, "move", Tut_X + 560., Tut_Y + 240.)
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
        {decir(['Ahora, las oleadas: los enemigos', 'llegan desde los bordes del mapa.'], 0.3)}''',
    f'''        call Tut_Estado("oleada")
        set Tut_FocoD = 398.
        call Tut_Poner(1, 385., 84., 0.)
        call Tut_Poner(2, 420., 0., 0.)
        call Tut_Mover(2, 75., 1., 0.8)
        call ShowUnit(Tut_Foco, true)
        {decir(['Este número cuenta los enemigos', 'que quedan en la oleada.'], 0.4)}''',
    f'''        call Tut_Mover(2, 420., 0., 0.5)
        call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenReady1.wav")
        {decir(['¡Dispara hasta acabar con todos!'], 0.2)}''',
    '''        call ShowUnit(Tut_Foco, false)
        set Tut_Combate = true
        set Tut_Obj = - 1
        set Tut_ProxTiro = Tut_T
        set Tut_Sig = Tut_T + 999.''',
    # Jefe fuera de la pantalla con su indicador.
    f'''        call Tut_Estado("limpia")
        call Ronda_Texto(Tut_RondaUI, "Wave 2", 0.017, Ronda_TITULO_Y)
        call Tut_JefeCrear()
        {decir(['Desde la oleada 2, al caer todos', 'aparece un jefe.'], 0.2)}''',
    f'''        call Tut_Poner(1, Tut_MarcaX, Tut_MarcaY, 0.)
        call Tut_Poner(2, 420., 0., 0.)
        call Tut_Mover(2, 70., 1., 0.8)
        call ShowUnit(Tut_Foco, true)
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
        {decir(['Si está fuera de la pantalla,', 'este indicador te muestra', 'hacia dónde está.'], 0.4)}''',
    f'''        call Tut_Mover(2, 420., 0., 0.5)
        call IssuePointOrder(Tut_Jefe, "move", Tut_X + 650., Tut_Y)
        {decir(['Síguelo y lo encontrarás.'], 0.2)}''',
    '''        call ShowUnit(Tut_Foco, false)
        call Tut_Estado("jefe")
        set Tut_Sig = Tut_T + 1.2''',
    f'''        call Tut_Estado("jefe")
        call Tut_Llamar()
        {decir(['El jefe llama refuerzos cada', 'cierto tiempo. ¡No le des tregua!'], 0.2)}''',
    '''        call Tut_Refuerzos()
        set Tut_Sig = Tut_T + 0.6''',
    '''        set Tut_Combate = true
        set Tut_Obj = - 1
        set Tut_ProxTiro = Tut_T
        set Tut_Sig = Tut_T + 999.''',
    f'''        call Tut_Estado("jefe caido")
        call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenYes3.wav")
        {decir(['¡Oleada superada! Tras cada una', 'tienes un descanso para comprar.'], 0.6)}''',
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
assert ultimo > 45
# Primero se renumera la despedida (43..45), que el bloque nuevo también usa.
for viejo, nuevo in ((45, ultimo + 2), (44, ultimo + 1), (43, ultimo)):
    s = once(s, f'''    elseif Tut_Fase == {viejo} then
        call Tut_Nota("fase {viejo} " + R2S(Tut_T))
''', f'''    elseif Tut_Fase == {nuevo} then
        call Tut_Nota("fase {nuevo} " + R2S(Tut_T))
''')
a = s.index('    elseif Tut_Fase == 14 then' + N)
b = s.index(f'    elseif Tut_Fase == {ultimo} then' + N)
assert s.count('    elseif Tut_Fase == 14 then' + N) == 1 and a < b
s = s[:a] + bloque + s[b:]
# Despedida: ya se vieron las oleadas.
viejo = [l for l in s.split(N) if 'call Tut_Decir("Esto es s' in l]
assert len(viejo) == 1
s = once(s, viejo[0] + '\n', '        ' + decir(['Esto es sólo el comienzo: después', 'verás la tienda y sus armas.', '¡Suerte en la batalla!'], 2.6) + '\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16f ok, fases 0..', ultimo + 2)
