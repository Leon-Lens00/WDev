# Incorporación autorizada de nuevas raíces de código

Fecha: 22 de octubre de 2026. Autorización: el usuario pidió aplicar la política
permanente de nuevas raíces y la incorporación de dialogue-system, tras explicar
la diferencia entre mantenimiento del índice y su inicialización.

Alcance: instrucciones locales de Proyect/UI Studio, índice nuevo para
TerrainDev/dialogue-system y corrección de identidad documental de UI Studio.
No modificar el motor CodeGraph ni fuentes/builds/mapas que edita el chat UI.

Fases: (1) verificar builder, fronteras de raíces e instrucciones; (2) documentar
la autorización delimitada, exclusiones y perfiles; (3) preparar perfil y APIs
Classic como entradas de análisis e inicializar por CLI sin prompts; (4) abrir
por MCP, comprobar fuentes, flujo de diálogo, exclusiones y vigencia; (5) cerrar
la discrepancia de versión y archivar su informe conservando enlaces.

Objetivo observable: consultas MCP con ConversationAdvance/BeginPage/Render
incluyen código nuevo de src; build.py y tools pertenecen al mismo alcance,
los builds históricos y recursos binarios están excluidos. El perfil corresponde
al builder vjass sin --debug y mantiene completeInputs false por dependencias
externas y script base fuera del índice. Las bibliotecas UserInterface/Camera
se consultan en inventory-integration, sin duplicarlas en esta raíz. No se
afirman aristas entre índices independientes.

Estado: completado. Política guardada, nueva raíz inicializada y verificada
por MCP; discrepancia documental corregida y archivada. Evidencia: work/codegraph-nuevas-raices-20261022/.

## Resultado

CLI init --yes: nueve archivos, 7815 nodos y 22298 aristas. MCP devuelve fuente
y enlaces ConversationAdvance → Render/BeginPage; metadata .5/extracción 32,
estado complete y quick_check ok, cero errores de extracción. No aparecen rutas
excluidas. API inputs coinciden por SHA-256 con los originales de la toolchain.

La nueva política se guardó en AGENTS.md de Proyect y UI Studio. La raíz de
diálogo tiene guía propia; no se modificaron las fuentes, mapas, recursos o
servidores que trabaja el chat UI. Su trabajo puede cambiar esos archivos en
paralelo; el watcher seguirá los cambios mientras esté abierto el índice.
No se envió un mensaje al otro chat ni se afirma que ya haya consultado esta
raíz nueva: se comprobó disponibilidad real desde el chat de herramientas.
La ausencia de aristas a UserInterface/Camera externos es un límite explícito.

Informe documental cerrado en informes/errores/resueltos/
2026-10-22-130507-codegraph-guia-ui-version.md. Las demás incidencias del chat UI
conservan su estado y no se modificaron ni archivaron por esta tarea.
