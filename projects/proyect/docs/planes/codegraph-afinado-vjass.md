# Afinado de la adaptación vJASS de CodeGraph

Fecha: 2026-10-21. Base upstream: v1.6.2,
`6560052a6f856855d3f71eee838fd66ccfa4285d`. Checkout modificado previamente:
`/home/snz/Documentos/MCP W3/codegraph-vjass`.

## Objetivo y alcance

Corregir defectos demostrados de extracción/resolución y orientación MCP,
manteniendo el pipeline original: extracción, SQLite, resolución, consultas y
sync. Conservar el trabajo previo y las fuentes/mapas del usuario. No declarar
soporte completo ni implementar expansión general de macros/módulos en este
afinamiento. La petición autoriza correcciones y comprobaciones locales.

## Hallazgos y fases

1. Reproducir con pruebas de regresión la contaminación de ámbitos por bloques
   `novjass` (observada en el Missile.j real). Comprobar con JassHelper/pJASS la
   semántica de cadenas multilínea antes de decidir cómo analizarlas.
2. Corregir sólo causas reproducidas; revisar llamadas, callbacks, ámbitos,
   conservación de coordenadas y diagnósticos de zonas omitidas. Aclarar la
   orientación del servidor que contradice su ciclo de vida por `projectPath`.
3. Construir y ejecutar regresiones pertinentes del original y la adaptación,
   incluyendo un control con otro lenguaje. Sondear fuentes reales copiadas
   (TerrainDev e inventario) y verificar que no se crean símbolos desde
   documentación ni se inventan expansiones de módulos/macros.
4. Aplicar la salida construida a consultas e índices activos de forma coherente,
   preservando fuentes/mapas y registrando qué procesos/sesiones usan la revisión.

## Aceptación y límites

- Regresiones que fallen antes del cambio y pasen después; compilación TypeScript.
- Casos locales del compilador para cualquier semántica JASS que se cambie.
- Extracción y consultas reales con cobertura no vacía, diagnósticos conservados,
  actualizaciones incrementales y control de otro lenguaje sin regresión.
- Fuentes/mapas originales sin cambios por SHA-256.
- Metodología original de aceptación de lenguaje completo: repositorios reales
  pequeños/medianos/grandes y comparación A/B con agentes. No está acreditada
  por las pruebas unitarias ni por los sondeos locales; revisar disponibilidad
  del harness y dejar pendiente lo que no pueda ejecutarse.

Evidencias y respaldo previo: `work/codegraph-afinado-vjass-20261021/`.
## Implementación y verificación ejecutadas

- Se reprodujeron fallos en regresiones antes del arreglo: documentación
  `novjass` contaminaba ámbitos; fragmentos de regiones omitidas producían
  falsos errores léxicos; llamadas en inicializadores locales no aparecían como
  llamadas de su función; métodos sin prefijo no resolvían dentro de un struct.
- JassHelper y pJASS confirmaron exclusión de `novjass`, aceptación/conversión
  de cadenas multilínea y prioridad del método del struct sobre la función
  global homónima. El primer intento de cadenas falló en Wine antes de compilar;
  el ensayo secuencial posterior produjo salida válida y pasó pJASS.
- Se corrigieron esas causas en el extractor/resolvedor registrados en el
  pipeline original. La guía MCP ya no promete AST completo para vJASS ni
  niega el watcher de `projectPath`. El original también registra extractores
  propios sin Tree-sitter; usar uno estructural no incumple por sí solo su
  arquitectura. La profundidad semántica debe comprobarse por separado.
- Build completo TypeScript + assets + visor: éxito. Siete suites, **1028
  pruebas aprobadas**, ninguna omitida. Incluyen extracción/resolución originales,
  mezcla de lenguajes, ciclo de vida MCP, vigencia y 20 casos JASS/vJASS.
- Copias reales: TerrainDev 16 archivos/850 nodos/1141 aristas; inventario
  56/2576/3737 tras la corrección de los jurados; UI Studio 4/126/734. Cero errores de extracción en estas copias,
  pero **286/624/0 avisos de cobertura**, respectivamente: no se ocultan límites.
- Tres flujos reales comprobados con aristas y respuestas explore:
  `RapidPair.emit → face`, `RapidPair.cast → emit`,
  `RapidBolt.onPeriod → resolve`. Control Python: mismos símbolos/coordenadas
  y llamadas que el paquete upstream 1.6.2 fijado.
- Conexión MCP nueva: identidad `1.6.2+jass-vjass.2`, herramienta única original
  `codegraph_explore`, consultas no vacías en las tres copias y 9/9 transiciones
  automáticas de creación/edición/borrado observadas en SQLite sin hacer sync
  ni consultas durante la observación.
- Los tres índices originales se reconstruyeron con extracción 29/revisión 2,
  sin cambios pendientes, con integridad SQLite correcta. Los 71 archivos de
  fuentes/mapas observados mantuvieron su hash. La skill y AGENTS registran la
  revisión vigente y los límites; la referencia de skill pasó su validador.

