# Dev Mission v16u: Freezer, Future Trunks y Naruto de D.O.N 1.8c

Fecha: 13/11/2026. Objetivo Warcraft III Classic 1.27b (JASS). Prueba privada de Leon; recursos y código de los
héroes pertenecen a Battle Stadium D.O.N 1.8c (Valkemiere y autores de sus recursos).

## Pedido (Leon, 13/11/2026)

"traemos a freezer, thunks del futuro y naruto", con el método de Goku (habilidades tal cual, movimiento en nuestro
Missile), y anotar los hallazgos para importar otros héroes con facilidad
(`WDev/skills/claude/mapa-dev-mission/references/importar-heroes-don.md`).
Elección de Leon: **celdas propias** del título (Goku 2, Freezer 3, Trunks 4, Naruto 5) con su icono; la celda 0
vuelve a ser el Tauren; sin retrato ni voz por ahora; uno de cada por partida.

## Base y fuentes

| Entrada | SHA-256 |
|---|---|
| `TerrainDev-Titulo-v16t-gokum.w3x` (base; su j = `v16t-gokum/war3map.j`) | `8a280ec4…` |
| `devmission-don18c-20261112/BattlestadiumDON-1.8c-original.w3x` (código) | `7fb3f034…` |
| `devmission-don18c-20261112/DevMission-DON18c-f2.w3x` (objetos y recursos) | `8da58de9…` |

Construcción: `work/titulo-devmission-20261026/scripts/hacer-v16u.sh`:
`don_heroe.py` (trasplante genérico, por héroe) → `don_misil.py` (movimiento) → `objetos_v16u.py` → `don_v16u.py`
(integración) → pJASS → `recursos_v16u.py` → `mpq_escribir.py` → reextracción por hash y `mpq verify`. Datos de los
héroes (celda, unidad, botones, órdenes) en `don_heroes.py`. Informe del trasplante en `v16u/trasplante.txt`.

Nota: en esta sesión `don_trasplante.py` (trasplante de v16t-don, 12/11) quedó sobrescrito por el genérico; se
restauró desde el historial de la sesión y el genérico pasó a `don_heroe.py`. No se reconstruyó v16t-don para
comprobar la restauración.

## Decisiones

- **Héroes** (fila de D.O.N → unidad de Dev Mission, fila del Tauren h005 con lo visual del héroe):
  Freezer H0GX → `hFrz`; Future Trunks H037 → `hTrk`; Naruto modo sabio H01A → `hNar` y su forma Kyuubi H0D9 →
  `hNaK` (A00U morfa entre las dos; las condiciones de D.O.N con H01A/H0D9 se remapean). Iconos de vida hbi4–hbi6.
- **Triggers principales** (el resto sale por cierre): Freezer `Ct Ty At Bt ct`; Trunks `dt Lu bB aB SA` (+ rama
  Bt7 del fin de canalización); Naruto `Au Ja Cy yu Uv jB`. Registro de D.O.N al entrar: Trunks `s8[$CEE]`, Naruto
  `s8[5790]`; Freezer no tiene.
- **Botones puente** (Canal, 1 de maná, sin enfriamiento) en las seis casillas libres: E W R X C T.
  Freezer: Destructo Disc, Death Break, You Will Die By My Hand!, Death Ball (círculo 1000), Imprisonment Ball,
  Power Up. Trunks: Power Up, Finish Buster, Heat Dome, Burning Attack, Burning Slash, Finish Sign. Naruto: Kage
  Bunshin, Rasengan, Kyuubi, Rasenrengan, RasenShuriken, Kyuubi Chakra Blast (T, sólo en forma Kyuubi, círculo 600).
- Habilidades reales y pasivas (cabezas de Trunks, ojo y Frog Taka de Naruto) permanentes en el cuerpo, al nivel de
  D.O.N; también `Arei` (reaparición), por el cambio de forma de Naruto.
- **Movimiento**: los triggers periódicos que mueven piezas pierden su temporizador y los ejecuta un motor de Missile
  (struct 72, uno por trigger) al ritmo de D.O.N; cada `SetUnitPositionLoc*` de esas acciones pasa por `Don_Pon`
  (GroundCollision: la pieza no atraviesa precipicios ni árboles; por el aire, sin choque). Los finales siguen siendo
  los de D.O.N. Motores: Freezer Dt Uy Vy at bt is js; Trunks BB Mu js; Naruto Vv Wv Xv cy kB mB zu.
- Atributos de D.O.N por nivel (`<P>_Stat`), con el mismo `-gk N` que Goku.
- Un héroe de cada: `Hero_Lock` da error si otro jugador ya fijó esa celda; al entrar, quien la fijó tiene prioridad;
  el resto recibe al Tauren. Goku pasa a la celda 2 con la misma regla.
- Disparar o hacer dash corta las canalizaciones (voodoo, rainoffire) de los cinco cuerpos (antes sólo Goku).
- La tienda nombra al personaje (Goku, Freezer, Trunks, Naruto) en lugar de "Tauren".

## Estado

**Validated** (13/11/2026): pJASS correcto; 823 entradas reextraídas iguales por SHA-256; `mpq verify` correcto.
Struct 72 libre (71 Goku, 70 RapidPair); máximo de elseif por función 44; sin funciones duplicadas.
Mapa `TerrainDev-Titulo-v16u.w3x` SHA-256 `4b0ca11a…`. Recursos: 123 de f2 (1,5 MB) + 3 iconos de vida.

Sin comprobar: juego (Leon, `scripts/entrar-v16u.sh`), multijugador. Riesgos a mirar en la prueba:
- Frog Taka de Naruto (trigger de ataque `vU`) no se trasplantó: el cuerpo no ataca de forma nativa.
- Forma Kyuubi: velocidad de la fila (300) en lugar de 350 mientras dura; ilusiones de Kage Bunshin quietas.
- Piezas bloqueadas por precipicio o árbol esperan ahí el final propio de D.O.N (no hay final por choque como en Goku).
- Celdas 2–5 sin retrato ni voz (pedido); `Hero_Say` con voz vacía.

## v16v: comando -pj N (13/11/2026)

Leon, al probar v16u: "como pruebo los pjs, aparece la partida con el tauren como predeterminado". Causa: desde v16a la
partida entra directa (`Tut_Entrar` llama a `Title_Begin` y `Title_Exit`), no se ve el título y nadie elige celda.
`scripts/pj_v16v.py` (`hacer-v16v.sh`, sólo cambia el j) añade `-pj N` (0 Tauren, 1 Cairne, 2 Goku, 3 Freezer,
4 Trunks, 5 Naruto): rehace la pareja en el mismo sitio (RapidPair_destroy + Game_Cuerpo, como la reaparición), cambia
el icono de vida y pasa al cuerpo nuevo el blanco y la visión de la oleada en curso. Uno de cada héroe de D.O.N; sólo
con el personaje vivo y sin una habilidad de D.O.N en curso. La invulnerabilidad del descanso se copia mirando `Avul`
(1.27b no tiene IsUnitInvulnerable; sin comprobar en el juego que SetUnitInvulnerable la añada).

**Validated** (13/11/2026): pJASS correcto; 823 entradas reextraídas iguales; `mpq verify` correcto. Mapa
`TerrainDev-Titulo-v16v.w3x` SHA-256 `f5a94248…`. Sin comprobar: juego (`scripts/entrar-v16v.sh`), multijugador.

## v16w: -pj corregido (13/11/2026)

Leon probó v16v: "-pj 5" respondía con el uso ("esta bien asi? no funca"). Causa: `Pj_Cambiar` exigía
`Hero_Icon[k] != 0`, y `Hero_Icon` sólo lo rellena `Hero_Build`, que corre al mostrar la pantalla de héroes; con la
entrada directa no corre y todas las celdas valen 0. `scripts/pj_v16w.py` quita esa condición (el rango 0..5 ya se
comprueba). `-pj5` sin espacio sigue dando el uso, como debe.

**Validated** (13/11/2026): pJASS correcto; el j difiere de v16v sólo en esa línea; 823 entradas reextraídas iguales;
`mpq verify` correcto. Mapa `TerrainDev-Titulo-v16w.w3x` SHA-256 `d1edd8eb…`. Sin comprobar: juego
(`scripts/entrar-v16w.sh`), multijugador.

## v16x: la oleada sigue al personaje nuevo (13/11/2026)

Leon, con v16w: "lo malo que la wave sys los enemigos se quedan en pausa". Causa: `-pj` sólo cambiaba
`DevWave__Targets`; la IA de oleadas guarda sus blancos en `WaveAI__TargetUnit` (`WaveAIRegisterTarget`) y la oleada
en curso en `nearUnits`. Al quitar el cuerpo viejo la IA quedaba sin blancos vivos. `scripts/pj_v16x.py` sustituye el
cuerpo viejo por el nuevo en las dos listas (`WaveAIUnregisterTarget` + `WaveAIRegisterTarget`).

**Validated** (13/11/2026): pJASS correcto; 823 entradas reextraídas iguales; `mpq verify` correcto. Mapa
`TerrainDev-Titulo-v16x.w3x` SHA-256 `2853677f…`. Sin comprobar: juego (`scripts/entrar-v16x.sh`), multijugador.

## v16y: revisión de habilidades (13/11/2026)

Leon, con v16x: "unas de trunk como el burning attack no funciona/ freezer con su disco, naruto su dummy effecto
espcial del shuriken no desaparece, y las habilidades en el modo kyubi, evaluemos para ver si estan realemente bien o
necesitan unos fix". Revisión estática del código trasplantado; `scripts/don_v16y.py` (`hacer-v16y.sh`, cambia j, w3a y
w3u):

- **Niveles**: sin `alev` en D.O.N la habilidad tiene el nivel por defecto de su base (`AbilityData.slk`: ACro, Absk y
  AOvd 1). La regla de v16u ("máximo nivel con datos") puso 4 a A0IY (Destructo Disc; sus niveles 2–4 son datos de
  "Angry Explosion"), A0IZ, A0H5 y A0I5. Pasan a 1 en el j y en el w3a.
- **RasenShuriken Kyuubi**: la primera pieza `h09P` (escala 50, altura 75) se creaba sin vida temporal ni variable y
  quedaba para siempre; también ocurre en el código de D.O.N. Recibe 1,8 s, lo que vive la pieza que vuela (`h0DI`).
- **Relanzar**: sin enfriamiento, un segundo lanzamiento mientras vuela el primero pisa el estado de una sola instancia
  de D.O.N (RasenShuriken de sabio: `s8[5141]`/`s8[5142]` sin vida temporal hasta el final, quedaban huérfanas).
  `Don_EnCurso` rechaza el botón mientras su motor sigue encendido (`IsTriggerEnabled`). Destructo Disc lleva lista
  propia (`vg..wg`) y no se bloquea.
- **Modo Kyuubi**: H0D9 tiene `A0HX,A0HW` y `A00U,A0F3,Aamk,A00W`; Kage Bunshin (A00T) y Rasengan (A0AI) se rechazan en
  esa forma (no tienen rama hNaK). Rasenrengan (A0F5) sí tiene rama hNaK y sigue. Atributos de H0D9 en `Na_Stat`
  (fuerza 30 +3,4; agilidad 14 +2,7; inteligencia 19 +1,9). `umvs` 350 en hNar y hNaK (el morfo devolvía 300).
- **Avisos en el chat** (no registros): "Todavía en curso", "Ahora no: otra habilidad está en curso" (cuerpo pausado)
  y "El cuerpo no aceptó la orden X". El aviso de Kyuubi Chakra Blast pasa de latin-1 a UTF-8.
- **Sin causa encontrada**: Burning Attack (A05B, AOsh `shockwave`, punto; motor `BB` hasta que muere `h06F`, unos
  2,6 s) y Destructo Disc (A0IY, ACro `roar`; el disco sale en la dirección a la que mira el cuerpo, a altura 200 y sin
  choque) no muestran fallo en la lectura del código. Los avisos nuevos deben decir si la orden se rechaza o si el
  cuerpo estaba ocupado; falta la descripción exacta de Leon.

