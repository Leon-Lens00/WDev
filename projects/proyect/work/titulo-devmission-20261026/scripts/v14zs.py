#!/usr/bin/env python3
"""v14zs (07/11/2026), con lo pedido por Leon tras v14zr:
- «Wave N» y su cifra pasan de arriba al centro a la derecha de la barra de vida (x 345, alineados a la izquierda,
  y 70 y 98); en el descanso dice «Tiempo de compra» en lugar de «Descanso».
- Las tarjetas de rachas suben y caben hasta 4 en 2 filas de 2, entre el texto de la oleada y el marcador: tarjeta de
  410 × 56 px, columnas con centro en x 705 y 1125, filas con centro en y 76 y 138 (Racha_Y 76).
  Cada tarjeta nueva ocupa el primer hueco (arriba izquierda, arriba derecha, abajo izquierda, abajo derecha); con los 4
  ocupados sale la más vieja y la nueva entra en su hueco cuando aquélla ya subió. Baja desde arriba y, a los 5 s, sube
  hasta salir; las de la fila de abajo pasan por detrás de las de arriba. Grupo de 5 tarjetas (4 quietas y una que sale).
- Habla sólo la tarjeta más nueva del jugador cuya voz suena.
Uso: v14zs.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
N = base.N if hasattr(base, 'N') else '\r\n'


def u(x):
    return x.encode('utf-8').decode('latin-1')


def once(s, old, new):
    return base.once(s, u(old), u(new))


def funcion(s, nombre, nuevo):
    """Sustituye la función entera (de «function NOMBRE takes» a su endfunction)."""
    a = s.index(N + 'function %s takes' % nombre) + len(N)
    assert s.count(N + 'function %s takes' % nombre) == 1, nombre
    b = s.index(N + 'endfunction' + N, a) + len(N + 'endfunction')
    return s[:a] + u(nuevo.strip('\n')).replace('\n', N) + s[b:]


# Oleada a la derecha de la barra de vida.
s = once(s, 'constant real Ronda_TITULO_Y = 58.\n', 'constant real Ronda_TITULO_Y = 70.\n')
s = once(s, 'constant real Ronda_CIFRA_Y = 84.\n', 'constant real Ronda_CIFRA_Y = 98.\n')
s = funcion(s, 'Ronda_Texto', '''
function Ronda_Texto takes integer ui,string s,real size,real y returns nothing
    call s__UIText_setPosition(ui,( 345. - 960. ) / 728. , ( 420. - y ) / 390.)
    call SetTextTagText(s__UIText_text[ui], s, size)
endfunction
''')
s = once(s, '            set t="Descanso"\n', '            set t="Tiempo de compra"\n')

# Tarjetas: hueco y orden.
s = once(s, 'real Racha_Y= 150.\n', 'real Racha_Y= 76.\ninteger array Racha_CHueco\ninteger array Racha_CSeq\ninteger Racha_Seq= 0\n')

s = funcion(s, 'Racha_Anunciar', '''
function Racha_Anunciar takes string texto,integer p returns nothing
    local integer k= 0
    local integer n= -1
    local integer h= 0
    local integer v= -1
    local boolean array lleno
    // Huecos ocupados por tarjetas que se quedan; la más vieja de ellas por si no hay hueco.
    loop
        exitwhen k > 4
        if Racha_CActiva[k] and not Racha_CSale[k] then
            set lleno[Racha_CHueco[k]] = true
            if v < 0 or Racha_CSeq[k] < Racha_CSeq[v] then
                set v = k
            endif
        endif
        set k = k + 1
    endloop
    loop
        exitwhen h > 3 or not lleno[h]
        set h = h + 1
    endloop
    if h > 3 then
        set Racha_CSale[v] = true
        set h = Racha_CHueco[v]
    endif
    set k = 0
    loop
        exitwhen k > 4
        if not Racha_CActiva[k] and n < 0 then
            set n = k
        endif
        set k = k + 1
    endloop
    if n < 0 then
        // Todas activas: se reusa la que sale y ya subió más.
        set k = 0
        loop
            exitwhen k > 4
            if Racha_CSale[k] and ( n < 0 or Racha_CY[k] < Racha_CY[n] ) then
                set n = k
            endif
            set k = k + 1
        endloop
    endif
    set Racha_Seq = Racha_Seq + 1
    set Racha_CSeq[n] = Racha_Seq
    set Racha_CHueco[n] = h
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
''')

s = funcion(s, 'Racha_VozDe', '''
function Racha_VozDe takes integer p returns nothing
    local integer i
    local integer k= 0
    local integer n= -1
    if Racha_EsCairne(p) then
        set i = 10 + GetRandomInt(0, 4)
    else
        set i = GetRandomInt(0, 3)
    endif
    call Racha_Sonar(Racha_Voz[i])
    loop
        exitwhen k > 4
        if Racha_CActiva[k] and not Racha_CSale[k] and Racha_CPid[k] == p and ( n < 0 or Racha_CSeq[k] > Racha_CSeq[n] ) then
            set n = k
        endif
        set k = k + 1
    endloop
    if n >= 0 then
        set Racha_CHabla[n] = Racha_VozLen[i]
    endif
endfunction
''')

s = once(s, '''    set i = 0
    loop
        exitwhen i > 1
        if Racha_CActiva[i] and not Racha_CSale[i] then
''', '''    set i = 0
    loop
        exitwhen i > 4
        if Racha_CActiva[i] and not Racha_CSale[i] then
''')

s = funcion(s, 'Racha_Mover', '''
function Racha_Mover takes nothing returns nothing
    local integer k= 0
    local integer j
    local boolean libre
    local real meta
    loop
        exitwhen k > 4
        if Racha_CActiva[k] then
            if Racha_CSale[k] then
                set meta = -90.
            else
                // Entra cuando la que salía de su mismo hueco ya no se ve.
                set libre = true
                set j = 0
                loop
                    exitwhen j > 4
                    if j != k and Racha_CActiva[j] and Racha_CSale[j] and Racha_CHueco[j] == Racha_CHueco[k] and Racha_CY[j] > -50. then
                        set libre = false
                    endif
                    set j = j + 1
                endloop
                set meta = -80.
                if libre then
                    set meta = Racha_Y + 62. * ( Racha_CHueco[k] / 2 )
                endif
            endif
            set Racha_CY[k] = Racha_CY[k] + ( meta - Racha_CY[k] ) * 0.2
            if Racha_CSale[k] and Racha_CY[k] < -72. then
                set Racha_CActiva[k] = false
            endif
        endif
        set k = k + 1
    endloop
endfunction
''')

s = funcion(s, 'Racha_Hud', '''
function Racha_Hud takes integer p,integer cam returns nothing
    local boolean shown= HealthBars__Visible and Game_On[p] and not Shop_Open[p]
    local boolean vis
    local integer k= 0
    local integer v
    local integer j
    local integer a
    local real y
    local real cx
    local real d
    local real e
    if not Racha_UIOk[p] then
        return
    endif
    loop
        exitwhen k > 4
        set v = p * 5 + k
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
            set cx = 705. + 420. * ModuloInteger(Racha_CHueco[k], 2)
            // La fila de abajo, un poco más lejos: al bajar o subir pasa por detrás de la de arriba.
            set d = 3. * ( Racha_CHueco[k] / 2 )
            if Racha_VVer[v] != Racha_CVer[k] then
                set Racha_VVer[v] = Racha_CVer[k]
                // Mostrar antes de elegir la animación: el cambio de visibilidad puede reiniciarla.
                call ShowUnit(Racha_Cara[v * 2 + 1 - j], false)
                call ShowUnit(Racha_Cara[v * 2 + j], true)
                // 44 px de alto; el retrato mide 21,4 de alto a escala 1 (Hero_PortraitScale).
                set e = 44. * ( 0.302 / 387.73819261 ) * ( 398. + d ) / 21.4 * Racha_AjS
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
            call HealthBars__Place(Racha_Caja[v] , cam , cx , y , 400. + d)
            call HealthBars__Place(Racha_Cara[v * 2 + j] , cam , cx + 177.8 + Racha_AjX , y + Racha_AjY , 398. + d)
            call s__UIText_setPosition(Racha_TT[v * 2],( cx - 28.4 - Racha_CAnchoN[k] - 960. ) / 728. , ( 420. - ( y - 17. + Racha_AjN ) ) / 390.)
            call s__UIText_setPosition(Racha_TT[v * 2 + 1],( cx - 28.4 - Racha_CAnchoL[k] - 960. ) / 728. , ( 420. - ( y + 8. + Racha_AjL ) ) / 390.)
            call s__UIText_show(Racha_TT[v * 2],true , cam)
            call s__UIText_show(Racha_TT[v * 2 + 1],true , cam)
        endif
        set k = k + 1
    endloop
    if shown != Racha_TablaVista[p] then
        set Racha_TablaVista[p] = shown
        if GetLocalPlayer() == Player(p) then
            call MultiboardDisplay(Racha_Tabla, shown)
            if shown then
                call MultiboardMinimize(Racha_Tabla, false)
            endif
        endif
    endif
endfunction
''')

old_alta = '''        loop
            exitwhen i > 1
            set Racha_Caja[p * 2 + i] = HealthBars__Dummy('uidb', p)
            call UnitAddAbility(Racha_Caja[p * 2 + i], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Caja[p * 2 + i], s__Interface_LOCUST_ID)
            call Racha_Foto(Racha_Caja[p * 2 + i] , 480. , 60. , 'DS18')
'''
new_alta = '''        loop
            exitwhen i > 4
            set Racha_Caja[p * 2 + i] = HealthBars__Dummy('uidb', p)
            call UnitAddAbility(Racha_Caja[p * 2 + i], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Caja[p * 2 + i], s__Interface_LOCUST_ID)
            call Racha_Foto(Racha_Caja[p * 2 + i] , 410. , 56. , 'DS18')
'''
a = s.index(old_alta.replace('\n', N))
b = s.index(N + '        set Racha_UIOk[p] = true' + N, a)
bloque = s[a:b].replace(old_alta.replace('\n', N), new_alta.replace('\n', N))
assert bloque.count('p * 2 + i') == 17, bloque.count('p * 2 + i')
s = s[:a] + bloque.replace('p * 2 + i', 'p * 5 + i') + s[b:]
assert s.count('p * 2 + i') == 0 and s.count("'DS18'") == 1
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
