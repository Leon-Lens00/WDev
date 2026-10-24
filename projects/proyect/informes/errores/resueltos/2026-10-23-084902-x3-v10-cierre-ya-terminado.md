# Cierre de prueba ya terminada
Fecha:2026-10-23. Agente:/root. ModelEditor V10, CachyOS/Warcraft1.27b.
Estado: corregido pendiente de verificar auxiliar idempotente.
Síntoma: tras observar confirmación de salida, close-x3-v10.py confirm encontró ausente /proc/978078/stat y lanzó FileNotFoundError. No envió tecla.
Causa confirmada: proceso ya terminado antes de la segunda llamada. No se conoce quién confirmó/cerró durante ese intervalo.
Impacto: ninguno sobre modelo o partida ajena; guardas evitaron entrada global. Lanzador terminó0, cero procesos del prefijo, ventana ausente. Perfil propio enviado a papelera.
Acción: auxiliar admitirá proceso/ventana ya terminados como cierre consumado, sin enviar teclas; PID reciclado seguirá rechazado por inicio.
Evidencia: ModelEditor/evidence/x3-v10/ydwe-exit.json, closure.json, close-confirm.png.

Verificación: repetir confirm con el PID ausente devolvió0, alreadyClosed:true,inputSent:false; ventana ausente. Estado:resuelto.
