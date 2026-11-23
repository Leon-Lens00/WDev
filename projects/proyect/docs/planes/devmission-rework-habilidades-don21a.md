# Dev Mission: rework de habilidades frente a DON 2.1a

Estado: **Scanned** (comparación estática de código y objetos). Nada compilado ni jugado para este plan.

## Fuentes

| Fuente | Identidad |
|---|---|
| DON 2.1a de Leon | `/home/snz/Descargas/Battlestadium DON 2.1a.w3x`, sha256 `ae30dfee…`, 40 624 009 bytes (sin tocar; copia en scratch) |
| Nuestra base | `TerrainDev-Titulo-v21c.w3x`, sha256 `73ab2605…` |
| Referencia anterior | `work/battle-don-ref-20261112/extraido`: mismos w3u/w3a/w3h/wts que 2.1a, pero su j tenía 66 funciones de trucos inyectadas. La copia de Leon está limpia. |

La medición del j original 1.8c no se pudo emparejar por nombre (los nombres `GkF_…` son de nuestra copia); nuestro v21c ya contiene ese código 1.8c más nuestras capas (copias Dcp, Missile, área v20u).

## Hallazgos

### Forma del código

- 2.1a es GUI convertido: cada habilidad guarda su estado en índices fijos de arrays globales (`udg_Caster[6010]`, `udg_Point[6500]`, `udg_KameTrail[0]`…). **No es MUI**: dos lanzamientos simultáneos de la misma habilidad comparten estado. En una partida de 5 jugadores con héroes repetidos o con copias, se pisan.
- Movimiento por disparadores periódicos de 0,03-0,04 s que, en cada cuadro, crean unidades de estela (Kamehameha: 1 unidad por cuadro ≈ 33/s, guardadas en grupo hasta el final), enumeran destructibles y unidades en área (grupo nuevo por cuadro) y mueven con `SetUnitPositionLoc`.
- Fugas: las ubicaciones y grupos están liberados (RemoveLocation ≥ creaciones, DestroyGroup = grupos) en los periódicos medidos. El coste viene del trabajo por cuadro, no de fugas.
- Sistemas compartidos `WAVE` (637 líneas por cuadro, 26 grupos), `slider` y `Homing` usados por varias habilidades.

### Nuestra versión

- Vuelo con Missile (un reloj de la biblioteca para todos), copias Dcp por lanzamiento; quedan pocos periódicos propios: Warp `GkV_js` 0,04, Burning Slash `TrV_TA` 0,05, Power Up `TrV_et` 0,04 y `TrV_ft` 1.
- Menos unidades creadas en la mayoría de habilidades (Heat Dome 11 frente a 28, Burning Attack 13/26, Burning Slash 8/25, Warp 24/35). Más en Rasenrengan (34/19) y Six Tail (33/6, incluye nuestro manejo de formas).
- Enfriamiento y maná a 0 en los objetos porque los gestiona el libro (v20q); 2.1a los lleva en el objeto (20-150 s, 50-100 maná).

### Diferencias de kit

| Personaje | Sólo en 2.1a | Cambiado de nombre o papel |
|---|---|---|
| Goku | A0BZ «Ultimate» (combo de 248 funciones y 8 periódicos) | nuestro A0BZ es Super Dragon Fist |
| Freezer | A0OH Golden Form (80 s), A0JD Imprisonment Ball propia (20 s) | A0IV: 2.1a White Launcher, nuestro Imprisonment Ball; A0IY: Death Saucer / Destructo Disc |
| Trunks | — | A03W: 2.1a Final Hope Slash (120 s), nuestro Burning Slash |
| Naruto | A0K2 RasenKyuugan (30 s) | A0F3: 2.1a Bijuu Dama (150 s), nuestro RasenShuriken; A0F5 pasa a «Multiple Rasenrengan» |

## Conclusión

- **Más ligero:** el nuestro, en casi todas. 2.1a no aporta una forma más eficiente de mover ni de dañar.
- **Mejor hecho:** el nuestro para varios jugadores (estado por lanzamiento). 2.1a sólo aporta contenido: habilidades nuevas, nombres, tiempos y la sensación de cada técnica.
- Rework propuesto: tomar de 2.1a **qué hace** cada habilidad (efectos, sonidos, tiempos, fórmulas) y reimplementarlo con nuestro motor (Missile + Dcp + libro), nunca copiar sus disparadores periódicos.

## Fases propuestas (una letra por entrega)

1. Elegir el kit final por personaje (decisión de Leon: ¿Golden Form, RasenKyuugan, Bijuu Dama, Ultimate de Goku, Final Hope Slash?).
2. Por personaje, una entrega: leer el disparador 2.1a, anotar tiempos, daño y efectos; portar al motor nuestro; quitar los periódicos restantes (Warp, Burning Slash, Power Up) pasándolos a Missile o a un reloj por lanzamiento.
3. Comprobación por entrega: pJASS, reextracción, variante `-prueba` con registro de lanzamientos y aciertos; LAN sólo si se toca lo local.

(Fases iniciales sustituidas por las de abajo tras las decisiones del 22/11.)

---

## Decisiones de Leon (22/11/2026)

- Se traen **todas** las habilidades nuevas de 2.1a y se reemplazan los kits de Goku, Freezer y Trunks por los de 2.1a.
- Naruto actual se queda como **Naruto sabio**, sin cambios. Se añade **Naruto Kurama** (H01A de 2.1a).
- Se traen los modelos nuevos de los personajes.
- Goku: su Ultimate cambia según la transformación (como 2.1a). La Q conserva el color por forma (SSJ3 amarillo, SSJ4 rojo).
- **Selección:** vuelve una pantalla de selección al empezar (sustituye el héroe fijo por color de v20y).
- **Choques de proyectiles:** no rompen árboles. Al chocar con un árbol o una pendiente que no puede cruzar, el proyectil se queda moviéndose en esa zona (como en DON al tocar el límite del mapa) y explota cuando se cumple su tiempo configurado.
- Lo que hace cada habilidad (efectos, sonidos, tiempos, daño) sale de 2.1a; el movimiento va con nuestro Missile y las copias Dcp.

### Color de la Q de Goku

Comprobado en el código: el disparador por cuadro de Kamehameha (`kamehameha2` en 2.1a, `GkF_aP7` en el nuestro) es el mismo en las dos versiones. Con la forma 4 (SSJ3) la estela sale amarilla (100/100/0, escala 600). Con la forma 5 (SSJ4) sale roja (100/0/0, escala 900). Los modelos `SO2` y `BibangKamehamehaBall` son idénticos por hash.

En 2.1a las formas dios usan otro Goku (H0LF), que lanza otro Kamehameha (A0O6, `kamehameha_goku_god`) con colores propios. Es probable que de ahí venga que «en 2.1a no cambia»; es una hipótesis. Se conserva nuestra regla.

## Inventario de 2.1a: personajes que entran

Teclas de 2.1a; «→» indica el cambio pedido. Los modelos de 2.1a vienen sin nombre en el MPQ; nombres recuperados por hash con `nombres_don.py`: 1725 de 2002 bloques.

