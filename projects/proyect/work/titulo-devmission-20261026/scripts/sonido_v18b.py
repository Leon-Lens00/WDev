#!/usr/bin/env python3
"""v18b (15/11/2026): saca a WAV, sin tocar las muestras, el sonido de la tirada de Dark Moon.

Dark Moon (workshop 2837608304) toca "BoostCreeps.Random" en cada cambio de la tirada; ese evento usa
sounds/ui/panorama/panorama_custom_lobby_drawer_slide_in_01.vsnd_c de Dota 2 (pak01 de la instalación local).
El .vsnd_c es un recurso con bloques REDI y DATA; DATA (40 bytes) da formato 0x2b111941 (PCM 16 bits), muestras y
duración, y el audio sigue tal cual tras el último bloque. Se envuelve en RIFF: 44,1 kHz, 2 canales, mismas muestras.
Uso: sonido_v18b.py ENTRADA.vsnd_c SALIDA.wav
"""
import struct, sys, wave

d = open(sys.argv[1], 'rb').read()
_, _, _, bo, bc = struct.unpack('<IHHII', d[:16])
p, fin = 8 + bo, 0
for _ in range(bc):
    cc = d[p:p + 4]; off, sz = struct.unpack('<II', d[p + 4:p + 12])
    if cc == b'DATA':
        ds = p + 4 + off
    fin = max(fin, p + 4 + off + sz); p += 12
fmt, _, n, dur = struct.unpack('<IIIf', d[ds:ds + 16])
assert fmt == 0x2b111941 and (fmt >> 14) & 0xffff == 44100, hex(fmt)
a = d[fin:]
assert len(a) == n * 4 and abs(n / 44100 - dur) < 1e-3, (len(a), n, dur)
with wave.open(sys.argv[2], 'wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(44100); w.writeframes(a)
print(f'{n} muestras, {dur:.3f} s, 44100 Hz estéreo')