**Validated** (13/11/2026): pJASS correcto; 823 entradas reextraídas iguales; `mpq verify` correcto. Mapa
`TerrainDev-Titulo-v16y.w3x` SHA-256 `ede162a6…`. Sin comprobar: juego (`scripts/entrar-v16y.sh`), multijugador.
Riesgo: si el final de una habilidad no llega nunca (pieza que no muere), su botón queda bloqueado con "Todavía en curso".

### v16y-prueba (13/11/2026)

Leon, con v16y: "no se ejecutan, agrega tu modo registro para que veas que pasa al terminar el mapa".
`scripts/prueba_v16y.py` (`hacer-v16y-prueba.sh`, sólo el j) escribe `CustomMapData/lat/v16y-1.txt` cada 2 s:
botones puente (estado del cuerpo, orden y si la aceptó), órdenes y eventos de hechizo de los cuerpos de D.O.N, niveles
al armar, inicio de Burning Attack y Destructo Disc, motores y muestras de sus piezas cada 0,2 s.
**Validated**: pJASS correcto; 823 entradas reextraídas iguales; `mpq verify` correcto. SHA-256 `60606ff9…`.
Lanzador `scripts/entrar-v16y-prueba.sh`. Pendiente: leer el registro tras la partida de Leon.
Registro leído (13/11/2026): el disco `h0AU` no se crea (`CreateNUnitsAtLoc` devuelve null) y la orden `shockwave` de
Burning Attack se acepta pero no llega evento CHANNEL de A05B. Investigación en pausa.

## v16t-corto: balas con Death de 0,3 s (13/11/2026)

Leon: "tomemos esa version de antes de optimizar los missiles y apliquemos ello". Base v16t (08/11/2026, anterior al
laboratorio `bench-misiles-toy-20261110` y a los héroes de D.O.N; SHA-256 `d307d552…`). Se aplica lo del laboratorio
(`ToyBullet-Tier6-Lab-vuelo`, `arte=4`, `BenchPool_ShotDelay` 0,30), que no había llegado a Dev Mission:

- 41 modelos de bala recortados con `acortar2.cjs` (Death comprimida a 0,3 s, emisores de muerte cortados, vida de
  partículas acotada; la estela de vuelo no cambia), en las mismas rutas: Interceptor Shell 1–6, Shot II y Shot
  (7 colores, incluye Orange de Rapid Fire), Daemonic Arrow y Chain Grenade (6 colores), Firebrand Shot (9 colores).
  Los tres de tier 6 rojo dan los mismos bytes que el laboratorio.
- j: sólo `MissileRecycler___DEATH_TIME` 2 → 0,3 (retención igual a la Death nueva).

`scripts/hacer-v16t-corto.sh`. **Validated**: pJASS correcto; 612 entradas reextraídas iguales; cambian sólo el j, los
41 modelos y el listfile; `mpq verify` correcto. SHA-256 `ac446852…`. Lanzador `scripts/entrar-v16t-corto.sh`. Sin
comprobar: juego (aspecto del impacto acortado, fps con SPAS), multijugador. No lleva los héroes de D.O.N ni nada
posterior a v16t.

## v16t-rpm: ritmo del tier 1 y daño en la bala (13/11/2026)

Leon: "dejemos de momento la rpm del tier 1, ahora el dano mejorara directo en la bala en lugar del rpm y la velocidad
fija en tier 1 tambien, el intervalo de la escopeta sera como el rifle franco, muy lenta" (antes: "en la escopeta sera
siempre 5 perdigones en abanico"). `scripts/rpm_v16t.py` sobre v16t-corto (`hacer-v16t-rpm.sh`, sólo el j):

- Subfusil 480 rpm, fusil de asalto 560, granada 240 y velocidad de bala del tier 1 (1300, 1800, 900) en los seis
  tiers. Francotirador y misiles ya tenían un solo ritmo; su velocidad queda en la del tier 1 (2400, 1200).
- Escopeta: 60 rpm (1 disparo/s, como el francotirador), 5 perdigones en abanico fijo de −10° a +10° (antes al azar),
  velocidad 1700.
- Daño por bala = el que conserva el daño por segundo de cada tier (±1 %): MP5 43→79, FN SCAR 49→70, SPAS-12 20→192 por
  perdigón, M67 103→137. Cuchillo sin cambios. Rasgos de la tienda con la velocidad y perdigones nuevos.
- Balas por segundo de un tirador en tier 6: MP5 14,7→8, FN SCAR 13,3→9,3, SPAS-12 48→5, M67 5,3→4.

**Validated**: pJASS correcto; j reextraído igual; sólo cambian el j y el listfile; `mpq verify` correcto. SHA-256
`dcffbcdf…`. Lanzador `scripts/entrar-v16t-rpm.sh`. Laboratorio antes/después en `bench-misiles-toy-20261110`
(`entrar.sh --ritmo-antes` / `--ritmo-despues`, `-serie`). Sin comprobar: juego, sensación de las armas, multijugador.
Pendiente de decidir: escopeta más rápida (Leon lo mencionó antes de fijar la velocidad del tier 1).
Laboratorio (13/11/2026, Tested in map en el laboratorio, no en Dev Mission): tier 6 × 8 tiradores, SPAS-12 34→62 fps
(p95 47→19 ms), FN SCAR 49→57 fps, MP5 y M67 sin cambio (≈ 62). Detalle en `bench-misiles-toy-20261110/LEEME.md`.

## v16t-rapidas: asalto al ritmo del MP5 y balas al doble (13/11/2026)

Leon, tras el laboratorio de ritmo: "la rpm de scar que sea a nivel del mp5, hazlos el doble de rapido ahora, como
balas autenticas y probar como va". `scripts/rapidas_v16t.py` sobre v16t-rpm (`hacer-v16t-rapidas.sh`, sólo el j):

- Fusil de asalto 560 → 480 rpm en los seis tiers; daño por bala que conserva el daño por segundo de v16t-corto
  (FN SCAR 70 → 82, Fedorov 21 → 25).
- Velocidad ×2: subfusil 2600, asalto 3600, francotirador 4800, escopeta 3400. Misiles y granadas igual (arco).
  El choque se barre cada 8 de distancia (`GroundCollision_trace`), así que no atraviesa unidades; el trabajo de barrido
  por bala no cambia y cada bala pasa la mitad de tiempo en vuelo.

**Validated**: pJASS correcto; j reextraído igual; sólo cambian el j y el listfile; `mpq verify` correcto. SHA-256
`bbefceb2…`. Lanzador `scripts/entrar-v16t-rapidas.sh`. Laboratorio `entrar.sh --ritmo-rapidas` (`a5b6570e…`).
Laboratorio (Tested in map en el laboratorio): tier 6 × 8, FN SCAR 60,7 fps (57,4 en rpm, 48,9 en corto), balas vivas a
la mitad, misma proporción de impactos (no atraviesa); el resto ≈ 61,6 fps. Detalle en `bench-misiles-toy-20261110/LEEME.md`.
Sin comprobar en Dev Mission: juego, sensación, multijugador.

## v16z: armas de v16t-rapidas en la línea D.O.N (13/11/2026)

Leon: "vale, llevala al dev ahora". `scripts/hacer-v16z.sh` sobre v16y (`ede162a6…`): los 41 modelos de bala con
Death 0,3 s, `DEATH_TIME` 0,3, `rpm_v16t.py` y `rapidas_v16t.py`. Los datos de armas, `Arm_Bala`, el bucle de
perdigones y los 41 modelos de v16y eran iguales a los de v16t; el cambio del j de v16y → v16z es idéntico línea a
línea al de v16t → v16t-rapidas, y los modelos cortos son iguales a los de v16t-corto.

**Validated**: pJASS correcto; 823 entradas reextraídas iguales; cambian sólo el j y los 41 modelos; `mpq verify`
correcto. SHA-256 `04bd7afa…`. Lanzador `scripts/entrar-v16z.sh`. Sin comprobar: juego, multijugador.

Entrada: igual que desde v16a, `Title_Init` arranca `Tut_Begin` (tutorial) y `Tut_Entrar` pasa directo a la partida
(`Title_Begin` + `Title_Exit`); `Intro_Begin` existe pero nadie la llama, así que la intro no se ve.
Siguen pendientes las habilidades de D.O.N (disco h0AU, Burning Attack): ver secciones v16y y v16y-prueba.

## Siguiente paso

Prueba de Leon; según lo que vea, finales por choque por habilidad (como Kamehameha) y ajustes de cada héroe.

## v17a: intro, título, tutorial y partida (13/11/2026)

Leon: "que empieze con la intro completa y el tutorial antes de entrar a partida a jugar predeterminado".
Base v16z (`04bd7afa…`); sólo cambia el j (`scripts/v17a.py`, `scripts/hacer-v17a.sh`).

- Title_Init vuelve a arrancar `Intro_Begin` (intro completa: negro, modelo, canción).
- Tras el título, la selección y la presentación, `Title_Exit` limpia y lanza el tutorial una vez
  (`Tut_TrasTitulo` → `Tut_DesdeTitulo` → `Tut_Begin`). `Tut_Begin` recupera `if not Tut_Libre()`: sin hueco
  libre para el Tauren (8 jugadores) se salta.
- La apertura de la partida (tienda, cámara, `ConversationUI___Start`) pasa a `Title_Partida`; la llaman
  `Title_Exit` (si no toca tutorial) y `Tut_Entrar` al terminar el tutorial.

Mapa `TerrainDev-Titulo-v17a.w3x`, SHA-256 `a6193565fffbde59…`, 45,5 MB. Lanzador `scripts/entrar-v17a.sh`.
**Validated**: pJASS correcto, j reextraído igual, 822 entradas iguales, `mpq verify` correcto.
Sin probar en el juego ni en multijugador: el orden intro → título → tutorial → partida, la selección del
título junto con el tutorial, y la demostración de escopeta del tutorial a 1 disparo por segundo.

### v17a-tuto: entrada directa al tutorial (13/11/2026)

Leon: "dame una con entrada directa al tuto". v17a con `Title_Init` → `Tut_Begin` y `Tut_TrasTitulo= false`
(`scripts/v17a_tuto.py`, `hacer-v17a-tuto.sh`); al terminar el tutorial, `Tut_Entrar` registra a los jugadores y
abre la partida como en v16z. Mapa `TerrainDev-Titulo-v17a-tuto.w3x` `93cb0946…`, lanzador `entrar-v17a-tuto.sh`.
**Validated** (pJASS, j reextraído igual, 823 entradas iguales, `mpq verify`); sin probar en el juego.

## v16t-perfora: precisión, misil, escopeta de 3 y perforación (13/11/2026)

Leon pidió: misil algo más lento, ráfagas más precisas con una ligera imprecisión, escopeta de 3 balas con área y
modelo escalados para cubrir lo que cubrían los 5 perdigones, y perforación (escopeta tier-1; francotirador 2 + 1 por
tier; fusil de asalto 1 fijo). Base v16t-rapidas (`bbefceb2…`); `scripts/perfora_v16t.py`, `scripts/escalar_mdx.cjs`,
`scripts/hacer-v16t-perfora.sh`.

- Misiles bala 1200 → 1000. Subfusil desvío 12° → 4°. Fusil de asalto 6° → 2°, desvío creciente +0,3 hasta 4 (antes +0,8 hasta 12).
- Escopeta: 3 perdigones, ±8°, daño por perdigón ×5/3 (80, 130, 158, 223, 262, 320), radio 30 → 50. A 400 de distancia
  los tres cubren unos 210 de ancho sin huecos (antes ~200 con cinco de radio 30 en ±10°).
