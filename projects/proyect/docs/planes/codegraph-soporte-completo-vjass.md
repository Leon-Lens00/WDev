# Cobertura completa de vJASS: alcance y ruta propuesta

Estado actual: entrega instalada y comprobada el 22 de octubre de 2026:
`1.6.2+jass-vjass.4`, extracción 31 y esquema 12. Las tres raíces reales y la
conexión MCP de este chat están verificadas. La cobertura acreditada es análisis
estático JASS/vJASS con los límites de `JASS-VJASS.md`; no equivale a toda la
semántica del compilador. Las entradas siguientes conservan la historia del
trabajo y sus estados intermedios. Resultado final en
[informe de entrega](../../informes/codegraph-vjass-2026-10-22.md).

## Objetivo verificable

Cubrir la sintaxis y las relaciones estáticas del dialecto aceptado por el
JassHelper instalado para Warcraft III Classic 1.27b, preservando la incertidumbre
en despachos dependientes de valores de ejecución. Reconocer todas las
construcciones del perfil y explicar las dependencias que no puedan resolverse.
No equivale a predecir toda ejecución ni demostrar ausencia de errores del mapa.

El original define su soporte por extracción estructural y resolución entre
archivos; reconoce relaciones dinámicas sintetizadas como heurísticas. Su
etiqueta Full support no es un certificado de análisis semántico exhaustivo.

## Base comprobada y referencias

- Fork: `/home/snz/Documentos/MCP W3/codegraph-vjass`, original 1.6.2,
  commit `6560052a6f856855d3f71eee838fd66ccfa4285d`, identidad local
  `1.6.2+jass-vjass.3`, extracción 30. Cobertura declarada en `JASS-VJASS.md`.
- Corrección vigente: 1198 pruebas/15 suites, build, ocho recorridos reales,
  watcher y MCP comprobados. Esto acredita esos casos, no un porcentaje del
  lenguaje. Plan y evidencia en `codegraph-ampliacion-vjass.md` y
  `work/codegraph-ampliacion-vjass-20261021/judgment-final.json`.
- Toolchain: `/home/snz/Documentos/ChatGPT/FrozenThone/wc3toolchain.json`;
  compilador `editors/newgen/jasshelper/standart/clijasshelper.exe` de esa raíz,
  SHA-256 `23a3cf524d42581c3d5149db96cc64aeded46b30dbfc12f6815f039da6b55985`.
- Manual y changelog adyacentes: el HTML tiene fechas diferentes en título y
  cabecera, y el changelog llega a 2014-03-10. No deducir la versión binaria de
  esas fechas. Manual SHA-256:
  `41b92dcab46da263544413e40060accb8613ee9dade1c0f9bcf0f6bb7c049dae`.
- Original: `docs/design/framework-coverage.md`,
  `dynamic-dispatch-coverage-playbook.md`, `callback-edge-synthesis.md` y
  `AGENTS.md` del fork. Web de referencia:
  https://github.com/colbymchenry/codegraph/blob/6560052a6f856855d3f71eee838fd66ccfa4285d/README.md
  y https://colbymchenry.github.io/codegraph/core-concepts/knowledge-graph/.
- La copia web histórica del manual devolvió 404; se usó el manual local.
  Incidencia: `informes/errores/resueltos/2026-10-21-204938-manual-jasshelper-web.md`.

## Trabajo necesario y orden de entrega

| Fase | Entregable | Condición de aceptación |
|---|---|---|
| 1. Perfil y matriz | Inventario de reglas y semántica del manual/compilador, opciones, dependencias y casos de referencia | Cada fila tiene estado actual, fuente, ejemplo válido/inválido y salida esperada del grafo; las dudas se contrastan con el compilador |
| 2. Frontend | Parser con árbol sintáctico y preprocesamiento fiel al orden de JassHelper | Expresiones y declaraciones del perfil se reconocen sin depender del formato de una línea; imports/macros/módulos conservan origen y contexto |
| 3. Semántica | Tablas de símbolos, tipos y resolución por fases | Ámbitos, condiciones, receptores y destinos se resuelven según la evidencia; los candidatos ambiguos quedan diferenciados de destinos exactos |
| 4. Integración | Grafo, procedencia y actualización correctos | Los flujos aparecen en explore/impact y al editar/borrar/configurar; el incremental converge con reconstrucción completa |
| 5. Conformidad y uso real | Corpus diferencial y evaluación práctica | Pasan los casos de cada fila, negativos y regresiones; se mide precisión/cobertura y se verifica la utilidad del grafo en repositorios reales |

