# Confirmación de salida enviada tras perder foco

- Fecha: 2026-10-22 15:48 America/Lima, chat ModelEditor, prueba Classic 1.27b/Hyprland.
- Síntoma: tras Win+Q y captura del diálogo de salida de la partida propia, el siguiente comando leyó `activewindow` apuntando a Brave y envió `S` sin condicionar esa entrada al resultado. La partida anterior ya había terminado (lanzador exit 143). No se ha comprobado un efecto de esa S en la página del navegador.
- Causa confirmada: comprobar foco imprimiéndolo no impide la siguiente tecla; faltaba una condición dentro de la misma operación. El estado cambió entre captura y confirmación.
- Impacto: una entrada global ajena a la ventana objetivo; ningún cambio intencional en el navegador. No atribuir ausencia de efectos sin comprobarla. No se intentó deshacer a ciegas.
- Acción: evitar más entradas globales para el ensayo; usar auxiliar Win32 con HWND/prefijo/identidad actuales para comandos. Antes de cerrar, revisar PID/inicio y ventana propia; ante pérdida de foco no enviar confirmación global.
- Estado: documentado, sin recuperación de navegador acreditada. La prueba de modelos es independiente. Requiere verificación del cierre final seguro.


Cierre final seguro verificado: PID propio 611219 / hash de mapa 36c445d288631cb9; WM_CLOSE y tecla VK83 dirigidos al HWND 00020082 de su prefijo, captura del diálogo antes de confirmar, retorno del lanzador 0. Otra partida en runtime-isolated se conservó. El efecto de la S anterior en Brave permanece sin comprobar; informe abierto por ese límite.


## Repetición en integración TerrainDev, 22oct17:53

Al enfocar la ventana propia PID663900, la lectura inmediatamente posterior de activewindow no coincidió. El guard abortó ANTES de enviar Win+Q: no se envió ninguna tecla global. Cierre alternativo SIGTERM sólo al PID663900 tras revalidar tiempo de inicio, comando con hash del mapa y WINEPREFIX. Proceso terminado; evidencia en TerrainDev/reports/shot-colors-20261022/20261022-175007/closure.json. Se conserva la incidencia original abierta por el efecto previo ajeno a esta prueba que aún no está comprobado. Esta repetición no demuestra la causa de la pérdida de foco.
