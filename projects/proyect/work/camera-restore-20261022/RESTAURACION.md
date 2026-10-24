# Restauración de proyección y altura de cámara — 22/10/2026

Solicitud: restablecer el comportamiento original durante movimiento y resolver la cámara por otra vía. Objetivo Classic1.27b, copias Inventory y Dialogue; TerrainDev principal y originales descargados intactos.

`win2World` vuelve exactamente a `.eye.x/y/z`. SCREEN_WIDTH=.544, SCREEN_HEIGHT=.302, distancia/ángulos/ejes originales conservados. Se retiene la reparación independiente de destroy/deallocate. No hay lecturas GetCameraEyePosition en proyección.

La prueba sin calibrar midió objetivo lógico240.043 contra objetivo nativo217.254: -22.789; el error se repitió en ambas zonas. `DeltaZ` inicial196.776 proviene del punto CHECK_DELTAZ del ejemplo, mientras el controlador fijo de esta copia tiene base efectiva173.987. No se iguala esta base a GetLocationZ de un punto: la cámara tiene su propia referencia. Evidencias `before-DialogueProjection-1..3.txt`. La captura restore-zone1 muestra por qué alturas inconsistentes separan texto a profundidad101 del marco a400.

La alternativa es `Camera.calibrateHeightForPlayer(p)`, optativa: una sola medición local tras aplicar el controlador y esperar0.1s. Guarda targetZ-ZOFFSET por jugador; applyCameraForPlayer resta esa base al z lógico. El dato local sólo decide campos de cámara dentro de GetLocalPlayer; no alimenta posiciones de unidades, texto, asignación de handles ni lógica sincronizada. El resto del movimiento sigue por Camera.eye. Sin invocar calibración, se conserva la ruta DeltaZ original. Start del diálogo y de la copia Inventory llaman una vez tras preparar la cámara. No hay realimentación por tick ni constantes visuales nuevas.

Después: targetZ coincide con logicalAt.z a precisión de R2S en cuatro diagnósticos de zonas diferentes; marco y texto permanecen juntos. Escritura, variantes roja/azul, reinicio repetido, cierre y ambas zonas observados en PID639115. En cuatro capturas durante movimiento el borde inferior ocupa736..738, salvo última735..737: variación1px. Existe residual de eye lógico en z hasta0.138 unidades en estos logs; no se afirma inmovilidad perfecta ni ensayo de larga duración. No se cambia setPosition original para eliminar ese residual en esta tarea.

Inventory PID640845: ambos marcos visibles, caminata real por clic derecho (inventory-real-moving-0..4 cambia terreno/posición) y toggle cierre/reapertura, sin deriva grande ni recorte superior. Catálogo/equipado de objetos no ensayado exhaustivamente; la muestra Inventory sigue siendo referencia y está desactivada en Dialogue.

Builds: ver `result.json`/`final-equivalence.json`. Mapa diálogo5777003b… byte idéntico entre versión probada y reconstrucción final con inventario nuevo;61miembros iguales y cabecera igual. Inventario d523040e… Ambos JassHelper release, pJASS y conservación/reextracción correctos.35/35pruebas del editor. Sus referencias warcraft-unit-camera/warcraft-unit-hud se sustituyen por calibrated-moving-3/calibrated-closed, conservando capturas previas aquí. Sin retocar composición ni calibración geométrica del editor. Servidor4317 responde200.

CodeGraph consultado antes/después en inventory-integration (Camera/CalibrateCameras) y dialogue-system (CalibrateCamera/FollowCamera/Dump), sin fallos de vigencia. completeInputs false y dispatch/macros candidatos siguen siendo límites estáticos; no sustituyen pruebas del motor.

PIDs637864 (control sin calibrar),639115 y640845 cerrados con confirmaciónS observada; procesos ausentes, sinSIGTERM. La partida anterior635739 ya no existía antes de iniciar. Sin multijugador, otras resoluciones, compacto nuevo ni roundtrip NewGen. La regresión grande de proyección se considera recuperada en los escenarios anteriores; calibración visual fina del diálogo continúa como limitación.

Consulta adicional de fuente primaria: autor de [GetCamOffset en Hive](https://www.hiveworkshop.com/threads/system-getcamoffset.131434/) describe la referencia de altura de cámara sobre terreno. Sólo contexto; las cifras y la corrección se comprobaron aquí en el motor.