La elección de parser (propio, Tree-sitter u otro reutilizable) requiere una
prueba de viabilidad. Tree-sitter no es requisito suficiente ni obligatorio.
Una posible integración con el compilador debe demostrar disponibilidad de
estructura/origen utilizables; su JASS generado por sí solo no conserva toda
la identidad de los símbolos originales. Conservar la infraestructura original
de CodeGraph: SQLite, resolución, consultas, CLI, MCP y watcher.

## Matriz inicial de áreas pendientes

Esta lista organiza la futura matriz; no se presenta como inventario exhaustivo
ya verificado de toda la sintaxis ni como afirmación de que falta cada elemento
por completo. Hay soporte parcial que se deberá reutilizar y medir por subcaso.

- Sintaxis: expresiones, declaraciones y encabezados, comentarios/literales,
  casts, acceso encadenado, arrays y almacenamiento extendido; extensiones del
  compilador local documentadas como for/while/break requieren fixtures propios.
- Preprocesamiento: imports y rutas de búsqueda del perfil, orden de expansión,
  macros generadoras, argumentos, módulos y sus privados, static if/elseif,
  constantes, exists, debug/release, dependencias opcionales y scopes.
- Tipos/objetos: interfaces, herencia/stub/super, delegate, operadores [] y
  propiedades, retorno y receptores encadenados, keyword, keys, typeid/getType,
  asignación y arrays de structs, create/allocate/destroy/deallocate y onDestroy.
- Inicialización: library initializer, onInit de structs/módulos y orden de
  dependencias según el compilador exacto.
- Indirección: funciones como objetos, interfaces de función, valores callback,
  execute/evaluate, .name, ExecuteFunc, hook y registros/despachos demostrables
  mediante APIs Classic y bibliotecas. Distinguir posibles destinos de llamada
  efectiva; el origen de valores dinámicos puede quedar desconocido.
- Directivas y generación: inject, SLK/external y artefactos generados. Modelar
  entradas, salidas y dependencias declaradas; resultados de herramientas
  arbitrarias necesitan sus artefactos/configuración para analizarse.
- Zinc: lenguaje adicional aceptado por JassHelper; incluirlo si el alcance es
  todo el entorno JassHelper. El soporte completo de vJASS puede definirse y
  verificarse por separado, con la exclusión explícita de Zinc y otros dialectos.

## Contratos de integración que deben conservarse

Mantener texto original, posición exacta y cadena de expansión/origen; mostrar
código generado como tal. La configuración del compilador es parte de la
identidad del análisis: cambiar debug, dependencias o rutas invalida resultados.
Establecer dependencias de generación para reextraer todos los consumidores
afectados y no sólo archivos cuyo contenido cambió. Mantener avisos de vigencia
y cobertura reales; no mejorar una métrica ocultando avisos o inventando aristas.

La prueba de conformidad compara el extractor/resolvedor con fixtures compiladas
por el JassHelper fijado y validadas con pJASS y common.j/Blizzard.j Classic.
La salida compilada es evidencia de destinos y selección de ramas, no un
oráculo directo de todos los nodos fuente: optimización y generación alteran
la forma del programa. Probar variantes debug/release y controlar optimización
cuando la comparación lo requiera; el lanzador local necesitaría exponer las
opciones necesarias antes de afirmar esa cobertura.

Probar también ausencia de destinos falsos, cambios/eliminaciones y cambios de
configuración, límites de tamaño/ciclos, otros lenguajes y conexión MCP. Medir
por familia de construcciones y destinos conocidos; el número global de tests
o aristas no es porcentaje de cobertura semántica.

