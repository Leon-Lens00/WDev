#!/usr/bin/env python3
"""v22l (23/11/2026): cuadro de resultados más ancho, lado del MVP reordenado, modelos con ángulo de la presentación del
jefe y cabezas de los personajes en el MVP.

Leon tras -tabla en v22k-prueba: "darle mas espacio?, ... mira la interfaz de presentacion del boss ... tomes de
referencia para ajustar un angulo de mirada ... el texto que sale dentro del cuadro mvp o de abajo no me parece que se
vea bien asi, dale una mejor arquitectura ... estan modelos sin cabeza".
- Tabla de 720 (PuntTabla de puntos_v22l.py; antes 600): mismo centro 805; nombres de 15 letras y puntos de 5-6 cifras
  caben. Columnas: nombre 479, bajas 707, élites 761, daño 815, bolsas 947, caídas 1007, puntos 1075. Cifras de abajo y
  estrellas a las casillas nuevas.
- Lado (PuntLado v22l, centro 1325; antes 1265): en cada cuadro, nombre arriba a lo ancho, modelo a la izquierda (x 1250)
  y a la derecha la cifra de puntos (0,032, sin "puntos": la etiqueta PUNTOS va en la textura) y debajo la recompensa.
- Modelos: los MvpFrente*.mdx pierden el Billboarded del hueso MvpFrente (mvp_sin_billboard.cjs) y se giran a 0 como el
  jefe de JefePres (antes 240, que no contaba con billboard); escala 0,27 a 0,22 (el modelo de lado ocupa la mitad).
- Cabezas: Mvp_Piezas ponía la cabeza SSJ con A069, que es la normal de Goku (NormalHeadGoku), y no tenía la de Goku
  dios (A0O8) ni las de Vegeta (A080/A081 SSJ2, A0JN Blue): Vegeta salía sin cabeza también en partida. Ahora cada
  habilidad con el arte de su objeto (war3map.w3a).
- Prueba (-tabla): sin héroe, las piezas salen del tipo: Goku cabeza normal, Trunks TrunkHead, Vegeta la de A080.
Uso: v22l.py ENTRADA.j SALIDA.j [prueba]   (normal de v22j; prueba de v22k-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


# 1) Piezas y medidas.
cambia("Punt_Pieza(p, 600. * 412. / 400., 470. * 412. / 400., 'DSP4')", "Punt_Pieza(p, 720. * 412. / 400., 470. * 412. / 400., 'DSP4')")
cambia('call HealthBars__Place(Punt_Lado[p], cam, 1265.0, 380.0 + dy, 412.)', 'call HealthBars__Place(Punt_Lado[p], cam, 1325.0, 380.0 + dy, 412.)')
cambia('constant real MVP_MOD_X = 1262.', 'constant real MVP_MOD_X = 1250.')
cambia('constant real MVP_MOD_GIRO = 240.', 'constant real MVP_MOD_GIRO = 0.')
cambia('constant real MVP_MOD_ESCALA = 0.27', 'constant real MVP_MOD_ESCALA = 0.22')
cambia('MVP_MOD_X, 358.0 + dy', 'MVP_MOD_X, 362.0 + dy')
cambia('MVP_MOD_X, 590.0 + dy', 'MVP_MOD_X, 594.0 + dy')
cambia('981.0 + 40. * k, 517 + dy', '1025.0 + 40. * k, 517 + dy', 2)

# 2) Columnas de la tabla (v22j) y textos del lado.
for k, (a, b) in enumerate([(717, 707), (771, 761), (825, 815), (931, 947), (989, 1007), (1047, 1075)]):
    cambia('call Punt_Pos(Punt_TT[p * 16%s], %d.0, a, 0.019)' % ('' if k == 0 else ' + %d' % k, a),
           'call Punt_Pos(Punt_TT[p * 16%s], %d.0, a, 0.019)' % ('' if k == 0 else ' + %d' % k, b))
cambia('call Punt_Pos(Punt_TT[p * 16 + 6], 539.0, a, 0.019)', 'call Punt_Pos(Punt_TT[p * 16 + 6], 479.0, a, 0.019)')
cambia('''    call Punt_Pos(Punt_TT[p * 16 + 10], 1139.0, 240.0 + dy, 0.030)
    call Punt_Pos(Punt_TT[p * 16 + 11], 1139.0, 300.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 12], 1139.0, 340.0 + dy, 0.014)
    call Punt_Pos(Punt_TT[p * 16 + 13], 1139.0, 472.0 + dy, 0.030)
    call Punt_Pos(Punt_TT[p * 16 + 14], 1139.0, 532.0 + dy, 0.019)
''', '''    // v22l: nombre arriba a lo ancho; cifra de puntos y recompensa a la derecha del modelo (etiqueta PUNTOS en PuntLado).
    call Punt_Pos(Punt_TT[p * 16 + 11], 1195.0, 205.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 10], 1320.0, 257.0 + dy, 0.032)
    call Punt_Pos(Punt_TT[p * 16 + 12], 1320.0, 334.0 + dy, 0.014)
    call Punt_Pos(Punt_TT[p * 16 + 14], 1195.0, 437.0 + dy, 0.019)
    call Punt_Pos(Punt_TT[p * 16 + 13], 1320.0, 489.0 + dy, 0.032)
''')
cambia('call Punt_PosC(Punt_TT[p * 16 + 7], v, 591.0, 563 + dy, 0.028)', 'call Punt_PosC(Punt_TT[p * 16 + 7], v, 548.0, 563 + dy, 0.028)')
cambia('call Punt_PosC(Punt_TT[p * 16 + 8], v, 735.0, 563 + dy, 0.028)', 'call Punt_PosC(Punt_TT[p * 16 + 8], v, 722.0, 563 + dy, 0.028)')
cambia('call Punt_PosC(Punt_TT[p * 16 + 9], v, 879.0, 538 + dy, 0.028)', 'call Punt_PosC(Punt_TT[p * 16 + 9], v, 894.0, 538 + dy, 0.028)')
cambia('" puntos|r"', '"|r"', 2)
cambia('set Mvp_Tam[7] = 0.030', 'set Mvp_Tam[7] = 0.032')
cambia('set Mvp_Tam[10] = 0.030', 'set Mvp_Tam[10] = 0.032')

# 3) Cabezas con el arte de cada habilidad.
cambia('''    set k = Mvp_Pieza(p, h, i, k, 'A069', "war3mapImported\\\\GokuHead_SS_squished.mdx", "head")
''', '''    // v22l: A069 es la cabeza normal (antes la SSJ); A0O8 dios; cabezas de Vegeta (A080/A081 SSJ2, A0JN Blue).
    set k = Mvp_Pieza(p, h, i, k, 'A069', "war3mapImported\\\\NormalHeadGoku.mdx", "head")
    set k = Mvp_Pieza(p, h, i, k, 'A0O8', "war3mapImported\\\\GokuGodHead.mdx", "head")
    set k = Mvp_Pieza(p, h, i, k, 'A080', "war3mapImported\\\\Vegeta Super Saiyan 2 Head_squished.mdx", "head")
    set k = Mvp_Pieza(p, h, i, k, 'A081', "war3mapImported\\\\Vegeta Super Saiyan 2 Head_squished.mdx", "head")
    set k = Mvp_Pieza(p, h, i, k, 'A0JN', "war3mapImported\\\\VegetaHeadBlue.mdx", "head")
''')

if prueba:
    # 4) -tabla: piezas por tipo (sin héroe).
    cambia('''// v20c: al fijarse el resultado, los modelos; con GoodJob, ataque del MVP; con QuestFailed, muerte del otro.
''', '''// v22l-prueba: cabeza de la fila f inventada por -tabla, según el tipo.
function Mvp_PiezaTipo takes integer p, integer i, integer f returns nothing
    local string m = ""
    local integer t = Mvp_TipoF[f]
    if Mvp_Mod[i] == null then
        return
    endif
    if t == 'hGok' then
        set m = "war3mapImported\\\\NormalHeadGoku.mdx"
    elseif t == 'hTrk' then
        set m = "war3mapImported\\\\TrunkHead.mdx"
    elseif t == 'hVeg' then
        set m = "war3mapImported\\\\Vegeta Super Saiyan 2 Head_squished.mdx"
    else
        return
    endif
    if GetLocalPlayer() != Player(p) then
        set m = ""
    endif
    set Mvp_Pz[i * 3] = AddSpecialEffectTarget(m, Mvp_Mod[i], "head")
endfunction

// v20c: al fijarse el resultado, los modelos; con GoodJob, ataque del MVP; con QuestFailed, muerte del otro.
''')
    cambia('''                call Mvp_Piezas(p, p * 2, Game_Hero[Mvp_Fila[Mvp_Gana]])
                if Mvp_Pierde >= 0 then
                    call Mvp_Piezas(p, p * 2 + 1, Game_Hero[Mvp_Fila[Mvp_Pierde]])
                endif
''', '''                call Mvp_Piezas(p, p * 2, Game_Hero[Mvp_Fila[Mvp_Gana]])
                if Mvp_Pierde >= 0 then
                    call Mvp_Piezas(p, p * 2 + 1, Game_Hero[Mvp_Fila[Mvp_Pierde]])
                endif
                if Mvp_Falso then
                    call Mvp_PiezaTipo(p, p * 2, Mvp_Gana)
                    call Mvp_PiezaTipo(p, p * 2 + 1, Mvp_Pierde)
                endif
''')
    assert 'function Cop_Anotar' in src
    cambia('lat\\\\v22k-', 'lat\\\\v22l-', src.count('lat\\\\v22k-'))
    cambia('v22k-don.txt', 'v22l-don.txt', src.count('v22k-don.txt'))
    assert 'lat\\\\v22k-' not in src and 'v22k-don.txt' not in src, 'quedan registros v22k'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22l', 'prueba' if prueba else 'normal', len(src.splitlines()), 'líneas')
