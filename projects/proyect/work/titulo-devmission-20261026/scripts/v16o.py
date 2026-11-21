#!/usr/bin/env python3
"""v16o (08/11/2026): correcciones del tutorial tras el vídeo de v16m.
- Suelo: sin el plano SueloAzur; el recinto lleva texturas, árboles y casas copiados de la aldea (terreno_v16o.py).
- Icono al centro: con R, D y Z salía el icono anterior (UserInterface_ApplySkin no siempre prende en un dummy ya
  usado). Tut_Centro crea un dummy nuevo con la textura de esa habilidad, como al crearlo en Tut_Begin.
- Tiers: tras T1 y T2 se muestra el máximo, SPAS-12 (T6, alcance 700), con su marca; luego vuelve a T2.
  Fases de Tut_Guion2 desde la 93 corridas en uno (Tut_Guion2 sigue por debajo de 90 elseif).
- Rachas: tarjetas como Racha_Hud (cuadro DS18, retrato Tauren o Cairne en marco DS19, nombre y racha) que bajan
  desde arriba, dos por fila y hasta cuatro, en vez del texto grande. En la escena multijugador entran dos de otros
  jugadores (Cairne).
- Caja verde: más arriba (Y+60 en vez de Y-260), lejos del cuadro de diálogo; el aviso ESC y el foco van sobre ella.
- Tienda: los textos llevan el mismo desplazamiento vertical que Shop_At en la tienda real (salían altos).
- Batería: el cuadro del juego (Arm_Blindaje DS0E en 230,124 y relleno DS0F de Bat_Hud) con su texto en y 158.
Uso: v16o.py ENTRADA.j SALIDA.j (el j de v16n o v16n-prueba)
"""
from pathlib import Path
import re, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def j(t):
    return t.encode('utf-8').decode('latin-1')


def m(t):
    return ''.join('0' if 0x80 <= c <= 0xBF else '1' for c in t.encode('utf-8'))


def decir(a, b, c, espera):
    return f'call Tut_Decir("{j(a)}", "{m(a)}", "{j(b)}", "{m(b)}", "{j(c)}", "{m(c)}", {espera})'


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s

# Globales.
s = once(s, 'integer Tut_AvisoB= 0\n', '''integer Tut_AvisoB= 0
real Tut_AvisoY= 520.
texttag Tut_MarcaT3= null
unit Tut_BatMarco= null
unit Tut_BatBarra= null
integer Tut_BatVisto= -1
unit array Tut_RCaja
unit array Tut_RMarco
unit array Tut_RCara
integer array Tut_RTN
integer array Tut_RTL
real array Tut_RY
real array Tut_RHabla
real array Tut_RAnchoN
real array Tut_RAnchoL
boolean array Tut_RAct
boolean array Tut_RSale
boolean array Tut_RCairne
''')

# Suelo: sin plano.
s = once(s, '''    set Tut_Suelo = AddSpecialEffect("war3mapImported\\\\SueloAzur.mdx", Tut_X + 500., Tut_Y)
''', '''    // v16o: sin plano; el recinto lleva el suelo, los \xc3\xa1rboles y las casas de la aldea (terreno_v16o.py).
''')
s = once(s, '''    call Racha_Registrar("war3mapImported\\\\announcer_kill_spree_01.mp3")
''', '''    call Racha_Registrar("war3mapImported\\\\announcer_kill_spree_01.mp3")
    call Racha_Registrar("Units\\\\Orc\\\\Tauren\\\\TaurenYesAttack1.wav")
    call Racha_Registrar("Units\\\\Orc\\\\Cairne\\\\CairneYesAttack1.wav")
''')