- Modelo: 9 copias `FirebrandShots\Grande\Firebrand Shot <color>.mdx` ×5/3 (vértices, pivotes, traslaciones, tamaño y
  velocidad de partículas, alto de estelas), porque las partículas y estelas no crecen con la escala de la unidad. Las
  originales siguen para Rapid Fire. Precarga añadida.
- Atraviesa: escopeta 0..5, fusil de asalto 1, francotirador 2..7 (ya estaba). Rasgos de la tienda actualizados.

Mapa `TerrainDev-Titulo-v16t-perfora.w3x` `d97e601f…`; lanzador `entrar-v16t-perfora.sh`. **Validated**: pJASS, 621
entradas reextraídas iguales, `mpq verify` correcto ((attributes) fuera, como en v16t-corto). Sin probar en el juego:
el tamaño visual del perdigón grande y si el abanico cubre bien de cerca.

### Estrés de v16t-perfora a 8 jugadores (preparado 13/11/2026)

Leon: "desactivemos el tutorial y probemos las armas a 8 jugadores ahora junto al sistema de interfaz como de waves como
se hizo mucho antes". `scripts/estres_v16t.py` (de estres_v16s.py): entrada directa sin tutorial, interfaz normal, oleadas
como con 8 jugadores desde la ronda 5; 10 s sin disparar y luego 8 tiradores con tier 6 de cada arma 20 s (MP5, fusil de
asalto, francotirador, escopeta, misiles, granada), COMPLETE a 130 s. Registros `lat\e16t-N.txt`, cuadros con rastreo.
Mapa `TerrainDev-Titulo-v16t-perfora-estres.w3x` `c1fedf33…` (sólo prueba), `hacer-estres-v16t-perfora.sh`,
`entrar-estres-v16t-perfora.sh`. **Validated**; resultados pendientes de la ejecución de Leon.

Resultado (13/11/2026, `estres-v16t-perfora/20261113-224031-armas`, **Tested in map**, un cliente con 7 tiradores
automáticos; juego a tiempo real en todos los tramos, 0 tandas cortadas):

| Arma (tier 6, 8 tiradores) | fps | mediana | p99 | máx. | balas vivas máx. | enemigos al final |
|---|---|---|---|---|---|---|
| MP5 | 58,1 | 16,3 ms | 30,4 | 148 (1 cuadro) | 32 | 160 |
| Fusil de asalto | 45,0 | 22,2 ms | 38,3 | 87 | 31 | 112 |
| Francotirador | 61,3 | 16,0 ms | 25,5 | 108 | 20 | 12 |
| Escopeta | 60,7 | 16,3 ms | 30,0 | 102 | 24 | 1 |
| Misiles | 61,5 | 16,1 ms | 25,4 | 86 | 10 | 65 |
| Granada | 60,6 | 15,6 ms | 28,2 | 107 | 31 | 31 |

Límite: francotirador y escopeta casi sin enemigos (la oleada bajó a 12 y a 1), así que no se midieron con carga.
Referencia: v16q con 8 MP5 daba 41 fps.

Repetición con orden escopeta, francotirador, fusil de asalto, MP5, misiles, granada (`estres_v16t.py ... 6 4,3,2,1,0,6`):
`TerrainDev-Titulo-v16t-perfora-estres2.w3x` `636a38cb…`, `hacer-/entrar-estres2-v16t-perfora.sh`. **Validated**; pendiente de ejecutar.

Resultado de la repetición (13/11/2026, `estres-v16t-perfora/20261113-225002-orden2`, **Tested in map**, un cliente; a
tiempo real, 0 tandas cortadas, ningún cuadro > 100 ms):

| Arma (tier 6, 8 tiradores) | fps | mediana | p99 | máx. | balas vivas máx. | enemigos al final |
|---|---|---|---|---|---|---|
| Escopeta | 58,0 | 16,6 ms | 39,5 | 66 | 24 | 181 |
| Francotirador | 59,8 | 16,8 ms | 29,5 | 68 | 8 | 115 |
| Fusil de asalto | 45,4 | 21,7 ms | 40,0 | 67 | 26 | 10 |
| MP5 | 59,0 | 16,3 ms | 31,4 | 67 | 26 | 1 |
| Misiles | 61,4 | 16,2 ms | 25,5 | 65 | 26 | 74 |
| Granada | 60,1 | 16,4 ms | 29,5 | 90 | 32 | 22 |

El fusil de asalto vuelve a dar ~45 fps aunque la oleada baje a 10: su coste no viene de los enemigos. Frente al MP5
(mismo ritmo, mismos enums/s) cambian alcance 1100 vs 700, bala 3600 vs 2600 y el modelo (Daemonic Arrow vs Shot II).
Sospecha sin comprobar: el dibujo del Daemonic Arrow. Siguiente: aislar modelo y alcance en el laboratorio.

Prueba del modelo: fusil de asalto con Shot II del subfusil (`scripts/scar_shot2.py`), orden fusil de asalto, MP5,
escopeta, francotirador, misiles, granada. `TerrainDev-Titulo-v16t-perfora-estres3.w3x` `044a0aac…`,
`hacer-/entrar-estres3-v16t-perfora.sh`. **Validated**; pendiente de ejecutar.

Resultado (13/11/2026, `estres-v16t-perfora/20261113-225704-scar-shot2`, **Tested in map**, un cliente): fusil de asalto
con Shot II 56,1 fps (mediana 17,4 ms, p99 33, máx. 68; oleada 168) frente a 45 con Daemonic Arrow; MP5 justo después,
también con oleada llena, 53,5 fps. Escopeta 58,4, francotirador 60,9, misiles 61,4, granada 60,0; 0 tandas cortadas.
Conclusión: la mayor parte del coste del fusil de asalto era el dibujo del Daemonic Arrow; con el mismo modelo queda a la
par del MP5. El MP5 baja a ~54 cuando hay muchos enemigos (antes se midió con la oleada casi vacía).

## v16t-shots: MP5 con Shot vol. 1, fusil de asalto con Shot II (13/11/2026)

Leon: "si colocamos ahora la mp5 con balas del shot vol 1 y la scar ya se queda con el shot vol 2". `scripts/shots_v16t.py`
sobre v16t-perfora: subfusil `ShotsAjustados\Shot <color>.mdx` (radio de choque 18 como antes), fusil de asalto Shot II
(radio 18; antes Daemonic Arrow 15); francotirador sigue con Daemonic Arrow; precarga de Shot Yellow/Purple/Red.
`TerrainDev-Titulo-v16t-shots.w3x` `688e6bbe…`, `hacer-v16t-shots.sh`. **Validated** (pJASS, j reextraído, verify).

Balas teóricas (tier 6; el ritmo es igual en todos los tiers): MP5 y fusil de asalto 8/s (12 en 1,5 s), francotirador
1/s, escopeta 3/s (3 perdigones), misiles 1,25/s, granada 4/s; ×8 tiradores: 64, 64, 8, 24, 10, 32 por segundo.
Estrés con contador de balas (`estres_v16t.py` cuenta cada Arm_Tiro; `analizar_estres_v16t.py` da la tabla):
`TerrainDev-Titulo-v16t-shots-estres.w3x` `cf636c02…`, `hacer-/entrar-estres-v16t-shots.sh`. Pendiente de ejecutar.

## Prueba de oleadas (13/11/2026, sólo prueba, no se entrega)

Leon: "prepara tus pruebas evaluativas para wave, si se logra detectar algo mal hecho o repitiendose constantemente".

Revisión del código (**Scanned**, `v16t-shots/war3map.j`):
- `ConversationUI___Tick` corre a 0,01 s (100 Hz) toda la partida y nunca se pausa: cámara que sigue al héroe (bucle de
  12 jugadores), barras y HUD completo por jugador (Ronda_Hud, Racha_Hud, Arm_Hud, DevJefe_Poner, DevTienda_Hud) y
  `s__Interface_updateAll`. Es el trabajo repetido más caro por frecuencia; casi todo podría ir a 0,03-0,05 s.
- Cada orden de cualquier unidad (la IA da muchas) dispara dos disparadores globales de ISSUED_ORDER: UnitDex (salida
  por orden 852056) y `AbilitySilence_OnSilence`. Su condición es barata, pero el evento se cuenta por orden.
- Otros relojes siempre activos: Racha 0,05; Barras_Heroes 0,03; Arm_Latido 0,05; DevJefe_Mirar 0,03;
  DevTienda_Latido 0,03; Tx_Tick 0,03; Bat_Paso 0,10 (Luz_Ajustar ×12); Ronda, MissileStats y RecycleBin 1 s;
  Cadaver 0,5. Barras_Enemigos se pausa sola.
- WaveAI: reloj 0,10 s, cada unidad piensa cada 0,5 s (presupuesto ≤128), RefreshTargets cada tick, reorden de ataque
  cada 20 ticks si está a más de 500.

Prueba (`scripts/oleadas_v16t.py`, `hacer-oleadas-v16t.sh`, `entrar-oleadas-v16t.sh`, `analizar_oleadas_v16t.py`):
ronda 9 con 8 jugadores (límite 240), enemigos invulnerables con vida llena (población fija, sin élites), 30 s de
llenado y 14 tramos de 15 s, dos vueltas de 7 modos: 0 normal; 1 sin interfaz (reloj 100 Hz parado); 2 sin IA; 3
enemigos en pausa y sin IA; 4 sin interfaz y cámara lejos; 5 8 tiradores MP5; 6 8 tiradores sin IA. Registros
`lat\olas-N.txt` con piensa, ataques, esperas, reobjetivo, órdenes (eventos de orden contados en AbilitySilence) y balas.
Mapa `TerrainDev-Titulo-v16t-shots-oleadas.w3x` `6fd6706c…` (**Validated**: pJASS, reextracción, mpq verify).
Pendiente de ejecutar.

Resultado (13/11/2026, `oleadas-v16t/20261113-234621-oleadas`, **Tested in map**, 1 cliente, COMPLETE, 240 enemigos
todo el rato, fps topados a ~62):
- Tramo 1 normal: 62,0 fps, CPU hilo 58 %, IA 490 piensa/s y 73 ataques/s. Tramo 2 sin interfaz: 61,9 fps, 61 %.
  Tramo 3 sin IA: 61,9 fps, 62 %. Ni el reloj de 100 Hz ni la IA dan una diferencia medible.
- Enemigos en pausa: 43 % / 36 % (movimiento y búsqueda de camino ≈ 15-20 puntos). Cámara lejos: 19 % / 16 %
  (dibujar 240 enemigos ≈ 40 puntos, el coste mayor).
- 8 tiradores MP5 (58 balas/s): 51-54 fps, 75-77 %, p99 33-37 ms. Las balas son la carga que baja fps.
- **Fallo de la prueba:** tras PauseTimer + ResumeTimer el reloj periódico de WaveAI dejó de repetirse (98 piensa por
  tramo en lugar de 7350); probablemente también el de ConversationUI desde el tramo 2. Los tramos 3-14 corren sin
  IA (y quizá sin interfaz). Valen los tramos 1 y 2 y la comparación de pausa/cámara. Para repetir: TimerStart de
  nuevo en lugar de ResumeTimer.
- Corrección del hallazgo de órdenes: EVENT_PLAYER_UNIT_ISSUED_ORDER sólo salta con órdenes sin objetivo (1-2/s; 240
  al pausar). Las órdenes de ataque de la IA son de punto y llegan a `s__RapidPair_pointOrder`, que sale tras una
  consulta de tabla para unidades que no son pareja. Coste despreciable.

Repetición (13/11/2026): `scripts/oleadas2_v16t.py` (relojes con TimerStart en cada tramo; «ordenes» cuenta también
las órdenes de punto en `s__RapidPair_pointOrder`), `hacer-/entrar-oleadas2-v16t.sh`, mapa
`TerrainDev-Titulo-v16t-shots-oleadas2.w3x` `82196018…` (**Validated**). Pendiente de ejecutar.

