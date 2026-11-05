#!/usr/bin/env python3
"""v14h: tienda que baja al terminar cada oleada, zonas de munición, élites con la vida del jefe y Burning Rage.
Plan: Proyect/docs/planes/devmission-tienda-municion-v14h.md. Objetos de scripts/objetos_v14h.py y modelos de
scripts/efectos_v14h.py.

- Tienda (Shop_Golem): no está al empezar. Espera oculta a 4000 de altura sobre uno de los 10 puntos 'nPtA', con el
  facing de su campesino de referencia ('hpea' más cercano). Al terminar una oleada baja dormida y frenando (3 s)
  hasta el suelo, nace y queda en stand. Al acabar el descanso sube dormida acelerando, se oculta arriba y pasa a otro
  punto al azar, nunca el mismo dos veces seguidas. Se recrea en cada punto para nacer con su facing.
- Sin clic: a 300 o menos, en el descanso, un texto en el centro "Press [ESC] to buy supplies" en degradado azul
  claro, blanco y rojo; ESC abre la tienda y ESC dentro la cierra.
- Descanso único de 45 s, sin la pausa de la tienda abierta. En la tienda se ve también el tiempo; a 10 s o menos
  parpadea en rojo, igual que en el HUD. A 0 se cierra la tienda.
- Zonas de munición (20 puntos 'nPtB'): 2 activas al azar en la oleada 1 y 2 más en cada oleada. Radiance Nature
  (verde) si el jugador no la ha usado en esta oleada, Crimson (roja) si ya; un efecto por zona y jugador con el
  modelo sólo en su cliente. A 250 o menos, "[ESC] Pick up Ammo": ESC llena el cargador de todas sus armas y suma un
  cargador a la reserva sin pasar del máximo. Vuelven a verde al empezar la oleada siguiente. Se usan en ronda y
  descanso; si hay zona y tienda a mano, ESC toma la munición.
- Localizador de la tienda: como el del jefe, con icono 'hbjt' y esfera azul 'ubjt', en ronda y descanso; apunta al
  punto aunque la tienda esté arriba oculta.
- Élites: siempre 1 por tipo y oleada. Vida 45% de la del jefe de la oleada: 0,45 × 800 × (1 + 0,75 (r − 1)) ×
  jugadores; la base 360 es la del w3u y el resto lo suman 'ALh0'..'ALhA' en binario (múltiplos de 10).
- Burning Rage: un color por tipo k (élite 'ne0k' y jefe del tipo k, que sale en la ronda k + 1): verde, turquesa,
  azul, púrpura, rosa, amarillo, naranja, rojo, plata y violeta, sobre la cabeza (`overhead`). Se quita al morir.
- UnitHitShape de élites y jefes con selección × 2,1 y × 2,7; barras 110 más arriba en élites y 170 en jefes.
- Puntos de oleada: los 100 'nPto' del mapa de puntos guardado por el usuario.

Uso: v14h.py ENTRADA.j SALIDA.j UNITS_DOO
"""
from pathlib import Path
import math
import re
import struct
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
from objetos_v14g import TIPOS, escalada, formas
from puntos_editor_v13b import registros

ELITE, JEFE = 2.1, 2.7
ALTO, ACEL, BAJA = 4000., 2400., 3.0

ent, sal, doo = sys.argv[1], sys.argv[2], sys.argv[3]
s = Path(ent).read_text(encoding='latin-1', newline='')


class base:  # war3map.j lleva UTF-8 leído como latin-1: los textos con tildes se pasan igual.
    @staticmethod
    def once(s, a, b):
        return __import__('puente_v12').once(s, a.encode().decode('latin-1'), b.encode().decode('latin-1'))


# Puntos del mapa guardado.
u = Path(doo).read_bytes()
pts = {}
for a, c in registros(u):
    x, y = struct.unpack_from('<ff', u, a + 8)
    ang = struct.unpack_from('<f', u, a + 20)[0]
    pts.setdefault(u[a:a + 4], []).append((round(x), round(y), ang))
