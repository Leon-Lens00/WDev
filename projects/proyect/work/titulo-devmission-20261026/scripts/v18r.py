#!/usr/bin/env python3
"""v18r (15/11/2026): la muestra de la Mutación Evo como cuadro de interfaz central (Leon).

- Leon: los ganadores de la votación se dibujan con piezas de interfaz al centro, como el cuadro de puntuación; la
  cámara se queda en el héroe (en v18q la muestra abría la tienda y llevaba la cámara a la escena de cuadros).
- Cuadro: título «Mutación Evo» y 3 cuadros carmesí ('DS01', el fondo de los cuadros de la tienda) con el icono y el
  nombre de cada ganador (jefe, élite, comunes, de izquierda a derecha). Piezas 'uidb' como Punt_Pieza, colocadas cada
  tick delante de la cámara de cada jugador; entra desde arriba en 0,5 s y sale hacia abajo en los últimos 0,5 s.
- Contador: el HUD de la ronda pone «Oleada en» con 8..1, parpadeo rojo y tic cada segundo (Ronda_Fase 3, de v18q).
- 4 texttags locales más por jugador (título y 3 nombres).
Prueba/lan: registros v18q -> v18r.  Uso: v18r.py ENTRADA.j SALIDA.j [prueba|lan]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


DUR = 8.  # igual que la cuenta de la muestra
cambia('real Punt_Sale = 0.\n', 'real Punt_Sale = 0.\n'
       'unit array Mut_Bg\nunit array Mut_Ico\ninteger array Mut_TT\nboolean array Mut_Ok\ninteger array Mut_Visto\n'
       'integer Mut_Ver = 0\nreal Mut_T = -1.\n')

# 1. Piezas y textos del cuadro; HUD por jugador; reloj del cuadro en el tick común.
MUT = f'''// v18r: cuadro central de la Mutación Evo (como el de puntuación): 3 fondos 'DS01' carmesí, 3 iconos y 4 textos
// locales (título y nombres) del jugador p.
function Mut_HudCrear takes integer p returns nothing
    local integer k = 0
    local integer a = 0
    if GetLocalPlayer() == Player(p) then
        set a = 255
    endif
    loop
        exitwhen k > 2
        set Mut_Bg[p * 3 + k] = Punt_Pieza(p, 230. * 412. / 400., 300. * 412. / 400., 'DS01')
        call SetUnitVertexColor(Mut_Bg[p * 3 + k], 225, 45, 70, a)
        set Mut_Ico[p * 3 + k] = Punt_Pieza(p, 128. * 398. / 400., 128. * 398. / 400., 'DC00')
        set k = k + 1
    endloop
    set k = 0
    loop
        exitwhen k > 3
        set Mut_TT[p * 4 + k] = s__UIText_createEx(Player(p), 0., 0., 1.)
        call SetTextTagPermanent(s__UIText_text[Mut_TT[p * 4 + k]], true)
        call JefeTx_Color(Mut_TT[p * 4 + k], s__UIText_text[Mut_TT[p * 4 + k]], 245, 235, 238)
        set k = k + 1
    endloop
    call JefeTx_Color(Mut_TT[p * 4], s__UIText_text[Mut_TT[p * 4]], 255, 80, 100)
    set Mut_Visto[p] = 0
    set Mut_Ok[p] = true
endfunction

// Igual en todos los clientes, desde el tick del HUD (0,01 s).
function Mut_Tick takes nothing returns nothing
    if Mut_T >= 0. then
        set Mut_T = Mut_T + 0.01
    endif
endfunction

function Mut_Hud takes integer p, integer cam returns nothing
    local boolean shown
    local boolean txt
    local integer k = 0
    local real dy = 0.
    local real a
    local real cx
    local string s
    if not Mut_Ok[p] then
        return
    endif
    set shown = Mut_T >= 0. and HealthBars__Visible and Game_On[p] and not Shop_Open[p]
    if shown and Mut_Visto[p] != Mut_Ver then
        set Mut_Visto[p] = Mut_Ver
        call JefeTx_Texto(Mut_TT[p * 4], s__UIText_text[Mut_TT[p * 4]], "Mutación Evo", 0.03)
        loop
            exitwhen k > 2
            call Arm_Foto(Mut_Ico[p * 3 + k], 128. * 398. / 400., 128. * 398. / 400., Cua_Tex[Cua_Gana[k]])
            call JefeTx_Texto(Mut_TT[p * 4 + 1 + k], s__UIText_text[Mut_TT[p * 4 + 1 + k]], Cua_Nom[Cua_Gana[k]], 0.02)
            set k = k + 1
        endloop
        set k = 0
    endif
    // Entra desde arriba en 0,5 s (frenando) y sale hacia abajo en los últimos 0,5 s (acelerando).
    if Mut_T < 0.5 then
        set a = RMaxBJ(0., 1. - Mut_T / 0.5)
        set dy = -640. * a * a * a
    elseif Mut_T > {DUR - 0.5} then
        set a = RMinBJ(1., (Mut_T - {DUR - 0.5}) / 0.5)
        set dy = 960. * a * a
    endif
    set txt = shown and dy > -300. and dy < 300.
    loop
        exitwhen k > 2
        call Hud_Ver(Mut_Bg[p * 3 + k], shown)
        call Hud_Ver(Mut_Ico[p * 3 + k], shown)
        call s__UIText_show(Mut_TT[p * 4 + 1 + k], txt, cam)
        set k = k + 1
    endloop
    call s__UIText_show(Mut_TT[p * 4], txt, cam)
    if not shown then
        return
    endif
    set k = 0
    loop
        exitwhen k > 2
        set cx = 960. + 260. * (k - 1)
        call HealthBars__Place(Mut_Bg[p * 3 + k], cam, cx, 420. + dy, 412.)
        call HealthBars__Place(Mut_Ico[p * 3 + k], cam, cx, 385. + dy, 398.)
        set s = Cua_Nom[Cua_Gana[k]]
        call Punt_Pos(Mut_TT[p * 4 + 1 + k], cx - StringLength(s) * 0.02 * 235., 505. + dy, 0.02)
        set k = k + 1
    endloop
    call Punt_Pos(Mut_TT[p * 4], 960. - 12. * 0.03 * 235., 245. + dy, 0.03)
endfunction

'''
cambia('// Fondos (\'DSC0\' desde v18c, dorado o violeta) y 5 textos locales por jugador; los iconos, en Sup_Pintar.\n',
       MUT + '// Fondos (\'DSC0\' desde v18c, dorado o violeta) y 5 textos locales por jugador; los iconos, en Sup_Pintar.\n')
cambia('    call Sup_HudCrear(p)\n    call Punt_HudCrear(p)\n', '    call Sup_HudCrear(p)\n    call Punt_HudCrear(p)\n    call Mut_HudCrear(p)\n')
cambia('    call Punt_Tick()\n    loop\n', '    call Punt_Tick()\n    call Mut_Tick()\n    loop\n')
cambia('            call Punt_Hud(p , cam)\n', '            call Punt_Hud(p , cam)\n            call Mut_Hud(p , cam)\n')

# 2. La muestra ya no abre la tienda ni mueve la cámara: sólo el cuadro central.
cambia('''        if Game_On[p] then
            // v18q: con Shop_Open la cámara del héroe se detiene y el HUD del mundo se oculta, como en la tienda.
            if not Shop_Open[p] then
                set Shop_Open[p] = true
                set Shop_Abiertos = Shop_Abiertos + 1
            endif
            set Cua_Open[p] = true
            set Cua_Modo[p] = 2
            call Cua_Pintar(p)
            if GetLocalPlayer() == Player(p) then
                call ResetToGameCamera(0)
                call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
                call ClearSelection()
            endif
            call Shop_Camara(p)
            call Cua_Mostrar(p, true)
        endif
        set p = p + 1
    endloop
''', '''        set p = p + 1
    endloop
    // v18r: cuadro central de interfaz (Mut_Hud); la cámara sigue en el héroe.
    set Mut_Ver = Mut_Ver + 1
    set Mut_T = 0.
''')
cambia('''    set Cua_MuestraOn = false
    set Ronda_Fase = 0
    set Ronda_Resta = 0
''', '''    set Cua_MuestraOn = false
    set Ronda_Fase = 0
    set Ronda_Resta = 0
    set Mut_T = -1.
''')

# 3. HUD de la ronda durante la muestra.
cambia('''        elseif Ronda_Descanso and Ronda_Fase == 2 then
            set t="Resultados"
''', '''        elseif Ronda_Descanso and Ronda_Fase == 3 then
            set t="Oleada en"
            set c=I2S(Ronda_Resta)
        elseif Ronda_Descanso and Ronda_Fase == 2 then
            set t="Resultados"
''')

if modo in ('prueba', 'lan'):
    viejo = '-v18q-' if modo == 'lan' else 'lat\\\\v18q-'
    assert src.count(viejo) == 4, src.count(viejo)
    src = src.replace(viejo, viejo.replace('v18q', 'v18r'))
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18r', modo or 'normal')
