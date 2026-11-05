#!/usr/bin/env python3
"""Sólo prueba, v14h: entrada directa, héroe que recibe daño pero se cura cada 0,03 s, empieza en la ronda RONDA (2 por
defecto) y juega dos rondas.

Registro oculto (Preload, un archivo por línea en lat\\v14h-N.txt), sin textos en pantalla:
- cada élite y jefe al aparecer: tipo, color de Burning Rage, vida y vida esperada;
- cada cambio de estado de la tienda (punto, posición, altura, oculta);
- en la ronda: a los 3 s zonas activas, vacía el arma y lleva al héroe a una zona; a los 4 s toma la munición como
  ESC (Recarga_Cerca y Recarga_Tomar) y registra cargador y reserva; desde los 8 s mata cada 2 s a los de la oleada;
- en el descanso: a los 3 s lleva al héroe junto a la tienda; a los 4 s aviso y abre la tienda como ESC; a los 6 s
  la cierra; a los 40 s la abre otra vez para ver que se cierra al llegar a 0.
Termina a los 6 s de la tercera ronda con FIN.

Uso: prueba_v14h.py ENTRADA.j SALIDA.j [RONDA]
"""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
import puente_v12 as base

ronda = sys.argv[3] if len(sys.argv) > 3 else '2'
s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')
s = base.once(s, 'call TimerStart(CreateTimer(), 0.1, false, function Intro_Begin)', 'call TimerStart(CreateTimer(), 0.1, false, function Entrada_Directa)')
s = base.once(s, 'integer Ronda_Numero = 1\n', f'integer Ronda_Numero = {ronda}\n')
s = base.once(s, 'real Title_CX=', f'''integer Prueba_N= 0
real Prueba_T= 0.
integer Prueba_RT= 0
integer Prueba_DT= 0
integer Prueba_Est= - 1
integer Prueba_Z= - 1
integer Prueba_Rondas= 0
boolean Prueba_Fin= false
group Prueba_G= CreateGroup()
real Title_CX=''')

s = base.once(s, '\nfunction DevJefe_Limpiar takes nothing returns nothing\n', r'''
// TEMPORARY test bridge (scripts/prueba_v14h.py).
function Prueba_Log takes string s returns nothing
    set Prueba_N = Prueba_N + 1
    call PreloadGenClear()
    call Preload(s)
    call PreloadGenEnd("lat\\v14h-" + I2S(Prueba_N) + ".txt")
endfunction

function DevJefe_Limpiar takes nothing returns nothing
''')
s = base.once(s, '''    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''', '''    call Prueba_Log("fuego id=" + I2S(id) + " k=" + I2S(k) + " r=" + I2S(Ronda_Numero) + " jug=" + I2S(DevWave_Jug) + " vida=" + I2S(R2I(GetWidgetLife(u))) + "/" + I2S(R2I(GetUnitState(u, UNIT_STATE_MAX_LIFE))) + " esperada=" + I2S(R2I(0.45 * I2R(R2I(800. * ( 1. + 0.75 * ( Ronda_Numero - 1 ) ) + 0.5)) * DevWave_Jug + 0.5)) + " t=" + R2S(Prueba_T))
    call SaveEffectHandle(DevFuego_HT, GetHandleId(u), 0,''')

