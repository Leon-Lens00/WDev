"""v16u (13/11/2026): héroes de Battle Stadium D.O.N 1.8c en las celdas del título de Dev Mission.

Leon (13/11/2026): Goku, Freezer, Future Trunks y Naruto en celdas propias (2-5) con su icono; la celda 0 vuelve a
ser el Tauren; sin retrato ni voz por ahora; uno de cada por partida. Datos comunes de objetos_v16u.py y don_v16u.py.
Botones del controlador: las seis casillas libres con las armas básicas (Q y Z ocupadas por las armas, A dash..., F
recarga, G, D): (1,0) E, (2,0) W, (3,0) R, (1,2) X, (2,2) C, (3,2) T. Órdenes reales de classic-assets/Units/*Func.txt.
Objetivo: 0 ninguno, 1 unidad, 2 punto. area: círculo del botón (radio del daño de D.O.N).
"""
CASILLAS = [(1, 0, 'E'), (2, 0, 'W'), (3, 0, 'R'), (1, 2, 'X'), (2, 2, 'C'), (3, 2, 'T')]

HEROES = [
    dict(P='Gk', celda=2, unidad='hGok', don='H00C', icono_titulo='DT4G', nuevo=False),
    dict(P='Fz', celda=3, unidad='hFrz', don='H0GX', icono_titulo='DT4F', nuevo=True, nombre='Freezer',
         vida='hbi4', stats=((24, 2.8), (15, 2.3), (21, 2.9)), registro=[], pasivas=[],
         triggers='Ct Ty At Bt ct', remapeo='',
         botones=[  # real, orden real, objetivo, orden del puente, nombre, descripción, área
             ('A0IY', 'roar', 0, 'starfall', 'Destructo Disc', 'Freezer lanza un disco cortante.', 0),
             ('A0J1', 'entanglingroots', 1, 'tranquility', 'Death Break', 'Freezer castiga al enemigo elegido.', 0),
             ('A0IX', 'ward', 2, 'stampede', 'You Will Die By My Hand!', 'Freezer dispara hacia el punto.', 0),
             ('A0IW', 'rainoffire', 2, 'deathanddecay', 'Death Ball', 'Freezer reúne y lanza la Death Ball sobre el punto.', 1000.),
             ('A0IV', 'thunderbolt', 1, 'monsoon', 'Imprisonment Ball', 'Freezer encierra al enemigo elegido.', 0),
             ('A0IZ', 'berserk', 0, 'volcano', 'Power Up', 'Freezer libera su poder.', 0)]),
    dict(P='Tr', celda=4, unidad='hTrk', don='H037', icono_titulo='DT4T', nuevo=True, nombre='Future Trunks',
         vida='hbi5', stats=((20, 2.5), (25, 3.2), (15, 2.3)), registro=['set TrV_s8[$CEE]=b'], pasivas=['A07X', 'A03Z'],
         triggers='dt Lu bB aB SA', remapeo='',
         botones=[
             ('A0H5', 'voodoo', 0, 'blackarrow', 'Power Up', 'Trunks canaliza su poder. Disparar o hacer dash la corta.', 0),
             ('A0GV', 'ward', 2, 'cripple', 'Finish Buster', 'Trunks lanza el Finish Buster hacia el punto.', 0),
             ('A086', 'forkedlightning', 1, 'deathcoil', 'Heat Dome', 'Trunks atrapa al enemigo elegido en el Heat Dome.', 0),
             ('A05B', 'shockwave', 2, 'doom', 'Burning Attack', 'Trunks dispara el Burning Attack hacia el punto.', 0),
             ('A03W', 'entanglingroots', 1, 'drunkenhaze', 'Burning Slash', 'Trunks se lanza con la espada contra el enemigo.', 0),
             ('A0I5', 'roar', 0, 'frostnova', 'Finish Sign', 'Trunks remata con el Finish Sign.', 0)]),
    dict(P='Na', celda=5, unidad='hNar', don='H01A', icono_titulo='DT4N', nuevo=True, nombre='Naruto (modo sabio)',
         vida='hbi6', stats=((27, 3.6), (14, 2.5), (19, 1.9)), registro=['set NaV_s8[5790]=b'], pasivas=['A0AO', 'A00W'],
         triggers='Au Ja Cy yu Uv jB', remapeo='H01A=hNar,H0D9=hNaK', forma=('hNaK', 'H0D9'),
         botones=[
             ('A00T', 'mirrorimage', 0, 'healingwave', 'Tajuu Kage Bunshin', 'Naruto crea sus clones de sombra.', 0),
             ('A0AI', 'thunderbolt', 1, 'holybolt', 'Senpuu Odama Rasengan', 'Naruto golpea al enemigo con el Rasengan.', 0),
             ('A00U', 'chemicalrage', 0, 'mindrot', 'Kyuubi de seis colas', 'Naruto pasa al modo Kyuubi un tiempo.', 0),
             ('A0F5', 'forkedlightning', 1, 'silence', 'Rasenrengan', 'Naruto lanza el Rasenrengan al enemigo elegido.', 0),
             ('A0F3', 'ward', 2, 'stormbolt', 'RasenShuriken', 'Naruto lanza el RasenShuriken hacia el punto.', 0),
             ('A0HW', 'rainoffire', 2, 'soulburn', 'Kyuubi Chakra Blast', 'Sólo en modo Kyuubi: ráfaga de chakra sobre el punto.', 600.)]),
]
SOLO_FORMA = {'A0HW'}  # sólo en la forma Kyuubi (fila hNaK); el puente la pide sólo con el cuerpo en esa forma
NIVELES = {'A00U': 3}  # el nivel 4 de D.O.N apunta a otras filas (H00C/H00D)
