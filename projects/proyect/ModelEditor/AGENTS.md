# Pruebas visuales de ModelEditor

Por indicación del usuario del 22-10-2026, cargar las pruebas de este componente en la pantalla 3: el monitor de la derecha, actualmente `DP-1` (x=3840, y=0). Comprobar nombres y disposición antes de actuar, porque pueden cambiar.

Identificar PID, inicio, prefijo propio y ventana del ensayo. Mover únicamente esa ventana al workspace activo del monitor DP-1 y enfocar allí; no usar `follow=true` sobre un workspace nuevo sin fijar su monitor, porque puede crearlo en la pantalla actualmente enfocada. Conservar otras partidas y ventanas.

Después del auxiliar Win32 de consola, comprobar activación real del juego: su simulación puede seguir pausada aunque Hyprland lo muestre enfocado. Si hace falta, un clic dentro de la ventana propia previamente identificada restaura la activación. Capturar el monitor que contiene esa ventana y contrastar PID/workspace en cada toma relevante.

## Modelos antes de juego

Corrección del usuario22/10/2026: usar el lanzamiento anterior con perfil propio, sin imponer LAN. Antes de abrir Warcraft, mostrar la revisión en un espacio3D con cámara orbital, ejes/rejilla, origen y secuencias. Para X3, pulir hacia las técnicas observadas en los originales de Vinz: forma energética y capas luminosas, manteniendo la identidad de las referencias X3. El primer pack v1 sigue conservado.

Para los ensayos X3 el usuario pidió intentar YDWE, **un jugador, sin LAN**. Rama observada: YDWE.exe -war3 -loadfile, EnableHost0 sólo en copia privada. No acreditar editorCtrlF9 por usar esa rama. Al mover la ventana flotante, fijar fullscreen0→2 antes de enfocarla y comprobar monitor/coordenadas; conservar otras partidas.
