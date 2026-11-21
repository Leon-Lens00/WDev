#!/usr/bin/env python3
"""v16h (08/11/2026): tienda, caja verde y despedida del tutorial (puntos 5, 6 y 7 del plan).
La tienda real se construye después del tutorial (Shop_Construir tras Title_Cleanup), se ve con la cámara cenital de
la tienda y es local por jugador. El tutorial usa una réplica para todos con la cámara del tutorial: las mismas
texturas (DS00..DS0D, DT3E, Cat_Tex) en los mismos píxeles de pantalla y los mismos textos, con datos de Arm_* y oro
del guion (800). Nada de la réplica toca la tienda real, el oro de los jugadores ni Arm_Tier.
Tras «¡Oleada superada!»:
- Un golem 'ngst' cae a X+1500 (4000 → 0 en 3 s, como DevTienda_Paso); el indicador del borde pasa a 'hbjt'/'ubjt'.
- Foco en el indicador; el Tauren camina hasta el golem y la cámara del tutorial lo sigue (hasta X+1000) con
  recalibrado de altura en cada paso; panel y textos se recolocan mientras se mueve.
- Aviso de la partida («Press [ESC] to buy supplies», copiado de DevTienda_Hud) con foco; ESC; la tienda.
- En la tienda la narración pasa a la columna derecha (retrato del Tauren en el hueco del golem): oro, tiers,
  recargar balas, Abastecer todo y vida, cambio de categoría a Escopetas, compra de T2 (Winchester 1887), reloj del
  descanso (cuenta desde 45) y Salir.
- Caja verde: MP18 a 0/0, foco en las balas, caja RecargaVerde.mdx, el Tauren va a ella, aviso «[ESC] Pick up Ammo»,
  recarga como Recarga_Tomar (cargador lleno y un cargador más de reserva) y la caja pasa a RecargaRoja.mdx.
- Despedida nueva y fundido a la partida.
Uso: v16h.py ENTRADA.j SALIDA.j (el j de v16g)
"""
from pathlib import Path
import re
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

N = '\r\n'
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s


def j(texto):
    """Texto JASS con acentos (UTF-8) para un j leído en latin-1."""
    return texto.encode('utf-8').decode('latin-1')


def mascara(linea):
    return ''.join('0' if 0x80 <= b <= 0xBF else '1' for b in linea.encode('utf-8'))


def decir(a, b='', c='', espera=0.3):
    for l in (a, b, c):
        assert len(l) <= 40, l
    return j(f'        call Tut_Decir("{a}", "{mascara(a)}", "{b}", "{mascara(b)}", "{c}", "{mascara(c)}", {espera})\n')


# Los dos avisos de la partida, tal cual (texto con degradado de color).
avisos = re.findall(r'call DevTienda_AvisoPoner\(DevTienda_Aviso\[p\] , ("[^"]*") , (\d+)\)', s)
assert len(avisos) == 2 and avisos[0][1] == '27' and avisos[1][1] == '18', avisos
AVISO_TIENDA, AVISO_CAJA = avisos[0][0], avisos[1][0]

s = once(s, 'integer Tut_JefeK= -1\n', '''integer Tut_JefeK= -1
unit Tut_Golem= null
real Tut_GolemT0= -1.
boolean Tut_Paneo= false
real Tut_CamX= 0.
integer Tut_CalibN= 0
real Tut_FaseT= 0.
integer Tut_Aviso= 0
integer Tut_AvisoB= 0
effect Tut_Caja= null
real Tut_CajaX= 0.
real Tut_CajaY= 0.
unit array Tut_SPz
real array Tut_SPx
real array Tut_SPy
real array Tut_SPd
integer array Tut_SAn
boolean array Tut_SFijo
integer Tut_SPzN= 0
integer array Tut_STx
integer Tut_STxN= 0
integer Tut_SCatOn= 0
integer Tut_SRowOn= 0
integer Tut_SBuyOn= 0
integer Tut_SRecOn= 0
integer Tut_STodoOn= 0
integer Tut_SVidaOn= 0
integer array Tut_SArma
integer array Tut_SCatT
integer array Tut_SFN
integer array Tut_SFP
integer array Tut_SV
integer Tut_SCab= 0
integer Tut_SBuy= 0
integer Tut_SRec= 0
integer Tut_STodo= 0
integer Tut_SVida= 0
integer Tut_SOro= 0
integer Tut_SReloj= 0
integer Tut_SRelojN= -1
real Tut_STiendaT0= 0.
boolean Tut_TiendaOn= false
integer Tut_SCat= 1
integer Tut_SFila= 1
integer array Tut_STier
integer array Tut_SRva
integer Tut_Oro= 800
integer Tut_SRondas= 1
''')

