# X3: control de facing a distancia cero

- Fecha:22/10/2026 America/Lima. Agente raíz, TerrainDev vJASS/Classic1.27b CachyOS/Wine.
- Revisión: mapa entregable9eb1cc5c7bd17514a3c0ee416d1fbb565f31468a60b943a6d6101550b437394e, laboratorioc2081b25e64b415c0b774d02b59793e8b8478f485fdbb19a4c2d4730dd416a05.
- Síntoma: X3Probe marca FAIL zero-distance aim falls back to unit facing. El caso llama SetUnitFacing(source,90) y exige90 inmediatamente sin observar GetUnitFacing.
- Evidencia: /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-buster-20261022-201342/20261022-202306/x3-engine-first.txt. Los casos previos de trayectoria, órbita, unión, impactos, MUI y limpieza pasan.
- Hipótesis: el motor no ha terminado el giro al consultar inmediatamente, por lo que el fixture compara un objetivo solicitado con un valor actual distinto. Falta instrumentar ambos valores; no se atribuye aún al producto.
- Impacto: ensayo no aprobado; no presentar PASS total hasta recuperar el caso. No se cambian núcleos ni física para acomodar la prueba.
- Acción: esperar un paso de motor, registrar GetUnitFacing y ángulo del lanzamiento; repetir en copia nueva con las mismas fuentes productivas.
- Estado: en investigación.

## Medición de la hipótesis

Segundo laboratorio629f062787723901797e0fcd86aef9f2c3d5c6dbc4e0ede43f7234ab659e0924: facingImmediate=0.000, facingSettled=34.950 tras0.125s y fallbackDegrees=0.000. Esto confirma que el disparo usa el facing actual correctamente y que el giro nativo no es instantáneo. El nuevo control que exigía90 tras0.125s vuelve a fallar por la misma premisa del fixture. Se espera0.5s, superior al tiempo de giro observado, antes de verificar el destino90. Fuentes productivas intactas.

## Recuperación verificada

Laboratorio finalcf71ef31949c289c1296dab6ba432bc834f842255a48fad8a16008e9876222b0, mismas fuentes productivas:51checks/0failures; facingImmediate0.000, facingSettled90.000 tras0.5s, fallbackDegrees0.000. El disparo usa el facing actual; los dos fallos previos fueron expectativas de giro instantáneo/demasiado breve del laboratorio. Se añadieron controles reales de órdenes W/E a través del controlador: ambos activan la física y el ejecutor no recibe orden de habilidad.182cuerpos creados/retirados, cero activos/secuencias/flashes finales. Estado final: resuelto. Evidencia/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-buster-20261022-201342/20261022-203103/x3-engine.txt.
