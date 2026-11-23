#!/usr/bin/env python3
"""v20t (20/11/2026), fase 3 del rework de habilidades (docs/planes/devmission-rework-habilidades-v20r.md).
Pasivas por impacto de bala (Arm_Impacto), con probabilidad según el intervalo del arma en la mano:
p = clamp(25 % × intervalo / 1 s, 4 %, 25 %): las de fuego rápido la tienen menor, las lentas mayor.
- Freezer: Destructo Disc (A0IY) sale solo, lo lanza la copia como antes la X. Enfriamiento interno 1,5 s; no se
  lanza si el anterior sigue en curso.
- Cairne: Marca ancestral sobre el blanco golpeado (el de más vida a 400 de él), como antes la S. Enfriamiento 3 s.
- Tauren: Disparo encantado nuevo: el daño del impacto se repite a 300 alrededor del blanco con el efecto del
  pisotón (WarStompCaster). Enfriamiento 1 s. Sustituye al triple del 4.º impacto.
Arm_Impacto está antes que el código de las copias: deja el golpe en Prc_* y llama Prc_Golpe con ExecuteFunc.
Uso: v20t.py ENTRADA.j SALIDA.j [prueba]   (normal de v20s; prueba de v20s-prueba)
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


nota = (lambda s: f'        call Dia_Anotar({s})\n') if prueba else (lambda s: '')
cambia('boolean Frm_Corte= false\n', '''boolean Frm_Corte= false
// v20t: golpe de bala pendiente de las pasivas por impacto (Prc_Golpe) y su enfriamiento por jugador.
integer Prc_P= 0
unit Prc_T= null
unit Prc_C= null
real Prc_D= 0.
integer Prc_Tipo= 0
real array Prc_Listo
''')
cambia('''    // v19b: Disparo encantado del Tauren: onda del 4.º impacto, el daño de la bala a 200 alrededor del blanco.''',
       '''    // v20t: Disparo encantado del Tauren: con probabilidad, el daño de la bala a 300 alrededor del blanco (pisotón).''')
cambia('''        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Human\\\\FlakCannons\\\\FlakTarget.mdl", x, y))
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Enc_Grupo, x, y, 328., null)''',
       '''        call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\Orc\\\\WarStomp\\\\WarStompCaster.mdl", x, y))
        set s__GroundCollision_shaped=true
        call GroupEnumUnitsInRange(Enc_Grupo, x, y, 428., null)''')
cambia('s__GroundCollision_touches(u , x , y , 200.) then\n                call UnitDamageTarget(caster, u, d, false, false, Dano_Ataque(tipo), Dano_TipoArma, null)',
       's__GroundCollision_touches(u , x , y , 300.) then\n                call UnitDamageTarget(caster, u, d, false, false, Dano_Ataque(tipo), Dano_TipoArma, null)')
cambia('''        if GetUnitTypeId(Game_Hero[GetPlayerId(s__RapidBolt_owner[m])]) == 'h005' and Tec_Niv[GetPlayerId(s__RapidBolt_owner[m]) * 100 + 69] > 0 then
            set Enc_K[GetPlayerId(s__RapidBolt_owner[m])]=Enc_K[GetPlayerId(s__RapidBolt_owner[m])] + 1
            if Enc_K[GetPlayerId(s__RapidBolt_owner[m])] >= 4 then
                set Enc_K[GetPlayerId(s__RapidBolt_owner[m])]=0
                call Enc_Onda(caster , s__RapidBolt_owner[m] , target , d , Bala_Tipo[m])
                set d=d * 3.
            endif
        endif
        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)''',
       '''        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
        // v20t: pasivas por impacto de Tauren, Freezer y Cairne (Prc_Golpe).
        set Prc_P=GetPlayerId(s__RapidBolt_owner[m])
        if Prc_P >= 0 and Prc_P <= 11 and ( GetUnitTypeId(Game_Hero[Prc_P]) == 'h005' or GetUnitTypeId(Game_Hero[Prc_P]) == 'hFrz' or GetUnitTypeId(Game_Hero[Prc_P]) == 'h006' ) then
            set Prc_T=target
            set Prc_C=caster
            set Prc_D=d
            set Prc_Tipo=Bala_Tipo[m]
            call ExecuteFunc("Prc_Golpe")
            set Prc_T=null
            set Prc_C=null
        endif''')
cambia('''function Cop_Marca takes nothing returns nothing
    local integer p = Cop_Inicio()
    local unit src
''', '''// v20t: cuerpo de la Marca ancestral, desde el botón (Cop_Marca) o desde el impacto de bala (Prc_Golpe).
function Cop_MarcaHacer takes integer p returns nothing
    local unit src
''')
cambia('''    call Cop_Arrancar()
    set src = null
    set o = null
    set mejor = null
endfunction
''', f'''    call Cop_Arrancar()
    set src = null
    set o = null
    set mejor = null
endfunction

function Cop_Marca takes nothing returns nothing
    call Cop_MarcaHacer(Cop_Inicio())
endfunction

// v20t: pasivas por impacto de bala. Probabilidad según el intervalo del arma en la mano (4 % a 25 %).
function Prc_Golpe takes nothing returns nothing
    local integer p = Prc_P
    local unit h = Game_Hero[p]
    local integer t = GetUnitTypeId(h)
    local real ahora = TimerGetElapsed(s__RapidPair_clock)
    local real c
    if h == null or Prc_T == null or not UnitAlive(h) or ahora < Prc_Listo[p] then
        set h = null
        return
    endif
    set c = RMaxBJ(0.04, RMinBJ(0.25, 0.25 * Arm_Int[Arm_W(p)]))
    if GetRandomReal(0., 1.) >= c then
        set h = null
        return
    endif
    if t == 'h005' then
        set Prc_Listo[p] = ahora + 1.
        call Enc_Onda(Prc_C, Player(p), Prc_T, Prc_D, Prc_Tipo)
{nota('"pasiva tauren j" + I2S(p) + " dano " + R2S(Prc_D) + " prob " + R2S(c)')}    elseif t == 'hFrz' then
        if not Dcp_Ocupada(p, 'A0IY') and Dcp_Lanzar(h, 'A0IY', 0, "roar", null, 0., 0.) then
            set Prc_Listo[p] = ahora + 1.5
{nota('"pasiva destructo j" + I2S(p) + " prob " + R2S(c)')}        endif
    elseif t == 'h006' and Cop_N < 190 then
        set Prc_Listo[p] = ahora + 3.
        set Cop_HX = GetUnitX(h)
        set Cop_HY = GetUnitY(h)
        set Cop_PX = GetUnitX(Prc_T)
        set Cop_PY = GetUnitY(Prc_T)
        set Cop_LA = Atan2(Cop_PY - Cop_HY, Cop_PX - Cop_HX)
        set Cop_LD = SquareRoot((Cop_PX - Cop_HX) * (Cop_PX - Cop_HX) + (Cop_PY - Cop_HY) * (Cop_PY - Cop_HY))
        set Cop_Fac = Tec_FacAb(p, 'ACb6')
        call Cop_MarcaHacer(p)
{nota('"pasiva marca j" + I2S(p) + " prob " + R2S(c)')}    endif
    set h = null
endfunction
''')
if prueba:
    for viejo, nuevo in (('lat\\\\v20s-', 'lat\\\\v20t-'), ('v20s-don.txt', 'v20t-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20t', 'prueba' if prueba else 'normal')