Tick de interfaz (Scanned): a 100 Hz, por jugador, `Ronda_Hud` y `Arm_Hud` arman y escriben sus textos con
SetTextTagText aunque no cambien («Wave »+I2S, munición I2S/I2S, «Recargando »+R2SW con décimas), y el porcentaje de
vida I2S+"%". Cada cadena distinta queda en la tabla de cadenas. Propuesta acordada con Leon: 0,01 s sólo para
posición (cámara, Place, setPosition, ShowUnit); textos sólo cuando cambia el valor; lógica a 0,05-0,1 s.

Resultado de la repetición (14/11/2026, `oleadas-v16t/20261114-000028-oleadas2`, **Tested in map**, COMPLETE; la IA
piensa 490/s en todos los tramos con IA, los relojes ya no se quedan parados):
- Sin disparos: normal 61,4 fps / 60 %; sin interfaz 61,6 / 63 %; sin IA 61,4 / 64 %; enemigos en pausa 62,2 / 45 %;
  cámara lejos 62,3 / 21 %. Sin tiradores, ni interfaz ni IA cambian algo medible; el motor (dibujo ≈ 40 puntos,
  movimiento ≈ 15) sí.
- 8 tiradores MP5: 42,6 fps / 81 % (p99 38-40 ms); sin IA 44,0. En la primera prueba, con la IA y probablemente la
  interfaz paradas por ResumeTimer, los mismos tramos daban 51-54 fps. Como sin IA aquí sigue en 44, la diferencia
  apunta a la interfaz de 100 Hz con 8 jugadores disparando (Arm_Hud reescribe munición y recarga cada tick). Es una
  inferencia entre dos ejecuciones; falta un tramo «tiradores sin interfaz» para confirmarlo.
- Las órdenes de ataque de la IA (72/s) no llegan a ISSUED_ORDER ni a ISSUED_POINT_ORDER (órdenes 3/s sin tiradores):
  son órdenes con objetivo y no tienen disparadores globales. Los ~50/s con tiradores son órdenes de punto de RapidPair.

## v16t-relojes y prueba de carga (14/11/2026)

Leon: "hagamoz la mejora de relojes, adicional el lag con los missiles, mediras con un jugador hasta con 8 … y otro
tambien las unidades maximas en el mapa".

Corrección de la nota anterior: Ronda_Hud y Arm_Hud ya escribían sus textos sólo al cambiar (comparan con lo último
mostrado). Lo que sí se repetía en cada tick de 0,01 s, por jugador: unas 17 llamadas a ShowUnit y unas 8 a
SetTextTagVisibility aunque nada cambiara, armar los textos de ronda y medir la distancia a 20 zonas de munición y al
golem para el aviso.

v16t-relojes (`scripts/relojes_v16t.py`, `hacer-/entrar-v16t-relojes.sh`), sobre v16t-shots:
- `Hud_Ver`: ShowUnit sólo si cambia (IsUnitHidden), en barras, iconos, arma, blindaje, batería y tarjetas de racha.
- `UIText.show` (y su copia de .evaluate): SetTextTagVisibility sólo al cambiar.
- Ronda_Hud y el aviso de DevTienda_Hud a 0,05 s (`HealthBars__Lento`, el sondeo que ya usaba la vida).
- Siguen a 0,01 s: cámara, Place/setPosition/UIText_updateAll, indicadores de borde, animación de la racha.
- `TerrainDev-Titulo-v16t-relojes.w3x` `06995f1e…` (**Validated**; sin registros).

Prueba de carga (`scripts/carga_v16t.py`, `hacer-carga-v16t.sh`, `entrar-carga-v16t-shots.sh` y `-relojes.sh`,
`analizar_carga_v16t.py ANTES DESPUÉS`): ronda 9, límite por escalones 60/120/180/240 con enemigos que no mueren;
por escalón 12 s de llenado y 9 tramos de 10 s con 0-8 tiradores MP5 tier 6. Mapas `v16t-shots-carga` `834872b1…` y
`v16t-relojes-carga` `2f8690b0…` (**Validated**). Pendiente de ejecutar.

Resultado antes (v16t-shots, `carga-v16t/20261114-002343-shots`, **Tested in map**, COMPLETE, poblaciones exactas):
fps con 0/4/8 tiradores — 60 enemigos 62/62/60; 120: 62/61/55; 180: 62/56/48; 240: 62/46/41 (p99 39 ms, CPU 81 %).
Con 240 baja ya con 1 tirador (57); con 180 desde 3-4; con 120 desde 6; con 60 sólo con 8. Falta la de v16t-relojes.

Resultado después (v16t-relojes, `carga-v16t/20261114-003413-relojes`, **Tested in map**, COMPLETE): igual que antes
dentro de ±2,4 fps en las 36 casillas (240 con 8 tiradores: 39 frente a 41; 180: 49 frente a 48). Los relojes de la
interfaz no eran la causa; la deducción entre las dos pruebas de oleadas queda descartada. El coste crece con
enemigos × balas (CPU del hilo hasta 81 %): candidatos, el choque de cada bala (barrido cada 8 de distancia con
enumeración de unidades cercanas) y el impacto/daño. Siguiente: medir eso por partes. Límite de unidades propuesto
para 8 jugadores: 120-150 en lugar de 240.

Prueba de balas por partes (14/11/2026; `scripts/balas_v16t.py`, `hacer-/entrar-balas-v16t.sh`,
`analizar_balas_v16t.py`) sobre v16t-relojes: 120 y luego 240 enemigos que no mueren, 12 s de llenado y 2 vueltas de
6 modos de 10 s: nadie dispara; 8 MP5 normal; sin colisión (resolve sale al empezar); sin modelo; sin Barras_Golpe;
sin UnitDamageTarget ni Barras_Golpe. Los enemigos son invulnerables: la prueba no incluye muertes. Mapa
`TerrainDev-Titulo-v16t-relojes-balas.w3x` `cfdc7fb7…` (**Validated**). Pendiente de ejecutar.

Resultado (14/11/2026, `balas-v16t/20261114-005052-balas`, **Tested in map**, COMPLETE). Media de 2 vueltas, fps:
- 120 enemigos: nadie 62,2; normal 57,7; sin colisión 58,4; sin modelo 58,6; sin barras 55,3; sin daño ni barras 55,8.
- 240 enemigos: nadie 62,2; normal 51,3; sin colisión 50,2; sin modelo 55,1; sin barras 54,2; sin daño ni barras 55,9.
- La misma casilla cambia mucho entre vueltas (240 normal: 47,5 y 55,2; la primera justo tras llenar, con los enemigos
  aún llegando). Ruido de ±4 fps.
- Sin colisión no mejora (balas vivas 28-40 frente a 7-9): la búsqueda de unidades por bala no es el coste. El modelo
  da +1 a +4. Barras y daño quedan dentro del ruido.
- Lo que sí escala con enemigos × tiradores y no se apagó: el apuntado de la prueba (`Est_Disparar`, cada 0,25 s por
  tirador, enumera 1100 de radio y prueba cada enemigo: hasta ~7700 comprobaciones/s con 240) y el movimiento de los
  enemigos que se apiñan alrededor de los héroes. Siguiente: medir con apuntado fijo y con enemigos en pausa.

Prueba de apuntado fijo y pausa (14/11/2026; `scripts/fijo_v16t.py`, `hacer-/entrar-fijo-v16t.sh`,
`analizar_fijo_v16t.py`) sobre v16t-relojes: 120 y 240 enemigos, 2 vueltas de 6 modos de 10 s: nadie dispara; 8 MP5
con apuntado normal; con apuntado fijo (p × 45°, sin enumerar); enemigos en pausa con apuntado normal; en pausa con
apuntado fijo; en pausa sin disparos. Mapa `TerrainDev-Titulo-v16t-relojes-fijo.w3x` `d047d305…` (**Validated**).
Pendiente de ejecutar.

Resultado (14/11/2026, `fijo-v16t/20261114-010050-fijo`, **Tested in map**, COMPLETE). Media de 2 vueltas, fps:
- 120: nadie 61,5; normal 54,7; apuntado fijo 54,5; pausa+normal 59,0; pausa+fijo 59,7; pausa sin disparos 62,1.
- 240: nadie 61,5; normal 43,2; apuntado fijo 41,2; pausa+normal 54,2; pausa+fijo 54,4; pausa sin disparos 62,2.
- El apuntado del bot no es la causa: las mediciones anteriores valen.
- Con 240, de los ~18 fps que se pierden al disparar, ~11 vuelven al pausar a los enemigos y ~7 son de las balas
  mismas. Sin disparos, que los enemigos se muevan no cuesta fps. Sin explicar todavía: por qué el movimiento de los
  enemigos cuesta más mientras se dispara (candidatos: colisión de las unidades bala con la multitud, reacción del
  motor al ser atacados).

## Investigación en foros (14/11/2026): enemigos en movimiento + balas

Pedido de Leon: "si, investiga en la web foros rusos chinos u otros". Fuentes: Hive Workshop (varios hilos), sc2mapster,
xgm.guru (ruso) y búsquedas en chino (sin resultados concretos).

Contraste con el código de v16t-relojes:
- Límite de órdenes de movimiento por jugador (Hive, "improving movement performance"): repartir enemigos entre más
  dueños. Las oleadas ya usan 6 dueños (`WAVE_DEFAULT_OWNER_MIN` 8 .. `MAX` 13): ya aplicado.
- Reciclar y precargar dummies: el disparo usa `GetRecycledMissile` (MissileRecycler): ya aplicado.
- SetUnitPosition caro: el Missile mueve con SetUnitX/Y (WorldBounds presente): ya aplicado.
- Crear efectos por disparo: `s__Missile__set_model` adjunta un efecto nuevo en cada bala (más `Bala_Boca` con
  2 `Bala_Libre` y set_scale/arc). Candidato a medir: es coste por disparo, no por vuelo.
- Tamaño de colisión de unidades: evidencia débil y contradictoria en foros; no se prioriza.
- Muchos eventos por disparo/daño (sc2mapster): coherente con que el coste sea por disparo (Arm_Impacto, Barras_Golpe).

Conclusión: no hay interacción oculta enemigo-bala; son costes que se suman en el hilo principal (~82 % satura).
Las recomendaciones conocidas de los foros ya están aplicadas salvo el efecto adjunto por bala. Próximo paso posible:
medir el lanzamiento por partes (sin efecto adjunto / sin Bala_Boca / sin animación ni sonido) y aplicar tope 120-150.

## Prueba del disparo por partes (14/11/2026): resultado

Mapa `TerrainDev-Titulo-v16t-relojes-disparo.w3x` `3a57b6be…` (disparo_v16t.py sobre estres de v16t-relojes, MP5 tier 6,
8 tiradores, 240 enemigos invulnerables). Corrida `disparo-v16t/20261114-013555-disparo`, COMPLETE. Tested in map, 1 cliente.
Media de 3 vueltas (la 1.ª vuelta salió más alta en todos los modos; ruido ±4 fps):

| Modo | fps | dif. con normal | CPU hilo |
|---|---|---|---|
| 0 nadie dispara | 61.1 | +15.8 | 58 % |
| 1 normal | 45.4 | 0 | 77 % |
| 2 sin boca | 44.3 | -1.1 | 80 % |
| 3 sin modelo | 47.3 | +1.9 | 78 % |
| 4 sin animación | 42.2 | -3.1 | 81 % |
| 5 sin bala (orden, ritmo y animación sí; ningún Missile) | 58.4 | +13.0 | 71 % |
| 6 sin modelo ni colisión (40 vivas en vez de 8) | 44.8 | -0.6 | 75 % |

Lectura: la orden, el ritmo y la animación del tirador cuestan poco (modo 5 casi igual a nadie). La boca, el modelo,
la animación y la colisión no explican la caída. Con 5 veces más balas en vuelo (modo 6) el coste es el mismo: lo que
cuesta es **crear y quitar cada bala**.

