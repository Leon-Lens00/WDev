# Entorno activo compartido: Codex y Claude

Las fuentes activas de esta PC son `/home/snz/Documentos/ChatGPT/Proyect/` y
`/home/snz/Documentos/WarDatsPy/ui-studio/`. Ambos asistentes deben leer el AGENTS.md
de la raíz/componente afectado antes de modificarlo. Incluye entorno, contratos,
revisión de premisas, pruebas y notificación de errores. Este documento no amplía
el alcance de una tarea: si el usuario pide trabajar una copia concreta, respetarla.

Si ambos asistentes trabajan a la vez, asignar archivos/componentes diferentes,
revisar cambios ajenos antes de escribir y mantener un solo escritor por mapa.
CodeGraph refleja archivos en disco; no coordina las decisiones de dos agentes.

## Entrada y skills

Para operar sobre el proyecto activo, iniciar Claude o Codex en Proyect (o UI
Studio para su editor). Claude importa AGENTS.md mediante CLAUDE.md y usa las nueve
adaptaciones de `skills/claude`, enlazadas en las entradas locales. Codex conserva
sus skills de `~/.codex/skills`; `skills/codex` es la copia versionada. No intercambiar
las herramientas de subagentes: la adaptación Claude usa Agent; Codex sus propias
herramientas. Los jurados sólo se lanzan cuando se solicitan/aceptan.

Para computer use en esta PC CachyOS/Hyprland, cargar control-escritorio-linux y
comprobar acceso/permisos actuales; preferir CLI/API específica cuando resuelva
la tarea. Las capacidades locales conocidas no garantizan acceso desde otra sesión.

Desde WDev, una tarea referida al proyecto activo debe usar las fuentes originales
y leer sus instrucciones; los directorios `projects/proyect` y `tools/ui-studio`
son snapshots para respaldo. No editar una copia y afirmar que cambió el original,
ni presentar una consulta del original como evidencia de una copia distinta.
La configuración de permisos local facilita acceso a esas dos raíces; no habilita
todos los comandos ni cambia las comprobaciones normales del cliente.
Las aprobaciones viven en `.claude/settings.local.json`, excluido de Git. No se
replican como autorizaciones al clonar: cada entorno debe confiar/configurar sus
propias entradas. Las sesiones nuevas cargan el contexto comprobado; una sesión
anterior no se considera actualizada sólo porque cambió un archivo de configuración.

## CodeGraph primero y raíces existentes

Antes de localizar/comprender/modificar código indexado, consultar
`codegraph_explore` con nombres concretos y projectPath del propietario. El código
devuelto cuenta como leído; ampliar sólo lo no cubierto o no vigente.

| Trabajo | projectPath activo |
|---|---|
| TerrainDev: movimiento y misiles | `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src` |
| Builder/laboratorios | `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/scripts` |
| Laboratorio SNES, sólo scripts | `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/labs/x3-snes/scripts` |
| Integración inventario | `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration` |
| Conversaciones | `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system` |
| ModelEditor | `/home/snz/Documentos/ChatGPT/Proyect/ModelEditor` |
| WaveSys aislado | `/home/snz/Documentos/ChatGPT/Proyect/WaveSys` |
| UI Studio, JS activo | `/home/snz/Documentos/WarDatsPy/ui-studio/dist` |

La tabla/instrucciones de Proyect prevalecen si se actualizan. Las raíces son
independientes: no suponer aristas entre ellas. Los nuevos archivos de una raíz
se actualizan mediante watcher/sync, no con otro índice. Revalidar diagnósticos;
DISABLED/RECOVERING persistente o falta de vigencia requieren recuperación/lectura
directa e informe. En CLI sin watcher, sincronizar tras cambios. El watcher no es
un servicio perpetuo: se libera tras10min sin consultas; reabrir sincroniza.

No inicializar un índice padre de WDev/Proyect ni copiar dependencias para aparentar
cobertura. Nuevas raíces en Proyect/UI Studio se rigen por la autorización y
política de Proyect/AGENTS.md. Una copia WDev elegida explícitamente para desarrollo
necesita alcance/índices propios antes de confiar en el grafo; no se preparan como
efecto de respaldarla. No ejecutar codegraph upgrade sobre la adaptación local.

## Exactitud, riesgos y errores

- Tratar afirmaciones del usuario y del asistente como hipótesis; contrastar
  premisas decisivas con las fuentes/APIs del entorno real y buscar evidencia
  contraria. Las preferencias del usuario no son afirmaciones técnicas a refutar.
- Revisar consumidores e impacto antes de cambiar interfaces/bibliotecas. Explicar
  incompatibilidades demostradas y alternativas; distinguir sospecha de defecto.
- No aceptar una conclusión por insistencia ni presentar instalación, conexión,
  consulta, compilación, juego y multijugador como pruebas equivalentes. Ajustar
  comprobaciones al riesgo y declarar los límites de cobertura.
- Informar fallos reales en el chat y registrar su evidencia/estado en
  `/home/snz/Documentos/ChatGPT/Proyect/informes/errores/`, según su README. Actualizar
  el informe existente en repeticiones; al comprobar recuperación mover a
  resueltos/ y actualizar enlaces. No ocultar errores de MCP ni falta de vigencia.
- Seguir las restricciones Classic1.27b y perfiles/API/completeInputs reales. Una
  arista candidata no demuestra ejecución; ausencia de arista no demuestra ausencia
  de consumidores. Compilador y juego siguen siendo verificaciones separadas.

CodeGraph vigente:1.6.2+jass-vjass.5, extracción32, esquema12. Capacidades y límites
en `/home/snz/Documentos/MCP W3/codegraph-vjass/JASS-VJASS.md`. Las instrucciones
guían al asistente; su presencia no garantiza ausencia de errores o complacencia.
