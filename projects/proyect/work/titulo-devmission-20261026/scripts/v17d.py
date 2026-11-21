#!/usr/bin/env python3
"""v17d (14/11/2026): sonidos de armas por tier, impactos, explosión, cajas verdes, tienda, cambio de arma y truenos.

Leon (14/11/2026): "adelante prepara e implementa los audios, averigua tambien como importar correctamente audio 3d en el
juego y se oigan bien". Archivos de scripts/sonidos_v17d.py (AudioClip de Leon).
3D como los sonidos de combate de Blizzard (UI\\SoundInfo\\AnimSounds.slk de War3x.mpq 1.27b: RiflemanAttack1, Mortar,
LightningBolt): WANT3D, MinDistance 600, MaxDistance 10000, DistanceCutoff 3000, canal 11, EAX MissilesEAX o
CombatSoundsEAX; sus WAV son PCM 16 bits 22050 Hz mono. Detener fuera de alcance (stopwhenoutofrange) activo.
- Disparo (Arm_Emitir, uno por disparo; la escopeta suena una vez, no por perdigón), en la posición del tirador.
- Impacto en unidad (Arm_Impacto, carne) y en pared o árbol (RapidBolt_resolve, piedra); explosión (Arm_Explotar).
- Tope por ventana de 0,25 s: 10 disparos y 6 impactos. Tono 0,95–1,05 de un contador (sin tocar el azar sincronizado).
- Cada sonido se crea en todos los clientes; sólo el volumen depende de GetLocalPlayer (lo de otros jugadores a 3/4).
- Caja verde (Recarga_Tomar), compra o mejora de tier (Shop_Comprar) y cambio de arma (Arm_Elegir): sonido 2D sólo
  para ese jugador, como UI_Click; precargados a volumen 0.
- Truenos: 3 de AudioClip por intensidad en lugar de StormT1-3 (8 bits), volumen 127, y la música baja a 0,45
  durante 4 s para quien ve la tormenta.
- Precarga: todos los archivos se reproducen una vez a volumen 0 (el primer uso de un sonido importado no suena).
Uso: v17d.py ENTRADA.j LISTA.tsv SALIDA.j
"""
from pathlib import Path
import sys, wave

j = Path(sys.argv[1]).read_bytes().decode('latin-1')
lista = [l.split('\t') for l in Path(sys.argv[2]).read_text().splitlines()]
crlf = lambda s: s.replace('\r\n', '\n').replace('\n', '\r\n')


def una(antes, despues):
    global j
    antes, despues = crlf(antes), crlf(despues)
    assert j.count(antes) == 1, (antes[:100], j.count(antes))
    j = j.replace(antes, despues)


def ms(nombre):
    f = dict(lista)['war3mapImported\\' + nombre]
    with wave.open(f) as w:
        assert (w.getframerate(), w.getnchannels(), w.getsampwidth()) == (22050, 1, 2), f
        return round(w.getnframes() * 1000 / 22050)


ARMA = {}
for t in range(6):
    ARMA[0 * 6 + t] = f'SonMis{t // 2 + 1}'
    ARMA[1 * 6 + t] = f'SonSub{t + 1}'
    ARMA[2 * 6 + t] = f'SonFus{t + 1}'
    ARMA[3 * 6 + t] = f'SonFra{t // 2 + 1}'
    ARMA[4 * 6 + t] = f'SonEsc{t + 1}'
    ARMA[6 * 6 + t] = 'SonGra'
for n in ARMA.values():
    ms(n + '.wav')
q = lambda n: '"war3mapImported\\\\' + n + '"'

# --- globales ---
una('string array Storm__ThunderPath\n', '''string array Storm__ThunderPath
// v17d: sonidos (Son_*)
string array Son_Arma
string array Son_Trueno
integer Son_TruenoN= 0
integer Son_Tono= 0
integer Son_Toma= 0
real Son_Ventana= 0.
integer array Son_Cuenta
sound Son_CajaSnd= null
sound Son_TiendaSnd= null
sound Son_CambioSnd= null
timer Son_Musica= null
''')

