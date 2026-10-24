# Captura de ventana de prueba fuera del monitor

Fecha: 2026-10-22 18:12 America/Lima. Proyecto ModelEditor, Hyprland 0.56 / juego Classic 1.27b en prefijo propio.

Síntoma: la captura de DP-1 mostró escritorio, aunque el mapa estaba cargado. La ventana flotante PID684466 se movió a workspace11/monitor1, pero conservó posición global [2372,196], fuera de DP-1 cuyo origen es [3840,0]. No es un fallo de MDX ni prueba del aspecto del modelo.

Causa confirmada: mover de workspace no recolocó las coordenadas flotantes. Se identificó la ventana por prefijo y hash del mapa, se aplicó `hl.dsp.window.fullscreen_state` sólo a su dirección y se enfocó la ventana propia. Estado posterior [3840,0], 1920×1080; captura repetida mostró el laboratorio correcto. No se cambiaron reglas globales ni se interactuó con partidas ajenas.

Estado: resuelto y verificado mediante inventario Hyprland y `ModelEditor/evidence/brillo/gallery-vol-i-doble.png`. Las capturas de escritorio quedan como evidencia de intento, sin contarlas como prueba de modelos.
