# X3V4: guardia de cierre y barra final del prefijo

23/10/2026, agente raíz, ModelEditor Classic1.27b/YDWE. Estado: corregido pendiente de verificar cierre.

La guardia rechazó el cierre antes de enviar entradas porque comparaba WINEPREFIX por bytes: Proton añade barra final y la identidad guardada no. PID e inicio seguían coincidiendo. No hubo cierre ni envío de teclado por ese rechazo; modelos y capturas intactos. Se corrigió la comprobación puntual comparando Path.resolve, como ya hace capture-x3-v4.py. Después se verificó PID/inicio/prefijo, Win+Q mostró Confirmar Salir en la partida propia. Evidencia: evidence/x3-v4/close-dialog.png. Pendiente comprobar salida tras S.

Recuperación: el foco había pasado a PID913833 de otra partida. No se envió S global. Se reconfirmó PID907756/inicio/prefijo y el único HWND del perfil propio00020082; se envió VK83 sólo a ese handle. Juego propio terminó y lanzador devolvió0; native-r1/close.json y ydwe-exit.json. Informe resuelto: guardia evitó entradas cruzadas.

Ensayo final B: la primera captura Stand se interrumpió por cambio de foco detectado por la nueva guardia por frame. No produjo timing.json ni se da por validada. Movimiento posterior pasó25frames con foco/PID/pantalla comprobados. Se repite Stand tras completar la activación; incidente reabierto mientras se comprueba recuperación.

Recuperación final: Stand repetido25frames completos y las otras cinco secuencias de captura completas (150frames). Guardia de foco mantenida por fotograma; carpeta stand-incomplete excluida de aprobación. Partida finalPID916423 cerrada con Win+Q/S tras confirmar diálogo y foco; retorno0, cero procesos con prefijo propio, perfil a papelera y configuración compartida sin cambios. Estado final: resuelto.

Repetición V8 (23/10/2026 08:03): un comando ad hoc volvió a comparar cadenas sin normalizar. La guarda bloqueó antes de entradas. Corregido con auxiliar persistente src/close-x3-v8.py y Path.resolve; PID951847/inicio15786781/prefijo comprobados. Diálogo observado, salida0, cero procesos propios y perfil a papelera. Evidencia ModelEditor/evidence/x3-v8/{closure-guard-diagnostic.json,close-confirm.png,closure.json,ydwe-exit.json}. Estado final: resuelto.
