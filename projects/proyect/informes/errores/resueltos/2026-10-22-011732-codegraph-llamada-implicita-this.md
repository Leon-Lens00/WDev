# CodeGraph: llamada de instancia implícita omitida en RapidPair.spell

- Fecha: 2026-10-22T01:17:32.941859-05:00 (America/Lima).
- Origen: revisión solicitada en el chat de TerrainDev, agente principal.
- Entorno: CachyOS; Warcraft III Classic 1.27b; CodeGraph 1.6.2+jass-vjass.4, extracción31, esquema12.
- Estado actual: resuelto en la revisión .5, verificado en índices reales y MCP nuevo; reconexión desde configuración MCP comprobada. La historia anterior conserva sus estados intermedios.

## Síntoma y resultado esperado

En `TerrainDev/src/libraries/RapidFire.j:271`, el método estático `RapidPair.spell` declara un local `thistype this` y ejecuta `call cast(GetSpellTargetX(),GetSpellTargetY())`. Se espera una relación hacia `RapidPair.cast` con el receptor implícito local `this`.

El índice actual contiene ambos métodos, pero no esa arista. `unresolved_refs` registra `cast` como `failed` en la línea271. La consulta MCP devuelve la fuente y otros recorridos, sin informar esta omisión individual como error de extracción.

## Evidencia y reproducción

1. Consultar por MCP `RapidPair.initialize RapidPair.spell GroundMotion.step GroundMotion.leave MissileStats.released` en la raíz `TerrainDev/src`.
2. Abrir SQLite en modo lectura y consultar las aristas salientes de `RapidFire.RapidPair.spell`: aparecen `fromController`, el local `this` y su lectura; no `RapidPair.cast`.
3. Consultar `unresolved_refs` para `libraries/RapidFire.j`, línea271, nombre `cast`: estado `failed`.
4. Contrastar con `TerrainDev/build/20261021-133143-771381/compiled.j:4038`: JassHelper produjo `s__RapidPair_spell`, cuya línea4041 llama a `s__RapidPair_cast(this,GetSpellTargetX(),GetSpellTargetY())`.

Se verificaron los hashes del mapa y de las15 bibliotecas contra `TerrainDev/reports/verification.json`: coinciden. El índice está `complete`, sin fuentes obsoletas, y conserva versión.4/extracción31. La evidencia compilada pertenece a las fuentes actuales; no se ejecutó una nueva partida ni compilación para esta revisión.

## Impacto y causa

Impacto confirmado: un seguimiento del evento de hechizo hacia la ráfaga puede quedar incompleto; consultar consumidores de `cast` puede omitir este uso. No se demuestra un defecto del mapa ni del runtime. La fuente directa y JassHelper acreditan la llamada.

Hipótesis: la resolución del receptor implícito de instancia desde un método estático con local `this` no se conserva. No se ha aislado aún si la causa está en inferencia, resolución o filtrado de candidatos. No atribuirla a toda llamada estática ni afirmar regresión frente a revisiones anteriores sin compararlas.

## Acciones y verificaciones

- Revisión sólo de lectura; sin cambios en CodeGraph, bibliotecas, configuración o mapas.
- Recorridos confirmados: `shoot → launch` generado por MissileStruct, `onPeriod → resolve`, `tick → GroundMotion.step`, `cast → GroundMotion.enter`, `finish → GroundMotion.leave` y referencias explícitas a callbacks.
- Los201 avisos conocidos de cobertura no equivalen a201 defectos. Esta omisión sí se registra por contraste concreto con la salida del compilador.

## Pendientes

Crear una regresión mínima con el patrón exacto, contrastarla con JassHelper y corregir/verificar el resolvedor en una tarea de implementación. Mientras tanto, ampliar la lectura del método al revisar consumidores: la ausencia de arista no acredita ausencia de llamada.

## Contraste independiente de las evaluaciones

Fecha: 2026-10-22T01:22:54.140897-05:00

Se leyeron las evaluaciones más recientes de «Implementar sistema de equipo»
y «Verifica soporte de wc3ctl». Ambos ejecutaron consultas MCP sobre sus sistemas;
el segundo detectó este caso concreto que el primero no había examinado.
No son dos dictámenes contradictorios: utilidad operativa y cobertura incompleta
pueden coexistir.

Reproducción independiente del agente principal en el chat de adaptación:
consulta MCP RapidPair.spell/RapidPair.cast, seguida de SQLite de sólo lectura.
El índice sigue complete, revisión .4, extracción 31 e integridad ok. spell tiene
aristas a fromController y a su local this, pero ninguna a cast. unresolved_refs
mantiene cast como failed en libraries/RapidFire.j:271. La salida existente de
JassHelper en compiled.j:4041 sí contiene s__RapidPair_cast(this, ...).
La incidencia permanece abierta; no se modificó el resolvedor ni se repitieron
compilación o pruebas de juego en esta revisión.

No existe codegraph.json en TerrainDev/src, y no se localizaron declaraciones
indexadas de GetSpellTargetX/GetSpellTargetY/GetTriggerUnit. Esto concuerda con
el contexto conservador y las APIs ausentes señalados por el otro chat; es una
limitación de entradas/configuración distinta de la llamada cast omitida.
No elegir release/debug ni completeInputs por conveniencia sin comprobar el build.

Comprobación de vigencia de fuentes: las 15 bibliotecas coinciden con los hashes
de reports/verification.json. El primer comparador auxiliar buscó nombres sin
añadir .j y devolvió false por rutas inexistentes; corregir esa construcción de
rutas produjo 15/15 coincidencias. Fue un fallo del comprobador auxiliar, sin
diferencias de fuentes. La compilación histórica no se vuelve una prueba nueva.

