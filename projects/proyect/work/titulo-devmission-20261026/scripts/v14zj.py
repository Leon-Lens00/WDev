#!/usr/bin/env python3
"""v14zj (07/11/2026): fase 1 de docs/planes/devmission-armas-rachas-v14zj.md. Parte del j de v14zi.

- Sin pistolas: el jugador empieza con el subfusil T1 (categoría 1) y el cuchillo T1. La categoría 0 queda oculta en
  la tienda hasta el misil de calor (fase 5), que ocupará la última fila; las demás suben una fila (Shop_CatFila).
- Daño y precios de la tabla aprobada: el mismo daño sostenido por tier (100 / 150 / 220 / 300 / 400 / 520 por
  segundo; escopeta ×1,1, granadas ×0,8) y el mismo precio por tier (250 / 600 / 1200 / 2200 / 3600 / 5500).
  Francotirador a 1 disparo por segundo; cuchillo a 4 + 2 (t − 1) golpes por 1,5 s.
- Menos precisión: subfusil 8° → 12°, rifle 3° → 6° (más su retroceso).
- Requisito de ronda (Arm_Req) para el tier siguiente de cualquier arma: T2 tras la ronda 1, T3 tras la 2, T4 tras la
  4, T5 tras la 6 y T6 tras la 8.
- La batería se recarga con G (objetos_v14zj.py): el texto del HUD lo dice.

Uso: v14zj.py ENTRADA.j SALIDA.j
"""
from pathlib import Path
import re
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once


def u8(t):
    return t.encode('utf-8').decode('latin-1')


ent, sal = sys.argv[1:3]
s = Path(ent).read_text(encoding='latin-1', newline='')

# Tabla de daño (por golpe o perdigón) y precios por tier; categorías 1..6.
DANO = {1: [19, 25, 28, 33, 38, 43], 2: [21, 26, 31, 38, 45, 49], 3: [150, 197, 215, 293, 359, 443],
        4: [12, 14, 17, 18, 21, 20], 5: [38, 38, 41, 45, 50, 56], 6: [28, 42, 51, 69, 79, 103]}
PRECIO = [250, 600, 1200, 2200, 3600, 5500]
i = s.index('function Arm_Datos takes nothing returns nothing')
e = s.index('endfunction', i)
b = s[i:e]


def poner(b, campo, w, valor):
    pat = re.compile(r'(    set %s\[%d\] = )[^\r\n]*' % (campo, w))
    b, n = pat.subn(lambda m: m.group(1) + valor, b)
    assert n == 1, (campo, w, n)
    return b


for c, fila in DANO.items():
    for t in range(6):
        w = c * 6 + t
        b = poner(b, 'Arm_Dano', w, '%d.' % fila[t])
        b = poner(b, 'Arm_Precio', w, '0' if t == 0 and c in (1, 5) else str(PRECIO[t]))
        if c == 3:
            b = poner(b, 'Arm_Int', w, '1.0')
        elif c == 5:
            b = poner(b, 'Arm_Int', w, '%.4f' % (1.5 / (4 + 2 * t)))
        elif c == 1:
            b = poner(b, 'Arm_Disp', w, '12.')
        elif c == 2:
            b = poner(b, 'Arm_Disp', w, '6.')
s = s[:i] + b + s[e:]

# Arma inicial: subfusil T1 (categoría 1) en lugar de la pistola.
s = once(s, '''        if Arm_Tier[p * 7] == 0 then
            set Arm_Tier[p * 7]=1
            set Arm_Clip[p * 7]=Arm_Mag[0]
            set Arm_Rva[p * 7]=Arm_Res[0]
            set Arm_Tier[p * 7 + 5]=1
        endif
''', '''        if Arm_Tier[p * 7 + 1] == 0 then
            set Arm_Tier[p * 7 + 1]=1
            set Arm_Clip[p * 7 + 1]=Arm_Mag[6]
            set Arm_Rva[p * 7 + 1]=Arm_Res[6]
            set Arm_Tier[p * 7 + 5]=1
            set Arm_Cat[p]=1
        endif
''')

