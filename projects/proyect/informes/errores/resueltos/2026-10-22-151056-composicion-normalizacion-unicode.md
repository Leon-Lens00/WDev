# Regresión de normalización Unicode durante composición

Fecha: 2026-10-22 15:10:56.389417; UI Studio diálogo, chat actual.

Síntoma: Node 25/27; el compositor normalizaba `a + acento combinante` a `á`, alterando el texto original. Causa confirmada: normalize(NFC) en el wrapper. Corregido: normalizar sólo al medir, conservar los grafemas originales al componer/revelar. La otra expectativa antigua dependía del corte a36caracteres, sustituido por prueba explícita de cuatro renglones.

Estado: resuelto. Suite ampliada con conservación, fragmentos y pool: véase work/dialogue-composition-20261022/node-suite.log.

El auxiliar de navegador también esperaba el rótulo Completar frase después de que la animación había terminado: selector agotado sin cambiar estado. Se observó captura completa y se usan controles de edición estables. No indica fallo del reproductor.
