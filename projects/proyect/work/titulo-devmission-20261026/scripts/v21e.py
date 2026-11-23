#!/usr/bin/env python3
"""v21e (22/11/2026): Goku de D.O.N 2.1a (fase 2 del plan devmission-rework-habilidades-don21a.md) y sonidos 3D.

1. Código de Goku 2.1a trasplantado (goku21_trasplante.py + don_misil.py: GLOB.j, FUNC.j) tras Don_MotInit. Sustituye
   al Goku de 1.8c: Q Kamehameha (A0O6), W Warp Kamehameha (A0IA), E Transmisión Instantánea (por script, a una unidad
   aliada o enemiga), R Ultimate (A0BZ), que cambia con la forma: base Genki Dama, SSJ Super Kamehameha, SSJ3 Dragon
   Fist, SSJ Dios Big Bang, SSJ Blue Kaioken, Ultra Instinto. Las técnicas las lanza la copia (Dcp) como hasta ahora.
2. Formas por muertes en la oleada (15/30/50/70/90): sin gasto de maná ni vuelta atrás dentro de la oleada; al acabarla
   vuelve a la base. Power Up (X) desaparece.
3. Color del Kamehameha (Q) como en 1.8c: amarillo en SSJ3, rojo en SSJ Dios y en Kaioken (Blue con Kaioken).
4. Kaioken refuerza al cuerpo de Goku, no a la copia.
5. Sonidos de los personajes D.O.N (Goku, Freezer, Trunks, Naruto) en 3D, como los disparos de v17d: 600/10000, corte
   3000, canal 11. Los que no se lanzaban en un punto suenan en la copia que lanzó la técnica (o en el cuerpo). Los
   estéreo se cambian por copias mono (sonidos_don3d.py, CAMBIOS.tsv).
Uso: v21e.py ENTRADA.j GLOB.j FUNC.j CAMBIOS.tsv SALIDA.j [prueba]   (normal de v21d; prueba de v21d-prueba).
"""
import re
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_bytes().decode('latin-1')
glob = Path(sys.argv[2]).read_bytes().decode('latin-1').replace('\r\n', '\n')
func = Path(sys.argv[3]).read_bytes().decode('latin-1').replace('\r\n', '\n')
CAMBIOS = dict(l.rstrip('\n').split('\t') for l in open(sys.argv[4], encoding='latin-1') if l.strip())
prueba = len(sys.argv) > 6 and sys.argv[6] == 'prueba'
crlf = '\r\n' in src
src = src.replace('\r\n', '\n')
U = lambda s: s.encode('utf-8').decode('latin-1')


def cambia(viejo, nuevo, veces=1):
    global src
    viejo, nuevo = U(viejo), U(nuevo)
    assert src.count(viejo) == veces, (src.count(viejo), viejo[:90])
    src = src.replace(viejo, nuevo)


def funcion(nombre, nuevo):
    global src
    pat = re.compile(r'^function %s takes.*?^endfunction\n' % nombre, re.S | re.M)
    assert len(pat.findall(src)) == 1, nombre
    src = pat.sub(lambda m: U(nuevo), src, count=1)


# ---------------------------------------------------------------- sonidos 3D (sobre un texto JASS)
def sonidos3d(t, cuerpo_de):
    """CreateSound 3D (ruta mono), Son_DON3D al final de cada *_InitDON y PlaySoundBJ con posición."""
    def crea(m):
        ruta = m.group(1).replace('\\\\', '\\')
        ruta = CAMBIOS.get(ruta, ruta).replace('\\', '\\\\')
        return f'CreateSound("{ruta}",{m.group(2)},true,true,'
    n = 0

    def init(m):
        nonlocal n
        cuerpo, c = re.subn(r'CreateSound\("([^"]+)",(true|false),(?:true|false),(?:true|false),', crea, m.group(0))
        n += c
        vars_ = re.findall(r'^set (\w+)=CreateSound\(', cuerpo, re.M)
        return cuerpo[:-len('endfunction\n')] + ''.join(f'call Son_DON3D({v})\n' for v in vars_) + 'endfunction\n'
    t, k = re.subn(r'^function \w+_InitDON takes.*?^endfunction\n', init, t, flags=re.S | re.M)

    def bloque(m):
        nombre = m.group(1)
        for pref, kk in cuerpo_de.items():
            if nombre.startswith(pref):
                return re.sub(r'call PlaySoundBJ\((\w+)\)', lambda q: f'call Son_DONSuena({q.group(1)},{kk})', m.group(0))
        return m.group(0)
    t = re.sub(r'^function (\w+) takes.*?^endfunction\n', bloque, t, flags=re.S | re.M)
    return t, n, k


