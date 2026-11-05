---
name: mapa-dev-mission
description: "Entregar versiones del mapa Dev Mission (TerrainDev-Titulo-vNN) a Leon: dónde se construye, qué variantes y parámetros lleva cada entrega, qué se comprueba antes y cómo se informa. Usar al preparar, probar o entregar una versión del mapa; complementar build-warcraft3-vjass-127b para el código y probar-warcraft3-classic-linux para el juego."
license: MIT
metadata:
  creado: 2026-11-04
  origen: indicaciones de Leon en el chat Integration
---

# Entrega del mapa Dev Mission

Objetivo Warcraft III Classic 1.27b (JASS, sin Blz/Frame/Lua). Esta skill fija **cómo se entrega** el mapa; las reglas
de código, sincronización y prueba siguen en [build-warcraft3-vjass-127b](../build-warcraft3-vjass-127b/SKILL.md) y
[probar-warcraft3-classic-linux](../probar-warcraft3-classic-linux/SKILL.md). Leer antes el AGENTS.md de Proyect y
`docs/traspasos/coordinacion-chats.md`: Integration es el único escritor del mapa.

## Dónde y con qué nombre

- Carpeta de trabajo: `Proyect/work/titulo-devmission-20261026/` (`$M`). Cada versión es `vNN` + letra (v14h, v14i…).
  No reescribir una versión ya entregada: la siguiente parte de la anterior y comprueba que su `war3map.j` es el del
  mapa anterior (como hace `hacer-v14h.sh`).
- Fuentes de cada versión en `scripts/`: `vNN.py` (parche del j), `objetos_vNN.py`, `efectos_vNN.py` si hay modelos o
  texturas, `prueba_vNN.py` (puente de registros) y `hacer-vNN.sh`, que construye todo de forma reproducible.
- Los puntos que coloca Leon en el editor (`nPto`, `nPtA`, `nPtB`, `hpea`…) se copian a `puntos/guardado-…/` y se leen
  del `war3mapUnits.doo` de esa copia. El mapa que guarda el editor sólo aporta posiciones; nunca se usa como base.
- Plan y estado en `Proyect/docs/planes/devmission-<tema>-vNN.md`; fallos reales en `Proyect/informes/errores/`.

## Qué lleva cada entrega

| Mapa | Uso | Registros |
|---|---|---|
| `TerrainDev-Titulo-vNN.w3x` | el que juega Leon | **ninguno**: sin registros, rastreador ni atajos de prueba |
| `TerrainDev-Titulo-vNN-prueba.w3x` | prueba propia de un jugador | Preload en `CustomMapData/lat/vNN-*.txt` |
| `TerrainDev-Titulo-vNN-lan.w3x` | sólo si el cambio toca `GetLocalPlayer` | Preload `lat/j<id>-*.txt`, sumas del estado sincronizado |

- Lanzadores `scripts/entrar-vNN.sh` y `entrar-vNN-prueba.sh`: comprueban `pgrep -x war3.exe`, mandan a la papelera los
  registros viejos de esa versión, copian el mapa a `Maps/Test/DevMission-vNN.w3x` y abren con `-window -loadfile`.
- Variantes para que Leon juegue él mismo (desde v14j, a petición del 04/11/2026): `vNN-prueba` (entrada directa,
  `Entrada_Directa`) y `vNN-prueba-intro` (intro y título). Ninguna trae atajos ni muertes automáticas; las dos llevan
  un registro ligero de cámara, tienda y ronda cada 2 s en `lat/vNN-*.txt`, con tope. Las pruebas automáticas con
  rondas aceleradas se guardan con otro nombre.
