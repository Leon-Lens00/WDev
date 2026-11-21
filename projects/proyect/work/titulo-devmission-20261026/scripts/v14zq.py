#!/usr/bin/env python3
"""v14zq (07/11/2026): el anuncio de rachas pasa de 3 filas de texto a una tarjeta.
- Cuadro 'uidb' de 480 × 60 px con la textura RachaCaja ('DS18', tarjeta_v14zq.py): arriba el nombre del jugador
  (0,015), debajo el texto de la racha (0,020, antes 0,013), centrados en el cuadro del texto sea cual sea su largo.
- Al final, el retrato del personaje que anota ('dta0' Tauren o 'dca0' Cairne, los de la conversación), que hace su
  animación de hablar mientras suena su voz (Racha_VozLen, duración de cada archivo).
- Una tarjeta a la vez: baja rápido desde arriba (sale de detrás de la barra superior) hasta y 150; a los 5 s, o cuando
  llega otro anuncio, sube hasta salir de la vista, y la siguiente baja cuando la anterior ya salió. Dos tarjetas en
  el grupo (la que sale y la que entra); el estado de las tarjetas es igual en todos los clientes.
- Cada jugador ve sus propias piezas (HealthBars__Dummy, alfa sólo en su cliente); los dos textos de cada tarjeta se
  crean sólo en el cliente del que mira y sólo mientras se ve (con la tienda abierta no hay ninguno), para no gastar
  el presupuesto de 100 texttags. El marcador sigue igual.
Uso: v14zq.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')


def once(s, old, new):
    # El j guarda los acentos en UTF-8 y se lee en latin-1.
    u = lambda x: x.encode('utf-8').decode('latin-1')
    return base.once(s, u(old), u(new))



s = once(s, 'integer Racha_SonN= 0\n', '''integer Racha_SonN= 0
boolean array Racha_CActiva
boolean array Racha_CSale
boolean array Racha_CCairne
integer array Racha_CPid
integer array Racha_CVer
string array Racha_CTexto
string array Racha_CNombre
real array Racha_CAnchoN
real array Racha_CAnchoL
real array Racha_CY
real array Racha_CFin
real array Racha_CHabla
real array Racha_VozLen
unit array Racha_Caja
unit array Racha_Cara
integer array Racha_TT
boolean array Racha_VShow
integer array Racha_VVer
integer array Racha_VHabla
real Racha_Y= 150.
real Racha_AjX= 0.
real Racha_AjY= 0.
real Racha_AjS= 1.
real Racha_AjN= 0.
real Racha_AjL= 0.
''')

# Las llamadas guardan sólo el texto de la racha; el nombre sale del jugador al anunciar.
for old, new in [
        ('Racha_NombreJ(p) + " |cffff3333FIRST BLOOD|r (Wave "', '"|cffff3333FIRST BLOOD|r (Wave "'),
        ('Racha_NombreJ(p) + " |cffffff00" + Racha_Nombre[t]', '"|cffffff00" + Racha_Nombre[t]'),
        ('Racha_NombreJ(p) + " |cff66ccff" + Racha_Nombre[10 + t]', '"|cff66ccff" + Racha_Nombre[10 + t]'),
        ('Racha_NombreJ(p) + " |cffff6666perdió su racha|r ("', '"|cffff6666perdió su racha|r ("')]:
    s = once(s, old, new)

s = once(s, '''// Fila nueva abajo; si ya hay 3, la más vieja sale por arriba.
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
''', '''function Racha_EsCairne takes integer p returns boolean
    return GetUnitTypeId(Game_Hero[p]) == 'h006'
endfunction

// v14zq: tarjeta nueva. La que se veía pasa a salir; la nueva espera arriba, fuera de la vista, hasta que la otra salga.
function Racha_Anunciar takes string texto,integer p returns nothing
    local integer k= 0
    local integer n= -1
    loop
        exitwhen k > 1
        if Racha_CActiva[k] then
            set Racha_CSale[k] = true
        elseif n < 0 then
            set n = k
        endif
        set k = k + 1
    endloop
    if n < 0 then
        // Las dos estaban activas: se reusa la que ya subió más.
        set n = 0
        if Racha_CY[1] < Racha_CY[0] then
            set n = 1
        endif
    endif
    set Racha_CActiva[n] = true
    set Racha_CSale[n] = false
    set Racha_CPid[n] = p
    set Racha_CTexto[n] = texto
    set Racha_CNombre[n] = Racha_NombreJ(p)
    set Racha_CAnchoN[n] = I2R(Racha_Largo(Racha_CNombre[n])) * 4.5 * 0.015 / 0.017
    set Racha_CAnchoL[n] = I2R(Racha_Largo(texto)) * 4.5 * 0.020 / 0.017
    set Racha_CY[n] = -80.
    set Racha_CFin[n] = 5.
    set Racha_CHabla[n] = 0.
    set Racha_CCairne[n] = Racha_EsCairne(p)
    set Racha_CVer[n] = Racha_CVer[n] + 1
    set Racha_Ver = Racha_Ver + 1
endfunction

// La voz del personaje de p; su tarjeta habla mientras dura.
function Racha_VozDe takes integer p returns nothing
    local integer i
    local integer k= 0
    if Racha_EsCairne(p) then
        set i = 10 + GetRandomInt(0, 4)
    else
        set i = GetRandomInt(0, 3)
    endif
    call Racha_Sonar(Racha_Voz[i])
    loop
        exitwhen k > 1
        if Racha_CActiva[k] and not Racha_CSale[k] and Racha_CPid[k] == p then
            set Racha_CHabla[k] = Racha_VozLen[i]
        endif
        set k = k + 1
    endloop
endfunction
''')

s = once(s, '        call Racha_Anunciar(Racha_ColaTexto[0])\n', '        call Racha_Anunciar(Racha_ColaTexto[0], Racha_ColaPid[0])\n')
s = once(s, '''    set i = 0
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
''', '''    set i = 0
    loop
        exitwhen i > 1
        if Racha_CActiva[i] and not Racha_CSale[i] then
            set Racha_CFin[i] = Racha_CFin[i] - 0.05
            if Racha_CFin[i] <= 0. then
                set Racha_CSale[i] = true
            endif
        endif
        if Racha_CHabla[i] > 0. then
            set Racha_CHabla[i] = Racha_CHabla[i] - 0.05
        endif
        set i = i + 1
    endloop
''')

s = once(s, '''// En cada repaso del HUD: filas del anuncio y marcador de p (oculto con su tienda abierta).
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
''', '''// Como Arm_Foto (que va más abajo en el script): imagen de HUD de wpx × hpx a distancia 400.
function Racha_Foto takes unit u,real wpx,real hpx,integer tex returns nothing
    local real w= wpx * ( 0.544 / 718.18930543 ) * 400.
    local real h= hpx * ( 0.302 / 387.73819261 ) * 400.
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

// Los textos de la tarjeta sólo existen en el cliente de p y mientras se ven (texttags locales, como UIText.createEx).
function Racha_TTCrear takes integer p,integer ui returns nothing
    if GetLocalPlayer() == Player(p) and s__UIText_text[ui] == null then
        set s__UIText_text[ui] = CreateTextTag()
        call SetTextTagPermanent(s__UIText_text[ui], true)
        call SetTextTagColor(s__UIText_text[ui], 255, 255, 255, 255)
        call SetTextTagVisibility(s__UIText_text[ui], false)
        call SetTextTagPosUnit(s__UIText_text[ui], s__UIText_dummy[ui], 0)
    endif
endfunction

function Racha_TTQuitar takes integer ui returns nothing
    if s__UIText_text[ui] != null then
        call DestroyTextTag(s__UIText_text[ui])
        set s__UIText_text[ui] = null
    endif
endfunction

// Una vez por repaso del HUD (100 por segundo), igual en todos los clientes: la que sale sube; la que entra baja cuando
// ya no se ve ninguna que sale.
function Racha_Mover takes nothing returns nothing
    local integer k= 0
    local boolean libre= true
    local real meta
    loop
        exitwhen k > 1
        if Racha_CActiva[k] and Racha_CSale[k] and Racha_CY[k] > -50. then
            set libre = false
        endif
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 1
        if Racha_CActiva[k] then
            if Racha_CSale[k] then
                set meta = -90.
            elseif libre then
                set meta = Racha_Y
            else
                set meta = -80.
            endif
            set Racha_CY[k] = Racha_CY[k] + ( meta - Racha_CY[k] ) * 0.2
            if Racha_CSale[k] and Racha_CY[k] < -72. then
                set Racha_CActiva[k] = false
            endif
        endif
        set k = k + 1
    endloop
endfunction

// En cada repaso del HUD: las tarjetas y el marcador de p (ocultos con su tienda abierta).
function Racha_Hud takes integer p,integer cam returns nothing
    local boolean shown= HealthBars__Visible and Game_On[p] and not Shop_Open[p]
    local boolean vis
    local integer k= 0
    local integer v
    local integer j
    local integer a
    local real y
    local real cx= 926.7
    local real e
    if not Racha_UIOk[p] then
        return
    endif
    loop
        exitwhen k > 1
        set v = p * 2 + k
        set vis = shown and Racha_CActiva[k] and Racha_CY[k] > -71.
        call ShowUnit(Racha_Caja[v], vis)
        if vis != Racha_VShow[v] then
            set Racha_VShow[v] = vis
            if vis then
                call Racha_TTCrear(p , Racha_TT[v * 2])
                call Racha_TTCrear(p , Racha_TT[v * 2 + 1])
                set Racha_VVer[v] = -1
            else
                call ShowUnit(Racha_Cara[v * 2], false)
                call ShowUnit(Racha_Cara[v * 2 + 1], false)
                call s__UIText_show(Racha_TT[v * 2],false , cam)
                call s__UIText_show(Racha_TT[v * 2 + 1],false , cam)
                call Racha_TTQuitar(Racha_TT[v * 2])
                call Racha_TTQuitar(Racha_TT[v * 2 + 1])
            endif
        endif
        if vis then
            set j = 0
            if Racha_CCairne[k] then
                set j = 1
            endif
            set y = Racha_CY[k]
            if Racha_VVer[v] != Racha_CVer[k] then
                set Racha_VVer[v] = Racha_CVer[k]
                // Mostrar antes de elegir la animación: el cambio de visibilidad puede reiniciarla.
                call ShowUnit(Racha_Cara[v * 2 + 1 - j], false)
                call ShowUnit(Racha_Cara[v * 2 + j], true)
                // 48 px de alto a 398; el retrato mide 21,4 de alto a escala 1 (Hero_PortraitScale).
                set e = 48. * ( 0.302 / 387.73819261 ) * 398. / 21.4 * Racha_AjS
                call SetUnitScale(Racha_Cara[v * 2 + j], e, e, e)
                set Racha_VHabla[v] = -1
                call SetTextTagText(s__UIText_text[Racha_TT[v * 2]], Racha_CNombre[k], 0.015)
                call SetTextTagText(s__UIText_text[Racha_TT[v * 2 + 1]], Racha_CTexto[k], 0.020)
            endif
            set a = 0
            if Racha_CHabla[k] > 0. then
                set a = 1
            endif
            if a != Racha_VHabla[v] then
                set Racha_VHabla[v] = a
                if j == 1 then
                    call SetUnitAnimationByIndex(Racha_Cara[v * 2 + 1], a)
                elseif a == 1 then
                    call SetUnitAnimationByIndex(Racha_Cara[v * 2], DIALOGUE_RIGHT_TALK)
                else
                    call SetUnitAnimationByIndex(Racha_Cara[v * 2], DIALOGUE_RIGHT_IDLE)
                endif
            endif
            call HealthBars__Place(Racha_Caja[v] , cam , 960. , y , 400.)
            call HealthBars__Place(Racha_Cara[v * 2 + j] , cam , 1168.1 + Racha_AjX , y + Racha_AjY , 398.)
            call s__UIText_setPosition(Racha_TT[v * 2],( cx - Racha_CAnchoN[k] - 960. ) / 728. , ( 420. - ( y - 24. + Racha_AjN ) ) / 390.)
            call s__UIText_setPosition(Racha_TT[v * 2 + 1],( cx - Racha_CAnchoL[k] - 960. ) / 728. , ( 420. - ( y + 1. + Racha_AjL ) ) / 390.)
            call s__UIText_show(Racha_TT[v * 2],true , cam)
            call s__UIText_show(Racha_TT[v * 2 + 1],true , cam)
        endif
        set k = k + 1
    endloop
''')

s = once(s, '''        set Racha_Voz[14] = "Units\\\\Orc\\\\Cairne\\\\CairneWarcry1.wav"
''', '''        set Racha_Voz[14] = "Units\\\\Orc\\\\Cairne\\\\CairneWarcry1.wav"
        set Racha_VozLen[0] = 2.109
        set Racha_VozLen[1] = 1.222
        set Racha_VozLen[2] = 1.352
        set Racha_VozLen[3] = 2.541
        set Racha_VozLen[10] = 1.609
        set Racha_VozLen[11] = 1.343
        set Racha_VozLen[12] = 1.343
        set Racha_VozLen[13] = 1.609
        set Racha_VozLen[14] = 1.308
''')

s = once(s, '''    if not Racha_UIOk[p] then
        loop
            exitwhen i > 2
            set Racha_UI[p * 3 + i] = s__UIText_createEx(Player(p) , 0. , 0. , 1.)
            call SetTextTagPermanent(s__UIText_text[Racha_UI[p * 3 + i]], true)
            call SetTextTagColor(s__UIText_text[Racha_UI[p * 3 + i]], 255, 255, 255, 255)
            set i = i + 1
        endloop
''', '''    if not Racha_UIOk[p] then
        // Por tarjeta: cuadro, retrato Tauren y Cairne, y dos textos sin texttag hasta que se vea.
        loop
            exitwhen i > 1
            set Racha_Caja[p * 2 + i] = HealthBars__Dummy('uidb', p)
            call UnitAddAbility(Racha_Caja[p * 2 + i], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Caja[p * 2 + i], s__Interface_LOCUST_ID)
            call Racha_Foto(Racha_Caja[p * 2 + i] , 480. , 60. , 'DS18')
            set Racha_Cara[( p * 2 + i ) * 2] = HealthBars__Dummy('dta0', p)
            set Racha_Cara[( p * 2 + i ) * 2 + 1] = HealthBars__Dummy('dca0', p)
            call UnitAddAbility(Racha_Cara[( p * 2 + i ) * 2], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Cara[( p * 2 + i ) * 2], s__Interface_LOCUST_ID)
            call UnitAddAbility(Racha_Cara[( p * 2 + i ) * 2 + 1], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Cara[( p * 2 + i ) * 2 + 1], s__Interface_LOCUST_ID)
            set Racha_TT[( p * 2 + i ) * 2] = s__UIText_createEx(Player(p) , 0. , 0. , 1.)
            set Racha_TT[( p * 2 + i ) * 2 + 1] = s__UIText_createEx(Player(p) , 0. , 0. , 1.)
            call Racha_TTQuitar(Racha_TT[( p * 2 + i ) * 2])
            call Racha_TTQuitar(Racha_TT[( p * 2 + i ) * 2 + 1])
            // Visible al crear: el primer repaso la oculta (y esconde los retratos).
            set Racha_VShow[p * 2 + i] = true
            set Racha_VVer[p * 2 + i] = -1
            set Racha_VHabla[p * 2 + i] = -1
            set i = i + 1
        endloop
''')

s = once(s, '''    if poll then
        set HealthBars__PollTime=0
    endif
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
''', '''    if poll then
        set HealthBars__PollTime=0
    endif
    call Racha_Mover()
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
''')
assert s.count("'DS18'") == 1 and s.count('call Racha_Mover()') == 1
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