# ---------------------------------------------------------------- bloque de Goku 2.1a
assert func.count('call PlaySoundBJ(G2S_charge)') == 5
func = func.replace('call PlaySoundBJ(G2S_charge)', 'call Son_DONSuenaEn(G2S_charge,G2V_Caster[7150])')
func, nsg, kig = sonidos3d(func, {'G2F_': 0})
assert 'PlaySoundBJ(' not in func and kig == 1, kig

fn = {m.group(1): m for m in re.finditer(r'^function (\w+) takes.*?^endfunction\n', func, re.S | re.M)}


def fpatch(nombre, viejo, nuevo, veces=1):
    global func
    m = re.search(r'^function %s takes.*?^endfunction\n' % nombre, func, re.S | re.M)
    cuerpo = m.group(0)
    assert cuerpo.count(viejo) == veces, (nombre, cuerpo.count(viejo), viejo)
    func = func[:m.start()] + cuerpo.replace(viejo, nuevo) + func[m.end():]


# Q: el que lanza es la copia (G2V_QC); el cuerpo (Caster[7150]) sólo da la forma y el buff de Kaioken.
ROJO = ['G2F_kamehameha_goku_god_Func020C', 'G2F_kamehameha_goku_god_Func044C', 'G2F_kamehameha_goku_god_Func052C',
        'G2F_kamehameha_goku_god_Func091C', 'G2F_kamehameha_goku_god2_Func004C']
for r in ROJO:
    func = re.sub(r'^(function %s takes nothing returns boolean\n).*?^endfunction\n' % r,
                  lambda m: m.group(1) + 'return G2_Rojo()\nendfunction\n', func, count=1, flags=re.S | re.M)


def qc(m):
    return m.group(0).replace('G2V_Caster[7150]', 'G2V_QC') if m.group(1).startswith('G2F_kamehameha_goku_god') else m.group(0)


func = re.sub(r'^function (\w+) takes.*?^endfunction\n', qc, func, flags=re.S | re.M)
fpatch('G2F_kamehameha_goku_god_Actions', 'set G2V_Point[7151]=GetSpellTargetLoc()\n',
       'set G2V_QC=GetTriggerUnit()\nset G2V_Point[7151]=GetSpellTargetLoc()\n')
# amarillo en SSJ3 (sólo las ramas "no rojo")
fpatch('G2F_kamehameha_goku_god_Actions', 'call SetUnitVertexColorBJ(bj_lastCreatedUnit,100,100,100,80.)',
       'call G2_Color(bj_lastCreatedUnit,100.,100.,100.,80.)')
fpatch('G2F_kamehameha_goku_god_Actions', 'call SetUnitVertexColorBJ(bj_lastCreatedUnit,100,100,100,15.)',
       'call G2_Color(bj_lastCreatedUnit,100.,100.,100.,15.)')
fpatch('G2F_kamehameha_goku_god2_Actions', 'call SetUnitVertexColorBJ(bj_lastCreatedUnit,60.,60.,80.,10.)',
       'call G2_Color(bj_lastCreatedUnit,60.,60.,80.,10.)')
