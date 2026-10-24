# InventorySys: proyección durante movimiento

Fecha: 2026-10-22T16:37:05.068835-05:00. Proyecto: TerrainDev/inventory-integration, Classic1.27b. Estado: abierto, en investigación.

Original141 SHA a1b65723… coincide con la descarga reciente y con el mapa ejecutado por el usuario (PID628515). Integración6cea157b… en instancia propia629638 desplaza/recorta el equipo mientras se camina; original mantiene marco estable en muestra de movimiento. Evidencias work/inventory-original-audit-20261022/original-moving-*.png, integrated-moving-*.png y TerrainDev/dialogue-system/evidence/inventory-audit-equipped.png.

Dummy uidm y modelos/texturas UI originales idénticos a nuestra integración; principal cambio candidato es Camera.win2World .eye→GetCameraEyePosition*. Otras diferencias locales constan en diffs del mismo directorio. Comparación estática no demuestra causalidad individual. Preparado Camera-AB.w3x con dos ramas seleccionables -audit-original/-audit-local dentro de una misma partida, compilado JassHelper/pJASS y script reextraído/miembros conservados. Sólo es laboratorio: WCT retiene fuentes de entrega; la alternancia está en el JASS generado de esta copia. Entregas y fuentes no modificadas.

Contraste A/B en TerrainDev, PID631592: -audit-original hace desaparecer panel; -audit-local vuelve a mostrarlo en el mismo lugar, de forma repetible (camera-ab-original-still/original-repeat/local-still.png). Esto confirma que la proyección modifica la visibilidad en el terreno integrado y que revertir tres líneas no basta como arreglo general. No demuestra todavía que esa única modificación explique la diferencia en movimiento frente al mapa original, porque cambia también el terreno entre ambos mapas.

## Causa acotada por contraste en la demo original

Copia OriginalDemo-Camera-AB.w3x (40736c1f…), PID634043. Conserva todos los miembros
originales salvo war3map.j; cabecera, objetos, modelos, terreno y texturas exactos.
El JASS alterna sólo el origen de win2World (.eye frente a GetCameraEyePosition*)
y añade los dos comandos de diagnóstico. pJASS y reextracción verificadas.
Original: capturas demo-original-moving-1..3.png mantienen el marco completo en
su ancla. Local: demo-local-moving-1..3.png reproducen desplazamiento y recorte
superior. Restablecer original recupera el marco (demo-original-recovered.png).
Esta prueba implica directamente el cambio de origen de proyección en el fallo
observado. No se instrumentó el tiempo interno de render: explicarlo como mezcla
de cámara lógica/renderizada es una interpretación, no una medición de latencia.

La afirmación anterior de que bastaba explicar el problema por el dummy era
incompleta. uidm no fue alterado en la integración y sus recursos UI son idénticos.
El diálogo tiene además un dlog propio y cambios adicionales; no se trasladan a él
estos resultados como solución ya aplicada. Sigue pendiente corregir la proyección
conservando visibilidad/altura en TerrainDev. No se cambian fuentes ni entregas en
esta auditoría. Estado: causa de regresión acotada, corrección pendiente.

Las tres partidas propias629638/631592/634043 terminaron con S tras confirmación
visible; sin SIGTERM. El usuario tenía628515 abierta en otro prefijo: no se cerró
por el agente. Al intentar devolverle foco al final, /proc/628515 ya no existía;
el guard de identidad rechazó la acción. No se presume causa de su salida ni crash.

## Recuperación comprobada — 22/10/2026

Restauradas tres componentes de win2World a eye original; altura del controlador calibrada una vez trasaplicación inicial. Error de referencia -22.789 pasa a0.000 en targetZ de cuatro registros. Inventario d523040e probadoPID640845 con ambos marcos, movimiento real y cierre/reapertura; diálogo5777003b probadoPID639115 en dos zonas/reinicios/rojo/azul. No se reproduce recorte grande anterior. Informes y logs: work/camera-restore-20261022/RESTAURACION.md y result.json. Compilación/pJASS/reextracción PASS, juegos terminadosconS. Estado: resuelto para regresión de proyección a1920×1080 SP; no acredita LAN ni exactitud subpíxel. Diálogo mantiene limitación residual≈1px en su incidencia propia.
