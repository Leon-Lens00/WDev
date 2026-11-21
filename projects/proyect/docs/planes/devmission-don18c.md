# Dev Mission dentro de Battle Stadium D.O.N 1.8c

Prueba privada de Leon. Mapa original de Valkemiere; recursos de sus autores. Objetivo Classic 1.27b, JASS.

## Decisiones de Leon (12/11/2026)

- v16t-don "fue bien, aunque faltaron efectos". En vez de llevar D.O.N a nuestro mapa, se construye **dentro del mapa de
  D.O.N**, así no se pierde ningún efecto ni dependencia oculta.
- Base: **D.O.N 1.8c**, la versión con Naruto en modo sabio. En 2.0 y 2.1a la ficha H01A pasó a "Kyuubi Chakra Mode".
  Se usan los personajes de la 1.8c tal cual; los que falten (Kid Buu, Bardock, Goku Black…) "se adaptan fácilmente"
  después.
- Elegibles: **DBZ y Naruto**.
- Se trae el **sistema de oleadas de Dev Mission** "a ver qué pasa"; sin tienda ni menús en esta primera prueba.
- Sigue en pie: movimiento al núcleo Missile más adelante, personaje a personaje ([[dbz-fidelidad-don]]).

## Hechos del mapa base

Archivo `FrozenThone/games/WarcraftIII-1.27b/Maps/Download/Battlestadium DON1.8c.w3x`.
- SHA-256 `7fb3f034c25bc18d92607522ea90b762f63dc1c82d343706842ef8da462aca85`, 8,4 MB.
- Protegido: listfile mínimo, sin wtg/wct/imp/w3r/war3mapUnits.doo y wts vacío. Los textos van en línea en los objetos.
- Script optimizado: nombres de funciones y globales acortados (`ZD`, `s8[]`…), separadores `\r`. Normalizado tiene
  62 197 líneas, 6 719 funciones y 769 TriggerSleepAction. Rawcodes en entero. Regiones y unidades se crean en el script.
- Jugadores: 12 slots en 2 equipos; P0-P4 y P6-P10 usuarios, P5 y P11 ordenador. Inicio común en (7168, 6592).
  Área jugable de 96×96 casillas; cámara de -3072..8192 × -4352..7424. Héroe hasta nivel 25.
- 70 héroes, elegidos en tabernas:
  - `n00L` Dragon Ball: H00C, H00P, H04Z, H037, H0H5, H036, H02T, H00B, H062, H07O, H0AK, H0CV.
  - `n00Y` Dragon Ball: H0GX (Freezer).
  - `n00B` Naruto: H01A (Naruto modo sabio) y otros 11 de Naruto.
  - `n002`/`n00U` One Piece, `n00P` Naruto 2, `n00X` secretos.
- Naruto modo sabio H01A:
  - héroe: Six Tailed Kyuubi Mode A00U, Rasenrengan A0F5, RasenShuriken A0F3, Frog Taka A00W;
  - unidad: Tajuu Kage Bunshin A00T, sage eye A0AO, Senpuu Odama Rasengan A0AI.
  - H00N (Naruto normal, Rasen Shuriken A056) no lo vende ninguna taberna.

## Fases

1. **Copia y entrada** (siguiente):
   - copia de trabajo en `work/devmission-don18c-<fecha>/`; el original no se toca;
   - se deja intacto todo el script de D.O.N;
   - las tabernas venden sólo DBZ y Naruto modo sabio: se quitan los demás de `useu` y se ocultan las tabernas vacías;
   - lanzador propio; Leon comprueba que todo sigue igual que el original.
2. **Oleadas de Dev Mission**:
   - inventario de lo que necesitan del mapa Dev Mission (puntos, dueños de oleada, rondas, élites, jefe, texttags);
   - puntos de aparición nuevos sobre el terreno de D.O.N;
   - decidir con Leon qué pasa con el modo PvP 5v5, los jugadores ordenador P5/P11 y el modo jefe de D.O.N.
3. **Missile** por personaje, después de confirmar fidelidad.