# Kaioken: el buff mira al cuerpo, y el dummy lo lanza junto al cuerpo
assert func.count("UnitHasBuffBJ(G2V_Caster[4410],'B05J')") == 2
func = func.replace("UnitHasBuffBJ(G2V_Caster[4410],'B05J')", "UnitHasBuffBJ(G2V_Caster[7150],'B05J')")
fpatch('G2F_Ultimate_Goku_GOd_Actions', 'call IssueTargetOrderById(bj_lastCreatedUnit,$D0062,G2V_Caster[4410])',
       'call SetUnitX(bj_lastCreatedUnit,GetUnitX(G2V_Caster[7150]))\ncall SetUnitY(bj_lastCreatedUnit,GetUnitY(G2V_Caster[7150]))\n'
       'call IssueTargetOrderById(bj_lastCreatedUnit,$D0062,G2V_Caster[7150])')
# Formas: las da Frm_Matar (G2_Subir); no hay gasto ni vuelta atrás por tiempo
func = re.sub(r'^(function G2F_Saian_Goku_God_Func001C takes nothing returns boolean\n).*?^endfunction\n',
              lambda m: m.group(1) + 'return(G2V_Bool[7150]==false)and(G2V_Int[7160]<6)\nendfunction\n', func, count=1,
              flags=re.S | re.M)
for t, n in (('call EnableTrigger(G2T_SaianGokuTImer)\n', 4), ('call EnableTrigger(G2T_SaianGoku_GodTimer)\n', 1)):
    assert func.count(t) == n, t
    func = func.replace(t, '')
fpatch('G2F_Saian_Goku_God2_Actions', 'call AddSpecialEffectLocBJ(G2V_Point[7150],"war3mapImported\\\\Slam.mdx")',
       'call AddSpecialEffectLocBJ(G2V_Point[7160],"war3mapImported\\\\Slam.mdx")', 4)

QUITA = ['B05J', 'A00Y', 'AG2c', 'A0OE', 'AG2b', 'A0O7', 'A0OD', 'A0OC', 'A0OB', 'A069', 'A06A', 'A06B', 'A0O8', 'A0O9',
         'A0OA']
