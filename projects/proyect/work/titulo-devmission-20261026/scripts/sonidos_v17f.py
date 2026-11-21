#!/usr/bin/env python3
"""v17f (14/11/2026): tomas de arma completas, hasta que su sonido cae a -30 dB (máx. 1 s), con fundido final.

Leon (14/11/2026), tras v17e: "si reducir los audio originales, suenan raro sino, puedes crear el audio cada momento
que sale el proyectil". Subfusil, fusil y granada vuelven a la toma natural (medida con la envolvente de 5 ms + 50 ms);
el resto sigue como v17e (SonCambio sin silencio). El ritmo lo da el mapa (v17f.py), no el recorte.

v17e (14/11/2026): sonidos de v17d con disparos cortos a la medida del intervalo y el cambio de arma sin silencio.

Leon (14/11/2026), tras v17d: "el sonido de las armas, estan en loop? o la podemos como sonido individual al momento de
salir cada bala, ya que no iba de acuerdo al rps" y "verificar el sonido del cambio de arma no tenga un silencio al inicio".
Ya era un sonido por bala; cada toma duraba 0,5 s y el subfusil y el fusil disparan cada 0,09–0,17 s, así que se
encimaban 3–5. Ahora subfusil y fusil duran 2 intervalos del tier (Arm_Int de v17d) con fundido desde el 40 %, la granada
0,3 s. armasligeras empezaba con 290 ms de silencio: se recorta desde 0,27 s.

v17d: sonidos de armas, impactos, explosión, cajas, tienda y truenos desde AudioClip de Leon.

Formato de los sonidos 3D de combate de Blizzard (RiflemanAttack1, MortarImpact, LightningBolt en los MPQ de 1.27b):
PCM 16 bits, 22050 Hz, mono. Todo sale así: recorte, fundido de salida, compresión suave y pico a -1 dB.
Elección de Leon tras la muestra 4: arma por tier (sonidos_muestra4.py), ammobox en las cajas verdes, equipamiento al
comprar o mejorar un tier, armasligeras al cambiar de arma; truenos de AudioClip en lugar de StormT1-3 (8 bits).
Uso: sonidos_v17d.py AUDIOCLIP SALIDA  →  SALIDA/war3mapImported/Son*.wav y SALIDA/lista.tsv (nombre interno, archivo).
"""
from pathlib import Path
import array, subprocess, sys, wave

src, sal = Path(sys.argv[1]), Path(sys.argv[2])
d = sal / 'war3mapImported'; d.mkdir(parents=True, exist_ok=True)
COMP = 'acompressor=threshold=-20dB:ratio=3:attack=3:release=120:makeup=3'
TRUENO = 'acompressor=threshold=-26dB:ratio=5:attack=5:release=400:makeup=6'
lista = []


