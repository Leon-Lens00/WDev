# CodeGraph JASS/vJASS: instalación y verificación

## Actualización posterior: revisión .5

Corrección instalada `1.6.2+jass-vjass.5`, extracción 32, esquema 12. La llamada
implícita RapidPair.spell → RapidPair.cast se recupera mediante un receptor this
local/parámetro conocido. Suite del parche: **6093 pruebas aprobadas, 36 omitidas,
466 suites aprobadas**; build y oráculos JassHelper/pJASS comprobados.

Los tres índices se reconstruyeron sin errores de extracción, con 18/58/4
archivos (8874/10737/126 nodos). Las dos raíces JASS incorporan copias declaradas
de APIs Classic y perfil release confirmado contra sus builders. Los archivos
originales y mapas se conservan. Dos transiciones aisladas del watcher y tres
consultas de un MCP nuevo .5 pasan; la recarga de la aplicación quedó comprobada en
work/codegraph-this-20261022/app-reload-verification.json.

La conexión de este mismo chat también quedó verificada: tres consultas reales
con fuente y la relación corregida visible. Los seis informes cerrados están en
`informes/errores/resueltos/`; no quedan abiertos en la raíz al finalizar.

Los jurados y el A/B descritos más abajo pertenecen a .4; no se extienden al
parche nuevo. La omisión posterior queda corregida y su cierre se conserva en
el informe de la incidencia. Los apartados siguientes describen la entrega .4
y su evidencia histórica.


Estado final, 22 de octubre de 2026: **instalado, recargado y operativo desde este chat** en las tres raíces del proyecto. Se completó la ampliación de análisis estático acordada; esto no certifica toda la semántica del compilador ni toda ejecución posible de vJASS.

Runtime local `1.6.2+jass-vjass.4`, extracción 31, esquema 12. Base upstream 1.6.2, commit `6560052a6f856855d3f71eee838fd66ccfa4285d`. La versión de paquete/CLI sigue siendo 1.6.2. Instalación: `/home/snz/Documentos/MCP W3/codegraph-vjass`. El código instalado coincide con los 63 archivos revisados, hash de árbol `d3daa5f81f8254d5fe8f3ae59d506fd9dd638e847b73e559d4bf66cf3c660846`.

## Cobertura y límites

Integración en el pipeline original: scopes, tipos declarados, expresiones y operadores; herencia y delegates; macros y módulos acotados; condiciones según perfil; interfaces y flujo posible de valores de función; hooks, lifecycle, inicialización e inyección; imports y SLK explícitos. MCP, CLI, consultas de impacto y watcher consumen el mismo grafo. Las proyecciones conservan la fuente original y su procedencia.

Los candidatos y contextos desconocidos permanecen visibles. Zinc/C/cJASS, salidas externas no indexadas, strings arbitrarios y dispatch no demostrable siguen siendo fronteras. Una arista ausente no demuestra ausencia de consumidores. Los 57 apartados inventariados del manual se solapan y no equivalen a 57 capacidades certificadas de manera independiente. Compilar con JassHelper/pJASS y probar en Warcraft III 1.27b o multijugador siguen siendo verificaciones separadas.

Contrato detallado: [JASS-VJASS.md](</home/snz/Documentos/MCP W3/codegraph-vjass/JASS-VJASS.md>).

## Verificaciones

- **6085 pruebas aprobadas, 36 omitidas y 465 suites aprobadas**. Build de la candidata y de la instalación completados. Los casos omitidos no cuentan como aprobados.
- Fixtures positivas y negativas contrastadas con JassHelper Classic y pJASS. El ejemplo inicial con `Compute` en globals era inválido por orden de declaraciones; se conservó como negativo. El ejemplo corregido con el native `StringLength` compila.
- Control JavaScript Express: 148 archivos, 1124 nodos y 2240 aristas. El grafo previo y el nuevo son estructuralmente iguales al excluir timestamps y ausencias JSON equivalentes.
- Corpus reales: Noise, 2 archivos y 381 líneas; Jassjass, 1 archivo y 1719 líneas; Nestharus, 255 archivos y 70 807 líneas. Cero errores de extracción; los avisos de cobertura se conservaron. No equivalen a los corpus upstream de miles de archivos ni certifican todas sus APIs para Classic.
- Nueve recorridos MCP sobre esos corpus verificaron fuente y hashes. En 36 sesiones A/B independientes de Codex, hubo cero lecturas/búsquedas de contenido con MCP frente a 56 sin él, con entre una y tres consultas por caso y cero fallos MCP.

