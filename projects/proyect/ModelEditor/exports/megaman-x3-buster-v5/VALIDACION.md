# Validación V5 A — 23-10-2026

Estado: **Tested in map**, muestra visual V5. No implica aceptación artística final ni fidelidad de timing SNES.

- MDX800, relectura binaria estricta M3 y lector independiente war3-model; MDL reabierto, geometría contrastada.
- 474 poses Birth/Stand/Death: raíz(0,0,0), geometría X[-79.502342,0], nodos/jerarquía/UV/materiales/extents coherentes. Sin trayectoria mundial exportada.
- Nueve máscaras propias verificadas por cabecera, bytes, mipmaps y decodificador independiente. Dependencias12 presentes; texturas stock originales resueltas en visor y motor.
- Visor3D antes del juego: lateral, frontal, oblicua, ocho pasos de40ms; corrección del centro frontal de la punta y del pivote del residuo confirmada.
- Mapa compilado con JassHelper y pJASS;26 miembros reextraídos idénticos. Se verificó el hash de la copia WorldEditTestMap realmente abierta por YDWE.
- YDWE un jugador, EnableHost0 privado, pantalla3 DP-1.150 capturas con guarda de PID, inicio, prefijo, monitor y foco. Stand2.4, movimiento, Birth, Death, escala0.5 y3. Partida propia cerrada con retorno0.
- V4 y fuente Vinz conservados por hash. CodeGraph consultado antes y después; fuentes vigentes. No acredita por sí mismo render ni funcionamiento nativo.

La serie de Birth muestra entrada y estado lleno; el muestreo nativo de~200ms no reconstruye sus160ms completos. Los pasos de40ms se verifican en visor. El ciclo continuoV5 es una adaptación3D, no una copia demostrada del timingSNES. La física y la fusión quedan fuera de este pack.
