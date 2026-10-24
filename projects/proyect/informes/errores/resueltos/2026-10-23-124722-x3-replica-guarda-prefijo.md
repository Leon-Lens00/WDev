# Guarda de identidad: barra final de WINEPREFIX

Fecha: 2026-10-23T12:47:22.131568-05:00. Agente raíz, TerrainDev, Classic1.27b/CachyOS. Revisión de ensayo6fc9c2f5b2cdb360.

Síntoma: el inventario encontró el PID1030762 y su mapa, pero la igualdad textual entre prefijos rechazó la partida propia: entorno termina en `/pfx/`, ruta esperada en `/pfx`. AssertionError[] antes de enfocar/capturar; no se enviaron entradas por esa ruta. Evidencia: salida de inventario en este chat.

Causa confirmada: falta de normalización de rutas en el snippet de inspección, sin cambio del juego. Impacto: retraso de la identificación gráfica; no afecta a física o compilación.

Corrección y recuperación: comparar Path(prefix).resolve() contra el prefijo esperado, conservando además PID/inicio y hash del mapa en comando. Se encontró una sola partida y se guardó identidad en TerrainDev/reports/x3-gif-replica-20261023-124052/20261023-124607/identity.json; foco y fullscreen dirigidos a su dirección comprobados por hyprctl. No se relajó la guarda ni se cerraron procesos ajenos.

Estado: resuelto; esta comprobación sólo acredita identificación, no que la suite de física haya pasado.
