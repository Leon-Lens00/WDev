#!/usr/bin/env python3
"""Sala de espera de v17p (14/11/2026): nombre, dos equipos fijos y raza Humano.

Leon: "configurar el estado del mapa con los jugadores ... un jugador podria ponerse equipo 8 o saltarse ciertos slots
... ya necesitamos poner nombre al mapa"; nombre "Proyect Dev Us"; "dividelo en dos equipos, dev us y dev mission,
dentro del juego ya los ariamos aliados ... en partida en linea el juego te obliga a que deben ser minimo dos fuerzas";
raza "Humano".
- w3i (versión 25): banderas + 0x40 (fuerzas propias) + 0x20 (ajustes fijos: no se cambia equipo ni raza en la sala);
  jugadores 0-7 raza 1 (humano); fuerzas "Dev Us" (jugadores 1-4, máscara 0x0F) y "Dev Mission" (5-8, 0xF0), las dos
  aliadas y con victoria aliada (banderas 3). Lo demás del w3i se copia igual.
- wts: STRING 1 (nombre) "Proyect Dev Us", STRING 2 (jugadores propuestos) "1-8 cooperativo", STRING 7 (fuerza 1)
  "Dev Us" y una cadena nueva (la siguiente libre) "Dev Mission" para la fuerza 2.
Uso: w3i_v17p.py IN_W3I IN_WTS OUT_W3I OUT_WTS  (imprime el id de la cadena nueva)
"""
from pathlib import Path
import re, struct, sys

src = Path(sys.argv[1]).read_bytes()


class R:
    def __init__(s, b): s.b, s.o = b, 0
    def i(s): v = struct.unpack_from('<i', s.b, s.o)[0]; s.o += 4; return v
    def f(s): v = struct.unpack_from('<f', s.b, s.o)[0]; s.o += 4; return v
    def c(s, n=1): v = s.b[s.o:s.o + n]; s.o += n; return v
    def z(s): e = s.b.index(b'\0', s.o); v = s.b[s.o:e]; s.o = e + 1; return v


r = R(src)
assert r.i() == 25
r.o = 12
for _ in range(4): r.z()
r.o += 8 * 4 + 4 * 4 + 4 + 4
flags_at = r.o
r.o += 4 + 1
r.i(); r.z(); r.z(); r.z(); r.z()
r.i(); r.z(); r.z(); r.z(); r.z()
r.i(); r.o += 4 * 3 + 4; r.i(); r.z(); r.c(1); r.c(4)
head_end = r.o
players = []
for _ in range(r.i()):
    pid, typ, race, fixed = r.i(), r.i(), r.i(), r.i()
    name = r.z(); x, y = r.f(), r.f(); lo, hi = r.i(), r.i()
    players.append([pid, typ, race, fixed, name, x, y, lo, hi])
forces = [(r.i(), r.i(), r.z()) for _ in range(r.i())]
tail = src[r.o:]


def encode(players, forces, head):
    b = bytearray(head) + struct.pack('<i', len(players))
    for pid, typ, race, fixed, name, x, y, lo, hi in players:
        b += struct.pack('<iiii', pid, typ, race, fixed) + name + b'\0' + struct.pack('<ffii', x, y, lo, hi)
    b += struct.pack('<i', len(forces))
    for fl, mask, name in forces:
        b += struct.pack('<ii', fl, mask) + name + b'\0'
    return bytes(b + tail)


assert encode(players, forces, src[:head_end]) == src, 'no re-codifica igual'
assert [p[0] for p in players] == list(range(8)) and all(p[1] == 1 for p in players)
assert forces == [(0, -1, b'TRIGSTR_007')], forces

wts = Path(sys.argv[2]).read_bytes().decode('utf-8-sig')
ids = [int(m) for m in re.findall(r'^STRING (\d+)\r?$', wts, re.M)]
nuevo = max(ids) + 1


def cadena(n, texto):
    global wts
    pat = re.compile(r'(^STRING %d\r\n(?://[^\r\n]*\r\n)?\{\r\n)(.*?)(\r\n\})' % n, re.M | re.S)
    assert len(pat.findall(wts)) == 1, n
    wts = pat.sub(lambda m: m.group(1) + texto + m.group(3), wts)


cadena(1, 'Proyect Dev Us')
cadena(2, '1-8 cooperativo')
cadena(7, 'Dev Us')
wts = wts.rstrip('\r\n') + '\r\n\r\nSTRING %d\r\n{\r\nDev Mission\r\n}\r\n' % nuevo

head = bytearray(src[:head_end])
fl = struct.unpack_from('<i', head, flags_at)[0]
struct.pack_into('<i', head, flags_at, fl | 0x40 | 0x20)
for p in players:
    p[2] = 1
forces = [(3, 0x0F, b'TRIGSTR_007'), (3, 0xF0, b'TRIGSTR_%03d' % nuevo)]
Path(sys.argv[3]).write_bytes(encode(players, forces, head))
Path(sys.argv[4]).write_bytes(b'\xef\xbb\xbf' + wts.encode('utf-8'))
print('%03d' % nuevo)
