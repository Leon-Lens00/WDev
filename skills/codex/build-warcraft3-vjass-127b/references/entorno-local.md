# Entorno local de Warcraft III Classic

Rutas comprobadas el 20-10-2026 en CachyOS x86_64/Hyprland. Son referencias de esta PC: verificar los destinos y el proyecto elegido antes de usarlas; no migrar ni reconfigurar instalaciones automáticamente.

## Fuentes de configuración

- Entorno del juego y compilación: `/home/snz/Documentos/ChatGPT/FrozenThone`.
- Leer allí `AGENTS.md`, `docs/herramientas-wc3.txt`, `wc3-environment.json` y `wc3toolchain.json` según la operación.
- Entrada directa estable: `/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py`.
- Taller: `/home/snz/Documentos/WarDatsPy/Taller-WC3/wc3`, enlace a `scripts/wc3-taller.py` del entorno.
- Forge encontrado actualmente: `/home/snz/Documentos/MCP W3/wc3-forge`.

**Desajuste observado:** `wc3-environment.json`, algunas guías y el enlace de Forge del Taller aún apuntan a `/home/snz/Documentos/WarDatsPy/wc3-forge`, ruta que ya no existe. `wc3 verificar` falla por esos destinos, mientras los destinos de compilación, juego, NewGen y YDWE existen. Evaluar cada fallo: esto no demuestra que `vjass` o `play` estén rotos. Comprobar y resolver Forge por separado antes de usar `forge`, `mcp`, `probe` o scripts que dependan de su fuente/GUI. No cambiar configuración ajena como efecto de leer esta skill.

## Toolchain y comandos locales

El `wc3toolchain.json` del entorno apunta a:

| Componente | Ruta relativa al entorno |
|---|---|
| JassHelper Windows | `editors/newgen/jasshelper/standart/clijasshelper.exe` |
| pJASS Linux | `tools/wc3-addons/wc3_agent_tools/pjass/pjass` |
| API Classic | `tools/wc3-addons/classic-assets/Scripts/common.j` |
| Biblioteca BJ | `tools/wc3-addons/classic-assets/Scripts/Blizzard.j` |
| Juego fuente | `games/WarcraftIII-1.27b` |

```bash
python3 /home/snz/.codex/skills/build-warcraft3-vjass-127b/scripts/check_toolchain.py /home/snz/Documentos/ChatGPT/FrozenThone/wc3toolchain.json --json
python3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py vjass /ruta/FUENTE.j /ruta/SALIDA-NUEVA.j
python3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py pjass /ruta/JASS-COMPILADO.j
python3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py wc3ctl info /ruta/COPIA.w3x --json
```

El lanzador `vjass` prepara una copia de JassHelper con sus DLL y configuración, usa `editores.environment('newgen')` y el runtime que ese módulo seleccione, traduce rutas a `Z:\...`, conserva logs y termina validando con pJASS nativo. No ejecutar el PE como un binario Linux ni copiarlo aislado sin sus dependencias. El Wine antiguo puede servir para compilación sin acreditar calidad gráfica; no confundirlo con el perfil moderno de pruebas.

