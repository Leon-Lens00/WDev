# Primera compilación del prototipo de conversación
Fecha: 2026-10-22 13:02 America/Lima. Proyecto: TerrainDev/dialogue-system, Classic1.27b, JassHelper release.
Estado: corregido, pendiente de recompilar.
Síntoma: JassHelper/pJASS rechaza Undefined function Tick y Undeclared function Camera_GetTerrainZ.
Evidencia: build/20261022-130130-507170/compile.json y FrozenThone/runtime/wc3-tools/reports/vjass-20261022-130130-994576/logs/compileerrors.txt.
Causa: callback privado referenciado antes de declaración; se asumió un prefijo público en una función que no lo tiene. No es fallo del compilador ni de CodeGraph.
Acción: mover ConversationOpen después de Tick; usar GetLocationZ sobre la ubicación inicial existente. Impacto: no se empaquetó el mapa fallido. Los mapas anteriores se conservan.
Verificación pendiente: compilar, pJASS reextraído y prueba visual.

Recuperación comprobada: segunda compilación, empaquetado, reextracción y pJASS final correctos. Manifiesto: TerrainDev/dialogue-system/latest-build.json; build/20261022-130223-983815. Resuelto el bloqueo sintáctico; prueba visual registrada por separado.