CABEZA = '''// ==== v21e: Goku de Battle Stadium D.O.N 2.1a (trasplantado; ver scripts/goku21_trasplante.py) ====
// Sonidos 3D de los personajes D.O.N (como los disparos de v17d). k: 0 Goku, 1 Freezer, 2 Trunks, 3 Naruto.
function Son_DON3D takes sound s returns nothing
    call SetSoundChannel(s, 11)
    call SetSoundDistances(s, 600., 10000.)
    call SetSoundDistanceCutoff(s, 3000.)
endfunction

function Son_DONDe takes integer t returns integer
    if t == 'hGok' or t == 'hCpG' then
        return 0
    elseif t == 'hFrz' or t == 'hCpF' then
        return 1
    elseif t == 'hTrk' or t == 'hCpT' then
        return 2
    elseif t == 'hNar' or t == 'hNaK' or t == 'hCpN' or t == 'hCpK' then
        return 3
    endif
    return -1
endfunction

function Son_DONSuenaEn takes sound s, unit u returns nothing
    set bj_lastPlayedSound = s
    if s != null and u != null and GetUnitTypeId(u) != 0 then
        call SetSoundPosition(s, GetUnitX(u), GetUnitY(u), 0.)
        call StartSound(s)
    endif
endfunction

// En la última copia de ese personaje (la que lanzó la técnica); si ya no existe, en su cuerpo.
function Son_DONSuena takes sound s, integer k returns nothing
    local unit u = Son_Foco[k]
    local integer p = 0
    if u == null or GetUnitTypeId(u) == 0 then
        set u = null
        loop
            exitwhen p > 11 or u != null
            if Game_Hero[p] != null and Son_DONDe(GetUnitTypeId(Game_Hero[p])) == k then
                set u = Game_Hero[p]
            endif
            set p = p + 1
        endloop
    endif
    call Son_DONSuenaEn(s, u)
    set u = null
endfunction

// Rojo: SSJ Dios, o Blue con Kaioken. Amarillo: SSJ3.
function G2_Rojo takes nothing returns boolean
    return G2V_Int[7160] == 4 or (G2V_Int[7160] == 5 and GetUnitAbilityLevel(G2V_Caster[7150], 'B05J') > 0)
endfunction

function G2_Color takes unit u, real r, real g, real b, real a returns nothing
    if G2V_Int[7160] == 3 then
        call SetUnitVertexColorBJ(u, 100., 100., 0., a)
    else
        call SetUnitVertexColorBJ(u, r, g, b, a)
    endif
endfunction

'''
COLA = '''
// v21e: forma base (al armar el cuerpo y al acabar la oleada).
function G2_Base takes nothing returns nothing
    local unit b = G2V_Caster[7150]
    call DisableTrigger(G2T_Saian_Goku_God2)
    if G2V_Bool[7150] then
        call RemoveUnit(G2V_Caster[7160])
        call DestroyEffect(G2V_Effect[7161])
        call DestroyEffect(G2V_Effect[7162])
        set G2V_Bool[7150] = false
    endif
    call StopSound(G2S_instinctauraloop, false, false)
    call StopSound(G2S_aura_power_fluxing, false, false)
    call StopSound(G2S_super_saiyan_aura, false, false)
    set G2V_Int[7160] = 1
    if b != null then
''' + ''.join(f"        call UnitRemoveAbility(b, '{a}')\n" for a in QUITA) + '''        call UnitAddAbility(b, 'A069')
        call SetUnitTimeScalePercent(b, 100.)
    endif
    set b = null
endfunction

// Sube una forma (carga de 0,8 s de D.O.N). La llama Frm_Matar.
function G2_Subir takes nothing returns nothing
    if G2V_Caster[7150] != null and UnitAlive(G2V_Caster[7150]) and not G2V_Bool[7150] and G2V_Int[7160] < 6 then
        call G2F_Saian_Goku_God_Actions()
    endif
endfunction

function G2_Armar takes nothing returns nothing
    set G2V_Caster[7150] = G2_PB
    call G2_Base()
endfunction

'''

# ---------------------------------------------------------------- globales
cambia('''boolean Gk_MisChoque = false
''', '''boolean Gk_MisChoque = false
// v21e: Goku 2.1a y sonidos 3D de D.O.N
unit G2V_QC = null
unit G2_PB = null
unit array Son_Foco
''' + U(glob if glob.endswith('\n') else glob + '\n'))

# ---------------------------------------------------------------- bloque tras Don_MotInit
cambia('''    set Missile__expression[Don_MOT] = Condition(function Don_MotIterar)
endfunction
''', '''    set Missile__expression[Don_MOT] = Condition(function Don_MotIterar)
endfunction

''' + CABEZA + func + COLA)

# ---------------------------------------------------------------- sonidos 3D de Freezer, Trunks y Naruto
ini = src.index('// ==== v21e: Goku de Battle Stadium')
resto, nsd, kid = sonidos3d(src[ini + len(CABEZA) + len(func):], {'FzF_': 1, 'TrF_': 2, 'NaF_': 3})
assert kid == 3, kid
src = src[:ini + len(CABEZA) + len(func)] + resto
for p in ('FzF_', 'TrF_', 'NaF_'):
    assert not re.search(r'^function %s\w* takes(?:(?!^endfunction).)*PlaySoundBJ\(' % p, src, re.S | re.M), p
assert src.index('function FzF_') > src.index('function Son_DONSuena takes')

