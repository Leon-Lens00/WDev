#!/usr/bin/env python3
"""v18x (15/11/2026): efectos reales de la Mutación Evo (fase 8, Leon: "vamos con las siguientes").

Cada mutación cuenta las veces que ganó (Cua_Activa[id]) y su efecto se multiplica por esas veces. Todo en código
común, desde los eventos de la wave (aparición y muerte) y el reloj del jefe; GetRandomInt sólo en esos eventos.
- Jefe: Coloso +30 % vida; Escolta 2 élites del tipo nuevo por jugador al aparecer; Furia con < 50 % de vida
  +50 % vel. de ataque y +30 % de movimiento; Corona 2 pasivas de súper élite y daño de súper élite.
- Élite: Ascenso +1 élite por jugador en cada evento de élites; Promoción 10 % de los comunes salen con vida ×3 y
  daño ×1,5 (con fuego encima; siguen contando como comunes); Élite feroz +1 pasiva de súper élite; Último aliento
  explosión al morir (260 de radio, (30 + 15 × ronda) de daño a los héroes).
- Comunes: Piel gruesa +25 % vida; Marea rápida +20 % movimiento; Veteranos los tipos 0-2 +60 % vida y +50 % daño;
  Horda +20 % de unidades; Pocos pero fuertes unidades / 2, vida y daño ×2; Caparazón tortugas +3 armadura y espinas
  ('ANth'); Regeneración 1 % de vida por segundo; Asalto inicial la wave sale el doble de rápido y lo que sale en los
  10 primeros segundos corre un 30 % más.
- Sustituidas (no hay nativa en 1.27b sin tocar objetos): Lluvia de flechas = los de distancia +25 % vel. de ataque
  (en vez de +150 de alcance); Red de pesca = los tramperos +30 % vel. de ataque y movimiento (en vez de más redes).
- El movimiento se cambia en la velocidad base de WaveAI para que sus carreras no lo devuelvan al valor del objeto.
Prueba: vuelven las oleadas (v18u las quitó), "-mut N" suma una vez la mutación N (0-17) y al acabar cada oleada se
anotan las activas y cuántas unidades recibieron cada una (lat\\v18x-bolsas.txt). Registros v18w -> v18x.
Uso: v18x.py ENTRADA.j SALIDA.j [prueba]
"""
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
modo = sys.argv[3] if len(sys.argv) > 3 else ''
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


cambia('integer array Cua_Activa\n', 'integer array Cua_Activa\nreal Mut_Inicio = 0.\nboolean Mut_Furia = false\n'
       'integer array Mut_Cuenta\n')

# 1. Ayudas (antes del jefe): vida y velocidad.
cambia('function DevJefe_Limpiar takes nothing returns nothing\n', '''// v18x: Mutación Evo. Suma f × vida máxima (BonusMod) y deja la vida llena (la unidad acaba de salir).
function Mut_Vida takes unit u, real f returns nothing
    if f > 0. then
        call BM_VidaMax(u, R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE) * f + 0.5))
        call SetWidgetLife(u, GetUnitState(u, UNIT_STATE_MAX_LIFE))
    endif
endfunction

// v18x: multiplica la velocidad base de WaveAI (sus carreras parten de ella); fuera de WaveAI, la actual.
function Mut_Velocidad takes unit u, real m returns nothing
    local integer this
    if m == 1. then
        return
    endif
    if HaveSavedInteger(Table___ht, WaveAI__UnitByHandle, GetHandleId(u)) then
        set this = LoadInteger(Table___ht, WaveAI__UnitByHandle, GetHandleId(u))
        set s__WaveAI__WaveAIUnit_baseSpeed[this] = s__WaveAI__WaveAIUnit_baseSpeed[this] * m
        call s__WaveAI__WaveAIUnit_applySpeed(this)
    else
        call SetUnitMoveSpeed(u, GetUnitMoveSpeed(u) * m)
    endif
endfunction

function DevJefe_Limpiar takes nothing returns nothing
''')

