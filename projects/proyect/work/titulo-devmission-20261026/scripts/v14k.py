#!/usr/bin/env python3
"""v14k: la tienda de v14j con retratos vivos, voces al comprar y un botón para abastecer todas las armas.

Pedido de Leon (04/11/2026):
- El retrato del golem de roca y el del personaje que compra en lugar de la imagen fija (DS0D). El golem no tiene
  _Portrait en el juego: su retrato es la secuencia Portrait del modelo de unidad, rehecha como retrato ligero con
  scripts/retrato_golem.cjs (war3mapImported\\RetratoGolem.mdx, unidad 'dgo0'). El Tauren ('dts0') y Cairne ('dcs0') son
  los del título sin billboard (retrato_sin_billboard.cjs): en X 2400 el billboard los deja de canto y no se ven. Sale el retrato de quien habla: el golem al comentar el arma, el comprador al comprar.
- Una voz al azar del comprador al comprar un arma, con su animación de hablar; las líneas Yes, YesAttack y Warcry de su
  unidad. El azar va en código sincronizado (el clic del trackable); el sonido y la animación son locales.
- "Abastecer todo": llena la reserva de todas las armas con munición. Si el oro no alcanza, lo reparte por igual: las
  que se llenan con su parte se llenan y lo que sobra se reparte entre las demás; la regla de precio por bala no cambia.
  El oro y su etiqueta suben 48 px para dejar sitio al botón, sobre el de vida.

Los retratos están a profundidad 405, entre el fondo (DS0D, ahora oscuro, a 420) y el marco DT3E (403), cuya banda tapa
el borde de la pared del retrato (27 x 21,4 unidades). Escala: la pared mide 362 px de ancho a esa profundidad.
Uso: v14k.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base


def once(s, old, new):
    # El script está en UTF-8 y se lee como latin-1: los acentos de lo insertado también.
    return base.once(s, old.encode('utf-8').decode('latin-1'), new.encode('utf-8').decode('latin-1'))


# (ruta, ms) por personaje: 0 Tauren (Units\Orc\Tauren), 1 Cairne (Units\Orc\Cairne); duraciones de los WAV de war3.mpq.
VOCES = [
    [('Tauren\\TaurenYes1', 1398), ('Tauren\\TaurenYes2', 1007), ('Tauren\\TaurenYes3', 780),
     ('Tauren\\TaurenYesAttack1', 2109), ('Tauren\\TaurenYesAttack2', 1222), ('Tauren\\TaurenYesAttack3', 1352),
     ('Tauren\\TaurenWarcry1', 2541)],
    [('Cairne\\CairneYes1', 1457), ('Cairne\\CairneYes2', 1211), ('Cairne\\CairneYes3', 1348),
     ('Cairne\\CairneYes4', 1350), ('Cairne\\CairneYesAttack1', 1609), ('Cairne\\CairneYesAttack2', 1343),
     ('Cairne\\CairneWarcry1', 1308)],
]

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = once(s, 'unit Shop_VidaOn= null\n', '''unit Shop_VidaOn= null
unit Shop_TodoOn= null
unit array Shop_Retrato
sound array Shop_Voz
real array Shop_VozLen
timer array Shop_VozT
integer array Shop_Falta
''')

# Un texttag más (Shop_T[20], el botón nuevo) y el oro 48 px más arriba.
assert s.count('        exitwhen i > 19\n'.replace('\n', '\r\n')) == 2
s = s.replace('        exitwhen i > 19\r\n', '        exitwhen i > 20\r\n')
s = once(s, '    call Shop_Tag(1424, 610, 0.024, 0, "Oro")\n', '    call Shop_Tag(1424, 562, 0.024, 0, "Oro")\n')
s = once(s, '    call Shop_Izq(p, Shop_T[14], I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)), 1490, 604, 0.026)\n',
              '    call Shop_Izq(p, Shop_T[14], I2S(GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)), 1490, 556, 0.026)\n'
              '    call Shop_TodoTexto(p)\n')
s = once(s, '    call Shop_Hablar(p, "Golem de roca", Arm_Coment[w])\nendfunction\n',
              '    call Shop_Hablar(p, "Golem de roca", Arm_Coment[w])\n    call Shop_Cara(p, 0)\nendfunction\n')

# Retratos, voces y el reparto, antes de Shop_Refrescar, que los usa.
s = once(s, 'function Shop_Mostrar takes integer p, boolean on returns nothing\n', r'''// v14k: el retrato de quien habla en el cliente de p (0 golem, 1 Tauren, 2 Cairne, -1 ninguno). Sólo la escala, que es visual.
function Shop_Cara takes integer p, integer k returns nothing
    local integer j = 0
    local real e
    if GetLocalPlayer() == Player(p) then
        loop
            exitwhen j > 2
            set e = 0.
            if j == k then
                set e = 181 * (0.302 / 387.73819261) * 405 / 21.4
            endif
            call SetUnitScale(Shop_Retrato[j], e, e, e)
            set j = j + 1
        endloop
    endif
endfunction

// Reposo: Portrait en el golem, Portrait - 1 en el Tauren (1) y en Cairne (0).
function Shop_Reposo takes nothing returns nothing
    call SetUnitAnimationByIndex(Shop_Retrato[0], 0)
    call SetUnitAnimationByIndex(Shop_Retrato[1], DIALOGUE_RIGHT_IDLE)
    call SetUnitAnimationByIndex(Shop_Retrato[2], 0)
endfunction

function Shop_Callar takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > 13
        call StopSound(Shop_Voz[i], false, false)
        set i = i + 1
    endloop
endfunction

// El temporizador corre en todos los clientes; la animación vuelve al reposo sólo en el de p.
function Shop_VozFin takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if GetExpiredTimer() == Shop_VozT[p] then
            if GetLocalPlayer() == Player(p) then
                call Shop_Reposo()
            endif
            return
        endif
        set p = p + 1
    endloop
endfunction

// Código sincronizado (clic de compra): elige la voz con GetRandomInt; sonido y animación sólo para p.
function Shop_Voz_Comprar takes integer p returns nothing
    local integer h = IMinBJ(1, IMaxBJ(0, Hero_Choice[p]))
    local integer k = h * 7 + GetRandomInt(0, 6)
    call Shop_Cara(p, h + 1)
    if GetLocalPlayer() == Player(p) then
        call Shop_Callar()
        call StartSound(Shop_Voz[k])
        call Shop_Reposo()
        if h == 0 then
            call SetUnitAnimationByIndex(Shop_Retrato[1], DIALOGUE_RIGHT_TALK)
        else
            call SetUnitAnimationByIndex(Shop_Retrato[2], 1)
        endif
    endif
    call TimerStart(Shop_VozT[p], Shop_VozLen[k], false, function Shop_VozFin)
endfunction

function Shop_Mostrar takes integer p, boolean on returns nothing
''')
s = once(s, 'function Shop_Refrescar takes integer p returns nothing\n', r'''// v14k: lo que cuesta llenar la reserva de todas las armas de p con munición; Shop_Falta queda con las balas que faltan.
function Shop_TodoCosto takes integer p returns integer
    local integer c = 0
    local integer i
    local integer x
    local integer total = 0
    loop
        exitwhen c > 6
        set i = p * 7 + c
        set Shop_Falta[c] = 0
        if c != 5 and Arm_Tier[i] > 0 then
            set x = c * 3 + Arm_Tier[i] - 1
            set Shop_Falta[c] = IMaxBJ(0, Arm_Res[x] - Arm_Rva[i])
            set total = total + Shop_CostoBalas(x, Shop_Falta[c])
        endif
        set c = c + 1
    endloop
    return total
endfunction

function Shop_TodoTexto takes integer p returns nothing
    local integer total = Shop_TodoCosto(p)
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local string s = "Todo abastecido"
    if total > 0 and oro >= total then
        set s = "Abastecer todo: " + I2S(total) + " oro"
    elseif total > 0 then
        set s = "Abastecer todo: repartir " + I2S(oro) + " oro"
    endif
    call Shop_Centro(p, Shop_T[20], s, 1601, 624, 0.021)
    call Shop_Luz(p, Shop_TodoOn, total > 0 and oro > 0)
endfunction

function Shop_Refrescar takes integer p returns nothing
''')
s = once(s, 'function Shop_Vida takes integer p returns nothing\n', r'''// v14k: abastece todas las armas. Sin oro para todo, partes iguales: cada arma que se llena con su parte se llena, y lo
// que sobra vuelve a repartirse entre las que faltan; éstas compran las balas que paga su parte (10 de oro en 5 armas: 2).
function Shop_Todo takes integer p returns nothing
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    local integer total = Shop_TodoCosto(p)
    local integer gasto = 0
    local integer k = 0
    local integer c = 0
    local integer i
    local integer x
    local integer n
    local integer costo
    local integer parte
    local boolean otra = true
    loop
        exitwhen c > 6
        if Shop_Falta[c] > 0 then
            set k = k + 1
        endif
        set c = c + 1
    endloop
    if k == 0 or oro <= 0 then
        call UI_Error(p)
        return
    endif
    loop
        exitwhen not otra or k == 0
        set otra = false
        set parte = oro / k
        set c = 0
        loop
            exitwhen c > 6
            if Shop_Falta[c] > 0 then
                set i = p * 7 + c
                set x = c * 3 + Arm_Tier[i] - 1
                set costo = Shop_CostoBalas(x, Shop_Falta[c])
                if costo <= parte then
                    set Arm_Rva[i] = Arm_Rva[i] + Shop_Falta[c]
                    set Shop_Falta[c] = 0
                    set oro = oro - costo
                    set gasto = gasto + costo
                    set k = k - 1
                    set otra = true
                endif
            endif
            set c = c + 1
        endloop
    endloop
    if k > 0 then
        set parte = oro / k
        set c = 0
        loop
            exitwhen c > 6
            if Shop_Falta[c] > 0 then
                set i = p * 7 + c
                set x = c * 3 + Arm_Tier[i] - 1
                set n = IMinBJ(Shop_Falta[c], parte * Arm_Res[x] / ((Arm_Precio[x] + 100) / 4))
                if n > 0 then
                    set costo = Shop_CostoBalas(x, n)
                    set Arm_Rva[i] = Arm_Rva[i] + n
                    set oro = oro - costo
                    set gasto = gasto + costo
                endif
            endif
            set c = c + 1
        endloop
    endif
    if gasto == 0 then
        call UI_Error(p)
        return
    endif
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro)
    call UI_Click(p)
    call Shop_Refrescar(p)
endfunction

function Shop_Vida takes integer p returns nothing
''')

# Al comprar habla el comprador con su nombre, su retrato y su voz.
s = once(s, '    call Shop_Hablar(p, "Tauren", Shop_Frase[GetRandomInt(0, 5)])\n', '''    if Hero_Choice[p] == 1 then
        call Shop_Hablar(p, "Cairne", Shop_Frase[GetRandomInt(0, 5)])
    else
        call Shop_Hablar(p, "Tauren", Shop_Frase[GetRandomInt(0, 5)])
    endif
    call Shop_Voz_Comprar(p)
''')
s = once(s, '    elseif k == 23 then\n        call Shop_Vida(p)\n',
              '    elseif k == 23 then\n        call Shop_Vida(p)\n    elseif k == 24 then\n        call Shop_Todo(p)\n')

# Al cerrar se van retrato y voz.
s = once(s, '''    if on then
        set Shop_Fondo[p] = AddSpecialEffect(path, Title_X(), Title_Y())
    else
        call DestroyEffect(Shop_Fondo[p])
        set Shop_Fondo[p] = null
    endif
endfunction
''', '''    if on then
        set Shop_Fondo[p] = AddSpecialEffect(path, Title_X(), Title_Y())
    else
        call DestroyEffect(Shop_Fondo[p])
        set Shop_Fondo[p] = null
        call PauseTimer(Shop_VozT[p])
        call Shop_Cara(p, -1)
        if GetLocalPlayer() == Player(p) then
            call Shop_Callar()
            call Shop_Reposo()
        endif
    endif
endfunction
''')

# Construcción: fondo oscuro detrás, los tres retratos, el botón nuevo, su zona de clic y las voces.
voces = ''.join(f'''    set Shop_Voz[{h * 7 + k}] = CreateSound("Units\\\\Orc\\\\{r.replace(chr(92), chr(92) * 2)}.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(Shop_Voz[{h * 7 + k}], {ms})
    call SetSoundChannel(Shop_Voz[{h * 7 + k}], 0)
    call SetSoundVolume(Shop_Voz[{h * 7 + k}], 127)
    set Shop_VozLen[{h * 7 + k}] = {ms / 1000:.3f}
''' for h, lista in enumerate(VOCES) for k, (r, ms) in enumerate(lista))
# Marco del retrato (04/11/2026): el de la selección de héroe (DT3E, StratFrame), delante del retrato y con su
# hueco (320 de 512 texeles) del alto de la pared; 290 px de alto, ancho por la razón de píxeles R de marco_v11e.
s = once(s, "    call Shop_Pic(1601, 270, 330, 268, 399, 'DS0D')\n    call Shop_Pic(1601, 269, 366, 290, 398, 'DS03')\n",
              "    call Shop_Pic(1601, 269, 230, 230, 420, 'DS0D')\n    call Shop_Pic(1601, 269, 298.21, 290, 403, 'DT3E')\n    call Shop_Retratos()\n")
s = once(s, "    call Shop_Pic(1601, 706, 366, 62, 399, 'DS0A')\n",
              "    call Shop_Pic(1601, 639, 366, 62, 399, 'DS0A')\n    set Shop_TodoOn = Shop_Pic(1601, 639, 366, 62, 398.5, 'DS09')\n"
              "    call Shop_Pic(1601, 706, 366, 62, 399, 'DS0A')\n")
s = once(s, '            call Shop_Pista(p, "war3mapImported\\\\ShopHitBtn.mdx", 1601, 706, 23)\n',
              '            call Shop_Pista(p, "war3mapImported\\\\ShopHitBtn.mdx", 1601, 706, 23)\n'
              '            call Shop_Pista(p, "war3mapImported\\\\ShopHitBtn.mdx", 1601, 639, 24)\n')
s = once(s, 'function Oro_Muerte takes nothing returns nothing\n',
              r'''// v14k: golem, Tauren y Cairne en el centro del marco, a profundidad 405; ocultos (escala 0) hasta que hablan.
function Shop_Retratos takes nothing returns nothing
    local integer j = 0
    local integer array id
    local real x = Title_WX(Shop_PY(269), 405)
    local real y = Title_WY(1601, 405)
    set id[0] = 'dgo0'
    set id[1] = 'dts0'
    set id[2] = 'dcs0'
    loop
        exitwhen j > 2
        set Shop_Retrato[j] = CreateUnit(CAMERA_DUMMY_PLAYER, id[j], x, y, 0)
        call SetUnitX(Shop_Retrato[j], x)
        call SetUnitY(Shop_Retrato[j], y)
        call UnitAddAbility(Shop_Retrato[j], s__Interface_DESTROYER_FORM_ID)
        call UnitRemoveAbility(Shop_Retrato[j], s__Interface_DESTROYER_FORM_ID)
        call UnitAddAbility(Shop_Retrato[j], s__Interface_LOCUST_ID)
        call UnitRemoveAbility(Shop_Retrato[j], s__Interface_LOCUST_ID)
        call SetUnitFlyHeight(Shop_Retrato[j], Shop_OJO - 405 - UserInterface_GetTerrainZ(x, y), 0)
        call SetUnitScale(Shop_Retrato[j], 0, 0, 0)
        set j = j + 1
    endloop
    call Shop_Reposo()
    set j = 0
    loop
        exitwhen j > 11
        set Shop_VozT[j] = CreateTimer()
        set j = j + 1
    endloop
''' + voces + '''endfunction

function Oro_Muerte takes nothing returns nothing
''')
# Dos comentarios de puentes anteriores (v12y, v14j) quedaron en latin-1: se pasan a UTF-8 como el resto.
lineas = s.encode('latin-1').split(b'\n')
for n, l in enumerate(lineas):
    try:
        l.decode('utf-8')
    except UnicodeDecodeError:
        assert l.lstrip().startswith(b'//'), l[:60]
        lineas[n] = l.decode('latin-1').encode('utf-8')
Path(sys.argv[2]).write_bytes(b'\n'.join(lineas))
print('ok', len(s))
