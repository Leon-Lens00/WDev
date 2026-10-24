# Análisis léxico de JASS/vJASS — prototipo local

Consulta fuentes de un proyecto sin convertirlas a Lua, compilar el mapa ni modificarlo.
Reutiliza `internal/forge/jass2lua.Tokenize`; no usa los preprocesadores de reescritura ni el emisor Lua.
Es una herramienta local de Forge, no una extensión instalada en CodeGraph ni un servidor MCP nuevo.

## Uso

Desde `wc3-forge`:

```sh
./scripts/jassgraph -root /home/snz/Documentos/WarDatsPy/struct-rebuild/MoveSys
./scripts/jassgraph -root /home/snz/Documentos/WarDatsPy/struct-rebuild/MoveSys -symbol IsLeapBuffActive
./scripts/jassgraph -root /home/snz/Documentos/WarDatsPy/struct-rebuild/MoveSys -format json
```

`-symbol` acepta un nombre simple o cualificado exacto. Devuelve las definiciones coincidentes,
las referencias entrantes candidatas y las llamadas salientes. Los nombres duplicados no se fusionan.
Las referencias a miembros pueden coincidir por texto; no constituyen una resolución de tipos.
Shell, Gentle AI y Codex pueden ejecutar este mismo comando mediante su herramienta de terminal.
No se ha cambiado su configuración global ni activado llamadas automáticas.

## Evidencia y límites

- Cada definición y referencia incluye archivo relativo, línea y columna (base 1, columnas del lexer en bytes).
- Cada fuente incluye SHA-256. El análisis se calcula en cada ejecución; no hay índice persistente que pueda quedar obsoleto.
- Reconoce declaraciones de funciones, natives, métodos con nombre, libraries, scopes, structs, modules e interfaces.
- Extrae llamadas textuales, callbacks `function Nombre`, inicializadores y dependencias `requires/needs/uses` en la línea de declaración.
- `lexical_candidate`: un único candidato por ámbito léxico; **no** es una confirmación del compilador.
- `ambiguous`: múltiples definiciones candidatas, conservadas con sus ubicaciones.
- `member_unresolved`: receptor de método sin inferencia de tipos; incluye `this`, `thistype`, accesos implícitos y dispatch `.execute/.evaluate`.
- `external_or_unresolved`: no encontrado en el ámbito analizado; puede ser un native o una librería fuera de la raíz. No significa que la función no exista.
- No expande textmacros, imports, implementaciones de módulos ni resuelve herencia/dispatch dinámico. Emite diagnósticos de cobertura para directivas y módulos/interfaces.
- No detecta todas las construcciones vJASS inválidas: es análisis léxico, no un parser completo ni un validador semántico.
- No analiza directamente `.w3x`, `.w3m`, `.wct` ni `.wtg`. Primero deben existir fuentes de texto extraídas por las herramientas del taller.
- No ejecuta `ExecuteFunc`, no interpreta strings como código ni demuestra ausencia de fugas o desincronizaciones.
- No ejecuta JassHelper/pJASS ni abre el juego. Cero diagnósticos no acredita compilación o funcionamiento.

## Alcance de archivos

Requiere `-root`: no escanea todo el taller por defecto. Resuelve la raíz explícita a su ruta real
y recorre únicamente `.j`, `.jass` y `.vjass` dentro de ella. Omite enlaces simbólicos internos,
`.git`, `.codegraph`, `.jassgraph`, `node_modules`, `.venv`, `build`, `dist` y `backups`.
Lista las exclusiones en `skipped`; si necesitas fuentes de una carpeta `build`, indícala directamente como raíz.
Límites: 2000 fuentes y 4 MiB por archivo. Un error de recorrido/lectura o límite devuelve salida no exitosa;
los diagnósticos léxicos se devuelven en el informe para que el consumidor vea la cobertura parcial.
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
