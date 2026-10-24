# Lectura auxiliar MDX: límite del buffer

Fecha: 2026-10-22T12:52:58.434667-05:00. Proyecto: prototipo de conversaciones Classic 1.27b. Origen: este chat. Entorno: Node, war3-model 4.0.1.

Síntoma: RangeError al inspeccionar UI/RaceWindow.mdx. Causa confirmada: el comando de inspección mezclaba buffers de lecturas distintas y no acotaba el ArrayBuffer a byteOffset + byteLength. No indica corrupción del recurso original.

Acción y comprobación: una sola lectura, slice(b.byteOffset,b.byteOffset+b.byteLength). El mismo archivo se parsea y devuelve versión 800, secuencia Stand, BillboardedBone y sus materiales/geometría. No se modificó el original. Estado: resuelto; esto valida lectura estructural, no aspecto en juego.