assert [len(pts[k]) for k in (b'nPto', b'nPtA', b'nPtB', b'hpea')] == [100, 10, 20, 10], {k: len(v) for k, v in pts.items()}
tienda = []
for x, y, _ in pts[b'nPtA']:
    _, _, ang = min(pts[b'hpea'], key=lambda q: (q[0] - x) ** 2 + (q[1] - y) ** 2)
    tienda.append((x, y, round(math.degrees(ang)) % 360))


def r(v):
    return f'{float(v):.1f}'


def degradado(texto):
    """Cada letra con su color: azul claro, blanco y rojo."""
    paradas = [(115, 200, 255), (235, 240, 245), (255, 48, 48)]
    n, out = len(texto), []
    for i, ch in enumerate(texto):
        f = i / max(1, n - 1) * 2
        a, b = paradas[min(1, int(f))], paradas[min(2, int(f) + 1)]
        t = f - min(1, int(f))
        out.append('|cff%02x%02x%02x%s' % tuple([round(a[j] + (b[j] - a[j]) * t) for j in range(3)] + [ch]))
    return ''.join(out) + '|r'


AVISO_TIENDA, AVISO_BALAS = 'Press [ESC] to buy supplies', '[ESC] Pick up Ammo'

s = base.once(s, 'real Title_CX=', '''integer DevTienda_Estado= 0
integer DevTienda_Punto= - 1
boolean DevTienda_Pendiente= false
real DevTienda_T= 0.
real DevTienda_H0= 0.
real array DevTienda_X
real array DevTienda_Y
real array DevTienda_F
timer DevTienda_Reloj= null
unit array DevTienda_Icono
unit array DevTienda_Esfera
integer array DevTienda_Aviso
integer array DevTienda_AvisoK
real array Recarga_X
real array Recarga_Y
boolean array Recarga_On
boolean array Recarga_Usada
effect array Recarga_Fx
boolean array Ronda_CifraRoja
texttag Shop_RelojT= null
string Shop_RelojVisto= ""
boolean Shop_RelojRojo= false
hashtable DevFuego_HT= InitHashtable()
real Title_CX=''')

# Descanso único de 45 s.
s = base.once(s, 'constant integer Ronda_DESCANSO = 30', 'constant integer Ronda_DESCANSO = 45')
s = base.once(s, '''    // La tienda abierta detiene el descanso, hasta 120 s por descanso.
    if Shop_Abiertos > 0 and Shop_Pausa < 120 then
        set Shop_Pausa = Shop_Pausa + 1
        return
    endif
    set Ronda_Resta''', '''    set Ronda_Resta''')

# A 10 s o menos la cifra del descanso parpadea en rojo (2 Hz).
s = base.once(s, '''        if c != Ronda_CifraVista[p] then
            set Ronda_CifraVista[p]=c
            call Ronda_Texto(Ronda_Cifra[p] , c , 0.024 , Ronda_CIFRA_Y)
        endif
''', '''        if c != Ronda_CifraVista[p] then
            set Ronda_CifraVista[p]=c
            call Ronda_Texto(Ronda_Cifra[p] , c , 0.024 , Ronda_CIFRA_Y)
        endif
        if ( Ronda_Descanso and Ronda_Resta <= 10 and ModuloInteger(R2I(TimerGetElapsed(s__RapidPair_clock) * 4.), 2) == 0 ) != Ronda_CifraRoja[p] then
            set Ronda_CifraRoja[p]=not Ronda_CifraRoja[p]
            if Ronda_CifraRoja[p] then
                call SetTextTagColor(s__UIText_text[Ronda_Cifra[p]], 255, 48, 48, 255)
            else
                call SetTextTagColor(s__UIText_text[Ronda_Cifra[p]], 255, 255, 255, 255)
            endif
        endif
''')

# Localizador de la tienda: el del jefe con otro destino. Apunta al punto aunque la tienda esté arriba.
i = s.index('function DevJefe_Poner takes')
jefe = s[i:s.index('endfunction', i) + len('endfunction')]
loc = jefe
for a, b in [('function DevJefe_Poner', 'function DevTienda_Poner'), ('DevJefe_Icono[p]', 'DevTienda_Icono[p]'),
             ('DevJefe_Esfera[p]', 'DevTienda_Esfera[p]'),
             ('if DevJefe == null or GetWidgetLife(DevJefe) <= 0.405 or not HealthBars__Visible then',
              'if Shop_Golem == null or not Ronda_Activa or not HealthBars__Visible then'),
             ('GetUnitX(DevJefe)', 'GetUnitX(Shop_Golem)'), ('GetUnitY(DevJefe)', 'GetUnitY(Shop_Golem)'),
             ('GetUnitFlyHeight(DevJefe) + 80.', '150.')]:
    assert loc.count(a) >= 1, a
    loc = loc.replace(a, b)