# Filas de categorías: 0 oculta (-1) hasta el misil; las demás una fila más arriba.
s = once(s, 'function Shop_Textos takes nothing returns nothing\n', u8('''// v14zj: fila de cada categoría en la tienda; la 0 (antes pistolas) queda oculta hasta el misil de calor.
function Shop_CatFila takes integer k returns integer
    if k == 0 then
        return - 1
    endif
    return k - 1
endfunction

function Shop_Textos takes nothing returns nothing
'''))
s = once(s, '''        set Shop_CatT[i] = Shop_Tag(187, 146 + 66 * i, 0.022, 0, Cat_Nombre[i])
''', '''        if Shop_CatFila(i) >= 0 then
            set Shop_CatT[i] = Shop_Tag(187, 146 + 66 * Shop_CatFila(i), 0.022, 0, Cat_Nombre[i])
        endif
''')
s = once(s, '''        call Shop_Pic(307, 161 + 66 * i, 340, 62, 399, 'DS06')
        set Shop_CatOn[i] = Shop_Pic(307, 161 + 66 * i, 340, 62, 398.5, 'DS05')
        call Shop_Pic(166.5, 161 + 66 * i, 15, 26, 370, 'DS0C')
        set Shop_ArmaPic[i] = Shop_Pic(755, 594, 300, 150, 398, Cat_Tex[i])
''', '''        if Shop_CatFila(i) >= 0 then
            call Shop_Pic(307, 161 + 66 * Shop_CatFila(i), 340, 62, 399, 'DS06')
            set Shop_CatOn[i] = Shop_Pic(307, 161 + 66 * Shop_CatFila(i), 340, 62, 398.5, 'DS05')
            call Shop_Pic(166.5, 161 + 66 * Shop_CatFila(i), 15, 26, 370, 'DS0C')
            set Shop_ArmaPic[i] = Shop_Pic(755, 594, 300, 150, 398, Cat_Tex[i])
        endif
''')
s = once(s, '''                call Shop_Pista(p, "war3mapImported\\\\ShopHitCat.mdx", 307, 161 + 66 * i, i)
''', '''                if Shop_CatFila(i) >= 0 then
                    call Shop_Pista(p, "war3mapImported\\\\ShopHitCat.mdx", 307, 161 + 66 * Shop_CatFila(i), i)
                endif
''')

# La fila oculta no tiene texttag: no pintar un texttag nulo (podría caer en el id 0).
s = once(s, '''        if k == c then
            call Shop_Elegida(p, Shop_CatT[k])
        else
            call Shop_Pinta(p, Shop_CatT[k], 170)
''', '''        if Shop_CatT[k] == null then
        elseif k == c then
            call Shop_Elegida(p, Shop_CatT[k])
        else
            call Shop_Pinta(p, Shop_CatT[k], 170)
''')

# Requisito de ronda del tier t.
s = once(s, 'function Shop_FilaN takes integer k returns integer\n', u8('''// v14zj: rondas terminadas (en el descanso, la que acaba de terminar) y ronda que pide el tier t.
function Ronda_Pasadas takes nothing returns integer
    if Ronda_Descanso then
        return Ronda_Numero
    endif
    return Ronda_Numero - 1
endfunction

function Arm_Req takes integer t returns integer
    if t <= 1 then
        return 0
    elseif t <= 3 then
        return t - 1
    endif
    return 2 * (t - 2)
endfunction

function Shop_FilaN takes integer k returns integer
'''))
s = once(s, '''        elseif k == have then
            set s = I2S(Arm_Precio[x]) + " oro"
            set g = 225
''', '''        elseif k == have and Ronda_Pasadas() < Arm_Req(k + 1) then
            set s = "Tras la ronda " + I2S(Arm_Req(k + 1))
            set g = 130
        elseif k == have then
            set s = I2S(Arm_Precio[x]) + " oro"
            set g = 225
''')
s = once(s, '''    elseif t == have + 1 then
        set s = "Comprar: " + I2S(Arm_Precio[w]) + " oro"
''', u8('''    elseif t == have + 1 and Ronda_Pasadas() < Arm_Req(t) then
        set s = "Disponible tras la ronda " + I2S(Arm_Req(t))
    elseif t == have + 1 then
        set s = "Comprar: " + I2S(Arm_Precio[w]) + " oro"
'''))
s = once(s, '    call Shop_Luz(p, Shop_BuyOn, t == have + 1)\n',
         '    call Shop_Luz(p, Shop_BuyOn, t == have + 1 and Ronda_Pasadas() >= Arm_Req(t))\n')
s = once(s, '''    if t != Arm_Tier[i] + 1 or oro < Arm_Precio[w] then
        call UI_Error(p)
''', '''    if t != Arm_Tier[i] + 1 or oro < Arm_Precio[w] or Ronda_Pasadas() < Arm_Req(t) then
        call UI_Error(p)
''')
s = once(s, u8('"Batería " + I2S(pct) + "%   Recargas (V): "'), u8('"Batería " + I2S(pct) + "%   Recargas (G): "'))
Path(sal).write_text(s, encoding='latin-1', newline='')
