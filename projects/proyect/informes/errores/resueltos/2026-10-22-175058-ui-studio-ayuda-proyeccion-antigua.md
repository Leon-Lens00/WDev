# Ayuda del editor de diálogo conserva el estado antiguo de la proyección

- Fecha: 22/10/2026 17:50 America/Lima. Agente: chat de diálogo y retratos.
- Proyecto/entorno: UI Studio local, dist/dialogue-core.js, dialogueNotes;
  destino WarcraftIII Classic1.27b. Mapa actual ea4073c65837ff39b36376a6f4e4923d569a8fbd44fc2df363e9329d3b9dee45.
- Síntoma: el texto de ayuda dice «Su proyección sigue provisional: existe una
  incidencia de recorte por posición en el motor». La incidencia130405 ya está
  archivada como resuelta tras restauración/afinamiento, con cobertura limitada
  a1920×1080SP. La ayuda debe expresar ese estado y sus límites actuales.
- Evidencia/reproducción: consulta CodeGraph de dialogue-core.js devuelve
  dialogueNotes, línea39; contrastar con
  [incidencia130405](resueltos/2026-10-22-130405-dialogo-marco-invisible.md) y
  work/dialogue-fine-20261022/AFINADO.md. Lectura de fuente; no se ha abierto el
  panel de ayuda en navegador en esta evaluación.
- Impacto: información desactualizada al consultar/exportar las notas. No
  demuestra una nueva regresión del marco ni afecta a los tiempos de animación.
- Causa confirmada: cadena de ayuda no actualizada junto con la corrección.
- Estado: abierto, pendiente de corrección y comprobación. No modifica ni bloquea
  la evaluación de línea/estática o de los modelos originales.
- Acciones: registrado en el plan de retratos para la siguiente entrega del
  editor; código sin cambios. Pendiente actualizar la cadena conservando límites
  de cobertura y verificar texto obtenido por dialogueNotes.

## Corrección verificada
Estado final: resuelto. dialogueNotes informa ahora la calibración contrastada1920×1080SP y límites de otras resoluciones; ya no afirma incidencia activa de recorte. La prueba de migración/ayuda dialogue-transition.test.mjs pasa junto a40pruebas adicionales; CodeGraph devuelve la fuente actual. La corrección es documental, no certifica otros clientes.