# --- funciones, antes de Arm_Impacto ---
init = ''.join(f'    set Son_Arma[{w}] = {q(n + ".wav")}\n' for w, n in sorted(ARMA.items()))
init += ''.join(f'    set Son_Trueno[{v * 3 + k}] = {q(f"SonTrueno{v}{k + 1}.wav")}\n' for v in (1, 2, 3) for k in range(3))
ui = ''
for var, n in (('Son_CajaSnd', 'SonCaja.wav'), ('Son_TiendaSnd', 'SonTienda.wav'), ('Son_CambioSnd', 'SonCambio.wav')):
    ui += f'''    set {var} = CreateSound({q(n)}, false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration({var}, {ms(n)})
    call SetSoundChannel({var}, 0)
    call SetSoundVolume({var}, 0)
    call StartSound({var})
'''
pre = ''.join(f'    call Son_Cero({q(n[16:])})\n' for n, f in lista if n[16:] not in ('SonCaja.wav', 'SonTienda.wav', 'SonCambio.wav'))
una('    function Arm_Impacto takes integer m,unit caster,unit target returns nothing\n', f'''// v17d: sonidos de armas, impactos, explosión, cajas, tienda y truenos (AudioClip; scripts/sonidos_v17d.py).
// 3D como los de combate de Blizzard (AnimSounds.slk de 1.27b): WANT3D, 600/10000, corte 3000, canal 11, PCM 22050 Hz
// mono. Se crean en todos los clientes; sólo el volumen depende de GetLocalPlayer.
function Son_3D takes string f, real x, real y, integer vol, string eax, player owner returns nothing
    local sound s
    local integer v = vol
    if f == "" or f == null then
        return
    endif
    set Son_Tono = ModuloInteger(Son_Tono + 7, 11)
    if GetLocalPlayer() != owner then
        set v = vol * 3 / 4
    endif
    set s = CreateSound(f, false, true, true, 10, 10, eax)
    call SetSoundChannel(s, 11)
    call SetSoundDistances(s, 600., 10000.)
    call SetSoundDistanceCutoff(s, 3000.)
    call SetSoundPitch(s, 0.95 + 0.01 * I2R(Son_Tono))
    call SetSoundVolume(s, v)
    call SetSoundPosition(s, x, y, 0.)
    call StartSound(s)
    call KillSoundWhenDone(s)
    set s = null
endfunction

// Tope por ventana de 0,25 s: 10 disparos (tipo 0) y 6 impactos (tipo 1). Las explosiones no tienen tope.
function Son_Hueco takes integer tipo returns boolean
    local real t = TimerGetElapsed(s__RapidPair_clock)
    if t >= Son_Ventana or t < Son_Ventana - 0.25 then
        set Son_Ventana = t + 0.25
        set Son_Cuenta[0] = 0
        set Son_Cuenta[1] = 0
    endif
    if Son_Cuenta[tipo] >= 10 - 4 * tipo then
        return false
    endif
    set Son_Cuenta[tipo] = Son_Cuenta[tipo] + 1
    return true
endfunction

function Son_Disparo takes unit a, integer w returns nothing
    if Son_Hueco(0) then
        call Son_3D(Son_Arma[w], GetUnitX(a), GetUnitY(a), 127, "MissilesEAX", GetOwningPlayer(a))
    endif
endfunction

function Son_Impacto takes real x, real y, boolean carne, player owner returns nothing
    if Son_Hueco(1) then
        set Son_Toma = ModuloInteger(Son_Toma, 4) + 1
        if carne then
            call Son_3D("war3mapImported\\\\SonCarne" + I2S(Son_Toma) + ".wav", x, y, 110, "CombatSoundsEAX", owner)
        else
            call Son_3D("war3mapImported\\\\SonPiedra" + I2S(Son_Toma) + ".wav", x, y, 95, "CombatSoundsEAX", owner)
        endif
    endif
endfunction

// Sonido 2D sólo para el jugador p (como UI_Click).
function Son_Ui takes integer p, sound s returns nothing
    if GetLocalPlayer() == Player(p) then
        call StopSound(s, false, false)
        call SetSoundVolume(s, 127)
        call StartSound(s)
    endif
endfunction

function Son_MusicaVuelve takes nothing returns nothing
    call VolumeGroupSetVolume(SOUND_VOLUMEGROUP_MUSIC, 1.)
endfunction

// Primer uso a volumen 0: un sonido importado no suena la primera vez que se carga.
function Son_Cero takes string f returns nothing
    local sound s = CreateSound(f, false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundVolume(s, 0)
    call StartSound(s)
    call KillSoundWhenDone(s)
    set s = null
endfunction

function Son_Init takes nothing returns nothing
{init}{ui}    set Son_Musica = CreateTimer()
{pre}endfunction

    function Arm_Impacto takes integer m,unit caster,unit target returns nothing
''')

