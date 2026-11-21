#!/usr/bin/env python3
"""v17m (14/11/2026): marcador oculto y barra de vida del jefe de ronda a la derecha.

Leon: "ocultaremos ahora la multiboard ... en el sistema de interfaz ya se tiene otra barra de vida oculta pero a la
derecha ... con esa nueva barra se colocara el icono del boss jefe de la wave con su animacion como recargandose la barra
y al completarse liberandose el boss o dando spawn en el mapa, esa barra de vida de jefe saldra entrando en pantalla,
cuando el boss muere se vuelve a ocultar desplazandose hacia derecha para desaparecer de la pantalla".
- El multiboard "Marcador" no se muestra (la tabla sigue creándose y actualizándose, para usarla después).
- La barra derecha del HUD (HealthBars__EnemyBars: 1358,4 × 48,6 px a distancia 400, la misma que la del jugador a
  24 × 48,6 a 400) nunca se usaba. Ahora, al terminar la presentación del jefe, entra desde la derecha una barra igual con
  el icono del jefe de la ronda ('hbk2'..'hbkA', jefe_barras_v17m.py) en 0,30 s, se carga de 0 a 100 % en 2,50 s y al
  llenarse se libera al jefe (JefePres_Lista, antes al terminar la presentación). Con el jefe en el mapa muestra su vida
  y el porcentaje (el texto de la barra derecha, HealthBars__EnemyValues). Al morir sale hacia la derecha en 0,30 s.
- Todo se calcula con el reloj de la barra en todos los clientes, como la presentación: la vista es sólo del dueño
  (alfa local de HealthBars__Dummy). Se oculta con la tienda abierta, como las demás piezas del HUD.
- En la de prueba, "-pres N" también muestra la barra: se carga, espera 1,5 s llena y sale, sin liberar a ningún jefe.
Uso: v17m.py v17l/war3map.j SALIDA.j (y v17l-prueba/war3map.j para la de prueba)
"""
from pathlib import Path
import sys

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues, n=1):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == n, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


# --- marcador oculto ---
una('''            call MultiboardDisplay(Racha_Tabla, shown)
            if shown then
                call MultiboardMinimize(Racha_Tabla, false)
            endif
''', '''            // v17m: el marcador no se muestra; la tabla sigue al día para usarla después.
            call MultiboardDisplay(Racha_Tabla, false)
''')

# --- globales ---
una('boolean JefePres_EsDemo= false\n', '''boolean JefePres_EsDemo= false
unit array JefeBarra_Pieza
integer array JefeBarra_Pct
string array JefeBarra_Txt
integer JefeBarra_Estado= 0
boolean JefeBarra_Demo= false
boolean JefeBarra_Visto= false
real JefeBarra_T0= 0.
timer JefeBarra_Reloj= null
''')