## Implementación autorizada y preparación

El usuario autorizó corregir y archivar incidencias resueltas. Causa localizada:
el guard de resolución descarta todo método de instancia si el contexto es
estático, sin revisar el receptor local this. Prueba de regresión en copia aislada.
Primer arranque no ejecutó tests: npm no estaba en PATH durante global-setup-dist;
se recupera usando el tooling local existente. No contar esa salida como RED
del comportamiento. Dos rutas auxiliares se corrigieron antes de compilar:
vjass está en FrozenThone/scripts/wc3.py y la copia de compiler-profile.py
requería raíz absoluta al ejecutar desde checkout. Sin cambios de producto por
esos intentos; se conserva el fallo original de la llamada implícita.

## Corrección candidata verificada

Regresión real antes del arreglo: implicit-before-recovered.log ejecuta cuatro
casos; los dos positivos fallan y los dos controles negativos pasan. El fallo
previo de npm quedó recuperado y separado de esta reproducción.

La corrección admite this local/parámetro con representación entera conocida,
sin inventar instancia cuando no existe o es handle/array. Mantiene el límite
de function_ref de instancia y la privacidad/precedencia existentes.

implicit-after.log: 69 pruebas de tres suites pasan. Tras ampliar la regresión
a ocho casos, regression.log confirma 6093 PASS, 36 omitidas y 466 suites PASS.
Compiler-results.json contiene tres positivos (thistype/Pair/integer this) y
dos negativos previstos (sin this/unit this), contrastados con JassHelper+pJASS.
Las copias aisladas de misiles e inventario con APIs Classic y perfil release
indexan sin errores de extracción; misiles recupera cast y los natives de spell.
Aún pendiente: instalar, reconstruir raíces reales y recargar MCP.

## Instalación y recuperación del auxiliar de reconstrucción

Instalada la candidata .5/extracción 32/esquema 12 desde el build aprobado por
las pruebas, con respaldo production-backup-20261022-013435 y fuentes originales
intactas. Se detuvieron únicamente los procesos MCP antiguos de CodeGraph.
El primer auxiliar llamó CodeGraph.init en índices existentes: rechazó la
operación antes de escribir. Se corrigió a CodeGraph.open seguido de indexAll;
la salida original queda en production-rebuild-first-attempt.log. No era un
fallo de extracción ni pérdida de datos. El intento previo de editar CHANGELOG
usó una ruta relativa desde checkout; se corrigió con ruta absoluta antes de
instalar y sin cambios funcionales por ese fallo del auxiliar.

Las tres raíces se reconstruyeron en .5 y pasaron integridad y extracción sin
errores. El MCP instalado nuevo devuelve fuente en las tres y muestra spell →
cast. El primer canario del watcher intentó leer SQLite sin haber inicializado
su raíz; la consulta MCP no crea índices automáticamente. Se corrigió el
auxiliar para inicializar/indexar antes de abrir MCP. Salida previa conservada
en watch-this-uninitialized.log; no afectó índices productivos.

## Verificación de instalación

Revisión .5/extracción 32/esquema 12 instalada. Tres raíces complete con
quick_check ok, cero errores de extracción; 18/58/4 archivos y
8874/10737/126 nodos. El incremento JASS proviene de las dos APIs por raíz.
Se conserva el hash de los 76 archivos originales; no se cambió el mapa.

production-mcp-results.json acredita identidad .5 y fuente en tres consultas
JSON-RPC reales. La de misiles muestra spell → cast y resuelve GetSpellTargetX,
GetSpellTargetY y GetTriggerUnit contra common.j. Es una conexión de prueba
nueva; no se presenta como consulta de la conexión antigua de este chat.

watch-this-results.json: dos transiciones del watcher instalado, en 602 y
803 ms, observadas por SQLite de sólo lectura antes de otra consulta/sync.
La primera ejecución sin índice fue recuperada; no se contó como PASS.
El perfil release está respaldado por el comando sin --debug del builder;
completeInputs continúa false y las APIs Classic se declaran como entradas
del grafo sin importarlas al mapa. JassHelper/pJASS siguen siendo validadores
separados; no se ejecutó una partida ni multijugador por esta corrección.

No se amplía el dictamen de jurados de la revisión .4 al parche .5. La evidencia
de este parche son la reproducción, los oráculos de compilador, la suite
completa, el build y las comprobaciones reales descritas aquí.

## Cierre y archivo

Fecha: 2026-10-22T01:41:41.386919-05:00

La reconexión desde configuración MCP recreó el proceso administrado por la aplicación después
del build instalado. Se comprobaron tres índices completos e íntegros y fuentes
originales intactas (app-reload-verification.json). El MCP independiente .5 ya
había devuelto fuente y spell → cast. La consulta posterior desde el transporte
de este chat se registra por separado; no se atribuye a esa conexión lo que
sólo fue probado en el proceso independiente. Corrección funcional y activación
comprobadas; informe trasladado a resueltos/ por instrucción del usuario.

Verificación final desde este mismo chat: tres llamadas codegraph_explore
devolvieron fuente, sin errores ni estados de vigencia pendientes; misiles
muestra spell → cast. Respuestas en current-chat-mcp-{missiles,inventory,ui}.json
y resultado en app-reload-verification.json. El interruptor de MCP de la app
recreó los tres procesos y recuperó el transporte en esta ocasión; no hizo falta
el botón adicional de recarga ni se interrumpió el turno. Recuperación completa.
