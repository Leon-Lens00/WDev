# Vista de UI Studio caída al recargar
Fecha22/10/2026, chat de diálogo; IAB tab3, UI Studio127.0.0.1:4317. Estado: en recuperación.
Tras regenerar los bustos con torso fijo, reload terminó pero #d-edit agotó espera de3s/Runtime.evaluate. La siguiente lectura devuelve la pantalla interna This page crashed, localhost crashed unexpectedly. Impacto: no acredita la vista del último busto del Paladín, aunque las anteriores sí se verificaron. No se atribuye causa al MDX ni al navegador sin evidencia. Se intentará navegar de nuevo a la URL local; servidor/fuentes conservados. Capturas previas editor-bust-final.png no sustituyen esta última revisión.

## Recuperación comprobada
Estado final: resuelto mediante nueva vista del mismo navegador. Tab4 carga el mismo servidor/JSON, MDX y controles. Se seleccionó mensaje2X y habla; editor-body-stand.png guardada y revisada; nueva lectura AX confirma vista operativa. El último error de URL de datos al final de la llamada correspondía a cerrar la pestaña3 caída, después de haber guardado la captura de4; no fue una segunda caída del editor recuperado. Causa de la caída inicial no aislada; no se cambiaron modelo ni navegador para recuperarla. La vista nueva se conserva como entregable.

22/10, ajuste Tauren HUD: la recarga de tab4 vuelve a mostrar This page crashed. Se recuperará mediante vista nueva del mismo IAB; no se atribuye al nuevo MDX sin evidencia. Estado: en recuperación.

Repetición: tab9 cayó mientras tab11 de referencia estaba abierta. No sólo ocurre al recargar; causa todavía no aislada. Cierre de la tab caída bloqueado por política de URL de pantalla interna; no se intenta eludirla. Tab11 válida cerrada y tab12 nueva carga controles/modelos. La falta de persistencia de fill/Tab en controles numéricos se está comprobando separadamente y no se acredita como encuadre aplicado.

22/10, tab5: timeout Input.dispatchMouseEvent al desmarcar guías; AX posterior comprobó editor operativo y se guardó editor-idle-final.png. Más tarde la misma tab5 pasó a pantalla interna de caída; no se atribuye al clip sin aislar causa. Sigue abierta. El screenshot previo es válido para el instante guardado, no prueba estabilidad sostenida del navegador.

22/10, vista final tab6: editor-ordered-final.png muestra el MDX cronológico actual y reposo manual. La acción posterior para volver a automático agotó espera y la vista volvió a caer. Sigue abierta; nueva pestaña recupera un instante operativo pero no acredita estabilidad sostenida. La compilación y las pruebas nativas son independientes de esa caída.

Mezcla de retratos: nueva tab7 del mismo IAB agotó Page.getFrameTree al crearse (42s), sin acreditar vista de la modificación. Se mantiene abierto; suite Node47/47 pasa pero no sustituye revisión visual de la mezcla en editor. No se atribuye la caída a esa modificación sin aislamiento.
