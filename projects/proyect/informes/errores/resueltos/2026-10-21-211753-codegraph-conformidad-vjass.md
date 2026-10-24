# Conformidad de la ampliación vJASS: fallos de pruebas y recuperación

Estado actual (22 de octubre): incidencias corregidas o aclaradas con evidencia;
instalada la revisión .4, extracción 31 y esquema 12. Suite final: 6085 pruebas
aprobadas y 36 omitidas; tres índices íntegros y ocho comprobaciones de watcher
aprobadas. La conexión de este chat se recuperó mediante la recarga oficial de
MCP y devolvió fuente en las tres raíces. Los límites conocidos de cobertura
permanecen explícitos y no se contabilizan como fallos resueltos del lenguaje.

Entorno: copia aislada CodeGraph basado en revisión 3/extracción 30, Node24,
JassHelper Classic instalado hash 23a3cf524d42581c3d5149db96cc64aeded46b30dbfc12f6815f039da6b55985.
Fecha: 2026-10-21T21:17:53.460376-05:00

Primer fallo inesperado: fixture case-6 declaró private key SLOT directamente
en scope. JassHelper rechazó línea3: Expected type/struct/interface/function/
keyword/scope. El manual declara key dentro de globals. Causa confirmada:
entrada de prueba inválida, no defecto demostrado del compilador. Se conserva
case-6-invalid.j y logs; se añade globals a la fixture válida y se valida
ubicación en el extractor. Repetición de compilación pendiente.

Las primeras búsquedas internas nombraron __tests__/db.test.ts, inexistente;
se localizó el runner real con rg --files y se añadieron pruebas independientes
de persistencia; sin cambios derivados de esa ruta fallida.

Registro histórico de preparación: en ese momento no se había desplegado esta ampliación. Los controles negativos previstos
(Unknown factory y regresiones antes de implementar) no se cuentan como fallos
de producto. Evidencia bajo work/codegraph-completo-vjass-20261021/.

Recuperación key: la fixture corregida compiló y fue validada por pJASS;
compiler-declarations/case-6-fixed.log y -fixed-compiled.j. La entrada inválida
permanece conservada. Se identificó además un error de tipado en el prototipo
de flujo de valores (TS2339: unión string vacío | Node por un &&); primer intento
no ejecutó tests, por lo que no acredita una regresión de comportamiento. Se
corrigió a selección ternaria y se repite el ensayo de casos antes de integrar.

La fixture de interfaz de función usó el identificador alias. El pJASS.exe
invocado internamente por JassHelper lo rechaza como Invalid name, líneas25/26;
se conserva case-7-invalid-alias.j y el log original. Se renombra callbackAlias
en fixture/prueba; no hay evidencia de un fallo de CodeGraph por ese nombre.
No se afirma validez de la fixture original. Verificación corregida pendiente.
Otra búsqueda documental apuntó a un ejemplo React inexistente; se consultó
directamente el registro real SYNTH_PASSES, sin modificar otros lenguajes.

Recuperación interfaz de función: case-7-fixed compiló y validó con pJASS,
confirmado en compiler-values/case-7-fixed.log. El siguiente bloque contrasta
flags debug/release, static if y existencia adelantada con entradas nuevas;
los rechazos se clasifican por el diagnóstico, sin contar fallos de Wine como
negativos del lenguaje. El prototipo y su esquema12 siguen aislados del activo.

## Defecto confirmado del producto: existencia adelantada

El CodeGraph instalado .3 extrae S.early en compiler-conditions/forward.j,
porque declaredExists recolecta incondicionales de todo el struct antes de
evaluar. JassHelper local, --nooptimize, no emite early; later está declarado
después de la condición. La variante module-forward tampoco emite early.
forward-exists-before.json conserva la reproducción de la variante instalada;
compiler-condition-results.json y salidas -release-compiled.j conservan el
contraste. Impacto: puede elegir una rama y enlazar declaraciones inexistentes
en ese punto, incluso con fuentes válidas. No se ha observado un fallo de mapa
por este caso. Estado: confirmado, corrección en copia aislada pendiente.