Causa en el código: desde v13g (`scripts/v13g.py`, intencional, "sin reciclar dummies") `MissileRecycler___Init` no
precarga ninguna unidad y `queueStackN` empieza en 0. Así `GetRecycledMissile` siempre hace `CreateUnit` + `PauseUnit`
y `RecycleMissile` siempre toma la salida de `UnitApplyTimedLife` (0,3 s). Con 8 MP5 son ~60 unidades creadas y
muertas por segundo. Coincide con el laboratorio de misiles (10 562 dummies nuevos y 0 reutilizados) y con los foros
(reciclar y precargar dummies).

Siguiente paso propuesto: misma prueba con la reserva restaurada (precarga del código original, 8 sectores × 12, y una
variante más grande, p. ej. 8 × 32), y comparar normal / reserva 12 / reserva 32. Falta saber por qué se quitó en v13g.

## Prueba de la reserva del reciclador (14/11/2026): preparada

Leon: "nos hace falta configurar bien las reservas entonces" (recuerda haber pedido quitar el reciclador en v13g).
`reserva_v16t.py` recupera la precarga original de `MissileRecycler___Init` (bloque de v13e) con `ANG_STORAGE_MAX` = cupo;
DEATH_TIME sigue en 0,3. Tres mapas sobre v16t-relojes (estrés MP5 tier 6, 240 enemigos, 4 modos × 3 vueltas: nadie,
apuntado normal, cada tirador en su dirección, todos a la misma dirección), registro con unidades nuevas y reutilizadas:
- `v16t-relojes-res0` `453eca8a…` (como ahora), `res12` `9c48a7f7…` (96), `res32` `7a50f3e5…` (256). Validated.
Scripts `hacer-/entrar-reserva-v16t.sh`, `analizar_reserva_v16t.py CARPETA`.

### Resultado (14/11/2026), corrida `reserva-v16t/20261114-015856`, Tested in map, 1 cliente

res0 y res12 con 3 vueltas (COMPLETE); res32 cerrada tras 2 vueltas (la 3.ª partida no arrancó la primera vez: Wine
seguía cerrando la anterior, `Failed to execute L"cmd", ret 11`; el lanzador ahora espera a wineserver hasta 30 s y
admite `entrar-reserva-v16t.sh 32 CARPETA`). Media de fps con 240 enemigos y 8 MP5 (~63 balas/s):

| Modo | sin reserva | 96 (8 × 12) | 256 (8 × 32) |
|---|---|---|---|
| nadie dispara | 60.2 | 60.9 | 61.0 |
| apuntado normal | 43.2 | 49.3 | 53.5 |
| cada uno en su dirección | 39.9 | 50.1 | 51.3 |
| todos a la misma dirección | 38.8 | 48.3 | 53.8 |

Unidades de bala nuevas por tramo de 10 s: sin reserva 518–632 (todas); 96: 0–2, pero 56–94 cuando todos disparan hacia
el mismo lado (se agota ese sector); 256: 0 en todos los modos. Propuesta: reserva 8 × 32 en la línea normal.

## v16t-reserva (14/11/2026): reserva de 256 balas en el mapa normal

Leon: "Sí, aplicarla". Base v16t-relojes (`06995f1e…`). `scripts/reserva32.py` recupera la precarga de
`MissileRecycler___Init` (bloque de v13e) y el configure de MissileStats, y sube `ANG_STORAGE_MAX` de 12 a 32
(8 × 32 = 256 unidades de bala precargadas). DEATH_TIME sigue en 0,3. Sólo cambian war3map.j y (attributes); sin registros.
- `TerrainDev-Titulo-v16t-reserva.w3x` `a16fd945…`. Validated (pJASS, reextracción igual, mpq verify).
- Scripts `hacer-v16t-reserva.sh`, `entrar-v16t-reserva.sh`.
- Medido en la prueba reserva-v16t (mismo cambio sobre el estrés), no en este mapa jugado. Pendiente: que Leon lo juegue;
  llevarlo a la línea v17a (también DEATH_TIME 0,3 y sin reserva) cuando lo pida.

## Prueba de las armas de antes con reserva (14/11/2026): preparada

Leon: "podemos probar las anteriores, la escopeta si esta bien tal como esta ahora su fix con solo 3 perdigones mas ser
mas grandes". `scripts/armas_antes.py` devuelve Int, Dano y Vel de v16t-corto a subfusil, fusil de asalto, francotirador
y granada (MP5 880 rpm bala 1800; SCAR 800 rpm bala 2400); escopeta y misiles como ahora; Disp y Perfora como ahora.
Prueba `armas_prueba_v16t.py` sobre v16t-reserva con reserva 8 × 64 = 512; 120/180/240 enemigos; nadie, MP5, SCAR y MP5
todos al mismo lado, 2 vueltas. Mapa `v16t-reserva-armas` `0405f8b1…` (Validated). Scripts `hacer-/entrar-armas-v16t.sh`,
`analizar_armas_v16t.py CARPETA`.

### Resultado (14/11/2026), corrida `armas-v16t/20261114-024635-armas`, COMPLETE, Tested in map, 1 cliente

Reserva 512: 0 unidades nuevas en todos los tramos (alcanza). Media de fps, 8 tiradores tier 6 disparando sin parar:

| Enemigos | nadie | MP5 de antes (114 balas/s) | SCAR de antes (105/s) | MP5 al mismo lado |
|---|---|---|---|---|
| 120 | 62.2 | 52.4 | 50.4 | 49.4 |
| 180 | 61.4 | 42.1 | 40.3 | 40.3 |
| 240 | 56.4 | 33.6 | 30.9 | 32.7 |

Referencia con las armas de ahora (63 balas/s) y reserva 256, 240 enemigos: 53.5. Las armas de antes cuestan casi el
doble por el número de balas; con 120 enemigos quedan en ~50 fps (peor caso: 8 jugadores con la misma arma de ritmo alto
disparando sin parar). Decisión pendiente de Leon: ritmo intermedio, tope de enemigos o aceptar ~50 fps.

## Prueba de cámara lejos y armas solas (14/11/2026): preparada

Leon: "toma una arma y ejecutala, luego lleva la camara a otro lado del mapa ... tambien probemos las armas solas sin
oleadas subiendo de 1 a 8 jugadores". `camara_v16t.py` sobre v16t-reserva + armas de antes + reserva 512. Fase 1: 120
enemigos, MP5 de antes, nadie/8 tiradores con cámara en el héroe o lejos (FollowCamera centrada en una esquina).
Fase 2: enemigos quitados con RemoveUnit y sin apariciones; 1-8 tiradores MP5 y 1-8 SCAR. Mapa `v16t-reserva-camara`
`ffc98f78…` (Validated). Scripts `hacer-/entrar-camara-v16t.sh`, `analizar_camara_v16t.py CARPETA`.
- 1.ª corrida (`camara-v16t/20261114-030029-camara`): el juego se cerró poco después de pasar a cámara lejos (modo 2).
  El punto salió de los límites de cámara de ese momento: (-6440, -10920), fuera del área jugable (Y desde -7296); la
  interfaz coloca piezas alrededor de la cámara (ConversationUI___ProjectFrame con SetUnitX/Y). Fallo del guion de
  prueba, no del mapa normal. Corregido: punto en el mínimo del área jugable + 1500. Mapa nuevo `d8a83bc5…`.

### Resultado cámara y armas solas (14/11/2026), corrida `camara-v16t/20261114-030252-camara`, COMPLETE, Tested in map

Fase 1, 120 enemigos, 8 MP5 de antes (114 balas/s), media de 2 vueltas:

| Modo | fps | CPU hilo |
|---|---|---|
| nadie, cámara en el héroe | 59.6 | 56 % |
| 8 MP5, cámara en el héroe | 39.9 | 80 % |
| nadie, cámara lejos | 62.0 | 22 % |
| 8 MP5, cámara lejos | 61.5 | 34 % |

Fase 2, sin enemigos, cámara en el héroe (fps / CPU): 0 tiradores 62.0 / 36 %; MP5 1-5 ≥ 60.2 (hasta 60 %), 6 57.4,
7 56.2, 8 53.7 (69 %); SCAR 1-5 ≥ 60.9, 6 59.2, 7 58.4, 8 56.0 (70 %).

Lectura: con la cámara lejos, todo el cálculo (8 MP5 + 120 enemigos moviéndose y recibiendo golpes) cuesta ~12 puntos
y el juego va a 61.5. El resto (~45 puntos) es **dibujar** lo que ve la cámara: enemigos, balas y lo que muestran al
recibir golpes. Cada cliente dibuja sólo su cámara; el peor caso es tener a los 8 juntos y los enemigos en pantalla.
Medido con Proton/DXVK en esta PC: el coste de dibujo puede variar en Windows nativo. Sin enemigos, las armas de antes
van a ≥ 60 fps hasta 5 tiradores juntos.

### Prueba de dibujo de la bala (14/11/2026), preparada

Leon: "date ese test haber como va" (qué parte de la bala cuesta dibujar). `dibujo_v16t.py` sobre el j de
`camara_v16t.py` (v16t-reserva, armas de antes, reserva 512): 120 enemigos que no mueren, 8 MP5 de antes, cámara en el
héroe; modos de 10 s × 2 vueltas: 0 nadie, 1 normal, 2 sin inclinar (SetUnitAnimationByIndex), 3 sin inclinar ni girar
(SetUnitFacing), 4 sin barras al golpear (Barras_Golpe, texttags), 5 bala sin modelo, 6 todo quitado. Dos mapas:
`v16t-reserva-dib` `79942b02…` (dummy normal) y `v16t-reserva-dibp` `b4b4d57e…` (dummy.mdx sin la rotación de
Bone_Chest, `dummy_plano.py`; también lo usa dcst). Validated (pJASS, reextracción, mpq verify). Lanzador
`entrar-dibujo-v16t.sh`, análisis `analizar_dibujo_v16t.py`.

### Resultado prueba de dibujo (14/11/2026), corrida `dibujo-v16t/20261114-032830`, las dos COMPLETE, Tested in map

120 enemigos, 8 MP5 de antes (114 balas/s, ~10 vivas a la vez porque chocan cerca), cámara en el héroe; media de 2 vueltas:

| Modo | dummy normal fps / CPU | dummy plano fps / CPU |
|---|---|---|
| 0 nadie | 62.2 / 41 % | 62.2 / 41 % |
| 1 normal | 54.2 / 72 % | 54.5 / 71 % |
| 2 sin inclinar | 52.0 / 74 % | 53.7 / 74 % |
| 3 sin inclinar ni girar | 51.9 / 76 % | 51.8 / 76 % |
| 4 sin barras al golpear | 52.1 / 76 % | 51.6 / 75 % |
| 5 bala sin modelo | 60.8 / 63 % | 60.6 / 62 % |
| 6 todo quitado | 61.3 / 61 % | 60.9 / 60 % |

Lectura: el hueso del dummy, la inclinación, el giro y las barras no cuestan (diferencias dentro del ruido de ±2 entre
vueltas). Lo que cuesta es el **modelo de la bala**: sin él vuelve a ~61. Shot (MP5) tiene 4 emisores de partículas
(Stars, Lumps, F1, A Uno) y secuencias Birth/Death; a 114 balas/s se crean y mueren 114 modelos con partículas por
segundo. En la prueba de disparo (240 enemigos) quitar el modelo daba sólo +2: allí pesaban más los enemigos.
Siguiente posible: versión ligera del modelo de bala (menos emisores/partículas) y medirla igual.

### Bala Toy y versiones ligeras (14/11/2026), preparada