| Personaje | Unidad 2.1a | Kit (Q W E R T X) | Cambio | Modelo (bytes) |
|---|---|---|---|---|
| Goku | H00C (+H0LF formas dios) | Q A00P Kamehameha, W A0IA Warp, R A0BZ Ultimate, T A01G Spirit Bomb, X A0G2 Power Up | kit 2.1a; Ultimate por forma | Goku_squished 92 237 (el nuestro 90 625, distinto) |
| Freezer | H0GX, Golden H0LH | Q A0IX You Will Die, W A0JD Imprisonment Ball, A0J1 Death Break, T A0IW Death Ball, X A0IY Death Saucer, A0OH Golden Form | kit 2.1a | Frieza Final Form / Golden 131 396 (hoy Cooler4) |
| Trunks | H037 | Q A05B Burning Attack, E A086 Heat Dome, R A03W Final Hope Slash, T A0I5 Sword of Hope, X A0H5 Power Up, A0GV Finish Buster | kit 2.1a | TrunkNormal 183 496 (hoy usa Vegeta'sBody) |
| Naruto Kurama | H01A | Q A0F5 Multiple Rasenrengan, W A0K2 RasenKyuugan, E A00W, R A0F3 Bijuu Dama, T A0KY Bijuu RasenShuriken, X A0K5 Chakra Cloak | T → E | «Naruto (Sage Mode)_squished» 147 419: **mismo nombre que nuestro Naruto sabio, otro contenido**; importar con nombre nuevo |
| Vegeta | H00P | Q A01D Big Bang, R A01F Final Flash, A01E Galick Gun, T A0HT Final Explosion, X A0HM Power Up | T → E | Vegeta'sBody 104 117 (el que hoy usa nuestro Trunks) |
| Vegito | H02T | Q A03E Banshee Blast, W A033 Big Bang, E A0HN Afterimage, R A0DS Final Kamehameha, T A03F Spirit Sword, X A0HL Power Up | X se queda; T → E | Vegetto SS 103 410 |
| Broly | H07O | Q A0A5 Eraser Cannon, W A02S Bloody Smash, R A09Q Gigantic Meteor, T A0L7 Rage Broly, X A0H6 Power Up | X se queda; T → E. La T lanza el proyectil de la Q y no explota: se le añade la explosión y el daño en área de la Q | Broly_SSJ 112 925 |
| Kid Buu | H0IM | Q A0LL Shocking Ball, A0LO Vanishing Beam, R A0LM Assault Rain, T A0LV Mystic Ball, X A0MY Power Up | T → E | KidbuuEbony 91 377 |
| Sasuke | H00X | Q A00V Mangekyou, W A0D5 Katon, E A013 Chidori, R A079 Black Arrow, T A055 Susanoo, X A0AK Kirin | tal cual | Sasuke 85 553 |
| Itachi | H01F | Q A0J0 Tsukuyomi, A034 Katon, E A0JT Mangekyou, R A0JQ Yasaka, T A0HO Susanoo, X A0AM Izanami | tal cual | Itachi 90 989 |
| Madara | H04I / H0FX (Uchiha Founder; H0BP no tiene T) | Q A0IU Gouka Mekkyaku, W A0GY Jukai Kotan, E A0HJ Blocking Absorption, R A0GX Banbutsu Sozo, T A0JJ Mangekyou | T → E | Copy of madara NWU1112 120 848 |
| Jiraiya | H0AH | Q A0CV Gamayu Endan, W A0CF Frog Songs, R A0CG Chou Odama, T A0CX Toad Summoning, X A0HV Rasengan | T → E | xzilaiye 140 048 |
| Hashirama | H0IO | Q A0LP Jukai Ho, W A0LT Mokuryuu, R A0LU Shin Susenju, T A0LW Myojinmon, pasivas Sage Mode / Wood Clone | T → E | hashirama normal mode and sage mode 87 821 |
| Kaguya | H0JZ | Q A0NA Togebari, A0NB Strikes, R A0NF Infinite Tsukuyomi, T A0N9 Yomotsu Hirasaka, X A0NC Byakugan | X fuera; T sólo a aliado o enemigo (sin terreno, para no subir pendientes); R con más área y sin dormir aliados | B_Kaguya 120 590 |

Los retratos `_portrait` de 2.1a pesan 1284 B (retrato vacío). Para el cuadro y las rachas hará falta el modelo de frente (como `MvpFrente*`).

## Fases

Cada fase es una letra nueva con su variante `-prueba`; LAN de dos clientes cuando toque lo local (selección, cuadro).

1. **v21d, base común.**
   - Registro de personajes por tabla (tipo, copia, frente, escala, icono) en lugar de las cadenas `elseif` por id. Hoy hay unas 7 ramas y serían 15 o más; se respeta el tope de unos 90 `elseif` por función.
   - Regla de choque en la capa de Missile de las técnicas DON: árboles y pendientes no se rompen ni se cruzan. El proyectil sigue vivo moviéndose en la zona hasta su tiempo y explota.
   - Pantalla de selección (trackables, como los menús), un héroe por jugador.
2. **v21e, Goku 2.1a:** modelo, Ultimate por forma, Spirit Bomb T y Power Up X; Q con color por forma.
3. **v21f, Freezer 2.1a:** modelo Final/Golden, Golden Form, Imprisonment Ball propia.
4. **v21g, Trunks 2.1a:** modelo TrunkNormal, Final Hope Slash, Sword of Hope.
5. **Naruto Kurama** con el modelo importado con nombre propio.
6. **Un personaje nuevo por versión:** Vegeta, Vegito, Broly, Kid Buu, Sasuke, Itachi, Madara, Jiraiya, Hashirama, Kaguya. El orden lo confirma Leon.

Por cada personaje:
- leer sus disparadores 2.1a (lista en el `devmission-don21a-inventario.txt`, junto a este plan);
- portar sus tiempos, daño, efectos y sonidos;
- pasar el movimiento a Missile;
- quitar el estado de índice fijo (`udg_X[6010]`): estado por lanzamiento;
- pasar pJASS, reextraer, `mpq verify` y la variante `-prueba` con un registro de lanzamientos y aciertos.

Presupuesto que hay que vigilar: 8 luces, 100 texttags, unos 1,5 MB de modelos de héroe más sus texturas, y el disparador compartido de muertes, que ninguna técnica puede apagar (fallo de v21b).

## Indicaciones de Leon para cada personaje (22/11/2026)

- Modelo: cámara de retrato propia en el personaje (algunos traen un retrato con forma de icono; los `_portrait` de 2.1a pesan 1284 B), tamaño ajustado y sin efectos al morir, para la pantalla de resultados.
- Icono propio en las rachas, en la vida y en la selección.
- `-pj N` con todas sus técnicas para probarlas. En partida normal empieza sólo con la Q, como los actuales.
- Maná y enfriamiento según la recomendación, como en v20q: maná 150 que recupera 1/s; Q 25 de maná y 6 s; las definitivas 80-100.

## v21d: base común (hecho)

Fuente `scripts/v21d.py` y `scripts/hacer-v21d.sh`, construidas sobre v21c y v21c-prueba. Sólo cambia el j.

- **Tabla de personajes** `Pj_*`, una fila por tipo de cuerpo: tipo, celda, copia Dcp, frente, escala, icono, icono de vida, nombre y técnicas. `Mvp_TipoFrente`, `Mvp_Escala`, `Dcp_Tipo`, `Don_Nombre`, `Tec_Rango` y los iconos de `Game_Enter` y `Pj_Cambiar` leen de ella. Un personaje nuevo es una fila más en `Pj_Registro`.
- **Rachas:** el icono sale del cuerpo que tiene el jugador (`Game_Hero`). Antes salía de la celda elegida (`Hero_Choice`), que podía no coincidir con el cuerpo, como el Freezer con el icono de Cairne que vio Leon.
  - La causa exacta de esa partida no se reprodujo. Con la fuente nueva ya no depende de la celda.
- **Selección:** vuelve la pantalla de 40 celdas, que seguía en el código desde v20y.
  - El color queda como respaldo para quien no eligió (entrada directa); si otro jugador eligió esa celda de D.O.N, el respaldo cae en Tauren.
  - Todos los personajes desde la celda 2 son uno por partida.
- **Choques:** Kamehameha y Warp de Goku ya no explotan al chocar. La pieza se queda en el punto del choque y la técnica sigue su tiempo: la bola del Kamehameha dura 2,2 s y el Warp tiene un contador de 100 pasos.
  - Freezer, Trunks y Naruto ya se comportaban así con `Don_Pon`.
  - Ninguna técnica portada rompe árboles: el código de D.O.N que los mataba no tiene enumeración que lo llame.
- **`-pj N`:** desbloquea todas las técnicas del personaje al nivel 1 como mínimo.
- Don_Nombre da «Cairne» para Cairne; antes daba «Tauren». También lo usa la voz de la tienda.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21d.w3x | `23b5bcbe10a13faa1e4fb63dc1f08efcb030a7a8c9e873ae3a4efe3a011deeba` |
| TerrainDev-Titulo-v21d-prueba.w3x | `3f3d0cc4326b83317a0fe2b4e988ab62a5aa066b4a2602dc190bb71f45d49f5d` |

Comprobaciones:
- pJASS correcto en las dos variantes.
- Construcción reproducible: las dos pasadas dan el mismo sha.
- `bytes-diff` sólo muestra (attributes) y war3map.j; `mpq verify` correcto.
- Copia en WOE comprobada con cmp.

Estado **Validated**: no se ha jugado.

Pendiente de probar en el mapa:
- la selección con varios jugadores (LAN; los clics de trackables viajan por la red);
- el Kamehameha contra una pendiente;
- el icono de las rachas;
- `-pj`.

Límite encontrado para las fases siguientes: el libro guarda las técnicas en `p * 100 + x` y las de ahora llegan a 78. Con 11 personajes más (unas 66 técnicas) hay que ampliar el paso por jugador, por ejemplo a 200 (12 × 200 = 2400 < 8192), antes del segundo personaje nuevo.

## v21e: Goku de 2.1a y sonidos 3D (hecho)

Fuentes en `work/titulo-devmission-20261026/scripts/`: `v21e.py` (j), `objetos_goku21.py` (w3u/w3a/w3h/w3b, guardados en `fuentes/goku21-obj`), `recursos_goku21.py` (108 recursos, `fuentes/goku21.tsv`), `sonidos_don3d.py` (`fuentes/don3d.tsv`), `imp_v21e.py` y `hacer-v21e.sh`. El código trasplantado está en `fuentes/goku21-j`.

- **Kit de 2.1a** a través de la copia (Dcp): Q Kamehameha (A0O6), W Dragon Fist/slider (A0IA), E Ultimate (A0BZ), que cambia con la forma; la forma 1 es la Spirit Bomb.
- **Q por forma:** conserva el color de 1.8c (SSJ3 amarillo, rojo en Dios); la Q usa la copia que la lanza (`G2V_QC`).
- **Formas por muertes** en lugar de la X: 90/70/50/30/15 % de la oleada suben a SSJ, SSJ3, Dios, Blue y Ultra Instinto. Duran la oleada y vuelven a base al terminar (`G2_Base`). En 2.1a no hay SSJ4.
- **Instant Transmission** (AGk5): sólo a una unidad; el cuerpo aparece a 90 detrás del blanco, o sobre él si no se puede pisar.
- **Kaioken:** el dummy se coloca en el cuerpo y el buff se lee del cuerpo.
- **Modelo:** Goku21.mdx (Goku_squished de 2.1a con sus dos texturas renombradas a `G21_*`), icono de vida y frente del MVP propios.
- **Recursos:** 108 importados, 22 iguales a los nuestros. Con otro contenido en 2.1a se quedan los nuestros (versiones aligeradas): ValkDust.blp, new poff.blp, BTNSaiyanForm, BTN_O_Whitebeard, ChoOdamaRasengan1.mdx, SS.mp3, Slam.mdx, db_flying2.mp3, deathball_fire.mp3, kamehameha_fire2.mp3, laserkyuubi.mdx (`fuentes/goku21-informe.txt`).
- **Sonidos 3D** (indicación de Leon): todos los sonidos de técnica de Goku, Freezer, Trunks y Naruto se crean 3D con los parámetros de los disparos de v17d (600/10000, corte 3000, canal 11). Suenan en la copia que lanza la técnica o en el cuerpo de ese personaje (`Son_DONSuena`); la carga de Goku suena en su cuerpo. 55 archivos: 44 ya mono, 11 pasados a mono MP3 22050 Hz 64 kb/s como `M3D_*` (0,29 MB). Música, voces y sonidos de interfaz no cambian.

Créditos y procedencia: modelos, texturas, sonidos y código de Goku vienen de Battlestadium D.O.N 2.1a (`~/Descargas/Battlestadium DON 2.1a.w3x`, sólo leído), de sus autores.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21e.w3x | `fafe5c841bb48bca4616b1d745682573e04b2bf130f7195acddd6353096a89d0` |
| TerrainDev-Titulo-v21e-prueba.w3x | `8672d8763ba676ef616ae17c1ce03fa52e0e9b68c5f8e9355d3aabe25a713d10` |

Comprobaciones:
- pJASS correcto en las dos variantes; máximo de elseif seguidos 88 (Tut_Guion, ya existía).
- Reextracción por hash del j, los cuatro objetos, el imp y los 119 imports nuevos.
- `bytes-diff` sólo cambia (attributes), (listfile), war3map.j/w3u/w3a/w3h/w3b/imp; `mpq verify` correcto.
- Copia en WOE comprobada con cmp.

Estado **Validated**: no se ha jugado.

Pendiente de probar en el mapa:
- que los MP3 mono suenen en 3D (v17d usaba WAV) y que los sonidos del juego que usa D.O.N sean mono;
- la Ultimate en cada forma, las subidas de forma con las muertes y la vuelta a base;
- Instant Transmission sobre unidades y terreno no pisable;
- la carga del Saiyan sobre el cuerpo y el dummy del Kaioken;
- la escala del MVP y del retrato con el modelo nuevo.

## v21f: correcciones de Goku tras la prueba de v21e

Prueba de Leon con v21e (normal, sin registros): la R "no castea nada, solo sale el dummy y desaparece" y el retrato sale sin cabeza. Pide una X que transforme tras una carga, para probar las Ultimate de cada forma.

- **R:** el A0BZ de 2.1a tiene como base el Impale de criaturas (ACmp, orden impale). En v21d la copia lanzaba la R con Rain of Fire (ANrf) y funcionaba. v21f vuelve a esa fila (sin daño, 0,01 s) con los textos e icono de 2.1a, orden rainoffire. El código de 2.1a sólo lee la habilidad, quien la lanza y el punto. Si la copia no acepta la orden, aparece un aviso. Causa **no confirmada en el juego**: el código y los objetos no explican por qué fallaba Impale; la prueba lo dirá.
- **X Transformación (AGk4):** sube una forma con la carga de D.O.N (`G2_SubirX` → `G2_Subir`), 25 de maná, 10 s de recarga. Entra en el libro (técnica 44, tecla X); `-pj` la da. La forma sigue volviendo a la base al acabar la oleada.
- **Retrato:** 2.1a usaba un plano con el icono (`Goku_squished_portrait.mdx`). `retrato_goku21.cjs` crea `Goku21_portrait.mdx`: el cuerpo más la cabeza base (NormalHeadGoku) colocada en el pivote de Head Ref y pegada a Bone_Head. El retrato no cambia de cabeza con la forma. No se vio en un visor: Forge corre sin interfaz.
- Registros en v21f-prueba (`lat\v21f-don.txt`): resultado de la copia de la R con la forma, forma al dispararse la Ultimate y subidas con X.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21f.w3x | `41004810ce339aeddbd3067229cc9a0632fa2a4715a9708a0dfcbe590abc8aa7` |
| TerrainDev-Titulo-v21f-prueba.w3x | `77126f7d37dfba3f0bf87a0f18769554bf6597528c988adb80c774bfea87a6c5` |

Comprobaciones: pJASS correcto en las dos variantes; reextracción por hash del j, w3a, imp y el retrato; `bytes-diff` sólo cambia (attributes), (listfile), j, w3a e imp; `mpq verify` correcto; copia en WOE con cmp. Estado **Validated**.

Resultado de la prueba de Leon (v21f-prueba, registro `lat\v21f-don.txt`): la R sale por la copia en las 6 formas ("goku R copia 1") y la X sube de forma 2 a 6. Quedan tres fallos, que corrige v21g.

## v21g: fin de la R en SSJ3, bucles de forma y E = Revert

Leon: el sonido en bucle de la transformación sigue sonando; en 2.1a la E devolvía a la forma normal; la R en Super Saiyan 3 "parecia no parar su efecto y seguia el shake de la camara sin parar".

- **R en SSJ3 (Dragon Fist):** al acabar, DragonFist2 devuelve la copia al punto del golpe con `Don_Pon`. El salto mide ~2275 y `GroundCollision.trace` lo recorre de 8 en 8 con 9 sondeos por paso: el hilo se corta por el límite de operaciones justo después de `DisableTrigger`. No llegan a ejecutarse `Gk_SacudeQuitar`, `PauseUnit(false)` ni la retirada del puño. Pruebas en el registro: copia c8 pausada hasta k300, movió 2925 (= 65×10 antes del golpe + 35×65 después), el disparador ya apagado en k100 y el puño h0A4 vivo 8 s después. Arreglo: `Don_Pon` no traza saltos de más de 400 (los pasos de cada tick siguen trazándose). Red de seguridad en `Dcp_Tick`: si la copia de la R queda pausada cuando la Ultimate ya no está en curso, se despausa y se quita la sacudida de todos. Causa deducida del registro y del código, **no confirmada en el juego**.
- **Bucles de forma:** `super_saiyan_aura` (SSJ), `aura_power_fluxing` (SSJ3) e `instinctauraloop` (UI) empezaban al llegar a la forma y sonaban toda la oleada. Ahora suenan sólo durante la carga y la llegada a la forma los corta.
- **E = Revert:** en 2.1a la E era Revert (A0CZ, Aroa, 5 s, 1 de maná, `BTNRevert.blp`), mismo cuerpo que `G2_Base`. La Transmisión Instantánea (A0PM) estaba en la T. AGk5 pasa a Revert sin objetivo (`G2_Revertir`), icono de 2.1a importado. La Transmisión sale del kit: el libro tiene 5 técnicas por héroe (40-44 Goku). Volverla a poner en la T necesita ampliar ese paso.
- Registros en v21g-prueba (`lat\v21g-don.txt`): E con la forma de partida y el rescate de la copia, si ocurre.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21g.w3x | `11f09ad05c010e8d1ae43a54ec6f1275023ef5587a18adf8dd20d72bdd7fe4b0` |
| TerrainDev-Titulo-v21g-prueba.w3x | `f37df5c56b7e5ece733e2b6389145a656a082bd20804955267c81f345df82b7d` |

Fuentes: `scripts/v21g.py`, `scripts/objetos_v21g.py` (`fuentes/v21g-obj`), `fuentes/v21g.tsv`, `scripts/hacer-v21g.sh`, lanzadores `entrar-v21g*.sh`. Comprobaciones: pJASS correcto en las dos variantes; reextracción por hash del j, w3a, imp y el icono; `bytes-diff` sólo cambia (attributes), (listfile), j, w3a e imp; `mpq verify` correcto; copia en WOE con cmp. Estado **Validated**.

Resultado de la prueba de Leon (v21g-prueba): la R de SSJ3 suelta la copia en k85 sin rescate; la E vuelve a la forma 1 desde 6 y desde 4; la R sale en las 6 formas. Leon: "mejor". Pide que las piezas de la carga sigan a Goku y que la sacudida de la transformación sea leve y no permanente.

## v21h: carga que sigue a Goku y sacudida corta

- La pieza h0EY de la carga se mueve con Goku cada tick (las chispas salen de ella) y BitchAura/SaianAura se cuelgan del héroe (`origin`). En D.O.N el héroe queda quieto en la carga; aquí sigue libre.
- La carga ponía sacudida 3 y la llegada a Ultra Instinto 8, sin nada que las quitara. Ahora ambas son 3 y `G2_SacudeFin` las quita 0,5 s después de llegar a la forma, sólo a quien sigue con esa sacudida (`Sacude_Mag` = 6).
- Pendiente de decidir: **Kaioken** (R en forma 5). En 2.1a un dummy lanza A0JF (Inner Fire, orden innerfire) sobre Goku: buff B05J de 25 s en héroes (+100/150/200/250 % de daño de ataque por nivel, +10 de armadura, 0,5 de regeneración), y la Kamehameha pasa a su versión Kaioken mientras dura. Aquí no se aplica: A0JF sólo admite héroes ("hero" en los blancos) y Goku es una unidad normal, que además tiene 0,1 s de duración. Sólo quedan los efectos y la sacudida.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21h.w3x | `3033f71cc0b73bdef3b356caf447675d12b4e82320823c9e0263b277d10ae8b5` |
| TerrainDev-Titulo-v21h-prueba.w3x | `a76c4c90759f64067fd045adba8799169b1130a2481c0da1b2fb8d8e132cb7bf` |

Comprobaciones: pJASS correcto en las dos; sólo cambia el j (reextraído por hash); `mpq verify` correcto; copia en WOE con cmp. Estado **Validated**.

## v21i: Kaioken adaptado

Leon acepta la adaptación y pide que el daño extra, "como el don", se aplique a las armas que tenga.

- A0JF: blancos sin "hero" y 25 s también en unidades normales (`objetos_v21i.py`). El dummy ya apuntaba al cuerpo real (`G2V_Caster[7150]`), no a la copia.
- `Her_Dano` (daño de todas las armas del jugador) multiplica por 1 + `Kai_Bono[p]` mientras el cuerpo de Goku de ese jugador tiene B05J. `Kai_Bono` = 0,5 + 0,5 × nivel de la R (el Inf1 de A0JF: +100/150/200/250 %). Revert y las subidas de forma quitan B05J, y con él el bono.
- La Kamehameha Kaioken (forma 5 con B05J) ya estaba en el código de 2.1a y ahora puede activarse.
- Registros en v21i-prueba: bono al lanzar y si el buff está puesto 0,5 s después.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21i.w3x | `b4297b526cdc62e1ba668fa6d4084ebaa128241b0a8a6b4e48d3222756aeb1ba` |
| TerrainDev-Titulo-v21i-prueba.w3x | `6a700266ae66ece42a2a72e83c2ba40c2c3c4c29d66fcb3769a761ebed568077` |

Comprobaciones: pJASS correcto en las dos; reextracción por hash del j y el w3a; `bytes-diff` sólo cambia (attributes), (listfile), j y w3a; `mpq verify` correcto; copia en WOE con cmp. Estado **Validated**.

## v21j: el rayo no cruza árboles ni pendientes

Leon: "me parece el kameha traspasa arboles"; pide revisar también la R y la Genkidama.

Revisión estática de las técnicas que se mueven (`Don_Pon` traza el paso con radio 24 y frena ante árboles vivos, destructibles con oclusión ≥ 32 y terreno no transitable, sólo si la pieza vuela por debajo de 150):

| Técnica | Pieza que avanza (altura) | Antes de v21j |
|---|---|---|
| Kamehameha (Q) | cabezas h00E/h00M (110-120) | La cabeza frenaba, pero el cuerpo del rayo se creaba en origen + 55 × tick sin corregir: seguía alargándose tras el árbol. |
| Super Kamehameha (R, SSJ) | cabeza h00E (110) | Igual, pero el rayo sólo sobresalía 50 (punto = cabeza + 50). |
| Genkidama (R, base) | bola hG2b (80 tras Amrf) | Frena: la bola se mueve con `Don_Pon` desde su posición y se queda en el choque hasta su tiempo. Radio de choque 24 en una bola grande: el modelo puede verse metido en el árbol. |
| Dragon Fist (R, SSJ3) | puño h0A4 (0) | Frena; la estela h03I puede asomar hasta 65 tras el choque. |
| Big Bang (R, Dios) | — | Sin recorrido: explosiones al azar alrededor del blanco. |
| Ultra Instinto (R) | la copia (paso 100) | Frena. |

v21j: el rayo del Kamehameha y de la Super Kamehameha mueve primero la cabeza y no añade tramo si `Don_Choco` (lo fija `Don_Pon`) indica choque. Sin cambios en la regla de choque.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21j.w3x | `444a0f1c84ce93824580529401a59248f3440cd8b684002dcb0212e8a0087719` |
| TerrainDev-Titulo-v21j-prueba.w3x | `292e3bc106e83d62dad5adb3c9ab1d069a5653921e5e6906a1e0687d796e87b8` |

Comprobaciones: pJASS correcto en las dos; sólo cambia el j (reextraído por hash); `mpq verify` correcto; copia en WOE con cmp. Estado **Validated**; la revisión de la tabla es lectura de código (**Scanned**), no prueba en el juego.

## v21k: la Q se queda en el choque

Vídeo de Leon con v21j-prueba: la Q seguía cruzando el bosque. Causa: el punto de cada tick es origen + 55 × tick; con la
cabeza frenada la distancia crece y, pasados 400, `Don_Pon` no traza (regla de v21g) y la cabeza salta al otro lado. v21k
no avanza el tick mientras la cabeza choca (`Int[7150]` vuelve atrás). Informe en `informes/errores/` (goku-q-cruza-arboles).

La R en Super Saiyan (Super Kamehameha) "va lento" no es el terreno: es la regla de D.O.N que baja el avance de 50 a 10 por
tick si hay cualquier enemigo a 400 o menos de la cabeza (choque de rayos). Con oleadas casi siempre hay enemigos: pendiente
de decidir con Leon cómo adaptarla.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21k.w3x | `4704b855c4463b748a94a230247b6172a97183554981cabc321a9c87f07174c4` |
| TerrainDev-Titulo-v21k-prueba.w3x | `1e7dc00238f45625c35fcb2e8f9195381dde6f13216be3e08a924f6de2545d03` |

Comprobaciones: pJASS correcto en las dos; sólo cambia el j (reextraído por hash); `mpq verify` correcto; copia en WOE con
cmp. Estado **Validated**.

## v21l: Ultra Instinto avanza libre

Leon vio la Q bien en v21k-prueba (registro: choca en paso 11, parada 50; en libre llega a 60) y pide conservar el frenado
de la Super Kamehameha. La R en Ultra Instinto es de área: la copia avanza con SetUnitX/SetUnitY, sin choque.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21l.w3x | `80a935a0725517534efc76cd3c5ef1f73df48547a34410f9409d9ecfe2219a34` |
| TerrainDev-Titulo-v21l-prueba.w3x | `8e49586069a28966999a542cf0e6fd8cb0f06eec6060359847f1f8d2c965ad43` |

Comprobaciones: pJASS, reextracción del j, `mpq verify` y copia en WOE con cmp. Estado **Validated**.

## v21n: Freezer de 2.1a con tiers

Fase 3. Código de Freezer de 2.1a trasplantado (`fuentes/fz21-j`, `scripts/v21n.py`), objetos `objetos_fz21.py`
(`fuentes/fz21-obj`), 25 recursos (`recursos_fz21.py`, `fuentes/fz21.tsv`). Tiers como Goku en v21m. Daño por enemigo
en T6: Q 2900, W 2000, E 2000, X 1500, R 5800. Recargas sin maná: Q 20, W 30, E 30, X 30, R 90 y T 80 s.

- Regla de Leon (22/11): "habilidades que toman un target en la explosivo o momento que hace danio deben hacerlos en
  area para que ayude en las oleadas". `Fz_Area`:
  - W da a todos en 600 una vez;
  - E da en 200 por puñetazo y 350 en el remate;
  - R da el 60 % en 700;
  - X da con cada disco una vez por enemigo (`G2F_WAVE` propia).
- Golden Form (T): hFrz pasa a hFrG con copias hCpH, durante 35 s. Da +25/50/75 % de daño de armas con el buff B025
  (`Her_Dano`).
- Luz: `Luz_Ajustar` la vuelve a poner al cambiar el tipo del cuerpo y a los 0,6 y 1,2 s.
- La X sale como proc de armas, con 10 s entre discos. Se quita Power Up por muertes. Se corrige la fuga del Warp
  Kamehameha (`G2V_Group[5850]`).

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21n.w3x | `7ddf57625b51a79f871658b143580a51b6142f9ce05fde1384e72c91fedab65d` |
| TerrainDev-Titulo-v21n-prueba.w3x | `bf793f493cb0b8ac20c655af4c7b9b76557e62b5e1b8c542d67c9689c8a7e3ec` |

Registro de v21n-prueba (Leon, un jugador):
- Q, E, R y X hacen el daño de T1 esperado (725, 500, 1450 y 187 por disco).
- La W no se lanzó: la copia acepta la orden y la suelta, sin CHANNEL.
- Golden termina a 1,1 s y el cuerpo sigue en hFrz.

## v21o: Golden y W

- **A0OH (Golden).** El cuerpo hFrz deriva de Hmgd, que es héroe. Por eso la duración del efecto es ahdu 35, y adur es
  el tiempo de transformación. v21n había puesto adur 35, así que el `stop` del código cancelaba la transformación al
  segundo. Ahora se quitan las filas adur (`objetos_v21o.py`, `fuentes/v21o-obj`). Causa confirmada en
  AbilityData.slk: ANcr Dur 0,35, HeroDur 15.
- **A0JD (W).** El nivel 1 tenía objetivos "none"; ahora usa los de los niveles 2-4. Es la causa probable, pero no está
  comprobada.
- **Registro de prueba.** El de Golden da el tipo del cuerpo.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21o.w3x | `7049da8368231a768ffbeff526e028e482c8d12e194ecc816cd60970ba64c459` |
| TerrainDev-Titulo-v21o-prueba.w3x | `70af13071db7d08ba88d99f9e6695beac8600342e0e439abe5047ff7867d7fd6` |

Comprobaciones de v21n y v21o:
- pJASS correcto;
- reextracción por hash;
- `mpq verify` correcto;
- copia en WOE con cmp.

Estado **Validated**. En v21o falta jugar la W, Golden (modelo, duración y bono) y la luz tras el morph.

## v21p: W con base ANrf

Registro de v21o-prueba:
- Golden ya transforma (`ENDCAST hFrG A0OH`).
- La W sigue sin empezar con objetivos válidos. Leon: "como es error de antes el dummy se queda sin lanzar".
- Es el mismo caso que Dragon Fist en v19e (base Impale con distancia de onda de D.O.N). Ver
  `informes/errores/2026-11-19-devmission-don-copias-sin-lanzar.md`.

Cambio en v21p:
- A0JD pasa a base ANrf con los datos de Death Ball (`objetos_v21p.py`, `fuentes/v21p-obj`).
- El puente AFz5 pide la orden `rainoffire` (`v21p.py`).
- El disparador de 2.1a sólo lee GetSpellAbilityId y GetSpellTargetLoc.

Pendiente: en v21o-prueba, una pulsación de Q a 11 s dio "copia NO ACEPTA" (blanco a 933, alcance 2500). Las Q
siguientes de v21n sí salieron. Sin causa: vigilar.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21p.w3x | `fefd29490ab975f1093f95dd12d5f22c18e0d7930c10ed02886c53ac0fa47b60` |
| TerrainDev-Titulo-v21p-prueba.w3x | `d552bff24f234270d5b63139caade0ffdca6b67780902e519dcf2bc116f318b9` |

Comprobaciones: pJASS, reextracción por hash, `mpq verify` y copia en WOE con cmp. Estado **Validated**.

## v21q: Golden Form con tiers

Leon confirma que v21p va bien y pide "agregemosle tier tambien a la trasformacion golden para que haga buen danio al
tier maximo" (`scripts/v21q.py`, sólo el j).

- **Explosión al transformarse.** Daño de tier en 600 (`Fz_Area`, `Gk_TDano(…,50,4350.)`). Antes era 6 × fuerza en 500.
- **Bono de armas.** Vale 0,75 × curva del tier: T1 19 %, T2 26 %, T3 34 %, T4 45 %, T5 60 %, T6 75 %.
- **Libro.** Tec 50 con `Tec_Max` 6 y `Tec_T6` 4350. El nivel real de A0OH sigue llegando hasta 3.

| Mapa | sha256 |
|---|---|
| TerrainDev-Titulo-v21q.w3x | `f5361eeec5c9fb83c36a849fb45529d13169ebb2a11a365333a0e3cfdc09d6f4` |
| TerrainDev-Titulo-v21q-prueba.w3x | `942ef39d710b05838a32b0e03c159308404377ceb3b4906b895ff720d6e9cfb1` |

Comprobaciones: pJASS, reextracción por hash, `mpq verify` y copia en WOE con cmp. Estado **Validated**.

## v21r: regla de área en Goku

Revisión de los golpes de Goku en v21q: Kamehameha (400 en la punta), Homing/Ultimate (300), Super Kamehameha (400),
Ultra Instinto (400/700) y Spirit Final (1000) ya dañan a todos los enemigos del radio. Dos técnicas elegían un solo
enemigo al azar y ahora dañan en área alrededor de él con `Fz_Area`, una vez por enemigo y lanzamiento:

- Warp Kamehameha (W): 20 golpes; cada uno 250 alrededor del enemigo elegido (grupo `G2V_Group3[56]`).
- Dragon Fist (R): un puñetazo cada 0,04 s; cada uno 200 alrededor del enemigo elegido (grupo `G2V_Group2[43]`).

Fuentes: `scripts/v21r.py`, `scripts/hacer-v21r.sh`, `scripts/entrar-v21r*.sh`. Sólo cambia el j; w3a de `fuentes/v21p-obj`.
Mapas: v21r `3296935969a3…`, v21r-prueba `c32bea80140e…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción, mpq verify). Sin jugar. En prueba, Goku registra W en la ranura 1 y R en la 2.

## v21s: Future Trunks de 2.1a con tiers y área

Leon: "pasala a area y vamos con trunks". Mismo método que Freezer (v21n): código de H037 Sword Warrior de 2.1a
trasplantado con prefijo G2 (`scripts/tr21_trasplante.py`, init `G2Y_InitDON`; el `Tr_InitDON` de 1.8c ya no se llama).

| Tecla | Técnica | Real | T6 por enemigo | Área |
|---|---|---|---|---|
| Q | Burning Attack | A05B | 2900 | barrido 250 y 20 elegidos; luego el resto en 800 |
| W | Finish Buster | A0GV | 2000 | barrido 300 y explosión 500 (ya era área) |
| E | Heat Dome Attack | A086 | 2000 | 15 elegidos y luego el resto en 400 del blanco |
| R | Final Hope Slash | A03W | 5800 | 15 cortes y luego el resto en 500 de la explosión |
| T | Sword of Hope | A0I5 | 4350 | 600 alrededor de Trunks (ya era área) |

- Una vez por enemigo y lanzamiento en todas. Puentes sin maná: Q 20 s, W 30 s, E 30 s, R 90 s, T 80 s.
- Sword of Hope: la lanza el cuerpo (Dcp_EnHeroe), fila de 2.1a con la espada en la mano (buff B05L, 18 s). Ya no
  pide SSJ (con las formas por muertes el botón quedaba muerto al empezar cada oleada). Mientras dura, armas con
  0,75 × curva (T6 +75 %), mismo `Fz_Bono` que Golden.
- Formas por muertes (25 SSJ, 50 SSJ2) con el código nuevo; se quita el Finish Sign automático de las 75 muertes.
  La forma dura hasta el final de la oleada (`Frm_Corte`). Cabezas de 2.1a (TrunkHead, SS2, SS3) en cuerpo, copias y MVP.
- Cuerpo y copia: modelo TrunkNormal (escala 0,85 de H037). Frente del MVP `MvpFrenteTrunks21`. Q, W, E y R conservan
  nuestras filas (A03W con alcance 1000 de 2.1a y nombre Final Hope Slash). Cartas DK0B-DK0G con los iconos de 2.1a.
- Sonidos de Trunks en 3D; FinishBuster (estéreo) usa `M3D_FinishBuster` (ya en el mapa).
- Registro de prueba: "trunks dano Q/W/E/R/T" (Gk_Suma 10-14; el 9 es de los temporizadores) y "trunks Sword bono".

Fuentes: `scripts/objetos_tr21.py`, `recursos_tr21.py`, `v21s.py`, `hacer-v21s.sh`, `entrar-v21s*.sh`;
`fuentes/tr21-j`, `tr21-obj`, `tr21` (28 recursos, 1,7 MB, texturas ≤ 512), `tr21.tsv`, `tr3d-cambios.tsv`.
Mapas: v21s `efaab6eaa563…`, v21s-prueba `ea3ef8aed78d…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción del j, objetos, imp e imports, mpq verify). Sin jugar.
Sin comprobar: escala de `Pj_Fijar` (175/194, del modelo viejo) para el nuevo modelo; aspecto del frente del MVP.