# Tarjetas de racha, antes de Tut_Soltar (que las limpia).
s = once(s, 'function Tut_Soltar takes nothing returns nothing\n', '''// v16o: tarjetas de racha del tutorial, como Racha_Hud con la c\xc3\xa1mara del tutorial. Hueco h 0..3, dos por fila.
function Tut_TarjetaQuitarUna takes integer h returns nothing
    if not Tut_RAct[h] then
        return
    endif
    call RemoveUnit(Tut_RCaja[h])
    call RemoveUnit(Tut_RMarco[h])
    call RemoveUnit(Tut_RCara[h])
    set Tut_RCaja[h] = null
    set Tut_RMarco[h] = null
    set Tut_RCara[h] = null
    call s__UIText_destroy(Tut_RTN[h])
    call s__UIText_destroy(Tut_RTL[h])
    set Tut_RAct[h] = false
endfunction

function Tut_TarjetaCara takes integer h,boolean habla returns nothing
    if Tut_RCairne[h] then
        if habla then
            call SetUnitAnimationByIndex(Tut_RCara[h], 1)
        else
            call SetUnitAnimationByIndex(Tut_RCara[h], 0)
        endif
    elseif habla then
        call SetUnitAnimationByIndex(Tut_RCara[h], DIALOGUE_RIGHT_TALK)
    else
        call SetUnitAnimationByIndex(Tut_RCara[h], DIALOGUE_RIGHT_IDLE)
    endif
endfunction

function Tut_TarjetaPoner takes integer h returns nothing
    local real y= Tut_RY[h]
    local real cx= 705. + 420. * ModuloInteger(h, 2)
    local real d= 3. * ( h / 2 )
    call HealthBars__Place(Tut_RCaja[h], Tut_Cam, cx, y, 400. + d)
    call HealthBars__Place(Tut_RCara[h], Tut_Cam, cx + 170.6 + Racha_AjX, y + Racha_AjY, 398. + d)
    call HealthBars__Place(Tut_RMarco[h], Tut_Cam, cx + 170.6, y, 390. + d)
    call s__UIText_setPosition(Tut_RTN[h], ( cx - 36.4 - Tut_RAnchoN[h] - 960. ) / 728., ( 420. - ( y - 17. + Racha_AjN ) ) / 390.)
    call s__UIText_setPosition(Tut_RTL[h], ( cx - 36.4 - Tut_RAnchoL[h] - 960. ) / 728., ( 420. - ( y + 8. + Racha_AjL ) ) / 390.)
endfunction

function Tut_Tarjeta takes integer h,string nombre,string texto,boolean cairne returns nothing
    local real e= 50. * ( 0.302 / 387.73819261 ) * ( 398. + 3. * ( h / 2 ) ) / 21.4 * Racha_AjS
    call Tut_TarjetaQuitarUna(h)
    set Tut_RCaja[h] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_RCaja[h], 410., 56., 400., 'DS18')
    set Tut_RMarco[h] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_RMarco[h], 66. * 390. / 400., 56. * 390. / 400., 400., 'DS19')
    if cairne then
        set Tut_RCara[h] = Tut_Pieza('dca0')
    else
        set Tut_RCara[h] = Tut_Pieza('dta0')
    endif
    call SetUnitScale(Tut_RCara[h], e, e, e)
    set Tut_RCairne[h] = cairne
    set Tut_RTN[h] = s__UIText_create(0., 0., 1.)
    set Tut_RTL[h] = s__UIText_create(0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[Tut_RTN[h]], true)
    call SetTextTagPermanent(s__UIText_text[Tut_RTL[h]], true)
    call SetTextTagColor(s__UIText_text[Tut_RTN[h]], 255, 255, 255, 255)
    call SetTextTagColor(s__UIText_text[Tut_RTL[h]], 255, 255, 255, 255)
    call SetTextTagText(s__UIText_text[Tut_RTN[h]], nombre, 0.015)
    call SetTextTagText(s__UIText_text[Tut_RTL[h]], texto, 0.020)
    set Tut_RAnchoN[h] = I2R(Racha_Largo(nombre)) * 4.5 * 0.015 / 0.017
    set Tut_RAnchoL[h] = I2R(Racha_Largo(texto)) * 4.5 * 0.020 / 0.017
    set Tut_RY[h] = -80.
    set Tut_RHabla[h] = 1.6
    set Tut_RSale[h] = false
    set Tut_RAct[h] = true
    call Tut_TarjetaCara(h, true)
    call Tut_TarjetaPoner(h)
    call s__UIText_show(Tut_RTN[h], true, Tut_Cam)
    call s__UIText_show(Tut_RTL[h], true, Tut_Cam)
endfunction

// Cada tick (0,02 s): bajan a su fila (Racha_Y + 62 por fila) o suben al salir, como Racha_Mover.
function Tut_TarjetasPaso takes nothing returns nothing
    local integer h= 0
    local real meta
    loop
        exitwhen h > 3
        if Tut_RAct[h] then
            set meta = Racha_Y + 62. * ( h / 2 )
            if Tut_RSale[h] then
                set meta = -90.
            endif
            set Tut_RY[h] = Tut_RY[h] + ( meta - Tut_RY[h] ) * 0.36
            if Tut_RSale[h] and Tut_RY[h] < -72. then
                call Tut_TarjetaQuitarUna(h)
            else
                if Tut_RHabla[h] > 0. then
                    set Tut_RHabla[h] = Tut_RHabla[h] - 0.02
                    if Tut_RHabla[h] <= 0. then
                        call Tut_TarjetaCara(h, false)
                    endif
                endif
                call Tut_TarjetaPoner(h)
            endif
        endif
        set h = h + 1
    endloop
endfunction

function Tut_TarjetasSalir takes nothing returns nothing
    local integer h= 0
    loop
        exitwhen h > 3
        set Tut_RSale[h] = true
        set h = h + 1
    endloop
endfunction

function Tut_Soltar takes nothing returns nothing
''')
s = once(s, '''    if Tut_MarcaT2 != null then
        call DestroyTextTag(Tut_MarcaT2)
        set Tut_MarcaT2 = null
    endif
    // v16f: enemigos''', '''    if Tut_MarcaT2 != null then
        call DestroyTextTag(Tut_MarcaT2)
        set Tut_MarcaT2 = null
    endif
    // v16o: marca del tier m\xc3\xa1ximo, cuadro de bater\xc3\xada y tarjetas de racha.
    if Tut_MarcaT3 != null then
        call DestroyTextTag(Tut_MarcaT3)
        set Tut_MarcaT3 = null
    endif
    if Tut_BatMarco != null then
        call RemoveUnit(Tut_BatMarco)
        call RemoveUnit(Tut_BatBarra)
        set Tut_BatMarco = null
        set Tut_BatBarra = null
    endif
    set k = 0
    loop
        exitwhen k > 3
        call Tut_TarjetaQuitarUna(k)
        set k = k + 1
    endloop
    set k = 0
    // v16f: enemigos''')

