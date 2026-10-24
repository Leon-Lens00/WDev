# Ampliación del análisis vJASS en CodeGraph

## Objetivo y base

Ampliar la cobertura de las bibliotecas reales de TerrainDev e inventario,
conservando la infraestructura del original CodeGraph v1.6.2 y su criterio de
no adivinar destinos. Base local: `1.6.2+jass-vjass.2`, extracción 29, incluido
el arreglo de etiquetas aprobado en `informes/errores/resueltos/2026-10-21-174908-codegraph-etiquetas.md`.
Fuente: `/home/snz/Documentos/MCP W3/codegraph-vjass`; Node 24.16.0 aislado.

Autorizado: implementar ampliaciones, probarlas, actualizar índices e instrucciones
y recargar MCP. No modificar mapas o fuentes de producción para facilitar el
análisis. No sustituir el fork mediante upgrade ni afirmar equivalencia general
con todos los lenguajes. El soporte se declara por capacidades demostradas.

## Referencias e interfaces

- Original: `docs/design/dynamic-dispatch-coverage-playbook.md` y
  `callback-edge-synthesis.md`: resolver cuando existe una referencia nombrada;
  sintetizar sólo con evidencia de registro/despacho, conservando incertidumbre.
- Parser/resolvedor actual: `src/extraction/jass-extractor.ts`,
  `src/resolution/jass.ts`; pipeline original en `src/extraction/index.ts`.
- Toolchain: skill `build-warcraft3-vjass-127b`, JassHelper instalado y pJASS;
  compilar fixtures nuevos mediante el lanzador local, sin empaquetar mapas.
- Consultas MCP ejecutadas a `TerrainDev/src`: MissileStruct, RapidBolt.launch,
  onPeriod/onRemove y Missile.createXYZ. La lectura devuelta demuestra el uso de
  módulos y macros; actualmente launch de RapidBolt no está enlazado.

## Fases y criterios de aceptación

1. Preparar regresiones de módulos anidados, callbacks de thistype, macros
   parametrizadas entre archivos, imports internos, ciclos/ambigüedad y actualización.
   Deben fallar por cobertura ausente en la base; los controles negativos nunca
   deben enlazar un destino ajeno.
2. Integrar expansión estática acotada de macros/módulos con catálogo de fuentes
   dentro del alcance indexable. Conservar coordenadas originales y procedencia
   explícita para lo generado; no presentar cuerpos generados como texto del disco.
   Imports sólo enlazan archivos ya autorizados/indexables. Una expansión no
   soportada se declara, no se simula como completa.
3. Ampliar resolución de receptores/indirecciones demostrables y validar con
   JassHelper. Los casos dinámicos sin destino demostrable siguen sin resolverse.
   Medir relaciones reales nuevas y límites, sin usar el número de avisos como
   porcentaje de cobertura semántica.
4. Verificar incremental frente a reconstrucción completa al cambiar/eliminar
   una definición consumida. Ejecutar suites pertinentes, controles de otros
   lenguajes, compilación y consultas sobre copias de las raíces reales.
5. Actualizar versión de extracción/identidad local, documentación, índices
   autorizados y MCP activo. Registrar resultados y pendientes exactos.

## Estado

Implementadas las fases 1–3 y comprobado el núcleo de la fase 4.

- Nuevas pruebas cubren módulos/callbacks por consumidor, macros entre archivos,
  imports acotados, ámbitos privados de origen, onInit independientes, cadenas
  factory/array tipadas, operadores getter/setter, helpers nombrados y lifecycle
  sin inventar cuerpos. Casos negativos de ambigüedad, ciclos y exclusiones.
- La primera regresión de invalidación reprodujo proyecciones obsoletas tras
  borrar una definición; corregido y contrastado por igualdad del grafo
  incremental frente a una reconstrucción completa. Informe:
  `informes/errores/resueltos/2026-10-21-194600-codegraph-expansion-invalidacion.md`.
- 1.193 pruebas pasan en 15 suites; `regressions-release.log`. La compilación
  completa pasó (`build-3.log`); la preparación final de pruebas recompiló el
  motor con el último ajuste de alias local this. Skill validada por quick_validate.
