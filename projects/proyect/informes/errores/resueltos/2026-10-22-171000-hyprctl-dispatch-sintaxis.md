# Dispatcher Hyprland: sintaxis antigua rechazada

Fecha: 2026-10-22; tarea Camera TerrainDev, sesión Linux. `hyprctl dispatch fullscreen 0` retornó 7, parser Lua esperaba paréntesis. No modificó ventana ni mapa. Captura posterior confirma juego ya ocupa monitor completo por configuración propia. Estado: cerrado con alternativa comprobada: no hace falta cambiar fullscreen; continuar usando auxiliares Lua actuales y capturas de la ventana validada. No se envió ninguna tecla adicional por este fallo.
