# WaveSys: defectos detectados durante la evaluación

- Fecha: 23 de octubre de 2026, America/Lima. Agente: Codex, chat de evaluación de WaveSys.
- Proyecto: `/home/snz/Documentos/WarDatsPy/struct/`; vJASS, objetivo Classic 1.27b.
- Revisión: hashes de las 162 fuentes/artefactos `.j`/`.ps1` en `work/wavesys-auditoria-20261023/fuentes.json`. Sin Git.
- Estado: abierto; revisión en curso. No se han corregido las fuentes.

## Evidencia confirmada por lectura

1. El índice activo guarda unidades con `WaveActiveUnitByKey.unit[...]` (SwlsWave.j:1051), pero intenta liberarlas con `.remove` (1081, 1669). La Table local 3.1.0.1 ejecuta `RemoveSavedInteger` (Table.j:246–247); los handles requieren `.handle.remove` (82–83). Las referencias de unidad permanecen guardadas.
2. `WavePointGroupApplyToWave` retorna el número del grupo aunque `Wave.addPoint` puede rechazar por capacidad: límite 128 por grupo y 100 por Wave. El chequeo de StageExample no detecta esta truncación.
3. Los spawns reservados tienen temporizadores independientes de 1.50 s. `pause` sólo pausa `loopTimer`; el callback pendiente no comprueba `isPaused`. La pausa no impide materializar reservas.

## Impacto y límites

Retención de referencias y pérdida silenciosa de posiciones; semántica de pausa parcial. Evidencia de flujo y contratos en fuente, todavía sin ensayo en el motor. No implica que se hayan observado fallos durante una partida del usuario ni una desincronización.

## Acciones y comprobaciones

- Consulta CodeGraph: raíz no indexada; fallback por lectura directa, sin crear índice fuera de alcance autorizado.
- Toolchain 1.27b comprobada mediante `check_toolchain.py`: cuatro archivos presentes y hashes registrados por la herramienta.
- Pendiente: terminar contraste de consumidores, compilación de fuentes actuales e informe general con prioridades.

## Compilación de la unidad actual

El 23-10-2026 se generó un harness con las 113 fuentes activas del builder, las 15 declaraciones rect propias del mapa y config/main mínimos. JassHelper rechaza `VisionConfig.j:55`, función `InitTrig_Event` dentro de `library VisionConfi`: «InitTrig functions are forbidden inside libraries and scopes». No se produjo un compilado válido; no es una falta de rects en el harness. Hay otros nombres InitTrig dentro de bibliotecas pendientes de contrastar.