- Fixture real compilada y validada con JassHelper/pJASS, incluidos módulos,
  capturas privadas de biblioteca, operadores y helpers. En su primer intento
  se corrigió un nombre inválido de la fixture, sin tocar el juego. Salida y
  registros en `work/codegraph-ampliacion-vjass-20261021/compiler-fixture*`.
- Identidad preparada: `1.6.2+jass-vjass.3`, extracción 30. No requiere cambiar
  el formato SQLite. Requiere reconstruir índices y recargar procesos anteriores.

Sondas reales y despliegue de índices completados:

| Raíz | Archivos | Nodos | Aristas | Proyecciones (nodos) |
|---|---:|---:|---:|---:|
| TerrainDev/src | 16 | 1277 | 1739 | 427 |
| inventory-integration | 56 | 3333 | 4958 | 762 |
| ui-studio/dist | 4 | 126 | 734 | 0 |

Las copias convergen tras reconstrucción completa. Pasan 5 recorridos de misiles
(incluidos launch/callbacks y macro createXYZ) y 3 de inventario (tooltip aportado
por módulos). Los índices activos están completos con versión 3/extracción 30,
quick_check ok y cero cambios en los 76 hashes originales. UI Studio conserva
126 nodos/734 aristas; el cambio no añade proyecciones a JavaScript.

Conexión MCP independiente al lanzador instalado: serverInfo confirma revisión 3,
las tres consultas funcionan y 11 transiciones de watcher pasan. Modificar o
borrar módulos actualiza métodos del consumidor sin cambiar sus bytes. Todas
las sondas se retiraron. Evidencia en mcp-live-verification.json y logs.

La medida file-based de dependientes transversales cambia inventario 27→28 de
56 archivos, misiles mantiene 13 de 15 y UI 3 de 4. No representa porcentaje de
llamadas correctas, precisión, exhaustividad semántica o comportamiento runtime;
el beneficio probado son los recorridos nuevos y las regresiones concretas.

Se corrigió además el fallback InventoryItem.buildDescription con una regla
acotada de existencia positiva incondicional thistype.miembro.exists. Esa
condición y su negación están contrastadas con JassHelper/pJASS. No se supone
que toda condición o ausencia pueda evaluarse.

Conexión de la aplicación recuperada tras la recarga oficial: proceso nuevo
posterior al build, procesos anteriores cerrados. Además del protocolo MCP
independiente, se ejecutaron ahora consultas codegraph_explore desde este mismo
chat en las tres raíces; todas respondieron correctamente con el código actual.
Evidencia: app-reload-verification.json y current-chat-mcp-{missiles,inventory,ui}.txt.

No se ejecutó la evaluación A/B de agentes del original en tres repositorios
independientes de distintos tamaños: el runtime Claude/Sonnet no está disponible.
Las pruebas locales no acreditan ese criterio upstream ni ahorros de tokens,
soporte completo del lenguaje o funcionamiento adicional en juego/multijugador.


## Recarga oficial de la aplicación

Comprobación posterior completada: proceso MCP administrado por app-server nuevo,
iniciado después del build final; procesos antiguos cerrados, tres índices en
revisión 3/extracción 30, integridad correcta y fuentes originales sin cambios.
Evidencia: work/codegraph-ampliacion-vjass-20261021/app-reload-verification.json.
Tras reanudar el turno se comprobaron también las tres consultas directamente
desde este chat. El protocolo y las 11 transiciones se habían verificado
previamente con una conexión independiente al mismo lanzador.

## Revisión adversarial y estado actual (prevalece sobre el despliegue anterior)

Dos rondas utilizadas. Los cinco IDs iniciales quedaron corregidos y verificados
por ambos jueces; la segunda ronda aportó una regresión corroborada de arrays
con comentarios de bloque entre tokens. La compilación real conserva S.tick
pero el grafo omite su arista. Informe y propuesta concreta:
- informes/errores/resueltos/2026-10-21-202000-codegraph-jurados-ampliacion.md
- work/codegraph-ampliacion-vjass-20261021/proposed-comment-array.patch

JUDGMENT: ESCALATED; no aprobación final. Se pidió excepción explícita al usuario
para una corrección/pasada adicional, porque Judgment Day limita a dos rondas.
El parche propuesto no se ha aplicado ni validado. Los binarios locales están
compilados hasta R3, pero el proceso MCP de la aplicación sigue con el código
anterior a jurados. No confundir revisión/identidad 3 con igualdad de bytes.

