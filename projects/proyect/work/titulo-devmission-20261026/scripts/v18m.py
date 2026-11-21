#!/usr/bin/env python3
"""v18m (15/11/2026): ajustes del cuadro de puntuación y fase 7 (tienda con apartados). Sobre el j de v18l.

Cuadro (Leon, tras la prueba de v18l):
- El recuento empieza al terminar el sonido de misión completada: QuestCompleted.wav dura 5,155 s (war3.mpq,
  22050 Hz estéreo) y suena a 0,25 s, así que Punt_Ini[1] pasa de 1 a 5,45 s (el resto se encadena igual).
- Precarga también de las texturas del cuadro (PuntCuadro, PuntEstrella, PuntEstrellaVacia) y del sonido de misión.
- Los textos y estrellas sólo se muestran cuando el centro del fondo ya está en pantalla (dy > -380): en v18l se
  veían un cuadro (~50 ms) antes que el fondo, que el juego no dibuja mientras su centro está fuera.

Fase 7, tienda con apartados (plan: "pantalla inicial con 2 cuadros (armas / habilidades especiales) bloqueados y
Mutación Evo en el centro (carmesí)"):
- Al abrir la tienda, pantalla "Tienda" con 3 cuadros del marco de v17s (Cua_Modo 0): Armas (azul), Mutación Evo
  (carmesí, centro) y Habilidades (verde). Armas y Habilidades están cerrados (gris) hasta terminar las 3 elecciones
  de Mutación Evo; un cuadro hecho también queda gris. Clic en uno cerrado: sonido de error.
- Mutación Evo y Habilidades abren sus pasos de siempre (Cua_Modo 1); al terminar su grupo vuelven a la pantalla de
  inicio. Armas abre la tienda de armas.
- Esc (y el botón Salir de la tienda de armas) vuelve a la pantalla de inicio; en la pantalla de inicio cierra.
- El aviso de elecciones pendientes queda en la descripción de cada cuadro ("Elige 2 mejoras de tu héroe (0/2)");
  el aviso fuera de la tienda se deja para la fase 9, cuando las elecciones se acumulen.
- Iconos DC0H-DC0J (objetos_v18m.py).
Uso: v18m.py ENTRADA.j SALIDA.j [prueba]
"""
import re
import sys
from pathlib import Path

# El j mezcla UTF-8 (textos del juego) con algún comentario en latin-1: se lee byte a byte como latin-1 y lo nuevo se
# convierte desde UTF-8 (U), sin tocar finales de línea (CRLF con algunos LF/CR sueltos).
src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'


def U(s):
    return s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    n = src.count(viejo)
    if n == 0:
        viejo, nuevo = viejo.replace('\n', '\r\n'), nuevo.replace('\n', '\r\n')
        n = src.count(viejo)
    assert n == veces, (n, viejo[:90])
    src = src.replace(viejo, nuevo)


def funcion(nombre, nueva):
    """Sustituye la función entera (de 'function NOMBRE takes' a su endfunction)."""
    global src
    m = re.search(r'function ' + nombre + r' takes .*?\r?\nendfunction\r?\n', src, re.S)
    assert m and src.count('function ' + nombre + ' takes') == 1, nombre
    eol = '\r\n' if m.group(0).endswith('\r\n') else '\n'
    src = src[:m.start()] + U(nueva).replace('\n', eol) + src[m.end():]


# ---- Cuadro de puntuación ----
cambia('    set Punt_Ini[1] = 1.\n',
       '    // v18m: el recuento empieza al acabar QuestCompleted.wav (5,155 s desde 0,25 s).\n'
       '    set Punt_Ini[1] = 5.45\n')
cambia('    call Preload("war3mapImported\\\\PuntEstrella2.wav")\n',
       '    call Preload("war3mapImported\\\\PuntEstrella2.wav")\n'
       '    call Preload("war3mapImported\\\\PuntCuadro.blp")\n'
       '    call Preload("war3mapImported\\\\PuntEstrella.blp")\n'
       '    call Preload("war3mapImported\\\\PuntEstrellaVacia.blp")\n'
       '    call Preload("Sound\\\\Interface\\\\QuestCompleted.wav")\n')
