#!/usr/bin/env python3
"""v16a (08/11/2026): esqueleto del tutorial de Dev Mission, a puro guion y sin acciones del jugador.

Parte de v14zy (noche, intro con 60 s, arreglo de Cairne). Al empezar el mapa entra directo al tutorial (más adelante
se votará tras la presentación de Nereus) y al terminar pasa a la partida real, como la entrada directa de las pruebas.

Escena única y compartida: una sola cámara lógica (s__Camera) aplicada a todos los jugadores y unas mismas piezas
'uidb' visibles para todos, en el recinto llano X 6000..10000, Y 7500..9500 (terreno_v16a.py).
  - Fundido desde negro; el Tauren entra caminando a cámara y se para.
  - Panel abajo a la izquierda con el retrato del Tauren que habla (texto a máquina, voces del Tauren).
  - Saludo «Proyect Dev Us»; la consola sólo se nombra como referencia (abajo a la derecha, vacía).
  - Icono de Disparo (A) con el fondo oscuro de foco, que van juntos al centro; etiqueta «Disparo (A)».
  - Cursor del juego: pulsa el icono, se vuelve mira y dispara a tres puntos delante (arriba, centro, abajo).
  - «Puedes moverte mientras disparas», deseo de suerte, fundido y entrada a la partida.
Los disparos son un marcador provisional (explosión en el punto); los reales, el HUD, oleadas y tienda van en v16b-d.
Texturas DS1A TutFoco, DS1B TutPanel, DS1C TutMano, DS1D TutMira y DS1E icono BTNFireBolt (objetos_v16a.py).
Uso: v16a.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def jtexto(t):
    """Texto UTF-8 como lo guarda el j (latin-1 por byte) y su máscara: 1 donde puede cortarse, 0 dentro de un carácter
    de varios bytes o de un código de color."""
    b = t.encode('utf-8')
    m = []
    i = 0
    while i < len(b):
        if b[i:i + 2] == b'|c':
            m += ['1'] + ['0'] * 9
            i += 10
            continue
        if b[i:i + 2] == b'|r':
            m += ['1', '0']
            i += 2
            continue
        m.append('0' if 0x80 <= b[i] < 0xC0 else '1')
        i += 1
    assert '"' not in t and '\\' not in t
    return b.decode('latin-1'), ''.join(m)


def decir(lineas, espera):
    lineas = (lineas + ['', '', ''])[:3]
    args = []
    for l in lineas:
        assert len(l) <= 40, l
        s, m = jtexto(l)
        args += [f'"{s}"', f'"{m}"']
    return f'call Tut_Decir({", ".join(args)}, {espera})'


src, dst = sys.argv[1], sys.argv[2]
s = Path(src).read_text(encoding='latin-1', newline='')

s = once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)',
         'call TimerStart(CreateTimer(), 0.1, false, function Tut_Begin)')

globales = '''// v16a: tutorial (scripts/v16a.py).
real Tut_X= 8000.
real Tut_Y= 8300.
real Tut_Z= 0.
integer Tut_Cam= 0
timer Tut_Reloj= null
real Tut_T= 0.
integer Tut_Fase= 0
real Tut_Sig= 0.
boolean Tut_EsperaTexto= false
real Tut_Hold= 0.
unit Tut_Tauren= null
unit Tut_Panel= null
unit Tut_Cara= null
unit Tut_Marco= null
unit Tut_Foco= null
unit Tut_Icono= null
unit Tut_Mano= null
unit Tut_Mira= null
integer Tut_Nombre= 0
integer Tut_Etiqueta= 0
integer array Tut_Txt
string array Tut_Linea
string array Tut_Mask
integer array Tut_Car
real Tut_Acc= 0.
boolean Tut_Habla= false
real array Tut_X0
real array Tut_Y0
real array Tut_X1
real array Tut_Y1
real array Tut_T0
real array Tut_Dur
real array Tut_PX
real array Tut_PY
real Tut_IconoS= 1.
real Tut_PuntoX= 0.
real Tut_PuntoY= 0.
real array Tut_BlancoX
real array Tut_BlancoY
fogmodifier array Tut_Vista
'''
s = once(s, 'real Racha_AjL= 0.\n', 'real Racha_AjL= 0.\n' + globales)

guion = []
def fase(n, cuerpo):
    guion.append((n, cuerpo))

fase(0, '''        call Pres_Black(255, 0, 1.5)
        call IssuePointOrder(Tut_Tauren, "move", Tut_X, Tut_Y)
        set Tut_Sig = Tut_T + 4.9''')
fase(1, '''        call SetUnitFacingTimed(Tut_Tauren, 270., 0.5)
        set Tut_Sig = Tut_T + 0.7''')
fase(2, '''        call Tut_PanelVer(true)
        call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenWhat1.wav")
        ''' + decir(['¡Hola, guerrero! Bienvenido a', 'Proyect Dev Us.', 'Te ayudaré a entender cómo se juega.'], 2.4))
fase(3, '''        ''' + decir(['Abajo a la derecha, en la consola,', 'salen tus habilidades base. Ahora', 'está vacía: no tienes nada elegido.'], 0.6))
fase(4, '''        call Tut_Poner(0, 1529., 790., 0.)
        call Tut_Poner(1, 1529., 790., 0.)
        call Tut_Poner(2, 260., 0., 0.)
        call Tut_Mover(2, 70., 1., 0.9)
        call ShowUnit(Tut_Icono, true)
        call ShowUnit(Tut_Foco, true)
        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")
        set Tut_Sig = Tut_T + 2.2''')
fase(5, '''        call Tut_Mover(0, 960., 300., 1.2)
        call Tut_Mover(1, 960., 300., 1.2)
        call Tut_Mover(2, 85., 1., 1.2)
        set Tut_Sig = Tut_T + 1.3''')
fase(6, '''        call SetTextTagText(s__UIText_text[Tut_Etiqueta], "Disparo (A)", 0.022)
        call s__UIText_show(Tut_Etiqueta, true, Tut_Cam)
        call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenReady1.wav")
        ''' + decir(['Este es Disparo, tecla A.', 'Pulsa A y haz clic donde quieras', 'lanzar el proyectil.'], 1.2))
fase(7, '''        call Tut_Poner(3, 1250., 560., 0.)
        call Tut_Mover(3, 960., 300., 0.9)
        call ShowUnit(Tut_Mano, true)
        set Tut_Sig = Tut_T + 1.1''')
fase(8, '''        call Racha_Sonar("Sound\\\\Interface\\\\MouseClick1.wav")
        set Tut_IconoS = 0.86
        set Tut_Sig = Tut_T + 0.18''')
fase(9, '''        set Tut_IconoS = 1.
        call ShowUnit(Tut_Mano, false)
        call ShowUnit(Tut_Mira, true)
        call s__UIText_show(Tut_Etiqueta, false, Tut_Cam)
        call Tut_Mover(2, 85., 0., 0.5)
        call Tut_Blanco(0)
        call Tut_Mover(3, Tut_PuntoX, Tut_PuntoY, 0.7)
        set Tut_Sig = Tut_T + 0.6''')
fase(10, '''        call ShowUnit(Tut_Icono, false)
        call ShowUnit(Tut_Foco, false)
        set Tut_Sig = Tut_T + 0.25''')
fase(11, '''        call Tut_Disparo(0)
        call Tut_Blanco(1)
        call Tut_Mover(3, Tut_PuntoX, Tut_PuntoY, 0.5)
        set Tut_Sig = Tut_T + 0.75''')
fase(12, '''        call Tut_Disparo(1)
        call Tut_Blanco(2)
        call Tut_Mover(3, Tut_PuntoX, Tut_PuntoY, 0.5)
        set Tut_Sig = Tut_T + 0.75''')
fase(13, '''        call Tut_Disparo(2)
        set Tut_Sig = Tut_T + 0.9''')
fase(14, '''        call ShowUnit(Tut_Mira, false)
        call IssuePointOrder(Tut_Tauren, "move", Tut_X, Tut_Y + 320.)
        ''' + decir(['Puedes moverte mientras disparas:', 'el proyectil sale igual.'], 0.4))
fase(15, '''        call Tut_Disparo(0)
        set Tut_Sig = Tut_T + 0.5''')
fase(16, '''        call Tut_Disparo(2)
        call IssuePointOrder(Tut_Tauren, "move", Tut_X, Tut_Y)
        set Tut_Sig = Tut_T + 1.6''')
fase(17, '''        call SetUnitFacingTimed(Tut_Tauren, 270., 0.4)
        call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenYes3.wav")
        ''' + decir(['Esto es sólo el comienzo: pronto', 'verás armas, oleadas y la tienda.', '¡Suerte en la batalla!'], 2.6))
fase(18, '''        call Pres_Black(0, 255, 1.2)
        set Tut_Sig = Tut_T + 1.35''')
fase(19, '''        call Tut_Nota("fin " + R2S(Tut_T))
        call Tut_Terminar()
        return''')

ramas = []
for n, cuerpo in guion:
    ramas.append(f'''    {'if' if not ramas else 'elseif'} Tut_Fase == {n} then
        call Tut_Nota("fase {n} " + R2S(Tut_T))
{cuerpo}''')
ramas_txt = '\n'.join(ramas) + '\n    endif\n'

codigo = r'''// ===== v16a: tutorial (scripts/v16a.py) =====
// Registro de la variante de prueba; en el mapa normal no hace nada.
function Tut_Nota takes string s returns nothing
endfunction

// Pieza de interfaz para todos (misma cámara para todos): 'uidb' o retrato, sin selección, visible al 100 %.
function Tut_Pieza takes integer raw returns unit
    local unit u= CreateUnit(CAMERA_DUMMY_PLAYER, raw, Tut_X, Tut_Y, 270.)
    call UnitAddAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(u, s__Interface_DESTROYER_FORM_ID)
    call UnitAddAbility(u, s__Interface_LOCUST_ID)
    call UnitRemoveAbility(u, s__Interface_LOCUST_ID)
    call SetUnitInvulnerable(u, true)
    call SetUnitBlendTime(u, 0.)
    call SetUnitVertexColor(u, 255, 255, 255, 255)
    return u
endfunction

// Como Racha_Foto, para la profundidad d: wpx × hpx píxeles en pantalla.
function Tut_Escala takes unit u,real wpx,real hpx,real d returns nothing
    local real w= wpx * ( 0.544 / 718.18930543 ) * d
    local real h= hpx * ( 0.302 / 387.73819261 ) * d
    call SetUnitScale(u, 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h))
endfunction

function Tut_Foto takes unit u,real wpx,real hpx,real d,integer tex returns nothing
    local real w= wpx * ( 0.544 / 718.18930543 ) * d
    local real h= hpx * ( 0.302 / 387.73819261 ) * d
    local real a
    local integer anim= 0
    if h < w then
        set anim = IMinBJ(100, R2I(10 * ( w / h - 1 ) + 0.5))
    else
        set a = 10 * ( h / w - 1 )
        if a >= 0.5 then
            set anim = 100 + IMinBJ(100, R2I(a + 0.5))
        endif
    endif
    call SetUnitScale(u, 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h))
    call UserInterface_ApplySkin(u, tex)
    call SetUnitAnimationByIndex(u, anim)
endfunction

// Canales de movimiento: 0 icono, 1 foco, 2 radio del foco (x) y su opacidad 0..1 (y), 3 cursor.
function Tut_Poner takes integer k,real x,real y,real z returns nothing
    set Tut_PX[k] = x
    set Tut_PY[k] = y
    set Tut_X1[k] = x
    set Tut_Y1[k] = y
    set Tut_Dur[k] = 0.
endfunction

function Tut_Mover takes integer k,real x,real y,real dur returns nothing
    set Tut_X0[k] = Tut_PX[k]
    set Tut_Y0[k] = Tut_PY[k]
    set Tut_X1[k] = x
    set Tut_Y1[k] = y
    set Tut_T0[k] = Tut_T
    set Tut_Dur[k] = RMaxBJ(0.01, dur)
endfunction

function Tut_Paso takes integer k returns nothing
    local real u
    if Tut_Dur[k] <= 0. then
        return
    endif
    set u = RMinBJ(1., ( Tut_T - Tut_T0[k] ) / Tut_Dur[k])
    set u = u * u * ( 3. - 2. * u )
    set Tut_PX[k] = Tut_X0[k] + ( Tut_X1[k] - Tut_X0[k] ) * u
    set Tut_PY[k] = Tut_Y0[k] + ( Tut_Y1[k] - Tut_Y0[k] ) * u
    if Tut_T >= Tut_T0[k] + Tut_Dur[k] then
        set Tut_Dur[k] = 0.
    endif
endfunction

// Punto del mundo -> píxel de pantalla con la cámara del tutorial (inversa de HealthBars__Place).
function Tut_Pantalla takes real x,real y,real z returns nothing
    local integer e= s__Camera_eye[Tut_Cam]
    local integer ax= s__Camera_axisX[Tut_Cam]
    local integer ay= s__Camera_axisY[Tut_Cam]
    local integer az= s__Camera_axisZ[Tut_Cam]
    local real dx= x - s__VECTOR3_x[e]
    local real dy= y - s__VECTOR3_y[e]
    local real dz= z - s__VECTOR3_z[e]
    local real r= dx * s__VECTOR3_x[az] + dy * s__VECTOR3_y[az] + dz * s__VECTOR3_z[az]
    local real px= ( dx * s__VECTOR3_x[ax] + dy * s__VECTOR3_y[ax] + dz * s__VECTOR3_z[ax] ) / ( SCREEN_WIDTH * r )
    local real py= ( dx * s__VECTOR3_x[ay] + dy * s__VECTOR3_y[ay] + dz * s__VECTOR3_z[ay] ) / ( SCREEN_HEIGHT * r )
    set Tut_PuntoX = 961. + px * 718.18930543
    set Tut_PuntoY = 432.323669 - py * 387.73819261
endfunction

// Blanco k (0 arriba, 1 centro, 2 abajo) delante del Tauren, a la derecha de la pantalla.
function Tut_Blanco takes integer k returns nothing
    call Tut_Pantalla(Tut_BlancoX[k], Tut_BlancoY[k], Tut_Z + 60.)
    call Tut_Nota("blanco " + I2S(k) + " " + R2S(Tut_PuntoX) + " " + R2S(Tut_PuntoY))
endfunction

// Provisional hasta v16b: el Tauren mira y ataca; explosión en el blanco.
function Tut_Disparo takes integer k returns nothing
    local real a= Atan2(Tut_BlancoY[k] - GetUnitY(Tut_Tauren), Tut_BlancoX[k] - GetUnitX(Tut_Tauren)) * bj_RADTODEG
    call SetUnitFacing(Tut_Tauren, a)
    call SetUnitAnimation(Tut_Tauren, "attack")
    call QueueUnitAnimation(Tut_Tauren, "stand")
    call Racha_Sonar("Sound\\Interface\\MouseClick1.wav")
    call DestroyEffect(AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", Tut_BlancoX[k], Tut_BlancoY[k]))
endfunction

// Narración: hasta tres renglones con su máscara de corte; espera = segundos que se quedan tras escribirse.
function Tut_Decir takes string a,string ma,string b,string mb,string c,string mc,real espera returns nothing
    local integer i= 0
    set Tut_Linea[0] = a
    set Tut_Mask[0] = ma
    set Tut_Linea[1] = b
    set Tut_Mask[1] = mb
    set Tut_Linea[2] = c
    set Tut_Mask[2] = mc
    loop
        exitwhen i > 2
        set Tut_Car[i] = 0
        call SetTextTagText(s__UIText_text[Tut_Txt[i]], " ", 0.019)
        set i = i + 1
    endloop
    set Tut_Acc = 0.
    set Tut_Hold = espera
    set Tut_EsperaTexto = true
endfunction

// Avanza un carácter (sin cortar los de varios bytes ni los códigos de color). Falso si ya está todo escrito.
function Tut_Escribir takes nothing returns boolean
    local integer i= 0
    local integer n
    loop
        exitwhen i > 2
        set n = StringLength(Tut_Linea[i])
        if Tut_Car[i] < n then
            set Tut_Car[i] = Tut_Car[i] + 1
            loop
                exitwhen Tut_Car[i] >= n or SubString(Tut_Mask[i], Tut_Car[i], Tut_Car[i] + 1) == "1"
                set Tut_Car[i] = Tut_Car[i] + 1
            endloop
            call SetTextTagText(s__UIText_text[Tut_Txt[i]], SubString(Tut_Linea[i], 0, Tut_Car[i]), 0.019)
            return true
        endif
        set i = i + 1
    endloop
    return false
endfunction

function Tut_PanelVer takes boolean ver returns nothing
    local integer i= 0
    call ShowUnit(Tut_Panel, ver)
    call ShowUnit(Tut_Marco, ver)
    call ShowUnit(Tut_Cara, ver)
    if ver then
        // Mostrar antes de animar: el cambio de visibilidad puede reiniciar la animación.
        call SetUnitAnimationByIndex(Tut_Cara, DIALOGUE_RIGHT_IDLE)
        call HealthBars__Place(Tut_Panel, Tut_Cam, 344., 736., 396.)
        call HealthBars__Place(Tut_Cara, Tut_Cam, 110., 736., 394.)
        call HealthBars__Place(Tut_Marco, Tut_Cam, 110., 736., 388.)
    endif
    call s__UIText_show(Tut_Nombre, ver, Tut_Cam)
    loop
        exitwhen i > 2
        call s__UIText_show(Tut_Txt[i], ver, Tut_Cam)
        set i = i + 1
    endloop
endfunction

// Como la entrada directa de las pruebas: todos los jugadores entran ya registrados a la partida.
function Tut_Entrar takes nothing returns nothing
    local integer p= 0
    loop
        exitwhen p > 7
        if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            set Title_Registered[p] = true
            set Title_Count = Title_Count + 1
        endif
        set p = p + 1
    endloop
    call Title_Begin()
    call TimerStart(CreateTimer(), 0.1, false, function Title_Exit)
endfunction

function Tut_Terminar takes nothing returns nothing
    local integer p= 0
    local integer i= 0
    call PauseTimer(Tut_Reloj)
    call DestroyTimer(Tut_Reloj)
    set Tut_Reloj = null
    call RemoveUnit(Tut_Tauren)
    call RemoveUnit(Tut_Panel)
    call RemoveUnit(Tut_Marco)
    call RemoveUnit(Tut_Cara)
    call RemoveUnit(Tut_Foco)
    call RemoveUnit(Tut_Icono)
    call RemoveUnit(Tut_Mano)
    call RemoveUnit(Tut_Mira)
    call s__UIText_destroy(Tut_Nombre)
    call s__UIText_destroy(Tut_Etiqueta)
    loop
        exitwhen i > 2
        call s__UIText_destroy(Tut_Txt[i])
        set i = i + 1
    endloop
    loop
        exitwhen p > 11
        call FogModifierStop(Tut_Vista[p])
        call DestroyFogModifier(Tut_Vista[p])
        set Tut_Vista[p] = null
        set p = p + 1
    endloop
    call s__Camera_destroy(Tut_Cam)
    call EnableUserControl(true)
    call TimerStart(CreateTimer(), 0., false, function Tut_Entrar)
endfunction

function Tut_Guion takes nothing returns nothing
    if Tut_EsperaTexto or Tut_T < Tut_Sig then
        return
    endif
''' + ramas_txt + r'''    set Tut_Fase = Tut_Fase + 1
endfunction

function Tut_Tick takes nothing returns nothing
    local integer p= 0
    local integer k= 0
    local real r
    local real a
    local boolean habla
    set Tut_T = Tut_T + 0.02
    loop
        exitwhen p > 11
        if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            call s__Camera_applyCameraForPlayer(Tut_Cam, Player(p), true)
        endif
        set p = p + 1
    endloop
    loop
        exitwhen k > 3
        call Tut_Paso(k)
        set k = k + 1
    endloop
    // Texto a máquina, ~32 caracteres por segundo; el retrato habla mientras escribe.
    set habla = false
    if Tut_EsperaTexto then
        set Tut_Acc = Tut_Acc + 0.02 * 32.
        set habla = true
        loop
            exitwhen Tut_Acc < 1.
            set Tut_Acc = Tut_Acc - 1.
            if not Tut_Escribir() then
                set Tut_EsperaTexto = false
                set Tut_Sig = Tut_T + Tut_Hold
                set habla = false
                set Tut_Acc = 0.
            endif
        endloop
    endif
    if habla != Tut_Habla then
        set Tut_Habla = habla
        if habla then
            call SetUnitAnimationByIndex(Tut_Cara, DIALOGUE_RIGHT_TALK)
        else
            call SetUnitAnimationByIndex(Tut_Cara, DIALOGUE_RIGHT_IDLE)
        endif
    endif
    // Icono, foco y cursor.
    call Tut_Escala(Tut_Icono, 64. * Tut_IconoS, 64. * Tut_IconoS, 392.)
    call HealthBars__Place(Tut_Icono, Tut_Cam, Tut_PX[0], Tut_PY[0], 392.)
    set r = RMaxBJ(1., Tut_PX[2])
    call Tut_Escala(Tut_Foco, 64. * r, 64. * r, 430.)
    call HealthBars__Place(Tut_Foco, Tut_Cam, Tut_PX[1], Tut_PY[1], 430.)
    set a = RMinBJ(1., RMaxBJ(0., Tut_PY[2]))
    call SetUnitVertexColor(Tut_Foco, 255, 255, 255, R2I(255. * a))
    // La mano apunta con su esquina (punto activo 4,4 de 32): el centro va 18 px abajo a la derecha.
    call HealthBars__Place(Tut_Mano, Tut_Cam, Tut_PX[3] + 18., Tut_PY[3] + 18., 386.)
    call HealthBars__Place(Tut_Mira, Tut_Cam, Tut_PX[3], Tut_PY[3], 386.)
    call Tut_Guion()
endfunction

function Tut_Calibrar takes nothing returns nothing
    local integer p= 0
    loop
        exitwhen p > 11
        if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
            call s__Camera_calibrateHeightForPlayer(Tut_Cam, Player(p))
        endif
        set p = p + 1
    endloop
    call DestroyTimer(GetExpiredTimer())
endfunction

function Tut_Begin takes nothing returns nothing
    local integer p= 0
    local integer i= 0
    local location l= Location(Tut_X, Tut_Y)
    local rect zona= Rect(Tut_X - 2400., Tut_Y - 1300., Tut_X + 2400., Tut_Y + 1400.)
    call DestroyTimer(GetExpiredTimer())
    set Tut_Z = GetLocationZ(l)
    call RemoveLocation(l)
    set l = null
    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
    call ClearSelection()
    call EnableUserControl(false)
    loop
        exitwhen p > 11
        set Tut_Vista[p] = CreateFogModifierRect(Player(p), FOG_OF_WAR_VISIBLE, zona, true, true)
        call FogModifierStart(Tut_Vista[p])
        set p = p + 1
    endloop
    call RemoveRect(zona)
    set zona = null
    set Tut_Cam = s__Camera_create()
    call s__Camera_setPosition(Tut_Cam, Tut_X, Tut_Y, Tut_Z)
    set Tut_BlancoX[0] = Tut_X + 480.
    set Tut_BlancoY[0] = Tut_Y + 260.
    set Tut_BlancoX[1] = Tut_X + 520.
    set Tut_BlancoY[1] = Tut_Y
    set Tut_BlancoX[2] = Tut_X + 480.
    set Tut_BlancoY[2] = Tut_Y - 260.
    // El Tauren, de nadie y sin selección, entra desde la izquierda.
    set Tut_Tauren = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'h005', Tut_X - 1250., Tut_Y, 0.)
    call UnitAddAbility(Tut_Tauren, 'Aloc')
    call SetUnitInvulnerable(Tut_Tauren, true)
    call SetUnitMoveSpeed(Tut_Tauren, 300.)
    // Panel con retrato y marco (como la tarjeta de rachas, sin dueño).
    set Tut_Panel = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Panel, 640. * 396. / 400., 160. * 396. / 400., 400., 'DS1B')
    set Tut_Marco = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Marco, 150. * 388. / 400., 127. * 388. / 400., 400., 'DS19')
    set Tut_Cara = Tut_Pieza('dta0')
    set i = 0
    call SetUnitScale(Tut_Cara, 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4, 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4, 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4)
    set Tut_Foco = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Foco, 512., 512., 430., 'DS1A')
    set Tut_Icono = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Icono, 64., 64., 392., 'DS1E')
    set Tut_Mano = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Mano, 48., 48., 386., 'DS1C')
    set Tut_Mira = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Mira, 48., 48., 386., 'DS1D')
    call ShowUnit(Tut_Panel, false)
    call ShowUnit(Tut_Marco, false)
    call ShowUnit(Tut_Cara, false)
    call ShowUnit(Tut_Foco, false)
    call ShowUnit(Tut_Icono, false)
    call ShowUnit(Tut_Mano, false)
    call ShowUnit(Tut_Mira, false)
    // Textos para todos: nombre, tres renglones y la etiqueta del icono.
    set Tut_Nombre = s__UIText_create(( 200. - 960. ) / 728., ( 420. - 678. ) / 390., 1.)
    call SetTextTagPermanent(s__UIText_text[Tut_Nombre], true)
    call SetTextTagColor(s__UIText_text[Tut_Nombre], 255, 204, 0, 255)
    call SetTextTagText(s__UIText_text[Tut_Nombre], "Tauren", 0.016)
    loop
        exitwhen i > 2
        set Tut_Txt[i] = s__UIText_create(( 200. - 960. ) / 728., ( 420. - ( 722. + 27. * i ) ) / 390., 1.)
        call SetTextTagPermanent(s__UIText_text[Tut_Txt[i]], true)
        call SetTextTagColor(s__UIText_text[Tut_Txt[i]], 255, 255, 255, 255)
        call SetTextTagText(s__UIText_text[Tut_Txt[i]], " ", 0.019)
        set i = i + 1
    endloop
    set Tut_Etiqueta = s__UIText_create(( 900. - 960. ) / 728., ( 420. - 352. ) / 390., 1.)
    call SetTextTagPermanent(s__UIText_text[Tut_Etiqueta], true)
    call SetTextTagColor(s__UIText_text[Tut_Etiqueta], 255, 255, 255, 255)
    call Tut_Poner(0, 1529., 790., 0.)
    call Tut_Poner(1, 1529., 790., 0.)
    call Tut_Poner(2, 70., 0., 0.)
    call Tut_Poner(3, 1250., 560., 0.)
    call Tut_Nota("inicio z " + R2S(Tut_Z) + " cam " + I2S(Tut_Cam))
    set Tut_Reloj = CreateTimer()
    call TimerStart(Tut_Reloj, 0.02, true, function Tut_Tick)
    call TimerStart(CreateTimer(), 0.1, false, function Tut_Calibrar)
endfunction

function Intro_Begin takes nothing returns nothing
'''
s = once(s, 'function Intro_Begin takes nothing returns nothing\n', codigo)
Path(dst).write_text(s, encoding='latin-1', newline='')
print('v16a: fases', len(guion))