La validación del original pide repositorios reales pequeños/medianos/grandes y
evaluación de agentes. Las dos variantes relacionadas de TerrainDev y un
control JavaScript no equivalen a tres repositorios vJASS independientes.
La evaluación A/B original requiere un runtime de agentes actualmente no
acreditado aquí; no bloquea desarrollar el frontend, pero sí afirmar que se
cumplió ese criterio de rendimiento upstream.

## Recursos, límites y próximo paso

Ya existen TypeScript/Node, CodeGraph, JassHelper/pJASS, APIs Classic y fuentes
reales. El desarrollo y la conformidad local no requieren otra API de modelos.
El trabajo principal es implementación, corpus de pruebas y mantenimiento de
la compatibilidad. No hay base suficiente para prometer una duración concreta.

Primer entregable propuesto: matriz completa contra el manual instalado y
fixtures del compilador, con prioridades y aceptación por fila; después decidir
la arquitectura del frontend con una prueba pequeña. No iniciar una larga serie
de ampliaciones aisladas sin esa especificación. Esta propuesta no ha cambiado
código, mapas, configuración ni índices, ni iniciado otra ronda de jurados.

## Desarrollo iniciado

Copia aislada: work/codegraph-completo-vjass-20261021/checkout. Baseline de
hashes del fork activo en baseline.json; no se sustituirá la variante activa
por un prototipo. La matriz inicial derivada del manual tiene sus filas en
coverage-matrix.json y los ejemplos fuente en manual-sections.json; pending
no se cuenta como soporte acreditado. Referencias fijadas en references.json.

Primera decisión de arquitectura: parser de expresiones con AST y recorrido
uniforme de receptores, operadores y valores; reutilizar el lexer para no
confundir comentarios/literales con código. El resolvedor consume descriptores
de expresiones y mantiene scopes/tipos. Se conserva el pipeline de CodeGraph.
La gramática publicada de JassHelper es referencia de sintaxis, no se presume
idén­tica al fork instalado sin contrastar con el binario. Un parser TypeScript
externo se examinó pero no se incorporó: su licencia está vacía.

### Avance del frontend (copia aislada, aún sin despliegue)

Nuevos módulos: extracción jass-expression.ts (AST Pratt), resolución
jass-expression.ts y jass-value-flow.ts; lexer con stream semántico conservando
literales atómicos y comentarios anidados. El extractor produce hechos de
tipos, asignaciones, argumentos y retornos. Persistencia opcional semanticData
con migración SQLite12 (single/batch/update/reopen probado), conservando el
comportamiento sin datos de otros lenguajes. Fuente del activo intacta.

Se prueban cadenas factory/campo/índice, operadores índice reales, getter/setter
y sus retornos, delegates, super, keyword y key; helpers de interfaz de función
con posibles destinos propagados por alias/parámetros y ExecuteFunc(Target.name).
La fuente original de dos fixtures fue inválida: key fuera de globals y nombre
alias rechazado por pJASS.exe interno; corregidas y recompiladas. Incidencia
2026-10-21-211753-codegraph-conformidad-vjass.md; negativos preservados.

Última suite de núcleo: hooks-after.log, 64 casos/5 suites pasan; las pruebas
previas fallaron para tres nuevas relaciones y dos de flujo de valores antes
de integrar. La primera prueba de flujo no llegó a ejecutar por un error TS,
no se cuenta como regresión de comportamiento; el siguiente intento sí ejecutó
y reprodujo los dos casos. Compilaciones reales en compiler-expressions/,
compiler-declarations/ y compiler-values/. No afirmar 57 filas completas por
este primer bloque. Hooks call-site, colon y comentarios anidados probados en
SQLite; su contraste con JassHelper y el resto de la matriz siguen pendientes.

Próximo bloque: evaluación de constantes/condiciones con perfil explícito en
codegraph.json.jass (conservative/release/debug); invalidación por huella de
perfil aprovechando watcher existente de codegraph.json. No interpretar config
inexistente como certeza de debug/release. Después macros/módulos avanzados,
polimorfismo/lifecycle, imports/artefactos y cierre de matriz/corpus real.