cambia('    local real dy = 0.\n    local real a\n    if not Punt_Ok[p] then\n',
       '    local real dy = 0.\n    local real a\n    local boolean txt\n    if not Punt_Ok[p] then\n')
cambia('    call Hud_Ver(Punt_Cuadro[p], shown)\n',
       '    // v18m: textos y estrellas cuando el centro del fondo ya está en pantalla.\n'
       '    set txt = shown and dy > -380.\n    call Hud_Ver(Punt_Cuadro[p], shown)\n')
cambia('call Hud_Ver(Punt_Est[p * 6 + k], shown and k < n)', 'call Hud_Ver(Punt_Est[p * 6 + k], txt and k < n)')
cambia('call Hud_Ver(Punt_Est[p * 6 + 3 + k], shown and k >= n)', 'call Hud_Ver(Punt_Est[p * 6 + 3 + k], txt and k >= n)')
cambia('call s__UIText_show(Punt_TT[p * 8 + k], shown, cam)', 'call s__UIText_show(Punt_TT[p * 8 + k], txt, cam)')

# ---- Fase 7: pantalla de inicio de la tienda ----
cambia('integer array Cua_Paso\n', 'integer array Cua_Paso\n// v18m: 0 pantalla de inicio de la tienda, 1 pasos de elección.\ninteger array Cua_Modo\n')
cambia('function Cua_Cuantos takes integer p returns integer\n',
       'function Cua_Cuantos takes integer p returns integer\n'
       '    if Cua_Modo[p] == 0 then\n        return 3\n    endif\n')
cambia('function Cua_Item takes integer p, integer c returns integer\n',
       'function Cua_Item takes integer p, integer c returns integer\n'
       '    if Cua_Modo[p] == 0 then\n        return 30 + c\n    endif\n')
cambia('    local integer n = Cua_Cuantos(p)\n    local integer c = 0\n    if Cua_Paso[p] >= 5 then\n        return\n    endif\n',
       '    local integer n = Cua_Cuantos(p)\n    local integer c = 0\n    if Cua_Paso[p] >= 5 and Cua_Modo[p] != 0 then\n'
       '        return\n    endif\n')