Naruto: sólo el modo sabio H01A (Leon, 12/11). H00N no se vende en la 1.8c.

## Fase 2: D.O.N 1.8c con el terreno y los sistemas de Dev Mission

Leon (12/11/2026), después de ver la fase 1 ("se ve bien"):
- se usa D.O.N 1.8c como base;
- se traen la MP5 como ataque básico en la tecla A, los botones de movimiento ocultos (SilenceEx), el terreno de Dev
  Mission con sus zonas de aparición y demás, y la elección de personaje en la entrada directa mediante un puente.

Respuestas de Leon:
- MP5 en A: reemplaza el ataque normal de cada personaje DBZ/Naruto.
- Los héroes suben de nivel y aprenden habilidades como en D.O.N, con la experiencia de las oleadas.
- Además de las oleadas se traen la tienda móvil (golem), las cajas de vida y maná, las élites y el jefe.

### Hechos medidos en el script de la 1.8c

Análisis en scratchpad con `trig18.py` y `clasif18.py`:
- 680 triggers, 651 con eventos.
- Familia de los 14 personajes, 179 triggers: los que miran una de sus 90 habilidades o su tipo de unidad, más los que
  esos activan (75 de hechizo, 91 periódicos y 13 de otro tipo).
- Los 3 triggers de entrada a la región `Uk` (Jr, Xq, Yq) preparan al héroe recién comprado, porque las tabernas lo
  dejan allí. El puente de elección crea el héroe dentro de `Uk` para que D.O.N lo prepare igual que siempre.
- **Los 252 periódicos empiezan apagados**; los enciende cada habilidad o el flujo de partida.
- El resto es el flujo de D.O.N (diálogo de modos, tabernas, creeps, jefe, 22 comandos de chat, 51 regiones de entrada,
  objetos), además de los hechizos de héroes no elegibles, que nunca se disparan.
- En v16t-don se dejaron fuera triggers compartidos (ataque, daño, aprendizaje y muerte), y probablemente faltaron
  efectos por eso. Esta vez se conserva **todo** el script de D.O.N y sólo se apaga el flujo de partida.

### Pasos

1. **Terreno**:
   - copiar de Dev Mission (v16t-dbz) w3e, wpm, shd, doo, minimapa y límites del w3i;
   - las regiones de D.O.N se crean en el script, así que `Uk` se mueve al punto de aparición de Dev Mission;
   - el resto del script queda como en la fase 1.
2. **Apagar el flujo de D.O.N**:
   - el diálogo de modos, la creación de tabernas y tiendas y los triggers de región ajenos a la familia;
   - los comandos de chat de prueba (cheats) y el modo jefe o AoS;
   - de cada uno se anota qué es antes de apagarlo.
3. **Objetos e importados de Dev Mission** dentro de los de D.O.N:
   - oleadas, golem, cajas, MP5, piezas del selector y dummies;
   - comprobar choques de id y de ruta, y cambiar de nombre lo que choque.
4. **Sistemas de Dev Mission** en el script:
   - entrada directa con el selector de personajes (trackables) que llama al puente;
   - MP5 en A y SilenceEx;
   - oleadas con élites y jefe, tienda móvil y cajas;
   - jugadores: configuración de Dev Mission (8 jugadores y dueños de oleada) en lugar de los 2 equipos de D.O.N.
5. Mapa normal y mapa de prueba con registros; Leon juega la normal.

Por decidir más adelante: war3mapMisc. Lo normal es dejar el de D.O.N para los héroes, pero Dev Mission cambió la tabla
de daño (`DamageBonus`).

## Estado

**Fase 1 construida (12/11/2026):** `work/devmission-don18c-20261112/DevMission-DON18c-f1.w3x`.
- SHA-256 `c9a4b88d5a8d…22347a54`; se construye con `scripts/hacer-f1.sh` (`fase1.py`).
- **Validated**: pJASS acepta el original y el modificado; j y w3u reextraídos idénticos; `mpq verify` ok.
  bytes-diff: sólo cambian j, w3u y el listfile, y wc3ctl añade `(attributes)`.