Leon: "la bala del toy? evalua su composicion o lo puedes hacer mas ligero aun"; la idea es una opción para ver las
balas de los demás con un modelo muy ligero (y otra, extrema, también las propias).
Composición: Shot (MP5 actual) = geoset de 28 vértices + F1 a 24 partículas/s en vuelo + 3 emisores a 120/s al morir.
Toy `Bullet2.mdx` (Toy Soldiers, `toysoldiers_156 - Open.w3x`, vía laboratorio bench-misiles-toy) = 2 cuadrados
(trazo 185 × 3,4 y brillo 255 × 33) que miran a la cámara, sin partículas en vuelo; 2 emisores sólo al morir
(~9 partículas). `bala_ligera.py`: ligera1 = sin emisores; ligera2 = sin emisores y sólo el brillo (1 cuadrado).
Mapa `v16t-reserva-lig` `bbe245fe…` (ligera_v16t.py: 0 nadie, 1 Shot, 2 Toy, 3 ligera1, 4 ligera2, 5 sin modelo;
120 enemigos, 8 MP5, cámara en el héroe). Validated. Lanzador `entrar-ligera-v16t.sh`; análisis
`analizar_dibujo_v16t.py CARPETA lig`. Modelos ligeros sin revisar en visor 3D: se ven en la propia prueba.

### Resultado bala ligera (14/11/2026), corrida `ligera-v16t/20261114-034603`, COMPLETE, Tested in map

120 enemigos, 8 MP5 de antes (114 balas/s), cámara en el héroe, media de 2 vueltas (fps / CPU hilo): nadie 62.2 / 42 %;
Shot actual 55.6 / 72 %; Toy Bullet2 60.4 / 67 %; ligera1 60.7 / 64 %; ligera2 60.7 / 64 %; sin modelo 61.0 / 62 %.
Lectura: la bala Toy ya queda a ~0,6 fps de "sin modelo"; las ligeras sólo ahorran un poco de CPU (3 puntos), dentro
del ruido en fps. Para la opción de "balas ajenas ligeras" basta Toy o ligera1 (sin el estallido al morir).

## v17b (14/11/2026): balas ligeras con -bl y ritmo −25 %, Validated

Leon: "implementa la ligera … de momento se activara con un comando corto … del tier 1 al 6 se aligerara los rps".
Respuestas: −25 % en todos los tiers, mismo daño por segundo, base v17a + reserva + armas de antes.
- Base v17a `a6193565…`; j = perfora_v16t → shots_v16t → relojes_v16t → reserva32 (v13e) → armas_antes (v16t-corto)
  → `v17b.py`. Modelos: 9 `FirebrandShots\Grande\…` de v16t-reserva y 24 `BalaLigera\<Sub|Fus|Fra|Esc>_<color>.mdx`
  (`bala_ligera_tier.py` sobre ligera1 = Toy Bullet2 sin emisores; textura GenericGlow64 teñida por GEOA con el color
  del tier; largo/ancho por arma: Sub 110×12, Fus 217×36, Fra 300×50, Esc 400×90).
- Ritmo: subfusil 8,0–14,7 → 6,0–11,0 rps; fusil 9,3–13,3 → 7,0–10,0; granada 4,0–5,3 → 3,0–4,0; daño por bala /0,75
  (mismo daño/s). Tienda y tutorial muestran "N rps". Francotirador, escopeta y misiles sin cambio de ritmo.
- `-bl` alterna 0 → 1 → 2; `-bl N` fija: 0 normales, 1 las de los demás ligeras, 2 todas ligeras. Sólo cambia la ruta
  del modelo elegida en cada cliente (ambas cadenas se calculan en todos). Misiles y granadas no tienen versión ligera.
- Mapa `TerrainDev-Titulo-v17b.w3x` `50e7a9ba…`; `hacer-v17b.sh` (pJASS correcto, reextracción del j y de los 33
  modelos idéntica, mpq verify ok). Lanzador `entrar-v17b.sh`.
- Pendiente: jugarlo (Tested in map), LAN de dos clientes para `-bl` (toca GetLocalPlayer), revisar las balas ligeras
  en el juego (no vistas en visor 3D). Créditos: modelo base Bullet2 de Toy Soldiers.

## v17c (14/11/2026): v17b con entrada directa, Validated

Leon: "inicia directo al mapa, con intro y tutoriak desactivados". `v17c.py` vuelve al arranque de v16t: Title_Init →
Tut_Begin (salta el tutorial) → Tut_Entrar → Title_Begin + Title_Exit → Title_Partida; `Tut_TrasTitulo` en false.
Mapa `TerrainDev-Titulo-v17c.w3x` `24538466…` (sólo cambia el j; pJASS correcto, reextracción idéntica, mpq verify ok).
`hacer-v17c.sh`, `entrar-v17c.sh`. Pendiente: jugarlo.

## Sonidos de armas, impactos, truenos y cajas (14/11/2026), en preparación

Pedidos de Leon:
- Sonido al disparar (escopeta con disparo + bombeo), impactos, 3D, bucle adaptado al ritmo.
- "los rayos que estan con el sistema de tormenta, subemos mas su audio, se escucha muy poco y hasta se tapa con la
  musica": Storm usa `StormT1-3.wav` (PCM 8 bits, picos breves y poco cuerpo) ya a volumen 102–127 en canal 10; hay
  que subir el propio archivo (compresión) o cambiarlo, y quizá bajar la música durante el trueno.
- "en las cajas verdes debera sonar un sonido de recarga y mas fuerte": `Recarga_Tomar` llama hoy a `UI_Click(p)`.
Fuentes de sonido:
- The Free Firearm Sound Library (CC0): usada en las muestras 1 y 2 y mandada a la papelera el 14/11/2026 a petición de
  Leon (`gio trash fuentes/free-firearm-sfx`, 518 MB); sus scripts `sonidos_muestra*.py`/`sonidos_tomas.py` quedan
  sin datos.
- Fuente elegida: carpeta de Leon `~/Descargas/AudioClip` (624 clips de un juego Unity, Slendytubbies; Leon indica que
  no son comerciales y los tiene en buen estado). Sólo lectura; la música no se usa. Muestra 3 (`sonidos_audioclip.py`)
  y muestra 4 (`sonidos_muestra4.py` → `fuentes/audioclip/muestra4-audioclip.wav`, 139 s, orden en
  `muestra4-orden.txt`, tomas en `tomas4/`): un arma distinta por tier (subfusil Mac, MP40, Thompson, UMP9, MP5N, P90;
  fusil MP44_AKM, FAMAS, M4A1, G11, SCAR, Bren; escopeta Boomstick, Remington+bombeo, Benelli+bombeo, SPAS+bombeo,
  Pancor, Puntgun; francotirador Kar98k/M1Garand/Barrett; misiles Panzerfaust/Panzerschreck/Warhawk; granada Milkor +
  explosión), impactos por material (flesh, BodyHit, metal, stone, wood, sand, water, Glass, headshot), 8 candidatos
  para las cajas verdes (ningún archivo se llama recharge/recarga) y truenos: StormT1-3 actual frente a restaurado
  (afftdn, paso bajo 7 kHz, graves, compresión, 16 bits) y truenos nuevos de AudioClip (Thunder 5, truenolobo2/4,
  thunder_with_light_rain_003).
Decisiones de Leon (14/11/2026, tras la muestra 4): `ammobox` para las cajas verdes (sustituye `UI_Click` en
`Recarga_Tomar`); `equipamiento` al comprar o mejorar el tier de un arma en la tienda; `armasligeras` al cambiar el tipo
de arma; el resto de candidatos de caja queda para más adelante. Truenos: AudioClip trae 9 clips de trueno en 16 bits
44,1 kHz (Thunder 5 mono 2,1 s; truenolobo1-5 estéreo 10–15 s con 2–4 golpes cada uno; lightningimpact 1 s;
stormimpact 2,2 s; lluvia con trueno 81 s), frente a StormT1-3 en 8 bits 22 kHz (StormT2 con pico −5,9 dB y media
−25 dB). Alcanzan para sustituir los tres y dar varias tomas por intensidad.
Diseño previsto: WAV 22050 Hz 16 bits mono para 3D; disparo propio fuerte, ajeno con toma lejana y más bajo (volumen por
GetLocalPlayer, sin crear sonidos sólo en un cliente); bucles por tier en subfusil/fusil o un sonido por bala con tope;
impactos con tope por zona y tiempo; precarga silenciosa. Pendiente: elección de Leon y versión del mapa.

## v17d (14/11/2026): sonidos de armas, impactos, cajas, tienda, cambio de arma y truenos

Base v17c (`24538466…`). Construcción `scripts/hacer-v17d.sh`: `sonidos_v17d.py` (AudioClip de Leon, dos pasadas
iguales por hash) → `v17d.py` sobre el j → pJASS → `mpq add` del j y de 46 WAV → reextracción y comparación de cada uno
→ `mpq verify` correcto. Salida `TerrainDev-Titulo-v17d.w3x` `6d281dc752df0f96350a170cd79f7a498f399275240f39dac8c2a7b272009d13`.
Lanzador `scripts/entrar-v17d.sh`.

Cómo se oyen bien en 3D (evidencia local; Hive Workshop respondió 403 a la lectura automática):
- Blizzard en 1.27b (`UI\SoundInfo\AnimSounds.slk`, War3x.mpq): RiflemanAttack, Mortar, LightningBolt usan `WANT3D`,
  MinDistance 600, MaxDistance 10000, DistanceCutoff 3000, canal 11, `MissilesEAX`/`CombatSoundsEAX`/`SpellsEAX`,
  variación de tono 0,1. Sus WAV (RiflemanAttack1, MortarImpact, LightningBolt) son PCM 16 bits 22050 Hz mono.
- Hilos de Hive (sólo títulos y resúmenes del buscador): un sonido 3D importado debe ser mono; marcar 3D y "detener
  fuera de alcance"; la primera reproducción de un sonido importado no suena, por eso se reproduce antes a volumen 0.
- La cámara de juego está a 1650, dentro del corte de 3000.

Qué hace v17d:
- Disparo: un sonido por disparo en la posición del tirador (la escopeta, uno por disparo con su bombeo); arma por
  tier de la muestra 4; francotirador y misiles comparten cada dos tiers (Kar98k, M1Garand, Barrett; Panzerfaust,
  Panzerschreck, Warhawk); granada Milkor; cuchillo sin sonido nuevo.
- Impactos: carne (flesh1-4) al dar a una unidad, piedra (stone1-4) en pared o árbol; explosión (Granada Explosion)
  en granadas y misiles. Tope por 0,25 s: 10 disparos y 6 impactos.
- Lo de otros jugadores suena a 3/4 (sólo volumen por GetLocalPlayer; el sonido se crea en todos los clientes). Tono
  0,95–1,05 de un contador, sin usar el azar sincronizado.
- Caja verde `SonCaja` (ammobox), compra o mejora de tier `SonTienda` (equipamiento), cambio de arma `SonCambio`
  (armasligeras): 2D sólo para ese jugador.
- Truenos: 3 por intensidad (T1 Thunder 5, lightningimpact, stormimpact; T2 truenolobo2/5/1; T3 truenolobo4,
  truenolobo1 final, lluvia con trueno), comprimidos, volumen 127; la música baja a 0,45 durante 4 s.
- StormT1-3 siguen dentro del mapa sin uso.

Estado: **Validated** (pJASS, reextracción por hash, `mpq verify`). Sin probar en el mapa ni en multijugador. A
comprobar por Leon: que se oyen el primer disparo y la primera caja, volumen frente a la música, saturación con muchos
disparos, distancia a la que dejan de oírse los disparos lejanos. Sin variante -prueba (los sonidos no dejan registro).

## v17e (14/11/2026): disparos a la medida del ritmo, cambio de arma sin silencio, truenos y cambio más bajos

Leon tras jugar v17d: "reducir un 25% a los rayos y audio al cambiar de arma", "verificar el sonido del cambio de arma
no tenga un silencio al inicio" y que los disparos "no iba de acuerdo al rps". Medido (`onsets`, envolvente 5 ms):
ninguna toma de arma trae ráfaga ni silencio inicial; ya era un sonido por bala (Arm_Emitir), pero cada toma duraba
0,5 s y el subfusil y el fusil disparan cada 0,09–0,17 s (Arm_Int), así que se encimaban 3–5 y podían agotar voces.
armasligeras empezaba con 290 ms de silencio.
- `sonidos_v17e.py`: subfusil y fusil = 2 intervalos de su tier (0,18–0,33 s) con fundido desde el 40 %; granada 0,3 s;
  SonCambio desde 0,27 s (sin silencio). Mismos nombres de archivo; se sustituyen los 46.