El comando no acepta salida existente. Los imports deben resolver a archivos reales; usar UTF-8 sin BOM para nuevas fuentes. En `build_w3x_project.py`, `local_launcher` debe señalar a este `scripts/wc3.py`, no al enlace `wc3` del Taller: se verifica su configuración contra los cuatro archivos de la toolchain. El builder traduce el import absoluto a Wine; los nombres de miembros MPQ siguen usando `\` independientemente del sistema anfitrión.

## Empaquetado y fuente editable

La plantilla local configura `local_launcher` y no necesita MPQEditor.exe. wc3ctl extrae bytes, guarda cada sustitución en un archivo temporal distinto y repaca al guardar. El builder reextrae JASS, WCT e imports y compara SHA-256; conserva el prefijo HM3W. Para una versión entregable, comprobar también miembros ajenos con el diff de archivos y después guardar/reabrir o jugar según el alcance solicitado.

`sync_wct` sólo se activa si existe una WCT versión 1 compatible y se quiere conservar la importación externa. El bloque WCT no incorpora por sí solo todos los archivos `src/`: entregarlos y mantener la ruta relativa a la copia del mapa. Si el proyecto tiene otro formato de triggers o sólo debe entregar JASS compilado, seguir su construcción o desactivar explícitamente `sync_wct`; no inventar ni convertir WTG/WCT para forzar el ejemplo.

En otro entorno puede usarse `mpqeditor` sin `local_launcher`, conservando los parámetros existentes. Ese modo lanza MPQEditor/JassHelper directamente: requiere Windows o un wrapper ejecutable revisado que traduzca sus rutas y configure Wine. Un nombre `.exe` no basta para ejecutarlo en Linux.

## Versiones de wc3ctl y Forge

- El lanzador del entorno sigue usando `tools/wc3-addons/wc3ctl-classic-bin/wc3ctl.dll`: adaptación local **0.3.0** con lector MPQ Classic. Revisar diagnósticos y comprobaciones omitidas.
- La descarga **0.4.10** está en `/home/snz/Documentos/MCP W3/wc3-forge/wc3ctl`. Su viabilidad Linux/MPQ se verificó con un prototipo aislado; no reemplazó la instalación activa. Evidencia: `verificacion-adaptacion-20261020/RESULTADO.txt` dentro de esa copia.
- El comando `new` de 0.4.10 genera W3I versión 28 incluso con objetivo 1.27b; no usar esa salida como base Classic sin conversión verificada. Para 1.27b, comprobar W3I <=25, terreno <=11, objetos Classic, JASS y assets compatibles. Un análisis de identificadores no valida todos los formatos.
- Forge tiene modificaciones locales Classic. Abrir copias: su Save As puede guardar primero el archivo abierto. El auxiliar Linux/MCP y la ventana GUI son sesiones diferentes; seleccionar explícitamente la sesión y conservar un único escritor por archivo. No acreditar su visor como réplica exacta del juego.

## Auxiliares locales para leer y revisar código

`wc3lint.py` pertenece a esta skill; es un script local con reglas heurísticas, sin autor o repositorio externo documentado. Acepta `.j`, `.jass` y `.vjass` (también mayúsculas), máscaras de strings/rawcodes y comentarios `//`/`/* */`, UTF-8 con o sin BOM y CRLF. No convierte otras codificaciones. Un literal/comentario sin cerrar devuelve `LEX-INCOMPLETE`; una entrada sin fuentes o ilegible termina con código 2. Código 1 significa hallazgos ERROR; 0 sólo ausencia de ERROR en las reglas ejecutadas. `wc3lint: ignore REGLA -- motivo` sólo tiene efecto dentro de un comentario `//` real en esa línea. No expande macros/imports ni realiza análisis completo de tipos, alias o flujo entre funciones.

`jassgraph` es una extensión local de Forge que reutiliza su lexer, sin ejecutar la conversión a Lua. Para explorar llamadas y callbacks, usar una raíz acotada:

```bash
"/home/snz/Documentos/MCP W3/wc3-forge/scripts/jassgraph" -root /ruta/fuentes -symbol Nombre -format json
```

El JSON indica `coverage=lexical_only` o `partial`; ninguna significa validación del compilador. `-strict` conserva el informe y devuelve código 1 si la cobertura es parcial. Una raíz sin fuentes devuelve error. Las consultas incluyen callbacks cualificados y accesos `this.metodo`/`.metodo`; `query_match=textual_member` puede incluir receptores de otros tipos con el mismo nombre de método. No usar esas coincidencias para renombrar automáticamente. La implementación, pruebas y límites están en `docs/jassgraph.md` de Forge. Los ensayos de afinamiento del 20-10-2026 están en `/home/snz/Documentos/ChatGPT/Proyect/work/afinamiento-wc3-20261020/`.

Integración activa de exploración en Codex: servidor MCP `codegraph`, basado en el original v1.6.2 con extractor/resolvedor JASS/vJASS local, SQLite, exploración y sincronización incremental. Fuente en `/home/snz/Documentos/MCP W3/codegraph-vjass`; lanzador `/home/snz/.local/bin/codegraph`. El puente anterior `wc3-jass-explore` está desactivado; jassgraph sigue disponible por CLI. Consultar [jass-explore.md](jass-explore.md) para comandos, cobertura parcial y mantenimiento de la variante.

## Ejecución y bibliotecas

Seguir `/home/snz/.codex/skills/probar-warcraft3-classic-linux/SKILL.md` para `play`, editores, capturas, resultados y cierre. El perfil gráfico de `play` es NewGen moderno (GE-Proton/DXVK/RenderEdge); YDWE conserva su perfil propio. No cambiar perfiles por una receta histórica de compilación.

Los perfiles de bibliotecas de esta skill son evidencia por versión/hash. Para código local actual, consultar fuentes y contratos del proyecto, no adoptar automáticamente `030-Missiles.j`, una RC antigua, el candidato Two ni una biblioteca sólo porque tenga un PASS histórico. Los ensayos locales RC8/candidato y las limitaciones están en las guías del proyecto; no promover una revisión ni iniciar LAN aplazado como consecuencia de actualizar herramientas.
