#!/usr/bin/env python3
"""v18c (15/11/2026): sobre v18b, a petición de Leon tras probar v18b-prueba.

- Fondo propio de las tarjetas ('DSC0', SupCaja.blp de tarjeta_v18c.py): sin el cuadro negro del retrato de la racha.
- La súper élite es sólo para élites. Si el sorteo cae en una unidad común, se cambia por una élite de su tipo en el
  mismo sitio, con la misma orientación, dueño y proporción de vida: se crea la élite, se registra en la oleada como
  unidad externa de la común (WaveRegisterExternalUnit: cuenta, IA y DevFuego_Aparece como cualquier élite) y la
  común muere y se quita al momento, sin cadáver. Su muerte cuenta para los eventos de élites como cualquier otra.
- La tirada es igual para todos: los 12 cambios al azar se sortean al crear la súper élite (código común) y cada
  jugador los ve en el mismo orden; las dos estadísticas y las dos pasivas de cada cambio son distintas entre sí.
- Tamaños (tamanos_v18c.py): selección de UnitHitShape de élites y jefes con su nuevo factor, y altura de su barra.
Prueba: registros en lat\\v18c-*.txt; anota además cada cambio de común a élite.
Uso: v18c.py v18b/war3map.j SALIDA.j [prueba]
"""
from pathlib import Path
import re, sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from tamanos_v18c import TIPOS, ids, barra

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
prueba = len(sys.argv) > 3 and sys.argv[3] == 'prueba'
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')
u8 = lambda s: s.encode('utf-8').decode('latin-1')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(u8(antes)), crlf(u8(despues))
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


# 1. Fondo propio.
una("        call Arm_Foto(u, 309., 57.68, 'DS18')\n", "        call Arm_Foto(u, 309., 57.68, 'DSC0')\n")
una("// Fondos (cuadro de racha 'DS18', dorado o violeta)", "// Fondos ('DSC0' desde v18c, dorado o violeta)")

# 2. Globales.
una('sound Sup_TicSnd = null\n', '''sound Sup_TicSnd = null
unit Sup_CU = null
integer array Sup_RT
integer array Sup_RV
''')

# 3. Tamaños: selección de élites y jefes (UnitHitShape) con el factor nuevo, como objetos_v18c.py.
forma = {t: (float(a), float(b)) for t, a, b in
         re.findall(r"call s__UnitHitShape_register\('(\w{4})' , ([\d.]+) , ([\d.]+)\)", j) if t in TIPOS}
assert sorted(forma) == sorted(TIPOS)
for rid, t, f, _ in ids():
    pat = re.compile(r"call s__UnitHitShape_register\('" + rid + r"' , [\d.]+ , [\d.]+\)")
    assert len(pat.findall(j)) == 1, rid
    j = pat.sub(f"call s__UnitHitShape_register('{rid}' , {round(forma[t][0] * f, 3)} , {min(200., round(forma[t][1] * f, 1))})", j)

# Barras: altura por tipo en vez de 80 / 170 fijos.
cadena = ''.join(f"    {'if' if n == 0 else 'elseif'} id == '{rid}' then\n        return {barra(t, f, es)}.\n"
                 for n, (rid, t, f, es) in enumerate(ids()))
una('''// v17u: súper élite (Dark Moon).''', f'''// v18c: altura extra de la barra (sobre 150) de élites y jefes, por encima de su modelo (tamanos_v18c.py).
function Sup_Barra takes integer id returns real
{cadena}    endif
    return 80.
endfunction

// v18c: tipo común de la élite k ('ne0k'), como DevWave_TipoN.
function Sup_Comun takes integer k returns integer
    if k == 0 then
        return 'nmcf'
    elseif k == 1 then
        return 'nlpr'
    elseif k == 2 then
        return 'ntrh'
    elseif k == 3 then
        return 'nmtw'
    elseif k == 4 then
        return 'nmsn'
    elseif k == 5 then
        return 'nlds'
    elseif k == 6 then
        return 'nmmu'
    elseif k == 7 then
        return 'nnsw'
    elseif k == 8 then
        return 'ntrg'
    endif
    return 'ntrd'
endfunction

// v17u: súper élite (Dark Moon).''')
una("        call SaveReal(Barras_HT, 1, 'ne00' + k, 80.)\n", "        call SaveReal(Barras_HT, 1, 'ne00' + k, Sup_Barra('ne00' + k))\n")
una("        call SaveReal(Barras_HT, 1, DevJefe_Tipo(k), 170.)\n", "        call SaveReal(Barras_HT, 1, DevJefe_Tipo(k), Sup_Barra(DevJefe_Tipo(k)))\n")

# 4. Daño base: el de la élite es 1,5 × el del común (objetos_v14g: ua1b y ua1s × 1,5). Bases > 0 = candidatos.
una('''function Sup_Base takes integer id returns real
    if id == 'nmcf' or id == 'nlpr' then''', '''function Sup_Base takes integer id returns real
    // v18c: las élites también son candidatas (las comunes se cambian por élite en Sup_Crear).
    if id >= 'ne00' and id <= 'ne09' then
        return 1.5 * Sup_Base(Sup_Comun(id - 'ne00'))
    elseif id == 'nmcf' or id == 'nlpr' then''')

