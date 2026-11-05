#!/usr/bin/env python3
"""v14a: v13m con armas, munición, oro, tienda del golem y diez rondas acumulativas.

Armas: siete categorías y tres tiers (armas_v14a.py). Cada jugador guarda tier, cargador y reserva por categoría.
Disparo rápido apagado: una bala por A sin movimiento artificial. Encendido: seis balas al intervalo del arma.
El cuchillo golpea un cono de 120 grados, visible en origin mientras está activo.
Tienda: seleccionar el golem en descanso a 600 o menos lleva a la cámara cenital de Title (0, 4096), donde quedan
paneles y trackables por jugador. Lo visible por jugador cambia sólo en bloques locales; el estado, en los eventos
sincronizados de los trackables. Esc sale. El descanso se detiene hasta 60 s mientras alguien compra.

Uso: v14a.py IN_J OUT_J
"""
from pathlib import Path
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base
from armas_v14a import ARMAS, CATS, FRASES, TIPOS, RANGO, RONDAS, TEX


def u8(t):
    return t.encode('utf-8').decode('latin-1')


def crlf(t):
    return u8(t).replace('\r\n', '\n').replace('\n', '\r\n')


GLOBALS = r'''// v14a: armas [categoría*3+tier-1], estado [jugador*7+categoría]
string array Arm_Nombre
string array Arm_Rasgo
string array Arm_Coment
string array Cat_Nombre
integer array Cat_Tex
integer array Arm_Anio
integer array Arm_Mag
integer array Arm_Res
integer array Arm_Perd
integer array Arm_Precio
integer array Arm_Perfora
real array Arm_Int
real array Arm_Dano
real array Arm_Disp
real array Arm_Rec
real array Arm_Crit
real array Arm_Area
real array Arm_Alc
integer array Arm_Tier
integer array Arm_Clip
integer array Arm_Rva
real array Arm_Listo
integer array Arm_Cat
boolean array Arm_Rapido
real array Arm_Fin
effect array Arm_Cono
real Arm_Alcance= 1350.
group Arm_Enum= CreateGroup()
timer Arm_Reloj= CreateTimer()
unit array Arm_Icono
unit array Arm_Blindaje
integer array Arm_NombreUI
integer array Arm_BalasUI
integer array Arm_Clave
integer array Arm_IconoCat
real array Bala_Dano
real array Bala_Crit
real array Bala_Area
integer array Bala_Perfora
group array Bala_Grupo
group s__GroundCollision_skip= null
// v14a: tienda
boolean array Shop_Open
integer Shop_Abiertos= 0
integer Shop_Pausa= 0
unit Shop_Golem= null
integer array Shop_Cat
integer array Shop_Ver
trigger Shop_Hit= null
hashtable Shop_HT= InitHashtable()
unit array Shop_CatOn
unit array Shop_RowOn
unit array Shop_ArmaPic
unit array Shop_Pz
integer Shop_PzN= 0
texttag array Shop_Tz
integer Shop_TzN= 0
effect array Shop_Fondo
unit Shop_BuyOn= null
unit Shop_RecOn= null
texttag array Shop_T
texttag array Shop_CatT
string array Shop_L
string array Shop_Frase
'''

DATOS = ['function Arm_Datos takes nothing returns nothing']
for c, n in enumerate(CATS):
    rid = TEX[['Arma-pistola', 'Arma-subfusil', 'Arma-rifle', 'Arma-francotirador', 'Arma-escopeta', 'Arma-melee', 'Arma-granada'][c]]
    DATOS += [f'    set Cat_Nombre[{c}] = "{n}"', f"    set Cat_Tex[{c}] = '{rid}'"]
for w, a in enumerate(ARMAS):
    nombre, anio, mag, res, rpm, dano, perd, disp, precio, rec, perf, crit, area, alc, rasgo, coment = a
    DATOS += [f'    set Arm_Nombre[{w}] = "{nombre}"', f'    set Arm_Rasgo[{w}] = "{rasgo}"', f'    set Arm_Coment[{w}] = "{coment}"',
              f'    set Arm_Anio[{w}] = {anio}', f'    set Arm_Mag[{w}] = {mag}', f'    set Arm_Res[{w}] = {res}', f'    set Arm_Perd[{w}] = {perd}',
              f'    set Arm_Precio[{w}] = {precio}', f'    set Arm_Perfora[{w}] = {perf}', f'    set Arm_Int[{w}] = {60 / rpm:.4f}',
              f'    set Arm_Dano[{w}] = {dano}.', f'    set Arm_Disp[{w}] = {disp}.', f'    set Arm_Rec[{w}] = {rec}', f'    set Arm_Crit[{w}] = {crit}',
              f'    set Arm_Area[{w}] = {area}.', f'    set Arm_Alc[{w}] = {alc}.']
for i, f in enumerate(FRASES):
    DATOS.append(f'    set Shop_Frase[{i}] = "{f}"')
DATOS += ['endfunction', '']

A = '\n'.join(DATOS) + r'''
function Arm_W takes integer p returns integer
    return Arm_Cat[p] * 3 + Arm_Tier[p * 7 + Arm_Cat[p]] - 1
endfunction

function Arm_Familia takes integer tier returns integer
    if tier == 2 then
        return 3
    elseif tier == 3 then
        return 0
    endif
    return 1
endfunction

function Arm_Error takes integer p returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(UI_ErrorSnd, false, false)
        call StartSound(UI_ErrorSnd)
    endif
endfunction

function Oro_Dar takes integer p, integer n returns nothing
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) + n)
endfunction

// Sólo el dibujo de cámara cenital de la tienda, a 100 Hz; los números son los de Title_Camera.
function Shop_Camara takes integer p returns nothing
    if GetLocalPlayer() == Player(p) then
        call SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, 1650., 0)
        call SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 270., 0)
        call SetCameraField(CAMERA_FIELD_ROTATION, 180., 0)
        call SetCameraField(CAMERA_FIELD_ROLL, 0., 0)
        call SetCameraField(CAMERA_FIELD_FIELD_OF_VIEW, 70., 0)
        call SetCameraField(CAMERA_FIELD_ZOFFSET, 0., 0)
        call SetCameraField(CAMERA_FIELD_FARZ, 5000., 0)
        call SetCameraPosition(0., 4096.)
    endif
endfunction

'''