# Después de las funciones de la tienda, que usa; se arranca con ExecuteFunc desde DevWave_Arrancar.
s = base.once(s, 'function Shop_Construir takes nothing returns nothing\n', r'''// El héroe recibe daño (con uno invulnerable la IA sólo espera y no salta), pero no muere.
function Prueba_Curar takes nothing returns nothing
    if Game_Hero[0] != null and GetWidgetLife(Game_Hero[0]) > 0.405 then
        call SetWidgetLife(Game_Hero[0], GetUnitState(Game_Hero[0], UNIT_STATE_MAX_LIFE))
    endif
endfunction

function Prueba_Armas takes string q returns nothing
    local integer c = 0
    local string s = q
    loop
        exitwhen c > 6
        if Arm_Tier[c] > 0 then
            set s = s + " c" + I2S(c) + "=" + I2S(Arm_Clip[c]) + "/" + I2S(Arm_Rva[c]) + " max=" + I2S(Arm_Mag[c * 3 + Arm_Tier[c] - 1]) + "/" + I2S(Arm_Res[c * 3 + Arm_Tier[c] - 1])
        endif
        set c = c + 1
    endloop
    call Prueba_Log(s + " t=" + R2S(Prueba_T))
endfunction

function Prueba_Tick takes nothing returns nothing
    local integer z = 0
    local integer o
    local integer n
    local integer c
    local unit u
    local string s
    set Prueba_T = Prueba_T + 1.
    if Prueba_Fin or Ronda_Wave == 0 then
        return
    endif
    if DevTienda_Estado != Prueba_Est then
        set Prueba_Est = DevTienda_Estado
        call Prueba_Log("tienda est=" + I2S(DevTienda_Estado) + " punto=" + I2S(DevTienda_Punto) + " xy=" + I2S(R2I(GetUnitX(Shop_Golem))) + "," + I2S(R2I(GetUnitY(Shop_Golem))) + " f=" + I2S(R2I(GetUnitFacing(Shop_Golem))) + " h=" + I2S(R2I(GetUnitFlyHeight(Shop_Golem))) + " oculta=" + I2S(IntegerTertiaryOp(IsUnitHidden(Shop_Golem), 1, 0)) + " r=" + I2S(Ronda_Numero) + " descanso=" + I2S(IntegerTertiaryOp(Ronda_Descanso, 1, 0)) + " t=" + R2S(Prueba_T))
    endif
    if not Ronda_Descanso then
        set Prueba_DT = 0
        set Prueba_RT = Prueba_RT + 1
        if Prueba_RT == 1 then
            set Prueba_Rondas = Prueba_Rondas + 1
            call Prueba_Log("ronda " + I2S(Ronda_Numero) + " tiendaAbierta=" + I2S(IntegerTertiaryOp(Shop_Open[0], 1, 0)) + " abiertas=" + I2S(Shop_Abiertos) + " t=" + R2S(Prueba_T))
        elseif Prueba_RT == 3 then
            set s = "zonas"
            set n = 0
            set Prueba_Z = - 1
            loop
                exitwhen z > 19
                if Recarga_On[z] then
                    set n = n + 1
                    set s = s + " " + I2S(z) + "u" + I2S(IntegerTertiaryOp(Recarga_Usada[z], 1, 0)) + "fx" + I2S(IntegerTertiaryOp(Recarga_Fx[z] != null, 1, 0))
                    if Prueba_Z < 0 then
                        set Prueba_Z = z
                    endif
                endif
                set z = z + 1
            endloop
            call Prueba_Log(s + " n=" + I2S(n) + " t=" + R2S(Prueba_T))
            set c = 0
            loop
                exitwhen c > 6
                if Arm_Tier[c] > 0 and c != 5 then
                    set Arm_Clip[c] = 0
                    set Arm_Rva[c] = 0
                endif
                set c = c + 1
            endloop
            call Prueba_Armas("vacias")
            call SetUnitX(Game_Hero[0], Recarga_X[Prueba_Z] + 100.)
            call SetUnitY(Game_Hero[0], Recarga_Y[Prueba_Z])
        elseif Prueba_RT == 4 then
            set z = Recarga_Cerca(0)
            call Prueba_Log("cerca zona=" + I2S(z) + " esperada=" + I2S(Prueba_Z) + " aviso=" + I2S(DevTienda_AvisoK[0]) + " dist=" + I2S(R2I(SquareRoot(Pow(GetUnitX(Game_Hero[0]) - Recarga_X[Prueba_Z], 2) + Pow(GetUnitY(Game_Hero[0]) - Recarga_Y[Prueba_Z], 2)))))
            if z >= 0 then
                call Recarga_Tomar(0, z)
            endif
            call Prueba_Armas("tomada")
            call Prueba_Log("despues cerca=" + I2S(Recarga_Cerca(0)) + " usada=" + I2S(IntegerTertiaryOp(Recarga_Usada[Prueba_Z], 1, 0)) + " fx=" + I2S(IntegerTertiaryOp(Recarga_Fx[Prueba_Z] != null, 1, 0)))
        elseif Prueba_RT == 6 and Prueba_Rondas >= 3 then
            set Prueba_Fin = true
            call Prueba_Log("FIN t=" + R2S(Prueba_T))
        elseif Prueba_RT == 7 then
            set n = 0
            set o = WAVE_DEFAULT_OWNER_MIN
            loop
                exitwhen o > WAVE_DEFAULT_OWNER_MAX
                call GroupEnumUnitsOfPlayer(Prueba_G, Player(o), null)
                loop
                    set u = FirstOfGroup(Prueba_G)
                    exitwhen u == null
                    call GroupRemoveUnit(Prueba_G, u)
                    if GetWidgetLife(u) > 0.405 and GetUnitTypeId(u) >= 'ne00' and GetUnitTypeId(u) <= 'ne09' then
                        set n = n + 1
                    endif
                endloop
                set o = o + 1
            endloop
            call Prueba_Log("elites vivas=" + I2S(n) + " r=" + I2S(Ronda_Numero))
        elseif Prueba_RT >= 8 and ModuloInteger(Prueba_RT, 2) == 0 then
            set o = WAVE_DEFAULT_OWNER_MIN
            loop
                exitwhen o > WAVE_DEFAULT_OWNER_MAX
                call GroupEnumUnitsOfPlayer(Prueba_G, Player(o), null)
                loop
                    set u = FirstOfGroup(Prueba_G)
                    exitwhen u == null
                    call GroupRemoveUnit(Prueba_G, u)
                    if GetWidgetLife(u) > 0.405 then
                        call KillUnit(u)
                    endif
                endloop
                set o = o + 1
            endloop
        endif
    else
        set Prueba_RT = 0
        set Prueba_DT = Prueba_DT + 1
        if Prueba_DT == 3 then
            call SetUnitPosition(Game_Hero[0], GetUnitX(Shop_Golem) + 200., GetUnitY(Shop_Golem))
        elseif Prueba_DT == 4 then
            call Prueba_Log("descanso resta=" + I2S(Ronda_Resta) + " cerca=" + I2S(IntegerTertiaryOp(DevTienda_Cerca(0), 1, 0)) + " zona=" + I2S(Recarga_Cerca(0)) + " aviso=" + I2S(DevTienda_AvisoK[0]) + " fuegos=" + I2S(IntegerTertiaryOp(HaveSavedHandle(DevFuego_HT, GetHandleId(DevJefe), 0), 1, 0)))
            call Shop_Abrir(0)
            call Prueba_Log("abierta=" + I2S(IntegerTertiaryOp(Shop_Open[0], 1, 0)) + " reloj=" + I2S(IntegerTertiaryOp(Shop_RelojT != null, 1, 0)))
        elseif Prueba_DT == 5 then
            call Prueba_Log("reloj texto=" + Shop_RelojVisto + " rojo=" + I2S(IntegerTertiaryOp(Shop_RelojRojo, 1, 0)))
        elseif Prueba_DT == 6 then
            call Shop_Cerrar(0)
            call Prueba_Log("cerrada=" + I2S(IntegerTertiaryOp(not Shop_Open[0], 1, 0)) + " reloj=" + I2S(IntegerTertiaryOp(Shop_RelojT != null, 1, 0)))
        elseif Prueba_DT == 39 then
            call SetUnitX(Game_Hero[0], GetUnitX(Shop_Golem) + 150.)
            call SetUnitY(Game_Hero[0], GetUnitY(Shop_Golem))
        elseif Prueba_DT == 40 then
            call Prueba_Log("antes de abrir cerca=" + I2S(IntegerTertiaryOp(DevTienda_Cerca(0), 1, 0)) + " vivo=" + I2S(IntegerTertiaryOp(UnitAlive(Game_Hero[0]), 1, 0)) + " dist=" + I2S(R2I(SquareRoot(Pow(GetUnitX(Game_Hero[0]) - GetUnitX(Shop_Golem), 2) + Pow(GetUnitY(Game_Hero[0]) - GetUnitY(Shop_Golem), 2)))))
            call Shop_Abrir(0)
            call Prueba_Log("abierta otra vez=" + I2S(IntegerTertiaryOp(Shop_Open[0], 1, 0)) + " resta=" + I2S(Ronda_Resta))
        elseif Prueba_DT == 42 then
            call Prueba_Log("reloj texto=" + Shop_RelojVisto + " resta=" + I2S(Ronda_Resta))
        endif
    endif
    set u = null
endfunction

function Prueba_Iniciar takes nothing returns nothing
    call TimerStart(CreateTimer(), 1., true, function Prueba_Tick)
    call TimerStart(CreateTimer(), 0.03, true, function Prueba_Curar)
endfunction

function Shop_Construir takes nothing returns nothing
''')
s = base.once(s, '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n',
              '    call RegisterWaveFinishEvent(function Ronda_AlTerminar)\n    call ExecuteFunc("Prueba_Iniciar")\n')
Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