# 2. Furia en el reloj del jefe (0,03 s, común).
cambia('''function DevJefe_Mirar takes nothing returns nothing
    if not DevJefe_Vivo() then
''', '''function DevJefe_Mirar takes nothing returns nothing
    // v18x: Furia (Mutación Evo 2) al bajar de media vida, una vez por jefe.
    if not Mut_Furia and Cua_Activa[2] > 0 and DevJefe_Vivo() and GetWidgetLife(DevJefe) < 0.5 * GetUnitState(DevJefe, UNIT_STATE_MAX_LIFE) then
        set Mut_Furia = true
        set Mut_Cuenta[2] = Mut_Cuenta[2] + 1
        call BM_Add(DevJefe, 3, 50 * Cua_Activa[2])
        call Mut_Velocidad(DevJefe, 1. + 0.3 * Cua_Activa[2])
        call DestroyEffect(AddSpecialEffectTarget("Abilities\\\\Spells\\\\Orc\\\\Bloodlust\\\\BloodlustTarget.mdl", DevJefe, "overhead"))
    endif
    if not DevJefe_Vivo() then
''')

# 3. Cantidad (Horda, Pocos pero fuertes) y élites extra (Ascenso, Escolta) dentro de la biblioteca de la wave.
cambia('    // Por tipo 6 × J más su parte de la base total,', '''    // v18x: Horda (+20 % por vez) y Pocos pero fuertes (/ (1 + veces)); al menos 1.
    function Mut_Cantidad takes integer a returns integer
        return IMaxBJ(1, R2I(a * ( 1. + 0.2 * Cua_Activa[11] ) / ( 1 + Cua_Activa[12] ) + 0.5))
    endfunction

    // Por tipo 6 × J más su parte de la base total,''')
cambia('            set a=6 * DevWave_Jug + cuota[k]\n', '            set a=Mut_Cantidad(6 * DevWave_Jug + cuota[k])\n')
cambia('''    // Evento de élites del tipo k: una por jugador en partida,''', '''    // v18x: "veces" élites más del tipo k por jugador, en su propio grupo (no pisa las de 900 + k).
    function Mut_Elites takes integer k,integer grupo,integer veces returns nothing
        local integer p= 0
        local integer c= 0
        local integer j
        if veces <= 0 or k < 0 or k > 9 or Ronda_Wave == 0 or s__Wave_isDestroyed[Ronda_Wave] then
            return
        endif
        loop
            exitwhen p > 11
            if DevWave_Vale(p) then
                set j=0
                loop
                    exitwhen j >= veces
                    set DevWave_ColaP[DevWave_ColaF]=p
                    set DevWave_ColaF=DevWave_ColaF + 1
                    set j=j + 1
                endloop
                set c=c + veces
            endif
            set p=p + 1
        endloop
        if c > 0 then
            call WaveUpsertSlotExByPlayer(Ronda_Wave , grupo , 'ne00' + k , c , false , 9999 , 2 , 17 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[k] , 0 , 0 , 1.)
        endif
    endfunction

    // Evento de élites del tipo k: una por jugador en partida,''')
cambia('''            call WaveUpsertSlotExByPlayer(Ronda_Wave , 900 + k , 'ne00' + k , c , false , 9999 , 2 , 17 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[k] , 0 , 0 , 1.)
        endif
    endfunction
''', '''            call WaveUpsertSlotExByPlayer(Ronda_Wave , 900 + k , 'ne00' + k , c , false , 9999 , 2 , 17 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[k] , 0 , 0 , 1.)
        endif
        // v18x: Ascenso (Mutación Evo 4).
        if Cua_Activa[4] > 0 then
            set Mut_Cuenta[4] = Mut_Cuenta[4] + 1
            call Mut_Elites(k, 960 + k, Cua_Activa[4])
        endif
    endfunction
''')
# Asalto inicial: intervalo de aparición.
cambia('        set w=s__Wave_create(40 , 15 , 0.10 , n , Ronda_TOTAL)\n',
       '        // v18x: Asalto inicial (Mutación Evo 16) acorta la aparición.\n'
       '        set w=s__Wave_create(40 , 15 , 0.10 / ( 1 + Cua_Activa[16] ) , n , Ronda_TOTAL)\n')
cambia('    call DevWave_Start(Ronda_Numero)\n', '    call DevWave_Start(Ronda_Numero)\n'
       '    set Mut_Inicio = TimerGetElapsed(s__RapidPair_clock)\n')