# Icono al centro: dummy nuevo con su textura.
s = once(s, '''    call Tut_Poner(2, 260., 0., 0.)
    call Tut_Mover(2, 60., 1., 0.7)
    call HealthBars__Place(Tut_Icono, Tut_Cam, x, y, 392.)
    call ShowUnit(Tut_Icono, true)
    call UserInterface_ApplySkin(Tut_Icono, tex)
''', '''    call Tut_Poner(2, 260., 0., 0.)
    call Tut_Mover(2, 60., 1., 0.7)
    // v16o: un dummy nuevo; cambiar la textura del ya usado a veces dejaba la anterior (R, D y Z).
    call RemoveUnit(Tut_Icono)
    set Tut_Icono = Tut_Pieza('uidb')
    call Tut_Foto(Tut_Icono, 64., 64., 392., tex)
    call HealthBars__Place(Tut_Icono, Tut_Cam, x, y, 392.)
    call ShowUnit(Tut_Icono, true)
''')

# Tienda: desplazamiento vertical de Shop_At.
s = once(s, '''    local integer ui= s__UIText_create(( px - 960. ) / 728., ( 420. - py ) / 390., 1.)
    call SetTextTagPermanent(s__UIText_text[ui], true)
    call SetTextTagColor(s__UIText_text[ui], 235, 240, 245, 255)
''', '''    // v16o: como Shop_At, el texto baja 750 * size (sal\xc3\xada alto en sus cuadros).
    local integer ui= s__UIText_create(( px - 960. ) / 728., ( 420. - ( py + 750. * size ) ) / 390., 1.)
    call SetTextTagPermanent(s__UIText_text[ui], true)
    call SetTextTagColor(s__UIText_text[ui], 235, 240, 245, 255)
''')
s = once(s, '''    call SetTextTagText(s__UIText_text[ui], a, size)
    call s__UIText_setPosition(ui, ( px - 960. ) / 728., ( 420. - py ) / 390.)
endfunction''', '''    call SetTextTagText(s__UIText_text[ui], a, size)
    call s__UIText_setPosition(ui, ( px - 960. ) / 728., ( 420. - ( py + 750. * size ) ) / 390.)
endfunction''')

