#!/usr/bin/env python3
"""v20d (20/11/2026): modelos del cuadro MVP / menos puntos corregidos tras la prueba de v20c (vídeo de Leon).
- Salían negros: la noche fija (Dark Nights, luz 0,05) sólo deja ver las unidades cerca de la luz del héroe, y los
  modelos están junto a la cámara. Ahora cada modelo lleva su luz (MvpLuz.mdx, alcance 500, no llega al suelo),
  creada sólo en el cliente que lo ve (ruta vacía en los demás): como mucho 2 luces más durante el cuadro.
- Eran demasiado grandes y se salían del cuadro por la derecha y por abajo: escala 0,40 → 0,22, x 1345 → 1330,
  pies a y 290 (MVP) y 522 (menos puntos) en vez de 352 y 585.
Uso: v20d.py ENTRADA.j SALIDA.j [prueba]   (normal de v20c; prueba de v20c-prueba)
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


cambia('constant real MVP_MOD_ESCALA = 0.40\nconstant real MVP_MOD_X = 1345.\n',
       'constant real MVP_MOD_ESCALA = 0.22\nconstant real MVP_MOD_X = 1330.\n'
       '// v20d: luz de cada modelo, sólo en el cliente que lo ve.\neffect array Mvp_Luz\n')
cambia('''        if Mvp_Mod[i] != null then
            call RemoveUnit(Mvp_Mod[i])''', '''        if Mvp_Luz[i] != null then
            call DestroyEffect(Mvp_Luz[i])
            set Mvp_Luz[i] = null
        endif
        if Mvp_Mod[i] != null then
            call RemoveUnit(Mvp_Mod[i])''')
cambia('''                set Mvp_Mod[p * 2] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Gana]])
                if Mvp_Pierde >= 0 then
                    set Mvp_Mod[p * 2 + 1] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Pierde]])
                endif''', '''                set Mvp_Mod[p * 2] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Gana]])
                if Mvp_Pierde >= 0 then
                    set Mvp_Mod[p * 2 + 1] = Mvp_Modelo(p, Game_Hero[Mvp_Fila[Mvp_Pierde]])
                endif
                // v20d: la luz sólo existe en el cliente de p (en los demás el efecto no tiene modelo).
                set luz = ""
                if GetLocalPlayer() == Player(p) then
                    set luz = "war3mapImported\\\\MvpLuz.mdx"
                endif
                if Mvp_Mod[p * 2] != null then
                    set Mvp_Luz[p * 2] = AddSpecialEffectTarget(luz, Mvp_Mod[p * 2], "origin")
                endif
                if Mvp_Mod[p * 2 + 1] != null then
                    set Mvp_Luz[p * 2 + 1] = AddSpecialEffectTarget(luz, Mvp_Mod[p * 2 + 1], "origin")
                endif''')
cambia('''function Mvp_ModTick takes nothing returns nothing
    local integer p = 0
''', '''function Mvp_ModTick takes nothing returns nothing
    local integer p = 0
    local string luz
''')
cambia('MVP_MOD_X, 352.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 290.0 + dy, MVP_MOD_RANGO')
cambia('MVP_MOD_X, 585.0 + dy, MVP_MOD_RANGO', 'MVP_MOD_X, 522.0 + dy, MVP_MOD_RANGO')
if prueba:
    for viejo, nuevo in (('lat\\\\v20c-', 'lat\\\\v20d-'), ('v20c-don.txt', 'v20d-don.txt')):
        assert viejo in src, viejo
        src = src.replace(viejo, nuevo)
if crlf:
    src = src.replace('\n', '\r\n')
Path(sys.argv[2]).write_bytes(src.encode('latin-1'))
print('v20d', 'prueba' if prueba else 'normal')