- `v17e.py`: trueno y SonCambio a volumen 95 (−25 %); `Son_Ui` recibe el volumen; caja y tienda a 127.
Construcción `scripts/hacer-v17e.sh` (base v17d `6d281dc7…`), salida `TerrainDev-Titulo-v17e.w3x`
`b4523918eaf3027886b6fe75c3bff681fc8a57976b04ad5efa63f81481c542bb`; lanzador `scripts/entrar-v17e.sh`.
Estado: **Validated** (pJASS, reextracción por hash del j y los 46 WAV, `mpq verify`). Sin probar en el mapa.

## v17f (14/11/2026): tomas completas y un sonido por bala sin tope común

Leon tras v17e: "si reducir los audio originales, suenan raro sino, puedes crear el audio cada momento que sale el
proyectil, asi no tendria poblema con otros jugadores usando el mismo arma".
- `sonidos_v17f.py`: subfusil, fusil y granada vuelven a su toma natural (hasta −30 dB + 50 ms, máx. 1 s); el resto
  como v17e (SonCambio sin silencio).
- `v17f.py`: `Son_Disparo` crea un sonido 3D por bala sin el tope común de v17d (podía callar a otros jugadores); al
  salir la siguiente bala del mismo jugador, la anterior baja a 1/3. Cada jugador guarda sus 4 últimos sonidos sin
  KillSoundWhenDone y libera el de hace 4 disparos con `StopSound(s, true, false)`, así nunca se toca un handle
  liberado. Impactos siguen con su tope (6 por 0,25 s). Truenos y SonCambio a 95 (v17e).
Construcción `scripts/hacer-v17f.sh` (base v17e `b4523918…`), salida `TerrainDev-Titulo-v17f.w3x`
`447d9cfd45d1bac9e0be970158ce6c72a828f8885805fec17d1c3525443550d3`; lanzador `scripts/entrar-v17f.sh`.
Estado: **Validated** (pJASS, reextracción por hash, `mpq verify`). Sin probar en el mapa ni en multijugador.

Prueba de v17f (Leon, 14/11/2026, un jugador): "fue bien la prueba ahora si". **Tested in map** (Leon); sin LAN.

## v17g (14/11/2026): el trueno destaca sin bajar la música

Leon: "sin bajar la music, el rayo debera destacar por si solo".
- `v17g.py`: fuera `VolumeGroupSetVolume(MUSIC, 0.45)` y el reloj `Son_Musica` que la devolvía; trueno a 95.
- `sonidos_v17g.py`: truenos con +3 dB en 2,5 kHz y +6 dB contra un limitador, pico -1 dB; nivel medio +2 a +5 dB
  (Thunder 5 -17,4 → -12,0 dB; truenolobo2 -11,8 → -8,6; truenolobo4 -15,2 → -13,1). Resto igual que v17f.
Construcción `scripts/hacer-v17g.sh` (base v17f `447d9cfd…`), salida `TerrainDev-Titulo-v17g.w3x`
`ddb7606c0d5fd0bce0606a7750d0c6a4b6ed3c8a35af9a7ac58d214cff1f0c3b`; lanzador `scripts/entrar-v17g.sh`.
Estado: **Validated**. Sin probar en el mapa.

## v17h (14/11/2026): presentación del jefe de ronda

Leon, con un vídeo de presentación de jefe: el nombre del jefe en lugar del texto japonés, su modelo con la animación de
ataque, un rayo al centro, fondo oscurecido y ráfagas; "al acabar con la ultima unidad para que salga el jefe, antes de
generar o hacer aparecer al jefe mostrara esa presentacion, al terminar recien dara spawn el boss", con los movimientos
del vídeo y la hidra del título como referencia del modelo.
- Tiempos medidos cuadro a cuadro (30 cuadros/s): fondo, ráfagas y WARNING en 0,15 s; nombre (izquierda) y jefe
  (derecha) entran 0,50-0,65 frenando; derivan 25 px/s a la derecha y 48 px/s a la izquierda; tajo y trueno a 0,70,
  trazos 0,80 / 0,90 / 1,03, chispas 1,20-1,32; todo sale 3,03-3,18; el jefe aparece a 3,20.
- `recursos_v17h.py`: texturas propias JefeOscuro, JefeRafaga, JefeBarra, JefeAviso, JefeRayo1..5, JefeNombre2..10
  (Fira Sans). `jefe_modelos_v17h.py`: los 9 modelos del juego (`modelos/jefes-base-v17h`, con SHA256SUMS) girados a la
  cámara de juego con 35° de tres cuartos, sin sombra ni niebla, como PresHydra; imprime sus límites.
- `objetos_v17h.py`: destructibles DP00..DP08 y DPN2..DPNA, unidades 'upj2'..'upjA' (copias de 'uidm'), 27 imports.
- `v17h.py`: la puerta del jefe (`s__Wave_killGatePassed`) lanza `JefePres_Empezar` una vez por ronda y retiene al jefe
  hasta `JefePres_Lista`; piezas por jugador con alfa local, colocadas en `HealthBarsUpdate` a 1500 (fondo), 1400
  (ráfagas), 900 (jefe), 450 (franja), 430 (rayo) y 400 (textos); sin filtro de cine.
- Variante `-prueba`: comando `-pres N` (ronda 2..10) que muestra sólo la presentación.
Construcción `scripts/hacer-v17h.sh` (base v17g `ddb7606c…`): `TerrainDev-Titulo-v17h.w3x`
`bcd9fc41a84c31d23f70bd27195208cc57c41d4e298ba72ef6c2de98c32dc7ed` y `TerrainDev-Titulo-v17h-prueba.w3x`
`b1a6d8dfb26e85278a4793a664554202fb231f1159a5383461882ec6314861f7`; lanzadores `scripts/entrar-v17h.sh` y
`entrar-v17h-prueba.sh`.
Estado: **Validated** (pJASS de las dos, reextracción por hash del j y los 30 miembros nuevos o cambiados,
`mpq verify`, texturas iguales en dos generaciones). Sin probar en el mapa ni en multijugador: falta ver tamaños,
posiciones y orden de dibujo en el juego, y LAN porque el alfa es local.

## v17i (14/11/2026): presentación del jefe delante del HUD

Leon probó v17h-prueba con `-pres N` (vídeo y capturas): ráfagas flojas, jefes demasiado abajo, y la barra de vida y los
textos del HUD y de los héroes por delante del fondo oscuro; propuso simular con el color que tendrían los textos si el
fondo los cubriera. Además, evaluado en su prueba: el jefe se podía seleccionar (retrato "Invulnerable"), su salida
parecía quieta y luego desaparecía, la franja del nombre era una línea dura y el rayo no brillaba.
- Profundidades: las piezas del HUD van a 384-401, así que la presentación pasa delante: fondo 380, ráfagas 376, jefe
  260, franja 222, rayo 215, WARNING y nombre 200.
- Textos (`JefeTx_*`): la profundidad de un texttag no se cambia y su alfa no hace nada si ya se ve; cada color base y
  cada `|cAARRGGBB` del texto pasa a c × (1 − f) + (11, 16, 34) × f, con f = 0,647 × nivel / 8 (el alfa 165 del
  fondo), en 8 pasos durante la entrada y la salida; nivel 0 al terminar. Se envuelven los textos y colores del HUD
  (ronda, racha, arma y balas, valores de vida, aviso de tienda) y las barras sobre héroes y enemigos, con claves
  iguales en todos los clientes; se usa siempre el texttag vivo (los de la racha y UIText.destroy se reciclan).
- Jefe en una caja de 560 × 560 px centrada en (1480, 430) (antes 640 × 700 con el pie en 820). Piezas con Locust.
  Salidas con aceleración cuadrática.
- `recursos_v17i.py`: ráfaga más gruesa y brillante, franja de 1100 px con alfa 150, rayo con halo 2× más ancho y
  fuerte. 28 ráfagas (antes 16) con brillo 110-230.
Construcción `scripts/hacer-v17i.sh` (base v17h `bcd9fc41…`; objetos y modelos sin cambios, se reemplazan el j y las
18 texturas): `TerrainDev-Titulo-v17i.w3x` `23ede08a957850a44e0069143475a4f31871f0e6c45789098fdeb9dc97f09dbe` y
`TerrainDev-Titulo-v17i-prueba.w3x` `509ef155b1740b947c024bff9eea2c8ab3781339e7b43c84583a692b03859f5c`; lanzadores
`scripts/entrar-v17i.sh` y `entrar-v17i-prueba.sh`.
Estado: **Validated** (pJASS de las dos, reextracción por hash del j y las 18 texturas, objetos y modelo iguales a
v17h, `mpq verify`, texturas iguales en dos generaciones). Sin probar en el mapa ni en multijugador: falta ver el
tapado del HUD, el tinte de los textos y la posición del jefe en el juego, y LAN porque el alfa es local.

## v17j (14/11/2026): presentación del jefe como el vídeo de referencia

Leon probó v17i-prueba: el tinte de los textos "nos funciono bien ... como si realmente se cubrieran por el fondo".
Pidió revisar el rayo del vídeo de referencia, ráfagas más anchas y la banda grande que va con el nombre, el WARNING
del propio vídeo y una mejor fuente para el nombre con los colores del HUD, más las fallas vistas en su prueba (marco y
barra de vida por delante del fondo, Snarecaster y Deepseer que se salen por arriba, salida del jefe casi invisible).
- Referencia medida a 30 cuadros por s (`fuentes/presentacion/jefe/LEEME.md`): tajo 0,10 s, grieta 0,10 s, rayo 0,13 s,
  chispas 0,07 s, nada 0,10 s, otro rayo 0,10 s, chispas 0,20 s. El WARNING sale de la mediana de 30 cuadros
  (`warning-mediana.png`).
- `recursos_v17j.py`: WARNING de la referencia en rojo liso; nombres en Friz Quadrata (la fuente del juego y del HUD),
  blanco a celeste 199/247/255, borde azul marino y halo azul; ráfagas de núcleo plano de unos 6 px; banda del nombre
  de unos 45 px; rayo: tajo grueso, grieta fina, dos rayos ondulados distintos y chispas.
- `v17j.py` sobre los dos j de v17i: rayo con ese ritmo; la banda va con el nombre; HeroBars/EnemyBars oscurecidas con
  el color de vértice sólo en el cliente del dueño; hechizo sólo para la Naga; salidas de 0,30 s y fin a 3,35 s.
Construcción `scripts/hacer-v17j.sh` (base v17i `23ede08a…` y `509ef155…`): `TerrainDev-Titulo-v17j.w3x`
`350c9dcc5ece85f41b9540df09e2229976475b5a85e5910b3c6789933806bbb1` y `TerrainDev-Titulo-v17j-prueba.w3x`
`e0dc7b1c31413379b7fb3f22e15345bc988efe450ddb0c31655ac4135cd40fd3`; lanzadores `scripts/entrar-v17j.sh` y
`entrar-v17j-prueba.sh`.
Estado: **Validated** (pJASS de las dos, reextracción por hash del j y las 18 texturas, objetos y modelo iguales,
`mpq verify`, texturas iguales en dos generaciones). Sin probar en el mapa ni en multijugador.

## v17k (14/11/2026): fondo más oscuro, banda larga y Snarecaster entero

