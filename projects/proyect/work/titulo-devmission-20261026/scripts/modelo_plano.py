#!/usr/bin/env python3
"""TitleDummyFlat.mdl para las piezas de la tienda (v14e): TitleDummyBlend sin Billboarded, con el cuadro tendido
mirando a +Z.

El billboard orienta el cuadro según la posición absoluta y, lejos de X 0 (|X| > ~600), lo pone de canto bajo la
cámara cenital: la tienda en X 2400 salía sin dibujo. Con facing 270 el cuadro plano queda igual que antes; las claves
de escala de bone_chest {1, ancho, alto} pasan a {ancho, alto, 1}.

Uso: modelo_plano.py TitleDummyBlend.mdl SALIDA.mdl
"""
import re, sys

s = open(sys.argv[1], encoding='latin-1', newline='').read()
nl = '\r\n' if '\r\n' in s else '\n'


def once(a, b):
    global s
    a = a.replace('\n', nl); b = b.replace('\n', nl)
    assert s.count(a) == 1, a
    s = s.replace(a, b)


once('\tBillboarded,\n', '')
once('''		{ 0, -1, 1 },
		{ 0, -1, -1 },
		{ 0, 1, -1 },
		{ 0, 1, 1 },''', '''		{ 1, -1, 0 },
		{ 1, 1, 0 },
		{ -1, 1, 0 },
		{ -1, -1, 0 },''')
assert s.count('{ 1, 0, 0 },') == 4
s = s.replace('{ 1, 0, 0 },', '{ 0, 0, 1 },')
s = s.replace('MinimumExtent { 0, -1, -1 }', 'MinimumExtent { -1, -1, 0 }').replace('MaximumExtent { 0, 1, 1 }', 'MaximumExtent { 1, 1, 0 }')
i = s.index('Helper "bone_chest"'); j = s.index('Attachment "Origin Ref "')
s = s[:i] + re.sub(r'\{ ([\d.]+), ([\d.]+), ([\d.]+) \}', r'{ \2, \3, \1 }', s[i:j]) + s[j:]
open(sys.argv[2], 'w', encoding='latin-1', newline='').write(s)
