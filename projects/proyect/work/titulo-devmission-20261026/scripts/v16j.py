#!/usr/bin/env python3
"""v16j (08/11/2026): ajustes vistos por Leon en v16i.
- Cuadro de diálogo un 35 % mayor (panel 864 x 216, marco 202 x 171, texto 0,025 con renglones cada 36 px); en la tienda
  el texto vuelve a 0,019 como estaba. El retrato pasa delante del marco amarillo (profundidad 384), como en la tienda.
- Suelo negro en la zona del tutorial: el plano de la pantalla de título (TitlePlano.mdx, 4096 x 4096) en X + 500.
- Teclas sobre la consola 3 x 4 (las reales del juego por casilla: QWER / AFGD / ZXCV), visibles mientras se ve la
  consola; se quitan antes de abrir la réplica de la tienda (presupuesto de texttags).
- Como la A del principio, los iconos de F (recargar), R (escopeta) y D (dash) van al centro con su tecla, se pulsan
  allí y vuelven a su casilla.
- Partida y tutorial: mientras un jugador recarga, las cadenas azules del jefe (Bondage Blue SD.mdx) en el pecho de su
  cuerpo; al terminar o cancelarse la recarga el efecto muere (Arm_Latido, cada 0,05 s).
Uso: v16j.py ENTRADA.j SALIDA.j (el j de v16i)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def todas(s, old, new, n):
    o = old.replace('\n', '\r\n')
    assert s.count(o) == n, (old, s.count(o))
    return s.replace(o, new.replace('\n', '\r\n'))


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s

s = once(s, 'unit Tut_Nuevo= null\n', '''unit Tut_Nuevo= null
effect array Arm_CadFx
integer Tut_SinK= -1
integer array Tut_Tecla
real Tut_TxtTam= 0.025
effect Tut_Suelo= null
integer Tut_CenEt= 0
integer Tut_CenK= 0
real Tut_CenT0= 0.
''')

# Cadenas azules en el pecho mientras dura la recarga (todas las parejas, también la del tutorial).
s = once(s, '''                set Arm_Rva[i]=Arm_Rva[i] - n
            endif
            set p=p + 1
        endloop
    endfunction
''', '''                set Arm_Rva[i]=Arm_Rva[i] - n
            endif
            // v16j: cadenas azules en el pecho mientras recarga; al acabar o cancelarse, el efecto muere.
            if Arm_Fin[p] > 0. and Game_Pair[p] != 0 then
                if Arm_CadFx[p] == null then
                    set Arm_CadFx[p]=AddSpecialEffectTarget("war3mapImported\\\\Bondage Blue SD.mdx", s__RapidPair_actor[Game_Pair[p]], "chest")
                endif
            elseif Arm_CadFx[p] != null then
                call DestroyEffect(Arm_CadFx[p])
                set Arm_CadFx[p]=null
            endif
            set p=p + 1
        endloop
    endfunction
''')

# Cuadro de diálogo mayor y retrato delante del marco.
s = todas(s, 'call HealthBars__Place(Tut_Panel, Tut_Cam, 344., 736., 396.)', 'call HealthBars__Place(Tut_Panel, Tut_Cam, 455., 708., 396.)', 2)
s = todas(s, 'call HealthBars__Place(Tut_Cara, Tut_Cam, 110., 736., 394.)', 'call HealthBars__Place(Tut_Cara, Tut_Cam, 139., 708., 384.)', 2)
s = todas(s, 'call HealthBars__Place(Tut_Marco, Tut_Cam, 110., 736., 388.)', 'call HealthBars__Place(Tut_Marco, Tut_Cam, 139., 708., 388.)', 2)
s = once(s, "call Tut_Foto(Tut_Panel, 640. * 396. / 400., 160. * 396. / 400., 400., 'DS1B')",
         "call Tut_Foto(Tut_Panel, 864. * 396. / 400., 216. * 396. / 400., 400., 'DS1B')")
s = once(s, "call Tut_Foto(Tut_Marco, 150. * 388. / 400., 127. * 388. / 400., 400., 'DS19')",
         "call Tut_Foto(Tut_Marco, 202. * 388. / 400., 171. * 388. / 400., 400., 'DS19')")
s = once(s, 'call SetUnitScale(Tut_Cara, 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4, 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4, 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4)',
         'call SetUnitScale(Tut_Cara, 160. * ( 0.302 / 387.73819261 ) * 384. / 21.4, 160. * ( 0.302 / 387.73819261 ) * 384. / 21.4, 160. * ( 0.302 / 387.73819261 ) * 384. / 21.4)')
s = once(s, '''    local real e= 118. * ( 0.302 / 387.73819261 ) * 394. / 21.4
    local integer i= 0
    call Tut_TiendaVer(false)
''', '''    local real e= 160. * ( 0.302 / 387.73819261 ) * 384. / 21.4
    local integer i= 0
    call Tut_TiendaVer(false)
    set Tut_TxtTam = 0.025
''')
s = todas(s, 's__UIText_setPosition(Tut_Nombre, ( 200. - 960. ) / 728., ( 420. - 678. ) / 390.)',
          's__UIText_setPosition(Tut_Nombre, ( 261. - 960. ) / 728., ( 420. - 629. ) / 390.)', 1)
s = todas(s, 's__UIText_setPosition(Tut_Txt[i], ( 200. - 960. ) / 728., ( 420. - ( 722. + 27. * i ) ) / 390.)',
          's__UIText_setPosition(Tut_Txt[i], ( 261. - 960. ) / 728., ( 420. - ( 689. + 36. * i ) ) / 390.)', 1)
s = once(s, 'set Tut_Nombre = s__UIText_create(( 200. - 960. ) / 728., ( 420. - 678. ) / 390., 1.)',
         'set Tut_Nombre = s__UIText_create(( 261. - 960. ) / 728., ( 420. - 629. ) / 390., 1.)')
s = once(s, 'call SetTextTagText(s__UIText_text[Tut_Nombre], "Tauren", 0.016)', 'call SetTextTagText(s__UIText_text[Tut_Nombre], "Tauren", 0.020)')
s = once(s, 'set Tut_Txt[i] = s__UIText_create(( 200. - 960. ) / 728., ( 420. - ( 722. + 27. * i ) ) / 390., 1.)',
         'set Tut_Txt[i] = s__UIText_create(( 261. - 960. ) / 728., ( 420. - ( 689. + 36. * i ) ) / 390., 1.)')
s = todas(s, 'call SetTextTagText(s__UIText_text[Tut_Txt[i]], " ", 0.019)', 'call SetTextTagText(s__UIText_text[Tut_Txt[i]], " ", Tut_TxtTam)', 2)
s = once(s, 'call SetTextTagText(s__UIText_text[Tut_Txt[i]], SubString(Tut_Linea[i], 0, Tut_Car[i]), 0.019)',
         'call SetTextTagText(s__UIText_text[Tut_Txt[i]], SubString(Tut_Linea[i], 0, Tut_Car[i]), Tut_TxtTam)')
# En la tienda, el texto de la columna derecha como estaba; las teclas de la consola se quitan antes.
s = once(s, '''    if Tut_SPzN == 0 then
        call Tut_TiendaCrear()
    endif
''', '''    call Tut_TeclasQuitar()
    set Tut_TxtTam = 0.019
    if Tut_SPzN == 0 then
        call Tut_TiendaCrear()
    endif
''')

# Teclas sobre la consola.
s = once(s, '''    set i = 0
    // Textos para todos: nombre, tres renglones y la etiqueta del icono.
''', '''    set i = 0
    // v16j: la tecla de cada casilla de la consola, en su esquina.
    loop
        exitwhen i > 11
        set Tut_Tecla[i] = s__UIText_create(0., 0., 1.)
        call SetTextTagPermanent(s__UIText_text[Tut_Tecla[i]], true)
        call SetTextTagColor(s__UIText_text[Tut_Tecla[i]], 255, 204, 0, 255)
        call SetTextTagText(s__UIText_text[Tut_Tecla[i]], SubString("QWERAFGDZXCV", i, i + 1), 0.018)
        call s__UIText_show(Tut_Tecla[i], false, Tut_Cam)
        set i = i + 1
    endloop
    set i = 0
    // Textos para todos: nombre, tres renglones y la etiqueta del icono.
''')
s = once(s, '''        call ShowUnit(Tut_Casilla[i], ver)
        if ver then
            call HealthBars__Place(Tut_Casilla[i], Tut_Cam, x, y, 452.)
        endif
''', '''        call ShowUnit(Tut_Casilla[i], ver)
        if ver then
            call HealthBars__Place(Tut_Casilla[i], Tut_Cam, x, y, 452.)
        endif
        if Tut_Tecla[i] != 0 then
            call s__UIText_show(Tut_Tecla[i], ver, Tut_Cam)
            if ver then
                call s__UIText_setPosition(Tut_Tecla[i], ( x - 33. - 960. ) / 728., ( 420. - ( y - 35. ) ) / 390.)
            endif
        endif
''')
s = once(s, 'set ver = ver and not ( i == 4 and Tut_SinA )', 'set ver = ver and not ( i == 4 and Tut_SinA ) and i != Tut_SinK')

# Suelo negro y hora fija.
s = once(s, '''    call SuspendTimeOfDay(true)
    loop
''', '''    call SuspendTimeOfDay(true)
    // v16j: suelo negro (el plano del título) bajo toda la zona del tutorial.
    set Tut_Suelo = AddSpecialEffect("war3mapImported\\\\TitlePlano.mdx", Tut_X + 500., Tut_Y)
    loop
''')
s = once(s, '''        call FogModifierStop(Tut_Vista[p])
        call DestroyFogModifier(Tut_Vista[p])
        set Tut_Vista[p] = null
        set p = p + 1
    endloop
''', '''        call FogModifierStop(Tut_Vista[p])
        call DestroyFogModifier(Tut_Vista[p])
        set Tut_Vista[p] = null
        set p = p + 1
    endloop
    call Tut_TeclasQuitar()
    if Tut_Suelo != null then
        call DestroyEffect(Tut_Suelo)
        set Tut_Suelo = null
    endif
''')

s = once(s, 'function Tut_Terminar takes nothing returns nothing\n', '''// v16j: las teclas de la consola se destruyen al abrir la tienda o al terminar.
function Tut_TeclasQuitar takes nothing returns nothing
    local integer i= 0
    loop
        exitwhen i > 11
        if Tut_Tecla[i] != 0 then
            call s__UIText_destroy(Tut_Tecla[i])
            set Tut_Tecla[i] = 0
        endif
        set i = i + 1
    endloop
endfunction

function Tut_Terminar takes nothing returns nothing
''')

# Icono al centro con su tecla y vuelta a su casilla.
s = once(s, 'function Tut_Guion takes nothing returns nothing\n', '''// v16j: como la A del principio: el icono k de la consola va al centro con su tecla, se pulsa allí y vuelve.
function Tut_Centro takes integer k,integer tex,string a returns nothing
    local real x= 1500. + 106. * ModuloInteger(k, 4)
    local real y= 535. + 100. * ( k / 4 )
    set Tut_CenK = k
    set Tut_SinK = k
    set Tut_IconoS = 1.
    call Tut_Poner(0, x, y, 0.)
    call Tut_Poner(1, x, y, 0.)
    call Tut_Poner(2, 260., 0., 0.)
    call Tut_Mover(2, 60., 1., 0.7)
    call HealthBars__Place(Tut_Icono, Tut_Cam, x, y, 392.)
    call ShowUnit(Tut_Icono, true)
    call UserInterface_ApplySkin(Tut_Icono, tex)
    call ShowUnit(Tut_Foco, true)
    call SetTextTagText(s__UIText_text[Tut_Etiqueta], a, 0.022)
    call s__UIText_setPosition(Tut_Etiqueta, ( - StringLength(a) * 0.022 * 235. ) / 728., ( 420. - 352. ) / 390.)
    call Racha_Sonar("Sound\\\\Interface\\\\MouseClick1.wav")
    set Tut_CenEt = 1
    set Tut_CenT0 = Tut_T
endfunction

function Tut_CentroVolver takes nothing returns nothing
    call s__UIText_show(Tut_Etiqueta, false, Tut_Cam)
    call Tut_Mover(0, 1500. + 106. * ModuloInteger(Tut_CenK, 4), 535. + 100. * ( Tut_CenK / 4 ), 0.7)
    set Tut_CenEt = 4
    set Tut_CenT0 = Tut_T
endfunction

function Tut_CentroPaso takes nothing returns nothing
    if Tut_CenEt == 1 and Tut_T >= Tut_CenT0 + 0.8 then
        call Tut_Mover(0, 960., 300., 1.)
        call Tut_Mover(1, 960., 300., 1.)
        call Tut_Mover(2, 85., 1., 1.)
        set Tut_CenEt = 2
    elseif Tut_CenEt == 2 and Tut_T >= Tut_CenT0 + 1.9 then
        call s__UIText_show(Tut_Etiqueta, true, Tut_Cam)
        call Tut_Poner(3, 1250., 560., 0.)
        call Tut_Mover(3, 960., 300., 0.8)
        call ShowUnit(Tut_Mano, true)
        set Tut_CenEt = 3
    elseif Tut_CenEt == 4 and Tut_T >= Tut_CenT0 + 0.75 then
        call ShowUnit(Tut_Icono, false)
        set Tut_SinK = - 1
        set Tut_CenEt = 0
    endif
endfunction

function Tut_Guion takes nothing returns nothing
''')
s = once(s, '''    call Tut_Rejilla()
    call Tut_GolemPaso()
''', '''    call Tut_Rejilla()
    call Tut_CentroPaso()
    call Tut_GolemPaso()
''')
for fase, x, y, k, tex, a in ((19, 1606, 635, 5, 'DS1O', 'Recargar (F)'), (39, 1818, 535, 3, 'DS1L', 'Escopeta (R)'),
                              (44, 1818, 635, 7, 'DS1G', 'Dash (D)')):
    s = once(s, f'''        call Tut_Nota("fase {fase} " + R2S(Tut_T))
        call Tut_Poner(1, {x}., {y}., 0.)
        call Tut_Poner(2, 260., 0., 0.)
        call Tut_Mover(2, 60., 1., 0.7)
        call ShowUnit(Tut_Foco, true)
        call Tut_Poner(3, 1300., 420., 0.)
        call Tut_Mover(3, {x}., {y}., 0.8)
        call ShowUnit(Tut_Mano, true)
        set Tut_Sig = Tut_T + 0.95
''', f'''        call Tut_Nota("fase {fase} " + R2S(Tut_T))
        call Tut_Centro({k}, '{tex}', "{a}")
        set Tut_Sig = Tut_T + 2.9
''')
for fase in (21, 41, 47):
    s = once(s, f'''        call Tut_Nota("fase {fase} " + R2S(Tut_T))
        set Tut_IconoS = 1.
        call ShowUnit(Tut_Mano, false)
''', f'''        call Tut_Nota("fase {fase} " + R2S(Tut_T))
        set Tut_IconoS = 1.
        call ShowUnit(Tut_Mano, false)
        call Tut_CentroVolver()
''')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16j ok')