### Avance posterior: condiciones, macros, almacenamiento

Copia aislada sigue sin desplegar. `group-erasure.log`:73 pruebas/5 suites pasan; condiciones de JassHelper contrastadas con oracle, AST conserva agrupación y no atribuye tipo struct a receptores agrupados que el compilador rechaza. Perfil conservative/release/debug con invalidación de consumidores al cambiar configuración.

`preprocessor-expanded-final.log`:45 pruebas/3 suites pasan. Catálogo con el orden real: macros antes de módulos, macros dentro de módulos y módulos generados, namespaces privados por módulo, textmacro_once, comillas escapadas e import vjass con lookupPaths dentro del scope. Compiler-preprocessor-results.json:5 positivos y nested-macro negativo explícito.

Bloque siguiente en curso: arrays dinámicos anidados, 2D globales/static fields, propiedades size, constructor create heredado preservando subtipo y callbacks onDestroy de subtipos conocidos sobre referencia base; fixtures válidos compilados con --nooptimize y pJASS. Un fixture con array2D de instancia fue rechazado: corregido a static, original inválido conservado. La prueba inicial confundió getCallees (destinos únicos) con número de sitios: se revisan aristas por línea. Se añaden dependencias de lectura/escritura de almacenamiento y etiquetas explícitas de destinos posibles.

Pendiente del nuevo bloque: cerrar regresiones de helpers de test que antes agrupaban referencias y llamadas, ExecuteFunc con constantes/scope prefixes, inject e inicializadores, artefactos externos/SLK, matriz completa, corpus, rendimiento, revisión y despliegue. No atribuir los 1198 tests de la .3 anterior a esta revisión nueva.

### Validación de corpus y SLK (en curso, sin despliegue)

frontend-recovery.log:102 pruebas/6 suites pasan. frontend-linebreaks.log:103/6, incluyendo statements con strings físicos multilínea. Core-regression.log pasó899/13 suites en una revisión anterior de este bloque (no sumar como si fueran todas de la revisión final).

Corpus públicos fijados en references.json: eGlint Noise (MIT), lep/jassjass (sin licencia declarada; sólo lectura/prueba local, no distribuir fuentes), Nestharus JASS (MIT); h-vjass queda como referencia de sintaxis C/cJASS fuera del perfil. Snapshots acotados en corpus-runs/, manifiestos y hashes/revisión de repos. Primera corrida mezcló otras variantes: include es aditivo; se recuperó mediante copias sólo de fuentes del componente. corpus-profiled-results.json:2 archivos/381 líneas,1/1719,255/70807. Cero errores de parseo en las tres raíces; Nestharus mantiene2268 avisos, mayormente condiciones conservadoras, proyecciones y variantes ambiguas, no equivalen a cobertura completa. No son compilaciones de esos proyectos en Classic: Noise usa BlzBitAnd. Exploraciones reales con ToolHandler staged en corpus-explore-*.json, sin abrir los índices schema12 con el MCP activo antiguo. Faltan3 flujos deterministas por corpus y evaluación del rendimiento según método upstream.

Módulos: se conservan plantillas opacas, incluidas partes con métodos abiertos, hasta implementación; se modela deduplicación por struct antes de static-if, y se enlazan consumidores con definiciones reales de module/textmacro. module cycle es idempotente en JassHelper. Tests de impacto/plantillas pasan.

SLK: nuevo jass.dataFiles explícito, contención física/exclusiones y límite de lectura, huella de datos invalida consumidores, watcher acepta esos paths, parser SYLK acotado, constructor/campos/expresiones convertidas con tipos declarados, sin ejecutar herramientas externas. Fixture real compiler-slk-result.json compila con JassHelper/pJASS; archivo generado confirma que el texto de un campo string no genera llamada. Test encontró y corrigió falta de notificación onFileChange en consumidores invalidados sólo por perfil/datos; comparar incremental con fresh ahora pasa. Datos excluidos/borrados/symlink externo y rama static-if falsa se comprueban. Errores/reportes en2026-10-21-211753-codegraph-conformidad-vjass.md.