# --- disparo, impactos, explosión ---
una('''        set Arm_Clip[p * 7 + c]=Arm_Clip[p * 7 + c] - 1
        set angle=Atan2(''', '''        set Arm_Clip[p * 7 + c]=Arm_Clip[p * 7 + c] - 1
        call Son_Disparo(s__RapidPair_actor[this] , w)
        set angle=Atan2(''')
una('''        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
        call Barras_Golpe(caster, target)
''', '''        call UnitDamageTarget(caster, target, d, false, false, Dano_Ataque(Bala_Tipo[m]), Dano_TipoArma, null)
        call Barras_Golpe(caster, target)
        call Son_Impacto(GetUnitX(target) , GetUnitY(target) , true , s__RapidBolt_owner[m])
''')
una('''        set Bala_Area[m]=0.
        // v14o:''', '''        set Bala_Area[m]=0.
        call Son_3D("war3mapImported\\\\SonExplota.wav" , x , y , 127 , "MissilesEAX" , owner)
        // v14o:''')
una('''        if result == 1 then
            set s__RapidBolt_walls=s__RapidBolt_walls + 1
        endif
''', '''        if result == 1 then
            set s__RapidBolt_walls=s__RapidBolt_walls + 1
            if Bala_Area[m] <= 0. then
                call Son_Impacto(s__GroundCollision_x , s__GroundCollision_y , false , s__RapidBolt_owner[m])
            endif
        endif
''')

# --- cajas, tienda, cambio de arma ---
una('''    call Recarga_Pintar(p , z)
    call UI_Click(p)
''', '''    call Recarga_Pintar(p , z)
    // v17d: sonido de recarga (ammobox) en lugar del clic.
    call Son_Ui(p , Son_CajaSnd)
''')
una('''    set Arm_Rva[i] = Arm_Res[w]
    call UI_Click(p)
    call Shop_Refrescar(p)
''', '''    set Arm_Rva[i] = Arm_Res[w]
    // v17d: compra o mejora de tier (equipamiento).
    call Son_Ui(p, Son_TiendaSnd)
    call Shop_Refrescar(p)
''')
una('''        set Arm_Fin[p]=0.
        set Arm_Cat[p]=c
        call Arm_Conos(p)
''', '''        set Arm_Fin[p]=0.
        set Arm_Cat[p]=c
        // v17d: cambio de arma (armasligeras).
        call Son_Ui(p , Son_CambioSnd)
        call Arm_Conos(p)
''')

# --- truenos ---
una('''            if s__Storm__TStorm_Local[this] then
                set s = CreateSound(Storm__ThunderPath[v], false, false, false, 10, 10, "DoodadsEAX")
                call SetSoundChannel(s, 10)
            else''', '''            // v17d: tres truenos de AudioClip por intensidad, por turno (igual en todos los clientes); la música baja 4 s.
            set Son_TruenoN = Son_TruenoN + 1
            if s__Storm__TStorm_Local[this] then
                set s = CreateSound(Son_Trueno[v * 3 + ModuloInteger(Son_TruenoN, 3)], false, false, false, 10, 10, "DoodadsEAX")
                call SetSoundChannel(s, 10)
                call VolumeGroupSetVolume(SOUND_VOLUMEGROUP_MUSIC, 0.45)
            else''')
una('''            call SetSoundVolume(s, GetRandomInt(102, 127))
            call SetSoundPitch(s, GetRandomReal(0.9, 1.1))
            call StartSound(s)
            call KillSoundWhenDone(s)
            set s = null
''', '''            call SetSoundVolume(s, 127)
            call SetSoundPitch(s, GetRandomReal(0.9, 1.1))
            call StartSound(s)
            call KillSoundWhenDone(s)
            set s = null
            call TimerStart(Son_Musica, 4., false, function Son_MusicaVuelve)
''')

# --- precarga ---
una('''    // v14s: truenos de Storm con volumen 0.
    set i = 1
    loop
        exitwhen i > 3
        call Preload("war3mapImported\\\\StormT" + I2S(i) + ".wav")
        set s = CreateSound("war3mapImported\\\\StormT" + I2S(i) + ".wav", false, false, false, 10, 10, "DoodadsEAX")
        call SetSoundVolume(s, 0)
        call StartSound(s)
        call KillSoundWhenDone(s)
        set i = i + 1
    endloop
''', '''    // v17d: todos los sonidos (truenos incluidos) a volumen 0 en Son_Init.
    call Son_Init()
''')
Path(sys.argv[3]).write_bytes(j.encode('latin-1'))
print('v17d:', len(ARMA), 'armas con sonido,', len(lista), 'archivos')