# ---------------------------------------------------------------- copia (Dcp)
funcion('Dcp_GkReal', '''function Dcp_GkReal takes integer a returns integer
    if a == 'AGk1' then
        return 'A0O6'
    elseif a == 'AGk2' then
        return 'A0IA'
    elseif a == 'AGk3' then
        return 'A0BZ'
    endif
    return a
endfunction
''')
cambia('''    if a == 'A00P' then
        return 2500.
''', '''    if a == 'A0O6' or a == 'A00P' then
        return 2500.
''')
PIEZAS = ['A0O7', 'AG2b', 'A0O8', 'A0O9', 'A0OA', 'A0OB', 'A0OC', 'A0OD']
cambia('''    call Dcp_Pieza(b, c, 'A0HX')
    if tb == 'hGok' and GkV_n8[$B18] == 5 then
        call AddUnitAnimationProperties(c, "alternate", true)
    endif
''', '''    call Dcp_Pieza(b, c, 'A0HX')
''' + ''.join(f"    call Dcp_Pieza(b, c, '{a}')\n" for a in PIEZAS) + '''    if Son_DONDe(tc) >= 0 then
        set Son_Foco[Son_DONDe(tc)] = c
    endif
''')
cambia('''    call UnitRemoveAbility(c, 'A0HX')
endfunction
''', '''    call UnitRemoveAbility(c, 'A0HX')
''' + ''.join(f"    call UnitRemoveAbility(c, '{a}')\n" for a in PIEZAS) + '''endfunction
''')
# Son_DONDe se define después de Dcp_Lanzar: el foco se fija con su copia en línea.
src = src.replace('''    if Son_DONDe(tc) >= 0 then
        set Son_Foco[Son_DONDe(tc)] = c
    endif
''', '''    if tc == 'hCpG' then
        set Son_Foco[0] = c
    elseif tc == 'hCpF' then
        set Son_Foco[1] = c
    elseif tc == 'hCpT' then
        set Son_Foco[2] = c
    else
        set Son_Foco[3] = c
    endif
''')
cambia('''    elseif a == 'A0HW' then
        return IsTriggerEnabled(NaV_zu)
''', '''    elseif a == 'A0HW' then
        return IsTriggerEnabled(NaV_zu)
    elseif a == 'A0O6' then
        return IsTriggerEnabled(G2T_kamehameha_goku_god2)
    elseif a == 'A0IA' then
        return IsTriggerEnabled(G2T_Homing) or IsTriggerEnabled(G2T_slider)
    elseif a == 'A0BZ' then
        return IsTriggerEnabled(G2T_SF_1st) or IsTriggerEnabled(G2T_SF_MOve) or IsTriggerEnabled(G2T_Superkamehameha_goku_god) or IsTriggerEnabled(G2T_DragonFist2) or IsTriggerEnabled(G2T_Ultissgodred) or IsTriggerEnabled(G2T_UltraInstinct)
''')

