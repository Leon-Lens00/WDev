#!/usr/bin/env python3
"""v14i: nuevo sistema de generación de oleadas. Plan: Proyect/docs/planes/devmission-tienda-ia-v14i.md.

Sólo el núcleo de oleadas de este mapa (los originales de WaveSys no se tocan):
- Cantidades: por tipo 6 × J; base del tipo k en la ronda n con A = n − k: ceil(A/2) × min(6, 1 + floor(A/2)).
  Base total round(Σ base × (1 + (J − 1) × pct/100)), pct = DevWave_PCT_BASE (0-200, 100), repartida por restos mayores.
- Tope de la wave min(5 × n × J, 240) vivas (con reservas), y 40 por bot estricto. Sin tope por tipo.
- Un solo fondo por tipo, sin dueño: en cada aparición sale el tipo con más fracción pendiente y el bot con menos vivas.
- Una aparición cada 0,10 s, con el aviso de 1,5 s de WaveSpawnFx.
- Élites: E = n eventos a i × Total / (E + 1) muertes de unidades normales (Total fijado al empezar). Cada evento trae
  una élite 'ne0(i−1)' por jugador en partida, cada una atada a su jugador; si se queda sin vidas o se va, otro al azar.
  Vida 70% de la del jefe, sin multiplicar por jugadores.
- Refuerzos del jefe: la llamada k trae min(k, 6) × round(2 × factor) de cada tipo, el doble del tipo nuevo; sin tope.
- Efectos de aparición: 1 refuerzos, 17 élites, 2 jefe; el resto, al azar uno de los otros 16 en cada aparición.
- Aparición cercana: 15%, a 400-800 de un héroe, con tolerancia: camino recto caminable desde el héroe, al menos 6 de
  8 puntos libres a 128 y la sonda de objeto en su sitio. Si no, un punto 'nPto'.

Uso: v14i.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12


class base:  # war3map.j lleva UTF-8 leído como latin-1: los textos con tildes se pasan igual.
    @staticmethod
    def once(s, a, b):
        return puente_v12.once(s, a.encode().decode('latin-1'), b.encode().decode('latin-1'))


s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')


def entre(s, ini, fin, nuevo):
    """Sustituye desde ini hasta fin (incluido), comprobando que ambos son únicos."""
    ini, fin, nuevo = (x.encode().decode('latin-1').replace('\n', '\r\n') for x in (ini, fin, nuevo))
    assert s.count(ini) == 1, ini[:60]
    a = s.index(ini)
    b = s.index(fin, a) + len(fin)
    return s[:a] + nuevo + s[b:]


s = base.once(s, 'hashtable DevFuego_HT= InitHashtable()\n', '''hashtable DevFuego_HT= InitHashtable()
// v14i: por unidad de oleada, 0 = bot dueño, 1 = jugador al que sigue la élite, 2 = efecto de aparición, 3 = grupo.
hashtable DevWave_HT= InitHashtable()
integer DevWave_PCT_BASE= 100
integer DevWave_Limite= 0
integer DevWave_Total= 0
integer DevWave_Muertos= 0
integer DevWave_EliteSig= 1
integer DevWave_EliteE= 0
integer DevWave_Refuerzo= 2
integer DevWave_UltPs= 0
integer array DevWave_PsFx
integer array DevWave_ColaP
integer DevWave_ColaI= 0
integer DevWave_ColaF= 0
integer DevWave_Cerca= 0
item DevWave_Sonda= null
''')

# Dueño al crear la unidad: el de la reserva.
s = base.once(s, '            set u=CreateUnit(s__WaveSlot_owner[s__PendingSpawn_slot[ps]], ',
              '            set u=CreateUnit(Player(s__PendingSpawn_pid[ps]), ')
s = base.once(s, '            call sc__Wave_registerWaveUnit(s__PendingSpawn_wave[ps],u , s__PendingSpawn_slot[ps] , s__WaveSlot_isBoss[s__PendingSpawn_slot[ps]] , false)\n', '''            call SaveInteger(DevWave_HT, GetHandleId(u), 0, s__PendingSpawn_pid[ps])
            call RemoveSavedInteger(DevWave_HT, GetHandleId(u), 1)
            call SaveInteger(DevWave_HT, GetHandleId(u), 2, DevWave_PsFx[ps])
            call SaveInteger(DevWave_HT, GetHandleId(u), 3, s__WaveSlot_slotGroupId[s__PendingSpawn_slot[ps]])
            call sc__Wave_registerWaveUnit(s__PendingSpawn_wave[ps],u , s__PendingSpawn_slot[ps] , s__WaveSlot_isBoss[s__PendingSpawn_slot[ps]] , false)
''')

# Aparición cercana con tolerancia.
s = base.once(s, '        function s__Wave_tryGetNearUnitPoint takes integer this,real radius returns boolean\n', '''        // v14i: punto dentro del mapa jugable y caminable.
        function DevWave_Libre takes real x,real y returns boolean
            return x > GetRectMinX(bj_mapInitialPlayableArea) + 64. and x < GetRectMaxX(bj_mapInitialPlayableArea) - 64. and y > GetRectMinY(bj_mapInitialPlayableArea) + 64. and y < GetRectMaxY(bj_mapInitialPlayableArea) - 64. and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
        endfunction
        // Tolerancia: camino recto caminable cada 32 desde el héroe, 6 de 8 puntos libres a 128 y la sonda en su sitio
        // (árboles y bloqueadores, que no están en el mapa de caminos).
        function DevWave_Abierto takes real hx,real hy,real x,real y returns boolean
            local real d= SquareRoot(( x - hx ) * ( x - hx ) + ( y - hy ) * ( y - hy ))
            local integer n= R2I(d / 32.)
            local integer i= 1
            local integer libres= 0
            if not DevWave_Libre(x , y) then
                return false
            endif
            loop
                exitwhen i >= n
                if not DevWave_Libre(hx + ( x - hx ) * i / n , hy + ( y - hy ) * i / n) then
                    return false
                endif
                set i=i + 1
            endloop
            set i=0
            loop
                exitwhen i > 7
                if DevWave_Libre(x + 128. * Cos(i * 0.785398) , y + 128. * Sin(i * 0.785398)) then
                    set libres=libres + 1
                endif
                set i=i + 1
            endloop
            if libres < 6 then
                return false
            endif
            if DevWave_Sonda == null then
                set DevWave_Sonda=CreateItem('afac', x, y)
            endif
            call SetItemPosition(DevWave_Sonda, x, y)
            set d=( GetItemX(DevWave_Sonda) - x ) * ( GetItemX(DevWave_Sonda) - x ) + ( GetItemY(DevWave_Sonda) - y ) * ( GetItemY(DevWave_Sonda) - y )
            call SetItemVisible(DevWave_Sonda, false)
            return d < 400.
        endfunction
        function s__Wave_tryGetNearUnitPoint takes integer this,real radius returns boolean
''')
s = base.once(s, '''                    set dist=GetRandomReal(64.0, radius)

                    set x=GetUnitX(u) + dist * Cos(angle)
                    set y=GetUnitY(u) + dist * Sin(angle)

                    // false = caminable
                    if not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
''', '''                    set dist=GetRandomReal(400.0, radius)

                    set x=GetUnitX(u) + dist * Cos(angle)
                    set y=GetUnitY(u) + dist * Sin(angle)

                    if DevWave_Abierto(GetUnitX(u) , GetUnitY(u) , x , y) then
                        set DevWave_Cerca=DevWave_Cerca + 1
''')

# Elección del tipo: la mayor fracción pendiente (sin dueño fijo); sólo si queda un bot por debajo de 40.
s = entre(s, '        function s__Wave_pickSlot takes integer this returns integer\n', '            return 0 // seguridad\n        endfunction\n', '''        // v14i: el bot con menos vivas por debajo del tope por bot (copia de WavePickDefaultOwnerPid, que va después).
        function DevWave_Dueno takes integer w returns integer
            local integer pid= WAVE_DEFAULT_OWNER_MIN
            local integer bestPid= - 1
            local integer bestCount= 0
            loop
                exitwhen pid > WAVE_DEFAULT_OWNER_MAX
                if pid < WAVE_TRACKED_PLAYER_SLOTS then
                    if s___Wave_activeByPlayer[s__Wave_activeByPlayer[w]+pid] < s__Wave_perPlayerLimit[w] then
                        if bestPid < 0 or s___Wave_activeByPlayer[s__Wave_activeByPlayer[w]+pid] < bestCount then
                            set bestPid=pid
                            set bestCount=s___Wave_activeByPlayer[s__Wave_activeByPlayer[w]+pid]
                        endif
                    endif
                endif
                set pid=pid + 1
            endloop
            return bestPid
        endfunction
        // v14i: prioridad más alta y, dentro de ella, la mayor fracción pendiente (pendientes / total); sin azar.
        function s__Wave_pickSlot takes integer this returns integer
            local integer i= 0
            local integer s
            local integer best= 0
            local integer maxPrio= 0
            local real f
            local real bestF= 0.
            if DevWave_Dueno(this) < 0 then
                return 0
            endif
            loop
                exitwhen i >= s__Wave_slotCount[this]
                set s=s___Wave_slots[s__Wave_slots[this]+i]
                if s__WaveSlot_remaining[s] > 0 and s__WaveSlot_active[s] < s__WaveSlot_limit[s] and s__Wave_killGatePassed(this,s) then
                    set f=I2R(s__WaveSlot_remaining[s]) / I2R(IMaxBJ(1, s__WaveSlot_total[s]))
                    if best == 0 or s__WaveSlot_priority[s] > maxPrio or ( s__WaveSlot_priority[s] == maxPrio and f > bestF ) then
                        set best=s
                        set maxPrio=s__WaveSlot_priority[s]
                        set bestF=f
                    endif
                endif
                set i=i + 1
            endloop
            return best
        endfunction
''')

s = base.once(s, '''            set s=s__Wave_pickSlot(this)

            if s == 0 then
                return
            endif

            if not s__Wave_selectSpawnPoint(this,256.0) then
                return
            endif

            set pid=GetPlayerId(s__WaveSlot_owner[s])
''', '''            // v14i: tope de la wave, contando reservas; el dueño se elige al aparecer.
            if DevWave_Limite > 0 and s__Wave_activeOnMap[this] >= DevWave_Limite then
                return
            endif
            set s=s__Wave_pickSlot(this)

            if s == 0 then
                return
            endif

            if not s__Wave_selectSpawnPoint(this,800.0) then
                return
            endif

            set pid=DevWave_Dueno(this)
''')
s = base.once(s, '            set s__PendingSpawn_y[ps]=s__Wave_spawnY[this]\n',
              '            set s__PendingSpawn_y[ps]=s__Wave_spawnY[this]\n            set DevWave_UltPs=ps\n')

s = base.once(s, '''                if s__WaveSlot_owner[s] != null then
                    set pid=GetPlayerId(s__WaveSlot_owner[s])
                endif
''', '''                if HaveSavedInteger(DevWave_HT, hid, 0) then
                    set pid=LoadInteger(DevWave_HT, hid, 0)
                elseif s__WaveSlot_owner[s] != null then
                    set pid=GetPlayerId(s__WaveSlot_owner[s])
                endif
''')

# Élite con objetivo fijo en la IA.
s = base.once(s, '    function s__WaveAI__WaveAIUnit_think takes integer this returns boolean\n', '''    // v14i: jugador en partida (con vidas o en su última) y conectado.
    function DevWave_Vale takes integer p returns boolean
        return p >= 0 and p <= 11 and Game_On[p] and Vidas_EnPartida[p] and GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING
    endfunction
    // Un jugador válido al azar (RNG sincronizado: se llama en código de todos los clientes), o - 1.
    function DevWave_Azar takes nothing returns integer
        local integer p= 0
        local integer c= 0
        loop
            exitwhen p > 11
            if DevWave_Vale(p) then
                set c=c + 1
            endif
            set p=p + 1
        endloop
        if c == 0 then
            return - 1
        endif
        set c=GetRandomInt(1, c)
        set p=0
        loop
            if DevWave_Vale(p) then
                set c=c - 1
                if c == 0 then
                    return p
                endif
            endif
            set p=p + 1
        endloop
        return - 1
    endfunction
    function s__WaveAI__WaveAIUnit_think takes integer this returns boolean
''')
s = base.once(s, '        local integer currentI= - 1\n        local integer i= 0\n',
              '        local integer currentI= - 1\n        local integer i= 0\n        local integer fp= - 1\n')
s = base.once(s, '        if best == null and WaveAI__ResolveTender() and ', '''        // v14i: la élite sigue a su jugador mientras su héroe esté en la lista de vivos; si ya no vale, otro al azar.
        if HaveSavedInteger(DevWave_HT, GetHandleId(s__WaveAI__WaveAIUnit_u[this]), 1) then
            set fp=LoadInteger(DevWave_HT, GetHandleId(s__WaveAI__WaveAIUnit_u[this]), 1)
            if not DevWave_Vale(fp) then
                set fp=DevWave_Azar()
                if fp >= 0 then
                    call SaveInteger(DevWave_HT, GetHandleId(s__WaveAI__WaveAIUnit_u[this]), 1, fp)
                else
                    call RemoveSavedInteger(DevWave_HT, GetHandleId(s__WaveAI__WaveAIUnit_u[this]), 1)
                endif
            endif
            if fp >= 0 then
                set i=0
                loop
                    exitwhen i >= WaveAI__LiveCount
                    if WaveAI__LiveUnit[i] == Game_Hero[fp] then
                        set best=WaveAI__LiveUnit[i]
                        set bestX=WaveAI__LiveX[i]
                        set bestY=WaveAI__LiveY[i]
                        set bestInvulnerable=WaveAI__LiveInvulnerable[i]
                        if best != s__WaveAI__WaveAIUnit_target[this] then
                            set currentD=- 1.
                        endif
                        exitwhen true
                    endif
                    set i=i + 1
                endloop
            endif
        endif
        if best == null and WaveAI__ResolveTender() and ''')

# Efectos de aparición: el ajuste 99 es "al azar entre los 16 que no son 1, 2 ni 17", tirado al reservar.
s = base.once(s, '''        if s != 0 then
            call WaveSpawnFxIn(s__WaveSlot_fxId[s] , (WaveEventX) , (WaveEventY)) // INLINED!!
        endif
''', '''        local integer fx
        if s != 0 then
            set fx=s__WaveSlot_fxId[s]
            if fx == 99 then
                set fx=GetRandomInt(3, 18)
                if fx >= 17 then
                    set fx=fx + 1
                endif
            endif
            set DevWave_PsFx[DevWave_UltPs]=fx
            call WaveSpawnFxIn(fx , (WaveEventX) , (WaveEventY)) // INLINED!!
        endif
''')
s = base.once(s, '            call WaveSpawnFxOut(s__WaveSlot_fxId[s] , (WaveEventUnit)) // INLINED!!\n',
              '            call WaveSpawnFxOut(LoadInteger(DevWave_HT, GetHandleId((WaveEventUnit)), 2) , (WaveEventUnit)) // INLINED!!\n')

# Cantidades nuevas.
s = entre(s, '    // Sin tope por tipo: la cantidad, repartida entre los 6 dueños', '''            call WaveAddSlotExByPlayer(w , DevJefe_Tipo(n) , 1 , false , 1 , 1 , 0 , 1 , true , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[DevWave_NTipos - 1] , 0 , 0 , 1.)
        endif
    endfunction
''', '''    // v14i: tipos por orden de desbloqueo (el k sale desde la ronda k + 1).
    function DevWave_TipoN takes integer k returns integer
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
    function DevWave_PerfilN takes integer k returns integer
        if k == 2 or k == 4 or k == 5 or k == 7 then
            return AI_PROFILE_RANGED
        endif
        return AI_PROFILE_MELEE
    endfunction
    // Base del tipo k en la ronda n, con A = n − k: ceil(A/2) × min(6, 1 + floor(A/2)).
    function DevWave_Base takes integer n,integer k returns integer
        local integer a= n - k
        return ( ( a + 1 ) / 2 ) * IMinBJ(6, 1 + a / 2)
    endfunction

    // Por tipo 6 × J más su parte de la base total, en una sola entrada sin dueño fijo (grupo 700 + k). Las élites
    // entran por eventos de muertes (DevWave_Elite) y el jefe cuando sólo queda él.
    function DevWave_Slots takes integer w,integer n returns nothing
        local integer k= 0
        local integer sb= 0
        local integer tb
        local integer r
        local integer b
        local integer a
        local real f
        local integer array cuota
        local integer array resto
        set f=1. + ( DevWave_Jug - 1 ) * IMaxBJ(0, IMinBJ(200, DevWave_PCT_BASE)) / 100.
        set DevWave_NTipos=n
        loop
            exitwhen k >= n
            set DevWave_Tipo[k]=DevWave_TipoN(k)
            set DevWave_Perfil[k]=DevWave_PerfilN(k)
            set sb=sb + DevWave_Base(n , k)
            set k=k + 1
        endloop
        set tb=R2I(sb * f + 0.5)
        set r=tb
        set k=0
        loop
            exitwhen k >= n
            set cuota[k]=tb * DevWave_Base(n , k) / sb
            set resto[k]=tb * DevWave_Base(n , k) - cuota[k] * sb
            set r=r - cuota[k]
            set k=k + 1
        endloop
        // Restos mayores; a igualdad, el tipo más viejo.
        loop
            exitwhen r <= 0
            set b=0
            set k=1
            loop
                exitwhen k >= n
                if resto[k] > resto[b] then
                    set b=k
                endif
                set k=k + 1
            endloop
            set cuota[b]=cuota[b] + 1
            set resto[b]=- 1
            set r=r - 1
        endloop
        set DevWave_Total=0
        set k=0
        loop
            exitwhen k >= n
            set a=6 * DevWave_Jug + cuota[k]
            set DevWave_Total=DevWave_Total + a
            call WaveUpsertSlotExByPlayer(w , 700 + k , DevWave_Tipo[k] , a , false , 9999 , 1 , 99 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[k] , 0 , 0 , 1.)
            set k=k + 1
        endloop
        set DevWave_Limite=IMinBJ(5 * n * DevWave_Jug, 240)
        set DevWave_Muertos=0
        set DevWave_EliteSig=1
        set DevWave_EliteE=n
        set DevWave_ColaI=0
        set DevWave_ColaF=0
        set DevWave_Cerca=0
        set DevWave_Refuerzo=R2I(2. * f + 0.5)
        // El jefe, del tipo nuevo de la ronda, sale cuando sólo queda él por matar.
        if n >= 2 then
            call WaveAddSlotExByPlayer(w , DevJefe_Tipo(n) , 1 , false , 1 , 2 , 2 , 1 , true , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[n - 1] , 0 , 0 , 1.)
        endif
    endfunction

    // Evento de élites del tipo k: una por jugador en partida, cada una con su jugador en la cola (DevFuego_Aparece).
    function DevWave_Elite takes integer k returns nothing
        local integer p= 0
        local integer c= 0
        loop
            exitwhen p > 11
            if DevWave_Vale(p) then
                set DevWave_ColaP[DevWave_ColaF]=p
                set DevWave_ColaF=DevWave_ColaF + 1
                set c=c + 1
            endif
            set p=p + 1
        endloop
        if c > 0 and Ronda_Wave != 0 and not s__Wave_isDestroyed[Ronda_Wave] then
            call WaveUpsertSlotExByPlayer(Ronda_Wave , 900 + k , 'ne00' + k , c , false , 9999 , 2 , 17 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[k] , 0 , 0 , 1.)
        endif
    endfunction
''')
s = base.once(s, '        set w=s__Wave_create(40 , 0 , 0.25 , n , Ronda_TOTAL)\n', '        set w=s__Wave_create(40 , 15 , 0.10 , n , Ronda_TOTAL)\n')

# Refuerzos del jefe.
s = base.once(s, '''// Fin de la carga: la llamada k añade 2 por tipo de la ronda (escalado) por cada uno de min(k, 6) jugadores, en una
// entrada de refuerzo por tipo (grupo 800 + tipo, dueño según el tipo) con tope de vivos min(k, 6).
''', '''// Fin de la carga: la llamada k añade min(k, 6) × round(2 × factor) de cada tipo de la ronda, el doble del tipo nuevo,
// en una entrada de refuerzo por tipo (grupo 800 + tipo) sin tope propio: sólo cuenta el de la wave.
''')
s = base.once(s, '''        set d=Player(WAVE_DEFAULT_OWNER_MIN + ModuloInteger(k, 6))
        call WaveUpsertSlotExByPlayer(Ronda_Wave , 800 + k , DevWave_Tipo[k] , o * WaveComputeScaledAmount(2 , DevWave_Jug , 50.) , false , o , 1 , 0 , - 1 , false , d , DevWave_Perfil[k] , 0 , 0 , 1.)
        // Una entrada ampliada conserva su tope: se sube aquí con cada llamada.
        set e=s__Wave_findSlotByGroupForOwner(Ronda_Wave,800 + k , DevWave_Tipo[k] , false , d)
        if e != 0 then
            set s__WaveSlot_limit[e]=o
        endif
''', '''        set d=Player(WAVE_DEFAULT_OWNER_MIN)
        set e=o * DevWave_Refuerzo
        if k == DevWave_NTipos - 1 then
            set e=e * 2
        endif
        call WaveUpsertSlotExByPlayer(Ronda_Wave , 800 + k , DevWave_Tipo[k] , e , false , 9999 , 1 , 1 , - 1 , false , d , DevWave_Perfil[k] , 0 , 0 , 1.)
''')

# Élites: vida 70% del jefe sin jugadores y jugador fijo.
s = base.once(s, '''// Vida de élite 0,45 × 800 × (1 + 0,75 (r − 1)) × jugadores: base 360 del w3u''',
              '''// Vida de élite 0,70 × 800 × (1 + 0,75 (r − 1)), sin jugadores (sale una por jugador): base 360 del w3u''')
s = base.once(s, '''    local integer b= 0
    if k < 0 then
        set u=null
        return
    endif
    if id >= 'ne00' and id <= 'ne09' then
        set n=R2I(( 0.45 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) * DevWave_Jug - 360. ) / 10. + 0.5)
''', '''    local integer b= 0
    local integer p= - 1
    if k < 0 then
        set u=null
        return
    endif
    if id >= 'ne00' and id <= 'ne09' then
        if DevWave_ColaI < DevWave_ColaF then
            set p=DevWave_ColaP[DevWave_ColaI]
            set DevWave_ColaI=DevWave_ColaI + 1
        endif
        if not DevWave_Vale(p) then
            set p=DevWave_Azar()
        endif
        if p >= 0 then
            call SaveInteger(DevWave_HT, GetHandleId(u), 1, p)
        endif
        set n=R2I(( 0.70 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) - 360. ) / 10. + 0.5)
''')
s = base.once(s, '''function DevFuego_Muere takes nothing returns nothing
    local integer h= GetHandleId(GetWaveEventUnit())
''', '''function DevFuego_Muere takes nothing returns nothing
    local integer h= GetHandleId(GetWaveEventUnit())
    local integer g
    // v14i: muertes de unidades normales (grupos 700 + k) para los eventos de élites a i × Total / (E + 1).
    if HaveSavedInteger(DevWave_HT, h, 3) then
        set g=LoadInteger(DevWave_HT, h, 3)
        call RemoveSavedInteger(DevWave_HT, h, 1)
        call RemoveSavedInteger(DevWave_HT, h, 3)
        if g >= 700 and g < 800 then
            set DevWave_Muertos=DevWave_Muertos + 1
            loop
                exitwhen DevWave_EliteSig > DevWave_EliteE or DevWave_Muertos * ( DevWave_EliteE + 1 ) < DevWave_EliteSig * DevWave_Total
                call DevWave_Elite(DevWave_EliteSig - 1)
                set DevWave_EliteSig=DevWave_EliteSig + 1
            endloop
        endif
    endif
''')

Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