HUD = r'''// Imagen de HUD centrada en (px, py) a distancia 400, con el reparto de aspecto de Title_Pic.
function Arm_Foto takes unit u, real wpx, real hpx, integer tex returns nothing
    local real w = wpx * (0.544 / 718.18930543) * 400.
    local real h = hpx * (0.302 / 387.73819261) * 400.
    local real a
    local integer anim = 0
    if h < w then
        set anim = IMinBJ(100, R2I(10 * (w / h - 1) + 0.5))
    else
        set a = 10 * (h / w - 1)
        if a >= 0.5 then
            set anim = 100 + IMinBJ(100, R2I(a + 0.5))
        endif
    endif
    call SetUnitScale(u, 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h), 0.5 * RMinBJ(w, h))
    call UserInterface_ApplySkin(u, tex)
    call SetUnitAnimationByIndex(u, anim)
endfunction

function Arm_Texto takes integer ui, string s, real size, real y returns nothing
    call s__UIText_setPosition(ui, (150. - 960.) / 728., (420. - y) / 390.)
    call SetTextTagText(s__UIText_text[ui], s, size)
endfunction

function Arm_Hud takes integer p, integer cam returns nothing
    local boolean shown = HealthBars__Visible and GetUnitTypeId(HealthBars__Heroes[p]) != 0
    local integer c = Arm_Cat[p]
    local integer i = p * 7 + c
    local integer w
    local integer clave
    local string s
    if Arm_Icono[p] == null then
        return
    endif
    call ShowUnit(Arm_Icono[p], shown)
    call ShowUnit(Arm_Blindaje[p], shown)
    call s__UIText_show(Arm_NombreUI[p], shown, cam)
    call s__UIText_show(Arm_BalasUI[p], shown, cam)
    if shown then
        call HealthBars__Place(Arm_Icono[p], cam, 90., 215., 400.)
        call HealthBars__Place(Arm_Blindaje[p], cam, 230., 124., 400.)
        set clave = (c * 4 + Arm_Tier[i]) * 1000000 + Arm_Clip[i] * 1000 + Arm_Rva[i]
        if Arm_Fin[p] > 0 then
            set clave = - clave
        endif
        if clave != Arm_Clave[p] then
            set Arm_Clave[p] = clave
            set w = Arm_W(p)
            if Arm_IconoCat[p] != c + 1 then
                set Arm_IconoCat[p] = c + 1
                call Arm_Foto(Arm_Icono[p], 108., 54., Cat_Tex[c])
            endif
            call Arm_Texto(Arm_NombreUI[p], Arm_Nombre[w] + " T" + I2S(Arm_Tier[i]), 0.017, 192.)
            if c == 5 then
                set s = "-"
            elseif Arm_Fin[p] > 0 then
                set s = "Recargando"
            else
                set s = I2S(Arm_Clip[i]) + "/" + I2S(Arm_Rva[i])
            endif
            call Arm_Texto(Arm_BalasUI[p], s, 0.024, 222.)
        endif
    endif
endfunction

'''

B = r'''    function Arm_Impacto takes integer m,unit caster,unit target returns nothing
        local real d= Bala_Dano[m]
        if Bala_Crit[m] > 0. and GetRandomReal(0., 1.) < Bala_Crit[m] then
            set d=d * 2.
        endif
        call UnitDamageTarget(caster, target, d, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
    endfunction

    function Arm_Explotar takes integer m,unit caster,real x,real y returns nothing
        local real area= Bala_Area[m]
        local player owner= s__RapidBolt_owner[m]
        local unit u
        set Bala_Area[m]=0.
        call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", x, y))
        if GetUnitTypeId(caster) != 0 then
            set s__GroundCollision_shaped=true
            call GroupEnumUnitsInRange(Arm_Enum, x, y, area + 128., null)
            loop
                set u=FirstOfGroup(Arm_Enum)
                exitwhen u == null
                call GroupRemoveUnit(Arm_Enum, u)
                if s__GroundCollision_isTarget(u , caster , owner) and s__GroundCollision_touches(u , x , y , area) then
                    call UnitDamageTarget(caster, u, Bala_Dano[m], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                endif
            endloop
            set s__GroundCollision_shaped=false
        endif
        set owner=null
    endfunction

'''

C = r'''    function Arm_Puede takes integer this returns boolean
        local integer p= GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))
        return Arm_Cat[p] == 5 or Arm_Clip[p * 7 + Arm_Cat[p]] > 0
    endfunction

    // Sin balas no se espera el intervalo entero: el error llega enseguida.
    function Arm_Intervalo takes integer this returns real
        local integer p= GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))
        if not Arm_Puede(this) then
            return 0.25
        endif
        return Arm_Int[Arm_W(p)]
    endfunction

    function Arm_Tiro takes integer this,integer w,real angle,real range returns nothing
        local unit a= s__RapidPair_actor[this]
        local integer m
        set Arm_Alcance=range
        set m=s__RapidBolt_shootFamily(a , GetUnitX(a) + 1000. * Cos(angle) , GetUnitY(a) + 1000. * Sin(angle) , s__RapidPair_color(this) , s__RapidPair_family[this])
        set Arm_Alcance=s__RapidBolt_RANGE
        set s__RapidPair_lastMissile[this]=m
        set Bala_Dano[m]=Arm_Dano[w]
        set Bala_Crit[m]=Arm_Crit[w]
        set Bala_Area[m]=Arm_Area[w]
        set Bala_Perfora[m]=Arm_Perfora[w]
        if Arm_Perfora[w] > 0 then
            set Bala_Grupo[m]=CreateGroup()
        endif
        set a=null
    endfunction

    function Arm_Golpe takes integer this,integer w returns nothing
        local unit a= s__RapidPair_actor[this]
        local player owner= GetOwningPlayer(a)
        local real x= GetUnitX(a)
        local real y= GetUnitY(a)
        local real angle= Atan2(s__RapidPair_aimY[this] - y, s__RapidPair_aimX[this] - x)
        local real d
        local unit u
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Arm_Enum, x, y, Arm_Area[w] + 128., null)
        loop
            set u=FirstOfGroup(Arm_Enum)
            exitwhen u == null
            call GroupRemoveUnit(Arm_Enum, u)
            if s__GroundCollision_isTarget(u , a , owner) and s__GroundCollision_touches(u , x , y , Arm_Area[w]) then
                set d=Atan2(GetUnitY(u) - y, GetUnitX(u) - x) - angle
                if Cos(d) >= 0.5 then
                    call UnitDamageTarget(a, u, Arm_Dano[w], false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                endif
            endif
        endloop
        set s__GroundCollision_shaped=false
        set a=null
        set owner=null
    endfunction

    function Arm_Emitir takes integer this returns nothing
        local integer p= GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))
        local integer c= Arm_Cat[p]
        local integer w= Arm_W(p)
        local integer n= 0
        local real x= GetUnitX(s__RapidPair_actor[this])
        local real y= GetUnitY(s__RapidPair_actor[this])
        local real angle
        local real range= Arm_Alc[w]
        set Arm_Listo[p * 7 + c]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Int[w]
        if c == 5 then
            call Arm_Golpe(this , w)
            return
        endif
        set Arm_Clip[p * 7 + c]=Arm_Clip[p * 7 + c] - 1
        set angle=Atan2(s__RapidPair_aimY[this] - y, s__RapidPair_aimX[this] - x)
        if c == 6 then
            set x=s__RapidPair_pickX[this] - x
            set y=s__RapidPair_pickY[this] - y
            set range=RMaxBJ(150., RMinBJ(range, SquareRoot(x * x + y * y)))
        endif
        loop
            exitwhen n >= Arm_Perd[w]
            call Arm_Tiro(this , w , angle + GetRandomReal(- Arm_Disp[w], Arm_Disp[w]) * bj_DEGTORAD , range)
            set n=n + 1
        endloop
    endfunction

'''