assert 'DevJefe' not in loc

PUNTOS = ''.join(f'''    set DevTienda_X[{k}]={r(x)}
    set DevTienda_Y[{k}]={r(y)}
    set DevTienda_F[{k}]={r(f)}
''' for k, (x, y, f) in enumerate(tienda)) + ''.join(f'''    set Recarga_X[{k}]={r(x)}
    set Recarga_Y[{k}]={r(y)}
''' for k, (x, y, _) in enumerate(pts[b'nPtB']))

TIENDA = f'''// v14h (scripts/v14h.py): puntos de la tienda ('nPtA', facing de su campesino) y de las zonas de munición ('nPtB').
function DevTienda_Datos takes nothing returns nothing
{PUNTOS}endfunction

// Oculta arriba, sobre un punto distinto del anterior. Se recrea para nacer con el facing del punto.
function DevTienda_Mudar takes nothing returns nothing
    local integer k
    if DevTienda_Punto < 0 then
        set k=GetRandomInt(0, 9)
    else
        set k=GetRandomInt(0, 8)
        if k >= DevTienda_Punto then
            set k=k + 1
        endif
    endif
    set DevTienda_Punto=k
    if Shop_Golem != null then
        call RemoveUnit(Shop_Golem)
    endif
    set Shop_Golem=CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'ngst', DevTienda_X[k], DevTienda_Y[k], DevTienda_F[k])
    call SetUnitInvulnerable(Shop_Golem, true)
    call UnitAddAbility(Shop_Golem, s__Interface_DESTROYER_FORM_ID)
    call UnitRemoveAbility(Shop_Golem, s__Interface_DESTROYER_FORM_ID)
    call SetUnitX(Shop_Golem, DevTienda_X[k])
    call SetUnitY(Shop_Golem, DevTienda_Y[k])
    call SetUnitFlyHeight(Shop_Golem, {r(ALTO)}, 0.)
    call ShowUnit(Shop_Golem, false)
    set DevTienda_Estado=0
endfunction

// Estados: 0 arriba oculta, 1 bajando, 2 en el suelo, 3 subiendo.
function DevTienda_Bajar takes nothing returns nothing
    if DevTienda_Estado == 3 then
        set DevTienda_Pendiente=true
        return
    elseif DevTienda_Estado != 0 then
        return
    endif
    call ShowUnit(Shop_Golem, true)
    call SetUnitAnimation(Shop_Golem, "sleep")
    set DevTienda_T=0.
    set DevTienda_Estado=1
endfunction

function DevTienda_Subir takes nothing returns nothing
    set DevTienda_Pendiente=false
    if DevTienda_Estado == 0 or DevTienda_Estado == 3 then
        return
    endif
    set DevTienda_H0=GetUnitFlyHeight(Shop_Golem)
    call SetUnitAnimation(Shop_Golem, "sleep")
    set DevTienda_T=0.
    set DevTienda_Estado=3
endfunction

// Cada 0,03 s: baja frenando (altura × (1 − t / {BAJA})²) y sube acelerando ({r(ACEL)} / s²).
function DevTienda_Paso takes nothing returns nothing
    local real h
    if DevTienda_Estado == 1 then
        set DevTienda_T=DevTienda_T + 0.03
        if DevTienda_T >= {BAJA} then
            call SetUnitFlyHeight(Shop_Golem, 0., 0.)
            call SetUnitAnimation(Shop_Golem, "birth")
            call QueueUnitAnimation(Shop_Golem, "stand")
            set DevTienda_Estado=2
        else
            set h=1. - DevTienda_T / {BAJA}
            call SetUnitFlyHeight(Shop_Golem, {r(ALTO)} * h * h, 0.)
        endif
    elseif DevTienda_Estado == 3 then
        set DevTienda_T=DevTienda_T + 0.03
        set h=DevTienda_H0 + 0.5 * {r(ACEL)} * DevTienda_T * DevTienda_T
        if h >= {r(ALTO)} then
            call DevTienda_Mudar()
            if DevTienda_Pendiente then
                set DevTienda_Pendiente=false
                call DevTienda_Bajar()
            endif
        else
            call SetUnitFlyHeight(Shop_Golem, h, 0.)
        endif
    endif
endfunction

function DevTienda_Cerca takes integer p returns boolean
    return Ronda_Activa and Ronda_Descanso and Ronda_Numero < Ronda_TOTAL and DevTienda_Estado == 2 and UnitAlive(Game_Hero[p]) and IsUnitInRange(Game_Hero[p], Shop_Golem, 300.)
endfunction

// Zona activa que el jugador aún no usó en esta oleada, a 250 o menos; - 1 si no hay.
function Recarga_Cerca takes integer p returns integer
    local integer z= 0
    if not Ronda_Activa or not UnitAlive(Game_Hero[p]) then
        return - 1
    endif
    loop
        exitwhen z > 19
        if Recarga_On[z] and not Recarga_Usada[p * 20 + z] and IsUnitInRangeXY(Game_Hero[p], Recarga_X[z], Recarga_Y[z], 250.) then
            return z
        endif
        set z=z + 1
    endloop
    return - 1
endfunction

// Un efecto por zona y jugador, creado en todos los clientes; el modelo sólo en el del jugador.
function Recarga_Pintar takes integer p, integer z returns nothing
    local string m= ""
    if Recarga_Fx[p * 20 + z] != null then
        call DestroyEffect(Recarga_Fx[p * 20 + z])
        set Recarga_Fx[p * 20 + z]=null
    endif
    if Recarga_On[z] and Game_On[p] then
        if GetLocalPlayer() == Player(p) then
            if Recarga_Usada[p * 20 + z] then
                set m="war3mapImported\\\\RecargaRoja.mdx"
            else
                set m="war3mapImported\\\\RecargaVerde.mdx"
            endif
        endif
        set Recarga_Fx[p * 20 + z]=AddSpecialEffect(m, Recarga_X[z], Recarga_Y[z])
    endif
endfunction

// Al empezar cada oleada: 2 zonas más al azar y todas verdes otra vez.
function Recarga_Ronda takes nothing returns nothing
    local integer n= 0
    local integer z
    local integer q
    local integer libres= 0
    local integer p
    set z=0
    loop
        exitwhen z > 19
        if not Recarga_On[z] then
            set libres=libres + 1
        endif
        set z=z + 1
    endloop
    loop
        exitwhen n >= 2 or libres == 0
        set q=GetRandomInt(0, libres - 1)
        set z=0
        loop
            if not Recarga_On[z] then
                exitwhen q == 0
                set q=q - 1
            endif
            set z=z + 1
        endloop
        set Recarga_On[z]=true
        set libres=libres - 1
        set n=n + 1
    endloop
    set z=0
    loop
        exitwhen z > 19
        set p=0
        loop
            exitwhen p > 11
            set Recarga_Usada[p * 20 + z]=false
            call Recarga_Pintar(p , z)
            set p=p + 1
        endloop
        set z=z + 1
    endloop
endfunction

function DevTienda_AvisoPoner takes integer ui, string s, integer n returns nothing
    call s__UIText_setPosition(ui,( - I2R(n) * 4.5 * 0.026 / 0.017 ) / 728. , ( 420. - 520. ) / 390.)
    call SetTextTagText(s__UIText_text[ui], s, 0.026)
endfunction

// Aviso en el centro (sólo en el cliente del jugador, UIText local) y el localizador de la tienda.
function DevTienda_Hud takes integer p, integer cam returns nothing
    local integer k= 0
    if DevTienda_Icono[p] == null then
        set DevTienda_Icono[p]=HealthBars__Dummy('hbjt' , p)
        call ShowUnit(DevTienda_Icono[p], false)
        set DevTienda_Esfera[p]=HealthBars__Dummy('ubjt' , p)
        call UnitAddAbility(DevTienda_Esfera[p], s__Interface_LOCUST_ID)
        call UnitRemoveAbility(DevTienda_Esfera[p], s__Interface_LOCUST_ID)
        call SetUnitScale(DevTienda_Esfera[p], 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ))
        call ShowUnit(DevTienda_Esfera[p], false)
        set DevTienda_Aviso[p]=s__UIText_createEx(Player(p) , 0. , 0. , 1.)
        call SetTextTagPermanent(s__UIText_text[DevTienda_Aviso[p]], true)
        call SetTextTagColor(s__UIText_text[DevTienda_Aviso[p]], 255, 255, 255, 255)
    endif
    call DevTienda_Poner(p , cam)
    if HealthBars__Visible and not Shop_Open[p] then
        if Recarga_Cerca(p) >= 0 then
            set k=2
        elseif DevTienda_Cerca(p) then
            set k=1
        endif
    endif
    if k != DevTienda_AvisoK[p] then
        set DevTienda_AvisoK[p]=k
        if k == 1 then
            call DevTienda_AvisoPoner(DevTienda_Aviso[p] , "{degradado(AVISO_TIENDA)}" , {len(AVISO_TIENDA)})
        elseif k == 2 then
            call DevTienda_AvisoPoner(DevTienda_Aviso[p] , "{degradado(AVISO_BALAS)}" , {len(AVISO_BALAS)})
        endif
    endif
    call s__UIText_show(DevTienda_Aviso[p],k != 0 , cam)
endfunction

'''

