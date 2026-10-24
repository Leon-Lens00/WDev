# Operar el proyecto con Codex y Claude

Configuración completada el23/10/2026. Ambos clientes usan las mismas fuentes
activas de esta PC. Las copias WDev sirven para respaldo, no sustituyen en silencio
las fuentes que están usando los builders y el juego.

| Tarea | Carpeta de entrada |
|---|---|
| Proyecto/mapas/modelos | `/home/snz/Documentos/ChatGPT/Proyect/` |
| UI Studio | `/home/snz/Documentos/WarDatsPy/ui-studio/` |
| GitHub, respaldos y herramientas WDev | `/home/snz/Documentos/ChatGPT/WDev/` |

Iniciar Claude (`claude`) o Codex en la entrada correspondiente. Si un chat estaba
abierto antes de preparar el entorno, una sesión nueva garantiza cargar el contexto
verificado. No se interrumpieron ni reiniciaron las sesiones ajenas.

## Lo configurado

- `CLAUDE.md` importa `AGENTS.md` en Proyect/UI Studio y en los componentes con
  instrucciones propias: TerrainDev, diálogo y ModelEditor. WDev importa también
  su guía `docs/entorno-compartido.md`, aplicable a Codex/Claude.
- Claude encuentra las9adaptaciones desde `.claude/skills`; sus enlaces llevan a
  `WDev/skills/claude`. Codex mantiene sus skills activas. Las referencias a
  interfaces específicas se resuelven con la adaptación del cliente; la instalación
  de jurados no activa revisiones por sí sola.
- MCP codegraph configurado, aprobado y conectado en las3entradas. Sólo su
  herramienta `codegraph_explore` tiene permiso específico previo; el resto de
  permisos no se convierte en bypass. Las aprobaciones son locales y están
  excluidas de Git. Se conservaron las demás preferencias/servidores.
- La referencia JASS se actualizó a1.6.2+jass-vjass.5, extracción32/esquema12,
  tanto en Codex activo como en las copias Codex/Claude. No se cambió el backend.
- Se conservaron los8índices activos y su separación de variantes/componentes;
  consultas reales devolvieron fuentes/símbolos en todos. No se crearon índices
  duplicados para las copias de respaldo. La tabla de Proyect/AGENTS.md es la
  referencia de rutas y cobertura para consultas y nuevas raíces autorizadas.

## Comprobación realizada

Claude: sesiones interactivas propias en Proyect, UI Studio y WDev, comandos
locales `/context all` y panel `/mcp`, sin enviar una tarea a otro LLM. El contexto
mostró las9skills de proyecto y `mcp__codegraph__codegraph_explore` cargado; los
AGENTS/CLAUDE se mostraron como memoria. WDev mostró además su guía compartida.
Los tres `claude mcp get codegraph` devolvieron Connected después de completar la
confianza de las carpetas mediante el diálogo normal de Claude.

Codex: consultas MCP positivas en TerrainDev/src41símbolos, scripts13, SNES4,
inventario69, diálogo63, ModelEditor13, WaveSys1y UI Studio24. No hubo estados
DISABLED/RECOVERING ni consultas vacías en esta pasada. Los avisos conocidos de
cobertura estática se conservan; un resultado positivo no reemplaza compilación.

Validación de skills:19comprobaciones correctas (9Claude,9copiaCodex y la skill
Codex activa cuya referencia cambió). Enlaces/imports y las3copias del documento
de CodeGraph comprobados, con hashes idénticos. Toolchain: se reutiliza la
comprobación reciente y sin cambios de JassHelper/pJASS/APIs con4archivos y hashes
correctos; no se atribuye a ello una compilación nueva.

## Trabajo simultáneo y límites

Asignar archivos/componentes distintos a cada asistente y revisar cambios ajenos
antes de escribir. Mantener un escritor por mapa y preservar partidas/procesos
ajenos. CodeGraph se actualiza por archivos en disco, pero no coordina decisiones
ni evita sobrescrituras entre agentes. Respetar los avisos de vigencia y coverage.

No se ejecutaron jurados, juego, multijugador ni una tarea generativa en Claude
para esta preparación. La disponibilidad de skills/instrucciones no garantiza
que un modelo nunca se equivoque o complazca; las pruebas exigidas por cada cambio
siguen siendo necesarias. Otra PC necesita adaptar rutas/runtimes, confiar sus
entradas e inicializar índices propios. Los permisos locales no se publican como
aprobaciones de otras instalaciones.

Evidencia: `work/entorno-compartido-20261023/`: before.json, configured-paths.json,
codegraph-roots.json, claude-connections.json, skills-validation.json,
reference-hashes.json y salidas locales de `/context`. La auditoría anterior queda
como evidencia histórica del estado previo y enlaza el cierre de su incidencia.
