# Entorno Claude frente al entorno activo ·23/10/2026

> Estado histórico anterior a la corrección. Tras la autorización posterior del
> usuario, se completó y comprobó el entorno: ver
> [configuración compartida](entorno-compartido-codex-claude.md). Los resultados
> siguientes conservan lo observado durante la auditoría inicial.

Resultado: **preparación parcial; todavía no equivalente al flujo activo Codex**.
Se auditó WDev como entrada reciente de Claude y se contrastó con Proyect/UI
Studio originales. No se cambiaron configuraciones, aprobaciones ni fuentes.

| Área | Resultado observado |
|---|---|
| Claude Code |2.1.310 nativo; doctor no encontró fallos de instalación |
| Autenticación |Sesión ya iniciada vía claude.ai; no se leyó el archivo de credenciales |
| Instrucciones iniciales WDev |CLAUDE.md importa su AGENTS.md; configuración válida |
| Skills Claude |9directorios enlazados desde .claude/skills a skills/claude; nombres/descripciones de frontmatter y destinos Markdown comprobados |
| Toolchain Classic |JassHelper, pJASS, common.j y Blizzard.j presentes y fingerprintados; checker retornaok sin errores/avisos |
| CodeGraph instalado |Backend MCP reporta1.6.2+jass-vjass.5; consulta independiente RapidFire devuelve41símbolos y fuente real |
| CodeGraph desde Claude |Pendiente de aprobación de servidor de proyecto; no conectado por ese cliente |
| Índices de copias WDev |Ausentes en las6raíces Proyect y UI Studio comprobadas; exclusión deliberada del respaldo, no fallo de subida |
| Instrucciones detalladas del proyecto |Presentes en Proyect; ausentes del AGENTS.md raíz WDev importado al inicio |
| Referencia jass-explore |Desactualizada: describe.3/extracción30; compartido por versiones Claude y Codex |

## Hallazgos y acciones pendientes

### CodeGraph aún no habilitado en Claude

`claude mcp list` en WDev devuelve Pending approval para codegraph. Los conectores
claude.ai Docs/Google Drive sí aparecieron conectados. La confianza del workspace
está aceptada, pero no equivale a aprobar este servidor. La documentación oficial
[distingue ese estado y su aprobación](https://code.claude.com/docs/en/mcp#project-server-approvals-and-workspace-trust).
En una sesión interactiva de Claude debe revisarse/aprobarse ese MCP y repetirse
una consulta real; no se eludió el aviso ni se editó la configuración para simularlo.

El backend se probó por STDIO/MCP de forma independiente, sin ejecutar un LLM ni
delegar a otro agente. Inicialización, descubrimiento y consulta reales correctos;
versión.5,41símbolos deRapidFire. Hay avisos conocidos de cobertura estática y
proyecciones, no equivalencia con compilación/ejecución. La consulta inicial a
Main.j no encontró código relevante porque contiene sólo imports; se leyó esa
entrada y se sustituyó por el símbolo realRapidFire. No se presentó el resultado
vacío como validación positiva.

Incidencia cerrada posteriormente: [aprobación y referencia](../informes/errores/resueltos/2026-10-23-222021-claude-codegraph-pendiente.md).

### Elegir raíz activa y contexto equivalente

El AGENTS.md raíz WDev contiene instrucciones Classic y del workshop, pero no la
tabla de raíces/projectPath, CodeGraph-first, política de informes ni reglas
explícitas contra complacencia presentes en Proyect/AGENTS.md. Es una diferencia
del contexto inicial; no demuestra por sí sola qué reglas cargó después una sesión.
Los archivos de la copia projects/proyect también conservan sus instrucciones,
pero esta auditoría no verificó su carga contextual dentro de Claude.

Con Claude2.1.310 no debe afirmarse que un proyecto sin CLAUDE.md ignora AGENTS.md:
las versiones recientes pueden leerlo directamente bajo las condiciones descritas
en [la documentación oficial](https://code.claude.com/docs/en/memory#agents-md).
El import explícito @AGENTS.md de WDev es válido. Para acreditar el contexto real,
revisar /context o /memory en la sesión elegida y alinear las instrucciones de esa
raíz. No copiar globalmente todas las políticas de un componente sin su alcance.

Si se trabaja sobre originales, usar sus índices propietarios existentes. Si
Claude desarrolla las copias WDev, preparar índices propios de esas copias,
limitados a sus componentes y con su perfil real. No consultar los originales
como si acreditaran las copias. No se inicializó WDev ni sus nuevas raíces durante
esta revisión. Las copias de respaldo no quedan automáticamente indexadas.

### Referencias compartidas antiguas

skills/claude/build-warcraft3-vjass-127b/references/jass-explore.md todavía describe
la revisión.3, extracción30 y límites anteriores (incluye hooks/delegates entre
lo no admitido). La misma referencia antigua existe en la skill Codex activa y
la copia skills/codex. La identidad real del backend es.5 y anuncia hooks y otros
avances posteriores; Proyect/AGENTS.md y JASS-VJASS.md contienen el estado actual.
Actualizar esa referencia en sus fuentes y adaptaciones después de contrastarla
con la revisión instalada. No es un fallo exclusivo de la preparación de Claude.

## Skills, herramientas y evidencia de uso

Las9skills están estructuralmente presentes: construcción, pruebas, misiles,
modelado, optimización, escritorio, depuración, planes y Judgment Day. No hubo
destinos Markdown inexistentes en la comprobación realizada. Esto no valida todos
los paths escritos dentro de bloques de código ni acredita invocación automática.
La adaptación de jurados usa Agent/Explore en vez de las herramientas de Codex;
no se lanzaron jurados para probarla, porque esta petición no pidió una revisión
adversarial ni una ejecución de agentes.

En el transcript local reciente WDev revisado hubo77llamadas de herramientas,
sin llamadas MCP CodeGraph ni invocaciones de la herramienta Skill. Sí hubo
comandos Bash que mencionan SKILL.md y CodeGraph; no se infiere de ello que no se
hayan leído skills por Bash ni se evalúa la intención de Claude. Es una muestra
de una sesión, no un historial exhaustivo. No demuestra adopción operativa MCP.

El checker compartido confirma cuatro archivos y hashes; no ejecuta JassHelper
ni pJASS. Wine no aparece en PATH, pero ese dato aislado no invalida los runtimes
privados que usan los lanzadores documentados. No se iniciaron compiladores/juego.
Node22, Blender y módulos MDX referenciados existen; eso no prueba exportador MDX.
Herramientas Hyprland y de entrada presentes, ydotool activo y uinput accesible:
capacidad local observada, no una prueba de entradas o permisos desde Claude.

La ruta antigua WarDatsPy/wc3-forge no existe y la referencia ya documenta ese
desajuste conocido; MCP W3/wc3-forge sí existe. No se confunde con un fallo nuevo
ni se reconfigura el entorno compartido durante la auditoría.

## Evidencia y límites

`work/claude-entorno-audit-20261023/`: backend-smoke.json, backend-positive.json,
toolchain.json, auth-redacted.json, claude-codegraph-status.txt, summary.json y
transcript-and-reference-check.json. Sólo se conservaron metadatos seleccionados,
sin claves/tokens ni contenido íntegro de conversaciones.

Conclusión limitada a esta PC y las configuraciones observadas. Falta demostrar
consulta desde Claude tras aprobar el MCP, catálogo/contexto de su sesión y
ejecuciones funcionales cuando las requiera una tarea. No se hicieron pruebas
de juego, multijugador, escritorio interactivo ni portabilidad desde otro checkout.
No se publicó este informe ni se modificó WDev en esta auditoría.
