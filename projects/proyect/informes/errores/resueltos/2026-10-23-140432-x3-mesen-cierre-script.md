# MesenCE2.2.1: cierre de script discrepante en la ayuda

- Fecha/agente: 2026-10-23T14:04:32.374691-05:00, agente principal X3.
- Entorno: CachyOS, MesenCE2.2.1 Linuxx64 portable, commit20ba206…, ROM USA verificada, laboratorio TerrainDev/labs/x3-snes.
- Síntoma: boot-original creó complete.txt y cinco capturas, pero el proceso salió255 al timeout40s. process-result.json acredita own_process_closed=true, sin proceso propio residual.
- Causa confirmada documental: CommandLineHelper.cs instruye emu.exit para testRunner, pero LuaDocumentation.json de la misma release documenta emu.stop. Nuestro boot.lua empleó el nombre de la ayuda.
- Impacto: arranque/capturas reales producidos; no se acredita cierre voluntario ni medición del disparo todavía. No cambia ROM, mapa ni configuración global.
- Acción: sustituir por emu.stop(0), repetir y exigir salida0 con complete.txt. Aplicar depuración sistemática sin ampliar cambios.
- Estado: corregido pendiente de verificar.
- Evidencia: TerrainDev/labs/x3-snes/runs/boot-original/{console.txt,process-result.json,complete.txt}, upstream/{CommandLineHelper.cs,LuaDocumentation.json}.

## Segundo límite del bootstrap: entrada no aplicada

La ejecución enter-original salió0 y avanzó4800frames, pero sus capturas continuaron en la introducción pese a los Start programados. Fuente de la misma release: SnesConfig.Port1 crea configuración vacía; InitializeDefaults asigna SnesController sólo en el asistente que se evitó para mantener portable/headless. El laboratorio debe declarar Port1.Type explícitamente y comprobar que getInput contiene start antes de atribuir validez a una secuencia de control. No hay todavía evidencia de disparos. Se corrige configuración propia, sin tocar ROM ni instalar ajustes globales. boot-original-stop ya acredita recuperación del cierre: salida0,4.83s, proceso cerrado.

## Recuperación comprobada del bootstrap

enter-original-controller declara Snes.Port1.Type=SnesController y valida getInput.start. Salida0,4800frames, captura llega al diálogo inicial con X/Zero. scene-original avanza diálogo por B y alcanza juego libre: frame6000 muestra X quieto, menú0, lock0. ready-original intentó guardar en CPU008104, pero el hook no fue observado en60frames y salió3 de forma controlada, sin ready.mss. Esa dirección era el PC de espera mostrado por getState, no una instrucción demostrada como ejecutada. Estado guardado aún no acreditado. No se tomó ausencia de fallo como prueba del disparo: las trazas de proyectil son la fase siguiente.


## Guarda de creación de estado

El control previsto devolvió3 porque no observó el punto de guardado, y evitó publicar un estado inexistente. Se investiga la dirección realmente ejecutada alrededor del bucle WAI; no es prueba de fallo del juego. Las capturas y cierre anteriores siguen válidos. No se continuará con carga de estado hasta tener un archivo real y una carga comprobada.


El desensamblado de la ROM identifica LDA $09CE en $008103; $008104 es su operando. Hook corregido al inicio real de instrucción. ready-original-fixed salió0 en27.15s, generó ready.mss dentro del callback y dejó proceso cerrado. La siguiente fase comprobará su carga y el disparo completo.


## Cierre final

- Estado: resuelto. Emu.stop recupera salida0; Port1.Type explícito y getInput validan mando; $008103 permite crear ready.mss real. Se guardaron estados independientes original/mod y ambos cargaron durante ejecuciones completas.
- Seis casos finales con snapshots de script y hash: final-original, final-mod, final-original-left, final-mod-left, final-original-gap20, final-mod-gap20. Todos salida0 y proceso cerrado. Seis fusiones/cinco cuerpos cada una; 4880 valores de posición/velocidad frente a bloques aislados, cero discrepancias. A frame640 no quedan cuerpos relevantes activos en ninguno.
- Las limitaciones del primer arranque ya no bloquean. Las pruebas cubren una escena y configuración, no hardware SNES ni toda la lógica del juego. El mapa Warcraft no cambia.
- Evidencia final: TerrainDev/labs/x3-snes/analysis/native-comparison.json y closure.json. Recuperación registrada sin eliminar los logs/capturas de error iniciales.