D = r'''    function Arm_Conos takes integer p returns nothing
        if Arm_Cono[p] != null then
            call DestroyEffect(Arm_Cono[p])
            set Arm_Cono[p]=null
        endif
        if Arm_Cat[p] == 5 and GetUnitTypeId(Game_Hero[p]) != 0 then
            set Arm_Cono[p]=AddSpecialEffectTarget("war3mapImported\\ConoCuchillo.mdx", Game_Hero[p], "origin")
        endif
    endfunction

    // Botones de un cuerpo nuevo; antes de Silence_HideMove, como Arp1 y Ard1.
    function Arm_Botones takes integer p returns nothing
        local unit u= Game_Ctrl[p]
        local integer c= 0
        if Arm_Tier[p * 7] == 0 then
            set Arm_Tier[p * 7]=1
            set Arm_Clip[p * 7]=Arm_Mag[0]
            set Arm_Rva[p * 7]=Arm_Res[0]
            set Arm_Tier[p * 7 + 5]=1
        endif
        if Arm_Rapido[p] then
            call UnitAddAbility(u, 'Aw09')
        else
            call UnitAddAbility(u, 'Aw07')
        endif
        call UnitAddAbility(u, 'Aw08')
        loop
            exitwhen c > 6
            if Arm_Tier[p * 7 + c] > 0 then
                call UnitAddAbility(u, 'Aw00' + c)
                call SetUnitAbilityLevel(u, 'Aw00' + c, Arm_Tier[p * 7 + c])
            endif
            set c=c + 1
        endloop
        set u=null
    endfunction

    function Arm_Pareja takes integer p returns nothing
        set s__RapidPair_family[Game_Pair[p]]=Arm_Familia(Arm_Tier[p * 7 + Arm_Cat[p]])
        set Arm_Fin[p]=0.
        call Arm_Conos(p)
    endfunction

    function Arm_Elegir takes integer p,integer c returns nothing
        local integer this= Game_Pair[p]
        if c == Arm_Cat[p] or Arm_Tier[p * 7 + c] == 0 then
            return
        endif
        set Arm_Fin[p]=0.
        set Arm_Cat[p]=c
        call Arm_Conos(p)
        if this != 0 then
            set s__RapidPair_family[this]=Arm_Familia(Arm_Tier[p * 7 + c])
            if s__RapidPair_firing[this] then
                call s__RapidPair_showWalk(this)
                set s__RapidPair_nextShot[this]=RMaxBJ((TimerGetElapsed(s__RapidPair_clock)), Arm_Listo[p * 7 + c])
            endif
        endif
    endfunction

    function Arm_BotonArma takes nothing returns nothing
        call Arm_Elegir(GetPlayerId(GetOwningPlayer(GetTriggerUnit())) , GetSpellAbilityId() - 'Aw00')
    endfunction

    function Arm_BotonRapido takes nothing returns nothing
        local unit u= GetTriggerUnit()
        local integer p= GetPlayerId(GetOwningPlayer(u))
        set Arm_Rapido[p]=not Arm_Rapido[p]
        if Arm_Rapido[p] then
            call UnitRemoveAbility(u, 'Aw07')
            call UnitAddAbility(u, 'Aw09')
        else
            call UnitRemoveAbility(u, 'Aw09')
            call UnitAddAbility(u, 'Aw07')
            if Game_Pair[p] != 0 then
                call s__RapidPair_finish(Game_Pair[p],true)
            endif
        endif
        set u=null
    endfunction

    function Arm_BotonRecarga takes nothing returns nothing
        local integer p= GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        local integer i= p * 7 + Arm_Cat[p]
        local integer w= Arm_W(p)
        if Arm_Cat[p] == 5 or Arm_Rva[i] <= 0 then
            call Arm_Error(p)
        elseif Arm_Fin[p] <= 0. and Arm_Clip[i] < Arm_Mag[w] then
            if Game_Pair[p] != 0 then
                call s__RapidPair_finish(Game_Pair[p],true)
            endif
            set Arm_Fin[p]=(TimerGetElapsed(s__RapidPair_clock)) + Arm_Rec[w]
        endif
    endfunction

    function Arm_Latido takes nothing returns nothing
        local integer p= 0
        local integer i
        local integer n
        local real time= (TimerGetElapsed(s__RapidPair_clock))
        loop
            exitwhen p > 11
            if Arm_Fin[p] > 0. and time >= Arm_Fin[p] then
                set Arm_Fin[p]=0.
                set i=p * 7 + Arm_Cat[p]
                set n=IMinBJ(Arm_Mag[Arm_W(p)] - Arm_Clip[i], Arm_Rva[i])
                set Arm_Clip[i]=Arm_Clip[i] + n
                set Arm_Rva[i]=Arm_Rva[i] - n
            endif
            set p=p + 1
        endloop
    endfunction

'''