Faltante inmediato: cerrar operadores con cero, reglas de privacidad allocate/deallocate e interfaces de función con tipos convertidos por JassHelper (compiler-types en curso). Después actualizar matriz de conformidad, deps externas, etiquetado/cobertura MCP, pruebas globales, benchmarks y doble jurado antes de desplegar.

### Conformidad adicional y benchmarking preparado

core-regression-expanded.log:1040 pruebas/19 suites pasan,9 skipped; es la revisión anterior a los dos afinamientos de scope e inputs parciales, no el PASS final. comment-normalization-locations.log pasa113/6; optional-build-context-after.log117/6. Normalización de comentarios elimina comentarios de bloque y sus saltos como JassHelper, conserva spans/offsets para fuente real y diagnósticos originales. oracles compiler-comments-flags-results.json validan identifiers unidos, directivas tras comentario y flags globales entre libraries. Se restauró diagnóstico de comentario sin cerrar perdido al normalizar; test de endLine fue corregido de5 a4 según fixture real.

Nuevos helper jass-runtime-name.ts distingue nombres runtime de qualifiedName para ExecuteFunc y encabezados SLK; protege constructores privados contra fallback builtin y helpers .name de function interfaces inválidos. compiler-extra-types-results.json:cabecera comentada válida; FunctionInterface.S.method/name y constructor privado/extensión rechazan según compilador. Deallocate interno dispara onDestroy; comparación con cero no llama operador<; function-interface structs se convierten a integer, unit/widget no.

Módulos conservan SCOPE_PRIVATE de la biblioteca definidora (no la implementadora); SLK busca tipo por spelling del compilador, sin capturar homónimo privado léxico. scope-data-conformance.log82/4 pasa, oracles compiler-scope-* pendientes/comprobar.

Inputs parciales: prueba red optional-build-context-before.log detectó poda falsa. Library/flags de otro archivo sólo son ciertos con imports transitivos o completeInputs explícito. .exists de un tipo externo no se convierte en falso por no haber recorrido el otro archivo. Ajuste para que la caché de alias use la procedencia del archivo, no el primer consumidor; build-context-cache.log en curso. Falta regresión específica de orden de caché.

corpus-mcp-probes.mjs usa JSON-RPC stdio real sin SDK externo (no instalado). corpus-mcp-results.json:9/9 recorridos con fuente y hashes de fuentes sin cambios, latencias warm24–91ms, primeras261–488ms. Watcher intencionalmente desactivado, no probaría watcher. Es smoke preliminar: repetir tras rebuild con código congelado/versionado.

Claude CLI no está instalado. Codex CLI sí, login ChatGPT activo. Se consultó OpenAI Docs oficial (non-interactive-mode y config-reference); CLI dispone --ignore-user-config, --ephemeral, --json y read-only. Se prepara adaptación A/B con mismo modelo configurado por usuario gpt-6.1-sol/high en ambos brazos, sin cambiar configuración global ni copiar credenciales; no llamarlo ensayo Claude idéntico. Pilot en agent-ab/pilot.jsonl, prueba sin herramientas. Método original scripts/agent-eval/run-all.sh exige con/sin MCP, CLI de CodeGraph neutralizada y0 Read/Grep dentro del presupuesto; mantener auditoría de logs y verificar aislamiento.

Pendiente grande: matriz57 áreas sigue sin cierre formal; faltan conformance unit/compiler asociaciones completas, docs/capacidades MCP actualizadas, evalA/B,2jurados, build final, baselinehash/conflictos, desplegar sólo aprobado a activo y rebuild3raíces, recarga MCP real y consultas de este chat. No modificar activo ni afirmar completo todavía.

### Candidata congelada .4 (22 de octubre, sin despliegue)