# 4. Aparición y muerte (registradas tras DevFuego: la élite ya tiene su vida de élite).
MUT = r'''// v18x: tipo común k (0..9) o -1.
function Mut_Comun takes integer id returns integer
    local integer k = 0
    loop
        exitwhen k > 9
        if id == DevWave_TipoN(k) then
            return k
        endif
        set k = k + 1
    endloop
    return - 1
endfunction

// v18x: efectos de la Mutación Evo al salir cada unidad de la wave (código común).
function Mut_Aparece takes nothing returns nothing
    local unit u = GetWaveEventUnit()
    local integer id = GetUnitTypeId(u)
    local integer k = Mut_Comun(id)
    local integer n
    local integer j
    local real f = 0.
    local real d = 0.
    local real v = 1.
    if u == null or not UnitAlive(u) then
        set u = null
        return
    endif
    if IsWaveEventBoss() and ((id >= 'nj00' and id <= 'nj09') or id == 'nj0A') then
        set Mut_Furia = false
        set n = Cua_Activa[0]
        if n > 0 then
            set Mut_Cuenta[0] = Mut_Cuenta[0] + 1
            set f = 0.3 * n
        endif
        set n = Cua_Activa[3]
        if n > 0 then
            set Mut_Cuenta[3] = Mut_Cuenta[3] + 1
            set j = 0
            loop
                exitwhen j >= 2 * n
                call UnitAddAbility(u, Sup_PaId[GetRandomInt(0, 6)])
                set j = j + 1
            endloop
            call BM_Add(u, 1, Sup_Valor(0, Ronda_Numero) * n)
            call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 1, AddSpecialEffectTarget("Abilities\\Spells\\Undead\\UnholyFrenzy\\UnholyFrenzyTarget.mdl", u, "overhead"))
        endif
        if Cua_Activa[1] > 0 then
            set Mut_Cuenta[1] = Mut_Cuenta[1] + 1
            call Mut_Elites(DevWave_NTipos - 1, 980, 2 * Cua_Activa[1])
        endif
        call Mut_Vida(u, f)
        set u = null
        return
    endif
    if id >= 'ne00' and id <= 'ne09' then
        set n = Cua_Activa[6]
        if n > 0 then
            set Mut_Cuenta[6] = Mut_Cuenta[6] + 1
            set j = 0
            loop
                exitwhen j >= n
                call UnitAddAbility(u, Sup_PaId[GetRandomInt(0, 6)])
                set j = j + 1
            endloop
        endif
        set u = null
        return
    endif
    if k < 0 then
        set u = null
        return
    endif
    // Comunes.
    if Cua_Activa[5] > 0 and GetRandomInt(1, 100) <= 10 * Cua_Activa[5] then
        set Mut_Cuenta[5] = Mut_Cuenta[5] + 1
        set f = f + 2.
        set d = d + 0.5
        if not HaveSavedHandle(DevFuego_HT, GetHandleId(u), 0) then
            call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0, AddSpecialEffectTarget("war3mapImported\\BurningRage" + I2S(k + 1) + ".mdx", u, "overhead"))
        endif
    endif
    if Cua_Activa[8] > 0 then
        set Mut_Cuenta[8] = Mut_Cuenta[8] + 1
        set f = f + 0.25 * Cua_Activa[8]
    endif
    if Cua_Activa[9] > 0 then
        set Mut_Cuenta[9] = Mut_Cuenta[9] + 1
        set v = v * (1. + 0.2 * Cua_Activa[9])
    endif
    if Cua_Activa[10] > 0 and k <= 2 then
        set Mut_Cuenta[10] = Mut_Cuenta[10] + 1
        set f = f + 0.6 * Cua_Activa[10]
        set d = d + 0.5 * Cua_Activa[10]
    endif
    if Cua_Activa[12] > 0 then
        set Mut_Cuenta[12] = Mut_Cuenta[12] + 1
        set f = f + Cua_Activa[12]
        set d = d + Cua_Activa[12]
    endif
    if Cua_Activa[13] > 0 and (k == 2 or k == 8 or k == 9) then
        set Mut_Cuenta[13] = Mut_Cuenta[13] + 1
        call BM_Add(u, 0, 3 * Cua_Activa[13])
        call UnitAddAbility(u, 'ANth')
    endif
    if Cua_Activa[14] > 0 and (k == 2 or k == 4 or k == 5 or k == 7) then
        set Mut_Cuenta[14] = Mut_Cuenta[14] + 1
        call BM_Add(u, 3, 25 * Cua_Activa[14])
    endif
    if Cua_Activa[15] > 0 and k == 4 then
        set Mut_Cuenta[15] = Mut_Cuenta[15] + 1
        call BM_Add(u, 3, 30 * Cua_Activa[15])
        set v = v * (1. + 0.3 * Cua_Activa[15])
    endif
    if Cua_Activa[16] > 0 and TimerGetElapsed(s__RapidPair_clock) - Mut_Inicio < 10. then
        set Mut_Cuenta[16] = Mut_Cuenta[16] + 1
        set v = v * (1. + 0.3 * Cua_Activa[16])
    endif
    call Mut_Vida(u, f)
    if d > 0. then
        call BM_Add(u, 1, R2I(Sup_Base(id) * d + 0.5))
    endif
    if Cua_Activa[17] > 0 then
        set Mut_Cuenta[17] = Mut_Cuenta[17] + 1
        call BM_Add(u, 2, IMaxBJ(1, R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE) * 0.01 * Cua_Activa[17] + 0.5)))
    endif
    call Mut_Velocidad(u, v)
    set u = null
endfunction

// v18x: Último aliento (Mutación Evo 7): la élite explota al morir de verdad.
function Mut_Muere takes nothing returns nothing
    local unit u = GetWaveEventUnit()
    local integer id = GetUnitTypeId(u)
    local integer p = 0
    local real x
    local real y
    local real dano
    if WaveEventIsRetired or u == null or Cua_Activa[7] <= 0 or id < 'ne00' or id > 'ne09' then
        set u = null
        return
    endif
    set Mut_Cuenta[7] = Mut_Cuenta[7] + 1
    set x = GetUnitX(u)
    set y = GetUnitY(u)
    set dano = (30. + 15. * Ronda_Numero) * Cua_Activa[7]
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl", x, y))
    loop
        exitwhen p > 11
        if Game_On[p] and Game_Hero[p] != null and UnitAlive(Game_Hero[p]) and IsUnitInRangeXY(Game_Hero[p], x, y, 260.) then
            call UnitDamageTarget(u, Game_Hero[p], dano, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
        endif
        set p = p + 1
    endloop
    set u = null
endfunction

'''
cambia('// v14q: los cadáveres de las oleadas salen del mapa', MUT + '// v14q: los cadáveres de las oleadas salen del mapa')
cambia('    call RegisterWaveDeathEvent(function DevFuego_Muere)\n', '    call RegisterWaveDeathEvent(function DevFuego_Muere)\n'
       '    call RegisterWaveSpawnEvent(function Mut_Aparece)\n    call RegisterWaveDeathEvent(function Mut_Muere)\n')
