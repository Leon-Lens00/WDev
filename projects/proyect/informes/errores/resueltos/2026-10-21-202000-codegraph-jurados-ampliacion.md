# Hallazgos de los jurados sobre la ampliación vJASS

- Entorno: CodeGraph local 1.6.2+jass-vjass.3, extracción 30, Node 24.16.0.
- Origen: jurados A y B, copia congelada de 27 archivos, hash
  `8f3b0916c35ad25c8c8af0b751b23ea8152746bdf6a31c66019843ced353dbd2`.
- Estado actual: resuelto; ver «Activación confirmada y cierre definitivo». Los estados intermedios se conservan como historia.

## Casos

1. JD-A-001 / JD-B-002: para S[0].tick(), un receptor sin binding de array
   podía convertirse en el tipo S y enlazar S.tick sin conocer el retorno del
   operador []. Riesgo de destino incorrecto; esos operadores están fuera del
   soporte declarado. Corroboración prevista: regresión negativa y JassHelper
   con operador que retorna Other.
2. JD-A-002 / JD-B-001: una declaración debug se contaba como hecho
   incondicional para .exists y podía retirar un fallback de release.
   Corroboración prevista: conservar la rama en la extracción y contrastar
   fixture con el compilador.
3. JD-A-003: sync reextrae todos los consumidores JASS y cada indexFile borraba
   la caché del catálogo; repetía N veces el recorrido/lectura de N fuentes.
   Corroboración prevista: contar lecturas reales del catálogo en una
   sincronización de tres fuentes y confirmar que se leen una vez por lote.

No hay un fallo observado del mapa por estos casos. Se corrige la herramienta
para evitar conclusiones equivocadas y trabajo repetido en futuros cambios.
Los resultados de los jueces son inspección estática; el padre ejecuta las
regresiones y el contraste de compilación antes de resolver los hallazgos.

Evidencia: `work/codegraph-ampliacion-vjass-20261021/judgment-before.log` y
`judgment-index.j`, `judgment-debug.j`; resultados posteriores se incorporarán.

## Recuperación de la primera ronda y caso adicional

Las tres causas se reprodujeron y corrigieron. Pasan 1196 pruebas/15 suites,
build y ocho sondas reales. Ambos jueces verificaron los cinco IDs en R2,
hash 44f424faffdc3e3de7af057ed7b35fdd630831d0b18470aef14d67b7abedfde2.
El padre encontró una variante de JD-A-001/JD-B-002: el regex de array
aceptaba el comentario `// array` de una variable escalar. Con operador [] de
instancia, JassHelper/pJASS compila a Other.tick pero el grafo enlazaba S.tick.
Un primer ensayo con operador static fue rechazado correctamente por JassHelper
(scalar no es array); no se usa ese ensayo inválido como prueba del defecto.
La fixture corregida y su compilación están en judgment-index-comment*.
Estado: segunda y última ronda, comprobación de declaración de array pendiente.
Un comando de preparación usó una ruta relativa desde el fork y no encontró la
fixture; no modificó archivos. Se repitió con rutas absolutas.

## Resultado de la segunda ronda

Ambos jueces verificaron A001/B002 sobre R3 (50 archivos), hash
bf608d5912ec531ae63329261f0c33143fa12301d67d1019db7b4d249bddf806.
El padre comprobó integridad después de los dos informes. Pasan 1197 pruebas
en 15 suites, build completo y 8 recorridos reales con convergencia.

Ambos señalaron una regresión del predicado: `S array /* note */ values`
se extrae, pero pierde values[0].tick(). Confirmado por el padre: el grafo da
callees=[] y JassHelper/pJASS acepta la fuente y llama S.tick. Evidencia:
judgment-block-array{.j,-compiled.j,-compiler.log,-graph.log}. IDs
JD-A-R3-001 / JD-B-002-R3: confirmed, pendiente. Se pierde un enlace; no se
observó un fallo de mapa ni un destino incorrecto nuevo por este caso.

JUDGMENT: ESCALATED al agotar dos rondas, no se afirma aprobación final.
Preparado proposed-comment-array.patch para reutilizar el lexer y probar dos
ubicaciones de comentario. Es una propuesta sin aplicar ni validar todavía.
Se solicitó al usuario excepción expresa para corregir y revisar una vez más.
El servidor activo conserva el código previo a las correcciones de jurados; no
se presenta la comprobación MCP anterior como despliegue del parche actual.

## Cierre de correcciones — tercera pasada autorizada

El usuario autorizó “Claro dale otra pasada”. Aplicada propuesta mínima usando
el lexer existente antes del predicado array. La nueva prueba falla antes y
pasa después; 1198 pruebas/15 suites y build pasan. El grafo recupera S.tick
para la fixture de array comentado (judgment-block-array-graph-final.log),
coincidiendo con JassHelper/pJASS. Ambos jurados verifican los dos IDs y no
señalan nuevas regresiones en R4; informes completos judge-{A,B}-r4.json.

JUDGMENT: APPROVED para el código/delta revisado; identidad de 59 archivos
1d42d7d6a0acabff16dfb35d4197335a562cc27b226ff98e2017efc87f01167c.
Integridad comprobada antes y después de ambos jueces y tras pruebas instaladas.
No quedan hallazgos materiales abiertos del alcance. Tres rondas, la tercera
como excepción explícita del usuario, sin reiniciar el contador.

Los tres índices activos se reconstruyeron: 16/56/4 archivos y 1739/4954/734
aristas, quick_check ok, extracción 30/revisión 3, cero cambios en los 76 hashes
originales. Ocho recorridos reales y convergencia pasan. La conexión MCP nueva
independiente pasa consultas en las tres raíces, once transiciones de watcher
y sondas instaladas de array con comentario, scalar con // array y fallback
debug. Fixtures retiradas. mcp-final-verification.json guarda los resultados.
Una consulta rg inicial nombró un archivo CLI que no existía; se leyó luego la
implementación real src/bin/codegraph.ts, sin cambios por ese fallo de ruta.

Pendiente sólo activación en la conexión de la aplicación: el proceso anterior
debe recargarse. Verificar app-reload-final-verification.json y después las
consultas de este chat. No confundir el protocolo independiente con esta última
comprobación. No hay ensayo nuevo en juego/multijugador ni equivalencia completa
con los otros lenguajes del original.

## Activación confirmada y cierre definitivo

La recarga oficial interrumpió el turno; el verificador independiente continuó.
Proceso MCP nuevo 178799, posterior al build, administrado por app-server;
los tres procesos antiguos salieron. Integridad de tres índices correcta y
fuentes originales sin cambios (app-reload-final-verification.json).

Tras reanudar, se ejecutó realmente codegraph_explore desde este chat en las
tres raíces autorizadas: misiles, inventario y UI; respuestas sin isError y
símbolos esperados presentes. Se preservan avisos de cobertura parcial JASS.
Respuestas completas en current-chat-final-mcp-{missiles,inventory,ui}.txt.

Un validador auxiliar inicial marcó la palabra .disabled del código JavaScript
como si fuera un banner DISABLED del índice. Fue un falso positivo del validador,
no de CodeGraph; se inspeccionaron las líneas y se acotó el chequeo a banners.
Las tres respuestas pasaron. No requirió cambios de producto ni repetir MCP.

Estado final: corregido y verificado, sin hallazgos materiales pendientes del
alcance. JUDGMENT: APPROVED, tercera ronda expresamente autorizada. Se conserva
la limitación de soporte estático parcial, sin ensayo nuevo en juego,
multijugador ni evaluación A/B completa del original. El código revisado no
cambió durante activación; sólo se añadieron notas de cierre al plan.