Prueba de v17j (vídeo de Leon): HUD tapado entero (barra verde 254 → 100, marco 219 → 84), rayo con el parpadeo de la
referencia y salidas visibles. Faltaban: la banda del nombre asomaba como un trozo corto, el Snarecaster salta también
con el ataque y se le cortaba la cabeza, los nombres largos se veían pequeños y el fondo dejaba ver mucho el mapa de día.
Leon: "mejoremos ese apartado, en caso que subas mas oscuridad al fondo, seria tambien aplicar el nuevo color a los
textag".
- `v17k.py`: fondo con alfa 205 (80 %) y el tapado de textos y barras con f = 0,804; banda de 1210 × 110 px centrada
  50 px a la derecha del nombre; Snarecaster (ronda 5) a escala 0,8531 (75 %) con el pie en el mismo sitio.
- `recursos_v17k.py`: banda pareja que se apaga en el último 30 %; nombres a 50 px de letra (antes 42), estrechados si
  no caben, con trazo más grueso.
Construcción `scripts/hacer-v17k.sh` (base v17j `350c9dcc…` y `e0dc7b1c…`): `TerrainDev-Titulo-v17k.w3x`
`5d9a1ab449e5ce58fc1317268c711a205264528388cc7253c7af067a824a3f7c` y `TerrainDev-Titulo-v17k-prueba.w3x`
`a6870481925cf3825dacc0263dc25ea5f3badfef6366139cc72af31f6f0a5d80`; lanzadores `scripts/entrar-v17k.sh` y
`entrar-v17k-prueba.sh`.
Estado: **Validated** (pJASS de las dos, reextracción por hash del j y las 18 texturas, objetos y modelo iguales,
`mpq verify`, texturas iguales en dos generaciones). Sin probar en el mapa ni en multijugador.

## v17l (14/11/2026): Snarecaster a su tamaño

Prueba de v17k por Leon (vídeo `Videocaptura de pantalla_20261114_073810.mp4`): fondo 68→37, barra verde 250→60,
marco 116→37; Snarecaster dentro del cuadro; el Murloc Mutant asoma por arriba al atacar. Leon: "no importa que se
corte un poco, si ajustamos ello se quedara pequeno el murlok ... ya lo hicimos con el morado y termino pequenio,
ajustarias ello y estaria listo". v17l devuelve el Snarecaster a escala 1,1375 / OX 35,5 (v17j); el Murloc no cambia.

- Fuentes: `scripts/v17l.py`, `scripts/hacer-v17l.sh` (sólo reemplaza el j sobre v17k), `entrar-v17l*.sh`.
- `TerrainDev-Titulo-v17l.w3x` d86914c3faf6798d8bf92cba0911d2272a5a4cc813c69b6a32e9c706ccdfd896
- `TerrainDev-Titulo-v17l-prueba.w3x` aa0cfcabea00c819a36d2fa3c1097a8ba4e2dd5c279799cb359fc4c9efe075d0
- Estado: Validated (pJASS, j reextraído, w3u/w3b/imp/PresJefe5/texturas iguales a v17k, mpq verify). No probado en mapa.

## v17m (14/11/2026): marcador oculto y barra del jefe

Leon: ocultar la multiboard y usar la barra derecha oculta del HUD para el jefe, con su icono, cargándose hasta liberarlo,
entrando en pantalla y saliendo por la derecha al morir; "esa barra cambiara de icono de personaje de acuerdo al jefe".
- La barra derecha (HealthBars__EnemyBars, 1358,4 × 48,6 px, distancia 400) está a la misma profundidad y altura que la
  del jugador (24 × 48,6, 400); nunca se mostraba (HealthBarsTarget sin llamadas).
- Multiboard "Marcador": MultiboardDisplay false; la tabla sigue al día.
- Barras 'hbk2'..'hbkA' = HealthEnemyTauren.mdx con el BTN del JefeIcono de cada ronda (jefe_barras_v17m.py).
- Al acabar la presentación: entra en 0,30 s, se carga en 2,50 s, al llenarse JefePres_Lista (sale el jefe), muestra vida
  y % (EnemyValues); al morir sale en 0,30 s. La puerta del jefe no relanza la presentación durante la carga.
  "-pres N" (prueba) muestra la barra sin liberar jefe.
- Fuentes: v17m.py, objetos_v17m.py, jefe_barras_v17m.py, hacer-v17m.sh, entrar-v17m*.sh.
- `TerrainDev-Titulo-v17m.w3x` 850568dcc6c8877a90a1e47ab21428d6011926404435b51c53a2b31a24b556a5
- `TerrainDev-Titulo-v17m-prueba.w3x` c70f80e2201e6ddfba5e2e186fe33d1fe7f3362ca3cb69bbfa27e8d8021c6674
- Estado: Validated (pJASS, 12 miembros reextraídos, mpq verify). No probado en mapa.

## v17n (14/11/2026): porcentaje, relleno a la izquierda y vida ×2

Prueba de v17m (vídeo `..._080027.mp4`, sólo `-pres`): marcador oculto, barra entra y se carga con el icono de cada
jefe; con una presentación encima la barra no quedaba tapada. Leon: porcentaje debajo de la barra, crecer de derecha a
izquierda, vida de unidades, jefes y élites "un adicional mas".
- Porcentaje bajo el icono del jefe (espejo del del jugador, x 1870,8 - 4,5 × largo), también durante la carga.
- jefe_barras_v17n.py: pivote del hueso Life en y 125,799 (antes 7,635): relleno de derecha a izquierda.
- La barra del jefe se tiñe con JefeTx_Aplicar como las del jugador.
- objetos_v17n.py: uhpm × 2 en 10 tipos, 10 élites y 9 jefes (p. ej. nmcf 60→120, élites 160→320, nj02 1400→2800,
  nj0A 6200→12400); Oro_Muerte usa vida máx. / 10 (antes / 5): mismo oro.
- `TerrainDev-Titulo-v17n.w3x` f2ab5493a796d6ca46f653ee0ee20c714b95a18fc52ab2c2cbc73d148119bd58
- `TerrainDev-Titulo-v17n-prueba.w3x` 91d44115f5e515c76c6e8b35d0526fe5850cb87f023fee450b2d65fb6a3c7a97
- Estado: Validated (pJASS, 11 miembros reextraídos, w3q/w3b/imp iguales, mpq verify). No probado en mapa.

## v17o (14/11/2026): precarga de la presentación y la barra del jefe

Leon tras jugar v17n: "funciono bien, solo seria agregar todos nuestros elementos nuevo a la precarga para no tener
cuelgues". Precarga_Todo añade Preload de 18 Jefe*.blp, 9 PresJefe{n}.mdx y 9 HealthJefe{n}.mdx, y el primer uso de cada
textura de la presentación (JefePres_Dummy, 'uidb'/'uidg') y de las unidades 'upj2'..'upjA', 'hbk2'..'hbkA',
'hbj2'..'hbjA' (creadas y quitadas). Sólo cambia el j (scripts/v17o.py, hacer-v17o.sh).
- `TerrainDev-Titulo-v17o.w3x` bdc73708acbde5791626f13304fcb59ce31ccfccbd03573b867296d8aff24eaf
- `TerrainDev-Titulo-v17o-prueba.w3x` 5f37057a686a5a2858276d5743c62288e9d80b2c54545ece06018dbc901b8fd3
- Estado: Validated (pJASS, j reextraído, resto igual a v17n, mpq verify). v17n probado por Leon en el mapa
  (funcionó); v17o no probado en mapa.

## v17p (14/11/2026): sala con nombre, dos equipos fijos y raza Humano

Leon: "un jugador podria ponerse equipo 8o saltarse ciertos slots ... ya necesitamos poner nombre al mapa ... deberia
estar ya preconfigurado los equipos como la otra imagen que es de dota". Respuestas: nombre "Proyect Dev Us"; "dividelo en
dos equipos, dev us y dev mission, dentro del juego ya los ariamos aliados" (en línea hacen falta dos fuerzas); raza
"Humano".
- w3i (scripts/w3i_v17p.py): fuerzas propias y ajustes fijos (flags 0x40|0x20); fuerza "Dev Us" jugadores 1-4 y
  "Dev Mission" 5-8, las dos aliadas; raza Humano en los 8. wts: nombre (STRING 1) "Proyect Dev Us", jugadores
  recomendados "1-8 cooperativo", STRING 7 "Dev Us", STRING 25 nueva "Dev Mission".
- j (scripts/v17p.py): SetTeams(2); config llama a InitCustomTeams (hasta v17o se llamaba InitGenericPlayerSlots, que con
  ajustes del mapa no hace nada, e InitCustomTeams no se usaba); equipos 0/1 y alianza entre los 8 desde el inicio (la
  visión compartida sigue llegando al salir del título); raza Humano no elegible.
- `TerrainDev-Titulo-v17p.w3x` 7d080a499dd031e3bd71adfbb26552102a7da087ff7e9f35ef114d42b4f2f52d
- `TerrainDev-Titulo-v17p-prueba.w3x` 7dac601fa2b4568a5f1c90dba3b9d40bee301fddfbd84079b5c89fa32962361e
- Estado: Validated (pJASS, j/w3i/wts reextraídos, w3u/w3b/imp/doo/w3e iguales, mpq verify). Sala no comprobada: sólo
  se ve al crear partida (LAN o en línea); pendiente que Leon la revise.

## v17q (14/11/2026): nombre en la lista de mapas

Leon vio v17p en la sala (LAN, WOE): nombre, fuerzas Dev Us / Dev Mission, Humano y "1-8 cooperativo" correctos; la
lista de mapas seguía diciendo "Swamped Temple_v2", que sale de la cabecera HM3W del w3x. scripts/cabecera_v17q.py:
nombre "Proyect Dev Us" y marcas 0x1fc18 -> 0x1fc78 (fijos y fuerzas propias, como el w3i). MPQ idéntico a v17p.
Revisión estática (Scanned) de puestos con huecos y Ordenadores: todo el código recorre los 8 puestos y sólo atiende a
humanos jugando; los Ordenadores no reciben héroe ni IA. No probado en partida.
- `TerrainDev-Titulo-v17q.w3x` 8bd0aa485560821e57266db12241cb489988aa642d01c549b00fe526477967ee
- `TerrainDev-Titulo-v17q-prueba.w3x` ffe9c95d0ef6fe60e73449fe306faaabf3803315cbad7ba773611a330395354c
- Estado: Validated (MPQ idéntico, mpq verify). Copia también en Maps/Test de WOE (runtime/proton-woe).

## v17r (14/11/2026): piezas de interfaz con Langosta sin selección

Leon con captura (icono de vida 'hbi0' seleccionado en partida, "Invulnerable"): "si, ya que muchos elementos se puede
seleccionar, y en el sistema original me parece no pasaba". Las piezas de vida tienen 'Aloc' en el w3u; causa probable
(sin comprobar): ocultarlas y mostrarlas con ShowUnit las deja cogibles con el recuadro. scripts/v17r.py: en
Shop_Seleccion, una unidad con 'Aloc' seleccionada se quita de la selección de ese cliente y vuelve Game_Ctrl (con la
tienda abierta sólo se limpia). Botones del inventario (e000/e001, sin Aloc) sin cambio. La de prueba anota cada pieza
(máx. 60) en CustomMapData\lat\v17r-seleccion.txt. Cabecera de v17q conservada.
- `TerrainDev-Titulo-v17r.w3x` 62ea39750ca5e7013f3a6dae5a2213054aac46d75adb335895a67eda0d39fa49
- `TerrainDev-Titulo-v17r-prueba.w3x` b59ac401849919dca68b8ded7fda9f181c8cedea37e6974e55c71372fb9afd3e
- Estado: Validated (pJASS, j reextraído, cabecera y resto igual a v17q, mpq verify). No probado en mapa. Copias en
  Maps/Test de WOE.
- 14/11/2026, primera partida de v17r-prueba (2 min 23 s): sin registro v17r-seleccion.txt ni vídeo; no consta que se
  intentara seleccionar. Leon lo deja como **tema a tratar**: repetir arrastrando recuadros sobre el HUD tras
  ocultar/mostrar (tienda), con vídeo, y comparar con el sistema original.
