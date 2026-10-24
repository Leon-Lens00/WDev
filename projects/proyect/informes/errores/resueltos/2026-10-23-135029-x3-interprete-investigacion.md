# Intérprete acotado de investigación X3: instrucción ausente

- Fecha: 2026-10-23-135029, America/Lima.
- Entorno: CachyOS/Python3, TerrainDev, evaluación de ROM original y Zero Project; ninguna fuente productiva ni mapa modificados.
- Estado: resuelto; recuperación comprobada.
- Síntoma/evidencia: `evaluate_motion.py` terminó con `ValueError: unimplemented 05 at 81c5c7`, durante inicialización real extraída de la ROM USA SHA25665b03268…
- Reproducción: ejecutar el script de esta evaluación. Primera ejecución, sin resultados de trayectoria publicados.
- Impacto: impide acreditar la comprobación aislada; no afecta al mapa ni demuestra defecto de la ROM/mod.
- Causa confirmada: el intérprete deliberadamente acotado no incluía ORA directo, usado para configurar paleta/dirección. No es una instrucción de física nueva.
- Acción: implementar ORA directo con ancho M; repetir recorridos y comparación con recurrencia independiente. Se aplica systematic-debugging: reproducir, identificar la instrucción y comprobar recuperación.
- Evidencia: `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-rom-evaluation-20261023-134543/evaluate_motion.py`.

## Comprobación de recuperación

La misma ejecución inicial completó las 20 combinaciones (original/IPS, cinco cuerpos y dos orientaciones), 120 pasos cada una: 2400 pasos coinciden campo a campo entre instrucciones ROM y recurrencia derivada para vx, vy, x e y. Inicialización de velocidades y aceleraciones también contrastada. `isolated-checks.json`, `motion-isolated.csv` y `motion-metrics.json` conservan evidencia. Repetición final usa ruta relativa al propio script; no depende de /tmp.

Límite: intérprete de bloques enteros aislados; no reemplaza una traza completa de SNES ni acredita colisiones/animación/cadencia del juego. La ausencia de ORA era del útil de investigación, sin defecto demostrado en producción.
