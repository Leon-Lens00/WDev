#!/usr/bin/env python3
"""v16k (08/11/2026): escenas nuevas del tutorial y ajustes de v16j.
- Retrato dentro de su marco: escala 125 en el diálogo (antes 160) y 175 en la tienda (antes 200).
- Suelo azul celeste pastel (SueloAzur.mdx, suelo_v16k.py) en lugar del negro: resalta el foco oscuro.
- Tras la caja verde, antes de la despedida:
  1. Tiers: vuelve al centro y dispara el Trabuco T1 (alcance 400) y la Winchester T2 (450), con marcas en el suelo.
  2. Rachas: tres enemigos, Triple Kill y Killing Spree con su voz; compite en multijugador por la racha.
  3. Vidas: el Tauren cae, Vidas: 0, no reaparece hasta superar la oleada; luego vuelve.
  4. Luz: noche (hora 0), linterna BatLuz con batería que se gasta y se apaga; G al centro y se recarga.
  5. Cuchillo: sin balas, Z al centro, cono del cuchillo; se acerca al enemigo y lo remata.
- La réplica de la tienda se destruye al empezar estas escenas (texttags); las teclas de la consola se recrean.
Uso: v16k.py ENTRADA.j SALIDA.j (el j de v16j)
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def j(t):
    return t.encode('utf-8').decode('latin-1')


def mask(t):
    return ''.join('0' if 0x80 <= b <= 0xBF else '1' for b in t.encode('utf-8'))


def decir(a, b='', c='', espera=0.3):
    for t in (a, b, c):
        assert len(t) <= 40, t
    return (f'call Tut_Decir("{j(a)}", "{mask(a)}", "{j(b)}", "{mask(b)}", "{j(c)}", "{mask(c)}", {espera})')


def todas(s, old, new, n):
    o = old.replace('\n', '\r\n')
    assert s.count(o) == n, (old, s.count(o))
    return s.replace(o, new.replace('\n', '\r\n'))


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
assert '\r\n' in s

# Retrato dentro del marco, suelo azul.
s = todas(s, '160. * ( 0.302 / 387.73819261 ) * 384. / 21.4', '125. * ( 0.302 / 387.73819261 ) * 384. / 21.4', 4)
s = once(s, 'local real e= 200. * ( 0.302 / 387.73819261 ) * 394. / 21.4', 'local real e= 175. * ( 0.302 / 387.73819261 ) * 394. / 21.4')
s = once(s, '"war3mapImported\\\\TitlePlano.mdx", Tut_X + 500., Tut_Y)', '"war3mapImported\\\\SueloAzur.mdx", Tut_X + 500., Tut_Y)')

s = once(s, 'unit Tut_Nuevo= null\n', '''unit Tut_Nuevo= null
integer Tut_BatUI= 0
real Tut_BatT= 100.
integer Tut_BatCargas= 3
boolean Tut_BatDrena= false
integer Tut_BatPasoN= -2
effect Tut_LuzFx= null
texttag Tut_MarcaT1= null
texttag Tut_MarcaT2= null
integer Tut_Anun= 0
integer Tut_Cuchi= 0
''')
s = once(s, 'call Racha_Registrar("Sound\\\\Interface\\\\BigButtonClick.wav")\n', '''call Racha_Registrar("Sound\\\\Interface\\\\BigButtonClick.wav")
    call Racha_Registrar("war3mapImported\\\\announcer_kill_triple_01.mp3")
    call Racha_Registrar("war3mapImported\\\\announcer_kill_spree_01.mp3")
''')
# Icono del cuchillo en el HUD del tutorial.
s = once(s, "    call Tut_Foto(Tut_ArmaIcono[4], 108., 54., 400., Cat_Tex[4])\n", """    call Tut_Foto(Tut_ArmaIcono[4], 108., 54., 400., Cat_Tex[4])
    set Tut_ArmaIcono[5] = Tut_Pieza('uidb')
    call Tut_Foto(Tut_ArmaIcono[5], 108., 54., 400., Cat_Tex[5])
    call ShowUnit(Tut_ArmaIcono[5], false)
