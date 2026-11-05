---
name: build-warcraft3-vjass-127b
description: "Crear, auditar, compilar y recuperar mapas W3X y código JASS/vJASS para Warcraft III Classic 1.27b. Incluye objetos, rawcodes, bibliotecas, inventarios, misiles y sincronización; usa el entorno local CachyOS/Wine cuando corresponda. Para ejecución visual, complementar con probar-warcraft3-classic-linux. No aplicar a Reforged/Lua salvo cambio explícito de objetivo."
---

# Warcraft III Classic 1.27b: JASS/vJASS

Usar Warcraft III 1.27b, el JassHelper instalado y las bibliotecas exactas del mapa como objetivo cerrado de compatibilidad. Comprobar las APIs; no completar huecos con funciones de parches modernos.

## Entorno y herramientas

En esta PC, leer [references/entorno-local.md](references/entorno-local.md) antes de compilar, empaquetar o elegir Forge/wc3ctl. Contiene las rutas Linux comprobadas y las diferencias entre el entorno activo y las copias experimentales. Verificar su existencia; si el usuario aporta otro proyecto o toolchain, respetarlos y adaptar la ejecución.

- JassHelper es un `.exe` de Windows que aquí se ejecuta con el lanzador Wine existente; pJASS es nativo Linux. Las extensiones `.exe`, las rutas dentro de Wine y los nombres MPQ con barras inversas siguen siendo válidos en ese contexto.
- Para compilar una fuente: usar `scripts/wc3.py vjass FUENTE.j SALIDA-NUEVA.j` del entorno local. Compila y valida, pero no inyecta ni publica un mapa.
- Para el proyecto modular de esta skill: configurar `local_launcher` en `wc3project.json` y ejecutar `scripts/build_w3x_project.py MANIFEST`. Usa el lanzador de JassHelper y wc3ctl nativo para los MPQ. El modo `mpqeditor` directo sigue disponible para entornos donde esos ejecutables puedan ejecutarse directamente.
- No imponer este proyecto modular a un mapa con su propio proceso de construcción: usar su entrada y manifiesto existentes, conservando los controles de compatibilidad y verificación.

## Orden de evidencia

Resolver discrepancias con instrucciones vigentes del usuario/proyecto y evidencia local: fuente del mapa; `common.j`/`Blizzard.j` exactos; compilador instalado; fuente de cada biblioteca; pJASS; prueba de una copia en 1.27b; ensayo de clientes para afirmaciones de sincronización; documentación reproducible de la misma versión.

No afirmar que existe una función, miembro, callback, rawcode o dependencia sin evidencia de la capa correspondiente. Los perfiles `library-*.md` describen versiones y ensayos concretos: no certifican la revisión local actual ni obligan a sustituirla por una variante histórica.

## Flujo de trabajo

1. Resolver y validar `wc3toolchain.json` con `scripts/check_toolchain.py`; registrar hashes de compilador, pJASS y APIs.
2. Conservar el original `.w3x`/`.w3m`. Trabajar con copias y un solo escritor por mapa; separar fuentes editables y artefactos generados.
3. Leer sólo las referencias pertinentes. Distinguir errores funcionales, sincronización, recursos, rendimiento y estilo.
4. Compilar vJASS antes de pJASS. Conservar comandos, salida, códigos de retorno y la causa inicial de los errores.
5. Empaquetar en una salida nueva con el proceso del proyecto. Reextraer y comparar por hash el JASS, WCT e imports modificados; conservar cabecera HM3W y miembros ajenos. Una validación sin hallazgos no cubre comprobaciones omitidas.
6. Si se requieren objetos/GUI, guardar y reabrir una copia con el editor correspondiente. Para probar en el juego o manejar editores, seguir [probar-warcraft3-classic-linux](../probar-warcraft3-classic-linux/SKILL.md).
7. Informar el estado más fuerte realmente alcanzado y las pruebas pendientes.

## Referencias por tarea