Prueba de Leon con v21s-prueba (22/11, unos 3 min 46 s desde la oleada 6, sin -gt): **Tested in map** en T1. Daño
por golpe Q 725, W 500, E 500, R 1450, T 1087,5; área con hasta 15 enemigos (R). Bono de Sword of Hope +18,8 %
calculado; no visto en las armas. Sin cambios de forma. 1 de 6 W rechazada ("copia NO ACEPTA ... ward", 108,2 s);
anotada en `informes/errores/2026-11-19-devmission-don-copias-sin-lanzar.md`.

## v21t: W de Trunks con Channel

- A0GV (Finish Buster) pasa de Serpent Ward (AOsw), que coloca un guardián y se rechaza en suelo no transitable, a
  Channel (ANcl): blanco punto, visible, sin espera, orden propia `clusterrockets` (sin uso en el mapa). Se quitan
  las filas Hwe2; alcance 2500, niveles y textos iguales. El código de D.O.N sólo usa el id y el punto.
- `Don_BotOrden` de ATr2 pasa de "ward" a "clusterrockets". Prueba: registros `lat\v21t-*`.

Fuentes: `scripts/objetos_v21t.py`, `v21t.py`, `hacer-v21t.sh`, `entrar-v21t*.sh`.
Mapas: v21t `feada95568e2…`, v21t-prueba `066558b116bf…`; sólo cambian j y w3a; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción, mpq verify). Sin jugar.