# ---------------------------------------------------------------- Goku: armar, relevo, init
funcion('Gk_Armar', '''function Gk_Armar takes integer p returns nothing
    local unit b = Game_Hero[p]
    // v21e: técnicas de D.O.N 2.1a; la forma empieza en la base (G2_Armar).
    set Gk_Cuerpo = b
    call UnitAddAbility(b, 'A0O6')
    call SetUnitAbilityLevel(b, 'A0O6', 4)
    call UnitAddAbility(b, 'A0IA')
    call SetUnitAbilityLevel(b, 'A0IA', 4)
    call UnitAddAbility(b, 'A0BZ')
    call SetUnitAbilityLevel(b, 'A0BZ', 3)
    set G2_PB = b
    call ExecuteFunc("G2_Armar")
    set G2_PB = null
    set b = null
endfunction
''')
cambia('''function Gk_Relevo takes nothing returns nothing''', '''// v21e: Transmisión Instantánea. Aparece al otro lado de la unidad (aliada o enemiga), o encima si no se puede pisar.
function Gk_Transmision takes unit b, unit t returns nothing
    local real a = Atan2(GetUnitY(t) - GetUnitY(b), GetUnitX(t) - GetUnitX(b))
    local real x = GetUnitX(t) + 90. * Cos(a)
    local real y = GetUnitY(t) + 90. * Sin(a)
    if IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
        set x = GetUnitX(t)
        set y = GetUnitY(t)
    endif
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\NightElf\\\\Blink\\\\BlinkCaster.mdl", GetUnitX(b), GetUnitY(b)))
    call SetUnitX(b, x)
    call SetUnitY(b, y)
    call SetUnitFacing(b, bj_RADTODEG * a + 180.)
    call DestroyEffect(AddSpecialEffect("Abilities\\\\Spells\\\\NightElf\\\\Blink\\\\BlinkTarget.mdl", x, y))
    call PlaySoundOnUnitBJ(G2S_teleport2, 100., b)
endfunction

function Gk_Relevo takes nothing returns nothing''')
cambia('''            // v19c: Power Up sigue en el héroe; el resto lo lanza una copia y el héroe sigue libre.
            if a == 'AGk4' then
                call s__RapidPair_endDash(this, false)
                call s__RapidPair_finish(this, false)
                set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
                call IssueImmediateOrder(b, "voodoo")
            elseif Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b)), Dcp_GkReal(a)) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Todavía en curso: espera a que termine.")
            elseif a == 'AGk1' then
                // A00P es Serpent Ward (AOsw): su orden es ward (corrección del 13/11; shockwave no la lanzaba).
                call Dcp_Lanzar(b, 'A00P', 2, "ward", null, x, y)
            elseif a == 'AGk2' then
                call Dcp_Lanzar(b, 'A0IA', 1, "thunderbolt", t, x, y)
            elseif a == 'AGk3' then
                call Dcp_Lanzar(b, 'A0BZ', 2, "rainoffire", null, x, y)
            else
                call Dcp_Lanzar(b, 'A01G', 2, "rainoffire", null, x, y)
            endif
''', '''            // v21e: la Transmisión Instantánea mueve al héroe; el resto lo lanza una copia y el héroe sigue libre.
            if a == 'AGk5' then
                if t != null and t != b and UnitAlive(t) then
                    call s__RapidPair_endDash(this, false)
                    call s__RapidPair_finish(this, false)
                    set s__GroundMotion_hasGoal[s__RapidPair_motion[this]] = false
                    call Gk_Transmision(b, t)
                endif
            elseif Dcp_Ocupada(GetPlayerId(GetOwningPlayer(b)), Dcp_GkReal(a)) then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Todavía en curso: espera a que termine.")
            elseif a == 'AGk1' then
                // A0O6 es Serpent Ward (AOsw): orden ward.
                call Dcp_Lanzar(b, 'A0O6', 2, "ward", null, x, y)
            elseif a == 'AGk2' then
                call Dcp_Lanzar(b, 'A0IA', 1, "thunderbolt", t, x, y)
            elseif a == 'AGk3' then
                // A0BZ de 2.1a es ACmp: orden impale.
                call Dcp_Lanzar(b, 'A0BZ', 2, "impale", null, x, y)
            endif
''')
cambia('''    call Gk_InitDON()
    set Gk_OrdenSSJ''', '''    call ExecuteFunc("G2_InitDON")
    set Gk_OrdenSSJ''')
cambia('''    call RegisterSpellEffectEvent('AGk4', function Gk_Relevo)
''', '')

