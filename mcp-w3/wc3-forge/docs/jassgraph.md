# Análisis léxico de JASS/vJASS — prototipo local

Consulta fuentes de un proyecto sin convertirlas a Lua, compilar el mapa ni modificarlo.
Reutiliza `internal/forge/jass2lua.Tokenize`; no usa los preprocesadores de reescritura ni el emisor Lua.
Es una herramienta local de Forge, no una extensión instalada en CodeGraph. El adaptador
MCP local `wc3-jass-explore` de Codex reutiliza este comando sin cambiar su analizador;
actualmente está desactivado en favor del CodeGraph original adaptado.

## Uso

Desde `wc3-forge`:

```sh
./scripts/jassgraph -root /home/snz/Documentos/WarDatsPy/struct-rebuild/MoveSys
./scripts/jassgraph -root /home/snz/Documentos/WarDatsPy/struct-rebuild/MoveSys -symbol IsLeapBuffActive
./scripts/jassgraph -root /home/snz/Documentos/WarDatsPy/struct-rebuild/MoveSys -format json
./scripts/jassgraph -root /ruta/fuentes -format json -strict
```

`-symbol` acepta un nombre simple o cualificado exacto. Devuelve las definiciones coincidentes,
las referencias entrantes candidatas y las llamadas salientes. Los nombres duplicados no se fusionan.
Las referencias a miembros pueden coincidir por texto; no constituyen una resolución de tipos.
Una consulta por método incluye también `this.metodo`, `thistype.metodo`, `.metodo`
y otros receptores con el mismo nombre final. `query_match=textual_member` señala esa
coincidencia amplia: puede pertenecer a otro tipo. Los valores `outgoing`,
`lexical_candidate` y `textual` explican las otras razones de inclusión. Este campo
no cambia la resolución original de la referencia ni autoriza un renombrado automático.
Shell, Gentle AI y Codex pueden ejecutar este mismo comando mediante su herramienta de terminal.
El comando sigue siendo independiente. En esta PC el adaptador de lectura
`wc3-jass-explore` permanece instalado pero desactivado en `~/.codex/config.toml`.
La integración activa es `codegraph`, desde `/home/snz/Documentos/MCP W3/codegraph-vjass`:
usa su propio extractor JASS/vJASS y el índice original de CodeGraph, no este comando.
Consultar `/home/snz/.codex/skills/build-warcraft3-vjass-127b/references/jass-explore.md`.

## Evidencia y límites

- Cada definición y referencia incluye archivo relativo, línea y columna (base 1, columnas del lexer en bytes).
- Cada fuente incluye SHA-256. El análisis se calcula en cada ejecución; no hay índice persistente que pueda quedar obsoleto.
- Reconoce declaraciones de funciones, natives, métodos con nombre, libraries, scopes, structs, modules e interfaces.
- Extrae llamadas textuales, callbacks `function Nombre` y `function Tipo.metodo`, inicializadores y dependencias `requires/needs/uses` en la línea de declaración.
- `lexical_candidate`: un único candidato por ámbito léxico; **no** es una confirmación del compilador.
- `ambiguous`: múltiples definiciones candidatas, conservadas con sus ubicaciones.
- `member_unresolved`: receptor de método sin inferencia de tipos; incluye `this`, `thistype`, accesos implícitos y dispatch `.execute/.evaluate`.
- `external_or_unresolved`: no encontrado en el ámbito analizado; puede ser un native o una librería fuera de la raíz. No significa que la función no exista.
- No expande textmacros, imports, implementaciones de módulos ni resuelve herencia/dispatch dinámico. Emite diagnósticos de cobertura para directivas y módulos/interfaces.
- No detecta todas las construcciones vJASS inválidas: es análisis léxico, no un parser completo ni un validador semántico.
- No analiza directamente `.w3x`, `.w3m`, `.wct` ni `.wtg`. Primero deben existir fuentes de texto extraídas por las herramientas del taller.
- No ejecuta `ExecuteFunc`, no interpreta strings como código ni demuestra ausencia de fugas o desincronizaciones.
- No ejecuta JassHelper/pJASS ni abre el juego. Cero diagnósticos no acredita compilación o funcionamiento.
- `coverage=lexical_only` significa que no hubo incidencias de cobertura conocidas; `partial` señala diagnósticos. No equivale a cobertura completa del lenguaje. UTF-8 inválido omite el análisis del archivo y produce un diagnóstico; UTF-8 con BOM conserva coordenadas en bytes y hashes originales.
- No indexa variables ni sus tipos. Las llamadas en inicializadores globales y las referencias dinámicas en strings no forman parte del grafo de llamadas.

## Alcance de archivos

Requiere `-root`: no escanea todo el taller por defecto. Resuelve la raíz explícita a su ruta real
y recorre únicamente `.j`, `.jass` y `.vjass` dentro de ella. Omite enlaces simbólicos internos,
`.git`, `.codegraph`, `.jassgraph`, `node_modules`, `.venv`, `build`, `dist` y `backups`.
Lista las exclusiones en `skipped`; si necesitas fuentes de una carpeta `build`, indícala directamente como raíz.
Límites: 2000 fuentes y 4 MiB por archivo. Un error de recorrido/lectura o límite devuelve salida no exitosa;
Una raíz sin fuentes devuelve error. Los diagnósticos léxicos se devuelven en el informe
para que el consumidor vea la cobertura parcial. Por defecto el informe parcial mantiene
salida exitosa; `-strict` emite ese mismo informe y devuelve 1 cuando hay diagnósticos.
Los argumentos inválidos devuelven 2. Tampoco en modo estricto se ejecuta un compilador.
El comando no escribe dentro de la raíz analizada. Las redirecciones de salida las decide quien lo invoca.

## Construcción y comprobación

Requiere Go compatible con `go.mod`:

```sh
go test ./internal/jassgraph ./cmd/jassgraph
go vet ./internal/jassgraph ./cmd/jassgraph
go build -o .tools/jassgraph/wc3-jassgraph ./cmd/jassgraph
```

En esta PC se preparó Go 1.26.10 aislado en
`/home/snz/.local/share/wc3-jassgraph-build/go/bin/go`, con su caché en el mismo directorio padre.
No se modificó el Go ni el PATH global. El ejecutable local queda en `.tools/jassgraph/`, excluido por Git.

Prueba observada en `struct-rebuild/MoveSys`: 2 fuentes, 47 definiciones, 226 referencias y 6 dependencias.
De las referencias, 30 tienen un candidato léxico, 63 son miembros sin resolver y 133 son externas/no resueltas.
La búsqueda de `IsLeapBuffActive` encontró sus siete sitios de llamada, contrastados con el texto original.
Estos resultados describen las fuentes leídas, no certifican el mapa.

Afinamiento del 20-10-2026: se conservaron las 47 definiciones, las 226 referencias y
los hashes de ambos archivos. La consulta de `MovementSystem.MovementData.destroy`
pasó de 3 a 9 referencias al incluir receptores implícitos como candidatos textuales.
Esto amplía la búsqueda, no acredita seis llamadas resueltas adicionales.

El código de `internal/jassgraph` y `cmd/jassgraph` es una extensión local, con pruebas
en ambos paquetes; no debe atribuirse al proyecto upstream como funcionalidad publicada.
