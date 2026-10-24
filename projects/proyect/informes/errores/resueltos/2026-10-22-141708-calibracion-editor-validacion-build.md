# Validación y preparación del perfil del diálogo
Fecha:2026-10-22 14:17 America/Lima; agente de UI Studio/TerrainDev-dialogue-system. Estado: correcciones aplicadas pendientes de repetir.
Al añadir pruebas al perfil, 26/27 pasaron: calibration:null se trataba como proyecto antiguo en vez de rechazarse. Se distingue ausencia de propiedad (migración) de null explícito (rechazo).
El builder intentó preparar el JSON usando el wrapper de comandos Warcraft con subcomando node no admitido; abortó antes de compilar/empaquetar. Log: TerrainDev/dialogue-system/build/20261022-141708-611020/prepare-design.json. Se ejecuta Node directamente mediante subprocess, conservando comando/código/salidas y abortando si falla.
Impacto: primer ensayo de la nueva integración rechazado; mapa anterior conservado. Pendiente repetir27pruebas y construcción con JassHelper/pJASS/reextracción.

Recuperación comprobada:27/27pruebas Node PASS. Build20261022-141729-284004, mapa SHA256f76b2e573519ab1bcd893912981dd1242fad9a7d8d451d347e1f527d1d6e66bc: JassHelper release y pJASS PASS; cabecera y miembros conservados por reextracción. Proyección JASS descargada del navegador idéntica byte a byte a la fuente consumida por el builder. Estado final: resuelto. No se relanza el juego; el recorte nativo se conserva en la incidencia principal abierta.