# Tut_Soltar (antes que las funciones nuevas): golem, caja, avisos, cámara y réplica de la tienda.
s = once(s, '''function Tut_Soltar takes nothing returns nothing
    local integer i= Tut_P * 7
''', '''function Tut_Soltar takes nothing returns nothing
    local integer i= Tut_P * 7
    local integer k= 0
''')
s = once(s, '''    call s__UIText_destroy(Tut_VidaUI)
''', '''    // v16h: golem, caja, avisos y réplica de la tienda.
    set Tut_Paneo = false
    set Tut_GolemT0 = - 1.
    if Tut_Golem != null then
        call RemoveUnit(Tut_Golem)
        set Tut_Golem = null
    endif
    if Tut_Caja != null then
        call DestroyEffect(Tut_Caja)
        set Tut_Caja = null
    endif
    if Tut_Aviso != 0 then
        call s__UIText_destroy(Tut_Aviso)
        set Tut_Aviso = 0
    endif
    if Tut_AvisoB != 0 then
        call s__UIText_destroy(Tut_AvisoB)
        set Tut_AvisoB = 0
    endif
    loop
        exitwhen k >= Tut_SPzN
        call RemoveUnit(Tut_SPz[k])
        set Tut_SPz[k] = null
        set k = k + 1
    endloop
    set Tut_SPzN = 0
    set k = 0
    loop
        exitwhen k >= Tut_STxN
        call s__UIText_destroy(Tut_STx[k])
        set k = k + 1
    endloop
    set Tut_STxN = 0
    set Tut_TiendaOn = false
    call s__UIText_destroy(Tut_VidaUI)
''')