Última identidad revisada: bf608d5912ec531ae63329261f0c33143fa12301d67d1019db7b4d249bddf806
(copia /tmp/codegraph-ampliacion-review-20261021-r3, 50 archivos). Integridad
verificada antes y después; las notas de cierre se escribieron después.
1197 pruebas/15 suites pasan (judgment-r2-regressions.log), build completo
(judgment-r2-build.log), ocho recorridos reales y reconstrucciones convergentes
(judgment-r2-real-probes.log y real-results-final.json). Misiles 1739 aristas,
inventario 4954, UI 734; 76 hashes originales sin cambios.

Si el usuario autoriza la excepción: aplicar la propuesta mínima; comprobar
que la nueva regresión falla antes y pasa después; repetir suites pertinentes,
build y sondas; congelar delta y entregar idéntica copia a los mismos jueces,
limitados al caso comentarios/regresiones. Después reconstruir los tres índices
y recargar sólo la conexión MCP de la aplicación con el procedimiento anterior.
La recarga oficial puede interrumpir el turno; conservar observer y comprobar
proceso nuevo, watcher y consultas de este chat antes de afirmar activación.

## Pasada adicional autorizada y cierre del código

El usuario autorizó la tercera pasada (“Claro dale otra pasada”). El parche de
comentarios se aplicó y pasó TDD antes/después, 1198 pruebas en 15 suites, build
y los ocho recorridos reales con reconstrucción convergente. Ambos jueces
verifican JD-A-R3-001/JD-B-002-R3 sin nuevas regresiones. Los cinco IDs previos
ya estaban verificados. JUDGMENT: APPROVED para el código revisado (no afirmar
aún la activación de la conexión de esta aplicación).

Identidad R4: 1d42d7d6a0acabff16dfb35d4197335a562cc27b226ff98e2017efc87f01167c,
59 archivos en /tmp/codegraph-ampliacion-review-20261021-r4; integridad antes y
después verificada. Estas notas de cierre se escriben después de esa revisión.
Resultados y prompts exactos: judgment-final.json, judge-{A,B}-r4.json,
judge-prompts-r4.json en work/codegraph-ampliacion-vjass-20261021/.

Tres índices activos reconstruidos y comprobados: quick_check ok, extracción
30/revisión 3; misiles 1739 aristas, inventario 4954, UI 734. Todos los 76 hashes
originales siguen intactos. mcp-final-verification.json acredita conexión nueva
independiente, tres consultas, once transiciones watcher y las sondas de los
fallos corregidos. No acredita todavía el transporte de este chat.

Siguiente paso único de activación: recargar la conexión MCP desde Settings.
El verificador preparado verify-app-reload-final.py guarda el proceso nuevo y
la integridad en app-reload-final-verification.json. La recarga puede interrumpir
el turno; al reanudar leer ese JSON, hacer codegraph_explore desde este chat en
las tres raíces, guardar current-chat-final-mcp-{missiles,inventory,ui}.txt y
marcar la activación confirmada. No repetir revisiones ni builds ya acreditados
si el código no cambia. La variante sigue siendo parcial, sin A/B upstream ni
nuevo ensayo de juego/multijugador.

## Activación final confirmada

Cierre completado: app-reload-final-verification.json confirma proceso MCP
nuevo posterior al build y salida de los anteriores. Se ejecutaron consultas
codegraph_explore desde este chat en TerrainDev/src, inventory-integration y
ui-studio/dist; las tres respondieron sin error y con los símbolos esperados.
Respuestas guardadas en current-chat-final-mcp-{missiles,inventory,ui}.txt.
Los avisos de cobertura parcial se conservan y no equivalen a soporte completo.

JUDGMENT: APPROVED para R4, hash
1d42d7d6a0acabff16dfb35d4197335a562cc27b226ff98e2017efc87f01167c.
No quedan pasos de activación ni correcciones materiales pendientes del alcance.
Se mantienen los límites de lenguaje parcial, A/B upstream no ejecutado y sin
prueba nueva de juego/multijugador. Ver judgment-final.json y verification.json.
El código y demás evidencias revisadas siguen intactos; el único archivo de la
copia R4 cambiado después del juicio son estas notas de cierre del plan.