# --- bloque de la barra, antes de JefePres_Fin ---
una('function JefePres_Fin takes nothing returns nothing\n', '''// v17m (scripts/v17m.py): barra de vida del jefe a la derecha del HUD, en el sitio de la barra de enemigo
// (HealthBars__EnemyBars, 1358,4 × 48,6 px a distancia 400, igual que la del jugador). Estados: 0 fuera; 1 entra en
// 0,30 s y se carga en 2,50 s; 2 llena, libera al jefe y muestra su vida; 3 sale hacia la derecha en 0,30 s.
function JefeBarra_Quitar takes nothing returns nothing
    local integer p = 0
    loop
        exitwhen p > 11
        if JefeBarra_Pieza[p] != null then
            call RemoveUnit(JefeBarra_Pieza[p])
            set JefeBarra_Pieza[p] = null
        endif
        set p = p + 1
    endloop
    set JefeBarra_Estado = 0
endfunction

function JefeBarra_Entrar takes boolean demo returns nothing
    local integer p = 0
    local integer id = 'hbk0' + JefePres_N
    if JefePres_N == 10 then
        set id = 'hbkA'
    endif
    call JefeBarra_Quitar()
    if JefeBarra_Reloj == null then
        set JefeBarra_Reloj = CreateTimer()
    endif
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
            set JefeBarra_Pieza[p] = HealthBars__Dummy(id, p)
            call ShowUnit(JefeBarra_Pieza[p], false)
            call SetUnitAnimationByIndex(JefeBarra_Pieza[p], 0)
            set JefeBarra_Pct[p] = 0
            set JefeBarra_Txt[p] = ""
        endif
        set p = p + 1
    endloop
    set JefeBarra_Demo = demo
    set JefeBarra_Visto = false
    set JefeBarra_Estado = 1
    call TimerStart(JefeBarra_Reloj, 100000., false, null)
endfunction

// Una vez por repaso del HUD, igual en todos los clientes.
function JefeBarra_Tick takes nothing returns nothing
    local real t
    local boolean vivo
    if JefeBarra_Estado == 0 then
        return
    endif
    set t = TimerGetElapsed(JefeBarra_Reloj)
    set vivo = DevJefe != null and GetUnitTypeId(DevJefe) != 0 and GetWidgetLife(DevJefe) > 0.405
    if JefeBarra_Estado == 1 and t >= 2.80 then
        set JefeBarra_Estado = 2
        if not JefeBarra_Demo then
            set JefePres_Lista = true
        endif
    endif
    if JefeBarra_Estado == 2 then
        if vivo then
            set JefeBarra_Visto = true
        endif
        if (JefeBarra_Demo and t >= 4.30) or (not JefeBarra_Demo and JefeBarra_Visto and not vivo) or (not JefeBarra_Demo and not JefeBarra_Visto and not JefePres_Lista) then
            set JefeBarra_Estado = 3
            set JefeBarra_T0 = t
        endif
    endif
    if JefeBarra_Estado == 3 and t >= JefeBarra_T0 + 0.30 then
        call JefeBarra_Quitar()
    endif
endfunction

function JefeBarra_Poner takes integer p, integer cam returns nothing
    local unit u = JefeBarra_Pieza[p]
    local real t
    local real dx = 0.
    local integer pct = 100
    local string label = ""
    local boolean vis
    if u == null then
        return
    endif
    set t = TimerGetElapsed(JefeBarra_Reloj)
    set vis = HealthBars__Visible and not Shop_Open[p]
    if JefeBarra_Estado == 1 then
        set dx = 600. * (1. - JefePres_Frena(t / 0.30))
        set pct = R2I(100. * RMaxBJ(0., RMinBJ(1., (t - 0.30) / 2.50)))
    elseif JefeBarra_Estado == 3 then
        set dx = 600. * JefePres_Acelera((t - JefeBarra_T0) / 0.30)
    endif
    if JefeBarra_Estado >= 2 and JefeBarra_Visto then
        set pct = HealthBars__Percent(DevJefe)
        set label = I2S(pct) + "%"
    endif
    call HealthBars__Place(u, cam, 1358.4 + dx, 48.6, 400.)
    call Hud_Ver(u, vis)
    if pct != JefeBarra_Pct[p] then
        set JefeBarra_Pct[p] = pct
        call SetUnitAnimationByIndex(u, pct)
    endif
    if label != JefeBarra_Txt[p] then
        set JefeBarra_Txt[p] = label
        if label != "" then
            call JefeTx_Texto(HealthBars__EnemyValues[p], s__UIText_text[HealthBars__EnemyValues[p]], label, 0.017)
        endif
    endif
    if label != "" then
        call s__UIText_setPosition(HealthBars__EnemyValues[p], (1837.2 + dx - I2R(StringLength(label)) * 4.5 - 960.) / 728., (420. - 159.) / 390.)
    endif
    call s__UIText_show(HealthBars__EnemyValues[p], vis and label != "", cam)
    set u = null
endfunction

function JefePres_Fin takes nothing returns nothing
''')

# --- la presentación ya no libera al jefe: lo hace la barra al llenarse ---
una('''    if not JefePres_EsDemo then
        set JefePres_Lista = true
    endif
    set JefePres_EsDemo = false
''', '''    // v17m: el jefe sale cuando se llena su barra (JefeBarra_Tick).
    call JefeBarra_Entrar(JefePres_EsDemo)
    set JefePres_EsDemo = false
''')

# --- la puerta del jefe no relanza la presentación mientras la barra se carga ---
una('''                if not JefePres_Activa then
                    call ExecuteFunc("JefePres_Empezar")''', '''                if not JefePres_Activa and JefeBarra_Estado != 1 then
                    call ExecuteFunc("JefePres_Empezar")''')

# --- HUD ---
una('    call JefePres_Tick()\n', '    call JefePres_Tick()\n    call JefeBarra_Tick()\n')
una('            call JefePres_Poner(p , cam)\n', '            call JefePres_Poner(p , cam)\n            call JefeBarra_Poner(p , cam)\n')
una('''            call s__UIText_show(HealthBars__EnemyValues[p],shown , cam)
            if poll then''', '''            if JefeBarra_Pieza[p] == null then
                call s__UIText_show(HealthBars__EnemyValues[p],shown , cam)
            endif
            if poll then''')

una('// v17h: presentación del jefe de ronda (scripts/v17h.py); v17l',
    '// v17h: presentación del jefe de ronda (scripts/v17h.py); v17m (scripts/v17m.py): barra del jefe y marcador oculto;\n// v17l')
Path(sys.argv[2]).write_bytes(j.encode('latin-1'))
print('v17m: marcador oculto y barra del jefe')