Las sondas de restricciones verificaron or rechazado en static if, DEBUG_MODE
release=false/debug=true, e inicializador boolean compuesto no recogido como
constante de static if por este compilador. Estos rechazos/resultados forman
parte del perfil; no se considerarán defectos de JassHelper.

La evaluación nueva por orden corrige el defecto de existencia adelantada en
la copia: conditions-verified.log, 70 tests/6 suites pasan. Se añade perfil
codegraph.json.jass y la huella de ese perfil fuerza reextracción; la prueba
de cambio sólo de release→debug pasa. Globales booleanos se procesan antes de
cuerpos; .exists sólo cuenta métodos previos, privados propios sí y stub no;
campos y métodos heredados no cuentan para exists en este binario. El control
inherited inicial usó una base extends array inválida; conservado como negativo
y repetido con base normal: compila, chosen ausente como predice el nuevo modelo.

Primer intento del bloque lifecycle no ejecutó tests por TS7022 al inferir
una variable de un bucle de herencia. Se anotó string|undefined explícitamente;
repetición en polymorphic-lifecycle-fixed.log. No contar el intento sin tests
como comprobación del comportamiento.

El contraste del bloque dispatch rechazó dos fixtures iniciales: hook Foo OnFoo
a una función ordinaria del mapa (Unable to find native: Foo), y la cadena
(index:leaves).tick() por perder el tipo utilizable para punto. Se preservan
case-10-invalid-hook-target.j y case-9-invalid-group.j. Se ajustan fixture y
modelo: hook sólo sobre declaraciones native o APIs declaradas en el perfil,
y una conversión Leaf(index:leaves) antes de tick. Se prueban aparte grupos de
cast/array/factory para determinar la regla del binario. Las pruebas originales
no se cuentan como conformance del lenguaje válido. Destructor Child: el JASS
generado registra condiciones Child y Base sobre el mismo trigger; confirma
los dos callbacks modelados, no sólo su presencia como definiciones.

### Preprocesador avanzado

`preprocessor-expanded.log`: pérdida de procedencia del textmacro al implementar un módulo generado. Corrección conserva toda la cadena de origen. Otros dos fallos del test: API de consulta inexistente (getNodeById en vez de getNode) y fixture combinado con macros DECL duplicados, que producían ambigüedad legítima. Pruebas corregidas sin eliminar el requisito. Cinco fixtures positivos compilados con JassHelper/pJASS, nested-macro rechazado explícitamente como negativo previsto (`compiler-preprocessor-results.json`). Se agrupan además lecturas fallidas por rutas relativas equivocadas; recuperadas usando rutas comprobadas, sin cambios en fuentes activas.

### Arrays y almacenamiento

`storage-expanded.log`: falta de arista para array.size corregida (guard de getter descartaba builtins). Fixture 2D de instancia inválido: JassHelper Unexpected [4]; corregido a miembro static según manual y compilado. getCallees deduplica destinos; test usa aristas por línea para dos sitios. `storage-expanded-fixed.log` y `storage-references-verified.log`: los helpers antiguos mezclaban references con calls; nuevo frontend añade referencias válidas a campos/parámetros/tipos. Se ajustan helpers para preservar la comprobación de llamadas y se añaden comprobaciones separadas de almacenamiento. Falta rerun del conjunto. La fuente activa no cambió.

### Corpus real y plantillas abiertas