SHOP = r'''function Shop_Tag takes real px, real py, real size, real w, string s returns texttag
    local texttag t = CreateTextTag()
    call SetTextTagPermanent(t, true)
    call SetTextTagVisibility(t, false)
    call SetTextTagText(t, s, size)
    call SetTextTagColor(t, 235, 240, 245, 255)
    call Tx_At(t, px, py, size, w)
    set Shop_Tz[Shop_TzN] = t
    set Shop_TzN = Shop_TzN + 1
    set bj_lastCreatedTextTag = t
    set t = null
    return bj_lastCreatedTextTag
endfunction

// La zona está sobre terreno jugable: nada de la tienda se ve salvo en el cliente de quien la tiene abierta.
function Shop_Pic takes real px, real py, real w, real h, real depth, integer tex returns unit
    local unit u = Title_Pic('uidb', px, py, w, h, depth, tex)
    call SetUnitVertexColor(u, 255, 255, 255, 0)
    set Shop_Pz[Shop_PzN] = u
    set Shop_PzN = Shop_PzN + 1
    set bj_lastCreatedUnit = u
    set u = null
    return bj_lastCreatedUnit
endfunction

function Shop_Mostrar takes integer p, boolean on returns nothing
    local string path = ""
    local integer i = 0
    local integer a = 0
    if on then
        set a = 255
    endif
    if GetLocalPlayer() == Player(p) then
        if on then
            set path = "war3mapImported\\ShopPlano.mdx"
        endif
        loop
            exitwhen i >= Shop_PzN
            call SetUnitVertexColor(Shop_Pz[i], 255, 255, 255, a)
            set i = i + 1
        endloop
        set i = 0
        loop
            exitwhen i >= Shop_TzN
            call SetTextTagVisibility(Shop_Tz[i], on)
            set i = i + 1
        endloop
    endif
    if on then
        set Shop_Fondo[p] = AddSpecialEffect(path, Title_X(), Title_Y())
    else
        call DestroyEffect(Shop_Fondo[p])
        set Shop_Fondo[p] = null
    endif
endfunction

// Texto, sus colores y posición son sólo visuales: el cliente del jugador los escribe en un texttag común.
function Shop_Izq takes integer p, texttag t, string s, real px, real py, real size returns nothing
    if GetLocalPlayer() == Player(p) then
        call SetTextTagText(t, s, size)
        call Tx_At(t, px, py, size, 0)
    endif
endfunction

function Shop_Centro takes integer p, texttag t, string s, real px, real py, real size returns nothing
    local real w = StringLength(s) * size * 470.
    if GetLocalPlayer() == Player(p) then
        call SetTextTagText(t, s, size)
        call Tx_At(t, px, py, size, w)
    endif
endfunction

function Shop_Der takes integer p, texttag t, string s, real px, real py, real size returns nothing
    local real w = StringLength(s) * size * 470.
    if GetLocalPlayer() == Player(p) then
        call SetTextTagText(t, s, size)
        call Tx_At(t, px - w / 2, py, size, 0)
    endif
endfunction

function Shop_Pinta takes integer p, texttag t, integer g returns nothing
    if GetLocalPlayer() == Player(p) then
        call SetTextTagColor(t, g, g, IMinBJ(255, g + 8), 255)
    endif
endfunction

function Shop_Luz takes integer p, unit u, boolean on returns nothing
    if GetLocalPlayer() == Player(p) then
        if on then
            call SetUnitVertexColor(u, 255, 255, 255, 255)
        else
            call SetUnitVertexColor(u, 255, 255, 255, 0)
        endif
    endif
endfunction

function Shop_Partir takes string s returns nothing
    local integer n = 0
    local integer i = 0
    local integer len = StringLength(s)
    local integer c
    loop
        exitwhen n > 2
        if len - i <= 34 then
            set Shop_L[n] = SubString(s, i, len)
            set i = len
        else
            set c = i + 34
            loop
                exitwhen c <= i or SubString(s, c, c + 1) == " "
                set c = c - 1
            endloop
            if c <= i then
                set c = i + 34
            endif
            set Shop_L[n] = SubString(s, i, c)
            set i = c + 1
        endif
        set n = n + 1
    endloop
endfunction

function Shop_Hablar takes integer p, string quien, string s returns nothing
    local integer k = 0
    call Shop_Partir(s)
    call Shop_Izq(p, Shop_T[15], quien, 1418, 92, 0.026)
    loop
        exitwhen k > 2
        call Shop_Izq(p, Shop_T[16 + k], Shop_L[k], 1424, 440 + k * 34, 0.021)
        set k = k + 1
    endloop
endfunction

function Shop_CostoBala takes integer w returns integer
    return IMaxBJ(1, (Arm_Precio[w] + 100) / (Arm_Res[w] * 2))
endfunction

function Shop_Refrescar takes integer p returns nothing
    local integer c = Shop_Cat[p]
    local integer t = Shop_Ver[p]
    local integer i = p * 7 + c
    local integer have = Arm_Tier[i]
    local integer w = c * 3 + t - 1
    local integer k = 0
    local integer x
    local integer g
    local integer falta
    local string s
    call Shop_Centro(p, Shop_T[0], Cat_Nombre[c], 760, 92, 0.026)
    loop
        exitwhen k > 6
        call Shop_Luz(p, Shop_CatOn[k], k == c)
        call Shop_Luz(p, Shop_ArmaPic[k], k == c)
        if k == c then
            call Shop_Pinta(p, Shop_CatT[k], 255)
        else
            call Shop_Pinta(p, Shop_CatT[k], 170)
        endif
        set k = k + 1
    endloop
    if GetLocalPlayer() == Player(p) then
        if t < have then
            call SetUnitVertexColor(Shop_ArmaPic[c], 95, 95, 105, 255)
        endif
    endif
    set k = 0
    loop
        exitwhen k > 2
        set x = c * 3 + k
        call Shop_Luz(p, Shop_RowOn[k], k + 1 == t)
        if Arm_Anio[x] < 0 then
            set s = ""
        else
            set s = "  (" + I2S(Arm_Anio[x]) + ")"
        endif
        call Shop_Izq(p, Shop_T[1 + k], "T" + I2S(k + 1) + "  " + Arm_Nombre[x] + s, 644, 141 + k * 58, 0.022)
        if k + 1 < have then
            set s = "Obsoleta"
            set g = 95
        elseif k + 1 == have then
            set s = "En uso"
            set g = 255
        elseif k == have then
            set s = I2S(Arm_Precio[x]) + " oro"
            set g = 225
        else
            set s = "Bloqueada"
            set g = 130
        endif
        call Shop_Der(p, Shop_T[4 + k], s, 1290, 141 + k * 58, 0.022)
        call Shop_Pinta(p, Shop_T[1 + k], g)
        call Shop_Pinta(p, Shop_T[4 + k], g)
        set k = k + 1
    endloop
    if Arm_Perd[w] > 1 then
        set s = I2S(Arm_Perd[w]) + " x " + I2S(R2I(Arm_Dano[w]))
    else
        set s = I2S(R2I(Arm_Dano[w]))
    endif
    call Shop_Izq(p, Shop_T[7], s, 950, 548, 0.026)
    if c == 5 then
        set s = "Sin balas"
    else
        set s = I2S(Arm_Mag[w]) + " / " + I2S(Arm_Res[w])
    endif
    call Shop_Izq(p, Shop_T[8], s, 1140, 548, 0.026)
    call Shop_Izq(p, Shop_T[9], I2S(R2I(60. / Arm_Int[w] + 0.5)) + " rpm  " + R2SW(1. / Arm_Int[w], 1, 1) + "/s", 950, 632, 0.024)
    if c == 5 then
        set s = "Cono 120"
    else
        set s = I2S(100 - R2I(Arm_Disp[w] * 6.)) + "%"
    endif
    call Shop_Izq(p, Shop_T[10], s, 1140, 632, 0.026)
    call Shop_Izq(p, Shop_T[11], Arm_Rasgo[w], 950, 684, 0.020)
    if t < have then
        set s = "Obsoleta"
    elseif t == have then
        set s = "Ya la tienes"
    elseif t == have + 1 then
        set s = "Comprar: " + I2S(Arm_Precio[w]) + " oro"
    else
        set s = "Necesitas T" + I2S(t - 1)
    endif
    call Shop_Luz(p, Shop_BuyOn, t == have + 1)
    call Shop_Centro(p, Shop_T[12], s, 948, 758, 0.024)
    set s = "Munición completa"
    call Shop_Luz(p, Shop_RecOn, false)
    if c == 5 then
        set s = "No usa munición"
    elseif have == 0 then
        set s = "Compra el arma primero"
    else
        set x = c * 3 + have - 1
        set falta = Arm_Res[x] - Arm_Rva[i]
        if falta > 0 then
            set s = I2S(falta) + " balas: " + I2S(falta * Shop_CostoBala(x)) + " oro"
            call Shop_Luz(p, Shop_RecOn, true)
        endif
    endif
    call Shop_Centro(p, Shop_T[13], s, 1601, 758, 0.021)
    call Shop_Izq(p, Shop_T[14], I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)), 1490, 672, 0.026)
    call Shop_Hablar(p, "Golem de roca", Arm_Coment[w])
endfunction

function Shop_Cerrar takes integer p returns nothing
    if not Shop_Open[p] then
        return
    endif
    set Shop_Open[p] = false
    set Shop_Abiertos = Shop_Abiertos - 1
    call Shop_Mostrar(p, false)
    if GetLocalPlayer() == Player(p) then
        call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
        call ResetToGameCamera(0)
        call ClearSelection()
        call SelectUnit(Game_Ctrl[p], true)
    endif
endfunction

function Shop_CerrarTodos takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        call Shop_Cerrar(p)
        set p = p + 1
    endloop
endfunction

function Shop_Rechazar takes integer p returns nothing
    call UI_Error(p)
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
        call SelectUnit(Game_Ctrl[p], true)
    endif
endfunction

function Shop_Abrir takes integer p returns nothing
    if Shop_Open[p] or not Game_On[p] then
        return
    endif
    if not Ronda_Activa or not Ronda_Descanso or Ronda_Numero >= Ronda_TOTAL or not UnitAlive(Game_Hero[p]) or not IsUnitInRange(Game_Hero[p], Shop_Golem, 600.) then
        call Shop_Rechazar(p)
        return
    endif
    if Game_Pair[p] != 0 then
        call s__RapidPair_finish(Game_Pair[p], false)
    endif
    call IssueImmediateOrder(Game_Hero[p], "stop")
    set Arm_Fin[p] = 0.
    set Shop_Open[p] = true
    set Shop_Abiertos = Shop_Abiertos + 1
    set Shop_Cat[p] = Arm_Cat[p]
    set Shop_Ver[p] = IMaxBJ(1, Arm_Tier[p * 7 + Arm_Cat[p]])
    if GetLocalPlayer() == Player(p) then
        call ResetToGameCamera(0)
        call SetCameraBounds(-1, 4095, -1, 4097, 1, 4097, 1, 4095)
    endif
    call Shop_Camara(p)
    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
endfunction

function Shop_Seleccion takes nothing returns nothing
    local integer p = GetPlayerId(GetTriggerPlayer())
    if GetTriggerUnit() == Shop_Golem then
        call Shop_Abrir(p)
    elseif Shop_Open[p] and GetLocalPlayer() == Player(p) then
        call ClearSelection()
        call SelectUnit(Shop_Golem, true)
    endif
endfunction

function Shop_Esc takes nothing returns nothing
    call Shop_Cerrar(GetPlayerId(GetTriggerPlayer()))
endfunction

function Shop_Comprar takes integer p returns nothing
    local integer c = Shop_Cat[p]
    local integer t = Shop_Ver[p]
    local integer i = p * 7 + c
    local integer w = c * 3 + t - 1
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    if t != Arm_Tier[i] + 1 or oro < Arm_Precio[w] then
        call UI_Error(p)
        return
    endif
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - Arm_Precio[w])
    if t == 1 then
        call UnitAddAbility(Game_Ctrl[p], 'Aw00' + c)
    endif
    call SetUnitAbilityLevel(Game_Ctrl[p], 'Aw00' + c, t)
    set Arm_Tier[i] = t
    set Arm_Clip[i] = Arm_Mag[w]
    set Arm_Rva[i] = Arm_Res[w]
    call UI_Click(p)
    call Shop_Refrescar(p)
    call Shop_Hablar(p, "Tauren", Shop_Frase[GetRandomInt(0, 5)])
endfunction

function Shop_Balas takes integer p returns nothing
    local integer i = p * 7 + Shop_Cat[p]
    local integer x
    local integer costo
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local integer n
    if Shop_Cat[p] == 5 or Arm_Tier[i] == 0 then
        call UI_Error(p)
        return
    endif
    set x = Shop_Cat[p] * 3 + Arm_Tier[i] - 1
    set costo = Shop_CostoBala(x)
    set n = IMinBJ(Arm_Res[x] - Arm_Rva[i], oro / costo)
    if n <= 0 then
        call UI_Error(p)
        return
    endif
    set Arm_Rva[i] = Arm_Rva[i] + n
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - n * costo)
    call UI_Click(p)
    call Shop_Refrescar(p)
endfunction

function Shop_Clic takes nothing returns nothing
    local integer h = GetHandleId(GetTriggeringTrackable())
    local integer p = LoadInteger(Shop_HT, h, 0)
    local integer k = LoadInteger(Shop_HT, h, 1)
    if not Shop_Open[p] then
        return
    endif
    if k <= 6 then
        call UI_Click(p)
        set Shop_Cat[p] = k
        set Shop_Ver[p] = IMaxBJ(1, Arm_Tier[p * 7 + k])
        call Shop_Refrescar(p)
    elseif k <= 12 then
        call UI_Click(p)
        set Shop_Ver[p] = k - 9
        call Shop_Refrescar(p)
    elseif k == 20 then
        call Shop_Comprar(p)
    elseif k == 21 then
        call Shop_Balas(p)
    else
        call UI_Click(p)
        call Shop_Cerrar(p)
    endif
endfunction

function Shop_Pista takes integer p, string model, real px, real py, integer kind returns nothing
    local string path = ""
    local real depth = Title_D() + Title_Eye - 14
    local trackable t
    if GetLocalPlayer() == Player(p) then
        set path = model
    endif
    set t = CreateTrackable(path, Title_WX(py, depth), Title_WY(px, depth), 0)
    call SaveInteger(Shop_HT, GetHandleId(t), 0, p)
    call SaveInteger(Shop_HT, GetHandleId(t), 1, kind)
    call TriggerRegisterTrackableHitEvent(Shop_Hit, t)
    set t = null
endfunction

function Oro_Muerte takes nothing returns nothing
    local integer o = GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
    local integer k
    if o >= WAVE_DEFAULT_OWNER_MIN and o <= WAVE_DEFAULT_OWNER_MAX and GetKillingUnit() != null then
        set k = GetPlayerId(GetOwningPlayer(GetKillingUnit()))
        if k < 8 then
            call Oro_Dar(k, IMaxBJ(3, R2I(GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) / 5.)))
        endif
    endif
endfunction

// Después de Title_Cleanup, que borra los dummies; la zona ya tiene visión por Game_Enter.
function Shop_Construir takes nothing returns nothing
    local integer p = 0
    local integer i = 0
    local integer s = GetPlayerStartLocation(Player(0))
    local trigger t = CreateTrigger()
    local unit u
    set Shop_Golem = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'ngst', GetStartLocationX(s), GetStartLocationY(s) + 300, 270)
    call SetUnitInvulnerable(Shop_Golem, true)
    call Shop_Pic(307, 442, 430, 784, 400, 'DS00')
    call Shop_Pic(948, 442, 800, 784, 400, 'DS01')
    call Shop_Pic(1601, 442, 454, 784, 400, 'DS02')
    call Shop_Pic(1601, 270, 330, 268, 399, 'DS0D')
    call Shop_Pic(1601, 269, 366, 290, 398, 'DS03')
    call Shop_Pic(755, 594, 330, 196, 399, 'DS04')
    loop
        exitwhen i > 6
        call Shop_Pic(307, 161 + 66 * i, 340, 62, 399, 'DS06')
        set Shop_CatOn[i] = Shop_Pic(307, 161 + 66 * i, 340, 62, 398.5, 'DS05')
        call Shop_Pic(166.5, 161 + 66 * i, 15, 26, 398, 'DS0C')
        set Shop_ArmaPic[i] = Shop_Pic(755, 594, 300, 150, 398, Cat_Tex[i])
        set Shop_CatT[i] = Shop_Tag(187, 146 + 66 * i, 0.022, 0, Cat_Nombre[i])
        set i = i + 1
    endloop
    set i = 0
    loop
        exitwhen i > 2
        call Shop_Pic(948, 156 + 58 * i, 716, 56, 399, 'DS08')
        set Shop_RowOn[i] = Shop_Pic(948, 156 + 58 * i, 716, 56, 398.5, 'DS07')
        call Shop_Pic(621.5, 156 + 58 * i, 15, 26, 398, 'DS0C')
        set i = i + 1
    endloop
    call Shop_Pic(948, 773, 716, 62, 399, 'DS0B')
    set Shop_BuyOn = Shop_Pic(948, 773, 716, 62, 398.5, 'DS07')
    call Shop_Pic(1601, 773, 366, 62, 399, 'DS0A')
    set Shop_RecOn = Shop_Pic(1601, 773, 366, 62, 398.5, 'DS09')
    call Shop_Pic(307, 773, 340, 62, 399, 'DS06')
    call Shop_Tag(137, 92, 0.026, 0, "Categorías")
    call Shop_Tag(1190, 96, 0.02, 0, "Precio")
    call Shop_Tag(950, 522, 0.017, 0, "Daño")
    call Shop_Tag(1140, 522, 0.017, 0, "Cargador")
    call Shop_Tag(950, 606, 0.017, 0, "Cadencia")
    call Shop_Tag(1140, 606, 0.017, 0, "Precisión")
    call Shop_Tag(1424, 678, 0.024, 0, "Oro")
    call Shop_Tag(250, 758, 0.024, 0, "Salir (Esc)")
    set i = 0
    loop
        exitwhen i > 18
        set Shop_T[i] = Shop_Tag(960, 400, 0.02, 0, "")
        set i = i + 1
    endloop
    set Shop_Hit = CreateTrigger()
    call TriggerAddAction(Shop_Hit, function Shop_Clic)
    loop
        exitwhen p > 11
        if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
            set i = 0
            loop
                exitwhen i > 6
                call Shop_Pista(p, "war3mapImported\\ShopHitCat.mdx", 307, 161 + 66 * i, i)
                set i = i + 1
            endloop
            set i = 0
            loop
                exitwhen i > 2
                call Shop_Pista(p, "war3mapImported\\ShopHitRow.mdx", 948, 156 + 58 * i, 10 + i)
                set i = i + 1
            endloop
            call Shop_Pista(p, "war3mapImported\\ShopHitWide.mdx", 948, 773, 20)
            call Shop_Pista(p, "war3mapImported\\ShopHitBtn.mdx", 1601, 773, 21)
            call Shop_Pista(p, "war3mapImported\\ShopHitCat.mdx", 307, 773, 22)
        endif
        call TriggerRegisterPlayerEvent(t, Player(p), EVENT_PLAYER_END_CINEMATIC)
        set p = p + 1
    endloop
    call TriggerAddAction(t, function Shop_Esc)
    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function Shop_Seleccion)
    call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function Oro_Muerte)
    set t = null
    set u = null
endfunction

'''


