# UI Studio: servidor local detenido al iniciar QA

Fecha: 2026-10-22T12:43:04.676228-05:00. Origen: chat de prototipo de conversaciones. Entorno: CachyOS, Node, navegador integrado, UI Studio local.

Síntoma y evidencia: recargar http://127.0.0.1:4317/ devolvió ERR_CONNECTION_REFUSED. No se pudo iniciar la prueba visual. La página de error del navegador produjo además una negativa al navegar a su documento data:, sin que se intentara eludirla.

Causa: el servidor local de la sesión anterior no estaba atendiendo; no se atribuye un error al código del diálogo. Acción: iniciar el server.mjs existente mediante node en la carpeta del editor. Verificación: HTTP 200; pendiente recargar y comprobar render/interacciones de la conversación.

Estado: corregido pendiente de verificar en navegador. Las 23 pruebas Node de geometría, inventario y conversación habían pasado antes de este inicio.

Recuperación comprobada: pestaña nueva del navegador integrado carga el editor, muestra la conversación, permite escritura parcial, pausa, completar y avanzar a X; consola sin errores. La pestaña antigua conservaba la página de error y no aceptaba la recarga, por lo que se utilizó la recuperación documentada mediante pestaña nueva, sin cambiar mecanismos ni permisos. Estado final: resuelto.

Reapertura 12:57: el proceso ligado a la sesión de ejecución volvió a terminar; no había node server.mjs activo. Se relanza con Popen/start_new_session y log propio. Pendiente de confirmar estabilidad y acceso en navegador.

Recuperación: proceso493547 independiente sigue activo varios minutos después; pestaña3 carga editor, pausa y cambios de personaje; descarga GuardarJSON a /home/snz/Descargas/conversacion.wc3dialogue.json; sin errores consola. Proceso inicial se cerraba con su sesión de ejecución, el nuevo persiste. Resuelto.