La primera ejecución del corpus incluyó variantes y lenguajes adicionales: include no es un filtro exclusivo. Recuperación con snapshots limitados a fuentes JASS/vJASS, hashes/revisiones conservados en references.json y corpus-runs/*-manifest.json. Un arranque del harness usó recreate sin init; corregido detectando .codegraph/codegraph.db. La salida extensa inicial se mantiene en archivo y los resúmenes siguientes son compactos.

El corpus Nestharus expuso 13 falsos errores al analizar métodos abiertos y delegates en plantillas module como si fueran cuerpos completos. Corrección: definiciones de módulo opacas hasta implementación, condiciones no consumen sus cuerpos; enlaces explícitos de consumidores a plantillas module/textmacro. template-front-end.log y slk-integration-core.log:87 pruebas/4 suites pasan. Corpus acotado:255 archivos/70807 líneas; el recuento posterior de errores se verifica por separado.

Inyección: el fixture inicial declaró Ping fuera de una library; JassHelper ordenó Init antes de Ping, causando Undeclared function. Corregido colocando Ping antes de Init dentro de la library; oracle confirma compilación (compiler-control-inject-fixed.json). inject main sin dovjassinit es negativo previsto, rechazado por el compilador. injection-expanded-fixed.log:84 pruebas/5 suites pasan antes de los siguientes cambios.

### SLK: convergencia incremental

slk-build-inputs.log detectó una arista sintética main→datos ausente tras modificar sólo SLK, aunque reaparecía con reconstrucción. Causa: invalidación de consumidores por huella de perfil/datos no notificaba onFileChange antes de reemplazarlos y no marcaba synthesis_pending. Corrección notifica los consumidores JASS invalidados antes de reextracción. Rerun pendiente. El otro fallo fue del texto esperado del test de symlink: validatePathWithinRoot ya bloqueaba el enlace fuera de raíz antes del segundo control; no hubo lectura externa y dataTargets era vacío. Se acepta el diagnóstico real outside indexed root.

El fixture SLK con getFromKey, campo integer con Compute(), boolean y string con texto OtherCompute() pasó JassHelper+pJASS; salida confirma que sólo Compute() se ejecuta y OtherCompute() queda literal. compiler-slk-result.json y compiler-slk/compiled.j.

### Reparación de compilación del lexer

slk-build-inputs-fixed.log, frontend-current.log y slk-conditions-verified.log no ejecutaron pruebas: TS2448/TS2454 en jass-lexer.ts:40. Una sustitución al agrupar externalblock insertó la comprobación de cierre también dentro de la rama textmacro, antes de declarar sourceLines. Se elimina esa inserción accidental y se conserva el chequeo al final del lexer. No atribuir PASS al fix incremental/SLK hasta el rerun.

### Recuperación comprobada

frontend-recovery.log:102 casos/6 suites pasan; frontier-linebreaks se denomina realmente frontend-linebreaks.log y pasa103/6. Incluye el caso que fallaba de SLK incremental/fresh y symlink bloqueado. El error TS previo queda corregido; los tres logs de no tests no se cuentan. La revisión completa no está cerrada ni desplegada.

### Afinado de tipos y lifecycle

compiler-types y compiler-type-compatible-fixed.json acreditan: comparación a cero usa operador primitivo, comparación entre structs usa operator<; deallocate interno ejecuta onDestroy pero el acceso externo es privado; interfaces de función aceptan struct A/B por firma JASS convertida a integer, y rechazan unit/widget distintos; no admiten receptor struct encadenado tras evaluate. Fixture inicial usaba I en el parámetro del operador concreto, JassHelper exige S; corregido y compilado. Lectura fallida de ruta relativa impidió aplicar una corrección de deallocate y library_once; se recuperó aplicando rutas absolutas. frontend-once-types.log falló ambos casos, frontend-once-types-fixed.log pasa108/6 suites. type-conformance.log no ejecutó casos por narrowing TypeScript tras ampliar destroy a deallocate; corregido en type-conformance-fixed antes del arreglo funcional del dispatch.

Se separa nombre runtime de qualifiedName: funciones sin modificador dentro de library mantienen nombre global, como acredita Ping/Init en compiler-control/inject-fixed-compiled.j. Se añadió regresión de ExecuteFunc literal con nombres globales/public y rechazo de nombres private no construidos. Constructor private declarado no debe convertirse en builtin público ficticio. Rerun runtime-name-conformance en curso.

### Contexto de compilación parcial

optional-build-context-before.log ejecutó el caso y reprodujo una poda incorrecta: la presencia de una library/constante en otro archivo indexado se tomaba como presencia en la unidad de compilación actual. Se cambió a triestado por imports transitivos o completeInputs explícito; entradas opcionales ajenas conservan ambos caminos y se etiquetan potenciales. El rerun se comprueba en optional-build-context-after.log. También se evita convertir .exists de tipos de otro archivo en false sólo porque ese archivo no se recorrió todavía.

MCP corpus: primeros intentos del harness fallaron antes de conectar por require relativo y SDK MCP ausente. Se recuperó con cliente JSON-RPC stdio sin nuevas dependencias; corpus-mcp-raw.log/corpus-mcp-results.json acreditan9 consultas (3 por corpus), rutas de llamadas presentes y fuente devuelta. Watcher desactivado de forma intencional para esos probes; no acredita watcher. Requiere repetir con índice reconstruido y revisión final congelada.

### Receptores con tipos condicionales incompatibles

conditional-types-before.log reproduce dos aristas falsas a A.tick: campos alternativos A/B y factories con returns A/B bajo DEBUG_MODE desconocido. Se impide escoger un tipo arbitrario, conservando las llamadas candidatas a las factories. Con perfil debug explícito se comprueba que el receptor A vuelve a resolverse. Corrección en staging, pendiente de rerun final.

### Suite global y dependencia de empaquetado

full-regression.log: dos casos Windows archive de bundle-launcher.test.ts fallan con `zip: command not found` (exit127) en Linux. No modificar el test para ocultarlo; preparar zip aislado y repetir. Los mensajes EMFILE pertenecen a fault injection de watcher (comprobar resumen final), no se cuentan automáticamente como fallos. Pilot CLI A/B terminó OK; aviso de una skill ajena con products api inválido se retiene en stderr y no acredita defecto del frontend.

### Recuperación y preflight A/B

Zip preparado desde repositorio extra de CachyOS tras HTTP418 del primer mirror; instalado sólo en work/tooling. bundle-recovery.log pasa3/2skipped, incluidos los2 casos antes fallidos. Full original6074pass/36skip más recuperación cubre6076casos aprobados, no sumar duplicado del caso POSIX. Preflight A/B natural: el agente with no llamó MCP en el primer prompt (3 comandos); se conserva en agent-ab/preflight-unsteered. No atribuir reducción de lecturas ni conexión MCP a ese caso. Pilot explícito mcp-capability-pilot conecta, primero pasa argumento symbol inválido y recupera con query; se repite harness con enabled=true explícito. Sin claves nuevas ni cambios globales.

Recuperación de receptores condicionales confirmada: conditional-types-after.log106/4PASS y suite global sin regresión de esos casos. Corpus rebuilt conserva avisos explícitos; cero severity error. Piloto A/B confirmado como selección del agente, no fallo de conexión: protocolo funciona, se documenta variante con política común CodeGraph-first del proyecto. No llamarlo adopción automática.

### Judgment Day .4, primera pasada

Ambos jueces terminaron sobre review-r1, hash7993aadb…; snapshot verificado intacto antes de corregir. Hallazgos normalizados en judgment-r1-findings.json. B001: recursión exponencial de constantes y materialización sin límite, reproducida con guardia512lookups y cadena>64KiB. B002: endif runtime consume condición static en prepool, reproducido (No desaparece). A002: arrays no recuperan Target, A003: main no conecta constantes. B003: writers inject omitidos, confirmado usando arista calls/function-name-value. La primera aserción era insuficiente porque helper de tests también cuenta referencias .name.

A001 identifica falta real de filtro de lenguaje; el ejemplo TypeScript normal no reproduce porque kernel usa S::onDestroy, no S.onDestroy. Mantener esa distinción y no llamar al caso real demostrado. Se añade guardia y prueba de contrato con un contexto que sí suministra qualifiedName colisionante. Defensa del aislamiento, no afirmación de fallo observado en producción.

Corrección material única bajo objetivo autorizado: memo/depth/work y64KiBstringlimit; pila separa if normal/static; propietarios de assignments/calls incluyen inject; lecturas index recuperan posibles escritores; inicialización incluye constantes; callbacks lifecycle filtran lenguaje. jury-r1-before.log y jury-r1-reproduction.log conservan negativos. No desplegado; rerun y reevaluación de delta pendientes. A/B parcial de r1 se conserva separado e invalida como evidencia de versión final.

### Comprobaciones tras corrección de jurados

full-regression-r2.log:465suites PASS,6085tests PASS,36skipped. Build release-build-r2.log PASS. Ambos jueces reevaluaron seis IDs como verified y sin regresiones del delta, con límites estáticos y rectificación A001. Hashd3daa5f8…63archivos, integridad pendiente de verificación final.

compiler-jury-results.json: array-values, injected-values y nested-runtime-static (release/debug) compilan con JassHelper/pJASS. El caso constant-initializers con función custom Compute es inválido por orden JASS: globals se emiten antes de Compute, Undeclaredfunction (no contarlo como válido). Corrección del ejemplo usa native real StringLength; compiler-jury-constant-native-result.json confirma compilación. El test unitario de forma estructural no equivale a fixture compilable; la evidencia de lenguaje válido es el ejemplo nativo separado.

Control Express inicial falla la comparación por updatedAt distinto y propiedad semanticData:undefined nueva, no por diferencias de grafo. Canonicalización en JSON omite ausencias equivalentes y timestamps de extracción (no ubicaciones/firmas/aristas); comparación de148archivos1124nodos2240aristas resulta idéntica por diagnóstico. Se repite harness con raíces frescas control-runs-final y conserva control-modern.log original. No cambiar expectativas de resolución para ocultar una regresión.

Ajuste dentro de la misma ronda de corrección: reconocer namespace inject como owner inicialmente también trataba globals de library como locales. Test dedicado jury-r1-owner-before.log reproduce la pérdida de Demo.Target; owner ahora sólo funciones/métodos o injectionTarget. Suite global final lo incluye aprobado.

### Preparación de recarga MCP y escritorio

Hyprland actual rechaza dispatcher legacy focuswindow; recuperación con hl.dsp.focus documentado en referencia local. El primer control de cursor/clic sobre XWayland llegaba a la posición anterior; añadir movimiento relativo y0.25s antes del clic permitió verificar menú/capturas. wtype escribió12 en lugar deMCP en búsqueda de settings; Ctrl+A/type con ydotool recuperó texto correcto. No se cambió ninguna preferencia ni se guardó formulario MCP; capturas mcp-*.png documentan acceso al formulario actual. No confundir navegación con recarga ya realizada.

Lectura preparatoria de índices intentó tabla metadata inexistente; recuperación por inspección de schema y SELECT de project_metadata/schema_versions en modo read-only. Producción previa: schema11, runtime.3/extracción30,16/56/4archivos. No se migró ni editó ninguna base durante esa lectura.

### Conexión del chat tras instalación

Promoción:60archivos, backup production-backup-20261022-004742/ (fuentes/dist y SQLitebackup de3raíces). Build activo pasa. Índices schema12/extracción31/runtime.4, quick_check ok y estados complete;16/56/4archivos, fuentes sin cambios,0errores/201+329warnings JASS conocidos. Fresh MCP instalado responde.4 en3raíces;8checks watcher canarios pasan observando SQLite antes de consultas/sync. La conexión antigua de esta conversación devuelve Transportclosed tras SIGTERM planificado; el cliente no reconectó automáticamente. Recargar por UI MCP, después verificar consulta real de este chat; no confundir fresh-child con recuperación del cliente actual.

### Desenlace de la recarga y cierre

Alternar el interruptor MCP no recuperó el transporte existente. La acción
oficial de recarga desde la aplicación sí recreó el servidor y su conexión;
el observador registró un proceso nuevo posterior al build, identidad .4 e
índices completos e íntegros. La recarga interrumpió el turno anterior de forma
prevista. Tras el mensaje del usuario «Continua», este mismo chat ejecutó tres
consultas reales: RapidFire.RapidBolt, InventoryProbe y applyTheme. Las tres
respondieron con fuente y sin errores ni estados de vigencia pendientes.

Evidencia: app-reload-v4-verification.json y current-chat-v4-mcp-*.json en
work/codegraph-completo-vjass-20261021/. El fallo de transporte queda recuperado;
las consultas de servidores hijos anteriores se conservan como comprobaciones
separadas. No se requirió que el usuario reiniciara Codex desde el PC.

### Recuperación de edición documental al cerrar

El editor apply_patch rechazó reemplazar el informe de entrega mediante Delete
y Add del mismo destino dentro de una sola operación: «multiple operations
target». No aplicó esa operación ni afectó al código o a los índices. Se recuperó
escribiendo el contenido completo con pathlib; lectura posterior confirma el
informe guardado y los estados JSON coherentes. Incidencia documental cerrada.
