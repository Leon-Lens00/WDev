# Instrucciones del proyecto

<!-- CODEGRAPH_START -->
## CodeGraph

- Para comprender/localizar código, revisar dependencias o preparar cambios en
  las fuentes indexadas de este proyecto, consultar primero `codegraph_explore`.
  Pasar siempre `projectPath` según la tabla siguiente y nombres concretos de
  archivos/símbolos. Si la herramienta está diferida, cargarla por su nombre.
- Alternativa CLI: `/home/snz/.local/bin/codegraph explore "SIMBOLOS" --path RAIZ`.
  El código devuelto cuenta como leído; ampliar consultas o leer directamente
  sólo lo que no cubre el grafo o cuya vigencia no puede verificarse.
<!-- CODEGRAPH_END -->

### Rutas y alcance de los índices actuales

| Trabajo | `projectPath` absoluto |
|---|---|
| TerrainDev actual: Rapid Fire, movimiento y misiles | `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src` |
| Copia de InventorySys y sus dependencias congeladas | `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration` |
| Diseñador UI Studio: JavaScript ejecutado por la aplicación | `/home/snz/Documentos/WarDatsPy/ui-studio/dist` |

- Mantener separados el TerrainDev actual y la base `foundation-src` de la copia
  de inventario. Consultar el índice de la revisión que se va a cambiar.
- La primera consulta MCP con `projectPath` abre el índice, sincroniza los
  cambios pendientes y activa el watcher. Se comprobó la actualización
  automática al crear, modificar y eliminar archivos en las tres raíces.
  Se actualiza por cambios en disco, independientemente de qué agente los haga.
  El watcher se libera tras 10 minutos sin consultas, al desalojar el proyecto
  de la caché o al cerrar el servidor; la siguiente consulta lo reabre y pone
  al día. No es un servicio permanente fuera de una sesión MCP activa.
- Tras editar, comprobar los avisos de vigencia/cobertura de la respuesta.
  Si aparecen `DISABLED`, `RECOVERING`, archivos pendientes o una negativa por
  falta de vigencia, no asumir que el grafo está actualizado: esperar/reintentar
  o ejecutar `/home/snz/.local/bin/codegraph sync RAIZ` y comprobar el resultado.
  Leer directamente las fuentes afectadas cuando siga sin poder verificarse.
  En uso sólo por CLI, sincronizar tras cambios antes de reutilizar el índice.
- El soporte JASS/vJASS sigue siendo parcial. Proyecta macros con argumentos
  simples y módulos anidados dentro del alcance indexable; los imports enlazan
  sólo archivos ya indexables. Los miembros generados apuntan a la invocación
  real y conservan el origen en su docstring: el código mostrado es la fuente
  original, no el cuerpo expandido. Al cambiar/borrar una fuente JASS se
  reextraen también los consumidores JASS, aunque no cambien sus bytes.
- Resuelve algunos operadores de propiedad, receptores de retorno/arrays con
  tipo declarado, helpers execute/evaluate nombrados y ExecuteFunc literal.
  Sólo simplifica condiciones simples thistype.miembro.exists respaldadas por
  una declaración pública incondicional del mismo struct. El resto de static-if
  y debug, Zinc, hooks y dispatch arbitrario conservan límites. No implementa
  toda la semántica del compilador. Contrastar diagnósticos y casos no cubiertos
  con JassHelper/pJASS; ausencia de aristas no demuestra ausencia de consumidores.
- Los mapas, builds y evidencias históricas no forman parte de estos índices.
  "No tests found" en el grafo no demuestra que falten los ensayos del proyecto:
  consultar también planes, manifiestos e informes vigentes.
- No indexar carpetas ajenas al alcance autorizado ni sustituir compilación o
  pruebas en juego por una consulta al grafo. Registrar las consultas relevantes
  y sus límites al informar del cambio; no afirmar uso de CodeGraph sin ejecutarlo.
- Si una carpeta carece de `.codegraph/`, usar las herramientas habituales;
  indexarla requiere que esté dentro del alcance autorizado. No ejecutar
  `codegraph upgrade` sobre esta variante: reemplazaría nuestra adaptación
  JASS/vJASS por upstream. Para actualizarla, integrar y probar el parche.
- Revisión local vigente: `1.6.2+jass-vjass.3`, extracción 30. Los servidores MCP
  abiertos antes de la actualización deben recargarse; reconstruir la base no
  sustituye su código en memoria. Evidencia y límites del afinamiento en
  `docs/planes/codegraph-afinado-vjass.md` y
  `docs/planes/codegraph-ampliacion-vjass.md`.

## Evitar la complacencia (sycophancy)

- Trata las afirmaciones técnicas del usuario y las tuyas como hipótesis
  verificables. Distingue esas afirmaciones de sus objetivos y preferencias.
- Antes de aplicar cambios, identifica el entorno objetivo indicado para la
  tarea: proyecto, versión, motor, APIs y dependencias relevantes. Contrástalo
  con los archivos y herramientas disponibles; no extrapoles compatibilidad
  desde otro entorno. Reutiliza datos comprobados mientras sigan vigentes. Si
  hay una contradicción o falta un dato decisivo, resuélvelo mediante inspección
  o una pregunta concreta antes de ejecutar el cambio que dependa de ese dato.