# loc viene de s, ya en latin-1: sólo TIENDA se pasa como los demás textos.
s = __import__('puente_v12').once(s, 'function HealthBarsUpdate takes nothing returns nothing', loc + '\n\n' + TIENDA.encode().decode('latin-1') + 'function HealthBarsUpdate takes nothing returns nothing')
s = base.once(s, '''            call DevJefe_Poner(p , cam)
''', '''            call DevJefe_Poner(p , cam)
            call DevTienda_Hud(p , cam)
''')

# Oleadas: la tienda sube al empezar y baja al terminar; zonas nuevas en cada oleada.
s = base.once(s, '''    set Ronda_Descanso = false
    set Ronda_Activa = true
    call DevWave_Start(Ronda_Numero)''', '''    set Ronda_Descanso = false
    set Ronda_Activa = true
    call DevTienda_Subir()
    call Recarga_Ronda()
    call DevWave_Start(Ronda_Numero)''')
s = base.once(s, '''        else
            call TimerStart(Ronda_Reloj, 1., true, function Ronda_Cuenta)
        endif''', '''        else
            call TimerStart(Ronda_Reloj, 1., true, function Ronda_Cuenta)
            call DevTienda_Bajar()
        endif''')

# Tienda: sin clic, alcance 300 y sólo con la tienda en el suelo.
s = base.once(s, 'not UnitAlive(Game_Hero[p]) or not IsUnitInRange(Game_Hero[p], Shop_Golem, 600.) then',
              'not UnitAlive(Game_Hero[p]) or DevTienda_Estado != 2 or not IsUnitInRange(Game_Hero[p], Shop_Golem, 300.) then')
