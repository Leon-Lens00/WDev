# Proyecciones JASS desactualizadas tras borrar su módulo

- Origen: agente del chat de ampliación CodeGraph, 2026-10-21, America/Lima.
- Entorno: implementación en desarrollo sobre 1.6.2+jass-vjass.2; extracción 29.
- Estado: resuelto; corrección incorporada a la revisión local 3 y a los tres índices activos.
- Síntoma: la regresión `jass-expansion.test.ts` conservó `S.run` después de
  eliminar defs.j, cuyo módulo M había aportado ese método a use.j.
- Impacto: grafo con relaciones obsoletas si se desplegara esta implementación.
- Causa confirmada: los borrados se contabilizan en filesRemoved, pero no se
  añaden a changedFilePaths; la invalidación añadida sólo observaba ese array y
  filesToIndex. Los consumidores sin cambios no se reextraían.
- Acción: detectar también borrados JASS; reextraer los consumidores JASS dentro
  del alcance indexable y contabilizar las proyecciones modificadas para que el
  coordinador vuelva a resolverlas. Otros lenguajes mantienen su camino original.
- Verificación pendiente: repetir regresión con sincronización por paths,
  comparar incremental con reconstrucción completa y probar las raíces reales.
- Evidencia: `work/codegraph-ampliacion-vjass-20261021/expansion-after-1.log`;
  el resto de fallos de esa pasada eran expectativas antiguas de cobertura y una
  coordenada mal contada en la prueba nueva (implement está en línea 4, no 5).

## Preparación del contraste con compilador

La primera fixture fue rechazada por usar Consumers_S para un struct que no
se declaró public: JassHelper informó «Consumers_S is not of a type that allows
. syntax». El nombre de prueba se corrigió a S.start(); no se modificaron las
fuentes del juego. Registro inicial: runtime/wc3-tools/reports/vjass-20261021-194809-228448
en FrozenThone; resultado repetido pendiente al registrar este punto.

## Preparación de las sondas reales

verify-real.mjs asumió que todas las copias tenían índice antes de recrearlo.
La copia de misiles sí lo tenía y sus 5 recorridos pasaron; el inventario era
nuevo y CodeGraph.recreate lo rechazó correctamente («not initialized»). Se
corrigió el auxiliar para usar init cuando no existe .codegraph. No es un fallo
del servidor ni del contenido del inventario. Repetición completa pendiente
al registrar este punto; evidencia en real-probes.log.

## Cierre de verificaciones

- La regresión que conservaba S.run tras borrar defs.j pasa con sincronización
  por paths y converge al mismo conjunto de aristas que una reconstrucción total.
- 1.193 casos pasan en 15 suites (regressions-release.log). La fixture corregida
  y una segunda con fallback .exists compilan y pasan pJASS, sin modificar mapas.
- La preparación de sondas reales terminó recuperada: las tres raíces pasan
  reconstrucción estable y hashes; 5 recorridos de misiles y 3 de inventario.
- Una sonda esperaba un solo buildDescription y encontró dos debido al fallback
  static-if .exists. Era un límite de cobertura, no un error del juego. Se añadió
  simplificación sólo para existencia positiva demostrada por una declaración
  pública incondicional del mismo struct; su negación elimina el fallback.
  Condiciones desconocidas/compuestas y elseif siguen abiertas. La fixture del
  compilador y la prueba de regresión comprueban este caso.
- MCP de verificación recién iniciado: versión 1.6.2+jass-vjass.3, consultas a las
  tres raíces y 11 transiciones automáticas aprobadas, incluyendo modificación
  y borrado de módulos sin cambiar consumidores. Todas las sondas se retiraron.
- Los 76 hashes de fuentes indexadas originales permanecen iguales.

Al detener los procesos MCP antiguos para desplegar, el transporte de este chat
quedó cerrado y la consulta informó Transport closed. Se continuó por CLI y una
conexión MCP independiente de prueba. La recuperación de la conexión de la app
se registra en el plan y app-reload-verification.json; no confundirla con las
consultas de la conexión de verificación.

Evidencias: work/codegraph-ampliacion-vjass-20261021/ (real-results.json,
mcp-live-verification.json, active-index-verification.json y logs). El nuevo
soporte sigue siendo parcial; estas verificaciones no son pruebas del juego
ni evaluación A/B de agentes del upstream.

Recuperación de app confirmada: proceso nuevo posterior al build y consultas
codegraph_explore desde el mismo chat en las tres raíces, todas correctas.
Transport closed quedó resuelto mediante recarga oficial; no quedó pendiente
para el usuario. Ver app-reload-verification.json y current-chat-mcp-*.txt.