# Corona guarda su efecto en la clave 1 de DevFuego_HT: se quita al morir, como el fuego.
cambia('''    if HaveSavedHandle(DevFuego_HT, h, 0) then
        call DestroyEffect(LoadEffectHandle(DevFuego_HT, h, 0))
        call RemoveSavedHandle(DevFuego_HT, h, 0)
    endif
endfunction
''', '''    if HaveSavedHandle(DevFuego_HT, h, 0) then
        call DestroyEffect(LoadEffectHandle(DevFuego_HT, h, 0))
        call RemoveSavedHandle(DevFuego_HT, h, 0)
    endif
    if HaveSavedHandle(DevFuego_HT, h, 1) then
        call DestroyEffect(LoadEffectHandle(DevFuego_HT, h, 1))
        call RemoveSavedHandle(DevFuego_HT, h, 1)
    endif
endfunction
''')
# Precarga de los efectos nuevos (en la carga basta para modelos).
cambia('    // v18v: calentado otra vez ya en partida', '''    // v18x: efectos de la Mutación Evo.
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Other\\\\Incinerate\\\\FireLordDeathExplode.mdl", -12000., 9000.))
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\Bloodlust\\\\BloodlustTarget.mdl", -12000., 9000.))
    // v18v: calentado otra vez ya en partida''')