- Entorno CachyOS, Wine, Forge, wc3ctl y comandos: [entorno-local.md](references/entorno-local.md).
- Buscar símbolos y explorar referencias JASS/vJASS desde Claude Code (MCP `codegraph`, ver `.mcp.json` en la raíz): [jass-explore.md](references/jass-explore.md); CodeGraph original con extractor local y cobertura estática parcial.
- APIs, parche y rawcodes: [compatibility-127b.md](references/compatibility-127b.md).
- Datos de objeto (w3u…): tipo de campo según metadata (`usca`/`ussc` real), radio del círculo de selección 36 × `ussc`, altura de unidades inmóviles: [object-data-127b.md](references/object-data-127b.md). Leer antes de escribir objetos desde un builder.
- Multijugador, handles, grupos y waits: [multiplayer-and-handles.md](references/multiplayer-and-handles.md).
- vJASS avanzado: [vjass-advanced.md](references/vjass-advanced.md).
- Bibliotecas e inicialización: [libraries-and-initialization.md](references/libraries-and-initialization.md).
- Fallos frecuentes: [ai-failure-patterns.md](references/ai-failure-patterns.md).
- Misiles: [missile-systems.md](references/missile-systems.md) y el perfil `library-*.md` de la versión exacta. Para diseñar habilidades con los ejemplos descargados de BPower, usar [crear-misiles-warcraft3-127b](../crear-misiles-warcraft3-127b/SKILL.md).
- Recuperación WTG/WCT/JASS y empaquetado: [map-analysis-toolchain.md](references/map-analysis-toolchain.md).
- Interfaces clásicas de cámara, dummies e inventario: [library-inventorysys-141.md](references/library-inventorysys-141.md); técnicas observadas, no certificación multijugador. Incluye por qué una pieza de imagen con billboard desaparece lejos de X 0 y el cuadro plano que lo resuelve.
- Texto flotante, párrafos y conversaciones: [texttags-dialogos-127b.md](references/texttags-dialogos-127b.md); límites observados en 29 casos de Classic 1.27b, diferencia entre tamaño GUI/nativo, ajuste de renglones y composición reutilizable. Consultar al diseñar o depurar diálogos con texttags.
- Matrices de validación: [testing-matrices.md](references/testing-matrices.md).
- Procedencia y fuentes: [sources.md](references/sources.md).

## Restricciones de compatibilidad

- Rechazar `Blz*`, `FourCC`, Frame API, APIs de 24 jugadores y extensiones de parches/plataformas para vanilla 1.27b, salvo disponibilidad probada en el objetivo o cambio explícito del usuario.
- El script del mapa es JASS. Lua de configuración de NewGen/YDWE o de herramientas externas no convierte el mapa en un objetivo Lua ni está prohibido por esta restricción.
- Usar rawcodes como `'hfoo'` y comprobar cada objeto; no inventar IDs.
- En `GetLocalPlayer`, demostrar que todas las escrituras y sus efectos posteriores son exclusivamente visuales. No asignar/destruir handles de juego, alterar estado sincronizado o consumir RNG sincronizado sólo en un cliente.
- Mantener un propietario autorizado de `SetUnitUserData` al usar UnitIndexer.
- Registrar versión, procedencia, dependencias, ciclo de vida y compilador de cada biblioteca. No mezclar forks ni trasladar PASS entre versiones.
- Preservar el comportamiento público al auditar código heredado. Separar las correcciones demostradas de cambios experimentales.

## Resultado y herramientas auxiliares

Clasificar hallazgos como `ERROR`, `WARNING`, `PERF` o `STYLE`. Informar un único estado más fuerte: **Designed**, **Scanned**, **Compiled**, **Validated**, **Tested in map** o **Tested in multiplayer**. Un ensayo con fallos sigue teniendo fallos; no equivale a aprobación del producto.

- `scripts/check_toolchain.py CONFIG [--json]`: objetivo, archivos, superficie clásica y SHA-256.
- `scripts/wc3lint.py PATH [--json]`: revisión estática conservadora de `.j/.jass/.vjass`; distingue código de literales y comentarios. Una raíz sin fuentes o una entrada ilegible devuelve error. Los avisos de recursos/sincronización requieren revisión; no sustituye compilador ni motor.
- `scripts/compile_vjass.py --jasshelper EXE --pjass BIN --common FILE --blizzard FILE --input FILE --output NUEVO [--local-launcher /ruta/scripts/wc3.py] [--dry-run] [--log FILE]`: compilación y pJASS. En modo directo admite `--debug` y `--no-optimize`; el lanzador local no expone esos parámetros.
- `scripts/build_w3x_project.py MANIFEST`: construcción modular con backend local wc3ctl o MPQEditor directo, WCT opcional y reextracción por hash. Requiere salida y compilado nuevos.
- `scripts/map_inventory.py EXTRACTED_DIR`: inventario y recuperación de WCT sin modificar el mapa.
- `assets/project-template/`: ejemplo local; revisar rutas, mapa base y política de WCT antes de usarlo.
