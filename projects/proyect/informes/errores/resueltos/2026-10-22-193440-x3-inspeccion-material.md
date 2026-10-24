# Auxiliar de inspección X3: índice de material inexistente

Fecha:2026-10-22 America/Lima. Entorno ModelEditor/Node22, lectura de referencia Shots800.

Se intentó inspeccionar materials[1] en un modelo que sólo tiene un material. `plain(undefined)` lanzó SyntaxError al pasar por JSON.parse. No se escribió ni modificó el modelo. La hipótesis errónea era que había varios materiales; son varias capas dentro de materials[0].

Acción: corregir la consulta a materials[0], leer los campos reales y continuar la construcción de modelos originales del buster. Estado: pendiente comprobar recuperación de esa lectura; la exportación y prueba del nuevo modelo tendrán verificaciones separadas.

Recuperación: la consulta con materials[0] terminó correctamente y mostró las cuatro capas y sus filtros, junto con los campos de PE2, geoset y hueso. El original siguió intacto; no queda un bloqueo para inspección. Estado: resuelto.