funcion('Cua_Ver', r'''// v18m: cuadro k de la pantalla de inicio (0 Armas, 1 Mutación Evo, 2 Habilidades) cerrado o ya hecho.
function Cua_InicioCerrado takes integer p, integer k returns boolean
    if k == 1 then
        return Cua_Paso[p] >= 3
    elseif k == 2 then
        return Cua_Paso[p] < 3 or Cua_Paso[p] >= 5
    endif
    return Cua_Paso[p] < 3
endfunction

// v18m: descripción de cada cuadro de la pantalla de inicio, con lo que falta por elegir.
function Cua_InicioDes takes integer p, integer k returns string
    if k == 1 then
        if Cua_Paso[p] < 3 then
            return "Elige 3 mejoras para|nlos enemigos (" + I2S(Cua_Paso[p]) + "/3)."
        endif
        return "|cff909090Hecho: entran en|nla próxima oleada.|r"
    endif
    if Cua_Paso[p] < 3 then
        return "|cff909090Se abre al terminar|nla Mutación Evo.|r"
    endif
    if k == 0 then
        return "Mejora tus armas|ny compra munición."
    elseif Cua_Paso[p] < 5 then
        return "Elige 2 mejoras de|ntu héroe (" + I2S(Cua_Paso[p] - 3) + "/2)."
    endif
    return "|cff909090Hecho: ya elegiste|nlas 2 mejoras.|r"
endfunction

// Lo que ve el cliente de p: alfa y tinte de fondos, botones e iconos; textos del paso o de la pantalla de inicio.
function Cua_Ver takes integer p returns nothing
    local integer n = Cua_Cuantos(p)
    local integer s = 0
    local integer c
    local integer a
    local integer r = 225
    local integer g = 45
    local integer b = 70
    local integer ic = 255
    local boolean inicio = Cua_Modo[p] == 0
    local boolean ver = Cua_Open[p] and (inicio or Cua_Paso[p] < 5)
    if Cua_Paso[p] >= 3 then
        set r = 70
        set g = 205
        set b = 95
    endif
    if GetLocalPlayer() != Player(p) then
        return
    endif
    loop
        exitwhen s > 8
        if Cua_SlotUsa[s] then
            set a = 0
            set ic = 255
            set c = s - (5 - n)
            if ver and c >= 0 and ModuloInteger(c, 2) == 0 and c / 2 < n then
                set a = 255
                if inicio then
                    set c = c / 2
                    if c == 0 then
                        set r = 60
                        set g = 120
                        set b = 215
                    elseif c == 1 then
                        set r = 200
                        set g = 30
                        set b = 50
                    else
                        set r = 70
                        set g = 205
                        set b = 95
                    endif
                    if Cua_InicioCerrado(p, c) then
                        set r = 70
                        set g = 70
                        set b = 80
                        set ic = 110
                    endif
                endif
            endif
            call SetUnitVertexColor(Cua_Bg[s], r, g, b, a)
            call SetUnitVertexColor(Cua_Bt[s], ic, ic, ic, a)
            call SetUnitVertexColor(Cua_Et[s], ic, ic, ic, a)
            call SetUnitVertexColor(Cua_Ico[p * 9 + s], ic, ic, ic, a)
        endif
        set s = s + 1
    endloop
    // v18g: el pie, textura 'DSEB'.
    set a = 0
    if ver then
        set a = 255
    endif
    call SetUnitVertexColor(Cua_PieP, 255, 255, 255, a)
    if Cua_TCab == null or not ver then
        return
    endif
    if inicio then
        call Cua_Centro(p, Cua_TCab, Cua_PasoNom[5], 960, 70, 0.03)
        call SetTextTagColor(Cua_TCab, 240, 238, 232, 255)
    else
        call Cua_Centro(p, Cua_TCab, Cua_PasoNom[Cua_Paso[p]], 960, 70, 0.03)
        if Cua_Paso[p] < 3 then
            call SetTextTagColor(Cua_TCab, 255, 80, 100, 255)
        else
            call SetTextTagColor(Cua_TCab, 120, 240, 140, 255)
        endif
    endif
    set c = 0
    loop
        exitwhen c > 4
        if c < n then
            set s = Cua_Slot(n, c)
            call Cua_Centro(p, Cua_TN[c], Cua_Nom[Cua_Item(p, c)], Cua_PX(s), 392, 0.025)
            if inicio then
                call Cua_Izq(p, Cua_TD[c], Cua_InicioDes(p, c), Cua_PX(s) - 150, 440, 0.021)
            else
                call Cua_Izq(p, Cua_TD[c], Cua_Des[Cua_Item(p, c)], Cua_PX(s) - 150, 440, 0.021)
            endif
            call SetTextTagVisibility(Cua_TN[c], true)
            call SetTextTagVisibility(Cua_TD[c], true)
        else
            call SetTextTagVisibility(Cua_TN[c], false)
            call SetTextTagVisibility(Cua_TD[c], false)
        endif
        set c = c + 1
    endloop
endfunction
''')

# Ir a la tienda de armas y clic en la pantalla de inicio (antes de Cua_Clic).
cambia('// Clic en el botón de la posición s (0-8). Sin efecto todavía: se avisa y se anota.\n',
       '''// v18m: de la pantalla de inicio a la tienda de armas.
function Cua_IrArmas takes integer p returns nothing
    set Cua_Open[p] = false
    call Cua_Mostrar(p, false)
    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
endfunction

// v18m: clic en un cuadro de la pantalla de inicio (posiciones 2, 4 y 6).
function Cua_InicioClic takes integer p, integer s returns nothing
    local integer c = s - 2
    if c < 0 or ModuloInteger(c, 2) != 0 or c / 2 > 2 then
        return
    endif
    set c = c / 2
    if Cua_InicioCerrado(p, c) then
        call UI_Error(p)
        return
    endif
    call UI_Click(p)
    if c == 0 then
        call Cua_IrArmas(p)
        return
    endif
    set Cua_Modo[p] = 1
    call Cua_Pintar(p)
    call Cua_Ver(p)
endfunction

// Clic en el botón de la posición s (0-8). Sin efecto todavía: se avisa y se anota.
''')
cambia('    local integer c = s - (5 - n)\n    local integer x\n',
       '    local integer c = s - (5 - n)\n    local integer x\n'
       '    if Cua_Modo[p] == 0 then\n        call Cua_InicioClic(p, s)\n        return\n    endif\n')