Leon jugó v21t (sin registro de la W): la W ya sale; la esfera atravesaba árboles y precipicios.

## v21u: piezas por el aire también chocan

- Leon: "que se comporte como todos los demás ... aquí aplica con árboles y precipicios". `Don_Pon` dejaba sin choque
  las piezas con altura de vuelo >= 150 (v16u); la esfera de Finish Buster vuela a 300. Se quita la excepción: toda
  pieza de Freezer, Trunks y Naruto colocada con `Don_Pon` se queda en el último punto libre, como las de Goku
  (`Gk_MisPaso`). El final sigue siendo el de D.O.N: la esfera espera ahí y explota al acabar su vida (1,73 s).
- Afecta a todas las técnicas de D.O.N que mueven piezas en el aire con `Don_Pon`, no sólo a la W. Se mantiene el
  límite de 400 por paso (v21g).

Fuentes: `scripts/v21u.py`, `hacer-v21u.sh`, `entrar-v21u*.sh`. Sólo cambia el j.
Mapas: v21u `149f79babe37…`, v21u-prueba `641af6eff2a4…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción, mpq verify). Sin jugar.

Leon jugó v21u-prueba con Trunks: "fue bien" (la W choca con árboles y precipicios).

## v21v: formas por tiempo, X de Trunks y bonos por forma; retrato de Trunks

- Leon: "la duración sería por tiempo, también aplicaríamos con Goku", la velocidad de ataque de las formas pasa a las
  armas, y "con transformaciones las habilidades podrían ganar un plus de daño ... aplicaría a todas".
- X de Trunks (Power Up, técnica 56): carta de un nivel, como la X de Goku. Carga de 1 s de D.O.N y una forma más
  (base → SSJ → SSJ2). Puente ATr1 a 10 s sin maná, directo al cuerpo (`Tr_SubirX`), no al A0H5 de D.O.N (Big Bad
  Voodoo, 10 s canalizando). Al acabar la carga se quitan la pieza h0G1 y las dos auras, que D.O.N dejaba.
- Duración: cada forma de Goku y Trunks dura 50 s (`Frm_DURA`) desde que se alcanza; subir de forma reinicia el tiempo;
  luego vuelve a la base (`Frm_Reloj`, cada 0,25 s desde `Tec_Vigila`). La oleada ya no corta las formas. Las muertes
  dan cada forma una vez por oleada (`Frm_Dado`).
- Cadencia de las armas: +25 % por forma sobre la base (`Arm_IntJ`): Trunks SSJ +25 %, SSJ2 +50 %; Goku hasta +125 %
  en Ultra Instinto. Las ráfagas de 1,5 s llevan más tiros.
- Daño de técnicas: +20 % por forma en `Gk_TDano` (todas las técnicas con tier de Goku y Trunks): Trunks hasta +40 %,
  Goku hasta +100 %. Freezer y Naruto sin cambio.
- Retrato de Trunks: "sale sin cabeza". Como Goku en v21f, la cabeza es un modelo colgado (A07X) y el retrato no dibuja
  lo colgado. `TrunkNormal_portrait.mdx` (`retrato_tr21.cjs`): TrunkNormal más TrunkHead pegada a bone_new12, con la
  cámara a la altura de la cabeza (la original miraba al pecho, Z 165; la cabeza va de 191 a 235). Sólo la cabeza base.
  No se revisó en un visor 3D: el encuadre sólo se comprobó con números.

Fuentes: `scripts/v21v.py`, `objetos_v21v.py`, `retrato_tr21.cjs`, `hacer-v21v.sh`, `entrar-v21v*.sh`,
`fuentes/v21v.tsv`, `fuentes/v21v-obj/`. Cambian el j, el w3a, el imp y un recurso nuevo.
Mapas: v21v `4884bb389c7f…`, v21v-prueba `2093f2e32501…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción, mpq verify). Sin jugar.