def hacer(nombre, archivo, ini=0., dur=None, filtro=COMP, mezcla=None, fin=0.75):
    """mezcla = (archivo, desfase s, ganancia): bombeo de la escopeta."""
    o = d / nombre
    cmd = ['ffmpeg', '-v', 'error', '-y', '-ss', str(ini)] + (['-t', str(dur)] if dur else []) + ['-i', str(src / archivo)]
    af = []
    if mezcla:
        cmd += ['-i', str(src / mezcla[0])]
        af.append(f'[1:a]adelay={int(mezcla[1] * 1000)}:all=1,volume={mezcla[2]}[b];[0:a][b]amix=inputs=2:duration=longest:normalize=0')
        if dur:
            af[-1] += f',atrim=0:{dur}'
    fx = []
    if dur:
        fx.append(f'afade=t=out:st={dur * fin:.3f}:d={dur * (1 - fin):.3f}')
    fx += [filtro, 'aresample=22050', 'aformat=sample_fmts=s16:channel_layouts=mono']
    if af:
        cmd += ['-filter_complex', af[0] + ',' + ','.join(fx)]
    else:
        cmd += ['-af', ','.join(fx)]
    cmd += ['-map_metadata', '-1', '-fflags', '+bitexact', '-flags:a', '+bitexact', '-c:a', 'pcm_s16le', str(o)]
    subprocess.run(cmd, check=True)
    with wave.open(str(o)) as w:
        a = array.array('h'); a.frombytes(w.readframes(w.getnframes()))
    k = 0.89 * 32767 / max(1, max(abs(x) for x in a))
    with wave.open(str(o), 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(22050)
        w.writeframes(array.array('h', (max(-32768, min(32767, round(x * k))) for x in a)).tobytes())
    lista.append(('war3mapImported\\' + nombre, str(o), len(a) / 22050))


# armas (índice w = categoría × 6 + tier − 1, como Arm_Nombre); el francotirador y los misiles comparten cada 2 tiers
for t, f in enumerate(('Mac', 'MP40', 'Thompson', 'UMP9', 'MP5N', 'P90'), 1):
    hacer(f'SonSub{t}.wav', f + '.wav', dur=(0.46, 0.36, 0.37, 0.33, 0.52, 0.64)[t - 1])
for t, f in enumerate(('MP44_AKM', 'FAMAS', 'M4A1', 'G11', 'SCAR', 'Bren'), 1):
    hacer(f'SonFus{t}.wav', f + '.wav', dur=(1.0, 0.40, 1.0, 0.67, 0.78, 0.94)[t - 1])
for t, (f, b, en) in enumerate((('Boomstick', None, 0), ('Remington', 'RemingtonPump', 0.30), ('Benelli', 'BenelliCocking', 0.22),
                                ('SPAS', 'SpasPump', 0.25), ('Pancor', None, 0), ('Puntgun', None, 0)), 1):
    hacer(f'SonEsc{t}.wav', f + '.wav', dur=0.95, mezcla=(b + '.wav', en, 0.9) if b else None)
for k, f in enumerate(('Kar98k', 'M1Garand', 'Barrett M82'), 1):
    hacer(f'SonFra{k}.wav', f + '.wav', dur=1.3)
for k, f in enumerate(('Panzerfaust', 'Panzerschreck', 'Warhawk'), 1):
    hacer(f'SonMis{k}.wav', f + '.wav', dur=1.2)
hacer('SonGra.wav', 'Milkor.wav')
hacer('SonExplota.wav', 'Granada (Explosion).wav', dur=2.0)
for k in (1, 2, 3, 4):
    hacer(f'SonCarne{k}.wav', f'flesh{k}.wav', dur=0.6)
    hacer(f'SonPiedra{k}.wav', f'stone{k}.wav', dur=0.6)
hacer('SonCaja.wav', 'ammobox.wav', filtro=COMP + ',volume=3dB')
hacer('SonTienda.wav', 'equipamiento.wav', filtro=COMP + ',volume=3dB')
hacer('SonCambio.wav', 'armasligeras.wav', 0.27, filtro=COMP + ',volume=3dB')
# truenos: 3 por intensidad (Storm variante 1-3)
for v, tomas in enumerate(((('Thunder 5.wav', 0, 2.06), ('lightningimpact.wav', 0, 1.0), ('stormimpact.wav', 0, 2.19)),
                           (('truenolobo2.wav', 0.4, 5.0), ('truenolobo5.wav', 0.5, 5.0), ('truenolobo1.wav', 1.1, 5.0)),
                           (('truenolobo4.wav', 0.5, 6.0), ('truenolobo1.wav', 8.9, 3.1), ('thunder_with_light_rain_003.wav', 24.2, 6.0))), 1):
    for k, (f, ini, dur) in enumerate(tomas, 1):
        hacer(f'SonTrueno{v}{k}.wav', f, ini, dur, filtro=TRUENO)
(sal / 'lista.tsv').write_text(''.join(f'{n}\t{f}\n' for n, f, _ in lista))
print(len(lista), 'sonidos,', sum(Path(f).stat().st_size for _, f, _ in lista) // 1024, 'KB')
for n, f, s in lista:
    print(f'  {n[16:]:18} {s:5.2f} s')