- Cambios en el script, 43 líneas añadidas y nada más:
  - lista F9 sólo con DBZ 1..13 y H01A en 50 (31 entradas a 0); de ella sacan héroe `-random`, la IA y los modos;
  - las tabernas One Piece ×2, Naruto 2 y secretos se crean ocultas (3 sitios × 4).
- Objetos: la taberna de Naruto `n00B` vende sólo H01A; las ocultas no venden nada.
- Riesgo sin comprobar: los modos de elección de una sola serie (`-apop` One Piece) se quedan sin héroes. `r1` vuelve a
  tirar con `TriggerExecute` hasta encontrar uno, así que podría no terminar.
- Sin probar en juego. Lanzador `scripts/entrar-f1.sh`.

**Fase 2 construida (12/11/2026):** `work/devmission-don18c-20261112/DevMission-DON18c-f2.w3x` (normal) y
`-f2-prueba.w3x` (registro `CustomMapData\lat\don18c-f2.txt` cada 10 s, muestra por héroe cada 2 s).
- SHA-256 normal `8da58de91801…5928b0b`, prueba `92ac3fcddb06…66278ef4`. Se construye con `scripts/hacer-f2.sh` desde
  el original de D.O.N, v16t-dbz y el j/w3u de la fase 1 (comprueba sus hashes).
- Cadena: `nombres_don.py` (recupera 1061 de 1132 nombres por hash; 71 bloques sin nombre que nada cita se dejan
  fuera) → `fusion_obj.py` (ids de D.O.N que chocan pasan a xQ..; estándar: D.O.N gana w3u/w3a/w3h/w3t, Dev Mission
  w3b/w3d) → `fusion_j.py` (D.O.N entero renombrado Dn*, 37 rawcodes reescritos) → `fase2.py` → `ensamblar_f2.py` +
  `mpq_escribir.py` (empaquetador propio: wc3ctl no podía añadir el listfile al mapa protegido).
- Terreno, regiones, cámaras, puntos y w3i de Dev Mission. Misc de D.O.N + DamageBonus de Dev Mission; Skin de Dev
  Mission + cursor de objetivo de D.O.N. Los 12 modelos/texturas DBZ que chocaban: gana D.O.N; NewMassiveEX y
  NuclearExplosion quedan los de Dev Mission y los de D.O.N entran como `DON_*`.
- Apagado por `Dn__Apagar`: inicio y modos (Wq, Lr, Mr, Pq), destructibles (LB), hora (Gq, Hq, Iq, lq), flechas (Sq,
  Tq), ESC de D.O.N (ns), 22 comandos de chat y los 50 triggers de región del terreno de D.O.N. Quedan las misiones (Up).
- Puente: `Entrada_Directa` en vez de la intro; el selector crea el héroe D.O.N dentro de `Uk` (Jr/Xq/Yq lo preparan,
  revive a los 10 s en `M4[1]` = punto de aparición de Dev Mission). Sin héroes repetidos entre jugadores.
- MP5 en A: el héroe D.O.N lleva Arp1 (A) y Aw08 (F, recarga) y apunta a `Game_Pair[p]` en la tabla de RapidPair; el
  `Game_Hero` oculto y pausado le sigue cada 0,1 s y dispara desde allí. `Silence_HideMove` quita ataque y botones de
  movimiento. Oleadas, élites, jefe, golem y cajas vienen con el script de Dev Mission completo.
- **Validated**: pJASS acepta normal y prueba; los 1727 archivos reextraídos iguales por hash a su fuente;
  `mpq verify` ok en los dos. Lint: sólo avisa de 7 rutas que ya faltaban en los originales.
- Sin probar en juego. Riesgos: que Jr no salte al crear en `Uk` (hay SetUnitPosition de respaldo); botón o tecla A
  pisando una habilidad D.O.N; balas desde el actor oculto; oro "Berry" y rachas de D.O.N siguen activos.
- Lanzadores `scripts/entrar-f2.sh` y `entrar-f2-prueba.sh`.