# ---------------------------------------------------------------- formas por muertes
LOG = '                call Dia_Anotar("forma goku " + I2S(n) + " pts " + I2S(Frm_Pts[k]) + "/" + I2S(DevWave_Total))\n' if prueba else ''
if prueba:
    cambia('''                call Frm_Aviso(k, "¡Super Saiyan 4!")
            endif
    call Dia_Anotar("forma goku " + I2S(GkV_n8[$B18]) + " pts " + I2S(Frm_Pts[k]) + "/" + I2S(DevWave_Total))
''', '''                call Frm_Aviso(k, "¡Super Saiyan 4!")
            endif
''')
cambia('''    if t == 'hGok' and h == GkV_s8[$B18] and not GkV_o8[$B18] then
        if Frm_Llega(k, 85) then
            set n = 5
        elseif Frm_Llega(k, 60) then
            set n = 4
        elseif Frm_Llega(k, 40) then
            set n = 3
        elseif Frm_Llega(k, 20) then
            set n = 2
        endif
        if GkV_n8[$B18] < n then
            set GkV_o8[$B18] = true
            set GkV_n8[$B1F] = 1
            call ExecuteFunc("GkF_B77")
            if GkV_n8[$B18] == 2 then
                call Frm_Aviso(k, "¡Super Saiyan!")
            elseif GkV_n8[$B18] == 3 then
                call Frm_Aviso(k, "¡Super Saiyan 2!")
            elseif GkV_n8[$B18] == 4 then
                call Frm_Aviso(k, "¡Super Saiyan 3!")
            elseif GkV_n8[$B18] == 5 then
                call Frm_Aviso(k, "¡Super Saiyan 4!")
            endif
        endif
''', '''    if t == 'hGok' and h == G2V_Caster[7150] and not G2V_Bool[7150] then
        // v21e: formas de D.O.N 2.1a (base, SSJ, SSJ3, SSJ Dios, SSJ Blue, Ultra Instinto).
        if Frm_Llega(k, 90) then
            set n = 6
        elseif Frm_Llega(k, 70) then
            set n = 5
        elseif Frm_Llega(k, 50) then
            set n = 4
        elseif Frm_Llega(k, 30) then
            set n = 3
        elseif Frm_Llega(k, 15) then
            set n = 2
        endif
        if G2V_Int[7160] < n then
            call G2_Subir()
            if G2V_Bool[7150] then
                set n = G2V_Int[7160] + 1
''' + LOG + '''                if n == 2 then
                    call Frm_Aviso(k, "¡Super Saiyan!")
                elseif n == 3 then
                    call Frm_Aviso(k, "¡Super Saiyan 3!")
                elseif n == 4 then
                    call Frm_Aviso(k, "¡Super Saiyan Dios!")
                elseif n == 5 then
                    call Frm_Aviso(k, "¡Super Saiyan Blue!")
                else
                    call Frm_Aviso(k, "¡Ultra Instinto!")
                endif
            endif
        endif
''')
cambia('''    if GkV_s8[$B18] != null then
        call ExecuteFunc("GkF_Bf7")
        call DisableTrigger(GkV_ba)
    endif
''', '''    if G2V_Caster[7150] != null then
        call G2_Base()
    endif
''')

# ---------------------------------------------------------------- libro
cambia('''    set Cua_Nom[40] = "Super Dragon Fist"
    set Cua_Des[40] = "Técnica de D.O.N."''', '''    set Cua_Nom[40] = "Ultimate"
    set Cua_Des[40] = "Técnica de D.O.N.|nCambia con la forma."''')
cambia('''    set Tec_Real[41] = 'A01G'
    set Tec_Max[41] = 1
    set Tec_Tecla[41] = "E"
    set Tec_Ini[41] = 0
    set Cua_Nom[41] = "Spirit Bomb"
    set Cua_Des[41] = "Técnica de D.O.N."''', '''    set Tec_Real[41] = 'AGk5'
    set Tec_Max[41] = 1
    set Tec_Tecla[41] = "E"
    set Tec_Ini[41] = 0
    set Cua_Nom[41] = "Instant Transmission"
    set Cua_Des[41] = "Técnica de D.O.N.|nJunto a una unidad."''')
cambia('''    set Tec_Real[43] = 'A00P'
''', '''    set Tec_Real[43] = 'A0O6'
''')
cambia('''    set Cua_Nom[44] = "Super Saiyan"
    set Cua_Des[44] = "Técnica de D.O.N."''', '''    set Cua_Nom[44] = "Formas"
    set Cua_Des[44] = "Suben con las muertes."''')

if prueba:
    for v, n in (('lat\\\\v21d-', 'lat\\\\v21e-'), ('v21d-don.txt', 'v21e-don.txt')):
        assert v in src, v
        src = src.replace(v, n)
print('sonidos: CreateSound', nsg + nsd, '| bloque Goku', len(func.splitlines()), 'líneas')
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[5]).write_bytes(src.encode('latin-1'))