Evidencia conservada en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/evidence/compile-full-original/`. Fuentes copiadas a `WaveSys/src/` a solicitud del usuario: 162/162 hashes idénticos. Se continuará con variantes generadas de diagnóstico, sin corregir las fuentes de la copia ni el original.

## Preparación del laboratorio aislado

Primer harness de núcleo rechazado: faltaba la declaración `native UnitAlive`, obtenida en el build completo de `SpellIndex.j:30`, sin dependencia explícita desde WaveTest. Se declara la misma native Classic en el borde del harness; no se reimplementa. Se intentó después el lanzamiento sin salida del builder y el launcher rechazó correctamente el archivo inexistente; no se inició juego. Diagnósticos conservados en `WaveSys/evidence/core-compile-first.json`, `build-core-first.log` y `play-core.log`. Pendiente repetición con el harness completo.

## Lint y codificación

El lint auxiliar abortó al leer bytes CP1252 como UTF-8 (byte 0xf3); por eso no produjo JSON. El intento posterior de leer ese archivo vacío también falló. Ninguna de esas salidas acredita revisión limpia. Se generó una copia UTF-8 bajo `WaveSys/artifacts/lint-input`, preservando fuentes originales y registrando las conversiones en `evidence/lint-normalization.json`; pendiente resultado de repetición.

## Resultado consolidado — evaluación

Se entregará el informe en `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/docs/evaluacion-wavesys-2026-10-23.md`. Las incidencias individuales siguientes contienen causa, evidencia, impacto y límite. Todas permanecen abiertas; no se aplicaron arreglos a las fuentes.

- [E01 La unidad de fuentes actual no compila sin adaptación](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e01-inittrig.md) — P1, ERROR.
- [E02 La muerte de invocados aborta antes de avisar y limpiar](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e02-muerte-invocado.md) — P1, ERROR.
- [E03 RemoveUnit deja la oleada esperando unidades inexistentes](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e03-removeunit.md) — P1, ERROR.
- [E04 PlayerUtils corrompe el índice compacto de jugadores al salir](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e04-jugadores-salida.md) — P1, ERROR.
- [E05 Las habilidades agotan índices acumulativos sin reciclar](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e05-ids-habilidades.md) — P1, ERROR.
- [E06 Los eventos anidados borran el contexto del evento exterior](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e06-contexto-eventos.md) — P2, ERROR.
- [E07 La limpieza de Table usa el tipo equivocado](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e07-table-handles.md) — P2, ERROR.
- [E08 Aplicar puntos devuelve una cantidad que no se insertó](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e08-conteo-puntos.md) — P2, ERROR.
- [E09 La pausa permite materializar apariciones ya reservadas](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e09-pausa-reservas.md) — P2, WARNING.
- [E10 La memoria de órdenes puede impedir reanudar persecución](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e10-cache-ordenes.md) — P2, ERROR.
- [E11 El tablero inicial sobrescribe la interfaz de descanso y victoria](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e11-tablero-descanso.md) — P2, ERROR.
- [E12 El aura pierde miembros vivos al retirar una entrada inválida](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e12-aura-compactacion.md) — P2, ERROR.

### Recuperación de las comprobaciones auxiliares

- Compilación completa: el original sigue rechazado. La variante generada con cuatro renombres InitTrig compila y pasa pJASS; no es una corrección aplicada ni validación del mapa completo.
- Harness de núcleo: declaración UnitAlive completada con la native exacta Classic; el builder empaqueta y verifica hashes sin cambiar las bibliotecas de origen.
- Preparación de markers: CreateUnit desplazó coordenadas y GetUnitTypeId reflejó RemoveUnit después de actualizar el motor. Fixture final fuerza coordenadas y verifica la retirada en otro callback. Esos controles pasan en baseline2 y slot-init; no son defectos de WavePointGroups.
- Baseline final:18checks/7FAIL; diagnóstico con sólo s=0:18checks/5FAIL. Comparación controlada verificada en evidence/controlled-comparison.json. Tres partidas propias cerradas y evidencia conservada.
- Lint: se recuperó usando34copias normalizadas de encoding;35WARNING y0ERROR en las reglas ejecutadas. Los avisos no se elevaron automáticamente a fallos, y el resultado no sustituye los fallos de compilación/motor ya demostrados.
- Integridad:162/162 archivos JASS/PowerShell idénticos en el original y en la copia; resultado en evidence/source-integrity-final.json.

## Última prueba y estado final

El ensayo removal-delayed confirmó E03 con engineRemoved=1 después de0.5s: activos1, indexados1, finished0 y forceTerminated0. La evidencia final se enlaza en la incidencia E03. Se descarta el retraso nativo como explicación. Cuatro partidas propias ejecutadas; cierre final verificado en evidence/game-sessions-closed.json. Evaluación completada; las doce incidencias de producto permanecen abiertas por no haberse solicitado su corrección.


Seguimiento evaluación completa: se repitió una lectura directa UTF-8 de SwlsWave.j y falló en byte0xf3/posición222. Recuperación inmediata con decodificación UTF-8-sig o CP1252, igual que el builder ya validado. No se cambiaron bytes ni codificación de la fuente; lectura completa pertinente recuperada. Es fallo de la consulta del agente, no un nuevo defecto del producto.

Seguimiento: lectura de activewindow sin ventana activa devolvió objeto vacío; el acceso directo a pid falló con KeyError. Se sustituyó la guarda por .get y se revalidó por PID/inicio antes de entradas. Recuperación comprobada al abrir y cerrar únicamente la sesión integration-v2.
