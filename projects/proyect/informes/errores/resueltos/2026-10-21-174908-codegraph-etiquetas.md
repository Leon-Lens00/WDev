# CodeGraph: etiquetas de relaciones y recordatorio de pruebas

- Fecha: 2026-10-21-174908 (America/Lima).
- Origen: chat «Reducir la sycophancy en MCP W3»; revisión de «Verifica soporte de wc3ctl» y «Implementar sistema de equipo».
- Entorno: CachyOS, CodeGraph local 1.6.2+jass-vjass.2, extracción 29, Node aislado 24.16.0.
- Estado: resuelto; doble revisión finalizada.

## Síntoma, causa e impacto

El encabezado `Dynamic-dispatch links` mostraba aristas estáticas JASS junto a
aristas inferidas de otros lenguajes. El filtro por procedencia `heuristic`
incluye ambos casos. Confirmado en `src/mcp/tools.ts`: afecta a la interpretación
de la salida, sin un destino incorrecto demostrado en las relaciones revisadas.

El recordatorio global `/home/snz/.codex/AGENTS.md` conservaba que no había pruebas
visuales de Warcraft III. Los informes de las entregas ya documentan pruebas
locales; esa frase no describía el estado comprobado. Las pruebas locales no
acreditan todos los flujos ni multijugador.

## Reproducción y acciones

Una regresión de `jass-vjass.test.ts` consulta una cadena de llamadas estáticas
con y sin sección Flow. Tras preparar el runtime correcto, falla antes del fix
por la etiqueta anterior: 1 caso ejecutado y fallido, 26 omitidos por el filtro.

Se cambió el encabezado a `Additional graph links`, el subtítulo distingue
relaciones estáticas e inferidas y las aristas JASS llevan `static JASS: TIPO`.
Las etiquetas dinámicas de los sintetizadores existentes se conservan.
Se actualizó la orientación MCP en `server-instructions.ts` y las expectativas
correspondientes de dos pruebas previas. No cambia extracción, resolución ni
formato de la base; no necesita reconstruir índices por este parche.

Se corrigió el recordatorio global y se creó `informes/errores/` con formato e
instrucciones en AGENTS del proyecto y de UI Studio. Las evidencias históricas
siguen en sus ubicaciones originales:

- [Inventario](../../docs/codegraph-comprobacion-inventario-20261021.md).
- [TerrainDev](../../TerrainDev/reports/codegraph-review-20261021/result.json).

## Incidente durante la verificación

El primer intento no ejecutó casos: global-setup no encontró `npm` (salida 127
al lanzar copy-assets). Fue una omisión de PATH en el comando de este agente.
Se repitió con el npm y Node aislados existentes; la preparación terminó y la
regresión reprodujo el defecto. No se instalaron paquetes nuevos. El control
negativo posterior era previsto y no representa un fallo nuevo del producto.

## Verificaciones realizadas

- Regresión nueva: falla antes del parche y pasa después.
- 65 casos pasan en `jass-vjass.test.ts` (27), `dynamic-boundaries.test.ts` (37)
  y `explore-synth-constant-endpoints.test.ts` (1). Comando: Node aislado con
  `--liftoff-only node_modules/vitest/vitest.mjs run` y esas tres rutas, con PATH
  de npm/Node aislados. Se ejercitan ambos caminos de presentación (con/sin Flow)
  y se mantienen los sintetizadores dinámicos de TypeScript/Redux.
- `npm run build` con runtime aislado: termina correctamente; `check-ui-build`
  verifica viewer, 29 gramáticas y motor.
- Recarga desde Ajustes MCP de la aplicación, sin cerrar la ventana de Codex.
  Los tres procesos anteriores finalizaron. La consulta real MCP del chat a
  TerrainDev devuelve `Additional graph links` y `static JASS: calls`.
- Sin cambios de lógica del juego ni ampliación de cobertura vJASS; no se
  ejecutaron partidas o ensayos multijugador para un cambio de presentación.

En la preparación de la copia de revisión, el script del padre intentó aplicar
`len()` al contador entero `files` devuelto por snapshot.py: falló sólo la
impresión del resumen posterior a crear la copia. Se leyó el manifiesto y se
verificó correspondencia de los 19 archivos contra origen antes de lanzar
ambos jueces. No se regeneró ni alteró la copia. Registro de esa verificación:
`work/codegraph-etiquetas-review-identity.json`.

## Doble revisión

Dos jueces independientes revisan una única copia de 19 archivos, identidad
`13bba935837a3afa17b67f3eb989ce0667c9bb95c0329b0858a9edb4dfd04c31`.
Ambos jueces terminaron sin hallazgos. El padre verificó después de las dos
revisiones que los 19 archivos coinciden con la copia y conservan su identidad.
No hubo rondas de corrección tras los jurados (0/2). Los jueces realizaron
inspección estática del delta y contexto pertinente; no ejecutaron pruebas ni
auditaron todo tools.ts o los productores de metadata. Sus límites se conservan
en `jurado-A.json` y `jurado-B.json`, dentro de la carpeta de evidencias.

**JUDGMENT: APPROVED** para este cambio de presentación e instrucciones.
La aprobación no amplía el soporte vJASS ni acredita el juego o multijugador.
Identidad y comprobaciones finales en `judgment.json`.



## Evidencia

Logs en `../2026-10-21-174908-codegraph-etiquetas-evidencias/`. El log inicial con cero casos no acredita una
reproducción; `before-retry` sí reproduce la etiqueta incorrecta.