Runtime 1.6.2+jass-vjass.4, extracción31/schema12. AST acotado evita overflow
por expresiones largas. Inyección siempre representa su región completa,
main/config→namespace de inyección, locales y cadenas multilínea conservan spans.
Receptores de campos/factories condicionales con tipos incompatibles ya no eligen
el primer tipo: dos negativos reproducidos y corregidos, perfil debug positivo.
conditional-types-after.log:106/4 suites pasan. No hubo cambios posteriores al
código de esa corrección.

Suite global full-regression.log:6074 PASS,2 fallos de dependencia zip ausente,
36 skipped,464 suites. zip se preparó sólo en work/tooling desde repo extra;
bundle-recovery.log:3PASS/2skip, recupera ambos fallos Windows archive (no prueba
Windows nativo). Conjunto de casos ejecutables6076PASS; no sumar repetidos.
release-build.log pasa. Regresiones de otros lenguajes incluidas en suite global.

Corpus reconstruidos con versión final:2/381líneas/168nodos,1/1719/466,
255/70807/8715. Cero diagnósticos severity=error;2/0/2077 warnings retenidos.
corpus-final-mcp.log/corpus-mcp-results.json:9consultas JSONRPC stdio reales,
version4, fuente/hash verificables, primera296–532ms y warm23–108ms. No watcher
porque se desactiva intencionalmente en benchmark.

Matriz57secciones está asociada a tests y evidencia compiler; estados describen
cobertura estructural con límites, nunca57features independientes ni compilador
completo. ExternalTools es frontera explícita, no ejecución. JASS-VJASS.md,
README y CHANGELOG actualizados. Código activo sigue intacto (.3); hash de
baseline sin conflictos. Copia Judgment Day review-r1:62archivos,
7993aadb021dac007adf949406f0400f0cfb8263179bd793d21d91b1d2978e94,
review-r1.diff/context fijados. Dos jueces nuevos iniciados, no confundir con
jurados antiguos de .3.

A/B adapta consumidor Codex en lugar de Claude ausente. Preflight natural with
no eligió MCP, se conserva y no cuenta como éxito. Pilot confirma disponibilidad.
Ensayo principal usa la misma política condicional CodeGraph-first para ambos
brazos (coherente con AGENTS del usuario), sesiones fresh read-only,
gpt-6.1-sol/high,2repeticiones por3prompts por3corpus, orden alternado.
No atribuir adopción espontánea ni igualdad con metodología Claude upstream.
agent-ab/method.json y logs completos conservan diferencias y métricas.

### Instalación22oct00:49

.4/extracción31/schema12 instalada;63archivos revisados verificados contra activo.6085PASS/36omitidos/465suites.36A/B finales completados,0lecturas conMCP frente56sin; pequeño neutral,1–3explores, diferencia metodológica Codex/Claude explícita. Ambos jueces verifican6IDs, una ronda.3raíces rebuilt completas e íntegras, fuentes intactas;8watcher canarios pasan antes de consulta/sync. Informe de entrega informes/codegraph-vjass-2026-10-22.md. Único paso de sesión pendiente: recargar transporte MCP antiguo del chat (Transportclosed); fresh MCP instalado sí responde.4.

### Cierre de sesión e instalación — 22 de octubre de 2026

La recarga oficial de MCP recreó el transporte que había quedado cerrado.
Tras reanudar este mismo chat, tres llamadas reales a codegraph_explore
consultaron RapidFire.RapidBolt, InventoryProbe y applyTheme en sus raíces
correspondientes. Todas devolvieron fuente, sin isError ni estados DISABLED o
RECOVERING; las respuestas JASS muestran las capacidades nuevas de la revisión 4.
Se conservan respuestas completas en current-chat-v4-mcp-*.json y la comprobación
en app-reload-v4-verification.json dentro de la carpeta de evidencia.

Quedan cerrados despliegue, índices, watcher, recarga y comprobación desde el
cliente actual. Suite final: 6085 pruebas aprobadas, 36 omitidas y 465 suites
aprobadas. Dos jurados verificaron los seis hallazgos tras una ronda de corrección.
Los límites semánticos, metodológicos y de runtime permanecen documentados;
no se certifica toda ejecución de vJASS ni rendimiento idéntico a upstream.