cambia('''    set Cua_Paso[p] = Cua_Paso[p] + 1
    if Cua_Paso[p] < 5 then
        call Cua_Pintar(p)
        call Cua_Ver(p)
        return
    endif
    // Último paso: se cierra la ventana y se abre la tienda (Shop_Open ya está activo).
    set Cua_Open[p] = false
    call Cua_Mostrar(p, false)
    call Shop_Camara(p)
    if GetLocalPlayer() == Player(p) then
        call Shop_Textos()
    endif
    call Shop_Mostrar(p, true)
    call Shop_Refrescar(p)
''', '''    set Cua_Paso[p] = Cua_Paso[p] + 1
    // v18m: al terminar Mutación Evo (paso 3) o las mejoras del héroe (paso 5) se vuelve a la pantalla de inicio.
    if Cua_Paso[p] == 3 or Cua_Paso[p] >= 5 then
        set Cua_Modo[p] = 0
    endif
    call Cua_Pintar(p)
    call Cua_Ver(p)
''')
# Abrir: siempre por la pantalla de inicio cuando ya hay sorteo.
cambia('''    if Cua_Listo and Cua_Paso[p] < 5 then
        set Cua_Open[p] = true
''', '''    if Cua_Listo then
        set Cua_Open[p] = true
        set Cua_Modo[p] = 0
        call Cua_Pintar(p)
''')
# Volver: Esc y Salir llevan a la pantalla de inicio; desde ella se cierra.
cambia('function Shop_Seleccion takes nothing returns nothing\n', '''// v18m: Esc o Salir. Desde la tienda de armas o un paso de elección, a la pantalla de inicio; desde ella, cerrar.
function Shop_Volver takes integer p returns nothing
    if not Cua_Listo or (Cua_Open[p] and Cua_Modo[p] == 0) then
        call Shop_Cerrar(p)
        return
    endif
    set Cua_Modo[p] = 0
    if Cua_Open[p] then
        call Cua_Pintar(p)
        call Cua_Ver(p)
        return
    endif
    call Shop_Mostrar(p, false)
    if GetLocalPlayer() == Player(p) then
        call Shop_TextosFuera()
        call ClearSelection()
    endif
    set Cua_Open[p] = true
    call Shop_Camara(p)
    call Cua_Pintar(p)
    call Cua_Mostrar(p, true)
endfunction

function Shop_Seleccion takes nothing returns nothing
''')
cambia('    if Shop_Open[p] then\n        call Shop_Cerrar(p)\n        return\n    endif\n    set z=Recarga_Cerca(p)\n',
       '    if Shop_Open[p] then\n        call Shop_Volver(p)\n        return\n    endif\n    set z=Recarga_Cerca(p)\n')
cambia('    else\n        call UI_Click(p)\n        call Shop_Cerrar(p)\n    endif\nendfunction\n',
       '    else\n        call UI_Click(p)\n        call Shop_Volver(p)\n    endif\nendfunction\n')
# Textos, iconos y posiciones de la pantalla de inicio.
cambia('    set Cua_PasoNom[0] = "Mutación Evo · jefe (1/3)"\n',
       '''    // v18m: pantalla de inicio de la tienda (fase 7).
    set Cua_Nom[30] = "Armas"
    set Cua_Tex[30] = 'DC0H'
    set Cua_Nom[31] = "Mutación Evo"
    set Cua_Tex[31] = 'DC0I'
    set Cua_Nom[32] = "Habilidades"
    set Cua_Tex[32] = 'DC0J'
    set Cua_PasoNom[5] = "Tienda"
    set Cua_PasoNom[0] = "Mutación Evo · jefe (1/3)"
''')
cambia('    set Title_CX = 4800.\n    set Menu_Ancla[2]',
       '''    // v18m: los 3 cuadros de la pantalla de inicio.
    set s = 0
    loop
        exitwhen s > 2
        set Cua_SlotUsa[Cua_Slot(3, s)] = true
        set s = s + 1
    endloop
    set Title_CX = 4800.
    set Menu_Ancla[2]''')

if prueba:
    n = src.count('lat\\\\v18l-')
    assert n == 4, n
    src = src.replace('lat\\\\v18l-', 'lat\\\\v18m-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18m', 'prueba' if prueba else 'normal')
