#!/usr/bin/env python3
"""Sólo prueba (14/11/2026): coste de dibujo de la bala Toy y de sus versiones ligeras (bala_ligera.py).
Leon: "la bala del toy? evalua su composicion o lo puedes hacer mas ligero aun".
Sobre el j de camara_v16t.py y el mismo marco que dibujo_v16t.py: 120 enemigos que no mueren, 8 MP5 de antes, cámara en
el héroe. Modos de 10 s × 2 vueltas: 0 nadie; 1 Shot (la de ahora); 2 Toy Bullet2; 3 ligera1 (sin partículas);
4 ligera2 (sin partículas, un cuadrado); 5 sin modelo. Registros lat\\lig-N.txt.
Uso: ligera_v16t.py ENTRADA.j SALIDA.j   (ENTRADA = salida de camara_v16t.py)
"""
from pathlib import Path
import runpy, sys, tempfile, os

sys.path.insert(0, str(Path(__file__).resolve().parent))
from puente_v12 import once

ent, sal = sys.argv[1], sys.argv[2]
tmp = sal + '.dib'
sys.argv = ['dibujo_v16t.py', ent, tmp, 'lig']
runpy.run_path(str(Path(__file__).resolve().parent / 'dibujo_v16t.py'), run_name='__main__')
s = Path(tmp).read_text(encoding='latin-1', newline='')
os.remove(tmp)
N = '\r\n'


def funcion(s, nombre, nuevo):
    i = s.index('function ' + nombre + ' takes')
    j = s.index('endfunction\r\n', i) + len('endfunction\r\n')
    return s[:i] + nuevo.replace('\n', N) + s[j:]


s = once(s, 'boolean Est_SinModelo= false\n', 'boolean Est_SinModelo= false\nstring Est_Arte= ""\n')
s = once(s, '''        if Est_SinModelo then
        elseif Arm_BalaModelo != "" then
''', '''        if Est_SinModelo then
        elseif Est_Arte != "" then
            call s__Missile__set_model(m,Est_Arte)
        elseif Arm_BalaModelo != "" then
''')
s = funcion(s, 'Est_Modo_Poner', '''function Est_Modo_Poner takes integer m returns nothing
    local integer p = 0
    loop
        exitwhen p > 7
        if Game_Pair[p] != 0 then
            call s__RapidPair_finish(Game_Pair[p], true)
        endif
        set p = p + 1
    endloop
    set Est_Modo = m
    set Est_Cat = 1
    set Est_Tir = 8
    if m == 0 then
        set Est_Tir = 0
    endif
    set Est_CamLejos = false
    set Est_SinModelo = m == 5
    set Est_Arte = ""
    if m == 2 then
        set Est_Arte = "war3mapImported\\\\BalaToy.mdx"
    elseif m == 3 then
        set Est_Arte = "war3mapImported\\\\BalaLigera1.mdx"
    elseif m == 4 then
        set Est_Arte = "war3mapImported\\\\BalaLigera2.mdx"
    endif
endfunction
''')
s = once(s, '    elseif Est_Modo < 6 then\n', '    elseif Est_Modo < 5 then\n')
Path(sal).write_text(s, encoding='latin-1', newline='')
print('ligera v16t: 6 modos x 2 vueltas (nadie, Shot, Toy, ligera1, ligera2, sin modelo)')