# 5. Común → élite de su tipo antes de darle las mejoras.
una('''    set u = e
    set id = GetUnitTypeId(u)
    set i = Sup_N
''', '''    set u = e
    set id = GetUnitTypeId(u)
    // v18c: la súper élite es sólo para élites; si tocó una común, Sup_Convertir la cambia por la élite de su tipo.
    if id < 'ne00' or id > 'ne09' then
        set Sup_CU = u
        call ExecuteFunc("Sup_Convertir")
        set u = Sup_CU
        set Sup_CU = null
        if u == null then
            set e = null
            return false
        endif
''' + ('''        call Sup_Anotar("r" + I2S(r) + " comun " + UnitId2String(id) + " cambiada por elite " + UnitId2String(GetUnitTypeId(u)) + " vida " + R2SW(GetWidgetLife(u), 1, 0) + "/" + R2SW(GetUnitState(u, UNIT_STATE_MAX_LIFE), 1, 0))
''' if prueba else '') + '''        set id = GetUnitTypeId(u)
    endif
    set i = Sup_N
''')
una('''function DevWave_IA takes nothing returns nothing''', '''// v18c: cambia la común Sup_CU por la élite de su tipo (mismo sitio, orientación, dueño y proporción de vida). La élite
// entra en la oleada como externa de la común (cuenta, IA, DevFuego_Aparece); la común muere y se quita sin cadáver.
// Deja en Sup_CU la élite, o null si no se pudo. Va aquí, tras la biblioteca de oleadas; Sup_Crear la llama con
// ExecuteFunc (código común: el mismo resultado en todos los clientes).
function Sup_Convertir takes nothing returns nothing
    local unit c = Sup_CU
    local unit n
    local integer k = 0
    local real f
    set Sup_CU = null
    loop
        exitwhen k > 9 or DevWave_TipoN(k) == GetUnitTypeId(c)
        set k = k + 1
    endloop
    if k > 9 or not UnitAlive(c) or GetWaveByUnit(c) == 0 then
        set c = null
        return
    endif
    set f = GetWidgetLife(c) / GetUnitState(c, UNIT_STATE_MAX_LIFE)
    set n = CreateUnit(GetOwningPlayer(c), 'ne00' + k, GetUnitX(c), GetUnitY(c), GetUnitFacing(c))
    call WaveRegisterExternalUnit(c, n, false)
    if GetWaveByUnit(n) == 0 then
        call RemoveUnit(n)
        set n = null
        set c = null
        return
    endif
    call SetWidgetLife(n, RMaxBJ(1., f * GetUnitState(n, UNIT_STATE_MAX_LIFE)))
    call KillUnit(c)
    call RemoveUnit(c)
    set Sup_CU = n
    set n = null
    set c = null
endfunction

function DevWave_IA takes nothing returns nothing''')

# 6. Tirada común: 12 cambios sorteados al crear (sin repetir estadística ni pasiva dentro de un cambio).
una('''    set Sup_U[i] = u
    set Sup_Vista = i
''', '''    // v18c: los 12 cambios de la tirada, iguales para todos los jugadores (Sup_Barajar).
    set b = 0
    loop
        exitwhen b > 11
        set t = GetRandomInt(0, 6)
        set Sup_RT[i * 48 + b * 4] = t
        set k = GetRandomInt(0, 5)
        if k >= t then
            set k = k + 1
        endif
        set Sup_RT[i * 48 + b * 4 + 1] = k
        set k = 0
        loop
            exitwhen k > 1
            set t = Sup_RT[i * 48 + b * 4 + k]
            if t == 2 or t == 4 then
                set Sup_RV[i * 48 + b * 4 + k] = 5 * GetRandomInt(1, 10)
            else
                set Sup_RV[i * 48 + b * 4 + k] = GetRandomInt(1, 60)
            endif
            set k = k + 1
        endloop
        set t = GetRandomInt(0, 6)
        set Sup_RT[i * 48 + b * 4 + 2] = t
        set k = GetRandomInt(0, 5)
        if k >= t then
            set k = k + 1
        endif
        set Sup_RT[i * 48 + b * 4 + 3] = k
        set b = b + 1
    endloop
    set Sup_U[i] = u
    set Sup_Vista = i
''')
una('''        else
            set t = GetRandomInt(0, 6)
            if k < 2 then
                if t == 2 or t == 4 then
                    set v = 5 * GetRandomInt(1, 10)
                else
                    set v = GetRandomInt(1, 60)
                endif
                call Sup_Poner(p, k, t, "+" + I2S(v) + Sup_StNom[t])
''', '''        else
            // v18c: el cambio Sup_Tiro (1-12) sorteado en Sup_Crear, igual para todos.
            set v = i * 48 + (Sup_Tiro[p] - 1) * 4 + k
            set t = Sup_RT[v]
            if k < 2 then
                call Sup_Poner(p, k, t, "+" + I2S(Sup_RV[v]) + Sup_StNom[t])
''')

if prueba:
    for n in ('super', 'precarga', 'cuadros'):
        una(f'call PreloadGenEnd("lat\\\\v18b-{n}.txt")', f'call PreloadGenEnd("lat\\\\v18c-{n}.txt")')
    assert 'lat\\\\v18b-' not in j
assert "'DS18')" in j and "309., 57.68, 'DS18'" not in j and 'GetRandomInt(1, 60)' in j
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v18c: fondo propio, súper sólo en élites, tirada común, tamaños' + (' + registro' if prueba else ''))
