# Selección SP y captura del laboratorio

Fecha: 2026-10-23T09:22:57.423213-05:00. Codex, WaveSys Classic1.27b. Estado: en investigación.

La ejecución gameplay-api-v1 completó13entradas de armas y abrió selección; el registro permanece selection-open durante más de un minuto real con diálogo visible. Sus timers de selección y observador no avanzan. Hipótesis: pausa de reloj propia de diálogos en SP; contrastar elección manual y reanudación. No se considera timeout aprobado.

Capturas auxiliares gameplay-api-v1-progress.png mostraron Codex y actual-monitor.png mostró otra partida ModelEditor superpuesta en DP-1; ambas se descartan para conclusiones de este juego. La identidad own994871 y cmd420911892f030a2f.w3x se verificaron. Se movió sólo la ventana propia a workspace1/eDP-1; own-visible.png muestra el diálogo correcto. Una orden antigua focusmonitor fue rechazada por sintaxis Lua; no ejecutó entrada. Se usó la API hl.dsp.window.move conocida. No se hicieron clics ni cierres sobre otras sesiones.

Pendiente: contraste manual y captura final por identidad/monitor. Producto sin cambios.

Actualización: la posición absoluta de ydotool no coincidió con la prevista (limitación multimonitor ya descrita en la skill); ese clic no demuestra selección manual ni se conoce su destinatario final. La ventana propia volvió aDP-1 y otras partidas compartieron la composición/foco. Nuevas guardas abortaron cuando el foco era ajeno; ninguna tecla de cierre se envió a otra partida. La captura propia own-visible.png sí muestra diálogo; own-dp.png mostró otra partida y se descarta. NO se declara confirmado un defecto del timeout: falta separar pausa SP de foco/entrada. Se conserva24controles/3FAIL recursos y13entradas API, sinCOMPLETE. La instancia propia994871 se cerró por SIGTERM después de validar PID/start/prefix/map; otras no tocadas. Estado: abierto para validar selección/timeout y efecto del clic no acreditado.
