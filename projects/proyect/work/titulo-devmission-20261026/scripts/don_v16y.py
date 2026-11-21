#!/usr/bin/env python3
"""v16y (13/11/2026): revisión de habilidades de Freezer, Trunks y Naruto tras la prueba de Leon.

Leon (13/11/2026): "unas de trunk como el burning attack no funciona/ freezer con su disco, naruto su dummy effecto
espcial del shuriken no desaparece, y las habilidades en el modo kyubi, evaluemos para ver si estan realemente bien o
necesitan unos fix".

Cambios (ver Proyect/docs/planes/devmission-don-v16u.md, sección v16y):
- Niveles: A0IY (Destructo Disc, ACro), A0IZ (Power Up, Absk), A0H5 (Power Up, AOvd) y A0I5 (Finish Sign, ACro) no
  tienen alev en D.O.N, así que valen el nivel por defecto de su base (1). v16u les puso 4 (regla equivocada "máximo
  nivel con datos"); A0IY a nivel 4 usa los datos de "Angry Explosion". Pasan a 1 en el j y en el w3a.
- RasenShuriken en modo Kyuubi: la primera pieza h09P se creaba sin vida temporal ni variable y quedaba para siempre
  (también en D.O.N). Recibe 1,8 s, lo mismo que la pieza que vuela (h0DI).
- Relanzar: sin enfriamiento (pedido de Leon), un segundo lanzamiento mientras vuela el anterior pisaba el estado de una
  sola instancia de D.O.N y dejaba piezas huérfanas. El relevo rechaza el botón mientras su motor sigue encendido
  (Destructo Disc admite varios a la vez y no se bloquea).
- Modo Kyuubi: H0D9 no tiene Kage Bunshin (A00T) ni Rasengan (A0AI): el relevo los rechaza en esa forma. Atributos de
  H0D9 en Na_Stat. Velocidad 350 en las filas hNar y hNaK (el morfo devolvía 300).
- Avisos en el chat (no registros): cuerpo ocupado por otra habilidad y orden rechazada por el cuerpo.
- El aviso de Kyuubi Chakra Blast estaba en latin-1; pasa a UTF-8.

Uso: don_v16y.py v16x/war3map.j v16u/war3map.w3a v16u/war3map.w3u SALIDA_DIR
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from w3b_titulo import parse, encode
from objetos_v12k import parse_w3a, encode_w3a

j_in, a_in, u_in, out = sys.argv[1:5]
out = Path(out)
j = Path(j_in).read_bytes()
crlf = lambda b: b.replace(b'\r\n', b'\n').replace(b'\n', b'\r\n')


def una(antes, despues):
    global j
    if isinstance(antes, str):
        antes = antes.encode('utf-8')
    if isinstance(despues, str):
        despues = despues.encode('utf-8')
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == 1, (antes[:90], j.count(antes))
    j = j.replace(antes, despues)


# --- niveles ---
for a in ('A0IY', 'A0IZ', 'A0H5', 'A0I5'):
    una(f"call SetUnitAbilityLevel(b, '{a}', 4)\n", f"call SetUnitAbilityLevel(b, '{a}', 1)\n")

# --- RasenShuriken Kyuubi: la pieza h09P del inicio no tenía final ---
una("call CreateNUnitsAtLoc(1,'h09P',GetOwningPlayer(NaV_s8[5140]),NaV_r8[5142],NaV_O8[5140])\n"
    "call SetUnitScalePercent(bj_lastCreatedUnit,50.,50.,50.)\n",
    "call CreateNUnitsAtLoc(1,'h09P',GetOwningPlayer(NaV_s8[5140]),NaV_r8[5142],NaV_O8[5140])\n"
    "call UnitApplyTimedLifeBJ(1.8,'BTLF',bj_lastCreatedUnit)\n"
    "call SetUnitScalePercent(bj_lastCreatedUnit,50.,50.,50.)\n")

# --- atributos del modo Kyuubi (H0D9: fuerza 30 +3,4; agilidad 14 +2,7; inteligencia 19 +1,9) ---
una("""function Na_Stat takes integer k returns integer
    if k == 0 then
""", """function Na_Stat takes integer k returns integer
    // v16y: en modo Kyuubi, atributos de la fila H0D9 de D.O.N
    if GetUnitTypeId(NaV_s8[5790]) == 'hNaK' then
        if k == 0 then
            return R2I(30. + 3.4 * I2R(Gk_Nivel - 1))
        elseif k == 1 then
            return R2I(14. + 2.7 * I2R(Gk_Nivel - 1))
        endif
    endif
    if k == 0 then
