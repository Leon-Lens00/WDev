# UI Studio: identidad de CodeGraph desactualizada en su guía

- Fecha: 2026-10-22T13:05:07.398459-05:00. Origen: chat Edit Tools, revisión del uso en UI.
- Entorno: UI Studio local, CodeGraph .5, extracción 32, esquema 12.
- Estado: resuelto; guía de UI Studio actualizada y coherente con la revisión .5/extracción 32/esquema 12.
- Síntoma: /home/snz/Documentos/WarDatsPy/ui-studio/AGENTS.md declara revisión
  1.6.2+jass-vjass.3 y extracción 30. El índice de dist observado en modo lectura
  antes de consultar MCP informa 1.6.2+jass-vjass.5 y extracción 32; seis archivos
  coinciden con disco, sin errores de extracción. MCP devuelve los módulos nuevos.
- Impacto: la guía puede inducir a interpretar incorrectamente qué revisión está
  activa. No demuestra que el proceso o el índice estén en .3.
- Causa: la guía de UI Studio conserva la identidad histórica; no se actualizó
  al documentar .5 en AGENTS.md de Proyect.
- Acciones: contraste de guía, metadata SQLite y consulta MCP del turno anterior.
  No se editó el proyecto en desarrollo por el chat UI ni se reinició su servidor.
- Pendiente: actualizar la identidad documental de UI Studio y verificar la
  coherencia con la instrucción principal; no requiere reconstruir por sí sola.

La ausencia de índice en TerrainDev/dialogue-system es un alcance nuevo,
no un fallo de actualización de dist. La regla upstream en el commit
6560052a6f856855d3f71eee838fd66ccfa4285d deja la inicialización de raíces nuevas
como decisión del usuario; no confundir ambas cuestiones.

## Recuperación comprobada

Autorización del usuario: «Claro, aplica el fix», incluyendo política de nuevas
raíces y corrección documental. UI Studio/AGENTS.md ahora declara .5, extracción
32 y esquema 12; se contrastó con las guías y metadata del índice. También se
incorporó la política local autorizada de nuevas raíces, sin modificar las
instrucciones genéricas upstream de otros proyectos. No hizo falta recompilar
CodeGraph, reiniciar MCP ni interrumpir la partida del chat UI.

La nueva raíz de diálogo se inicializó por CLI y se consultó por MCP: nueve
archivos, 7815 nodos, 22298 aristas, cero errores de extracción y SQLite íntegro.
Se excluyen build/evidence/assets/exports/cachés. APIs Classic exactas y perfil
release respaldado por builder; completeInputs false. Las dependencias de UI
se siguen consultando en inventory-integration, sin aristas entre índices.
Evidencia: work/codegraph-nuevas-raices-20261022/{init.log,index-verification.json,
mcp-dialogue-response.json,api-provenance.json}. Informe trasladado a resueltos/.
