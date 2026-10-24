# Dependencia de dibujo del plano Shots Vol. I

- Fecha: 2026-10-22T15:12:23.038855-05:00, agente Codex, proyecto Proyect; diagnóstico de origen de Shots Vol. I, MDX800, destino 1.27b.
- Estado: en recuperación.
- Síntoma/evidencia: el Python de runtime de documentos devolvió ModuleNotFoundError: No module named matplotlib al comprobar el entorno para generar el plano.
- Causa confirmada: matplotlib no está disponible en ese intérprete.
- Impacto: retrasa la generación del plano; lectura de modelos disponible y sin modificar originales.
- Acción: buscar un intérprete existente con matplotlib o preparar un entorno aislado del análisis.
- Verificación pendiente: generar y revisar visualmente el plano con un entorno funcional.

Dependencia recuperada: Matplotlib 3.11.2 y NumPy 2.5.4 instalados en plot-env aislado. El primer intento de dibujo falló porque np.cross ya rechaza vectores 2D en esta versión (ValueError). Es un fallo del código de dibujo, no del modelo ni de las mediciones. Se sustituye por el determinante 2D explícito para filtrar triángulos de área nula. Pendiente regeneración y revisión visual.

## Recuperación verificada

Estado final: resuelto. El entorno aislado plot-env ejecutó Matplotlib y la sustitución del producto vectorial 2D por el determinante corrigió el error del generador. Se generaron plano-original y escala-anclaje en PNG y SVG; ambos PNG se inspeccionaron visualmente con ejes, cotas y rótulos legibles. No se modificó el Python global ni los modelos. [Evidencia de verificación](../../../work/shots-vol-i-origen-20261022/verificacion.json); versiones en plot-requirements.txt en esa carpeta.
