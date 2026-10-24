# Calibración de las uniones de fragmentos

Fecha: 2026-10-22 15:16:31.072047; Classic1.27b, UI Studio compartido, agente chat actual.

Estado: en investigación.

El primer ensayo del pool de14tags muestra espacios excesivos entre fragmentos de un renglón. Evidencia: TerrainDev/dialogue-system/evidence/composition-initial.png, PID584835, mapa identificado por isolated-launch.json (conservar manifiesto de esta ejecución). Causa confirmada: avances TTF usados para colocar el fragmento siguiente son mayores que los avances del renderer nativo en varias letras; el tamaño nativo se mantiene. El marco también presenta el recorte conocido de la incidencia130405; es independiente de las posiciones de fragmentos.

Acción: usar el pool existente para medir avances por glifo en una misma sesión, incorporar ese perfil al editor y al builder y volver a comprobar uniones. No afirmar equivalencia nativa a partir del TTF.

Primer capturador de métricas: diez pantallas sin texto; no acreditan medidas. Se había detenido el reloj de proyección al cerrar la conversación y no se refrescaban los UIText al cambiar de cámara. Se añade actualización continua de cámara/UIText en el modo de laboratorio; causa de invisibilidad aún a contrastar. El primer juego se cerró con confirmación S, proceso584835 terminado.

Recuperación comprobada: perfil nativo111glifos obtenido en metrics-final-00..09.png (no usar metrics2-01..09, repetían página1: flecha derecha deshabilitada por UI; Esc sí avanzó y las diez páginas finales son distintas). El ciclo de cámara/UIText corrige la invisibilidad del laboratorio. Avances por autocorrelación acotada, _=15px por120px/8; datos y script reproducibles native-glyph-metrics.json y tools/measure-glyphs.py. Modo compacto conserva la misma altura0.027 para reutilizar ese perfil con tamaño legible.

Estado final: resuelto para las uniones observadas. Capturas composition-final-wide.png y composition-final-compact.png, PID592225: renglones continuos, sin los huecos de composition-initial.png. No certifica todos los pares de kerning, otras resoluciones o alturas interpoladas. El recorte y desalineación del marco continúan en la incidencia130405. Juegos584835,589024y592225 cerrados conS y proceso terminado, sinSIGTERM.
