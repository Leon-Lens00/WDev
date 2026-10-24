# Copia de ensayo sin sustituciones acumuladas

- Fecha: 2026-10-22 15:41 America/Lima. ModelEditor, wc3ctl Classic 0.3.0, mapa de prueba aislado. Original TerrainDev y modelos intactos.
- Síntoma: compilación JassHelper/pJASS correcta, pero reextracción de `war3map.j` devolvió 41872 bytes del mapa base frente a 18648 del ensayo.
- Causa confirmada: `wc3ctl file set` escribe por defecto `<input>.edited.w3x`, no modifica el input. El generador asumía sustitución in situ y cada operación partía de la base. Logs `ModelEditor/build/visual-20261022/commands.log` muestran SavedTo.
- Impacto: ensayo todavía no ejecutado. La comparación de bytes detectó el problema antes de abrir el juego; no hay conclusión visual válida.
- Acción: encadenar salidas nuevas explícitas `--out stage-N.w3x`, utilizando cada salida como entrada de la siguiente. Reextraer todos los miembros y comprobar hash/bytes antes de jugar.
- Estado: pendiente de repetir empaquetado/reextracción.

## Recuperación y ajuste visual

39 miembros reextraídos y comparados exactamente; el mapa cargó en 1.27b. La cámara inicial apuntaba hacia arriba por usar 70 grados en vez del ángulo descendente Classic; el segundo ensayo usó 290 y recuperó terreno/vista normal (`ModelEditor/evidence/game-grid.png`). Los modelos no cambiaron por el ajuste del laboratorio.


## Cierre — 22 de octubre de 2026

Recuperación final: mapa c, 39 miembros reextraídos exactamente, JassHelper/pJASS correctos y carga/Stand/Birth/Death observados en 1.27b. Modelo y fuente del mapa base conservados. Estado final: resuelto.