s = base.once(s, '''    if GetTriggerUnit() == Shop_Golem then
        call Shop_Abrir(p)
    elseif''', '''    if GetTriggerUnit() == Shop_Golem then
        if GetLocalPlayer() == Player(p) then
            call ClearSelection()
            call SelectUnit(Game_Ctrl[p], true)
        endif
    elseif''')
s = base.once(s, '''function Shop_Esc takes nothing returns nothing
    call Shop_Cerrar(GetPlayerId(GetTriggerPlayer()))
endfunction''', '''// Llena el cargador de cada arma con balas y suma un cargador a su reserva, hasta el máximo.
function Recarga_Tomar takes integer p, integer z returns nothing
    local integer c= 0
    local integer i
    local integer w
    loop
        exitwhen c > 6
        set i=p * 7 + c
        if c != 5 and Arm_Tier[i] > 0 then
            set w=c * 3 + Arm_Tier[i] - 1
            set Arm_Clip[i]=Arm_Mag[w]
            set Arm_Rva[i]=IMinBJ(Arm_Res[w], Arm_Rva[i] + Arm_Mag[w])
        endif
        set c=c + 1
    endloop
    set Arm_Fin[p]=0.
    set Recarga_Usada[p * 20 + z]=true
    call Recarga_Pintar(p , z)
    call UI_Click(p)
endfunction

// ESC: cierra la tienda abierta; si no, toma munición de una zona cercana o abre la tienda cercana.
function Shop_Esc takes nothing returns nothing
    local integer p= GetPlayerId(GetTriggerPlayer())
    local integer z
    if Shop_Open[p] then
        call Shop_Cerrar(p)
        return
    endif
    set z=Recarga_Cerca(p)
    if z >= 0 then
        call Recarga_Tomar(p , z)
    elseif DevTienda_Cerca(p) then
        call Shop_Abrir(p)
    endif
endfunction

// El tiempo del descanso dentro de la tienda, en el cliente de quien la tiene abierta; parpadea a 10 s o menos.
function Shop_Reloj takes nothing returns nothing
    local integer p= GetPlayerId(GetLocalPlayer())
    local string t
    local boolean rojo
    if not Shop_Open[p] or Shop_RelojT == null then
        return
    endif
    set t="Descanso " + I2S(Ronda_Resta)
    if t != Shop_RelojVisto then
        set Shop_RelojVisto=t
        call Shop_Izq(p , Shop_RelojT , t , 1650 , 92 , 0.022)
    endif
    set rojo=Ronda_Resta <= 10 and ModuloInteger(R2I(TimerGetElapsed(s__RapidPair_clock) * 4.), 2) == 0
    if rojo != Shop_RelojRojo then
        set Shop_RelojRojo=rojo
        if rojo then
            call SetTextTagColor(Shop_RelojT, 255, 48, 48, 255)
        else
            call SetTextTagColor(Shop_RelojT, 235, 240, 245, 255)
        endif
    endif
endfunction

function DevTienda_Latido takes nothing returns nothing
    call DevTienda_Paso()
    call Shop_Reloj()
endfunction''')
s = base.once(s, '''    call Shop_Tag(250, 758, 0.024, 0, "Salir (Esc)")
''', '''    call Shop_Tag(250, 758, 0.024, 0, "Salir (Esc)")
    set Shop_RelojT = Shop_Tag(1601, 88, 0.024, 0, "")
    set Shop_RelojVisto = ""
    set Shop_RelojRojo = false
''')
s = base.once(s, '''    set Shop_TzN = 0
    set i = 0''', '''    set Shop_TzN = 0
    set Shop_RelojT = null
    set i = 0''')