""")

# --- relevo: guardas y avisos ---
EN_CURSO = """// v16y: motor de D.O.N encendido por cada habilidad real; su estado es de una sola instancia, así que no se relanza
// mientras sigue en curso. Destructo Disc (A0IY) lleva lista propia y admite varios.
function Don_EnCurso takes integer a returns boolean
    if a == 'A0IX' then
        return IsTriggerEnabled(FzV_at)
    elseif a == 'A0IW' then
        return IsTriggerEnabled(FzV_bt)
    elseif a == 'A0IV' then
        return IsTriggerEnabled(FzV_Dt)
    elseif a == 'A0J1' then
        return IsTriggerEnabled(FzV_Uy) or IsTriggerEnabled(FzV_Vy)
    elseif a == 'A0GV' then
        return IsTriggerEnabled(TrV_Mu)
    elseif a == 'A05B' then
        return IsTriggerEnabled(TrV_BB)
    elseif a == 'A0HW' then
        return IsTriggerEnabled(NaV_zu)
    elseif a == 'A0F5' then
        return IsTriggerEnabled(NaV_Vv) or IsTriggerEnabled(NaV_Wv) or IsTriggerEnabled(NaV_Xv)
    elseif a == 'A0AI' then
        return IsTriggerEnabled(NaV_cy)
    elseif a == 'A0F3' then
        return IsTriggerEnabled(NaV_kB) or IsTriggerEnabled(NaV_mB)
    endif
    return false
endfunction

function Don_Relevo takes nothing returns nothing
"""
una("function Don_Relevo takes nothing returns nothing\n", EN_CURSO)
una("""    local unit b
    loop
        exitwhen n >= Don_Bots or Don_BotId[n] == a
""", """    local unit b
    local boolean ok = true
    loop
        exitwhen n >= Don_Bots or Don_BotId[n] == a
""")
una(b"""        if Don_BotReal[n] == 'A0HW' and GetUnitTypeId(b) != 'hNaK' then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 3., "Kyuubi Chakra Blast: s\xf3lo en modo Kyuubi.")
        elseif UnitAlive(b) and not IsUnitPaused(b) then
""", """        if Don_BotReal[n] == 'A0HW' and GetUnitTypeId(b) != 'hNaK' then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 3., "Kyuubi Chakra Blast: sólo en modo Kyuubi.")
        elseif (Don_BotReal[n] == 'A00T' or Don_BotReal[n] == 'A0AI') and GetUnitTypeId(b) == 'hNaK' then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 3., "En modo Kyuubi Naruto no tiene esa técnica.")
        elseif Don_EnCurso(Don_BotReal[n]) then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Todavía en curso: espera a que termine.")
        elseif UnitAlive(b) and IsUnitPaused(b) then
            call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 2., "Ahora no: otra habilidad está en curso.")
        elseif UnitAlive(b) then
""".encode('utf-8'))
una("""            if Don_BotObj[n] == 0 then
                call IssueImmediateOrder(b, Don_BotOrden[n])
            elseif Don_BotObj[n] == 1 then
                call IssueTargetOrder(b, Don_BotOrden[n], t)
            else
                call IssuePointOrder(b, Don_BotOrden[n], x, y)
            endif
""", """            if Don_BotObj[n] == 0 then
                set ok = IssueImmediateOrder(b, Don_BotOrden[n])
            elseif Don_BotObj[n] == 1 then
                set ok = IssueTargetOrder(b, Don_BotOrden[n], t)
            else
                set ok = IssuePointOrder(b, Don_BotOrden[n], x, y)
            endif
            if not ok then
                call DisplayTimedTextToPlayer(GetTriggerPlayer(), 0., 0., 4., "El cuerpo no aceptó la orden " + Don_BotOrden[n] + ".")
            endif
""")
assert b"Blast: s\xf3lo" not in j
out.mkdir(parents=True, exist_ok=True)
(out / 'war3map.j').write_bytes(j)

# --- w3a: alev 1 ---
raw = Path(a_in).read_bytes()
v, t = parse_w3a(raw)
assert encode_w3a(v, t) == raw
hechos = set()
for k, (base, new, mods) in enumerate(t[1]):
    if new in (b'A0IY', b'A0IZ', b'A0H5', b'A0I5'):
        nm = []
        for m in mods:
            if m[0] == b'alev':
                assert struct.unpack('<i', m[4])[0] == 4, (new, m)
                m = (m[0], m[1], m[2], m[3], struct.pack('<i', 1), m[5])
                hechos.add(new)
            nm.append(m)
        t[1][k] = (base, new, nm)
assert len(hechos) == 4, hechos
(out / 'war3map.w3a').write_bytes(encode_w3a(v, t))

# --- w3u: velocidad 350 en las dos formas de Naruto ---
raw = Path(u_in).read_bytes()
v, t = parse(raw)
assert encode(v, t) == raw
hechos = set()
for k, (base, new, mods) in enumerate(t[1]):
    if new in (b'hNar', b'hNaK'):
        nm = []
        for m in mods:
            if m[0] == b'umvs':
                assert struct.unpack('<i', m[2])[0] == 300, (new, m)
                m = (m[0], m[1], struct.pack('<i', 350), m[3])
                hechos.add(new)
            nm.append(m)
        t[1][k] = (base, new, nm)
assert len(hechos) == 2, hechos
(out / 'war3map.w3u').write_bytes(encode(v, t))
print('v16y: niveles, h09P, relevo, Kyuubi')