| Corpus | Tiempo medio con MCP | Sin MCP |
|---|---:|---:|
| Noise | 27,15 s | 27,05 s |
| Jassjass | 24,61 s | 30,00 s |
| Nestharus | 31,79 s | 32,49 s |

El A/B adapta el ensayo a Codex con el modelo configurado, porque Claude CLI no estaba disponible. Ambos brazos recibieron la misma política condicional CodeGraph-first del proyecto. El preflight sin esa regla no eligió MCP: no se acredita adopción espontánea. Dos repeticiones no demuestran aceleración universal; el corpus pequeño fue neutral y algunos casos necesitaron más de una consulta. Las sesiones fueron de lectura, sin cambiar la configuración global ni copiar credenciales.

## Instalación y actualización automática

| Índice | Archivos | Nodos | Errores de extracción | Avisos de cobertura |
|---|---:|---:|---:|---:|
| TerrainDev/src | 16 | 1234 | 0 | 201 |
| inventory-integration | 56 | 3098 | 0 | 329 |
| ui-studio/dist | 4 | 126 | 0 | 0 |

Las tres bases tienen estado completo, esquema 12, extracción 31, identidad .4 e integridad SQLite correcta. Las fuentes productivas permanecieron intactas. Tras la recarga oficial, **este mismo chat** consultó `RapidFire.RapidBolt`, `InventoryProbe` y `applyTheme`: las tres respuestas devolvieron código, sin errores de transporte ni estados `DISABLED` o `RECOVERING`.

Ocho pruebas aisladas del watcher instalado verificaron altas y bajas JASS, actualización de consumidores de módulos sin editar, cambios de SLK y perfil, y altas/cambios/bajas JavaScript. Se observó SQLite antes de cualquier consulta o sincronización adicional. El watcher responde a cambios en disco de cualquier agente mientras está activo; se libera tras diez minutos de inactividad, al desalojar el proyecto o al cerrar el servidor. La siguiente consulta reabre y sincroniza el índice.

Respaldo consistente: `work/codegraph-completo-vjass-20261021/production-backup-20261022-004742/`. Las instrucciones del proyecto reflejan la revisión instalada. No ejecutar `codegraph upgrade` sobre esta adaptación.

## Revisión independiente y evidencia

**JUDGMENT: APPROVED** para el código estático revisado y sus límites documentados. Dos jueces verificaron los seis hallazgos tras una ronda de corrección, sin nuevas regresiones del delta. Se corrigieron límites de constantes, condiciones anidadas y omisiones de flujo/inicialización, además de reforzar el aislamiento por lenguaje. El ejemplo TypeScript normal de la primera revisión no reproducía la colisión propuesta; esa rectificación permanece registrada. Los jueces revisaron código y evidencia; el agente principal ejecutó las pruebas. Su dictamen no certifica runtime Warcraft ni igualdad de rendimiento con todos los lenguajes y modelos.

Evidencia conservada en `work/codegraph-completo-vjass-20261021/`: `judgment-final.json`, `full-regression-r2.log`, `agent-ab/audit.json`, `production-database-checks.json`, `installed-watch-results.json`, `app-reload-v4-verification.json` y las tres respuestas `current-chat-v4-mcp-*.json`.

El transporte antiguo quedó cerrado durante la promoción. La recarga oficial lo recuperó y la comprobación desde este chat cerró la incidencia: [fallos y recuperación](</home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-21-211753-codegraph-conformidad-vjass.md>).

## Hallazgo posterior en uso real (.4), corregido en .5

La evaluación posterior del chat «Verifica soporte de wc3ctl» detectó una
omisión real en la revisión .4: RapidPair.spell no enlaza con RapidPair.cast
cuando usa un local thistype this dentro del método estático. El contraste
independiente por MCP, SQLite y salida de JassHelper confirma el caso. El índice
está actualizado; cero errores de extracción no equivale a resolución completa.

La integración continúa operativa, pero esta omisión limita el seguimiento del
evento y los consumidores de cast. Fue confirmada y corregida posteriormente en .5; no queda cubierta por el
APPROVED anterior, que corresponde al snapshot y los casos entonces revisados.
[Incidencia y reproducción](errores/resueltos/2026-10-22-011732-codegraph-llamada-implicita-this.md).
Las evaluaciones de inventario/UI y misiles coinciden en su utilidad para el
trabajo diario; ninguna demuestra paridad exhaustiva con los lenguajes upstream.