def rondas():
    out = ['    function DevWave_Reparto takes integer w,integer id,integer total,integer profile returns nothing',
           '        local integer k= 0', '        local integer a', '        loop', '            exitwhen k > 5',
           '            set a=total / 6', '            if k < total - total / 6 * 6 then', '                set a=a + 1', '            endif',
           '            if a > 0 then',
           '                call WaveAddSlotExByPlayer(w , id , a , false , WaveDifficultyOwnerCap() , 1 , 0 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN + k) , profile , 0 , 0 , 1.)',
           '            endif', '            set k=k + 1', '        endloop', '    endfunction', '',
           '    // Cada ronda repite los tipos de las anteriores con menos cantidad y añade uno.',
           '    function DevWave_Slots takes integer w,integer n returns nothing']
    for n, r in enumerate(RONDAS, 1):
        out.append(f'        {"if" if n == 1 else "elseif"} n == {n} then')
        for id_, c in zip(TIPOS, r):
            perfil = 'AI_PROFILE_RANGED' if id_ in RANGO else 'AI_PROFILE_MELEE'
            out.append(f"            call DevWave_Reparto(w , '{id_}' , {c} , {perfil})")
    out += ['        endif', '    endfunction', '', '']
    return '\n'.join(out)


def aplicar(j_in, j_out):
    s = Path(j_in).read_text(encoding='latin-1', newline='')

    def antes(ancla, bloque):
        nonlocal s
        assert s.count(ancla) == 1, ancla
        s = s.replace(ancla, crlf(bloque) + ancla)

    # Globales y datos
    s = base.once(s, 'endglobals\n', u8(GLOBALS) + 'endglobals\n')
    antes('function HealthBars__Percent takes', A)
    antes('function HealthBarsUpdate takes nothing', HUD)
    s = base.once(s, '            call Ronda_Hud(p , cam)\n', '            call Ronda_Hud(p , cam)\n            call Arm_Hud(p , cam)\n')
    s = base.once(s, '            call s__Camera_applyCameraForPlayer(cam,Player(p) , true)\n',
                  '            if Shop_Open[p] then\n                call Shop_Camara(p)\n            else\n'
                  '                call s__Camera_applyCameraForPlayer(cam,Player(p) , true)\n            endif\n')

    # Colisión: el grupo de la bala ignora a quien ya atravesó
    s = base.once(s, '                    if s__GroundCollision_isTarget(u , source , owner) then\n                        if s__GroundCollision_touches(u , nx , ny , radius) then\n',
                  '                    if s__GroundCollision_isTarget(u , source , owner) and not IsUnitInGroup(u, s__GroundCollision_skip) then\n                        if s__GroundCollision_touches(u , nx , ny , radius) then\n')
    antes('    function s__RapidBolt_sweep takes', B)
    s = base.once(s, '''        set s__GroundCollision_shaped=true
        set result=s__GroundCollision_trace(s__Missile_prevX[m]''', '''        set s__GroundCollision_shaped=true
        set s__GroundCollision_skip=Bala_Grupo[m]
        set result=s__GroundCollision_trace(s__Missile_prevX[m]''')
    s = base.once(s, '''        set s__GroundCollision_shaped=false
        return result
    endfunction

    function s__RapidBolt_resolve''', '''        set s__GroundCollision_shaped=false
        set s__GroundCollision_skip=null
        return result
    endfunction

    function s__RapidBolt_resolve''')
    s = base.once(s, '''        set result=s__RapidBolt_sweep(m)
        set target=s__GroundCollision_hit
        if result == 2 then
            set s__RapidBolt_hits=s__RapidBolt_hits + 1
            if GetUnitTypeId(caster) != 0 then
                call UnitDamageTarget(caster, target, 25., false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        elseif result == 1 then
            set s__RapidBolt_walls=s__RapidBolt_walls + 1
            set result=1
        endif
''', '''        loop
            set result=s__RapidBolt_sweep(m)
            set target=s__GroundCollision_hit
            exitwhen result != 2
            set s__RapidBolt_hits=s__RapidBolt_hits + 1
            if GetUnitTypeId(caster) != 0 and Bala_Area[m] <= 0. then
                call Arm_Impacto(m , caster , target)
            endif
            exitwhen Bala_Perfora[m] <= 0
            set Bala_Perfora[m]=Bala_Perfora[m] - 1
            call GroupAddUnit(Bala_Grupo[m], target)
        endloop
        if result == 1 then
            set s__RapidBolt_walls=s__RapidBolt_walls + 1
        endif
        if result != 0 and Bala_Area[m] > 0. then
            call Arm_Explotar(m , caster , s__GroundCollision_x , s__GroundCollision_y)
        endif
''')
    s = base.once(s, '''    function s__RapidBolt_onFinish takes integer m returns boolean
        call s__RapidBolt_resolve(m)
        return true
''', '''    function s__RapidBolt_onFinish takes integer m returns boolean
        call s__RapidBolt_resolve(m)
        if Bala_Area[m] > 0. then
            call Arm_Explotar(m , s__RapidBolt_source[m] , s__Missile_x[m] , s__Missile_y[m])
        endif
        return true
''')
    s = base.once(s, '''    function s__RapidBolt_onRemove takes integer m returns boolean
''', '''    function s__RapidBolt_onRemove takes integer m returns boolean
        if Bala_Grupo[m] != null then
            call DestroyGroup(Bala_Grupo[m])
            set Bala_Grupo[m]=null
        endif
        set Bala_Perfora[m]=0
        set Bala_Area[m]=0.
''')
    s = base.once(s, '        set length=s__RapidBolt_RANGE\n', '        set length=Arm_Alcance\n')

    # Disparo
    antes('    function s__RapidPair_emit takes', C)
    s = base.once(s, '''        set s__RapidPair_lastMissile[this]=s__RapidBolt_shootFamily(s__RapidPair_actor[this] , s__RapidPair_aimX[this] , s__RapidPair_aimY[this] , s__RapidPair_color(this) , s__RapidPair_family[this])
''', '''        call Arm_Emitir(this)
''')
    ini = s.index('    function s__RapidPair_cast takes integer this,real px,real py returns nothing')
    fin = s.index('    // A recast with another family refills the burst')
    s = s[:ini] + crlf(r'''    function s__RapidPair_cast takes integer this,real px,real py returns nothing
        local integer p= GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))
        local real time= (TimerGetElapsed(s__RapidPair_clock))
        local real ready= Arm_Listo[p * 7 + Arm_Cat[p]]
        if not s__GroundCollision_alive(s__RapidPair_actor[this]) then
            return
        endif
        set s__RapidPair_pickX[this]=px
        set s__RapidPair_pickY[this]=py
        call s__RapidPair_aimAt(this,px , py)
        if Arm_Fin[p] > 0. then
            return
        endif
        if not Arm_Puede(this) then
            call Arm_Error(p)
            if s__RapidPair_firing[this] then
                set s__RapidPair_remaining=s__RapidPair_remaining - s__RapidPair_pending[this]
                set s__RapidPair_pending[this]=0
                set s__RapidPair_nextShot[this]=time
            endif
            return
        endif
        // Sin disparo rápido: una bala cuando el arma esté lista, sin movimiento artificial.
        if not Arm_Rapido[p] then
            if time + 0.0001 >= ready then
                set s__RapidPair_pending[this]=1
                set s__RapidPair_remaining=s__RapidPair_remaining + 1
                call s__RapidPair_emit(this)
            endif
            return
        endif
        if s__RapidPair_firing[this] then
            set s__RapidPair_remaining=s__RapidPair_remaining + 6 - s__RapidPair_pending[this]
            set s__RapidPair_pending[this]=6
            set s__RapidPair_recasts=s__RapidPair_recasts + 1
            call s__RapidPair_showWalk(this)
            return
        endif
        set s__RapidPair_firing[this]=true
        set s__RapidPair_bursts=s__RapidPair_bursts + 1
        set s__RapidPair_pending[this]=6
        set s__RapidPair_remaining=s__RapidPair_remaining + 6
        // Initial instant transition, if needed, precedes the first attack.
        call s__GroundMotion_enter(s__RapidPair_motion[this])
        call s__RapidPair_showWalk(this)
        call SetUnitTimeScale(s__RapidPair_actor[this], 3.)
        if time + 0.0001 >= ready then
            set s__RapidPair_nextShot[this]=time + Arm_Int[Arm_W(p)]
            call s__RapidPair_emit(this)
        else
            set s__RapidPair_nextShot[this]=ready
        endif
    endfunction
''') + s[fin:]
    s = base.once(s, '''                        if s__RapidPair_pending[this] > 0 then
                            call s__RapidPair_emit(this)
                            set s__RapidPair_nextShot[this]=s__RapidPair_nextShot[this] + s__RapidPair_INTERVAL
                        else
                            call s__RapidPair_finish(this,true)
                        endif
''', '''                        if s__RapidPair_pending[this] > 0 and Arm_Puede(this) then
                            call s__RapidPair_emit(this)
                            set s__RapidPair_nextShot[this]=s__RapidPair_nextShot[this] + Arm_Intervalo(this)
                        else
                            if s__RapidPair_pending[this] > 0 then
                                call Arm_Error(GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this])))
                            endif
                            call s__RapidPair_finish(this,true)
                        endif
''')
    s = base.once(s, '''        // The dash replaces the burst and its artificial walk.
        call s__RapidPair_finish(this,false)
''', '''        // The dash replaces the burst and its artificial walk, and cancels a reload.
        call s__RapidPair_finish(this,false)
        set Arm_Fin[GetPlayerId(GetOwningPlayer(s__RapidPair_actor[this]))]=0.
''')
    antes('    function s__RapidPair_pointOrder takes', D)
    ini = s.index('    function s__RapidPair_spell takes nothing')
    fin = s.index('    function s__RapidPair_dashSpell takes')
    s = s[:ini] + crlf(r'''    function s__RapidPair_spell takes nothing returns nothing
        local integer this= (LoadInteger(Table___ht, (s__RapidPair_controls), (GetHandleId((GetTriggerUnit()))))) // INLINED!!
        local integer p= GetPlayerId(GetOwningPlayer(GetTriggerUnit()))
        if this != 0 and not s__RapidPair_down[this] then
            call s__RapidPair_castFamily(this,GetSpellTargetX() , GetSpellTargetY() , Arm_Familia(Arm_Tier[p * 7 + Arm_Cat[p]]))
        endif
    endfunction
''') + s[fin:]
    s = base.once(s, "        call RegisterSpellEffectEvent('Ard1' , function s__RapidPair_dashSpell)\n",
                  "        call RegisterSpellEffectEvent('Ard1' , function s__RapidPair_dashSpell)\n"
                  + ''.join(f"        call RegisterSpellEffectEvent('Aw0{c}' , function Arm_BotonArma)\n" for c in range(7))
                  + "        call RegisterSpellEffectEvent('Aw07' , function Arm_BotonRapido)\n"
                    "        call RegisterSpellEffectEvent('Aw09' , function Arm_BotonRapido)\n"
                    "        call RegisterSpellEffectEvent('Aw08' , function Arm_BotonRecarga)\n"
                    "        call TimerStart(Arm_Reloj, 0.05, true, function Arm_Latido)\n")

    # Cuerpo, HUD y oro inicial
    s = base.once(s, "    call UnitAddAbility(Game_Ctrl[p], 'Ard1')\n    call Silence_HideMove(Game_Ctrl[p])\n",
                  "    call UnitAddAbility(Game_Ctrl[p], 'Ard1')\n    call Arm_Botones(p)\n    call Silence_HideMove(Game_Ctrl[p])\n")
    s = base.once(s, '    set Game_Pair[p]=s__RapidPair_create(Game_Ctrl[p] , Game_Hero[p])\n',
                  '    set Game_Pair[p]=s__RapidPair_create(Game_Ctrl[p] , Game_Hero[p])\n    call Arm_Pareja(p)\n')
    antes('function Game_Enter takes integer p returns nothing', r'''function Arm_HudCrear takes integer p returns nothing
    set Arm_Icono[p] = HealthBars__Dummy('uidb', p)
    set Arm_Blindaje[p] = HealthBars__Dummy('uidb', p)
    call UnitAddAbility(Arm_Icono[p], s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Arm_Icono[p], s__Interface_LOCUST_ID)
    call UnitAddAbility(Arm_Blindaje[p], s__Interface_LOCUST_ID)
    call UnitRemoveAbility(Arm_Blindaje[p], s__Interface_LOCUST_ID)
    call Arm_Foto(Arm_Blindaje[p], 165., 20., 'DS0E')
    set Arm_NombreUI[p] = s__UIText_createEx(Player(p), 0., 0., 1.)
    set Arm_BalasUI[p] = s__UIText_createEx(Player(p), 0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[Arm_NombreUI[p]], true)
    call SetTextTagPermanent(s__UIText_text[Arm_BalasUI[p]], true)
    call SetTextTagColor(s__UIText_text[Arm_NombreUI[p]], 199, 247, 255, 255)
    call SetTextTagColor(s__UIText_text[Arm_BalasUI[p]], 255, 255, 255, 255)
    set Arm_Clave[p] = - 1
    set Arm_IconoCat[p] = 0
endfunction

''')
    s = base.once(s, '    call HealthBarsBindPlayer(p , Game_Cam[p] , Game_Hero[p] , icon)\n',
                  '    call HealthBarsBindPlayer(p , Game_Cam[p] , Game_Hero[p] , icon)\n    call Arm_HudCrear(p)\n'
                  '    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, 150)\n')

    # Rondas
    s = base.once(s, 'constant integer Ronda_TOTAL = 6\n', 'constant integer Ronda_TOTAL = 10\n')
    s = base.once(s, '    set Ronda_TemaActual = Ronda_Tema[Ronda_Numero]\n', '    set Ronda_TemaActual = Ronda_Tema[ModuloInteger(Ronda_Numero - 1, 6) + 1]\n')
    ini = s.index('    function DevWave_Slots takes integer w,integer n returns nothing')
    fin = s.index('    function DevWave_Start takes integer n returns nothing')
    s = s[:ini] + crlf(rondas()) + s[fin:]
    s = base.once(s, '''function Ronda_Cuenta takes nothing returns nothing
    set Ronda_Resta = Ronda_Resta - 1
    if Ronda_Resta <= 0 then
        call PauseTimer(Ronda_Reloj)
''', '''function Ronda_Cuenta takes nothing returns nothing
    // La tienda abierta detiene el descanso, hasta 60 s por descanso.
    if Shop_Abiertos > 0 and Shop_Pausa < 60 then
        set Shop_Pausa = Shop_Pausa + 1
        return
    endif
    set Ronda_Resta = Ronda_Resta - 1
    if Ronda_Resta <= 0 then
        call PauseTimer(Ronda_Reloj)
        call ExecuteFunc("Shop_CerrarTodos")
''')
    s = base.once(s, '''    if GetWaveEventWave() == Ronda_Wave then
        set Ronda_Descanso = true
''', '''    local integer p = 0
    if GetWaveEventWave() == Ronda_Wave then
        set Ronda_Descanso = true
        set Shop_Pausa = 0
        loop
            exitwhen p > 11
            if Game_On[p] then
                call Oro_Dar(p, 50 + 25 * Ronda_Numero)
            endif
            set p = p + 1
        endloop
''')

    # Tienda
    antes('function Title_Cleanup takes nothing returns nothing', SHOP)
    s = base.once(s, '    call Title_Cleanup()\n    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)\n',
                  '    call Title_Cleanup()\n    call ExecuteFunc("Shop_Construir")\n    call SetCameraBoundsToRect(bj_mapInitialCameraBounds)\n')
    s = base.once(s, 'call ExecuteFunc("RapidFire___Init")\n', 'call ExecuteFunc("Arm_Datos")\ncall ExecuteFunc("RapidFire___Init")\n')

    Path(j_out).write_text(s, encoding='latin-1', newline='')


if __name__ == '__main__':
    aplicar(sys.argv[1], sys.argv[2])