Leon jugó v21v-prueba (oleada 6, Q/W/E/T de Trunks bien): "hace falta agregarle la habilidad X". El registro no tiene
ninguna pulsación de X: ATr1 nunca se ponía en el controlador (v21s lo dejó fuera).

## v21w: botón X de Trunks

- ATr1 (Power Up) se añade al controlador de Trunks junto a Q/W/E/R/T, en la casilla (1,1) como la X de Goku.
- Icono de 2.1a ya importado (`war3mapImported\BTNPowerupTrunks.blp`) en lugar de BTNReincarnation.

Fuentes: `scripts/v21w.py`, `objetos_v21w.py`, `hacer-v21w.sh`, `entrar-v21w*.sh`, `fuentes/v21w-obj/`. Cambian el j y
el w3a. Mapas: v21w `57f6563ab095…`, v21w-prueba `0251ba9ef534…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción, mpq verify). Sin jugar.

Leon jugó v21w-prueba: la X sale y transforma (el registro de técnicas sólo anotó el inicio). Pidió que el efecto de
la transformación siga a Trunks, como el de Goku.

## v21x: el efecto de la transformación sigue a Trunks

- Las dos auras de la carga (BitchAura, SaianAura) cuelgan del origen del cuerpo en lugar de quedarse en el suelo, y la
  pieza h0G1 se mueve con Trunks en cada paso de la carga (0,04 s), como Goku desde v21h.

Fuentes: `scripts/v21x.py`, `hacer-v21x.sh`, `entrar-v21x*.sh`. Sólo cambia el j.
Mapas: v21x `e19cfc6f86e3…`, v21x-prueba `905c12c55c42…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción, mpq verify). Sin jugar.

Leon jugó v21x-prueba, preguntó si la T de Trunks tiene tier y le sube el daño (sí: Sword of Hope T1-T6, 4350 por
enemigo en T6 y bono a las armas) y cerró Trunks: "perfecto, cerramos entonces, vamos con el siguiente pj". Pidió
"Naruto Kurama".

## v21y: Naruto Kurama de 2.1a, personaje nuevo en la celda 6

Naruto sabio (hNar/hNaK, celda 5) no cambia. Kurama es otro personaje (hKur, copia hCpU, celda 6, `-pj 6`).

- Código de 2.1a trasplantado (prefijo G2, `fuentes/nk21-j`): Q Rasenrengan (AKu1), W RasenKyuugan (A0K2), E Bijuu
  RasenShuriken (A0KY), R Bijuu Dama (AKu4), X Kyuubi Chakra Cloak (A0K5, en el cuerpo, buff B04L). Remapeos por choque
  con nuestro sabio: h0DI>hKu0, A0F5>AKu1, A0F3>AKu4. Puentes AKp1-AKp5 en el controlador; las cuatro primeras las lanza
  una copia, como el resto de personajes D.O.N.
- Tiers T1-T6 (técnicas 89-93 del libro; `Tec_EsTec` amplía el 40-77), daño por enemigo en T6: Q 2900, W 2000,
  E 2000, R 5800 (onda 2320 + explosión 3480). Partida normal sólo con Q; `-pj 6` con todas.
- Regla de área: Q, al volver el último de los 15 rasengan, el resto en 1000 del blanco; W, cada golpe también en 250
  alrededor del golpeado; E, tras los cortes de la explosión, el resto en 650; R, explosión en 700 al final de la onda.
  Una vez por enemigo en cada lanzamiento.
- X: 25 s de manto; mientras dura, las armas hacen 0,75 × curva del nivel (T6 +75 %), como Golden Form y Sword of Hope.
- Modelo de 2.1a (`NarutoKurama21.mdx`, sin su luz por el límite de 8), retrato propio con la cámara en la cabeza,
  frente del MVP limpio (sin efectos de muerte en resultados), icono BTNNaruto de 2.1a (Naruto en modo Kurama) en
  selección, rachas y barra (`HealthIconKu.mdx`, hbi7). Escala de la ficha 175/160.
- Sonidos 3D (Son_DONSuena k 4): M3D_bijustart, M3D_bijuudama, M3D_rasenkyuugan nuevos; M3D_Rasenrengan ya estaba.

