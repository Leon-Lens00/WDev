# X3: regresión atendida pausada y validación anticipada

- Fecha:22/10/2026 America/Lima. Agente raíz,TerrainDev Classic1.27b CachyOS/Wine/Hyprland.
- Síntoma: RapidFireProbe conserva PROGRESSstage9 al perder el foco. La ventana propia esPID771030/prefijoTerrainDev/build/x3-runtime/pfx; se observaron otras partidas activasPID773549 y775075. No se modificaron ni cerraron.
- Causa: play individual puede pausar fuera de foco; esa limitación ya estaba documentada. No es un fallo demostrado de la habilidad ni se afirma continuidad independiente del foco.
- Incidencia secundaria: se invocó verify_x3_probe.py mientras todavía faltaba rapid-engine.txt, pese al estadoPENDING. FileNotFoundError; no se emitió PASS. Causa confirmada: llamada anticipada del agente.
- Acción: retomar únicamente la ventana propia para terminar la prueba atendida. Añadir guard al verificador: si faltan logs, indicar Laboratory incomplete antes de leerlos. No reemplazar el ensayo ni introducir LAN/pausas artificiales dentro del mapa.
- Estado: pendiente de recoger COMPLETE y validar. Evidencia:reports/x3-buster-20261022-201342/20261022-204528, logfrescoTerrainDev-20261022-204528-rapid.txt.

## Recuperación

RapidFireProbe finalCOMPLETE:44checks/0failures,observed46,minimum0.250,emitted63,live0,pairs2. El verificador final aprueba54X3+40colores+44RapidFire=138controles y rechaza14mutaciones negativas. Los logs nuevos comparten hash de producción4d4c0b227db9ed30edb4dbdcf233dca616a7fd0d62e4f7283312a60351e2a93a. Estado: resuelto. La pausa fuera de foco sigue siendo limitación conocida del modo individual; no se acredita continuidad ni multijugador.

## Captura y cierre final

La captura nueva se detuvo por su guard: la ventana propia pasó de1920×1080 en3840,0 a una ventana en4084,165; otra sesión cambió foco/workspace. No se produjo una demostración nueva con ese intento. El menúF10/F/A no ofreció una confirmación verificable en la captura. Al preparar el cierre de respaldo, /proc/771030/stat ya había desaparecido: la comprobación detuvo el script antes de cualquier señal. Verificación posterior: PID y ventana propios ausentes; no se usó SIGTERM. No se atribuye una interacción de salida no observada. En la verificación final quedan las partidas775075 y778805; no se enviaron entradas ni señales de cierre a esas partidas. Evidencia:closure.json de la ejecución final. Estado final: resuelto para esta tarea; limitación de captura/foco documentada.
