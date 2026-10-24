# QA de la vista de conversaciones — 2026-10-22
Fuente: captura suministrada 1202x545 y vídeo recording_2026-10-22_12.40.44.mp4. Comparación conjunta: /home/snz/Documentos/ChatGPT/Proyect/work/dialogue-studio-20261022/comparison.png.
Resultado del prototipo web: PASS para diseño y reproducción, sin P0/P1/P2 abiertos en el alcance web.

Se comprobó visualmente la silueta angular, dos retratos, nombre subrayado, texto rojo/azul por personaje, paginación y estado de avance. Retratos provisionales proceden de la referencia; el marco vacío se preparó con ImageGen. La tipografía es aproximada. Fondo de terreno usa una captura existente, sin simular una ejecución nueva de Warcraft.

Flujo en IAB: reiniciar muestra un prefijo corto, pausa conserva exactamente el texto, completar muestra la página entera, siguiente pasa a X/panel azul. Selector de mensaje, retorno al editor anterior, descarga Guardar JSON y consola sin errores verificados. 23 pruebas Node correctas, incluyendo las 16 del editor anterior.
A 640x850 se detectó NAV hasta705px y se corrigió a dos filas. Repetición: viewport640, scrollWidth625, controles visibles. Tamaño habitual restaurado. Evidencias editor-red.png, editor-blue.png, editor-final.png, editor-640.png en la carpeta de comparación.

La geometría, tipografía y escala real en Warcraft tienen su ensayo separado en TerrainDev/dialogue-system/evidence. Este PASS web no acredita ese resultado, la exportación automática W3X, animación labial ni multijugador.


Actualización14:25: vista Warcraft de captura con guías, equivalencia del plano y proyección del modelo. Comparación de dos capturas reales por opacidad. El lienzo completo cabe en el panel a1280×720. Edición real de ancho95→91.5, profundidad400→1200→400, centroY-.49→-.30→-.49 observada en DOM/readout. Exportación DialogueProjection.j descargada y comparada idéntica con la fuente del build;27/27pruebas Node. El ajuste de captura sigue provisional porque otra posición del mapa se recorta; no es un emulador del motor. Sin nuevas ejecuciones del juego para estos ajustes. Tipografía aproximada y exportación parcial de diseño explícita.