""")
s = once(s, '    call RemoveUnit(Tut_ArmaIcono[4])\n', '''    call RemoveUnit(Tut_ArmaIcono[4])
    call RemoveUnit(Tut_ArmaIcono[5])
    // v16k: luz, batería, marcas de alcance y anuncios.
    if Tut_LuzFx != null then
        call DestroyEffect(Tut_LuzFx)
        set Tut_LuzFx = null
    endif
    if Tut_BatUI != 0 then
        call s__UIText_destroy(Tut_BatUI)
        set Tut_BatUI = 0
    endif
    if Tut_Anun != 0 then
        call s__UIText_destroy(Tut_Anun)
        set Tut_Anun = 0
    endif
    if Tut_MarcaT1 != null then
        call DestroyTextTag(Tut_MarcaT1)
        set Tut_MarcaT1 = null
    endif
    if Tut_MarcaT2 != null then
        call DestroyTextTag(Tut_MarcaT2)
        set Tut_MarcaT2 = null
    endif
''')

bateria = j('Batería ')
s = once(s, 'function Tut_Guion takes nothing returns nothing\n', f'''// v16k: teclas de la consola otra vez (se quitaron al abrir la tienda).
function Tut_TeclasCrear takes nothing returns nothing
    local integer i= 0
    loop
        exitwhen i > 11
        if Tut_Tecla[i] == 0 then
            set Tut_Tecla[i] = s__UIText_create(0., 0., 1.)
            call SetTextTagPermanent(s__UIText_text[Tut_Tecla[i]], true)
            call SetTextTagColor(s__UIText_text[Tut_Tecla[i]], 255, 204, 0, 255)
            call SetTextTagText(s__UIText_text[Tut_Tecla[i]], SubString("QWERAFGDZXCV", i, i + 1), 0.018)
            call s__UIText_show(Tut_Tecla[i], false, Tut_Cam)
        endif
        set i = i + 1
    endloop
endfunction

// v16k: la réplica de la tienda ya no se usa tras cerrarla; libera sus piezas y texttags.
function Tut_TiendaQuitar takes nothing returns nothing
    local integer k= 0
    set Tut_TiendaOn = false
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
endfunction

// v16k: anuncio centrado de n caracteres visibles a la altura py.
function Tut_Anuncio takes string a,integer n,real py returns integer
    local integer ui= s__UIText_create(0., 0., 1.)
    call SetTextTagPermanent(s__UIText_text[ui], true)
    call SetTextTagColor(s__UIText_text[ui], 255, 255, 255, 255)
    call s__UIText_setPosition(ui, ( - I2R(n) * 4.5 * 0.030 / 0.017 ) / 728., ( 420. - py ) / 390.)
    call SetTextTagText(s__UIText_text[ui], a, 0.030)
    call s__UIText_show(ui, true, Tut_Cam)
    return ui
endfunction

function Tut_AnuncioCambiar takes string a,integer n,real py returns nothing
    call s__UIText_setPosition(Tut_Anun, ( - I2R(n) * 4.5 * 0.030 / 0.017 ) / 728., ( 420. - py ) / 390.)
    call SetTextTagText(s__UIText_text[Tut_Anun], a, 0.030)
endfunction

function Tut_AnuncioQuitar takes nothing returns nothing
    if Tut_Anun != 0 then
        call s__UIText_destroy(Tut_Anun)
        set Tut_Anun = 0
    endif
endfunction

// v16k: marca de alcance en el suelo (texttag del mundo, para todos).
function Tut_Marcar takes string a,real x,real y returns texttag
    local texttag t= CreateTextTag()
    call SetTextTagText(t, a, 0.022)
    call SetTextTagPos(t, x - 30., y, 16.)
    call SetTextTagPermanent(t, true)
    call SetTextTagVisibility(t, true)
    return t
endfunction

// v16k: batería y linterna del tutorial (como Luz_NivelDe y Bat_Paso, con su propio estado).
function Tut_BatPaso takes nothing returns nothing
    local integer n
    if Tut_BatUI == 0 then
        return
    endif
    if Tut_BatDrena then
        if Tut_BatT > 12. then
            set Tut_BatT = RMaxBJ(0., Tut_BatT - 0.02 * 30.)
        else
            set Tut_BatT = RMaxBJ(0., Tut_BatT - 0.02 * 4.)
        endif
    endif
    if Tut_BatT <= 0. then
        set n = - 1
    elseif Tut_BatT > 10. then
        set n = 5
    else
        set n = IMinBJ(4, R2I(Tut_BatT / 2.))
    endif
    call SetTextTagText(s__UIText_text[Tut_BatUI], "{bateria}" + I2S(IMinBJ(100, R2I(Tut_BatT + 0.999))) + "%   Recargas (G): " + I2S(Tut_BatCargas), 0.016)
    if n != Tut_BatPasoN then
        set Tut_BatPasoN = n
        if Tut_LuzFx != null then
            call DestroyEffect(Tut_LuzFx)
            set Tut_LuzFx = null
        endif
        if n >= 0 then
            set Tut_LuzFx = AddSpecialEffectTarget("war3mapImported\\\\BatLuz" + I2S(n) + ".mdx", Tut_Tauren, "origin")
        endif
    endif
endfunction

function Tut_Guion takes nothing returns nothing
''')
s = once(s, '''    call Tut_CentroPaso()
''', '''    call Tut_CentroPaso()
    call Tut_BatPaso()
''')

clic = 'call Racha_Sonar("Sound\\\\Interface\\\\MouseClick1.wav")'
boton = 'call Racha_Sonar("Sound\\\\Interface\\\\BigButtonClick.wav")'
I = 'Tut_P * 7'
fases = [
    # --- Tiers ---
    f'''call Tut_TiendaQuitar()
call Tut_Mover(2, 420., 0., 0.5)
set Tut_FaseT = Tut_T
call Tut_Ir(Tut_X, Tut_Y)
set Tut_Sig = Tut_T + 0.6''',
    f'''call ShowUnit(Tut_Foco, false)
if not IsUnitInRangeXY(Tut_Tauren, Tut_X, Tut_Y, 60.) and Tut_T < Tut_FaseT + 6. then
    set Tut_Sig = Tut_T + 0.1
    return
endif
call SetUnitFacingTimed(Tut_Tauren, 0., 0.3)
{boton}
{decir("En la tienda compraste la", "Winchester: tier 2 de escopetas.", "Mira la diferencia con la básica.", 0.3)}''',
    f'''set Arm_Tier[{I} + 4] = 1
set Arm_Clip[{I} + 4] = Arm_Mag[24]
set Arm_Rva[{I} + 4] = Arm_Res[24]
call Arm_Elegir(Tut_P, 4)
call Arm_Pareja(Tut_P)
set Tut_MarcaT1 = Tut_Marcar("|cffffcc00T1: 400|r", Tut_X + 400., Tut_Y + 80.)
call Tut_Disparo(1)
{decir("Trabuco, tier 1: alcance 400,", "5 perdigones y cargador de 6.", "", 0.8)}''',
    f'''set Arm_Tier[{I} + 4] = 2
set Arm_Clip[{I} + 4] = Arm_Mag[25]
set Arm_Rva[{I} + 4] = Arm_Res[25]
call Arm_Pareja(Tut_P)
set Tut_MarcaT2 = Tut_Marcar("|cff7fd4ffT2: 450|r", Tut_X + 450., Tut_Y - 80.)
call Tut_Disparo(1)
{decir("Winchester, tier 2: llega a 450,", "6 perdigones, más daño y", "cargador de 8.", 0.8)}''',
    f'''call Tut_Disparo(1)
{decir("Cada tier mejora el arma: alcance,", "daño, cadencia o balas.", "¡Ve mejorando tus armas!", 0.6)}''',
    f'''call DestroyTextTag(Tut_MarcaT1)
call DestroyTextTag(Tut_MarcaT2)
set Tut_MarcaT1 = null
set Tut_MarcaT2 = null
set Tut_Sig = Tut_T + 0.4''',
    # --- Rachas ---
    f'''call Tut_Enemigo('nmcf', Tut_X + 950., Tut_Y - 100., 45.)
call Tut_Destino(Tut_NEnem - 1, Tut_X + 330., Tut_Y - 100.)
call Tut_Enemigo('nmcf', Tut_X + 1000., Tut_Y, 45.)
call Tut_Destino(Tut_NEnem - 1, Tut_X + 360., Tut_Y)
call Tut_Enemigo('nmcf', Tut_X + 950., Tut_Y + 100., 45.)
call Tut_Destino(Tut_NEnem - 1, Tut_X + 330., Tut_Y + 100.)
set Tut_FaseT = Tut_T
{boton}
{decir("Ahora, las rachas: cuantos más", "enemigos tumbas sin caer, más", "sube tu racha.", 0.2)}''',
    f'''if Tut_T < Tut_FaseT + 6. and not IsUnitInRange(Tut_Enem[Tut_NEnem - 2], Tut_Tauren, 420.) then
    set Tut_Sig = Tut_T + 0.1
    return
endif
call Tut_DispararA(Tut_Enem[Tut_NEnem - 2])
set Tut_Sig = Tut_T + 0.5''',
    f'''call Tut_DispararA(Tut_Enem[Tut_NEnem - 3])
set Tut_Sig = Tut_T + 0.5''',
    f'''call Tut_DispararA(Tut_Enem[Tut_NEnem - 1])
set Tut_Sig = Tut_T + 0.6''',
    f'''if GetWidgetLife(Tut_Enem[Tut_NEnem - 1]) > 0.405 then
    call KillUnit(Tut_Enem[Tut_NEnem - 1])
endif
if GetWidgetLife(Tut_Enem[Tut_NEnem - 2]) > 0.405 then
    call KillUnit(Tut_Enem[Tut_NEnem - 2])
endif
if GetWidgetLife(Tut_Enem[Tut_NEnem - 3]) > 0.405 then
    call KillUnit(Tut_Enem[Tut_NEnem - 3])
endif
call Racha_Sonar("war3mapImported\\\\announcer_kill_triple_01.mp3")
set Tut_Anun = Tut_Anuncio("|cff66ccffTriple Kill|r (3)", 15, 190.)
set Tut_Sig = Tut_T + 2.2''',
    decir("Varias bajas seguidas son un", "multikill: Double, Triple Kill...", "", 0.4),
    f'''call Racha_Sonar("war3mapImported\\\\announcer_kill_spree_01.mp3")
call Tut_AnuncioCambiar("|cffffff00Killing Spree|r (25)", 18, 190.)
{decir("Cada 25 bajas sin caer subes de", "racha: Killing Spree, Dominating,", "Mega Kill...", 0.4)}''',
    decir("En multijugador, compite por", "quién hace más bajas sin morir", "y mantiene la racha.", 1.0),
    '''call Tut_AnuncioQuitar()
set Tut_Sig = Tut_T + 0.3''',
    # --- Vidas ---
    f'''{boton}
{decir("Cuida tu vida: si llega a cero,", "caes y pierdes una de tus vidas.", "", 0.3)}''',
    f'''call SetUnitAnimation(Tut_Tauren, "death")
call SetUnitAnimationByIndex(Tut_Vida, 0)
call SetTextTagText(s__UIText_text[Tut_VidaUI], "0%", 0.017)
set Tut_Anun = Tut_Anuncio("|cffff6666Vidas: 0|r", 8, 190.)
set Tut_Sig = Tut_T + 1.6''',
    f'''call SetUnitTimeScale(Tut_Tauren, 0.)
{decir("Sin vidas no reapareces: esperas", "a que alguien supere la oleada.", "Al caer, también pierdes la racha.", 0.8)}''',
    f'''call Tut_AnuncioCambiar("|cff66ff66Oleada superada|r", 15, 190.)
call DestroyEffect(AddSpecialEffectTarget("Abilities\\\\Spells\\\\Human\\\\Resurrect\\\\ResurrectTarget.mdl", Tut_Tauren, "origin"))
call SetUnitTimeScale(Tut_Tauren, 1.)
call SetUnitAnimation(Tut_Tauren, "stand")
call SetUnitAnimationByIndex(Tut_Vida, 100)
call SetTextTagText(s__UIText_text[Tut_VidaUI], "100%", 0.017)
call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenReady1.wav")
{decir("Superada la oleada, vuelves. En la", "tienda puedes comprar más vidas.", "", 0.6)}''',
    '''call Tut_AnuncioQuitar()
set Tut_Sig = Tut_T + 0.3''',
    # --- Luz ---
    '''call Pres_Black(0, 255, 0.5)
set Tut_Sig = Tut_T + 0.6''',
    f'''call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 0.)
call Pres_Black(255, 0, 0.8)
{decir("En algunos mapas es de noche y", "apenas se ve a los enemigos.", "", 0.4)}''',
    f'''set Tut_BatT = 100.
set Tut_BatCargas = 3
set Tut_BatPasoN = - 2
set Tut_BatDrena = false
set Tut_BatUI = s__UIText_create(( 150. - 960. ) / 728., ( 420. - 252. ) / 390., 1.)
call SetTextTagPermanent(s__UIText_text[Tut_BatUI], true)
call SetTextTagColor(s__UIText_text[Tut_BatUI], 255, 230, 140, 255)
call s__UIText_show(Tut_BatUI, true, Tut_Cam)
call Tut_BatPaso()
{boton}
{decir("Tu linterna ilumina alrededor", "del personaje y te deja verlos.", "", 0.6)}''',
    f'''set Tut_FocoD = 398.
call Tut_Poner(1, 300., 262., 0.)
call Tut_Poner(2, 420., 0., 0.)
call Tut_Mover(2, 140., 1., 0.7)
call ShowUnit(Tut_Foco, true)
{decir("Durante la oleada gasta batería.", "Aquí ves cuánta queda y tus", "recargas.", 0.3)}''',
    f'''set Tut_BatDrena = true
{decir("Si se agota, la luz se apaga", "poco a poco.", "", 0.3)}''',
    '''if Tut_BatT > 0. then
    set Tut_Sig = Tut_T + 0.1
    return
endif
set Tut_BatDrena = false
call Tut_Mover(2, 420., 0., 0.5)
set Tut_Sig = Tut_T + 0.8''',
    f'''call ShowUnit(Tut_Foco, false)
set Tut_FocoD = 430.
call Tut_TeclasCrear()
set Tut_GModo = 1
set Tut_GIni = Tut_T
{boton}
{decir("Con G recargas la batería. Cada", "descanso te da 2 recargas más.", "", 0.2)}''',
    f'''call Tut_Centro(6, 'DS1H', "{j('Recargar batería (G)')}")
set Tut_Sig = Tut_T + 2.9''',
    f'''{clic}
set Tut_IconoS = 0.86
set Tut_BatT = 100.
set Tut_BatCargas = 2
set Tut_Sig = Tut_T + 0.3''',
    f'''set Tut_IconoS = 1.
call ShowUnit(Tut_Mano, false)
call Tut_CentroVolver()
call ShowUnit(Tut_Foco, false)
call Racha_Sonar("Units\\\\Orc\\\\Tauren\\\\TaurenYes3.wav")
{decir("¡Luz de nuevo! Aprovéchala en", "las noches más largas.", "", 0.6)}''',
    '''set Tut_GModo = 3
set Tut_GIni = Tut_T
call Pres_Black(0, 255, 0.5)
set Tut_Sig = Tut_T + 0.6''',
    '''call SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12.)
if Tut_LuzFx != null then
    call DestroyEffect(Tut_LuzFx)
    set Tut_LuzFx = null
endif
call s__UIText_destroy(Tut_BatUI)
set Tut_BatUI = 0
call Pres_Black(255, 0, 0.6)
set Tut_Sig = Tut_T + 0.8''',
    # --- Cuchillo ---
    f'''call Arm_Elegir(Tut_P, 1)
set Arm_Clip[{I} + 1] = 0
set Arm_Rva[{I} + 1] = 0
set Arm_Clip[{I} + 4] = 0
set Arm_Rva[{I} + 4] = 0
{boton}
{decir("¿Sin balas y sin cajas cerca?", "Aún te queda el cuchillo.", "", 0.3)}''',
    '''call Tut_TeclasCrear()
set Tut_GModo = 1
set Tut_GIni = Tut_T
set Tut_Sig = Tut_T + 0.8''',
    '''call Tut_Centro(8, 'DS1M', "Cuchillo (Z)")
set Tut_Sig = Tut_T + 2.9''',
    f'''{clic}
set Tut_IconoS = 0.86
set Arm_Tier[{I} + 5] = IMaxBJ(1, Arm_Tier[{I} + 5])
call Arm_Elegir(Tut_P, 5)
set Tut_Sig = Tut_T + 0.3''',
    f'''set Tut_IconoS = 1.
call ShowUnit(Tut_Mano, false)
call Tut_CentroVolver()
{decir("No gasta balas, pero su alcance", "es muy corto: tienes que", "acercarte mucho al enemigo.", 0.3)}''',
    '''set Tut_GModo = 3
set Tut_GIni = Tut_T
call Tut_Enemigo('nmcf', Tut_X + 800., Tut_Y, 45.)
set Tut_Cuchi = Tut_NEnem - 1
call Tut_Destino(Tut_Cuchi, Tut_X + 260., Tut_Y)
set Tut_FaseT = Tut_T
set Tut_Sig = Tut_T + 0.3''',
    '''if not IsUnitInRange(Tut_Tauren, Tut_Enem[Tut_Cuchi], 170.) and Tut_T < Tut_FaseT + 7. then
    call Tut_Ir(GetUnitX(Tut_Enem[Tut_Cuchi]) - 110., GetUnitY(Tut_Enem[Tut_Cuchi]))
    set Tut_Sig = Tut_T + 0.25
    return
endif
call Tut_DispararA(Tut_Enem[Tut_Cuchi])
set Tut_Sig = Tut_T + 0.55''',
    '''call Tut_DispararA(Tut_Enem[Tut_Cuchi])
set Tut_Sig = Tut_T + 0.55''',
    f'''if GetWidgetLife(Tut_Enem[Tut_Cuchi]) > 0.405 then
    call Tut_DispararA(Tut_Enem[Tut_Cuchi])
endif
set Tut_Sig = Tut_T + 0.5''',
    f'''if GetWidgetLife(Tut_Enem[Tut_Cuchi]) > 0.405 then
    call KillUnit(Tut_Enem[Tut_Cuchi])
endif
call Arm_Elegir(Tut_P, 1)
{decir("Úsalo sólo en apuros: tan cerca,", "los enemigos también te golpean.", "", 0.6)}''',
]

base = 89
nuevo = base + len(fases)
# La despedida y el final pasan detrás de las escenas nuevas.
for k in (91, 90, 89):
    s = once(s, f'''    elseif Tut_Fase == {k} then
        call Tut_Nota("fase {k} " + R2S(Tut_T))
''', f'''    elseif Tut_Fase == {k + len(fases)} then
        call Tut_Nota("fase {k + len(fases)} " + R2S(Tut_T))
''')
bloques = []
for n, cuerpo in enumerate(fases):
    f = base + n
    lineas = '\n'.join('        ' + l for l in cuerpo.split('\n'))
    bloques.append(f'    elseif Tut_Fase == {f} then\n        call Tut_Nota("fase {f} " + R2S(Tut_T))\n{lineas}\n')
s = once(s, f'    elseif Tut_Fase == {nuevo} then\n', ''.join(bloques) + f'    elseif Tut_Fase == {nuevo} then\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
print('v16k ok', len(fases), 'fases nuevas; despedida en', nuevo)
