"""Datos de las rachas de v14zo (v14zo.py y objetos_v14zo.py)."""
# Escalones: (nombre, sonido, duración medida con ffprobe).
RACHA = [('Killing Spree', 'announcer_kill_spree_01.mp3', 2.46), ('Dominating', 'announcer_kill_dominate_01.mp3', 1.88),
         ('Mega Kill', 'announcer_kill_mega_01.mp3', 2.69), ('Unstoppable', 'announcer_kill_unstop_01.mp3', 2.09),
         ('Wicked Sick', 'announcer_kill_wicked_01.mp3', 2.69), ('Monster Kill', 'announcer_kill_monster_01.mp3', 3.42),
         ('Godlike', 'announcer_kill_godlike_01.mp3', 1.88), ('Beyond Godlike', 'announcer_kill_holy_01.mp3', 2.40)]
MULTI = [('Double Kill', 'announcer_kill_double_01.mp3', 2.09, 8), ('Triple Kill', 'announcer_kill_triple_01.mp3', 1.99, 15),
         ('Ultra Kill', 'announcer_kill_ultra_01.mp3', 2.66, 25), ('Rampage', 'announcer_kill_rampage_01.mp3', 2.04, 40)]
SONIDOS = [r[1] for r in RACHA] + [m[1] for m in MULTI] + ['announcer_1stblood_01.wav', 'RDK_RompeRacha.mp3']
VOCES = {'h005': ['Units\\Orc\\Tauren\\TaurenYesAttack%d.wav' % i for i in (1, 2, 3)] + ['Units\\Orc\\Tauren\\TaurenWarcry1.wav'],
         'h006': ['Units\\Orc\\Cairne\\CairneYesAttack%d.wav' % i for i in (1, 2, 3, 4)] + ['Units\\Orc\\Cairne\\CairneWarcry1.wav']}
