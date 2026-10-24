# CodeGraph original con soporte local JASS/vJASS

Instalación activa de esta PC: `/home/snz/Documentos/MCP W3/codegraph-vjass`,
basada en upstream1.6.2, commit `6560052a6f856855d3f71eee838fd66ccfa4285d`.
Identidad MCP/daemon vigente: **1.6.2+jass-vjass.5**, extracción **32**, esquema **12**.
`codegraph --version` conserva la versión base1.6.2; no usarla para distinguir el
parche local. Fuente de capacidades/límites: [JASS-VJASS.md](</home/snz/Documentos/MCP W3/codegraph-vjass/JASS-VJASS.md>).
No es una versión oficial upstream ni un compilador JASS.

## Clientes, fuentes y raíces

Servidor MCP `codegraph`, herramienta `codegraph_explore`. Codex lo registra en
`/home/snz/.codex/config.toml`; Claude en `.mcp.json` de la entrada del proyecto.
Claude necesita la aprobación local del servidor; tener el archivo no acredita
conexión. Comprobar `claude mcp get codegraph` y una consulta positiva de la sesión.
Los clientes abiertos antes de actualizar el backend deben recargarse: reconstruir
el índice no reemplaza su código en memoria.

Para este proyecto compartido, las fuentes activas siguen en Proyect y UI Studio.
La tabla completa/autorización de raíces está en
`/home/snz/Documentos/ChatGPT/Proyect/AGENTS.md`; UI tiene su guía específica.
WDev conserva snapshots: no consultar un índice original como si acreditara otra
copia. Si el usuario elige desarrollar una copia, delimitarla e indexarla con sus
propios perfiles. No inicializar todo WDev, Proyect, el home ni carpetas ajenas.

Para código ya indexado, consultar primero nombres concretos con `projectPath`
explícito del componente. La fuente devuelta cuenta como leída; ampliar sólo lo
no cubierto o no vigente. Las raíces no tienen aristas entre sí por estar en un
mismo proyecto: consultar cada dependencia en su índice propietario.

```bash
/home/snz/.local/bin/codegraph explore 'Nombre NombreRelacionado' --path /raiz/fuentes
/home/snz/.local/bin/codegraph sync /raiz/fuentes
```

Crear índices sólo en el alcance autorizado, reutilizando cobertura existente.
Una raíz nueva mínima necesita configuración y fuentes reales antes de ejecutar
`codegraph init /raiz/fuentes --yes`; consultar después archivos/símbolos reales.
No crear un índice por cada modo o archivo. El grafo no extrae por sí solo W3X/WCT.

## Perfil de compilación y cobertura

La integración participa en el pipeline original: workers, SQLite/FTS, resolución,
recorrido, impacto, CLI, MCP y watcher. Los otros lenguajes conservan sus rutas
originales. No depende de un segundo servicio JASS ni ejecuta herramientas externas
al indexar. La compilación/prueba autorizada se realiza por separado.

Reconoce scopes, tipos, bibliotecas/structs/interfaces/módulos, funciones/natives,
visibilidad, herencia/delegates, this/thistype y receptores/retornos declarados.
Incluye operadores/expresiones y cadenas tipadas, arrays, macros y módulos
acotados (incluidos módulos generados), selección static-if/debug compatible con
el perfil declarado, posibles valores de funciones, hooks, lifecycle e inicialización.
Los cuerpos generados conservan origen/invocación; lo mostrado es fuente original,
no un cuerpo expandido editable. Hay límites de trabajo, profundidad y tamaño.

`jass.mode` distingue conservative (predeterminado), release y debug; elegir según
el builder real, nunca por conveniencia. `completeInputs` sólo puede ser true si
la raíz representa la unidad completa de compilación. APIs Classic declaradas en
`jass.apiFiles` deben estar indexadas dentro de la raíz y tener procedencia/hash;
no importarlas otra vez al mapa si el compilador ya las recibe. Los datos SLK
requieren `jass.dataFiles` explícito y respetan raíz/exclusiones. Ver un archivo o
library opcional no prueba por sí solo que esté incluido en ese build.

Los imports sólo enlazan entradas indexadas. Zinc/C/cJASS, herramientas externas,
entradas generadas no indexadas, strings calculados y aliasing/dispatch no
acreditado son fronteras explícitas. Sin información decisiva se conservan
candidatos/desconocidos; no se elige un destino por semejanza. Una arista candidata
no demuestra ejecución y una arista ausente no demuestra ausencia de consumidores.

## Vigencia, errores y mantenimiento

La primera consulta MCP abre/sincroniza la raíz y activa el watcher. Cambios en
disco de cualquier agente se detectan mientras siga abierto; el proyecto puede
liberarse tras10min sin consultas o al cerrar/desalojar el servidor. La siguiente
consulta reabre y pone al día. No es vigilancia permanente fuera de la sesión.
En uso sólo CLI, sincronizar después de editar antes de reutilizar el grafo.

Cambiar una fuente JASS, su perfil o datos declarados invalida también consumidores
JASS sin cambios de bytes. Respetar avisos DISABLED/RECOVERING y archivos pendientes;
reintentar/sync y usar lectura directa si la vigencia no puede comprobarse. Informar
los fallos conforme al AGENTS.md del proyecto. Cero fuentes o cero coincidencias
no acreditan cobertura positiva; usar símbolos reales y contrastar los límites.

No ejecutar `codegraph upgrade`: sustituiría la adaptación por upstream. Integrar
actualizaciones conservando el parche y sus comprobaciones. JassHelper/pJASS con
las APIs del mapa validan compilación/compatibilidad Classic1.27b; consultas, tests
del extractor, pruebas en juego y multijugador acreditan cosas diferentes.
La instalación/consulta no certifica ahorro de tokens, FPS ni decisiones del agente.

El launcher `/home/snz/.local/bin/codegraph` usa el runtime Node aislado en
`/home/snz/.local/share/codegraph-vjass/runtime`, sin cambiar el Node del sistema.
Telemetría y actualización automática están desactivadas en ese launcher.
La alternativa CLI jassgraph conserva su cobertura léxica; no mezclar sus candidatos
con relaciones resueltas de CodeGraph sin mantener la procedencia.