# Batería: el cuadro del juego.
s = once(s, '''    call SetTextTagText(s__UIText_text[Tut_BatUI], "Bater\xc3\xada " + I2S(IMinBJ(100, R2I(Tut_BatT + 0.999))) + "%   Recargas (G): " + I2S(Tut_BatCargas), 0.016)
''', '''    // v16o: como Bat_Hud: marco, relleno con su color y texto en y 158.
    set pct = IMinBJ(100, R2I(Tut_BatT + 0.999))
    if pct * 1000 + Tut_BatCargas != Tut_BatVisto then
        set Tut_BatVisto = pct * 1000 + Tut_BatCargas
        set g = 210
        set b = 80
        if pct <= 10 then
            set g = 60
            set b = 40
        endif
        call SetUnitVertexColor(Tut_BatBarra, 255, g, b, 255)
        call Bat_Ancho(Tut_BatBarra, RMaxBJ(1., 1.566 * pct), 21.2)
        call SetTextTagColor(s__UIText_text[Tut_BatUI], 255, IMinBJ(255, g + 40), b + 40, 255)
        call Arm_Texto(Tut_BatUI, "Bater\xc3\xada " + I2S(pct) + "%   Recargas (G): " + I2S(Tut_BatCargas), 0.015, 158.)
    endif
    call HealthBars__Place(Tut_BatMarco, Tut_Cam, 230., 124., 400.)
    call ShowUnit(Tut_BatBarra, pct > 0)
    if pct > 0 then
        call HealthBars__Place(Tut_BatBarra, Tut_Cam, 151.7 + 0.783 * pct, 124., 385.)
    endif
''')
s = once(s, '''function Tut_BatPaso takes nothing returns nothing
    local integer n
''', '''function Tut_BatPaso takes nothing returns nothing
    local integer n
    local integer pct
    local integer g
    local integer b
''')
s = once(s, '''        set Tut_BatUI = s__UIText_create(( 150. - 960. ) / 728., ( 420. - 252. ) / 390., 1.)
        call SetTextTagPermanent(s__UIText_text[Tut_BatUI], true)
        call SetTextTagColor(s__UIText_text[Tut_BatUI], 255, 230, 140, 255)
        call s__UIText_show(Tut_BatUI, true, Tut_Cam)
''', '''        set Tut_BatUI = s__UIText_create(( 150. - 960. ) / 728., ( 420. - 158. ) / 390., 1.)
        call SetTextTagPermanent(s__UIText_text[Tut_BatUI], true)
        call s__UIText_show(Tut_BatUI, true, Tut_Cam)
        set Tut_BatMarco = Tut_Pieza('uidb')
        call Tut_Foto(Tut_BatMarco, 165., 20., 400., 'DS0E')
        set Tut_BatBarra = Tut_Pieza('uidb')
        call Tut_Foto(Tut_BatBarra, 156.6, 21.2, 400., 'DS0F')
        set Tut_BatVisto = -1
''')
s = once(s, '''        set Tut_FocoD = 398.
        call Tut_Poner(1, 300., 262., 0.)
        call Tut_Poner(2, 420., 0., 0.)
        call Tut_Mover(2, 140., 1., 0.7)''', '''        set Tut_FocoD = 398.
        call Tut_Poner(1, 230., 135., 0.)
        call Tut_Poner(2, 420., 0., 0.)
        call Tut_Mover(2, 130., 1., 0.7)''')
s = once(s, '''        call s__UIText_destroy(Tut_BatUI)
        set Tut_BatUI = 0
        call Pres_Black(255, 0, 0.6)''', '''        call s__UIText_destroy(Tut_BatUI)
        set Tut_BatUI = 0
        call RemoveUnit(Tut_BatMarco)
        call RemoveUnit(Tut_BatBarra)
        set Tut_BatMarco = null
        set Tut_BatBarra = null
        call Pres_Black(255, 0, 0.6)''')

# Caja verde más arriba; aviso ESC y foco sobre ella.
s = once(s, '        set Tut_CajaY = Tut_Y - 260.\n', '        set Tut_CajaY = Tut_Y + 60.\n')
s = once(s, '''        set Tut_AvisoB = Tut_AvisoCrear(''', '''        call Tut_Pantalla(Tut_CajaX, Tut_CajaY, Tut_Z)
        set Tut_AvisoY = Tut_PuntoY - 100.
        set Tut_AvisoB = Tut_AvisoCrear(''')
s = once(s, '''", 18)
        set Tut_Sig = Tut_T + 0.5''', '''", 18)
        call s__UIText_setPosition(Tut_AvisoB, ( - 18. * 4.5 * 0.026 / 0.017 ) / 728., ( 420. - Tut_AvisoY ) / 390.)
        set Tut_Sig = Tut_T + 0.5''')
s = once(s, '''        call Tut_Nota("fase 87 " + R2S(Tut_T))
        call Tut_Poner(1, 960., 532., 0.)''', '''        call Tut_Nota("fase 87 " + R2S(Tut_T))
        call Tut_Poner(1, 960., Tut_AvisoY + 12., 0.)''')

