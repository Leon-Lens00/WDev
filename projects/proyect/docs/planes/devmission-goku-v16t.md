# Dev Mission v16t-goku: Goku de D.O.N 1.8c en la pareja de Dev Mission

Fecha: 13/11/2026. Objetivo Warcraft III Classic 1.27b (JASS). Prueba privada de Leon; recursos y código de Goku
pertenecen a Battle Stadium D.O.N 1.8c (Valkemiere y autores de sus recursos).

## Pedido (Leon, 13/11/2026)

Empezar la importación de héroes por Goku: pasarlo de héroe a unidad atada al dummy creador con los parámetros del
Tauren (puntos de animación 0, etc.), habilidades sin enfriamiento y con 1 de maná para probar, el temblor de cámara
del SSJ sin mover la interfaz, y habilidades y MP5 funcionando con el movimiento artificial.

## Base y fuentes

| Entrada | SHA-256 |
|---|---|
| `TerrainDev-Titulo-v16t-ivan.w3x` (base; su j = `v16t-ivan/war3map.j`) | comprobado por cmp en el build |
| `devmission-don18c-20261112/BattlestadiumDON-1.8c-original.w3x` (código) | `7fb3f034…` |
| `devmission-don18c-20261112/DevMission-DON18c-f2.w3x` (objetos y recursos con nombres) | `8da58de9…` |

Construcción: `work/titulo-devmission-20261026/scripts/hacer-v16t-goku.sh`
(goku_trasplante.py → goku_v16t.py → pJASS → objetos_goku.py → recursos_goku.py → mpq_escribir.py → reextracción).

## Decisiones

- **Unidad, no héroe**: `hGok` es la fila de h005 (Tauren) con nombre, modelo, icono y escala de Goku (H00C).
  `Game_Cuerpo` crea cuerpo y controlador `hGok` cuando el jugador es `Gk_Dueno` (primer humano con la celda 0).
  Un solo Goku por partida. La celda 0 del título sigue mostrando el retrato del Tauren (cosmético).
- **Puente de habilidades**: el controlador lleva 5 Canal (AGk1..AGk5, fila de Arp1, 1 de maná, sin enfriamiento);
  `Gk_Relevo` corta dash y ráfaga y ordena al cuerpo la habilidad real de D.O.N (sin enfriamiento ni maná).
  Teclas: E Kamehameha (Q es Subfusiles), W Warp Kamehameha, R Super Dragon Fist, X Power Up (SSJ), T Spirit Bomb.
- **Movimiento artificial**: guardas en RapidPair: con el cuerpo pausado por D.O.N no se aceptan ráfaga, dash ni
  destino; disparar o hacer dash corta la canalización del SSJ y de la Spirit Bomb.
- **Temblor**: las llamadas de ruido de cámara de D.O.N pasan a `Sacude_Mag[p]`, que desplaza la cámara lógica en
  `FollowCamera`; la interfaz se proyecta desde esa cámara y tiembla con ella sin separarse. Ivan sigue usando el
  ruido nativo (no tocado).
- **Fuerza**: D.O.N calcula daño con la fuerza del héroe; aquí `Gk_Fuerza` = 25 + 3,5·(N−1), N = `Gk_Nivel`
  (10 por defecto; comando `-gk N`, 1..100).
- **Texttags**: los textos de Goku usan un anillo de 20 huecos (`Gk_TT`), dentro del presupuesto de 100.
- Árboles (Leon, 13/11): las habilidades de Goku no los destruyen; la enumeración de destructibles de D.O.N (`kb`) queda vacía.
- Spirit Bomb (Leon, 13/11): el botón apunta con círculo de área de 1500 (radio de su daño en D.O.N).

## Estado

Corrección del 13/11 tras la primera prueba de Leon (el Kamehameha no salía): A00P es Serpent Ward (AOsw),
cuya orden es `ward`; el relevo ordenaba `shockwave`. Las otras cuatro órdenes coinciden con 1.27b
(AHtb thunderbolt, ACmp impale, AOvd voodoo, ANrf rainoffire). Mapa reconstruido: SHA-256 `af0d4918…`.

**Validated** (13/11/2026): pJASS correcto; 697 entradas reextraídas iguales por SHA-256; `mpq verify` correcto.
Mapa `TerrainDev-Titulo-v16t-goku.w3x` SHA-256 `af0d4918…` (la primera entrega fue `9c16e8b4…`). Recursos: 73 de f2 + `HealthIconGoku.mdx` (0,9 MB).

Sin comprobar: juego (Leon prueba con `scripts/entrar-v16t-goku.sh`), multijugador, retrato del controlador sin
cabeza SSJ, alcance del Warp Kamehameha (800: si el objetivo está más lejos el cuerpo camina).

## v16t-gokum: movimiento con Missile (13/11/2026)

Leon (13/11): adaptar el movimiento de las habilidades a nuestro sistema de misiles. `scripts/goku_misil.py` entre el
trasplante y la integración (`hacer-v16t-gokum.sh`); la lógica de D.O.N no se reescribe.

- Instancia propia del módulo MissileStruct (struct id 71, `Gk_MIS`), como RapidBolt; la biblioteca no se toca.
  Misil sin modelo y sin colisión de unidades. Los triggers Aa (Kamehameha), Zx (Super Dragon Fist) y Pa (Spirit
  Bomb) pierden su temporizador; el misil los ejecuta a su ritmo original (0,03 / 0,04 s acumulados) y la acción
  de D.O.N coloca la pieza donde está el misil en vez de sumarle un paso fijo.
- Velocidades de D.O.N: Kamehameha 2000/s, Spirit Bomb 1125/s, Dragon Fist n8[4411]·25/s (250 y luego 1625).
- Choque con precipicios y árboles (`GroundCollision_trace`, como las balas): la bola del Kamehameha acaba ahí
  (fin propio a07); Goku en el Dragon Fist se detiene y acaba al lanzarse (Uu4 con o8[4410]). La Spirit Bomb va por
  el aire, sin choque. El empuje del Warp (js) conserva su temporizador pero corta en precipicios y árboles.
- Destino recortado a WorldBounds; si el misil se retira sin que D.O.N lo pidiera, un último paso con choque cierra
  la habilidad. Sigue siendo una sola instancia (un Goku por partida), no MUI.

**Validated** (13/11/2026): pJASS correcto; 697 entradas reextraídas iguales; `mpq verify` correcto. Mapa
`TerrainDev-Titulo-v16t-gokum.w3x` SHA-256 `8a280ec4…`. Sin comprobar: juego (`scripts/entrar-v16t-gokum.sh`),
multijugador.

## Siguiente paso

Prueba de Leon; luego los demás personajes de D.O.N con el mismo método.