Fuentes: `scripts/v21y.py`, `objetos_nk21.py`, `retrato_nk21.cjs`, `recursos_nk21.py`, `hacer-v21y.sh`,
`entrar-v21y*.sh`; `fuentes/nk21-obj/`, `fuentes/nk21-j/`, `fuentes/nk21/`, `fuentes/nk21.tsv` (40 imports),
`fuentes/nk3d-cambios.tsv`, `fuentes/nk21-informe.txt`. Cambian j, w3u, w3a, w3h, w3b, imp y 40 recursos.
Mapas: v21y `b1db6f376526…`, v21y-prueba `380cf672bfa0…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción de cada miembro e import, bytes-diff, mpq verify). Sin jugar.
Registro de prueba: "kurama dano" (Gk_Suma 15 Q, 16 W, 17 E, 18 R) y "kurama manto bono".

Leon jugó v21y-prueba: "funciona bien, solo seria ajustar el ulti que esta traspasando arboles y pendientes"; "la E
si funciona bien". Registro: Q 725 (T1) a 8 y 17 enemigos, W 500 a 10 y 11, E 500 a 13 y 4, onda de la R 580 a 16; la
explosión de la R no tocó a nadie (estallaba ~4000 más allá). La onda se anota como "freezer dano X T0" porque
G2F_WAVE usa la marca de Freezer; el daño sí es el del tier de Kurama.

## v21z: la Bijuu Dama choca con árboles y precipicios

- En G2F_WAVE (común con Freezer), la pieza de Kurama (hKu0) traza cada paso con GroundCollision como `Don_Pon` (v21u,
  radio 24). Si choca, queda en el último punto libre y muere; G2F_Bijuu_Dama_sfx hace la explosión (700, 3480 en T6)
  ahí. Las ondas de Freezer no cambian.

Fuentes: `scripts/v21z.py`, `hacer-v21z.sh`, `entrar-v21z*.sh`. Sólo cambia el j.
Mapas: v21z `2f1646d5fbff…`, v21z-prueba `7089b4198ad6…`; copiados a WOE e iguales por cmp.
Estado: **Validated** (pJASS, reextracción, mpq verify). Sin jugar. Registro de prueba: "kurama R choca en X Y".

## v22a: la Bijuu Dama espera su vida (22/11/2026)

Leon tras v21z-prueba: "va bien pero explota al chocar, debe cumplir su tiempo de vida, asi como la W, se para al chocar
y explora de acuerdo a su tiempo de vida".

- `scripts/v22a.py` sobre v21z / v21z-prueba: al chocar, la pieza `hKu0` ya no muere; su velocidad pasa a 0 y se queda
  en el último punto libre sin más trazos. Sigue dañando lo que entre en su radio (una vez por enemigo) y estalla
  (700, 3480 en T6) cuando acaba su vida de 2,5 s, como la esfera de la W de Trunks (v21u).
- `scripts/hacer-v22a.sh`, lanzadores `entrar-v22a.sh` y `entrar-v22a-prueba.sh`; registros `lat/v22a-*.txt`.
- v22a `0d4a6ec54554b6604d0d2c2d0b348caf58a6693c6cb898c110cadd978b9a1759`,
  v22a-prueba `9f26cb2047acd8ac05a0b12fe140137a5dcc2c3c268ee7db8772c92c25776c9f`.
- Validated: pJASS de los dos j, reextracción y cmp, sólo cambian `war3map.j` y `(attributes)`, `mpq verify`;
  copiados a WOE e idénticos.
- Registro de Leon con v22a-prueba (22/11, 3 min 35 s): 5 lanzamientos de la R, todos con "kurama R choca" (una vez
  cada uno). Las sumas de daño se escriben 6 s después del primer golpe: onda ≈23,2 s, choque 23,4 s, explosión
  ≈25,4 s (870 en T1, 1-4 enemigos). Las otras 4 siguen igual, choque y explosión separados 1,7-2,1 s, lo que encaja con la
  vida de 2,5 s contada desde la salida. Tested in map (un jugador); falta la valoración visual de Leon.

### Seguimiento del código de tiradas de Kurama (v22a, 22/11/2026)

Lectura del j de v22a (Scanned, sin partida). Cadena completa:
`Pj_Fijar('hKur', …, 89, 5)` → `Tec_Rango` da las técnicas 89-93 → `Her_Cartas` llama a `Tec_Cartas` (cartas 2 y 3,
también en las tiradas extra `Her_CartasExtra`) con el filtro `Tec_Puede` (rondas por tier como las armas: T2 ronda 1,
T3 2, T4 4, T5 6, T6 8) → al elegir, `Her_Aplicar` → `Tec_EsTec` → `Tec_Aprender` sube `Tec_Niv` y `Tec_Aplicar`
pone el nivel real en el cuerpo (tope 4/4/3/4/1) → la copia `hCpU` copia ese nivel al lanzar.
Daño por tier con `Gk_TDano` (curva .25/.35/.45/.6/.8/1; `Frm_Nivel` es 0 para Kurama):
Q 92 2900 (golpe y área 1000), W 91 2000 (golpe y área 250, dos ramas), E 90 2000 (golpes y área 650),
R 89 onda 2320 + explosión 3480 = 5800. Manto 93: `Ku_Manto` pone `Fz_Bono` = 0,75 × curva del nivel.
La Q empieza aprendida (`Tec_Ini[92]` 1); al reaparecer, `Tec_Empezar` vuelve a aplicar los niveles.
Iconos DK0N-DK0R y DT4K están en el w3b. Falta verlo en partida: comprar tiradas y subir un tier.

## v22b: Vegeta de 2.1a, personaje nuevo en la celda 7 (22/11/2026)

Leon: "vamos siguiente personaje entonces"; eligió Vegeta. Fuentes de 2.1a en `fuentes/vg21-j/` (glob, func), objetos en
`fuentes/vg21-obj/`, 18 imports en `fuentes/vg21/` (`fuentes/vg21.tsv`), informe en `fuentes/vg21-informe.txt`.

- `scripts/v22b.py` (sobre v22a / v22a-prueba) y `scripts/hacer-v22b.sh`; retrato con cabeza por `scripts/retrato_vg21.cjs`
  (como Trunks: el cuerpo de 2.1a no tiene cabeza, se le pega la del punto "head").
- Personaje `hVeg`, copia `hCpV`, icono `DT4V`, celda 7 (`-pj 7`), técnicas 94-98: R Final Flash 94 (T6 5800, área 1600
  a 800 delante), E Final Explosion 95 (2500, área 1000), W Galick Gun 96 (2000), Q Big Bang 97 (2900, empieza
  aprendida), X Power Up 98 (Max 1). Cartas DK0S-DK0W.
- Regla de choque: la Q (bola) y la W (rayo) se paran en árboles y precipicios y estallan/terminan al acabar su vida.
- Formas como Trunks: X sube base → SSJ → SSJ2 → Blue (rechaza en Blue); por muertes en la wave 25/50/75; vuelven a la
  base al acabar la wave (`Frm_Corte`). Se quitaron el fundido de pantalla de la R y las 5 escrituras de
  `SetUnitUserData` (conflicto con UnitIndexer); sonidos 3D con los parámetros de AnimSounds.
- v22b `40ccb99afb58052553c20505b536fdd461015723b3636a517a190a2368bed662`,
  v22b-prueba `94a447761f601693b7ea8f33be0f80af37b22b9b38ec311cc731d9c92aad7846`.
- Validated: pJASS de los dos j, reextracción, `mpq verify`; cambian j, w3a, w3b, w3u, imp, (listfile), (attributes) y
  entran los 18 archivos de Vegeta; copiados a WOE e idénticos (cmp).
- Sin comprobar: nada jugado; retrato y tamaño en la selección y el MVP; icono en la celda 7 del título; formas y sus
  efectos; daño real por tier. Registros esperados en prueba: "vegeta dano Q/W/E/R/X", "vegeta Q choca en",
  "vegeta W choca en", "vegeta forma N por X".

Leon jugó v22b-prueba el 23/11, 2 min 20 s en la oleada 6. Usó Q ×3, W ×2, E ×2, R ×1 y X ×3; las formas fueron
2, 3 y 4. Daño en T1:
- Q: 1014 a 9 enemigos y 1159 a 3;
- W: 699 a 14 y 799 a 1;
- E: 875 a 9;
- R: 2029 a 6.

Una Q y las dos W registraron choque. Copias limpias. Quedan **Tested in map** (un jugador) Q, W, E, R y X. Leon
reportó: "el efecto no sigue al personajes, y que la trasformacion deja un shake interminable".

## v22c: la X de Vegeta sigue al cuerpo y no deja temblor (23/11/2026)

- `scripts/v22c.py` (sobre v22b): el paso de carga mueve la pieza `h0G1` a Vegeta. `Gk_SacudeFinX` quita el temblor
  de la X (10) al acabar la carga en Vegeta y en Trunks. Prueba: "vegeta/trunks X temblor fuera N".
- v22c `3eb76de71a5f5d57516ed4a181aa20bcf964c2ceb3ea222256186d8fad883a3d`,
  v22c-prueba `03648e5ebd67b675eb9cc935d73da1ae6e904f049150c80049db423468913b9c`.
- Validated: pJASS, reextracción, `mpq verify`; solo cambian el j, `(attributes)` y `(listfile)`. Copiados a WOE.
- Informe (resuelto el 23/11): `informes/errores/resueltos/2026-11-23-030613-devmission-x-vegeta-trunks-efecto-temblor.md`. Lista para los personajes siguientes en
  la skill mapa-dev-mission (`references/importar-heroes-don.md`, "Fallos repetidos").

Leon jugó v22c-prueba el 23/11 (3 min) y dijo "fue correcto".
- Las 4 X registran "vegeta X temblor fuera 1".
- Formas por X: 2, 3 y 4. Al acabar la wave, "forma vegeta fin" (96,6 s); luego otra vez forma 2.
- R por forma: 1739 en forma 2, 2319 en Blue y 1450 en base.
- Q ×7, W ×6 (todas chocaron), E ×4, R ×6, con copias limpias.

Vegeta queda **Tested in map** (un jugador) y cerrado. Faltan las formas por muertes y los tiers por tiradas.

## v22d: Vegito de 2.1a en la celda 8 (23/11/2026)

Leon: "fue correcto, vamos al siguiente pj" y eligió Vegito.
- Fuentes: `scripts/v22d.py` (j), `objetos_vt21.py` (→ `fuentes/vt21-obj`), `recursos_vt21.py` + `retrato_vt21.cjs` +
  `sonidos_don3d.py` (→ `fuentes/vt21/`, `fuentes/vt21.tsv`, 15 archivos), `hacer-v22d.sh`, `entrar-v22d[-prueba].sh`.
- Técnicas 99-104 del libro: Q Banshee Blast (AVt1/A03E, T6 900 por explosión, 5 explosiones en 300), W Big Bang
  (AVt2/A033, 2000), E Spirit Sword (AVt3/A03F, a una unidad a 600, 2500 en 300), R Final Kamehameha (AVt4/A0DS,
  5800), X Power Up (AVt5/A0HL, formas 1-3) y Afterimage (104, pasiva con tiers, 1500; 2.1a no le daba evento: ahora
  al recibir un ataque a 300 o menos, cada 4 s). Partida normal: sólo Q; `-pj 8` todas.
- Libro ampliado: `Tec_Niv`/`Tec_Listo` pasan de `p * 100` a `p * 200` (27 sitios en la normal, 31 en prueba; índice
  máximo 2304). `Tec_EsTec` hasta 104; `Tec_Des` muestra "Pasiva." para una pasiva con tier.
- Lista de "Fallos repetidos": auras y pieza de la X en el cuerpo; `Vt_XFin` quita la sacudida de la carga
  (`Gk_SacudeFinX`); R, E y W tienen su `Gk_SacudeQuitar`; W y R se paran en árboles y precipicios (la cadena de la W
  estalla donde se paró la bola; la R deja de crear trozos parada); Q usa Homing (Don_Pon); todas en área; sin
  `CinematicFade` ni `SetUnitUserData`. Retrato revisado en el visor (cabeza en el cuerpo, cámara a 115 de "Head Ref";
  las formas no cambian la cabeza, sólo el aura de A0H4). La copia de Vegito lleva A0H4 (sólo Vegito; Trunks también
  la usa).
- Arreglos del trasplante: la imagen de Afterimage usaba una unidad de otra técnica (`G2V_Caster[4960]`); el primer
  golpe de la E se creaba en un punto aún sin crear; si el blanco de la E se retira, sigue en su último punto.
- v22d `6cdee0e40d2fd25fce2d38f2310c2c2f8691ce08c6149a32e38f792ddf31c6d5`,
  v22d-prueba `9983b5cc75cbae3d2487e6bf5df4ad84d687f0cbfa2cf000afd897da4f301f39`.
- Validated: pJASS de los dos j, reextracción del j, objetos, imp y los 15 recursos; `mpq verify`; cambian j, w3a,
  w3b, w3u, imp, (listfile) y (attributes). Copiados a WOE e idénticos (cmp).
- Sin comprobar: nada jugado. Registros esperados en prueba: "vegito dano Q/W/E/R/P", "vegito W/R choca en",
  "vegito forma N por X/muertes", "vegito X temblor fuera N", "vegito afterimage", "forma vegito fin".

## v22e: R de Vegito sin doble lanzamiento y retrato más arriba (23/11/2026)

Leon tras v22d-prueba: "funciona, detalle que el portrait esta algo bajo y la R parece que lanza otra luego de la 1ra".
- Tested in map (v22d-prueba, Leon): Vegito funciona; registros con "vegito dano Q/W/R/P", "vegito R choca",
  "vegito afterimage".
- Causa de la R doble (registro v22d-don.txt): la copia lanza A0DS a 46.734 y otra vez a 53.039 (k126), tras
  "vegito R choca". `G2F_SKTrail_vegito` despausa la copia y ésta retoma la orden previa a la pausa (las técnicas reales
  no tienen recarga). Vegeta, Trunks y la X de Vegito ya mandaban "stop" ($D0004); `v22e.py` lo añade tras despausar
  en la R y en la W (`G2F_bigbangv_vegito2`, mismo camino; no se repitió en el registro).
- Retrato: la cámara miraba a Z 184 (encuadre ~136-232 a 115 con 45°) y la cara quedaba bajo vida y maná;
  `retrato_vt22e.cjs` baja cámara y mirada 14 (mira a Z 170) → `fuentes/vt22e/Vegito21_portrait.mdx`.
- v22e `c45b5ca9bdc9c2724110a23a7e9226788c9f0c5b9d72022ae01ec5dfbf4cd3fd`,
  v22e-prueba `4aa13cc5a19dec67d05fbb788eaaa47ef0eca79b18dcc3e01be3eed22a35d67f`.
- Validated: pJASS, reextracción del j y del retrato, sólo cambian j, retrato, (listfile) y (attributes);
  `mpq verify`; copias WOE idénticas. Sin jugar. Registro esperado: "vegito R stop tras despausar" y un solo
  CHANNEL de A0DS por R.

## v22f: E de Vegito en el recorrido y Afterimage con copia (23/11/2026)

Leon: "durante el recorrido podria tambien realizar danio ... [Afterimage] lo puede hacer con una copia? y a cambio de
pegarle le lanzara una E, bajariamos su probabilidad" y "subele el radio a la E tambien, 550".
- Registro v22d: la E sólo daña en su golpe final (300 alrededor del blanco) y el arrastre aleja al blanco: 3, 1 y 1
  enemigos en 5 E (2 sin daño, probablemente blanco muerto durante el arrastre; no comprobado).
- `v22f.py`: `Vt_ERecorrido` en cada paso de los dos arrastres (spiritsword2 y 3): `Fz_Area` a 200 del blanco con la
  mitad del daño, una vez a cada enemigo (`Vt_EGrupo`, con el blanco dentro desde el inicio). Golpe final de 300 a 550.
- Afterimage: ya no mueve al héroe. Con un 25 % (4 s de espera tras saltar), si la E no está en curso, una copia lanza
  A03F al atacante (`Dcp_Lanzar`). Esa E usa el tier/base de Afterimage (104, 1500) y registra como "P". El evento de
  la E salta dentro de la orden, así que `Vt_EDeAfter` se pone antes de `Dcp_Lanzar` y se quita después (si no fuese
  inmediato, esa E usaría el tier de la E: se ve en el registro como "dano E").
- v22f `9a6a38aa2310165747a50ef731d7475bde3c48be5e9a02fc60e00130dcdfe6c4`,
  v22f-prueba `f4ce3dc90c4c8a30256a5ca9459300863d6475279dfc47437c02e2c2c135624f`.
- Validated: pJASS, reextracción del j, sólo cambian j, (listfile) y (attributes); `mpq verify`; copias WOE (cmp).
  Sin jugar (tampoco v22e). Registros esperados: "vegito dano E ... enemigos N" mayor que antes, "vegito afterimage E
  copia 1" y "vegito dano P" tras ella.

- Tested in map (v22f-prueba, Leon, ~85 s desde la oleada 6; registros evaluados):
  - E del botón: 2, 8 y 15 enemigos (antes 3, 1 y 1).
  - R: un solo CHANNEL de A0DS, "vegito R stop tras despausar" a 50.914, copia libre en k123 sin relanzar.
  - Afterimage: 3 veces "vegito afterimage E copia 1"; sus daños salen como "vegito dano P" (tier de 104: la marca
    funciona) con 5, 5 y 10 enemigos. Una E del jugador durante la de Afterimage quedó "ocupada 1" (rechazada).
  - Sin comprobar: el retrato de v22e (pendiente de Leon), tiers altos, formas y mensajes de la X.

- Leon (23/11): "funciona bien" (retrato incluido).

## v22g: E de Vegito con varias a la vez (23/11/2026)

Leon: "no soporta instancias verdad? ... la pasiva lanzo E, y si yo lanzo E manual ese ya no se lanza, deberian poder
ejecutarse mas independientes, 2-3 o mas".
- La E de 2.1a usa variables únicas (G2V_Caster[$B4]/[$B5], G2V_Point[$B4..$BC]) y dos disparadores periódicos.
  `v22g.py` la rehace por ranuras (`Vte_*`, 6): `Vte_Inicio` (acción de G2T_spiritsword, agarre con esperas propias) y
  un reloj de 0,04 s (`Vte_Tick`) para arrastre (cada 3 pasos = 0,12 s), empuje, golpe final y cierre. Mismos
  efectos, piezas, sonidos, temblor y deslizamientos; golpe del recorrido por ranura; "stop" al soltar la copia.
- `Dcp_Ocupada('A03F')` sólo con las 6 ocupadas; `Don_EnCurso('A03F')` = `Vte_Activas > 0`; Afterimage ya no mira
  `G2V_Caster[$B4]`. Los deslizamientos de 2.1a leen `G2V_Caster[$B4]`/`G2V_Point[$B7]`: se fijan sólo durante esa
  llamada. El temblor lo quita cada cierre para todos (como 2.1a).
- v22g `4ea224a5f8246017d8ba3dc5ca4ef6cc9a60510ae7ba370db70fa58653b69b1c`,
  v22g-prueba `4463719b5f51d9d7c613a0907553ddc90270bd240936d2abf1c61129cdeb7e6c`.
- Validated: pJASS, reextracción del j, sólo cambian j y (attributes); `mpq verify`; copias WOE (cmp). Sin jugar.
  Registro esperado: "vegito E ranura N activas M" con M ≥ 2 al juntarse botón y Afterimage, y sus "dano E"/"dano P".

- Tested in map (v22g-prueba, Leon, ~23 s): Afterimage lanza su E en la ranura 1 ("activas 1") y daña a 5 ("dano P").
  FALLO: el botón de la E a 18.094 da "curso 1 ocupada 0" y no crea copia: `Gk_Comando` mira `Don_EnCurso` antes que
  `Dcp_Ocupada`, y v22g hacía `Don_EnCurso('A03F')` = alguna E en curso.

## v22h: el botón de la E convive con la de Afterimage (23/11/2026)

- `v22h.py`: `Don_EnCurso('A03F')` = `Vte_Activas >= 6` (como `Dcp_Ocupada`). Consumidores revisados: `Gk_Comando`
  (botón), `Dcp_Tick` (suelta copias a k160 = 8 s si no está en curso; la E dura ~5 s y la copia se suelta antes por
  quedar sin orden), `Jun_*` (sigue mientras la copia esté pausada).
- v22h `5f853705e4b298c32ad636f73f3a0501eaee9368b054600e63dd5a8699d9d6a0`,
  v22h-prueba `c23eb7624fe4b9217b88033c42adde512c9348829ef6c04ad1c517c1d941167c`.
- Validated: pJASS, reextracción del j, sólo cambian j y (attributes); `mpq verify`; copias WOE (cmp). Sin jugar.

- Tested in map (v22h-prueba, Leon, ~95 s; registros evaluados): botón y Afterimage juntos: "ranura 2 activas 2"
  (8.594, 30.313, 89.438) y "ranura 3 activas 3" (22.391: dos de Afterimage y el botón). Cada copia se suelta en
  k94-k98; daños E (5, 5) y P (2, 6, 8, 12). R: un lanzamiento y "stop" en las 4. Afterimage saltó 8 veces en ~95 s
  (25 % por ataque con muchos atacantes, 4 s de espera).

## v22i (23/11/2026): probabilidad de Afterimage por tier

Leon: "ese 25 podria ser al tier maximo, tier 1 que sea menor". Afterimage (técnica 104) pasa de 25 % fijo a
10 + 3 × (tier - 1): T1 10, T2 13, T3 16, T4 19, T5 22, T6 25; espera de 4 s igual. Normal sobre v22h, prueba sobre
v22h-prueba; sólo cambia el j (`scripts/v22i.py`, `hacer-v22i.sh`). Registro de prueba: "vegito afterimage E copia N
tier T prob P".
- Validated: pJASS en las dos, reextracción igual, `mpq verify` correcto, sólo difieren war3map.j y (attributes).
- v22i `34f5874d24a5464cea7945cb5a4998b3836547705ce0445b3d9a522720ca8d4b`;
  v22i-prueba `d74be19b48ce300e7d02fdde8652437854aa5791604c0f9018484b908b34b75a`. Copiadas a WOE.

## v22j (23/11/2026): tabla de resultados con varios jugadores

Leon (capturas del 22/11, 5 jugadores): "se descuadra al jugar con varios jugadores, pero si se muestra bien si esta un
solo jugador, adicional que el espacio del danio ... deberia ser mas amplio".
- Causa: cada columna es un texttag de varias líneas, que crece hacia arriba desde su punto (243, primera franja):
  con N jugadores la última fila queda en la primera franja y las otras suben sobre el título y la cabecera.
- Cambio: el punto de las 7 columnas baja (Mvp_N - 1) × 20,805 (paso de las franjas). PuntTabla nueva
  (`scripts/puntos_v22j.py`, `fuentes/puntos-v22j/`): daño de ~60 a ~105 px; columnas en x 717/771/825/931/989/1047.
- Validated: pJASS en las dos; reextracción del j y de PuntTabla.blp iguales; `mpq verify` correcto; sólo difieren
  j, PuntTabla.blp, (attributes) y (listfile). Sin jugar: con un jugador no se ve el cambio de filas.
- v22j `bb373abf0c7b527c8d3b5a937a067dfbab77e5cb4460a48452a89cc2ceda5cab`;
  v22j-prueba `43363d01679c280e52eab72d73cde8b429ac4c8ae815e500b58c256ba2a3af45`. Copiadas a WOE.

## v22k-prueba (23/11/2026): "-tabla [N]" y revisión de los modelos del MVP

Leon: "crea un cuadro por comando de 8 jugadores con valores aleatorios nombre y personajes al final". Sólo prueba,
sobre v22j-prueba (`scripts/v22k.py`, `hacer-v22k.sh`): `-tabla [N]` (2-8, 8 por defecto) llena la tabla con nombres
de una lista (hasta 15 letras, colores de los jugadores 1-8), valores al azar (daño 1.000-9.999.999) y tipo al azar
entre h005, h006, hGok, hFrz, hTrk, hNar, hKur, hVeg, hVto para el MVP y el de menos puntos. Mvp_Modelo pasa por
Mvp_ModeloT (por tipo); Mvp_Preparar apaga el modo inventado (rondas reales iguales). Registro "-tabla N gana ...".
- Validated: pJASS, reextracción, `mpq verify`; sólo cambia el j. Sin jugar.
- v22k-prueba `7148a2dc25c1d6424072fb203670f64667c488cbf32612096dc771c42de09d2a`. Copiada a WOE.

Revisión pedida por Leon ("que no tenga efectos de muerte al morir o en general, practicamente como estan el cairne o
tauren"), Scanned sobre v22j:
- Objetos hMf0-hMf9: todos los campos iguales salvo modelo y nombre (Aloc, Avul, sin sonidos, sin arte especial).
- Modelos MvpFrente*.mdx de los 10: sin emisores de partículas ni cintas, sin eventos (sonido, salpicadura, huella),
  sin luces. Todos con Stand, Attack y Death, y el cuerpo sigue visible durante la muerte (alfa por secuencia).
- Duda sin comprobar: el de menos puntos se congela 1,2 s después de empezar Death. Death dura 2,0 s en Cairne y 3,1 en
  Tauren (se congelan a mitad), pero 1,0 en Goku, Naruto y Kyuubi y 0,6 en Vegito: terminan antes. Ver con -tabla si
  se quedan en el último fotograma o vuelven a Stand.

## v22l (23/11/2026): cuadro más ancho, lado del MVP reordenado, giro del jefe y cabezas

Leon tras v22k-prueba (captura con `-tabla`): nombres largos pisaban los números y 5 cifras tocaban el borde; tomar la
presentación del jefe como referencia del ángulo; mejor arquitectura del texto del cuadro MVP / menos puntos; Trunks
(MVP) y Goku (menos puntos) sin cabeza.
- Cuadro de 720 (antes 600): columnas 707/761/815/947/1007/1075, nombres en 479; PuntTabla/PuntLado nuevos
  (`scripts/puntos_v22l.py`, `fuentes/puntos-v22l/`). El lado lleva la etiqueta "PUNTOS" en cada recuadro: el número
  va sin " puntos", grande (0,032) y centrado; nombre arriba a la izquierda, recompensa debajo del número.
- Modelos del MVP: sin billboard (`scripts/mvp_sin_billboard.cjs` sobre los 10 MvpFrente*.mdx) y giro 0, como
  JefePres (tipo real a facing 0); escala 0,22, X 1250.
- Cabezas: en partida real A069 ponía otra cabeza y faltaban las de Vegeta; `Mvp_Piezas` usa NormalHeadGoku para
  A069 y añade A0O8, A080, A081, A0JN. En prueba, las filas inventadas de `-tabla` ponen la cabeza base por tipo
  (`Mvp_PiezaTipo`: Goku, Trunks, Vegeta).
- Hashes: v22l `eb84e9a3…`, v22l-prueba `a5409e8f…`. Validated (pJASS, reextracción por cmp de j, 2 blp y 10 mdx,
  bytes-diff limitado a esos miembros, mpq verify); sin jugar. Pendiente ver: ángulo, que la muerte corta (Goku,
  Naruto, Kyuubi 1,0 s; Vegito 0,6 s) no vuelva a stand antes de congelarse a 1,2 s, y el aspecto del nuevo lado.

## v22m (23/11/2026): modelos del MVP inclinados como el jefe; nombres que caben

Leon tras v22l-prueba (`-tabla 8`, captura): modelos tumbados (vistos desde arriba), "MMMMMMMMMMMMMMM" pisando BAJAS y
desbordando el cuadro de menos puntos, recompensa fuera del cuadro y sobre el modelo. "Segun el apartado de presentacion
de boss ... usa otro modelo inclinado para que cuadre con la vista".
- Error de v22l: quitar el billboard y girar la unidad a 0 no inclina el modelo (JASS no puede inclinar una unidad).
  PresJefe (jefe_modelos_v17h.py) lleva un giro fijo en la raíz. v22m hace lo mismo: `scripts/mvp_giro_camara.cjs` sobre
  los MvpFrente de v22j quita Billboarded y pone a MvpFrente un KGRT fijo (secuencia global nueva): +Z del modelo =
  arriba de la pantalla, +X hacia la cámara, -20° (tres cuartos hacia la cifra). Comprobado: cada vértice = matriz ·
  original en principio, centro y final de cada secuencia. Anotado en la skill (library-inventorysys-141.md).
- Tabla: `Punt_Corto` recorta a 214 de ancho estimado (`Punt_Ancho`, anchos de Friz medidos en la captura) con "..".
- Lado: nombre centrado en 1325 y achicado si pasa de 250 (`Mvp_PonNom`, `Mvp_Ancho`); cifra centrada en 1395 sobre la
  etiqueta PUNTOS centrada (PuntLado de `puntos_v22m.py`); recompensa en 3 renglones centrada en esa columna.
- Hashes: v22m `7f98ec0d…`, v22m-prueba `ba00e4cd…`. Validated (pJASS, reextracción por cmp, bytes-diff limitado al j,
  PuntLado y los 10 MvpFrente, mpq verify); sin jugar.

## v22n (23/11/2026): icono de racha en la columna derecha; cifra de la lápida

Leon tras v22m-prueba: "anda correcto ahora" (modelos inclinados, nombres y lado del MVP: **Tested in map** con
`-tabla`). Quedaban: la cifra de caídas algo descuadrada y el icono de la tarjeta de racha ausente en la segunda
columna (en la primera sí).
- Lápida: la cifra estaba ~10 px por encima del centro del recuadro: y 538 a 548.
- Racha: orden de lo translúcido por distancia real al ojo. En la columna derecha el icono (rango 398, 335 px del
  centro) quedaba a ~426 y el fondo (400, 165 px) a ~419: el fondo lo tapaba. Icono y marco 14 más cerca sólo en esa
  columna (384/376). Anotado en la skill y en la memoria orden-translucido.
- Hashes: v22n `3a21c5c0…`, v22n-prueba `267b5e22…`. Validated (pJASS, reextracción por cmp, bytes-diff sólo el j,
  mpq verify); sin jugar.

## v22o (23/11/2026): Tauren y Cairne con tiers; Estampida circular

Leon: "hace falta balancea los danios y cartas de las habilidades de nuestro tauren y de Cairne" (propuesta aceptada)
y "demos un rework a su R, este deberia ser circular ahora, van como rodeando en circulo, debera durar como la del
tauren".
- Tiers T1-T6 (curva 25/35/45/60/80/100 %, cartas "Subir tier" con color y el mismo paso por rondas que las armas):
  Q 2900, W 2000, E 2000, R 5800 por enemigo en T6. Marca ancestral y Espíritus guardianes: pasivas con tier, 1500 en
  T6; Marca empieza en T1 y sigue sin botón (sale al acertar). Disparo encantado y Réplica igual.
- Factor de cada técnica = T6 / base × curva. Bases (máximo a un enemigo por lanzamiento con factor 1, calculado del
  código): Bombardeo 5040, Embestida 800, Tótem 450, Roca 886, Estampida 3600, Grieta 250 (el % de vida no escala),
  Tótem del trueno 1950, Espíritu 600, Marca 500, Guardianes 250. Se calibran con el registro "enemigo" de la prueba
  (máximo, golpes, enemigos y base = máximo / factor por lanzamiento).
- w3a: maná 0; recarga Q 20, W 30, E 30, R 90 s; textos sin cifras de daño.
- Corrección: `Cop_Quitar` no movía `Cop_Mul` al compactar (una pieza podía quedarse con el factor de otra).
- Estampida: centro en el punto (hasta 900); 8 s; un kodo cada 8 pasos hasta el 177 (unos 23), a 250-650 del centro,
  da una vuelta completa en 2,7 s (antihoraria): daño una vez por enemigo (120) y empujón. Tipo 17 nuevo.
- Hashes: v22o `f23afaf4…`, v22o-prueba `b21b0b7a…`. Validated (pJASS, reextracción por cmp del j y del w3a,
  bytes-diff sólo j y w3a, mpq verify); sin jugar.

## v22p (23/11/2026): la Estampida crece con el tier; bases medidas

v22o-prueba (Cairne en T1, ~98 s): sin errores; Leon: "vale se ve bien" (Estampida circular: **Tested in map** en T1).
Registro "enemigo": Grieta 254-365 y Espíritu 500-599 cuadran; Tótem del trueno 600 con 6 enemigos (con uno solo
serían 12 rayos); Estampida 719-3059; Guardianes 750 siempre (las 3 copias golpean al de al lado); Embestida sin
golpes en el único lanzamiento; Marca no saltó. Leon: "con la subida de tier agregara mas filas lo que hara el area
mas grande tambien, como aumentar su velocidad tambien".
- Estampida: anillo de 400 + 100 por tier sobre T1 (radio hasta 650 en T1, 1150 en T6); 23 kodos por cada 400 de
  ancho (23 en T1, 52 en T6), con la misma densidad por fila; vuelta en 90 pasos en T1 y 6 menos por tier (60 en T6);
  salen hasta 8 s menos una vuelta, el último acaba a los 8 s. Texto del botón actualizado.
- Bases: Guardianes 250 -> 750, Estampida 3600 -> 3000.
- Hashes: v22p `d0497e75…`, v22p-prueba `0552f056…`. Validated (pJASS, reextracción por cmp del j y del w3a,
  bytes-diff sólo j y w3a, mpq verify); sin jugar.

## v22q (23/11/2026): Roca y Bombardeo del Tauren por tier; roca en la pasiva

v22p-prueba (Cairne, `-gt 6`): Guardianes 1500 justos; Grieta 2907-3235; 52 kodos por Estampida; máximo de la
Estampida muy variable (348-7308). Leon: "mucho mejor, ahora esta bien" (Estampida por tier: **Tested in map**).
Sin aclarar: la R salió 4 veces en ~40 s con recarga de 90 s en el w3a; no se encontró en el código qué la reinicia.
Leon pidió para el Tauren el área de la Roca por tier (por defecto era muy alta), rocas más rápidas con el tier y que
el Bombardeo acabe antes aprovechando todas sus rocas, y una pasiva con poca probabilidad de lanzar una roca.
- Roca: radio 250 + 50 por tier (300-550; antes 540) y vuelo de 22 - 2 × tier pasos (20 en T1, 10 en T6).
- Bombardeo: las mismas 88 rocas a ritmo (0,8 + 0,2 × tier) / 3 por paso (8 s en T1, 4 s en T6) y vuelo de
  19 - 2 × tier pasos (17 a 7); la copia anima en proporción. Misma base.
- Pasiva: cuando salta Disparo encantado, un 25 % de las veces (una cada 4 s como mucho) una copia lanza una roca de
  la E al blanco, con el tier de la E (T1 si no la tiene). Registro "pasiva roca" y "enemigo Roca pasiva".
- Textos de E, R y la pasiva actualizados.
- Hashes: v22q `32d3ce7f…`, v22q-prueba `1017d5e2…`. Validated (pJASS, reextracción por cmp del j y del w3a,
  bytes-diff sólo j y w3a, mpq verify); sin jugar.

## Próximo paso

Pendiente sin prisa: Leon juega v22i-prueba con `-pj 8` (Afterimage menos frecuente en T1; registro "tier 1 prob 10").
Importación de personajes en pausa (Leon, 23/11): "nuestro resto de personajes guardalos aun, haremos otras cosas y
luego las seguimos agregando". v22i tiene 9 personajes (celdas 0-8); el siguiente, cuando Leon lo retome.
Tabla de resultados aceptada en v22m. Ver en v22n: la cifra de la lápida y el icono de una racha en la columna derecha.
v22q-prueba jugada (Tauren, T1 y `-gt 6`), Tested in map: la roca de la pasiva salta ("pasiva roca", base 345/432);
Bombardeo T1 máx. 776, T6 máx. 4557-6628 con 22-32 golpes y base 3959-5759 (objetivo 5040-5800); Embestida base
299-799, Tótem 250, Roca T6 300 (una Roca T1 no tocó a nadie). Las recargas cortas del registro venían de
`thedudeabides` (Leon, 23/11): no es un fallo. Falta ver saltar la Marca de Cairne; afinar bases del Tauren con más
datos si Leon lo pide.