Evidencia principal: `verification.json`, `tests-before.log`,
`tests-calls-before.log`, `tests-after.log`, `build.log`, `real-probes.json`,
`mcp-verification.json`, `active-indexes.json`, fixtures/compilados y logs en
`work/codegraph-afinado-vjass-20261021/`. npm y PyYAML se usaron en ese directorio
aislado para ejecutar herramientas existentes; no se instalaron globalmente.

## Estado y pendientes

Implementación y comprobaciones locales terminadas. No se acredita soporte
completo, evaluación A/B con agentes del original, pruebas en juego o multijugador.
Al terminar la implementación quedaba pendiente recargar los servidores MCP
anteriores: una base reconstruida no reemplaza módulos cargados en memoria.
La recarga se completó posteriormente por petición del usuario desde los ajustes
MCP de la aplicación, manteniendo Codex abierto. No se enviaron mensajes a otros
chats.

## Judgment Day

Dos jueces independientes revisaron la adaptación completa del diff local,
sin ejecución, escritura ni coordinación entre ellos. La identidad inicial fue
`58aa0bd5388e7ad22bb249b2bcd95308bea6843211b2240b9ede675574e68df3`.
Se comprobaron las correspondencias de código y evidencias antes/después de la
revisión y antes de corregir.

Seis observaciones se agruparon en cinco causas, corroboradas por el padre:

| IDs | Causa | Estado |
|---|---|---|
| JD-A-001 | Texto de comentarios alteraba la selección de la clase base | confirmed → corregido y verificado por ambos |
| JD-B-001 | Un método ambiguo por static-if podía enlazarse a un global homónimo | confirmed → corregido y verificado por ambos |
| JD-A-002 | Marcadores ajenos dentro de novjass generaban errores falsos | confirmed → corregido y verificado por ambos |
| JD-B-002 | Se descartaban métodos ordinarios execute/evaluate por su nombre | confirmed → corregido y verificado por ambos |
| JD-A-003 / JD-B-003 | Lecturas secundarias perdían advertencias JASS | confirmed → corregido y verificado por ambos |

Una ronda de corrección (máximo dos), abierta por las dos causas que fabricaban
aristas incorrectas; el mismo delta acotado corrigió los contratos funcionales
del lexer y las consultas afectadas. Cinco regresiones fallaron antes del cambio
y pasaron después. Se añadió también un control de `extends array` para proteger
la resolución de funciones globales sin una jerarquía heredada.

La reevaluación se limitó a esos IDs y sus posibles regresiones. Ambos jueces
marcaron todos `verified`, sin defectos abiertos ni regresiones declaradas. Hash
final del código revisado:
`d948b166d87d3c80d21f7edca1e41bdd19cf6828848364ee197b1dc6318bcf6d`.
Evidencias finales: `judgment-findings-r1.json`, `judgment-reevaluation.json`,
`judgment-regressions-before.log`, `judgment-tests-final.log`,
`judgment-build-final.log` y fixtures/compilaciones complementarias.

Comprobaciones finales: **1054 pruebas aprobadas en nueve suites**, ninguna
omitida; build completo aprobado; tres flujos reales y control Python coincidente
con upstream; MCP nuevo revisión 2 y nueve transiciones automáticas aprobadas.
Los tres índices activos se reconstruyeron también después del delta, con
extracción 29. La recarga de los servidores anteriores se completó y verificó
después, como se documenta a continuación.

El dictamen se limita al alcance local examinado. Los jueces hicieron revisión
estática; el padre ejecutó las comprobaciones. No equivale a aceptación oficial
upstream, prueba de rendimiento A/B, soporte completo vJASS, ejecución en el juego
ni multijugador. El informe final y los hashes están en `judgment-final.json`.

## Activación en los chats abiertos

El 2026-10-21 se aplicó el reinicio desde Configuración → Complementos → MCP,
con CodeGraph activado. Los cuatro procesos anteriores (3434, 6507, 15783,
83766) terminaron; los nuevos 98487, 98761 y 99030 arrancaron después del build
vigente `1.6.2+jass-vjass.2`. La aplicación y su app-server permanecieron abiertos.

Se ejecutaron consultas reales mediante la herramienta MCP de este chat en las
tres raíces. Después se comprobaron 9/9 transiciones de creación/edición/borrado
automáticas, observando SQLite en modo lectura sin llamar a sync ni consultar
CodeGraph durante esas observaciones. El propietario activo fue PID 99030,
`ready=true`. Los archivos temporales se retiraron y los 71 hashes de
fuentes/mapas siguieron intactos. Ya no queda pendiente reiniciar Codex para
activar esta revisión.

Evidencia de activación:
`work/codegraph-mcp-restart-20261021/verification.json`, consultas y
`auto-sync-verification.json` en ese mismo directorio.