FUNCS = r'''// v16h: el golem de la tienda cae fuera de la pantalla; el indicador del borde pasa a ser el de la tienda.
function Tut_GolemCrear takes nothing returns nothing
    set Tut_Golem = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'ngst', Tut_X + 1500., Tut_Y + 60., 180.)
    call SetUnitInvulnerable(Tut_Golem, true)
    call UnitAddAbility(Tut_Golem, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Tut_Golem, s__Interface_DESTROYER_FORM_ID)
    call SetUnitX(Tut_Golem, Tut_X + 1500.)
    call SetUnitY(Tut_Golem, Tut_Y + 60.)
    call SetUnitFlyHeight(Tut_Golem, 4000., 0.)
    call SetUnitAnimation(Tut_Golem, "sleep")
    set Tut_GolemT0 = Tut_T
    if Tut_JefeIcono != null then
        call RemoveUnit(Tut_JefeIcono)
        call RemoveUnit(Tut_JefeEsfera)
    endif
    set Tut_JefeIcono = Tut_Pieza('hbjt')
    set Tut_JefeEsfera = Tut_Pieza('ubjt')
    call SetUnitScale(Tut_JefeEsfera, 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ))
    call ShowUnit(Tut_JefeIcono, false)
    call ShowUnit(Tut_JefeEsfera, false)
    set Tut_MarcaVer = false
    set Tut_Jefe = Tut_Golem
endfunction

// Como DevTienda_Paso: baja frenando, altura 4000 × (1 − t / 3)².
function Tut_GolemPaso takes nothing returns nothing
    local real u
    if Tut_GolemT0 < 0. then
        return
    endif
    set u = ( Tut_T - Tut_GolemT0 ) / 3.
    if u >= 1. then
        set Tut_GolemT0 = - 1.
        call SetUnitFlyHeight(Tut_Golem, 0., 0.)
        call SetUnitAnimation(Tut_Golem, "birth")
        call QueueUnitAnimation(Tut_Golem, "stand")
        call Tut_Nota("golem en el suelo t " + R2S(Tut_T))
    else
        call SetUnitFlyHeight(Tut_Golem, 4000. * ( 1. - u ) * ( 1. - u ), 0.)
    endif
endfunction

// v16h: la cámara del tutorial sigue al Tauren hacia el golem (hasta X+1000). Antes de moverla se recalibra la altura
// con lo que se pintó en el paso anterior, para que el suelo nuevo no desplace las piezas de interfaz.
function Tut_Camara takes nothing returns nothing
    local real x
    local integer p= 0
    if not Tut_Paneo then
        return
    endif
    if Tut_CalibN > 0 then
        set Tut_CalibN = Tut_CalibN - 1
        loop
            exitwhen p > 11
            if GetPlayerController(Player(p)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING then
                call s__Camera_calibrateHeightForPlayer(Tut_Cam, Player(p))
            endif
            set p = p + 1
        endloop
    endif
    set x = RMinBJ(Tut_X + 1000., RMaxBJ(Tut_X, GetUnitX(Tut_Tauren)))
    if RAbsBJ(x - Tut_CamX) < 0.5 then
        return
    endif
    set Tut_CamX = Tut_CamX + ( x - Tut_CamX ) * 0.06
    if RAbsBJ(x - Tut_CamX) < 0.5 then
        set Tut_CamX = x
    endif
    call s__Camera_setEyeAndAt(Tut_Cam, Tut_CamX, Tut_Y - 900., Tut_Z + 1333., Tut_CamX, Tut_Y, Tut_Z)
    call s__UIText_updateAll()
    if not IsUnitHidden(Tut_Panel) then
        call HealthBars__Place(Tut_Panel, Tut_Cam, 344., 736., 396.)
        call HealthBars__Place(Tut_Cara, Tut_Cam, 110., 736., 394.)
        call HealthBars__Place(Tut_Marco, Tut_Cam, 110., 736., 388.)
    endif
    set Tut_CalibN = 25
endfunction

// v16h: aviso del centro de la pantalla, como DevTienda_AvisoPoner, para todos.
function Tut_AvisoCrear takes string a,integer n returns integer
    local integer ui= s__UIText_create(0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[ui], true)
    call SetTextTagColor(s__UIText_text[ui], 255, 255, 255, 255)
    call s__UIText_setPosition(ui, ( - I2R(n) * 4.5 * 0.026 / 0.017 ) / 728., ( 420. - 520. ) / 390.)
    call SetTextTagText(s__UIText_text[ui], a, 0.026)
    call s__UIText_show(ui, true, Tut_Cam)
    return ui
endfunction

// v16h: pieza de la réplica de la tienda (los píxeles y profundidades de Shop_Construir; Shop_PY no hace falta aquí).
function Tut_SPic takes real px,real py,real w,real h,real d,integer tex returns integer
    local unit u= Tut_Pieza('uidb')
    local real ww= w * ( 0.544 / 718.18930543 ) * d
    local real hh= h * ( 0.302 / 387.73819261 ) * d
    local real a
    local integer anim= 0
    if hh < ww then
        set anim = IMinBJ(100, R2I(10 * ( ww / hh - 1 ) + 0.5))
    else
        set a = 10 * ( hh / ww - 1 )
        if a >= 0.5 then
            set anim = 100 + IMinBJ(100, R2I(a + 0.5))
        endif
    endif
    call Tut_Foto(u, w, h, d, tex)
    call ShowUnit(u, false)
    set Tut_SPz[Tut_SPzN] = u
    set Tut_SPx[Tut_SPzN] = px
    set Tut_SPy[Tut_SPzN] = py
    set Tut_SPd[Tut_SPzN] = d
    set Tut_SAn[Tut_SPzN] = anim
    set Tut_SFijo[Tut_SPzN] = true
    set Tut_SPzN = Tut_SPzN + 1
    set u = null
    return Tut_SPzN - 1
endfunction

// Mostrar antes de animar: el cambio de visibilidad puede reiniciar la animación (la del aspecto).
function Tut_SMostrar takes integer k,boolean on returns nothing
    call ShowUnit(Tut_SPz[k], on)
    if on then
        call SetUnitAnimationByIndex(Tut_SPz[k], Tut_SAn[k])
        call HealthBars__Place(Tut_SPz[k], Tut_Cam, Tut_SPx[k], Tut_SPy[k], Tut_SPd[k])
    endif
endfunction

function Tut_STexto takes real px,real py,real size,string a returns integer
    local integer ui= s__UIText_create(( px - 960. ) / 728., ( 420. - py ) / 390., 1.)
    call SetTextTagPermanent(s__UIText_text[ui], true)
    call SetTextTagColor(s__UIText_text[ui], 235, 240, 245, 255)
    call SetTextTagText(s__UIText_text[ui], a, size)
    set Tut_STx[Tut_STxN] = ui
    set Tut_STxN = Tut_STxN + 1
    return ui
endfunction

// Como Shop_Izq (izquierda en px) o Shop_Centro y Shop_Der (centrado en px), con el ancho de Shop_Centro.
function Tut_SEscribir takes integer ui,string a,real px,real py,real size,boolean centro returns nothing
    if centro then
        set px = px - I2R(StringLength(a)) * size * 470. / 2.
    endif
    call SetTextTagText(s__UIText_text[ui], a, size)
    call s__UIText_setPosition(ui, ( px - 960. ) / 728., ( 420. - py ) / 390.)
endfunction

function Tut_SGris takes integer ui,integer g returns nothing
    call SetTextTagColor(s__UIText_text[ui], g, g, IMinBJ(255, g + 8), 255)
endfunction

function Tut_SAzul takes integer ui returns nothing
    call SetTextTagColor(s__UIText_text[ui], 115, 200, 255, 255)
endfunction

function Tut_TiendaCrear takes nothing returns nothing
    local integer i= 1
    call Tut_SPic(307., 442., 430., 784., 460., 'DS00')
    call Tut_SPic(948., 442., 800., 784., 460., 'DS01')
    call Tut_SPic(1601., 442., 454., 784., 460., 'DS02')
    call Tut_SPic(1601., 269., 230., 230., 420., 'DS0D')
    call Tut_SPic(1601., 269., 298.21, 290., 403., 'DT3E')
    call Tut_SPic(755., 594., 330., 196., 399., 'DS04')
    loop
        exitwhen i > 6
        call Tut_SPic(307., 161. + 66. * ( i - 1 ), 340., 62., 399., 'DS06')
        call Tut_SPic(166.5, 161. + 66. * ( i - 1 ), 15., 26., 398.4, 'DS0C')
        set Tut_SCatT[i] = Tut_STexto(187., 146. + 66. * ( i - 1 ), 0.022, Cat_Nombre[i])
        set i = i + 1
    endloop
    set Tut_SCatOn = Tut_SPic(307., 161., 340., 62., 398.5, 'DS05')
    set Tut_SFijo[Tut_SCatOn] = false
    set Tut_SArma[1] = Tut_SPic(755., 594., 300., 150., 398.6, Cat_Tex[1])
    set Tut_SFijo[Tut_SArma[1]] = false
    set Tut_SArma[4] = Tut_SPic(755., 594., 300., 150., 398.6, Cat_Tex[4])
    set Tut_SFijo[Tut_SArma[4]] = false
    set i = 0
    loop
        exitwhen i > 5
        call Tut_SPic(948., 156. + 58. * i, 716., 56., 399., 'DS08')
        call Tut_SPic(660., 156. + 58. * i, 15., 26., 398.4, 'DS0C')
        set Tut_SFN[i] = Tut_STexto(678., 141. + 58. * i, 0.022, "")
        set Tut_SFP[i] = Tut_STexto(1190., 141. + 58. * i, 0.022, "")
        set i = i + 1
    endloop
    set Tut_SRowOn = Tut_SPic(948., 156., 716., 56., 398.5, 'DS07')
    set Tut_SFijo[Tut_SRowOn] = false
    call Tut_SPic(948., 773., 716., 62., 399., 'DS0B')
    set Tut_SBuyOn = Tut_SPic(948., 773., 716., 62., 398.5, 'DS07')
    set Tut_SFijo[Tut_SBuyOn] = false
    call Tut_SPic(1601., 773., 366., 62., 399., 'DS0A')
    set Tut_SRecOn = Tut_SPic(1601., 773., 366., 62., 398.5, 'DS09')
    set Tut_SFijo[Tut_SRecOn] = false
    call Tut_SPic(1601., 639., 366., 62., 399., 'DS0A')
    set Tut_STodoOn = Tut_SPic(1601., 639., 366., 62., 398.5, 'DS09')
    set Tut_SFijo[Tut_STodoOn] = false
    call Tut_SPic(1601., 706., 366., 62., 399., 'DS0A')
    set Tut_SVidaOn = Tut_SPic(1601., 706., 366., 62., 398.5, 'DS09')
    set Tut_SFijo[Tut_SVidaOn] = false
    call Tut_SPic(307., 773., 340., 62., 399., 'DS06')
    call Tut_STexto(137., 92., 0.026, "Categorías")
    call Tut_STexto(1140., 96., 0.02, "Precio")
    call Tut_STexto(950., 522., 0.017, "Daño")
    call Tut_STexto(1140., 522., 0.017, "Cargador")
    call Tut_STexto(950., 606., 0.017, "Cadencia")
    call Tut_STexto(1140., 606., 0.017, "Precisión")
    call Tut_STexto(1424., 562., 0.024, "Oro")
    call Tut_STexto(250., 758., 0.024, "Salir (Esc)")
    set Tut_SCab = Tut_STexto(760., 92., 0.026, "")
    set i = 0
    loop
        exitwhen i > 3
        set Tut_SV[i] = Tut_STexto(950., 548., 0.026, "")
        set i = i + 1
    endloop
    set Tut_SBuy = Tut_STexto(948., 758., 0.024, "")
    set Tut_SRec = Tut_STexto(1601., 758., 0.021, "")
    set Tut_STodo = Tut_STexto(1601., 624., 0.021, "")
    set Tut_SVida = Tut_STexto(1601., 691., 0.021, "")
    set Tut_SOro = Tut_STexto(1490., 556., 0.026, "")
    set Tut_SReloj = Tut_STexto(1650., 92., 0.022, "")
    call Tut_Nota("tienda piezas " + I2S(Tut_SPzN) + " textos " + I2S(Tut_STxN))
endfunction

// Balas que faltan en la reserva del arma en uso de la categoría c (réplica).
function Tut_SFalta takes integer c returns integer
    if Tut_STier[c] <= 0 then
        return 0
    endif
    return IMaxBJ(0, Arm_Res[c * 6 + Tut_STier[c] - 1] - Tut_SRva[c])
endfunction

function Tut_SCosto takes integer c returns integer
    if Tut_SFalta(c) <= 0 then
        return 0
    endif
    return Shop_CostoBalas(c * 6 + Tut_STier[c] - 1, Tut_SFalta(c))
endfunction

// Como Shop_Refrescar con los datos de la réplica (rondas pasadas: 1).
function Tut_SRefrescar takes nothing returns nothing
    local integer c= Tut_SCat
    local integer t= Tut_SFila
    local integer have= Tut_STier[c]
    local integer w= c * 6 + t - 1
    local integer k= 1
    local integer x
    local integer g
    local integer total
    local string a
    call Tut_SEscribir(Tut_SCab, Cat_Nombre[c], 760., 92., 0.026, true)
    loop
        exitwhen k > 6
        if k == c then
            call Tut_SAzul(Tut_SCatT[k])
        else
            call Tut_SGris(Tut_SCatT[k], 170)
        endif
        set k = k + 1
    endloop
    set Tut_SPy[Tut_SCatOn] = 161. + 66. * ( c - 1 )
    call Tut_SMostrar(Tut_SCatOn, true)
    call Tut_SMostrar(Tut_SArma[1], c == 1)
    call Tut_SMostrar(Tut_SArma[4], c == 4)
    set Tut_SPy[Tut_SRowOn] = 156. + 58. * ( t - 1 )
    call Tut_SMostrar(Tut_SRowOn, true)
    set k = 0
    loop
        exitwhen k > 5
        set x = c * 6 + k
        set a = ""
        if Arm_Anio[x] >= 0 then
            set a = "  (" + I2S(Arm_Anio[x]) + ")"
        endif
        call Tut_SEscribir(Tut_SFN[k], Arm_TierTexto(k + 1) + "  " + Arm_Nombre[x] + a, 678., 141. + 58. * k, 0.022, false)
        if k + 1 < have then
            set a = "Obsoleta"
            set g = 95
        elseif k + 1 == have then
            set a = "En uso"
            set g = 255
        elseif k == have and Tut_SRondas < Arm_Req(k + 1) then
            set a = "Tras la ronda " + I2S(Arm_Req(k + 1))
            set g = 130
        elseif k == have then
            set a = I2S(Arm_Precio[x]) + " oro"
            set g = 225
        else
            set a = "Bloqueada"
            set g = 130
        endif
        call Tut_SEscribir(Tut_SFP[k], a, 1190., 141. + 58. * k, 0.022, true)
        if k + 1 == t then
            call Tut_SAzul(Tut_SFN[k])
            call Tut_SAzul(Tut_SFP[k])
        else
            call Tut_SGris(Tut_SFN[k], g)
            call Tut_SGris(Tut_SFP[k], g)
        endif
        set k = k + 1
    endloop
    if Arm_Perd[w] > 1 then
        set a = I2S(Arm_Perd[w]) + " x " + I2S(R2I(Arm_Dano[w]))
    else
        set a = I2S(R2I(Arm_Dano[w]))
    endif
    call Tut_SEscribir(Tut_SV[0], a, 950., 548., 0.026, false)
    call Tut_SEscribir(Tut_SV[1], I2S(Arm_Mag[w]) + " / " + I2S(Arm_Res[w]), 1140., 548., 0.026, false)
    call Tut_SEscribir(Tut_SV[2], I2S(R2I(60. / Arm_Int[w] + 0.5)) + " rpm  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s", 950., 632., 0.024, false)
    call Tut_SEscribir(Tut_SV[3], I2S(100 - R2I(Arm_Disp[w] * 6.)) + "%", 1140., 632., 0.026, false)
    if t < have then
        set a = "Obsoleta"
    elseif t == have then
        set a = "Ya la tienes"
    elseif t == have + 1 and Tut_SRondas < Arm_Req(t) then
        set a = "Disponible tras la ronda " + I2S(Arm_Req(t))
    elseif t == have + 1 then
        set a = "Comprar: " + I2S(Arm_Precio[w]) + " oro"
    else
        set a = "Necesitas T" + I2S(t - 1)
    endif
    call Tut_SMostrar(Tut_SBuyOn, t == have + 1 and Tut_SRondas >= Arm_Req(t))
    call Tut_SEscribir(Tut_SBuy, a, 948., 758., 0.024, true)
    set a = "Munición completa"
    if Tut_SFalta(c) > 0 then
        set a = I2S(Tut_SFalta(c)) + " balas: " + I2S(Tut_SCosto(c)) + " oro"
    endif
    call Tut_SMostrar(Tut_SRecOn, Tut_SFalta(c) > 0)
    call Tut_SEscribir(Tut_SRec, a, 1601., 758., 0.021, true)
    set total = Tut_SCosto(1) + Tut_SCosto(4)
    set a = "Todo abastecido"
    if total > 0 then
        set a = "Abastecer todo: " + I2S(total) + " oro"
    endif
    call Tut_SMostrar(Tut_STodoOn, total > 0 and Tut_Oro > 0)
    call Tut_SEscribir(Tut_STodo, a, 1601., 624., 0.021, true)
    call Tut_SMostrar(Tut_SVidaOn, Tut_Oro >= Shop_VIDA)
    call Tut_SEscribir(Tut_SVida, "Vida: " + I2S(Shop_VIDA) + " oro", 1601., 691., 0.021, true)
    call Tut_SEscribir(Tut_SOro, I2S(Tut_Oro), 1490., 556., 0.026, false)
    call Tut_Nota("tienda cat " + I2S(c) + " fila " + I2S(t) + " tier " + I2S(have) + " oro " + I2S(Tut_Oro) + " falta " + I2S(Tut_SFalta(c)) + " t " + R2S(Tut_T))
endfunction

function Tut_TiendaVer takes boolean on returns nothing
    local integer k= 0
    loop
        exitwhen k >= Tut_SPzN
        if Tut_SFijo[k] or not on then
            call Tut_SMostrar(k, on)
        endif
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k >= Tut_STxN
        call s__UIText_show(Tut_STx[k], on, Tut_Cam)
        set k = k + 1
    endloop
    set Tut_TiendaOn = on
    if on then
        call Tut_SRefrescar()
    endif
endfunction

// El reloj del descanso, desde 45, mientras la réplica está abierta.
function Tut_SRelojPaso takes nothing returns nothing
    local integer n
    if not Tut_TiendaOn then
        return
    endif
    set n = IMaxBJ(0, 45 - R2I(Tut_T - Tut_STiendaT0))
    if n != Tut_SRelojN then
        set Tut_SRelojN = n
        call Tut_SEscribir(Tut_SReloj, "Descanso " + I2S(n), 1650., 92., 0.022, false)
    endif
endfunction

// La narración pasa a la columna derecha (nombre arriba, retrato en el hueco del golem, tres renglones debajo).
function Tut_TiendaAbrir takes nothing returns nothing
    local real e= 200. * ( 0.302 / 387.73819261 ) * 394. / 21.4
    local integer i= 0
    if Tut_SPzN == 0 then
        call Tut_TiendaCrear()
    endif
    set Tut_SCat = 1
    set Tut_SFila = 1
    set Tut_STier[1] = 1
    set Tut_STier[4] = 1
    set Tut_SRva[1] = IMinBJ(Arm_Rva[Tut_P * 7 + 1], Arm_Res[6] - 64)
    set Tut_SRva[4] = Arm_Rva[Tut_P * 7 + 4]
    set Tut_Oro = 800
    set Tut_SRondas = 1
    set Tut_STiendaT0 = Tut_T
    set Tut_SRelojN = - 1
    set Tut_HudVer = false
    call ShowUnit(Tut_Panel, false)
    call ShowUnit(Tut_Marco, false)
    call SetUnitScale(Tut_Cara, e, e, e)
    call HealthBars__Place(Tut_Cara, Tut_Cam, 1601., 269., 394.)
    call s__UIText_setPosition(Tut_Nombre, ( 1418. - 960. ) / 728., ( 420. - 92. ) / 390.)
    loop
        exitwhen i > 2
        call s__UIText_setPosition(Tut_Txt[i], ( 1424. - 960. ) / 728., ( 420. - ( 440. + 34. * i ) ) / 390.)
        set i = i + 1
    endloop
    call Tut_TiendaVer(true)
endfunction

function Tut_TiendaCerrar takes nothing returns nothing
    local real e= 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4
    local integer i= 0
    call Tut_TiendaVer(false)
    call SetUnitScale(Tut_Cara, e, e, e)
    call s__UIText_setPosition(Tut_Nombre, ( 200. - 960. ) / 728., ( 420. - 678. ) / 390.)
    loop
        exitwhen i > 2
        call s__UIText_setPosition(Tut_Txt[i], ( 200. - 960. ) / 728., ( 420. - ( 722. + 27. * i ) ) / 390.)
        set i = i + 1
    endloop
    call Tut_PanelVer(true)
    set Tut_HudVer = true
endfunction

// Clic de la réplica: el oro baja y la reserva del arma en uso se llena.
function Tut_SRecargar takes nothing returns nothing
    local integer c= Tut_SCat
    set Tut_Oro = Tut_Oro - Tut_SCosto(c)
    set Tut_SRva[c] = Arm_Res[c * 6 + Tut_STier[c] - 1]
    call Tut_SRefrescar()
endfunction

function Tut_SComprar takes nothing returns nothing
    local integer c= Tut_SCat
    local integer w= c * 6 + Tut_SFila - 1
    set Tut_Oro = Tut_Oro - Arm_Precio[w]
    set Tut_STier[c] = Tut_SFila
    set Tut_SRva[c] = Arm_Res[w]
    call Tut_SRefrescar()
endfunction

'''
s = once(s, 'function Tut_Guion takes nothing returns nothing\n', j(FUNCS) + 'function Tut_Guion takes nothing returns nothing\n')

