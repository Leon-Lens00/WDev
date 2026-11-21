#!/usr/bin/env python3
"""v18o (15/11/2026): sonidos del cuadro de puntuación calentados y fase 8, votación de Mutación Evo.

- Leon (prueba de v18n): los sonidos creados en el momento no suenan la primera vez. Medido en la grabación
  20261115_180003: en la ronda 1 no se oyen PuntTic ni PuntSubeFin (correlación 0,26/0,25); en la ronda 2 sí (0,96/0,94).
  Preload() del wav no basta. Se usa el método del mapa (Son_Cero, v17d): crear el sonido y reproducirlo a volumen 0
  al empezar, para los 6 wav del recuento y QuestCompleted.
- Fase 8 (plan devmission-mejoras-darkmoon.md):
  - Votación: el voto de cada jugador es su elección del paso (Cua_Elegido, ya viaja por red con el clic). Al acabar
    el descanso, Cua_Recuento en código común: gana el más votado; empate, al azar entre los empatados; sin votos, al
    azar entre todos. Las mejoras ganadoras se acumulan en Cua_Activa (sin efecto todavía: sólo se anotan).
  - Con 2 o más jugadores cada cuadro muestra sus votos, y se refresca para quien está en el mismo paso.
  - Muestra de 8 s: al llegar el descanso a 0 se cierran las tiendas, todos ven los 3 ganadores (jefe, élites,
    comunes) con sus votos y la cuenta atrás, y después empieza la oleada (8 s más tarde que antes).
  - Peso: entre los candidatos de comunes, ×3 para Caparazón, Lluvia de flechas y Red de pesca si el tipo nuevo de la
    ronda siguiente (DevWave_TipoN(ronda)) es tortuga, de distancia o el trampero.
  - El resumen de la oleada sólo lista ya las mejoras del héroe; la Mutación Evo sale en su propio aviso.
- Prueba: recuento por paso en lat\\v18o-cuadros.txt.  lan: igual que prueba, con registros lat\\j<id>-v18o-*.txt.
Uso: v18o.py ENTRADA.j SALIDA.j [prueba|lan]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
prueba = modo in ('prueba', 'lan')
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


# 1. Sonidos del recuento a volumen 0 al empezar (Son_Init).
WAV = ['PuntSube', 'PuntSubeFin', 'PuntPerdida', 'PuntTic', 'PuntEstrella1', 'PuntEstrella2']
cambia('    call Son_Cero("war3mapImported\\\\SonTrueno33.wav")\n',
       '    call Son_Cero("war3mapImported\\\\SonTrueno33.wav")\n'
       '    // v18o: los del cuadro de puntuación; con Preload solo, PuntTic y PuntSubeFin no sonaban la primera vez.\n'
       + ''.join(f'    call Son_Cero("war3mapImported\\\\{w}.wav")\n' for w in WAV)
       + '    call Son_Cero("Sound\\\\Interface\\\\QuestCompleted.wav")\n')

# 2. Globales.
cambia('integer Cua_NE = 3\n',
       'integer Cua_NE = 3\n'
       'integer Cua_Jug = 1\n'
       'integer array Cua_Gana\n'
       'integer array Cua_GanaV\n'
       'integer array Cua_GanaE\n'
       'integer array Cua_Activa\n'
       'boolean Cua_MuestraOn = false\n'
       'timer Cua_MuestraReloj = null\n')
cambia('    set Cua_NE = 3\n    if n >= 6 then\n', '    set Cua_Jug = n\n    set Cua_NE = 3\n    if n >= 6 then\n')

# 3. Modo 2 (muestra de los ganadores): 3 cuadros, los ganadores, sin botón.
cambia('function Cua_Cuantos takes integer p returns integer\n    if Cua_Modo[p] == 0 then\n',
       'function Cua_Cuantos takes integer p returns integer\n    if Cua_Modo[p] != 1 then\n')
cambia('function Cua_Item takes integer p, integer c returns integer\n    if Cua_Modo[p] == 0 then\n',
       'function Cua_Item takes integer p, integer c returns integer\n    if Cua_Modo[p] == 2 then\n'
       '        return Cua_Gana[c]\n    endif\n    if Cua_Modo[p] == 0 then\n')
cambia('    if Cua_Paso[p] >= 5 and Cua_Modo[p] != 0 then\n', '    if Cua_Paso[p] >= 5 and Cua_Modo[p] == 1 then\n')

VOTOS = '''// v18o: votos al candidato x del paso k de Mutación Evo: jugadores que ya pasaron ese paso y lo eligieron.
function Cua_Votos takes integer k, integer x returns integer
    local integer p = 0
    local integer v = 0
    loop
        exitwhen p > 11
        if Game_On[p] and Cua_Paso[p] > k and Cua_Elegido[p * 5 + k] == x then
            set v = v + 1
        endif
        set p = p + 1
    endloop
    return v
endfunction

function Cua_VotosN takes integer v returns string
    if v == 1 then
        return "1 voto"
    endif
    return I2S(v) + " votos"
endfunction

// v18o: línea de votos bajo la descripción: en la muestra, el resultado; votando con 2+ jugadores, el recuento.
function Cua_VotosTxt takes integer p, integer c returns string
    local string k
    if Cua_Modo[p] == 2 then
        set k = "|n|n|cffff5064Comunes|r: "
        if c == 0 then
            set k = "|n|n|cffff5064Jefe|r: "
        elseif c == 1 then
            set k = "|n|n|cffff5064Élites|r: "
        endif
        if Cua_GanaE[c] == 2 then
            return k + "|cffffcc00nadie votó, al azar|r"
        elseif Cua_GanaE[c] == 1 then
            return k + "|cffffcc00empate a " + Cua_VotosN(Cua_GanaV[c]) + ", al azar|r"
        endif
        return k + "|cffffcc00" + Cua_VotosN(Cua_GanaV[c]) + "|r"
    endif
    if Cua_Modo[p] == 1 and Cua_Paso[p] < 3 and Cua_Jug > 1 then
        return "|n|n|cffffcc00" + Cua_VotosN(Cua_Votos(Cua_Paso[p], Cua_Item(p, c))) + "|r"
    endif
    return ""
endfunction

function Cua_Cabecera takes integer p returns string
    if Cua_Modo[p] == 2 then
        return "Mutación Evo · oleada " + I2S(Ronda_Numero + 1)
    endif
    return Cua_PasoNom[Cua_Paso[p]]
endfunction

'''
cambia('// v18m: cuadro k de la pantalla de inicio (0 Armas, 1 Mutación Evo, 2 Habilidades) cerrado o ya hecho.\n',
       VOTOS + '// v18m: cuadro k de la pantalla de inicio (0 Armas, 1 Mutación Evo, 2 Habilidades) cerrado o ya hecho.\n')

# Cua_Ver: visible en modo 2, carmesí, sin botón, cabecera y votos.
cambia('    local boolean ver = Cua_Open[p] and (inicio or Cua_Paso[p] < 5)\n    if Cua_Paso[p] >= 3 then\n',
       '    local boolean ver = Cua_Open[p] and (inicio or Cua_Modo[p] == 2 or Cua_Paso[p] < 5)\n'
       '    local integer sinBoton = 1\n'
       '    if Cua_Modo[p] == 2 then\n        set sinBoton = 0\n    endif\n'
       '    if Cua_Paso[p] >= 3 and Cua_Modo[p] == 1 then\n')
cambia('            call SetUnitVertexColor(Cua_Bt[s], ic, ic, ic, a)\n            call SetUnitVertexColor(Cua_Et[s], ic, ic, ic, a)\n',
       '            call SetUnitVertexColor(Cua_Bt[s], ic, ic, ic, a * sinBoton)\n'
       '            call SetUnitVertexColor(Cua_Et[s], ic, ic, ic, a * sinBoton)\n')
cambia('        call Cua_Centro(p, Cua_TCab, Cua_PasoNom[Cua_Paso[p]], 960, 70, 0.03)\n        if Cua_Paso[p] < 3 then\n',
       '        call Cua_Centro(p, Cua_TCab, Cua_Cabecera(p), 960, 70, 0.03)\n        if Cua_Paso[p] < 3 or Cua_Modo[p] == 2 then\n')
cambia('                call Cua_Izq(p, Cua_TD[c], Cua_Des[Cua_Item(p, c)], Cua_PX(s) - 150, 440, 0.021)\n',
       '                call Cua_Izq(p, Cua_TD[c], Cua_Des[Cua_Item(p, c)] + Cua_VotosTxt(p, c), Cua_PX(s) - 150, 440, 0.021)\n')

# Reloj de la ventana durante la muestra.
cambia('    set t = "Descanso " + I2S(Ronda_Resta)\n    if t != Cua_RelojVisto then\n',
       '    set t = "Descanso " + I2S(Ronda_Resta)\n'
       '    if Cua_Modo[p] == 2 and Cua_MuestraReloj != null then\n'
       '        set t = "Oleada en " + I2S(R2I(TimerGetRemaining(Cua_MuestraReloj) + 0.999))\n'
       '    endif\n'
       '    if t != Cua_RelojVisto then\n')

# 4. Candidatos de comunes con peso.
PESO = '''// v18o: más peso (×3) a las mejoras de comunes que tocan al tipo nuevo de la ronda siguiente. La ronda n usa los
// tipos 0..n-1 (DevWave_Slots), así que tras la ronda R entra el tipo R: 2 ntrh, 4 nmsn, 5 nlds, 7 nnsw a distancia;
// 2, 8 y 9 tortugas; 4 el trampero.
function Cua_Peso takes integer x returns integer
    local integer t = Ronda_Numero
    if x == 13 and (t == 2 or t == 8 or t == 9) then
        return 3
    elseif x == 14 and (t == 2 or t == 4 or t == 5 or t == 7) then
        return 3
    elseif x == 15 and t == 4 then
        return 3
    endif
    return 1
endfunction

function Cua_Usado takes integer x, integer k, integer i returns boolean
    local integer j = 0
    loop
        exitwhen j >= i
        if Cua_Cand[k + j] == x then
            return true
        endif
        set j = j + 1
    endloop
    return false
endfunction

// v18o: como Cua_Elegir (Mutación Evo), con el peso de Cua_Peso. Código común.
function Cua_ElegirPeso takes integer ini, integer tam, integer c, integer k returns nothing
    local integer i = 0
    local integer x
    local integer tot
    local integer r
    loop
        exitwhen i >= c
        set tot = 0
        set x = ini
        loop
            exitwhen x >= ini + tam
            if not Cua_Usado(x, k, i) then
                set tot = tot + Cua_Peso(x)
            endif
            set x = x + 1
        endloop
        set r = GetRandomInt(1, tot)
        set x = ini
        loop
            if not Cua_Usado(x, k, i) then
                set r = r - Cua_Peso(x)
            endif
            exitwhen r <= 0
            set x = x + 1
        endloop
        set Cua_Cand[k + i] = x
        set i = i + 1
    endloop
endfunction

'''
cambia('// Al empezar el descanso (Ronda_AlTerminar, por nombre): candidatos nuevos y pasos a cero.\n',
       PESO + '// Al empezar el descanso (Ronda_AlTerminar, por nombre): candidatos nuevos y pasos a cero.\n')
cambia('    call Cua_Elegir(8, 10, Cua_Cnt[2], false, 10)\n', '    call Cua_ElegirPeso(8, 10, Cua_Cnt[2], 10)\n')

# 5. Clic: nada en la muestra; el resumen sólo con las del héroe; refresco de votos para los demás.
cambia('    local integer c = s - (5 - n)\n    local integer x\n    if Cua_Modo[p] == 0 then\n',
       '    local integer c = s - (5 - n)\n    local integer x\n    local integer q = 0\n'
       '    if Cua_Modo[p] == 2 then\n        return\n    endif\n    if Cua_Modo[p] == 0 then\n')
cambia('    if StringLength(Cua_Resumen[p]) > 0 then\n        set Cua_Resumen[p] = Cua_Resumen[p] + ", "\n    endif\n'
       '    if Cua_Paso[p] < 3 then\n        set Cua_Resumen[p] = Cua_Resumen[p] + "|cffff5064" + Cua_Nom[x] + "|r"\n'
       '    else\n        set Cua_Resumen[p] = Cua_Resumen[p] + "|cff78f08c" + Cua_Nom[x] + "|r"\n    endif\n',
       '    // v18o: el resumen de la oleada sólo lleva las del héroe; la Mutación Evo es por votación.\n'
       '    if Cua_Paso[p] >= 3 then\n'
       '        if StringLength(Cua_Resumen[p]) > 0 then\n            set Cua_Resumen[p] = Cua_Resumen[p] + ", "\n        endif\n'
       '        set Cua_Resumen[p] = Cua_Resumen[p] + "|cff78f08c" + Cua_Nom[x] + "|r"\n    endif\n')
cambia('        set Cua_Modo[p] = 0\n    endif\n    call Cua_Pintar(p)\n    call Cua_Ver(p)\n',
       '        set Cua_Modo[p] = 0\n    endif\n    call Cua_Pintar(p)\n    call Cua_Ver(p)\n'
       '    // v18o: votos nuevos a la vista de quien sigue en ese paso.\n'
       '    if Cua_Paso[p] <= 3 then\n'
       '        loop\n            exitwhen q > 11\n'
       '            if q != p and Cua_Open[q] and Cua_Modo[q] == 1 and Cua_Paso[q] == Cua_Paso[p] - 1 then\n'
       '                call Cua_Ver(q)\n            endif\n            set q = q + 1\n        endloop\n'
       '    endif\n')

# 6. Recuento y muestra de 8 s, antes de Shop_Cerrar.
ANOTA = '''        set t = "recuento r" + I2S(Ronda_Numero) + " paso " + I2S(k) + ":"
        set c = 0
        loop
            exitwhen c >= Cua_Cnt[k]
            set t = t + " " + Cua_Nom[Cua_Cand[k * 5 + c]] + "=" + I2S(Cua_Votos(k, Cua_Cand[k * 5 + c]))
            set c = c + 1
        endloop
        call Cua_Anotar(t + " gana " + Cua_Nom[Cua_Gana[k]] + " modo " + I2S(Cua_GanaE[k]) + " veces " + I2S(Cua_Activa[Cua_Gana[k]]))
''' if prueba else ''
RECUENTO = '''// v18o, fase 8: recuento de Mutación Evo al acabar el descanso (código común). Gana el más votado; si hay empate, al
// azar entre los empatados; sin votos, al azar entre todos. Se acumula en Cua_Activa (todavía sin efecto).
function Cua_Recuento takes nothing returns nothing
    local integer k = 0
    local integer c
    local integer m
    local integer n
    local integer r
    local string t
    loop
        exitwhen k > 2
        set m = 0
        set c = 0
        loop
            exitwhen c >= Cua_Cnt[k]
            set m = IMaxBJ(m, Cua_Votos(k, Cua_Cand[k * 5 + c]))
            set c = c + 1
        endloop
        set n = 0
        set c = 0
        loop
            exitwhen c >= Cua_Cnt[k]
            if Cua_Votos(k, Cua_Cand[k * 5 + c]) == m then
                set n = n + 1
            endif
            set c = c + 1
        endloop
        set r = GetRandomInt(1, n)
        set c = 0
        loop
            if Cua_Votos(k, Cua_Cand[k * 5 + c]) == m then
                set r = r - 1
            endif
            exitwhen r <= 0
            set c = c + 1
        endloop
        set Cua_Gana[k] = Cua_Cand[k * 5 + c]
        set Cua_GanaV[k] = m
        set Cua_GanaE[k] = 0
        if m == 0 then
            set Cua_GanaE[k] = 2
        elseif n > 1 then
            set Cua_GanaE[k] = 1
        endif
        set Cua_Activa[Cua_Gana[k]] = Cua_Activa[Cua_Gana[k]] + 1
''' + ANOTA + '''        set k = k + 1
    endloop
endfunction

// v18o: fin de la muestra: fuera los cuadros, cámara de juego, aviso de lo que entra y la oleada.
function Cua_MuestraFin takes nothing returns nothing
    local integer p = 0
    local string s = "|cffff5064" + Cua_Nom[Cua_Gana[0]] + "|r, |cffff5064" + Cua_Nom[Cua_Gana[1]] + "|r, |cffff5064" + Cua_Nom[Cua_Gana[2]] + "|r"
    set Cua_MuestraOn = false
    loop
        exitwhen p > 11
        if Cua_Open[p] then
            set Cua_Open[p] = false
            set Cua_Modo[p] = 0
            call Cua_Mostrar(p, false)
            if GetLocalPlayer() == Player(p) then
                call SetCameraBoundsToRect(bj_mapInitialCameraBounds)
                call ResetToGameCamera(0)
                call ClearSelection()
                call SelectUnit(Game_Ctrl[p], true)
            endif
        endif
        if Game_On[p] then
            call DisplayTimedTextToPlayer(Player(p), 0, 0, 8, "Mutación Evo (aún sin efecto): " + s)
        endif
        set p = p + 1
    endloop
    set Ronda_Numero = Ronda_Numero + 1
    call Ronda_Lanzar()
endfunction

// v18o: al llegar el descanso a 0 (Ronda_Cuenta, por nombre; las tiendas ya están cerradas): recuento y 8 s con los
// 3 ganadores a la vista de todos antes de la oleada.
function Cua_MuestraEmpezar takes nothing returns nothing
    local integer p = 0
    call Cua_Recuento()
    set Cua_MuestraOn = true
    loop
        exitwhen p > 11
        if Game_On[p] then
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
    if Cua_MuestraReloj == null then
        set Cua_MuestraReloj = CreateTimer()
    endif
    call TimerStart(Cua_MuestraReloj, 8., false, function Cua_MuestraFin)
endfunction

'''
cambia('function Shop_Cerrar takes integer p returns nothing\n', RECUENTO + 'function Shop_Cerrar takes integer p returns nothing\n')

# 7. Descanso a 0: muestra en vez de lanzar ya la oleada; tienda cerrada durante la muestra.
cambia('        call ExecuteFunc("Shop_CerrarTodos")\n        set Ronda_Numero = Ronda_Numero + 1\n        call Ronda_Lanzar()\n',
       '        call ExecuteFunc("Shop_CerrarTodos")\n'
       '        // v18o: con candidatos, 8 s de muestra de la Mutación Evo; la oleada la lanza Cua_MuestraFin.\n'
       '        if Cua_Listo then\n            call ExecuteFunc("Cua_MuestraEmpezar")\n            return\n        endif\n'
       '        set Ronda_Numero = Ronda_Numero + 1\n        call Ronda_Lanzar()\n')
cambia('    if not Ronda_Activa or not Ronda_Descanso or Ronda_Numero >= Ronda_TOTAL or not UnitAlive(Game_Hero[p])',
       '    if Cua_MuestraOn or not Ronda_Activa or not Ronda_Descanso or Ronda_Numero >= Ronda_TOTAL or not UnitAlive(Game_Hero[p])')
cambia('"Elegido para esta oleada (aún sin efecto): "', '"Mejoras del héroe (aún sin efecto): "')

if prueba:
    assert src.count('lat\\\\v18n-') == 4
    if modo == 'lan':
        src = src.replace('"lat\\\\v18n-', '"lat\\\\j" + I2S(GetPlayerId(GetLocalPlayer())) + "-v18o-')
    else:
        src = src.replace('lat\\\\v18n-', 'lat\\\\v18o-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18o', modo or 'normal')
