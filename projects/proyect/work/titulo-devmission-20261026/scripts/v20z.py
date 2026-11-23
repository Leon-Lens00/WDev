#!/usr/bin/env python3
"""v20z (21/11/2026): pulls comprados para las dos tiendas, páginas de iconos, rachas con icono y MVP de interfaz.
Leon (LAN de v20y):
- Comprar un pull ya no abre sólo la tienda del héroe con un arma dentro: el pull queda en una cola (hasta 5) y abre
  las dos tiendas, Armas y Habilidades; el jugador elige en cuál lo gasta. Entrar y salir con ESC sin elegir no gasta
  nada: el pull sigue en la cola con las mismas cartas. La mano del héroe es sólo del héroe (sin las 2 de armas); la
  de armas sale como las de Armas, con la calidad de la rareza comprada y sin malditas. Al elegir una se sigue con la
  siguiente mientras queden (pasos ganados y luego comprados); ESC vuelve al menú cuando se quiera.
- Panel "Mejoras de tu héroe": 15 iconos por página y botones < > con "1/N" debajo (antes 20 y la cuarta fila se
  salía del cuadro). Hasta 60 mejoras guardadas.
- Tarjeta de racha: icono del personaje (piel del icono de la selección) en lugar del retrato animado; sin la voz
  del personaje tras el anuncio, así la cola de anuncios avanza al acabar cada sonido (+0,3 s).
- Cuadro MVP: piezas hMf0-6 ya son copias de la pieza de retrato (objetos_v20z.py) y los modelos van sin partículas
  ni eventos (mvp_limpio.cjs); el código no cambia.
- Prueba: registro de cada elección del héroe/armas ("cua elige") para revisar cuándo se vuelve al menú.
Uso: v20z.py ENTRADA.j SALIDA.j [prueba]   (normal de v20y; prueba de v20y-prueba).
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


def reemplaza(viejo, nuevo):
    """viejo ya es texto del j (latin-1); nuevo en UTF-8 salvo las partes que vengan del j (marcadas con J())."""
    global src
    assert src.count(viejo) == 1, viejo[:90]
    src = src.replace(viejo, nuevo)


def funcion(nombre):
    """Texto completo de la función (desde 'function nombre ' hasta 'endfunction\\n')."""
    i = src.index('\nfunction ' + nombre + ' ') + 1
    j = src.index('\nendfunction\n', i) + len('\nendfunction\n')
    return src[i:j]


# --- globales
cambia('''integer array ArmC_Quedan
''', '''integer array ArmC_Quedan
integer array HerC_N
integer array HerC_R
boolean array HerC_HHecha
boolean array HerC_AHecha
integer array HerC_HC
integer array HerC_HQ
integer array HerC_HT
integer array HerC_AC
integer array HerC_AQ
integer array HerC_AT
boolean array HerC_HAb
boolean array ArmC_Comp
integer array Pan_Pag
unit array Pan_Nav
integer array Racha_CIco
''')

# ===================== 1) pulls comprados para las dos tiendas
cambia('''    if Cua_Modo[p] == 3 then
        return "Armas (" + I2S(ArmC_Total[p] - ArmC_Quedan[p] + 1) + "/" + I2S(ArmC_Total[p]) + ") · suerte " + I2S(Her_Suerte[p])
    endif
''', '''    if Cua_Modo[p] == 3 and ArmC_Comp[p] then
        return "Armas · " + HerC_Nombre(HerC_R[p * 8]) + " · suerte " + I2S(Her_Suerte[p])
    elseif Cua_Modo[p] == 3 then
        return "Armas (" + I2S(ArmC_Total[p] - ArmC_Quedan[p] + 1) + "/" + I2S(ArmC_Total[p]) + ") · suerte " + I2S(Her_Suerte[p])
    endif
''')
cambia('''function Cua_Cabecera takes integer p returns string
''', '''// v20z: nombre de un pull comprado de rareza r.
function HerC_Nombre takes integer r returns string
    if r == 0 then
        return "Pull comprado · bajo"
    elseif r == 1 then
        return "Pull comprado · medio"
    endif
    return "Pull comprado · alto"
endfunction

// v20z: p puede abrir en Habilidades un pull comprado (cola con alguno y sitio para un paso más).
function HerC_HayH takes integer p returns boolean
    return HerC_N[p] > 0 and Her_Extra[p] < 5
endfunction

function Cua_Cabecera takes integer p returns string
''')
cambia('''    elseif k == 2 then
        return Cua_Paso[p] < 3 or Cua_Paso[p] >= Her_FinDe(p)
    endif
    return Cua_Paso[p] < 3 or (not ArmC_TiendaVieja and ArmC_Quedan[p] <= 0)
''', '''    elseif k == 2 then
        return Cua_Paso[p] < 3 or (Cua_Paso[p] >= Her_FinDe(p) and not HerC_HayH(p))
    endif
    return Cua_Paso[p] < 3 or (not ArmC_TiendaVieja and ArmC_Quedan[p] <= 0 and HerC_N[p] <= 0)
''')
cambia('''    if k == 0 and not ArmC_TiendaVieja then
        if ArmC_Quedan[p] <= 0 then
            return "|cff909090Hecho: ya elegiste|nlas de tus armas.|r"
        endif
        return "Elige " + I2S(ArmC_Quedan[p]) + " mejoras de|ntus armas."
    elseif k == 0 then
        return "Mejora tus armas|ny compra munición."
    elseif Cua_Paso[p] < Her_FinDe(p) then
        return "Elige " + I2S(2 + Her_Extra[p]) + " mejoras de|ntu héroe (" + I2S(Cua_Paso[p] - 3) + "/" + I2S(2 + Her_Extra[p]) + ")."
    endif
    return "|cff909090Hecho: ya elegiste|ntus mejoras.|r"
''', '''    if k == 0 and not ArmC_TiendaVieja then
        if ArmC_Quedan[p] <= 0 and HerC_N[p] > 0 then
            return "Tienes " + I2S(HerC_N[p]) + " pulls comprados|npara tus armas."
        elseif ArmC_Quedan[p] <= 0 then
            return "|cff909090Hecho: ya elegiste|nlas de tus armas.|r"
        elseif HerC_N[p] > 0 then
            return "Elige " + I2S(ArmC_Quedan[p]) + " mejoras de|ntus armas, +" + I2S(HerC_N[p]) + " pulls."
        endif
        return "Elige " + I2S(ArmC_Quedan[p]) + " mejoras de|ntus armas."
    elseif k == 0 then
        return "Mejora tus armas|ny compra munición."
    elseif Cua_Paso[p] < Her_FinDe(p) and HerC_N[p] > 0 then
        return "Elige " + I2S(2 + Her_Extra[p]) + " mejoras de|ntu héroe (" + I2S(Cua_Paso[p] - 3) + "/" + I2S(2 + Her_Extra[p]) + "), +" + I2S(HerC_N[p]) + " pulls."
    elseif Cua_Paso[p] < Her_FinDe(p) then
        return "Elige " + I2S(2 + Her_Extra[p]) + " mejoras de|ntu héroe (" + I2S(Cua_Paso[p] - 3) + "/" + I2S(2 + Her_Extra[p]) + ")."
    elseif HerC_HayH(p) then
        return "Tienes " + I2S(HerC_N[p]) + " pulls comprados|npara tu héroe."
    endif
    return "|cff909090Hecho: ya elegiste|ntus mejoras.|r"
''')
# Cartas a la vista también en la mano comprada de Armas; botones de compra grises con la cola llena.
cambia('''(Cua_Modo[p] == 3 and ArmC_Quedan[p] > 0) or (Cua_Modo[p] == 1 and Cua_Paso[p] < Her_FinDe(p)))''',
       '''(Cua_Modo[p] == 3 and (ArmC_Quedan[p] > 0 or ArmC_Comp[p])) or (Cua_Modo[p] == 1 and Cua_Paso[p] < Her_FinDe(p)))''')
cambia('''            if 2 + Her_Extra[p] >= 7 or GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) < HerC_Precio(c) then''',
       '''            if HerC_N[p] >= 5 or GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD) < HerC_Precio(c) then''')
# Entrar en Armas o Habilidades desde la pantalla de inicio.
cambia('''    elseif c == 0 then
        // v20v: Armas por cartas (la tienda de compra vieja queda apagada).
        set Cua_Modo[p] = 3
        call Cua_Pintar(p)
        call Cua_Ver(p)
        return
    endif
    set Cua_Modo[p] = 1
''', '''    elseif c == 0 then
        // v20v: Armas por cartas (la tienda de compra vieja queda apagada).
        // v20z: sin elecciones de la oleada, la mano del primer pull comprado.
        if ArmC_Quedan[p] <= 0 then
            call HerC_AbrirA(p)
        endif
        set Cua_Modo[p] = 3
        call Cua_Pintar(p)
        call Cua_Ver(p)
        return
    endif
    // v20z: con los pasos del héroe hechos, el primer pull comprado como un paso más.
    if Cua_Paso[p] >= Her_FinDe(p) then
        call HerC_AbrirH(p)
    endif
    set Cua_Modo[p] = 1
''')

# HerC_Mano: sólo cartas del héroe (fuera las 2 de armas).
mano = funcion('HerC_Mano')
reemplaza(mano, U('''function HerC_Mano takes integer p, integer k, integer r returns nothing
    local integer i = 0
    call Her_CartasExtra(p, k, 0)
    loop
        exitwhen i > 3
        if Cua_HCand[k + i] < 40 or Cua_HCand[k + i] >= 78 then
            set Her_Cal[k + i] = HerC_Cal(r)
        endif
        set i = i + 1
    endloop
endfunction
'''))
cambia('''// v20w: mano de un pull comprado en k: cartas del héroe y 2 de armas (Filo, Golpe de suerte, Calibre, Cargador ágil;
// en medio y alto, Subir tier de un arma que tiene si se puede). Las técnicas se quedan como salieron.
''', '''// v20w: mano de un pull comprado en k. v20z: sólo cartas del héroe, con la calidad de la rareza r (las técnicas se quedan
// como salieron); las de armas se eligen en Armas.
''')

# ArmC_Hacer: después de las funciones de la cola (las necesita); sigue con la mano comprada.
hacer = funcion('ArmC_Hacer')
src = src.replace(hacer, '', 1)
hacer2 = hacer.replace(U('''    local integer e = Her_Tipo[k]
    if ArmC_Quedan[p] <= 0 then
        return
    endif
'''), U('''    local integer e = Her_Tipo[k]
    local boolean comp = ArmC_Comp[p]
    if ArmC_Quedan[p] <= 0 and not comp then
        return
    endif
'''), 1)
assert hacer2 != hacer
hacer3 = hacer2.replace(U('''    set ArmC_Quedan[p] = ArmC_Quedan[p] - 1
    if ArmC_Quedan[p] > 0 then
        call ArmC_Cartas(p)
    else
        set Cua_Modo[p] = 0
    endif
'''), U('''    // v20z: la mano comprada gasta el primer pull de la cola; después, las de la oleada y luego otra comprada.
    if comp then
        set ArmC_Comp[p] = false
        call HerC_Quitar(p)
    else
        set ArmC_Quedan[p] = ArmC_Quedan[p] - 1
    endif
    set Cop_Log = "cua elige j" + I2S(p) + " armas comprada " + I2S(IntegerTertiaryOp(comp, 1, 0)) + " quedan " + I2S(ArmC_Quedan[p]) + " cola " + I2S(HerC_N[p])
    call ExecuteFunc("Cop_Anotar")
    if ArmC_Quedan[p] > 0 then
        call ArmC_Cartas(p)
    elseif HerC_N[p] > 0 then
        call HerC_AbrirA(p)
    else
        set Cua_Modo[p] = 0
    endif
'''), 1)
assert hacer3 != hacer2

COLA = '''// v20z: cola de pulls comprados de p (hasta 5): rareza y, una vez vistas, sus manos del héroe (HC/HQ/HT) y de armas
// (AC/AQ/AT), 4 cartas cada una en (p * 8 + i) * 4. Todo código común (desde los clics sincronizados).
function HerC_Quitar takes integer p returns nothing
    local integer i = 0
    local integer c
    local integer a
    local integer b
    loop
        exitwhen i >= HerC_N[p] - 1
        set a = p * 8 + i
        set HerC_R[a] = HerC_R[a + 1]
        set HerC_HHecha[a] = HerC_HHecha[a + 1]
        set HerC_AHecha[a] = HerC_AHecha[a + 1]
        set c = 0
        loop
            exitwhen c > 3
            set b = a * 4 + c
            set HerC_HC[b] = HerC_HC[b + 4]
            set HerC_HQ[b] = HerC_HQ[b + 4]
            set HerC_HT[b] = HerC_HT[b + 4]
            set HerC_AC[b] = HerC_AC[b + 4]
            set HerC_AQ[b] = HerC_AQ[b + 4]
            set HerC_AT[b] = HerC_AT[b + 4]
            set c = c + 1
        endloop
        set i = i + 1
    endloop
    set HerC_N[p] = IMaxBJ(0, HerC_N[p] - 1)
endfunction

// v20z: el primer pull de la cola como un paso más del héroe (al final), con la mano que ya tenía si se vio antes.
function HerC_AbrirH takes integer p returns nothing
    local integer k = p * 40 + (2 + Her_Extra[p]) * 5
    local integer b = p * 32
    local integer r = HerC_R[p * 8]
    local integer c = 0
    if not HerC_HayH(p) or HerC_HAb[p] then
        return
    endif
    if HerC_HHecha[p * 8] then
        loop
            exitwhen c > 3
            set Cua_HCand[k + c] = HerC_HC[b + c]
            set Her_Cal[k + c] = HerC_HQ[b + c]
            set Her_Tipo[k + c] = HerC_HT[b + c]
            set c = c + 1
        endloop
    else
        call HerC_Mano(p, k, r)
        set HerC_HHecha[p * 8] = true
    endif
    set Her_ExTipo[p * 8 + Her_Extra[p]] = 3 + r
    set Her_ExMin[p * 8 + Her_Extra[p]] = r
    set Her_Extra[p] = Her_Extra[p] + 1
    set HerC_HAb[p] = true
    call Her_AlDia(p)
endfunction

// v20z: carta de armas para cambiar una maldita en la mano comprada que empieza en k: Filo o Golpe de suerte si no
// están, si no Vida extra.
function HerC_Libre takes integer k returns integer
    local integer c = 0
    local boolean f = false
    local boolean g = false
    loop
        exitwhen c > 3
        set f = f or Cua_HCand[k + c] == 20
        set g = g or Cua_HCand[k + c] == 23
        set c = c + 1
    endloop
    if not f then
        return 20
    elseif not g then
        return 23
    endif
    return 88
endfunction

// v20z: la mano de armas del primer pull de la cola en las cartas de Armas (p * 40 + 35). Se rehace si no se vio o si
// alguna carta ya no vale (Subir tier de un tier que cambió o Arma nueva de un arma que ya tiene).
function HerC_AbrirA takes integer p returns nothing
    local integer k = p * 40 + 35
    local integer b = p * 32
    local integer r = HerC_R[p * 8]
    local integer c = 0
    local integer x
    local integer t
    local boolean rehacer = not HerC_AHecha[p * 8]
    if HerC_N[p] <= 0 then
        return
    endif
    if not rehacer then
        loop
            exitwhen c > 3
            set x = HerC_AC[b + c]
            set Cua_HCand[k + c] = x
            set Her_Cal[k + c] = HerC_AQ[b + c]
            set Her_Tipo[k + c] = HerC_AT[b + c]
            if x == 86 then
                set t = Arm_Tier[p * 7 + HerC_AT[b + c]]
                if t >= 6 or Ronda_Pasadas() < Arm_Req(t + 1) or (t < 5 and HerC_AQ[b + c] != t) or (t >= 5 and HerC_AQ[b + c] != 6) then
                    set rehacer = true
                endif
            elseif x == 87 and Arm_Tier[p * 7 + HerC_AT[b + c]] > 0 then
                set rehacer = true
            endif
            set c = c + 1
        endloop
    endif
    if rehacer then
        call ArmC_Cartas(p)
        set c = 0
        loop
            exitwhen c > 3
            if Her_EsMaldita(Cua_HCand[k + c]) then
                call ArmC_Poner(p, c, HerC_Libre(k), -1)
            endif
            set x = Cua_HCand[k + c]
            if x != 86 and x != 87 and x != 88 then
                set Her_Cal[k + c] = HerC_Cal(r)
            endif
            set c = c + 1
        endloop
        set HerC_AHecha[p * 8] = true
    endif
    set ArmC_Comp[p] = true
endfunction

// v20z: al salir sin elegir (ESC o fin del descanso): el pull abierto vuelve a la cola con las cartas que tenía.
function HerC_Soltar takes integer p returns nothing
    local integer k
    local integer b = p * 32
    local integer c = 0
    if HerC_HAb[p] then
        set HerC_HAb[p] = false
        set Her_Extra[p] = Her_Extra[p] - 1
        set k = p * 40 + (2 + Her_Extra[p]) * 5
        loop
            exitwhen c > 3
            set HerC_HC[b + c] = Cua_HCand[k + c]
            set HerC_HQ[b + c] = Her_Cal[k + c]
            set HerC_HT[b + c] = Her_Tipo[k + c]
            set c = c + 1
        endloop
    endif
    set c = 0
    if ArmC_Comp[p] then
        set ArmC_Comp[p] = false
        set k = p * 40 + 35
        loop
            exitwhen c > 3
            set HerC_AC[b + c] = Cua_HCand[k + c]
            set HerC_AQ[b + c] = Her_Cal[k + c]
            set HerC_AT[b + c] = Her_Tipo[k + c]
            set c = c + 1
        endloop
    endif
endfunction

'''
# Cua_InicioClic también va detrás de la cola (abre los pulls comprados).
inicio = funcion('Cua_InicioClic')
src = src.replace(inicio, '', 1)
compra = funcion('HerC_Comprar')
reemplaza(compra, U(COLA) + hacer3 + '\n' + inicio + U('''
// v20w: compra de un pull de rareza r desde la pantalla de inicio (código común, desde el clic sincronizado).
// v20z: el pull va a la cola (hasta 5) y se gasta en Armas o en Habilidades, donde elija el jugador.
function HerC_Comprar takes integer p, integer r returns nothing
    local integer n = HerC_N[p]
    local integer v = HerC_Precio(r)
    local integer oro = GetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD)
    if not Her_Ok or n >= 5 or oro < v then
        call UI_Error(p)
        return
    endif
    call UI_Click(p)
    call SetPlayerState(Player(p), PLAYER_STATE_RESOURCE_GOLD, oro - v)
    call Oro_Dar(p, R2I(v * Her_Reembolso[p]))
    set HerC_R[p * 8 + n] = r
    set HerC_HHecha[p * 8 + n] = false
    set HerC_AHecha[p * 8 + n] = false
    set HerC_N[p] = n + 1
    set Cop_Log = "pull compra j" + I2S(p) + " rareza " + I2S(r) + " precio " + I2S(v) + " cola " + I2S(HerC_N[p]) + " paso " + I2S(Cua_Paso[p]) + " extra " + I2S(Her_Extra[p]) + " armas " + I2S(ArmC_Quedan[p])
    call ExecuteFunc("Cop_Anotar")
    call Cua_Pintar(p)
    call Cua_Ver(p)
endfunction
'''))
# (el comentario viejo de HerC_Comprar queda justo antes de la cola: se quita)
cambia('''// v20w: compra de un pull de rareza r desde la pantalla de inicio (código común, desde el clic sincronizado).
// v20z: cola de pulls''', '''// v20z: cola de pulls''')

# Cua_Hacer: tras elegir el paso comprado se quita de la cola y, con los pasos hechos, se abre el siguiente comprado.
cambia('''    set Cua_Paso[p] = Cua_Paso[p] + 1
    call Her_AlDia(p)
    // v18m: al terminar Mutación Evo (paso 3) o las mejoras del héroe (paso 5) se vuelve a la pantalla de inicio.
    if Cua_Paso[p] == 3 or Cua_Paso[p] >= Her_FinDe(p) then
        set Cua_Modo[p] = 0
    endif
''', '''    set Cua_Paso[p] = Cua_Paso[p] + 1
    // v20z: el paso elegido era el pull comprado abierto (siempre el último): fuera de la cola.
    if HerC_HAb[p] and Cua_Paso[p] >= Her_FinDe(p) then
        set HerC_HAb[p] = false
        call HerC_Quitar(p)
    endif
    if Cua_Paso[p] > 3 and Cua_Paso[p] >= Her_FinDe(p) and HerC_HayH(p) then
        call HerC_AbrirH(p)
    else
        call Her_AlDia(p)
    endif
    if Cua_Paso[p] >= 3 then
        set Cop_Log = "cua elige j" + I2S(p) + " heroe carta " + I2S(x) + " paso " + I2S(Cua_Paso[p]) + " fin " + I2S(Her_FinDe(p)) + " extra " + I2S(Her_Extra[p]) + " cola " + I2S(HerC_N[p])
        call ExecuteFunc("Cop_Anotar")
    endif
    // v18m: al terminar Mutación Evo (paso 3) o las mejoras del héroe (paso 5) se vuelve a la pantalla de inicio.
    if Cua_Paso[p] == 3 or Cua_Paso[p] >= Her_FinDe(p) then
        set Cua_Modo[p] = 0
    endif
''')
cambia('''(Cua_Modo[p] == 3 and ArmC_Quedan[p] > 0)) then
        call Cua_Hacer(p, Cua_FlaS[p])''', '''(Cua_Modo[p] == 3 and (ArmC_Quedan[p] > 0 or ArmC_Comp[p]))) then
        call Cua_Hacer(p, Cua_FlaS[p])''')
cambia('''(Cua_Modo[p] == 3 and ArmC_Quedan[p] <= 0) or c < 0''', '''(Cua_Modo[p] == 3 and ArmC_Quedan[p] <= 0 and not ArmC_Comp[p]) or c < 0''')
# Salir sin elegir: ESC y fin del descanso.
cambia('''        call Shop_Cerrar(p)
        return
    endif
    set Cua_Modo[p] = 0
    if Cua_Open[p] then
''', '''        call Shop_Cerrar(p)
        return
    endif
    call HerC_Soltar(p)
    set Cua_Modo[p] = 0
    if Cua_Open[p] then
''')
cambia('''        if Cua_Open[p] then
            set Cua_Open[p] = false
            set Cua_Modo[p] = 0
            call Cua_Mostrar(p, false)
''', '''        call HerC_Soltar(p)
        if Cua_Open[p] then
            set Cua_Open[p] = false
            set Cua_Modo[p] = 0
            call Cua_Mostrar(p, false)
''')

# ===================== 2) páginas de iconos del héroe
cambia('''    local integer i = Pan_HN[p]
    local real cx = Title_CX
    if i < 20 then
        set Pan_HX[p * 20 + i] = x
        set Pan_HQ[p * 20 + i] = q
        set Title_CX = 4800.
        set Pan_HIco[p * 20 + i] = Cua_Pic(Pan_IcoX(1, i), Pan_IcoY(i), 52, 52, 393, Pan_Tex(x))
''', '''    local integer i = Pan_HN[p]
    local real cx = Title_CX
    // v20z: hasta 60, de 15 en 15 por página (3 filas).
    if i < 60 then
        set Pan_HX[p * 60 + i] = x
        set Pan_HQ[p * 60 + i] = q
        set Title_CX = 4800.
        set Pan_HIco[p * 60 + i] = Cua_Pic(Pan_IcoX(1, ModuloInteger(i, 15)), Pan_IcoY(ModuloInteger(i, 15)), 52, 52, 393, Pan_Tex(x))
''')
cambia('''    set i = 0
    loop
        exitwhen i >= Pan_HN[p]
        set c = 170
        if Pan_SelH[p] == i + 1 then
            set c = 255
        endif
        call SetUnitVertexColor(Pan_HIco[p * 20 + i], c, c, c, a)
        set i = i + 1
    endloop
''', '''    set i = 0
    loop
        exitwhen i >= Pan_HN[p]
        set c = 170
        if Pan_SelH[p] == i + 1 then
            set c = 255
        endif
        // v20z: sólo los de la página que se ve.
        if i / 15 == Pan_Pag[p] then
            call SetUnitVertexColor(Pan_HIco[p * 60 + i], c, c, c, a)
        else
            call SetUnitVertexColor(Pan_HIco[p * 60 + i], c, c, c, 0)
        endif
        set i = i + 1
    endloop
    // v20z: botones de página con más de 15; el que no lleva a ninguna parte, apagado.
    set i = 0
    loop
        exitwhen i > 1
        if Pan_Nav[i] != null then
            set c = 255
            if (i == 0 and Pan_Pag[p] <= 0) or (i == 1 and Pan_Pag[p] >= (Pan_HN[p] - 1) / 15) then
                set c = 110
            endif
            if on and Pan_HN[p] > 15 then
                call SetUnitVertexColor(Pan_Nav[i], c, c, c, 255)
            else
                call SetUnitVertexColor(Pan_Nav[i], 255, 255, 255, 0)
            endif
        endif
        set i = i + 1
    endloop
''')
cambia('''    if not on then
        set i = 0
        loop
            exitwhen i > 9
            call SetTextTagVisibility(Pan_TT[i], false)
''', '''    if not on then
        set i = 0
        loop
            exitwhen i > 12
            call SetTextTagVisibility(Pan_TT[i], false)
''')
cambia('''    call SetTextTagVisibility(Pan_TT[5], Pan_HN[p] == 0)
''', '''    call SetTextTagVisibility(Pan_TT[5], Pan_HN[p] == 0)
    // v20z: página de los iconos del héroe.
    if Pan_HN[p] > 15 then
        call Cua_Centro(p, Pan_TT[10], I2S(Pan_Pag[p] + 1) + "/" + I2S((Pan_HN[p] - 1) / 15 + 1), 1710, 431, 0.02)
        call Cua_Centro(p, Pan_TT[11], "<", 1620, 431, 0.024)
        call Cua_Centro(p, Pan_TT[12], ">", 1800, 431, 0.024)
        call SetTextTagColor(Pan_TT[10], 230, 230, 235, 255)
        call SetTextTagColor(Pan_TT[11], 255, 236, 200, 255)
        call SetTextTagColor(Pan_TT[12], 255, 236, 200, 255)
    endif
    call SetTextTagVisibility(Pan_TT[10], Pan_HN[p] > 15)
    call SetTextTagVisibility(Pan_TT[11], Pan_HN[p] > 15)
    call SetTextTagVisibility(Pan_TT[12], Pan_HN[p] > 15)
''')
cambia('''        set i = p * 20 + Pan_SelH[p] - 1
''', '''        set i = p * 60 + Pan_SelH[p] - 1
''')
cambia('''    loop
        exitwhen i > 9
        set Pan_TT[i] = Cua_Tag()
''', '''    loop
        exitwhen i > 12
        set Pan_TT[i] = Cua_Tag()
''')
cambia('''    loop
        exitwhen i > 9
        call DestroyTextTag(Pan_TT[i])
''', '''    loop
        exitwhen i > 12
        call DestroyTextTag(Pan_TT[i])
''')
cambia('''    else
        set i = k - 80
        if i < Pan_HN[p] then
            call UI_Click(p)
            set Pan_SelH[p] = i + 1
            call Pan_Detalle(p, 1, Pan_Tex(Pan_HX[p * 20 + i]))
        endif
    endif
''', '''    elseif k <= 99 then
        // v20z: icono de la página que se ve.
        set i = Pan_Pag[p] * 15 + k - 80
        if k - 80 < 15 and i < Pan_HN[p] then
            call UI_Click(p)
            set Pan_SelH[p] = i + 1
            call Pan_Detalle(p, 1, Pan_Tex(Pan_HX[p * 60 + i]))
        endif
    elseif k == 100 and Pan_Pag[p] > 0 then
        call UI_Click(p)
        set Pan_Pag[p] = Pan_Pag[p] - 1
    elseif k == 101 and Pan_Pag[p] < (Pan_HN[p] - 1) / 15 then
        call UI_Click(p)
        set Pan_Pag[p] = Pan_Pag[p] + 1
    endif
''')
cambia('''// v19r: k 60-62 pestañas, 70-79 iconos de mutación de la pestaña, 80-99 iconos del héroe.
''', '''// v19r: k 60-62 pestañas, 70-79 iconos de mutación de la pestaña, 80-99 iconos del héroe.
// v20z: 80-94 iconos de la página del héroe; 100 y 101 página anterior y siguiente.
''')
cambia('''    set Pan_Pz[6] = Cua_Pic(1710, 205, 316, 34, 396, 'DS06')
    set Pan_PzN = 7
''', '''    set Pan_Pz[6] = Cua_Pic(1710, 205, 316, 34, 396, 'DS06')
    set Pan_PzN = 7
    // v20z: botones de página del panel del héroe (fila de abajo del cuadro).
    set Pan_Nav[0] = Cua_Pic(1620, 442, 56, 34, 396, 'DS06')
    set Pan_Nav[1] = Cua_Pic(1800, 442, 56, 34, 396, 'DS06')
''')
cambia('''                call Shop_Pista(p, "war3mapImported\\\\CuaHitIco.mdx", Pan_IcoX(1, i), Pan_IcoY(i), 80 + i)
                set i = i + 1
            endloop
''', '''                if i < 15 then
                    call Shop_Pista(p, "war3mapImported\\\\CuaHitIco.mdx", Pan_IcoX(1, i), Pan_IcoY(i), 80 + i)
                endif
                set i = i + 1
            endloop
            call Shop_Pista(p, "war3mapImported\\\\CuaHitIco.mdx", 1620, 442, 100)
            call Shop_Pista(p, "war3mapImported\\\\CuaHitIco.mdx", 1800, 442, 101)
''')

# ===================== 3) rachas: icono del personaje y sin voz
cambia('''        call Racha_Anunciar(Racha_ColaTexto[0], Racha_ColaPid[0])
        call Racha_Sonar(Racha_ColaSon[0])
        if Racha_ColaTipo[0] == 4 then
            set Racha_Espera = Racha_ColaDur[0] + 0.3
        else
            set Racha_VozPid = Racha_ColaPid[0]
            set Racha_VozEn = Racha_ColaDur[0] - 0.2
            set Racha_Espera = Racha_ColaDur[0] + 1.9
        endif
''', '''        call Racha_Anunciar(Racha_ColaTexto[0], Racha_ColaPid[0])
        call Racha_Sonar(Racha_ColaSon[0])
        // v20z: sin la voz del personaje después del anuncio; el siguiente entra al acabar este.
        set Racha_Espera = Racha_ColaDur[0] + 0.3
''')
cambia('''    set Racha_CCairne[n] = Racha_EsCairne(p)
''', '''    set Racha_CCairne[n] = Racha_EsCairne(p)
    // v20z: icono del personaje de p (piel de la selección).
    set Racha_CIco[n] = Hero_Icon[IMaxBJ(0, Hero_Choice[p])]
    if Racha_CIco[n] == 0 then
        set Racha_CIco[n] = 'DT3Q'
    endif
''')
cambia('''                // Mostrar antes de elegir la animación: el cambio de visibilidad puede reiniciarla.
                call ShowUnit(Racha_Cara[v * 2 + 1 - j], false)
                call ShowUnit(Racha_Cara[v * 2 + j], true)
                // 44 px de alto; el retrato mide 21,4 de alto a escala 1 (Hero_PortraitScale).
                set e = 50. * ( 0.302 / 387.73819261 ) * ( 398. + d ) / 21.4 * Racha_AjS
                call SetUnitScale(Racha_Cara[v * 2 + j], e, e, e)
                set Racha_VHabla[v] = -1
''', '''                // Mostrar antes de elegir la animación: el cambio de visibilidad puede reiniciarla.
                // v20z: icono del personaje (46 px) en lugar del retrato.
                call ShowUnit(Racha_Cara[v * 2], true)
                call Racha_Foto(Racha_Cara[v * 2], 46., 46., Racha_CIco[k])
''')
cambia('''                call ShowUnit(Racha_Cara[v * 2], false)
                call ShowUnit(Racha_Cara[v * 2 + 1], false)
''', '''                call ShowUnit(Racha_Cara[v * 2], false)
''')
cambia('''            set a = 0
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
            call HealthBars__Place(Racha_Cara[v * 2 + j] , cam , cx + 170.6 + Racha_AjX , y + Racha_AjY , 398. + d)
''', '''            call HealthBars__Place(Racha_Caja[v] , cam , cx , y , 400. + d)
            call HealthBars__Place(Racha_Cara[v * 2] , cam , cx + 170.6 , y , 398. + d)
''')
cambia('''            set Racha_Cara[( p * 5 + i ) * 2] = HealthBars__Dummy('dta0', p)
            set Racha_Cara[( p * 5 + i ) * 2 + 1] = HealthBars__Dummy('dca0', p)
            call UnitAddAbility(Racha_Cara[( p * 5 + i ) * 2], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Cara[( p * 5 + i ) * 2], s__Interface_LOCUST_ID)
            call UnitAddAbility(Racha_Cara[( p * 5 + i ) * 2 + 1], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Cara[( p * 5 + i ) * 2 + 1], s__Interface_LOCUST_ID)
''', '''            // v20z: una pieza de interfaz con el icono del personaje (antes retratos Tauren y Cairne).
            set Racha_Cara[( p * 5 + i ) * 2] = HealthBars__Dummy('uidb', p)
            call UnitAddAbility(Racha_Cara[( p * 5 + i ) * 2], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(Racha_Cara[( p * 5 + i ) * 2], s__Interface_LOCUST_ID)
            call Racha_Foto(Racha_Cara[( p * 5 + i ) * 2] , 46. , 46. , 'DT3Q')
            set Racha_Cara[( p * 5 + i ) * 2 + 1] = null
''')

if prueba:
    for viejo, nuevo in (('lat\\\\v20y-', 'lat\\\\v20z-'), ('v20y-don.txt', 'v20z-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20z', 'prueba' if prueba else 'normal')
