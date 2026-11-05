#!/usr/bin/env python3
"""v14g: élites, jefes con refuerzos, localizador del jefe en el borde y barras más altas.
Plan: Proyect/docs/planes/devmission-oleadas-jefes-v14g.md. Objetos de scripts/objetos_v14g.py.

- Sin tope por tipo (quitado tras la prueba del 02/11/2026): cada tipo se reparte entre los 6 dueños, con el primero
  rotando por tipo, y cada entrada puede tener vivas todas las suyas. Totales escalados +50% por jugador extra. Entradas
  con grupo 700 + índice del tipo. Tope de vivos por dueño 40 en vez de 10.
- Élites 'ne00'..'ne09': una por tipo y ronda (escalada), tope 1, acelerón permanente a 500 (sprint sin fin: sólo ellas
  lo usan). Tanques nmmu, ntrg, ntrd y sus élites corren con menos del 50%.
- Jefe desde la ronda 2 ('nj02'..'nj0A'): entrada de jefe que espera a que quede 1 por matar. Mejora 'Rdjv' al nivel
  jugadores − 1 en los dueños 8..13 (sólo sube). Salto a la espalda a 150–450 cada 15–25 s.
- Refuerzos: a los 15–20 s y luego cada 40–50 s; se detiene 1,5 s con texto y efecto. La llamada k añade
  min(k, 6) × 2 por tipo (escalado) en una entrada de refuerzo por tipo, con tope de vivos min(k, 6). Se cancela si
  el jefe muere.
- Localizador: un icono por jugador, proyectado con su cámara lógica (sincronizada); oculto con el jefe en pantalla
  o la tienda abierta; si no, en el borde en la dirección centro → jefe, dentro de x 25–1895, y 63–803 (780 sobre el
  minimapa), delante del HUD, dentro de la esfera del tablero de estrategia, plana y rubí ('ubj0', 60 px). Se coloca en el mismo tick de 0,01 s que la cámara.
- Impacto de balas: élites y jefes se registran en UnitHitShape con selección y colisión × 1,25 y × 1,8, los mismos
  valores que objetos_v14g.py pone en ussc/ucol.
- Barras: héroe 175, enemigos 150, más 25 las élites y 80 los jefes (Barras_HT, padre 1, clave el tipo).

Uso: v14g.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))

s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')


class base:  # war3map.j lleva UTF-8 leído como latin-1: los textos con tildes se pasan igual.
    @staticmethod
    def once(s, a, b):
        return __import__('puente_v12').once(s, a.encode().decode('latin-1'), b.encode().decode('latin-1'))


s = base.once(s, 'real Title_CX=', '''integer DevWave_NTipos= 0
integer DevWave_Turno= 0
integer DevWave_Jug= 1
integer array DevWave_Tipo
integer array DevWave_Perfil
unit DevJefe= null
integer DevJefe_Llamadas= 0
timer DevJefe_Reloj= null
timer DevJefe_Carga= null
timer DevJefe_Mira= null
effect DevJefe_Fx= null
unit array DevJefe_Icono
unit array DevJefe_Esfera
real WaveAI_SaltoMax= 450.
real Title_CX=''')

# IA: salto a distancia aleatoria y acelerón que no se apaga.
s = base.once(s, '''        local integer i= 0
        if s__WaveAI__WaveAITeleport_behind[cfg] <= 0. or''', '''        local integer i= 0
        local real dist= GetRandomReal(s__WaveAI__WaveAITeleport_behind[cfg], RMaxBJ(s__WaveAI__WaveAITeleport_behind[cfg], WaveAI_SaltoMax))
        if s__WaveAI__WaveAITeleport_behind[cfg] <= 0. or''')
s = base.once(s, 'set px=tx + Cos(a) * s__WaveAI__WaveAITeleport_behind[cfg]', 'set px=tx + Cos(a) * dist')
s = base.once(s, 'set py=ty + Sin(a) * s__WaveAI__WaveAITeleport_behind[cfg]', 'set py=ty + Sin(a) * dist')
s = base.once(s, '            if WaveAI__TickNo >= s__WaveAI__WaveAIUnit_sprintEnd[this] or d > leave * leave or s__WaveAI__WaveAISprint_bonus[s__WaveAI__WaveAIUnit_sprint[this]] <= 0. then\n',
              '            if s__WaveAI__WaveAISprint_bonus[s__WaveAI__WaveAIUnit_sprint[this]] <= 0. then\n')

# Barras más altas; élites y jefes, según su escala.
s = base.once(s, 'GetUnitY(u), 145. + GetUnitFlyHeight(u))', 'GetUnitY(u), 175. + GetUnitFlyHeight(u))')
s = base.once(s, 'GetUnitY(u), 120. + GetUnitFlyHeight(u))', 'GetUnitY(u), 150. + LoadReal(Barras_HT, 1, GetUnitTypeId(u)) + GetUnitFlyHeight(u))')

REPARTO_VIEJO = s[s.index('    // One entry per round; the amounts are per wave owner (6 owners).\r\n'):s.index('    // Cada ronda repite los tipos')]
REPARTO_VIEJO = REPARTO_VIEJO.replace('\r\n', '\n').encode('latin-1').decode()  # once() vuelve a poner CRLF y latin-1
s = base.once(s, REPARTO_VIEJO, '''    function DevJefe_Tipo takes integer n returns integer
        if n == 10 then
            return 'nj0A'
        endif
        return 'nj00' + n
    endfunction

    // La vida de los jefes se multiplica por jugadores con la mejora; el nivel no baja si alguien se va.
    function DevJefe_Mejora takes integer jug returns nothing
        local integer o= WAVE_DEFAULT_OWNER_MIN
        loop
            exitwhen o > WAVE_DEFAULT_OWNER_MAX
            call SetPlayerTechResearched(Player(o), 'Rdjv', jug - 1)
            set o=o + 1
        endloop
    endfunction

    // Sin tope por tipo: la cantidad, repartida entre los 6 dueños desde uno que rota; cada entrada puede tener vivas
    // todas las suyas y sólo corta el tope por dueño. Más una élite en el primer dueño.
    function DevWave_Reparto takes integer w,integer id,integer total,integer profile returns nothing
        local integer k= DevWave_NTipos
        local integer j= 0
        local integer a
        set DevWave_Tipo[k]=id
        set DevWave_Perfil[k]=profile
        set DevWave_NTipos=k + 1
        set total=WaveComputeScaledAmount(total , DevWave_Jug , 50.)
        loop
            exitwhen j > 5
            set a=total / 6
            if j < total - total / 6 * 6 then
                set a=a + 1
            endif
            if a > 0 then
                call WaveUpsertSlotExByPlayer(w , 700 + k , id , a , false , a , 1 , 0 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN + ModuloInteger(DevWave_Turno + j, 6)) , profile , 0 , 0 , 1.)
            endif
            set j=j + 1
        endloop
        call WaveAddSlotExByPlayer(w , 'ne00' + k , WaveComputeScaledAmount(1 , DevWave_Jug , 50.) , false , 1 , 1 , 0 , - 1 , false , Player(WAVE_DEFAULT_OWNER_MIN + DevWave_Turno) , profile , 0 , 0 , 1.)
        set DevWave_Turno=ModuloInteger(DevWave_Turno + 1, 6)
    endfunction

''')
s = base.once(s, '''    function DevWave_Slots takes integer w,integer n returns nothing
        if n == 1 then''', '''    function DevWave_Slots takes integer w,integer n returns nothing
        set DevWave_NTipos=0
        if n == 1 then''')
s = base.once(s, '''            call DevWave_Reparto(w , 'ntrd' , 2 , AI_PROFILE_MELEE)
        endif
    endfunction
''', '''            call DevWave_Reparto(w , 'ntrd' , 2 , AI_PROFILE_MELEE)
        endif
        // El jefe, del tipo nuevo de la ronda, sale cuando sólo queda él por matar.
        if n >= 2 then
            call WaveAddSlotExByPlayer(w , DevJefe_Tipo(n) , 1 , false , 1 , 1 , 0 , 1 , true , Player(WAVE_DEFAULT_OWNER_MIN) , DevWave_Perfil[DevWave_NTipos - 1] , 0 , 0 , 1.)
        endif
    endfunction
''')
s = base.once(s, '        set w=s__Wave_create(WaveDifficultyOwnerCap() , 0 , 0.25 , n , Ronda_TOTAL)\n', '''        set DevWave_Jug=IMaxBJ(1, WaveCountPlayingUsers())
        call DevJefe_Mejora(DevWave_Jug)
        set w=s__Wave_create(40 , 0 , 0.25 , n , Ronda_TOTAL)
''')

JEFE = r'''
function DevJefe_Limpiar takes nothing returns nothing
    local integer p= 0
    if DevJefe_Fx != null then
        call DestroyEffect(DevJefe_Fx)
        set DevJefe_Fx=null
    endif
    if DevJefe != null and GetUnitTypeId(DevJefe) != 0 then
        call PauseUnit(DevJefe, false)
    endif
    set DevJefe=null
    if DevJefe_Reloj != null then
        call PauseTimer(DevJefe_Reloj)
        call PauseTimer(DevJefe_Carga)
        call PauseTimer(DevJefe_Mira)
    endif
    loop
        exitwhen p > 11
        if DevJefe_Icono[p] != null then
            call RemoveUnit(DevJefe_Icono[p])
            call RemoveUnit(DevJefe_Esfera[p])
            set DevJefe_Icono[p]=null
            set DevJefe_Esfera[p]=null
        endif
        set p=p + 1
    endloop
endfunction

function DevJefe_Vivo takes nothing returns boolean
    return DevJefe != null and GetUnitTypeId(DevJefe) != 0 and GetWidgetLife(DevJefe) > 0.405
endfunction

// Fin de la carga: la llamada k añade 2 por tipo de la ronda (escalado) por cada uno de min(k, 6) jugadores, en una
// entrada de refuerzo por tipo (grupo 800 + tipo, dueño según el tipo) con tope de vivos min(k, 6).
function DevJefe_Aplicar takes nothing returns nothing
    local integer e
    local player d
    local integer k
    local integer o
    if DevJefe_Fx != null then
        call DestroyEffect(DevJefe_Fx)
        set DevJefe_Fx=null
    endif
    if not DevJefe_Vivo() then
        return
    endif
    call PauseUnit(DevJefe, false)
    if Ronda_Wave == 0 or not s__Wave_isOperational(Ronda_Wave) then
        return
    endif
    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl", DevJefe, "origin"))
    set DevJefe_Llamadas=DevJefe_Llamadas + 1
    set o=IMinBJ(DevJefe_Llamadas, 6)
    set k=0
    loop
        exitwhen k >= DevWave_NTipos
        set d=Player(WAVE_DEFAULT_OWNER_MIN + ModuloInteger(k, 6))
        call WaveUpsertSlotExByPlayer(Ronda_Wave , 800 + k , DevWave_Tipo[k] , o * WaveComputeScaledAmount(2 , DevWave_Jug , 50.) , false , o , 1 , 0 , - 1 , false , d , DevWave_Perfil[k] , 0 , 0 , 1.)
        // Una entrada ampliada conserva su tope: se sube aquí con cada llamada.
        set e=s__Wave_findSlotByGroupForOwner(Ronda_Wave,800 + k , DevWave_Tipo[k] , false , d)
        if e != 0 then
            set s__WaveSlot_limit[e]=o
        endif
        set k=k + 1
    endloop
    set d=null
endfunction

function DevJefe_Llamar takes nothing returns nothing
    local texttag t
    local string anim= "attack"
    local integer id
    if not DevJefe_Vivo() or Ronda_Wave == 0 or not s__Wave_isOperational(Ronda_Wave) then
        return
    endif
    set id=GetUnitTypeId(DevJefe)
    if id == 'nj05' or id == 'nj06' or id == 'nj08' then
        set anim="spell"
    endif
    call IssueImmediateOrder(DevJefe, "stop")
    call SetUnitAnimation(DevJefe, anim)
    call QueueUnitAnimation(DevJefe, "stand")
    call PauseUnit(DevJefe, true)
    set DevJefe_Fx=AddSpecialEffectTarget("war3mapImported\\Bondage Blue SD.mdx", DevJefe, "origin")
    set t=CreateTextTag()
    call SetTextTagText(t, "llamando refuerzos", 0.020)
    call SetTextTagPosUnit(t, DevJefe, 120.)
    call SetTextTagVelocity(t, 0., 0.0125)
    call SetTextTagPermanent(t, false)
    call SetTextTagLifespan(t, 3.)
    call SetTextTagFadepoint(t, 2.25)
    call TimerStart(DevJefe_Carga, 1.5, false, function DevJefe_Aplicar)
    call TimerStart(DevJefe_Reloj, 1.5 + GetRandomReal(40., 50.), false, function DevJefe_Llamar)
    set t=null
endfunction

// El icono se coloca en HealthBarsUpdate (DevJefe_Poner); este reloj sólo limpia al morir o desaparecer el jefe.
function DevJefe_Mirar takes nothing returns nothing
    if not DevJefe_Vivo() then
        call DevJefe_Limpiar()
    endif
endfunction

function DevJefe_Aparece takes nothing returns nothing
    local integer p= 0
    local integer icono
    if not IsWaveEventBoss() then
        return
    endif
    call DevJefe_Limpiar()
    set DevJefe=GetWaveEventUnit()
    set DevJefe_Llamadas=0
    set icono=GetUnitTypeId(DevJefe) - 'nj00' + 'hbj0'
    loop
        exitwhen p > 11
        if HealthBars__Bound[p] then
            set DevJefe_Icono[p]=HealthBars__Dummy(icono , p)
            call ShowUnit(DevJefe_Icono[p], false)
            // La esfera del tablero de estrategia, plana y rubí ('ubj0', esfera_v14g.py), de 60 px a distancia 397: escala
            // 60 × (0,544 / 718,19) × 397 / (2 × 78,54), como Boss_Fx. Sin partículas: el alfa local la oculta.
            set DevJefe_Esfera[p]=HealthBars__Dummy('ubj0' , p)
            call UnitAddAbility(DevJefe_Esfera[p], s__Interface_LOCUST_ID)
            call UnitRemoveAbility(DevJefe_Esfera[p], s__Interface_LOCUST_ID)
            call SetUnitScale(DevJefe_Esfera[p], 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ), 60. * ( 0.544 / 718.18930543 ) * 397. / ( 2. * 78.54 ))
            call ShowUnit(DevJefe_Esfera[p], false)
        endif
        set p=p + 1
    endloop
    call TimerStart(DevJefe_Reloj, GetRandomReal(15., 20.), false, function DevJefe_Llamar)
    call TimerStart(DevJefe_Mira, 0.03, true, function DevJefe_Mirar)
endfunction

function DevJefe_Muere takes nothing returns nothing
    if DevJefe != null and GetWaveEventUnit() == DevJefe then
        call DevJefe_Limpiar()
    endif
endfunction

// La IA lee la configuración al registrar cada unidad: se fija antes de la primera ronda.
function DevWave_IA takes nothing returns nothing
    local integer k= 0
    loop
        exitwhen k > 9
        call WaveAIEnableChaseSprint('ne00' + k, 500., 40., 3600., 0., "")
        call SaveReal(Barras_HT, 1, 'ne00' + k, 25.)
        set k=k + 1
    endloop
    set k=2
    loop
        exitwhen k > 10
        call WaveAIEnableTeleport(DevJefe_Tipo(k), 150., 0., 15., 25., "Abilities\\Spells\\NightElf\\Blink\\BlinkCaster.mdl")
        call SaveReal(Barras_HT, 1, DevJefe_Tipo(k), 80.)
        set k=k + 1
    endloop
    call WaveAIEnableLowLifeHaste('nmmu', 50., 40., "")
    call WaveAIEnableLowLifeHaste('ntrg', 50., 40., "")
    call WaveAIEnableLowLifeHaste('ntrd', 50., 40., "")
    call WaveAIEnableLowLifeHaste('ne06', 50., 40., "")
    call WaveAIEnableLowLifeHaste('ne08', 50., 40., "")
    call WaveAIEnableLowLifeHaste('ne09', 50., 40., "")
endfunction
'''
s = base.once(s, 'function HealthBarsUpdate takes nothing returns nothing\n', r'''// Inversa de win2World con la cámara lógica del jugador, que todos los clientes calculan igual: ShowUnit y SetUnitX
// son globales sin desincronizar. Sólo su dueño ve el icono (alfa local de HealthBars__Dummy). Va en el mismo tick de
// 0,01 s que la cámara y el resto del HUD; con un reloj propio quedaba desfasado y temblaba al moverse.
// Límites del centro del icono (JefeIcono centrado en su origen por objetos_v14g.py): ~6 px del borde de la vista,
// los mismos márgenes que con el modelo original, que se dibujaba 28 px a la derecha y 23 abajo de su punto. Distancia 398; el plano de prioridad 3 del modelo (objetos_v14g.py) lo pone delante del marco de vida.
function DevJefe_Poner takes integer p, integer cam returns nothing
    local integer e
    local real bx
    local real by
    local real dx
    local real dy
    local real dz
    local real r
    local real px
    local real py
    local real t
    local unit u= DevJefe_Icono[p]
    if u == null then
        return
    endif
    if DevJefe == null or GetWidgetLife(DevJefe) <= 0.405 or not HealthBars__Visible then
        if not IsUnitHidden(u) then
            call ShowUnit(u, false)
            call ShowUnit(DevJefe_Esfera[p], false)
        endif
        set u=null
        return
    endif
    set bx=GetUnitX(DevJefe)
    set by=GetUnitY(DevJefe)
    set e=s__Camera_eye[cam]
    set dx=bx - s__VECTOR3_x[e]
    set dy=by - s__VECTOR3_y[e]
    set dz=UserInterface_GetTerrainZ(bx , by) + GetUnitFlyHeight(DevJefe) + 80. - s__VECTOR3_z[e]
    set e=s__Camera_axisZ[cam]
    set r=RMaxBJ(1., dx * s__VECTOR3_x[e] + dy * s__VECTOR3_y[e] + dz * s__VECTOR3_z[e])
    set e=s__Camera_axisX[cam]
    set px=961. + ( dx * s__VECTOR3_x[e] + dy * s__VECTOR3_y[e] + dz * s__VECTOR3_z[e] ) / ( SCREEN_WIDTH * r ) * 718.18930543
    set e=s__Camera_axisY[cam]
    set py=432.323669 - ( dx * s__VECTOR3_x[e] + dy * s__VECTOR3_y[e] + dz * s__VECTOR3_z[e] ) / ( SCREEN_HEIGHT * r ) * 387.73819261
    if Shop_Open[p] or ( px >= 0. and px <= 1920. and py >= 0. and py <= 864. ) then
        if not IsUnitHidden(u) then
            call ShowUnit(u, false)
            call ShowUnit(DevJefe_Esfera[p], false)
        endif
    else
        set dx=px - 961.
        set dy=py - 432.323669
        set t=1000000.
        if dx > 0.01 then
            set t=RMinBJ(t, ( 1895. - 961. ) / dx)
        elseif dx < - 0.01 then
            set t=RMinBJ(t, ( 25. - 961. ) / dx)
        endif
        if dy > 0.01 then
            set t=RMinBJ(t, ( 803. - 432.323669 ) / dy)
            // Encima del minimapa, que sube más que la consola.
            if 961. + dx * t < 375. then
                set t=RMinBJ(t, ( 780. - 432.323669 ) / dy)
            endif
        elseif dy < - 0.01 then
            set t=RMinBJ(t, ( 63. - 432.323669 ) / dy)
        endif
        call HealthBars__Place(u , cam , 961. + dx * t , 432.323669 + dy * t , 398.)
        // Icono y esfera son billboard y están centrados en su origen: en el mismo punto coinciden en cualquier borde.
        call HealthBars__Place(DevJefe_Esfera[p] , cam , 961. + dx * t , 432.323669 + dy * t , 398.)
        if IsUnitHidden(u) then
            call ShowUnit(u, true)
            call ShowUnit(DevJefe_Esfera[p], true)
            // Nace cada vez que aparece en el borde.
            call SetUnitAnimation(DevJefe_Esfera[p], "birth")
            call QueueUnitAnimation(DevJefe_Esfera[p], "stand")
        endif
    endif
    set u=null
endfunction

function HealthBarsUpdate takes nothing returns nothing
''')
s = base.once(s, '            call Arm_Hud(p , cam)\n', '            call Arm_Hud(p , cam)\n            call DevJefe_Poner(p , cam)\n')

s = base.once(s, '''        call DevWave_Slots(w, n)
        call s__Wave_start(w)
    endfunction
''', '''        call DevWave_Slots(w, n)
        call s__Wave_start(w)
    endfunction
''' + JEFE)
s = base.once(s, '''    set DevWave__Count = 0
    call WaveAIClearTargets()
''', '''    set DevWave__Count = 0
    call WaveAIClearTargets()
    call DevJefe_Limpiar()
''')
s = base.once(s, '''    set Ronda_Reloj = CreateTimer()
    call RegisterWaveFinishEvent(function Ronda_AlTerminar)
''', '''    set Ronda_Reloj = CreateTimer()
    set DevJefe_Reloj = CreateTimer()
    set DevJefe_Carga = CreateTimer()
    set DevJefe_Mira = CreateTimer()
    call DevWave_IA()
    call RegisterWaveSpawnEvent(function DevJefe_Aparece)
    call RegisterWaveDeathEvent(function DevJefe_Muere)
    call RegisterWaveFinishEvent(function Ronda_AlTerminar)
''')
# Balas: sin registro usarían ucol con IsUnitInRangeXY; con él, el círculo de selección escalado.
TIPOS = ['nmcf', 'nlpr', 'ntrh', 'nmtw', 'nmsn', 'nlds', 'nmmu', 'nnsw', 'ntrg', 'ntrd']  # como objetos_v14g.py
forma = {t: (float(a), float(b)) for t, a, b in re.findall(r"call s__UnitHitShape_register\('(\w{4})' , ([\d.]+) , ([\d.]+)\)", s) if t in TIPOS}
assert sorted(forma) == sorted(TIPOS), sorted(forma)
registros = ''
for k, t in enumerate(TIPOS):
    for id, f in ([(f'ne0{k}', 1.25)] + ([(f'nj0{"23456789A"[k - 1]}', 1.8)] if k else [])):
        registros += f"        call s__UnitHitShape_register('{id}' , {round(forma[t][0] * f, 3)} , {min(200., round(forma[t][1] * f, 1))})\n"
h = "        call s__UnitHitShape_register('ntrd' , 4.0 , 64.0)\n"
s = base.once(s, h, h + "        // v14g: élites y jefes, escalados como su modelo (objetos_v14g.py).\n" + registros)
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