s = base.once(s, '''    set Shop_Golem = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), 'ngst', GetStartLocationX(s), GetStartLocationY(s) + 300, 270)
    call SetUnitInvulnerable(Shop_Golem, true)
''', '''    call DevTienda_Datos()
    call DevTienda_Mudar()
    set DevTienda_Reloj = CreateTimer()
    call TimerStart(DevTienda_Reloj, 0.03, true, function DevTienda_Latido)
''')

# Élites: 1 por tipo y oleada, con vida 45% del jefe; Burning Rage del color del tipo en élites y jefes.
s = base.once(s, "call WaveAddSlotExByPlayer(w , 'ne00' + k , WaveComputeScaledAmount(1 , DevWave_Jug , 50.) , false",
              "call WaveAddSlotExByPlayer(w , 'ne00' + k , 1 , false")
s = base.once(s, '''// La IA lee la configuración al registrar cada unidad''', '''// Tipo k de una élite ('ne0k') o de un jefe (el de la ronda k + 1); - 1 si no es ninguno.
function DevFuego_Tipo takes integer id returns integer
    if id >= 'ne00' and id <= 'ne09' then
        return id - 'ne00'
    elseif id >= 'nj02' and id <= 'nj09' then
        return id - 'nj01'
    elseif id == 'nj0A' then
        return 9
    endif
    return - 1
endfunction

function DevFuego_Bono takes integer b returns integer
    if b == 10 then
        return 'ALhA'
    endif
    return 'ALh0' + b
endfunction

// Vida de élite 0,45 × 800 × (1 + 0,75 (r − 1)) × jugadores: base 360 del w3u y el resto en pasos de 10 con
// 'ALh0'..'ALhA' (+10 × 2^b al añadirlas; al quitarlas en el nivel 2 se resta el de ese nivel, que es 0).
function DevFuego_Aparece takes nothing returns nothing
    local unit u= GetWaveEventUnit()
    local integer id= GetUnitTypeId(u)
    local integer k= DevFuego_Tipo(id)
    local integer n
    local integer b= 0
    if k < 0 then
        set u=null
        return
    endif
    if id >= 'ne00' and id <= 'ne09' then
        set n=R2I(( 0.45 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) * DevWave_Jug - 360. ) / 10. + 0.5)
        loop
            exitwhen n <= 0 or b > 10
            if ModuloInteger(n, 2) == 1 then
                call UnitAddAbility(u, DevFuego_Bono(b))
                call SetUnitAbilityLevel(u, DevFuego_Bono(b), 2)
                call UnitRemoveAbility(u, DevFuego_Bono(b))
            endif
            set n=n / 2
            set b=b + 1
        endloop
        call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE))
    endif
    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0, AddSpecialEffectTarget("war3mapImported\\\\BurningRage" + I2S(k + 1) + ".mdx", u, "overhead"))
    set u=null
endfunction

function DevFuego_Muere takes nothing returns nothing
    local integer h= GetHandleId(GetWaveEventUnit())
    if HaveSavedHandle(DevFuego_HT, h, 0) then
        call DestroyEffect(LoadEffectHandle(DevFuego_HT, h, 0))
        call RemoveSavedHandle(DevFuego_HT, h, 0)
    endif
endfunction

// La IA lee la configuración al registrar cada unidad''')
s = base.once(s, '''    call RegisterWaveDeathEvent(function DevJefe_Muere)
''', '''    call RegisterWaveDeathEvent(function DevJefe_Muere)
    call RegisterWaveSpawnEvent(function DevFuego_Aparece)
    call RegisterWaveDeathEvent(function DevFuego_Muere)
''')