s = once(s, '''    set Tut_T = Tut_T + 0.02
''', '''    set Tut_T = Tut_T + 0.02
    call Tut_Camara()
''')
s = once(s, '''    call Tut_Rejilla()
    call Tut_Guion()''', '''    call Tut_Rejilla()
    call Tut_GolemPaso()
    call Tut_SRelojPaso()
    call Tut_Guion()''')


def foco(x, y, r, dur=0.7):
    return f'''        call Tut_Poner(1, {x}, {y}, 0.)
        call Tut_Poner(2, 420., 0., 0.)
        call Tut_Mover(2, {r}, 1., {dur})
        call ShowUnit(Tut_Foco, true)
'''


def mover_foco(x, y, r, dur=0.6):
    return f'''        call Tut_Mover(1, {x}, {y}, {dur})
        call Tut_Mover(2, {r}, 1., {dur})
'''


QUITAR_FOCO = '        call Tut_Mover(2, 420., 0., 0.5)\n'
CLIC = '        call Racha_Sonar("Sound\\\\Interface\\\\MouseClick1.wav")\n'
BOTON = '        call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")\n'
VOZ = '        call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenYes3.wav")\n'
GX, GY = 'Tut_X + 1270.', 'Tut_Y + 60.'

fases = [
    # 62: el golem cae fuera de la pantalla.
    '        call Tut_Estado("descanso")\n        call Tut_GolemCrear()\n' + BOTON
    + decir('Durante el descanso baja la tienda:', 'un golem que cae en algún lugar', 'del mapa.', 0.4),
    # 63: foco en su indicador.
    foco('Tut_MarcaX', 'Tut_MarcaY', '70.') + decir('Este indicador te muestra hacia', 'dónde está la tienda.', '', 0.4),
    # 64: el Tauren va hacia el golem y la cámara lo sigue.
    QUITAR_FOCO + f'''        set Tut_CamX = Tut_X
        set Tut_Paneo = true
        set Tut_FaseT = Tut_T
        call Tut_Ir({GX}, {GY})
''' + decir('Camina hasta él para comprar.', '', '', 0.2),
    # 65: espera a que llegue (o 10 s); aviso de la partida.
    f'''        call ShowUnit(Tut_Foco, false)
        if not IsUnitInRangeXY(Tut_Tauren, {GX}, {GY}, 90.) and Tut_T < Tut_FaseT + 10. then
            set Tut_Sig = Tut_T + 0.1
            return
        endif
        call Tut_Estado("golem")
        call Tut_Nota("camara x " + R2S(Tut_CamX))
        set Tut_Aviso = Tut_AvisoCrear({AVISO_TIENDA}, 27)
        set Tut_Sig = Tut_T + 0.6
''',
    # 66: foco en el aviso.
    foco('960.', '532.', '200.') + decir('Junto al golem, pulsa ESC para', 'abrir la tienda.', '', 0.3),
    # 67: ESC.
    '        call Tut_Mover(2, 420., 0., 0.3)\n' + CLIC + '''        call s__UIText_show(Tut_Aviso, false, Tut_Cam)
        call Pres_Black(0, 255, 0.3)
        set Tut_Sig = Tut_T + 0.4
''',
    # 68: la tienda.
    '''        call ShowUnit(Tut_Foco, false)
        call Tut_TiendaAbrir()
        call Pres_Black(255, 0, 0.3)
''' + decir('Esta es la tienda. Con el oro que', 'ganas en las oleadas compras', 'armas, mejoras y balas.', 0.3),
    # 69: el oro.
    foco('1475.', '575.', '95.') + decir('Aquí ves el oro que tienes.', '', '', 0.3),
    # 70: los tiers.
    mover_foco('948.', '300.', '380.') + decir('Cada arma tiene 6 tiers, uno por', 'color. Se compran en orden y los', 'altos se abren tras algunas rondas.', 0.6),
    # 71: recargar balas.
    mover_foco('1601.', '773.', '190.') + '''        call Tut_Poner(3, 1250., 560., 0.)
        call Tut_Mover(3, 1601., 773., 0.9)
        call ShowUnit(Tut_Mano, true)
''' + decir('Con este botón recargas la reserva', 'del arma que estás viendo.', '', 0.2),
    # 72: clic.
    CLIC + '        call Tut_SRecargar()\n        set Tut_Sig = Tut_T + 0.9\n',
    # 73: Abastecer todo y vida.
    mover_foco('1601.', '672.', '200.') + '        call Tut_Mover(3, 1601., 639., 0.6)\n'
    + decir('«Abastecer todo» llena las de todas', 'tus armas; debajo compras una vida', 'extra.', 0.4),
    # 74: categorías.
    mover_foco('307.', '326.', '240.') + '        call Tut_Mover(3, 307., 359., 0.9)\n'
    + decir('A la izquierda cambias de', 'categoría.', '', 0.2),
    # 75: clic en Escopetas.
    CLIC + '''        set Tut_SCat = 4
        set Tut_SFila = IMaxBJ(1, Tut_STier[4])
        call Tut_SRefrescar()
        set Tut_Sig = Tut_T + 0.9
''',
    # 76: el tier siguiente.
    mover_foco('948.', '214.', '300.') + '        call Tut_Mover(3, 948., 214., 0.8)\n'
    + decir('Elige el siguiente tier y pulsa', 'Comprar para mejorar el arma.', '', 0.2),
    # 77: clic en T2.
    CLIC + '''        set Tut_SFila = 2
        call Tut_SRefrescar()
        set Tut_Sig = Tut_T + 0.6
''',
    # 78: al botón de compra.
    mover_foco('948.', '773.', '360.') + '        call Tut_Mover(3, 948., 773., 0.8)\n        set Tut_Sig = Tut_T + 1.1\n',
    # 79: compra.
    CLIC + VOZ + '        call Tut_SComprar()\n'
    + decir('¡Comprada! El tier anterior queda', 'obsoleto y el nuevo, en uso.', '', 0.4),
    # 80: reloj del descanso y Salir.
    mover_foco('1712.', '104.', '85.') + '        call Tut_Mover(3, 307., 773., 1.0)\n'
    + decir('Arriba ves lo que queda de', 'descanso. Sal con ESC o con Salir.', '', 0.4),
    # 81: clic en Salir.
    CLIC + '''        call Tut_Mover(2, 420., 0., 0.3)
        call Pres_Black(0, 255, 0.3)
        set Tut_Sig = Tut_T + 0.4
''',
    # 82: de vuelta a la partida.
    '''        call ShowUnit(Tut_Foco, false)
        call ShowUnit(Tut_Mano, false)
        call Tut_TiendaCerrar()
        call Pres_Black(255, 0, 0.3)
        set Tut_Sig = Tut_T + 0.8
''',
    # 83: sin balas.
    '''        call Arm_Elegir(Tut_P, 1)
        set Arm_Clip[Tut_P * 7 + 1] = 0
        set Arm_Rva[Tut_P * 7 + 1] = 0
        call Tut_Estado("sin balas")
''' + foco('215.', '222.', '115.') + BOTON + decir('¿Te quedaste sin balas durante', 'la oleada?', '', 0.4),
    # 84: la caja verde.
    r'''        set Tut_CajaX = Tut_X + 850.
        set Tut_CajaY = Tut_Y - 260.
        set Tut_Caja = AddSpecialEffect("war3mapImported\\RecargaVerde.mdx", Tut_CajaX, Tut_CajaY)
        call Tut_Pantalla(Tut_CajaX, Tut_CajaY, Tut_Z)
''' + mover_foco('Tut_PuntoX', 'Tut_PuntoY', '110.') + decir('Busca una caja verde: hay varias', 'repartidas por el mapa.', '', 0.3),
    # 85: el Tauren va a la caja.
    QUITAR_FOCO + '''        set Tut_FaseT = Tut_T
        call Tut_Ir(Tut_CajaX, Tut_CajaY)
        set Tut_Sig = Tut_T + 0.6
''',
    # 86: espera a que llegue (o 8 s); aviso de la caja.
    f'''        call ShowUnit(Tut_Foco, false)
        if not IsUnitInRangeXY(Tut_Tauren, Tut_CajaX, Tut_CajaY, 110.) and Tut_T < Tut_FaseT + 8. then
            set Tut_Sig = Tut_T + 0.1
            return
        endif
        call Tut_Estado("caja")
        set Tut_AvisoB = Tut_AvisoCrear({AVISO_CAJA}, 18)
        set Tut_Sig = Tut_T + 0.5
''',
    # 87: foco en el aviso.
    foco('960.', '532.', '140.') + decir('Pulsa ESC junto a ella: llena el', 'cargador y suma otro a la reserva.', '', 0.3),
    # 88: ESC; recarga como Recarga_Tomar y la caja pasa a roja.
    CLIC + r'''        call s__UIText_show(Tut_AvisoB, false, Tut_Cam)
        set Arm_Clip[Tut_P * 7 + 1] = Arm_Mag[6]
        set Arm_Rva[Tut_P * 7 + 1] = IMinBJ(Arm_Res[6], Arm_Rva[Tut_P * 7 + 1] + Arm_Mag[6])
        set Arm_Fin[Tut_P] = 0.
        call DestroyEffect(Tut_Caja)
        set Tut_Caja = AddSpecialEffect("war3mapImported\\RecargaRoja.mdx", Tut_CajaX, Tut_CajaY)
        call Tut_Estado("recargada")
''' + mover_foco('215.', '222.', '115.') + decir('La caja se pone roja: cada jugador', 'la usa una vez por oleada, y para', 'los demás sigue verde.', 0.6),
    # 89: despedida.
    QUITAR_FOCO + '        call SetUnitFacingTimed(Tut_Tauren, 270., 0.4)\n' + VOZ
    + decir('¡Ya conoces lo básico! Recuerda', 'que la tienda sólo baja en el', 'descanso. ¡Suerte en la batalla!', 2.6),
    # 90: fundido.
    '''        call ShowUnit(Tut_Foco, false)
        call Pres_Black(0, 255, 1.2)
        set Tut_Sig = Tut_T + 1.35
''',
    # 91: fin.
    '''        call Tut_Nota("fin " + R2S(Tut_T))
        call Tut_Terminar()
        return
''',
]
bloque = ''
for n, cuerpo in enumerate(fases, 62):
    bloque += f'    elseif Tut_Fase == {n} then\n        call Tut_Nota("fase {n} " + R2S(Tut_T))\n' + cuerpo
bloque = bloque.replace('\n', N)

ini = s.index('    elseif Tut_Fase == 62 then\r\n')
fin_txt = '        call Tut_Terminar()\r\n        return\r\n    endif\r\n'
fin = s.index(fin_txt, ini) + len(fin_txt)
assert s.count(fin_txt) == 1
viejo = s[ini:fin]
assert 'Tut_Fase == 64' in viejo and 'Tut_Fase == 65' not in viejo, viejo[:200]
s = s[:ini] + bloque + '    endif\r\n' + s[fin:]
assert '\n' not in s.replace('\r\n', '')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16h ok, fases 62..', 62 + len(fases) - 1)