- Revisa el impacto del cambio sobre el comportamiento existente, las interfaces
  y los componentes que lo usan. Para una habilidad de misil, por ejemplo,
  examina las relaciones pertinentes entre física, trayectoria, velocidad,
  colisiones, paso temporal, ciclo de vida y otras habilidades que compartan el
  sistema. Un cambio local puede afectar a consumidores de una biblioteca común.
  Antes de aplicarlo, comunica cualquier incompatibilidad o riesgo material
  detectado, con evidencia y una alternativa. Distingue un defecto demostrado
  de una sospecha; comprueba esta última antes de presentarla como cierta.
- Tras un cambio, ejecuta las verificaciones apropiadas para el comportamiento
  y los consumidores afectados. Si no puedes realizar una prueba necesaria,
  informa qué queda pendiente y qué conclusión no está demostrada. La revisión
  previa y estas instrucciones no sustituyen las pruebas.
- Antes de tomar una decisión que dependa de una premisa importante, compruébala
  con el código, las APIs del entorno, documentación primaria o una prueba
  reproducible. Busca también evidencia que pueda contradecirla. Ajusta la
  comprobación al impacto de la decisión; no conviertas cada edición en una
  auditoría completa.
- Si una premisa es incorrecta, señálalo claramente y con respeto, explica la
  evidencia y propone una alternativa que preserve el objetivo del usuario.
  No necesitas permiso para corregir una afirmación; continúa el trabajo ya
  autorizado cuando la corrección no requiera una decisión nueva del usuario.
- Si falta evidencia, declara la incertidumbre y qué falta comprobar. No
  presentes una suposición, una promesa del README o una respuesta anterior
  del agente como un hecho demostrado.
- No cambies una conclusión sólo porque el usuario insiste o parece preferir
  otra respuesta. Tampoco la mantengas por orgullo: rectifica cuando aparezcan
  pruebas contrarias. No discrepes por sistema ni confundas firmeza con exactitud.
- Describe únicamente las capacidades y resultados acreditados. En este entorno,
  instalación, conexión MCP, exploración léxica, resolución semántica,
  compilación y funcionamiento en Warcraft III 1.27b acreditan cosas distintas.
  Una referencia candidata no es una llamada resuelta; compilar no demuestra
  funcionamiento en juego ni ausencia de desincronización multijugador.
- Comprueba la cobertura antes de interpretar un resultado limpio: cero archivos
  analizados, casos omitidos o pruebas simuladas no validan el objetivo real.
  Informa qué se comprobó, el resultado y los límites materiales.
- Evita halagos y acuerdos automáticos. Prioriza la exactitud, la evidencia y
  el objetivo del usuario sobre confirmar lo que cualquiera de los dos espera.

## Notificación de errores

- Guardar el informe de cada fallo real o inesperado en
  `/home/snz/Documentos/ChatGPT/Proyect/informes/errores/` y enlazarlo al avisar
  en el chat. Usar `AAAA-MM-DD-HHMMSS-tema.md`, comprobar que no exista y añadir
  un sufijo si coincide con otro informe. Registrar fecha, proyecto/entorno y
  revisión, síntoma, reproducción o evidencia, impacto, causa confirmada o
  hipótesis, estado, acciones y verificaciones con sus resultados y límites.
  No guardar claves ni datos sensibles. Actualizar el mismo informe para
  repeticiones y recuperación; no sobrescribir informes de otros agentes.
- Consultar `informes/errores/README.md` para el formato. Un fallo al crear el
  informe también se comunica en el chat; no ocultar el error original ni
  detener el trabajo independiente por un problema de documentación.
- Informar al usuario en el chat cuando se detecte un fallo real o inesperado al
  explorar, modificar, compilar, indexar o probar el proyecto. Indicar qué falló,
  la evidencia relevante y su impacto. Si compromete una conclusión o bloquea
  un paso, avisar antes de continuar con el trabajo que dependa de él.
- Comunicar también su desenlace: corrección y comprobación de recuperación, o
  qué queda pendiente y qué no pudo validarse. Continuar el trabajo independiente
  ya autorizado; avisar de un error no exige pedir permiso para cada recuperación.
- En CodeGraph, incluir fallos de conexión MCP, extracción, índice o
  sincronización, y estados `DISABLED`/`RECOVERING` que persistan o impidan
  verificar la vigencia. Informar si fue necesario usar una alternativa de lectura.
- Agrupar repeticiones del mismo fallo y actualizar su estado. Distinguir errores
  confirmados de sospechas, controles negativos previstos y avisos conocidos de
  cobertura parcial; estos últimos requieren aviso cuando afecten a la tarea.

## Depuración y planificación

- Para investigar un fallo, regresión o resultado técnico inesperado, usar
  [systematic-debugging](/home/snz/.codex/skills/systematic-debugging/SKILL.md).
- Para un plan solicitado o un cambio técnico de varias fases con dependencias,
  usar [writing-plans](/home/snz/.codex/skills/writing-plans/SKILL.md). Conservar
  el plan y sus decisiones en el proyecto; los ajustes claros y pequeños no
  necesitan un documento de planificación.