# 5. Descripciones que cambian.
for i, viejo, nuevo in [
        (10, 'Un tipo viejo llega con|nfuerza de 3 rondas más.', 'Los 3 tipos más viejos|nganan vida y daño.'),
        (13, 'Las tortugas ganan|n+3 de armadura.', 'Las tortugas ganan +3|nde armadura y espinas.'),
        (14, 'Los de distancia ganan|n+150 de alcance.', 'Los de distancia atacan|nun 25 % más rápido.'),
        (15, 'Los tramperos lanzan|nredes más seguido.', 'Los tramperos atacan y|ncorren un 30 % más.'),
        (16, 'Los primeros 10 s llegan|nmás rápido.', 'La oleada sale antes y|nlos primeros corren más.'),
        (17, 'Los comunes recuperan|nvida con el tiempo.', 'Los comunes recuperan|n1 % de vida por segundo.')]:
    cambia(f'set Cua_Des[{i}] = "{viejo}"', f'set Cua_Des[{i}] = "{nuevo}"')

if modo == 'prueba':
    # Vuelven las oleadas (v18u-prueba las había quitado; su comentario quedó en latin-1, sin U).
    com = '    // v18u-prueba: sin oleadas ni m\xfasica, para probar el cuadro de resultados con "-punt [N]".\n'
    for c in (com, com.replace('\n', '\r\n')):
        if src.count(c) == 1:
            src = src.replace(c, '')
            break
    else:
        raise SystemExit('comentario de v18u no encontrado')
    cambia('''    call StopMusic(false)
    call ClearMapMusic()
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Prueba sin oleadas: escribe -punt o -punt N para ver el cuadro de resultados.")
endfunction
''', '''    call Ronda_Lanzar()
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Prueba: -mut N suma la Mutación Evo N (0-17) desde la oleada siguiente; -punt sigue.")
endfunction
''')
    cambia('function Punt_Registrar takes nothing returns nothing\n', '''// v18x-prueba: activas y unidades que recibió cada mutación, al acabar cada oleada.
function Mut_Anotar takes nothing returns nothing
    local integer i = 0
    local string s = "ronda " + I2S(Ronda_Numero) + " mutaciones:"
    loop
        exitwhen i > 17
        if Cua_Activa[i] > 0 or Mut_Cuenta[i] > 0 then
            set s = s + " " + I2S(i) + "x" + I2S(Cua_Activa[i]) + "=" + I2S(Mut_Cuenta[i])
        endif
        set Mut_Cuenta[i] = 0
        set i = i + 1
    endloop
    call Bolsa_Anotar(s)
endfunction

// v18x-prueba: "-mut N" suma una vez la mutación N (0-17).
function Mut_Comando takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    local integer n = - 1
    if StringLength(s) > 5 then
        set n = S2I(SubString(s, 5, StringLength(s)))
    endif
    if n < 0 or n > 17 or StringLength(s) <= 5 then
        call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0, 0, 6, "-mut N con N de 0 a 17")
        return
    endif
    set Cua_Activa[n] = Cua_Activa[n] + 1
    call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 6, "Mutación Evo: " + Cua_Nom[n] + " x" + I2S(Cua_Activa[n]))
    call Bolsa_Anotar("-mut " + I2S(n) + " " + Cua_Nom[n] + " x" + I2S(Cua_Activa[n]))
endfunction

function Punt_Registrar takes nothing returns nothing
    local trigger m = CreateTrigger()
''')
    cambia('    call TriggerAddAction(t, function Punt_Comando)\n', '''    call TriggerAddAction(t, function Punt_Comando)
    set p = 0
    loop
        exitwhen p > 11
        call TriggerRegisterPlayerChatEvent(m, Player(p), "-mut", false)
        set p = p + 1
    endloop
    call TriggerAddAction(m, function Mut_Comando)
    set m = null
''')
    cambia('''function Ronda_AlTerminar takes nothing returns nothing
    local integer p = 0
    if GetWaveEventWave() == Ronda_Wave then
''', '''function Ronda_AlTerminar takes nothing returns nothing
    local integer p = 0
    if GetWaveEventWave() == Ronda_Wave then
        call ExecuteFunc("Mut_Anotar")
''')
    assert src.count('lat\\\\v18w-') == 4, src.count('lat\\\\v18w-')
    src = src.replace('lat\\\\v18w-', 'lat\\\\v18x-')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v18x', modo or 'normal')
