#!/usr/bin/env python3
"""v18k (15/11/2026): saca a WAV los sonidos originales del cuadro "Round Score" de Dark Moon.

Dark Moon (workshop 570/2837608304), panorama/scripts/custom_game/holdout_scoreboard.vjs_c, y los eventos de
soundevents/game_sounds_winter_2018.vsndevts_c (KV3 con LZ4, leído con kv3):
- al abrir el cuadro: "RoundSuccess" = sounds/round_fanfare.vsnd (volumen 0,9);
- bolsas recogidas: "GoldRising" en bucle mientras cuentan = sounds/tally_rise_gold.vsnd (0,3), al terminar
  "GoldRisingEnd" = sounds/tally_end_gold.vsnd (0,4);
- bolsas perdidas: "Item.DropWorld" por cada una = sounds/ui/item_drop_world.vsnd (Dota 2, game_sounds_ui_imported);
- muertes del equipo (y torres): "TowerCountUp" por cada una = sounds/tally_end.vsnd;
- estrellas: "StarLevel" por cada una = sounds/bigtreant_step_01/02.vsnd (0,8).
Formato del bloque DATA del .vsnd_c: el antiguo 0x2b111941 (PCM 16 bits 44,1 kHz estéreo, como v18b) o el nuevo,
con la frecuencia en los 16 bits bajos, el códec en el byte 2 (0 PCM 16 bits, 2 MP3) y los canales en el byte 3.
PCM: las muestras tal cual en RIFF. MP3 (sólo la fanfarria): ffmpeg a PCM 16 bits, misma frecuencia y canales,
recortado a las muestras que declara el recurso. Sin normalizar ni remuestrear.
Uso: sonido_v18k.py ENTRADA.vsnd_c SALIDA.wav
"""
import struct, subprocess, sys, tempfile, wave
from pathlib import Path

d = open(sys.argv[1], 'rb').read()
_, _, _, bo, bc = struct.unpack('<IHHII', d[:16])
p, fin = 8 + bo, 0
for _ in range(bc):
    cc = d[p:p + 4]; off, sz = struct.unpack('<II', d[p + 4:p + 12])
    if cc == b'DATA':
        ds = p + 4 + off
    fin = max(fin, p + 4 + off + sz); p += 12
fmt, _, n, dur = struct.unpack('<IIIf', d[ds:ds + 16])
a = d[fin:]
if fmt == 0x2b111941:
    rate, codec, ch = 44100, 0, 2
else:
    rate, codec, ch = fmt & 0xffff, (fmt >> 16) & 0xff, (fmt >> 24) & 0xff
assert rate in (22050, 44100) and ch in (1, 2) and codec in (0, 2), hex(fmt)
assert abs(n / rate - dur) < 2e-3, (n, rate, dur)
if codec == 0:
    assert len(a) == n * 2 * ch, (len(a), n, ch)
else:
    assert a[:2] in (b'\xff\xfb', b'\xff\xfa', b'\xff\xf3'), a[:4].hex()
    with tempfile.TemporaryDirectory() as t:
        mp3 = Path(t) / 'a.mp3'; mp3.write_bytes(a)
        r = subprocess.run(['ffmpeg', '-v', 'error', '-i', str(mp3), '-f', 's16le', '-acodec', 'pcm_s16le', '-ar',
                            str(rate), '-ac', str(ch), '-'], capture_output=True, check=True)
    a = r.stdout
    assert len(a) >= n * 2 * ch * 0.99, (len(a), n)
    a = a[:n * 2 * ch]
    n = len(a) // (2 * ch)
with wave.open(sys.argv[2], 'wb') as w:
    w.setnchannels(ch); w.setsampwidth(2); w.setframerate(rate); w.writeframes(a)
print(f'{Path(sys.argv[1]).name}: {"PCM" if codec == 0 else "MP3"} {rate} Hz {ch} can., {n} muestras, {n / rate:.3f} s')
