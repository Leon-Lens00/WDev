#!/usr/bin/env python3
"""v22k-prueba (23/11/2026): "-tabla [N]" saca el cuadro de resultados con N jugadores inventados (2-8, 8 por defecto).

Leon tras v22j: "crea un cuadro por comando de 8 jugadores con valores aleatorios nombre y personajes al final, para
ver como quedo". Sólo en prueba (como -punt, v18t-prueba); la normal sigue siendo v22j.
- Nombres al azar de una lista (hasta 15 letras) con los colores de los jugadores 1-8; bajas 0-400, élites 0-10,
  daño 1.000-9.999.999, bolsas 0-20, caídas 0-5; puntos con la fórmula de Mvp_Preparar; MVP y menos puntos igual.
- Personajes al final: tipo al azar entre los 9 de Pj_Registro. Mvp_Modelo pasa a Mvp_ModeloT (por tipo) y Mvp_ModTick
  usa Mvp_ModeloF: con Mvp_Falso el tipo inventado; si no, el héroe como antes. Mvp_Fila = 12 (sin héroe: sin piezas).
- Mvp_Preparar apaga Mvp_Falso: las rondas reales no cambian.
Registro: "-tabla N gana G pierde P; ...".
Uso: v22k.py ENTRADA.j SALIDA.j prueba   (de v22j-prueba).
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
assert len(sys.argv) > 3 and sys.argv[3] == 'prueba', 'sólo prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


# 1) Globales.
cambia('boolean Mvp_Premio = false\n', '''boolean Mvp_Premio = false
// v22k-prueba: cuadro inventado de -tabla (tipo del personaje de cada fila).
boolean Mvp_Falso = false
integer array Mvp_TipoF
''')

# 2) Modelo por tipo.
i = src.index('function Mvp_Modelo takes integer p, unit h returns unit\n')
j = src.index('\nendfunction\n', i) + len('\nendfunction\n')
cuerpo = src[i:j]
assert cuerpo.count('GetUnitTypeId(h)') == 3
cuerpo = cuerpo.replace('function Mvp_Modelo takes integer p, unit h returns unit', 'function Mvp_ModeloT takes integer p, integer id returns unit')
cuerpo = cuerpo.replace('if h == null or GetUnitTypeId(h) == 0 then', 'if id == 0 then')
cuerpo = cuerpo.replace('GetUnitTypeId(h)', 'id')
cuerpo += '''function Mvp_Modelo takes integer p, unit h returns unit
    if h == null then
        return null
    endif
    return Mvp_ModeloT(p, GetUnitTypeId(h))
endfunction
// v22k-prueba: modelo de la fila f (tipo inventado con -tabla).
function Mvp_ModeloF takes integer p, integer f returns unit
    if Mvp_Falso then
        return Mvp_ModeloT(p, Mvp_TipoF[f])
    endif
    return Mvp_Modelo(p, Game_Hero[Mvp_Fila[f]])
endfunction
'''
src = src[:i] + cuerpo + src[j:]
cambia('set Mvp_Mod[p * 2] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Gana]])', 'set Mvp_Mod[p * 2] = Mvp_ModeloF(p, Mvp_Gana)')
cambia('set Mvp_Mod[p * 2 + 1] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Pierde]])', 'set Mvp_Mod[p * 2 + 1] = Mvp_ModeloF(p, Mvp_Pierde)')

# 3) Las rondas reales apagan el cuadro inventado.
cambia('''    local string nom = ""
    set Mvp_Gana = -1
    set Mvp_Pierde = -1
''', '''    local string nom = ""
    set Mvp_Falso = false
    set Mvp_Gana = -1
    set Mvp_Pierde = -1
''')

# 4) Comando.
cambia('// v18y-prueba: la última mejora del héroe aplicada.\n', '''// v22k-prueba: nombre y tipo inventados para -tabla.
function Tabla_Nombre takes integer k returns string
    if k == 0 then
        return "LocoM"
    elseif k == 1 then
        return "Leforyer"
    elseif k == 2 then
        return "ArcadeEX"
    elseif k == 3 then
        return "el_kuka"
    elseif k == 4 then
        return "SuperSaiyan9999"
    elseif k == 5 then
        return "Kakaroto_X"
    elseif k == 6 then
        return "NarutoUzumaki7"
    elseif k == 7 then
        return "Zz"
    elseif k == 8 then
        return "ProGamer_2026"
    elseif k == 9 then
        return "MMMMMMMMMMMMMMM"
    endif
    return "WWWWWWWWWWWWWWW"
endfunction
function Tabla_Color takes integer f returns string
    if f == 0 then
        return "|cffff0303"
    elseif f == 1 then
        return "|cff0042ff"
    elseif f == 2 then
        return "|cff1ce6b9"
    elseif f == 3 then
        return "|cff540081"
    elseif f == 4 then
        return "|cfffffc01"
    elseif f == 5 then
        return "|cfffe8a0e"
    elseif f == 6 then
        return "|cff20c000"
    endif
    return "|cffe55bb0"
endfunction
function Tabla_Tipo takes integer k returns integer
    if k == 0 then
        return 'h005'
    elseif k == 1 then
        return 'h006'
    elseif k == 2 then
        return 'hGok'
    elseif k == 3 then
        return 'hFrz'
    elseif k == 4 then
        return 'hTrk'
    elseif k == 5 then
        return 'hNar'
    elseif k == 6 then
        return 'hKur'
    elseif k == 7 then
        return 'hVeg'
    endif
    return 'hVto'
endfunction

// v22k-prueba: "-tabla [N]" cuadro de resultados con N jugadores inventados (2-8).
function Tabla_Comando takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer n = 8
    local integer f = 0
    local integer v
    local string nom = ""
    local string reg
    if Punt_T >= 0. or Ronda_Fase != 0 or Cua_MuestraOn then
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 4, "-tabla: ahora no (hay otro cuadro o cuenta en curso)")
        return
    endif
    if StringLength(s) > 7 then
        set n = IMaxBJ(2, IMinBJ(8, S2I(SubString(s, 7, StringLength(s)))))
    endif
    set Punt_Cogidas = GetRandomInt(0, 20)
    set Punt_Perdidas = GetRandomInt(0, 6)
    set Punt_Soltadas = Punt_Cogidas + Punt_Perdidas
    set Punt_Caidas = GetRandomInt(0, 12)
    set Punt_Estrellas = GetRandomInt(1, 3)
    set Punt_Ver = Punt_Ver + 1
    call Punt_Preparar()
    set Mvp_Falso = true
    set Mvp_Gana = -1
    set Mvp_Pierde = -1
    loop
        exitwhen f >= n
        set Mvp_Fila[f] = 12
        set Mvp_Nom[f] = Tabla_Color(f) + Tabla_Nombre(GetRandomInt(0, 10)) + "|r"
        set Mvp_TipoF[f] = Tabla_Tipo(GetRandomInt(0, 8))
        set Mvp_Val[f * 8] = GetRandomInt(0, 400)
        set Mvp_Val[f * 8 + 1] = GetRandomInt(0, 10)
        set Mvp_Val[f * 8 + 2] = GetRandomInt(1000, 9999999)
        set Mvp_Val[f * 8 + 3] = GetRandomInt(0, 20)
        set Mvp_Val[f * 8 + 4] = GetRandomInt(0, 5)
        set v = Mvp_Val[f * 8] + 5 * Mvp_Val[f * 8 + 1] + Mvp_Val[f * 8 + 2] / 1000 + 3 * Mvp_Val[f * 8 + 3] - 20 * Mvp_Val[f * 8 + 4]
        set Mvp_Val[f * 8 + 5] = IMaxBJ(0, v)
        if Mvp_Gana < 0 or Mvp_Mejor(f, Mvp_Gana) then
            set Mvp_Gana = f
        endif
        if Mvp_Pierde < 0 or Mvp_Mejor(Mvp_Pierde, f) then
            set Mvp_Pierde = f
        endif
        if f > 0 then
            set nom = nom + "|n"
        endif
        set nom = nom + Mvp_Nom[f]
        set f = f + 1
    endloop
    set Mvp_N = n
    if Mvp_Pierde == Mvp_Gana then
        set Mvp_Pierde = ModuloInteger(Mvp_Gana + 1, n)
    endif
    set Mvp_Premio = true
    call Mvp_Pon(6, nom)
    set Punt_T = 0.
    set reg = "-tabla " + I2S(n) + " gana " + I2S(Mvp_Gana) + " pierde " + I2S(Mvp_Pierde)
    set f = 0
    loop
        exitwhen f >= n
        set reg = reg + "; " + Mvp_Nom[f] + " tipo " + I2S(Mvp_TipoF[f]) + " d " + I2S(Mvp_Val[f * 8 + 2]) + " pts " + I2S(Mvp_Val[f * 8 + 5])
        set f = f + 1
    endloop
    call Bolsa_Anotar(reg)
endfunction

// v18y-prueba: la última mejora del héroe aplicada.
''')
cambia('''    call TriggerAddAction(m, function Mut_Comando)
    set m = null
''', '''    call TriggerAddAction(m, function Mut_Comando)
    // v22k-prueba: -tabla.
    set m = CreateTrigger()
    set p = 0
    loop
        exitwhen p > 11
        call TriggerRegisterPlayerChatEvent(m, Player(p), "-tabla", false)
        set p = p + 1
    endloop
    call TriggerAddAction(m, function Tabla_Comando)
    set m = null
''')
assert src.index('function Mvp_Mejor ') < src.index('function Tabla_Comando')
assert src.index('function Punt_Preparar ') < src.index('function Tabla_Comando')

assert 'function Cop_Anotar' in src
cambia('lat\\\\v22j-', 'lat\\\\v22k-', src.count('lat\\\\v22j-'))
cambia('v22j-don.txt', 'v22k-don.txt', src.count('v22j-don.txt'))
assert 'lat\\\\v22j-' not in src and 'v22j-don.txt' not in src, 'quedan registros v22j'
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v22k prueba', len(src.splitlines()), 'líneas')