- Recursos importados: texturas en potencia de dos y ≤ 512; rutas de `war3mapImported\` salvo las que el modelo pide
  en la raíz. Créditos de recursos ajenos en el plan (p. ej. Vinz).

## Antes de entregar

1. `hacer-vNN.sh` sin errores: pJASS correcto en la normal y en la de prueba.
2. Reextraer del `.w3x` y comparar por hash el j, w3u, w3a y cada import nuevo o cambiado; `wc3ctl mpq verify`.
3. Prueba propia con la variante `-prueba` y evaluación de sus registros; capturas sólo para lo visual. LAN de dos
   clientes cuando se toque lo local. Ver la memoria `pruebas-por-registros` y `pruebas-segun-local-player`.
4. Actualizar el plan con hashes, resultados y lo no comprobado.

## Cómo se informa

- En español. Cambios en lenguaje de juego, luego el estado con su nivel: **Validated**, **Tested in map** (un
  jugador) o **Tested in multiplayer** (indicar si fue LAN en esta PC). Nunca uno por otro.
- Lo que no se pudo comprobar, dicho aparte.
- SHA-256 abreviado de cada mapa entregado.
- El lanzador en un bloque `bash` propio para que Leon lo ejecute él:

  ```bash
  bash /home/snz/Documentos/ChatGPT/Proyect/work/titulo-devmission-20261026/scripts/entrar-vNN.sh
  ```

- Sin commit salvo que Leon lo pida.

## Parámetros del mapa vigentes (v14i)

Comprobar en el j antes de confiar en ellos; cambian por versión.

- Terreno Swamped Temple; menús en (0, 8700); 100 puntos de oleada `nPto`, 10 de tienda `nPtA`, 20 zonas de munición
  `nPtB`.
- Rondas: 10; descanso único de 45 s; tienda móvil (golem 'ngst') que baja al acabar la oleada.
- Presupuesto de texttags: 100 en total (memoria `texttags-presupuesto`).
- Oleadas (v14i): por tipo 6 × J más la base `ceil(A/2) × min(6, 1 + floor(A/2))` × factor (`DevWave_PCT_BASE` 100);
  límite `min(5 × ronda × J, 240)` y 40 por bot; una aparición cada 0,10 s; élites a `i × Total / (E + 1)` muertes, una
  por jugador; aparición cercana 15% a 400-800 con tolerancia.

## Terreno, minimapa y cámara (v14j)

- Leon ensancha o amplía el terreno en el editor; se toma de su guardado sólo la malla, el w3i (límites y área jugable)
  y las piezas especiales del `.doo`. Doodads, unidades y script siguen saliendo de la versión anterior.
  Ver `scripts/terreno_v14j.py`.
- Al crecer al oeste o al sur, los doodads especiales del final de `war3map.doo` (cueva `YCr2`, rampas `YCg*`) se
  guardan por casilla: correrlos lo mismo que creció la malla. Si no, aparece una cueva en forma de caja sobre suelo
  llano. Ver [map-analysis-toolchain](../build-warcraft3-vjass-127b/references/map-analysis-toolchain.md).
- El minimapa dibuja la zona de `SetCameraBounds` encajada con su proporción, y lo que está bajo máscara negra no se
  pinta. Desde v14j la partida, la intro, el título y la tienda usan los mismos límites apaisados de todo el mapa
  (`bj_mapInitialCameraBounds`, X -13440..12032, Y -7296..9728). Los menús fijan la cámara con
  `SetCameraTargetController` a `Menu_Ancla[0]` (título) o `Menu_Ancla[1]` (tienda), nunca con límites de punto. No
  compensar con ZOFFSET la altura que informa el bloqueo: la escena queda igual sin compensar.

## Indicaciones de Leon

Añadir aquí, con fecha, cada indicación nueva sobre la entrega o los parámetros obligatorios del mapa.

- 04/11/2026: crear esta skill para fijar cómo se entrega el mapa; Leon irá indicando más parámetros.
- 04/11/2026: entregar también mapas de prueba con intro y sin intro para jugarlos él mismo; anotar en la skill lo
  aprendido del terreno ensanchado (doodads especiales por casilla).