# Tarjetas en la escena de rachas.
s = once(s, '''        set Tut_Anun = Tut_Anuncio("|cff66ccffTriple Kill|r (3)", 15, 190.)
''', '''        call Tut_Tarjeta(0, "|cffff0303Tauren|r", "|cff66ccffTriple Kill|r", false)
        call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenYesAttack1.wav")
''')
s = once(s, '''        call Tut_AnuncioCambiar("|cffffff00Killing Spree|r (25)", 18, 190.)
''', '''        call Tut_Tarjeta(1, "|cffff0303Tauren|r", "|cffffff00Killing Spree|r", false)
''')
s = once(s, '''        call Tut_Decir("En multijugador, compite por",''', '''        call Tut_Tarjeta(2, "|cff0042ffJugador 2|r", "|cff66ccffDouble Kill|r", true)
        call Tut_Tarjeta(3, "|cff1ce6b9Jugador 3|r", "|cffffff00Dominating|r", true)
        call Racha_Sonar("Units\\\\Orc\\\\Cairne\\\\CairneYesAttack1.wav")
        call Tut_Decir("En multijugador, compite por",''')
s = once(s, '''        call Tut_AnuncioQuitar()
        set Tut_Sig = Tut_T + 0.3
    elseif Tut_Fase == 104 then''', '''        call Tut_TarjetasSalir()
        set Tut_Sig = Tut_T + 0.6
    elseif Tut_Fase == 104 then''')

# Tier máximo: fases de Tut_Guion2 desde la 93 corridas en uno y la nueva 93.
a = s.index('function Tut_Guion2 takes nothing returns nothing')
z = s.index('function Tut_Guion takes nothing returns nothing')
g = s[a:z]
antes = len(re.findall(r'Tut_Fase == \d+', g))
g = re.sub(r'Tut_Fase == (\d+) then\r\n        call Tut_Nota\("fase (\d+) ',
           lambda q: (f'Tut_Fase == {int(q[1]) + (int(q[1]) >= 93)} then\r\n        call Tut_Nota("fase '
                      f'{int(q[2]) + (int(q[2]) >= 93)} '), g)
assert len(re.findall(r'Tut_Fase == \d+', g)) == antes
nueva = '''    elseif Tut_Fase == 93 then
        call Tut_Nota("fase 93 " + R2S(Tut_T))
        // v16o: el tier m\xc3\xa1ximo de la escopeta.
        set Arm_Tier[Tut_P * 7 + 4] = 6
        set Arm_Clip[Tut_P * 7 + 4] = Arm_Mag[29]
        set Arm_Rva[Tut_P * 7 + 4] = Arm_Res[29]
        set Arm_Fin[Tut_P] = 0.
        call Arm_Pareja(Tut_P)
        set Tut_MarcaT3 = Tut_Marcar(Arm_TierTexto(6) + ": 700", Tut_X + 700., Tut_Y)
        call Tut_Disparo(1)
        ''' + decir('SPAS-12, tier 6, el máximo:', 'llega a 700, 8 perdigones y', 'cargador de 14.', 0.8) + '''
'''.replace('\n', '\r\n')
k = g.index('    elseif Tut_Fase == 94 then\r\n        call Tut_Nota("fase 94 ')
g = g[:k] + nueva + g[k:]
s = s[:a] + g + s[z:]
s = once(s, '''        set Tut_MarcaT1 = null
        set Tut_MarcaT2 = null
        set Tut_Sig = Tut_T + 0.4''', '''        set Tut_MarcaT1 = null
        set Tut_MarcaT2 = null
        call DestroyTextTag(Tut_MarcaT3)
        set Tut_MarcaT3 = null
        // v16o: vuelve a la Winchester (T2) para las rachas.
        set Arm_Tier[Tut_P * 7 + 4] = 2
        call Arm_Pareja(Tut_P)
        set Tut_Sig = Tut_T + 0.4''')
s = once(s, '''    call Tut_BatPaso()
    call Tut_GolemPaso()''', '''    call Tut_BatPaso()
    call Tut_TarjetasPaso()
    call Tut_GolemPaso()''')

g = s[s.index('function Tut_Guion2 takes'):s.index('function Tut_Guion takes')]
print('elseif en Tut_Guion2', g.count('elseif Tut_Fase =='), 'fases', sorted(int(x) for x in re.findall(r'Tut_Fase == (\d+)', g))[-3:])
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16o ok')
