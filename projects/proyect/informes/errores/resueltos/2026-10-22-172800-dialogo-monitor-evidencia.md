Estado vigente: RESUELTO para el capturador de esta prueba. Mantener las guardias;
no se afirma corregir globalmente Hyprland ni los cambios de foco ajenos.

# Capturas del monitor incorrecto en ensayo de diálogo
Fecha: 22/10/2026,17:28; Classic1.27b, diálogo34b7d91d, CachyOS/Hyprland. Estado: abierto para repetición controlada.
Tras enfocar/capturar con game.py (identidad647574), la secuencia global usó grim eDP-1 y coordenadas de ese monitor; las cinco fine-moving-*.png muestran Brave. Inventario posterior confirma Warcraft en monitor2/HDMI-A-1, mientras navegador en monitor0. La orden de ratón global no acredita movimiento: logs1/2 conservan owner -5136,2672. No se presume causa del cambio de monitor ni efecto de clic fuera del juego. Evidencias inválidas para ensayo; conservar como diagnóstico, no compartirlas como resultado del panel. Capturas game.py/fine-zone1 sí corresponden a la partida.
Acción: repetir con orden IssuePointOrder del propio mapa desde chat identificado, medir owner y capturar por monitor actual del PID. Nunca cerrar navegador ni procesos ajenos. Continuar editor en IAB sin teclado global.

Recuperación comprobada: PID649780, -caminardialogo emite IssuePointOrder; game.py obtiene monitor actual de ventana/PID y revalida identidad. fine-final-moving-0..3 son capturas del juego; owner x/y cambia en9registros conservados. Borde736..738 constante, residual≤0.001. Primeros cinco fine-moving inválidos permanecen excluidos. CierreS y proceso ausente. Estado: resuelto para la toma de evidencia; no se presume qué causó cambio de monitor ni efecto del clic global inicial.

22/10, piloto animado: otra captura inicial no correspondía al monitor de la ventana propia; se descartó antes de enviar entradas allí. Se movió sólo la ventana propia a workspace3/eDP-1, identificando PID/prefijo/mapa y verificando capturas posteriores. Recuperación mantenida en safe-* del mapa744544ae; sin cierre de otras partidas.

22/10, ajuste Tauren HUD: workspace3 quedó asignado a HDMI-A-1 al mover la ventana. Las capturas reference-loaded*.png de eDP-1 no son del juego y se descartan; reference-correct-monitor y before-panel-original-hud capturadas en HDMI muestran el PID710479 correcto. El capturador consultará monitor actual porPID en cada captura; no se enviaron entradas a otro programa.

Repetición al probar4c5d62bd: variants-native-idle-5 y variants-native-blue muestran otra partida X3 MODELS. La ventana propia está en workspace9 y otra en11 del mismo monitor; enfocar PID con hl.dsp.focus devuelve activewindow propio pero no garantiza que se cambie el workspace visible. Se invalidan variants-native-idle-0..9 y blue/moving/closed/reopened de ese intento salvo revisión visual. No se atribuyen sus imágenes al mapa. Entradas estaban guardadas por PID, pero la verificación visual requiere cambiar explícitamente al workspace propio y confirmar activeWorkspace del monitor antes de capturar. Estado pendiente de recuperación.

22/10, 20:43: prueba final-forced-idle abortó correctamente por pérdida de foco antes del segundo comando; no generó capturas y no acredita ciclo. Intento posterior de montage se descartó por archivos ausentes. Se pasó al auxiliar Win32 del prefijo propio (HWND20082, LinuxPID766344/inicio/hash guardados), cuyos mensajes van sólo a la ventana propia, y capturas por workspace9 HDMI. final-target-idle0..9 válidas; no atribuir continuidad temporal durante cambios de foco no medidos.

Repetición20:50: stand-names-first muestra escritorio y stand-names-correct muestra otra partidaX3; ambas inválidas. cliente propio conservabaPID773549 pero coordenadas3840/monitor1 mientras capturaHDMI. Se corrigió usando focusmonitor explícito, workspace32 propio y on_current_monitor=false, moviendo sólo la ventana propia aHDMI; se exige además at.x=1920 y monitor2. stand-names-screen2 válida. Auxiliar native_probe.py guarda estado de cliente/monitor por captura. No cerrar ni modificar sesiones ajenas.

Recuperación final: native_probe.py exige identidad PID/inicio/prefijo/hash,
monitorHDMI-A-1, coordenadaX1920 y workspace32 visible; focus de monitor explícito
y on_current_monitor=false. ordered-* y vídeo final2cb340db muestran la partida
propia, apertura/pausa/patrulla/cierre. Cada captura registra metadatos. No se
usan tomas X3/escritorio como evidencia. Todas las partidas propias de estos
ensayos terminaron; ninguna sesión ajena fue cerrada por este flujo.