# Barras más arriba con los modelos mayores.
s = base.once(s, "call SaveReal(Barras_HT, 1, 'ne00' + k, 25.)", "call SaveReal(Barras_HT, 1, 'ne00' + k, 110.)")
s = base.once(s, 'DevJefe_Tipo(k), 80.)', 'DevJefe_Tipo(k), 170.)')

# UnitHitShape de élites y jefes con las escalas nuevas (las de objetos_v14h.py).
forma = formas(s)
N = '\r\n'
cab = '        // v14g: élites y jefes, escalados como su modelo (objetos_v14g.py).\r\n'.encode().decode('latin-1')
i = s.index(cab)
fin = s.index("        call s__UnitHitShape_register('ucry'", i)
viejo = s[i:fin]
lineas = [cab.replace('v14g', 'v14h')]
for k, t in enumerate(TIPOS):
    for rid, f in [(f'ne0{k}', ELITE)] + ([(f'nj0{"23456789A"[k - 1]}', JEFE)] if k else []):
        a, b = escalada(forma[t], f)
        lineas.append(f"        call s__UnitHitShape_register('{rid}' , {a} , {b})" + N)
assert viejo.count('UnitHitShape_register') == 19, viejo
s = s[:i] + ''.join(lineas) + s[fin:]

# Los 100 puntos de oleada del mapa guardado.
cab = '    function DevWave_Marcadores takes nothing returns nothing' + N
cola = '        set DevWave_Marcas = 98' + N
i = s.index(cab)
fin = s.index(cola, i)
marcas = ''.join(f'        set DevWave_MarcaX[{k}] = {r(x)}{N}        set DevWave_MarcaY[{k}] = {r(y)}{N}'
                 for k, (x, y, _) in enumerate(pts[b'nPto']))
s = s[:i] + cab + marcas + '        set DevWave_Marcas = 100' + N + s[fin + len(cola):]

Path(sal).write_text(s, encoding='latin-1', newline='')
print('ok', len(tienda), len(pts[b'nPtB']), len(pts[b'nPto']), [f for _, _, f in tienda])
