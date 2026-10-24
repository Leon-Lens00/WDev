# Ampliación de evaluación completa de WaveSys

Solicitud vigente: «Continua … pruebas a su contenido» y «evaluación completa completa». Evaluar funciones y conexiones de todo el modo; no limitar el resultado a compilar o a WavePlayerUtils. Diagnóstico y laboratorios autorizados; conservar fuentes originales y no corregir automáticamente los defectos del producto.

Base: copia actual de 114 fuentes, manifiesto original de 162 JASS/PowerShell y migración de 16 consumidores documentada. Classic1.27b; release, JassHelper/pJASS instalados. CodeGraph-first sobre esta raíz, completeInputs=false. Reutilizar resultados anteriores cuando sus hashes y alcance sigan vigentes.

## Cobertura y fases

1. [x] Matriz completa de componentes y APIs, con evidencia por archivo/revisión y estado: fuente inspeccionada, compilada, probado en motor, fallo confirmado, integración pendiente. Incluir dependencias/UI y fuentes experimentales separadas de entradas activas.
2. [x] Ensayo nativo ampliado del núcleo: configuraciones, selección de slots/prioridad/gates/cupos, puntos fijos y cercanos, markers, reservas/efectos, pausa/reanudación, muerte, afiliados, externos, cancelación/destrucción/reutilización, eventos y fin. Conservar los fallos conocidos; añadir sólo hallazgos demostrados.
3. [x] IA y habilidades: perfiles, adquisición, movimiento, pausa, órdenes/caché, teletransporte, proyectiles, refuerzos y limpieza. Probar casos viables con unidades/objetos reales; identificar explícitamente cualquier objeto/import ausente, sin sustituir su efecto por un stub y llamarlo integración completa.
4. [x] Partida e interfaces: oro, selección, daño/crédito/streaks/pickups, vidas/reaparición, descansos/cuenta atrás, tienda, tableros, victoria/derrota. Buscar la base .w3x/.w3m y verificar procedencia/objetos antes de ejecutar el flujo completo. Pregunta de ruta enviada al usuario tras buscar WarDatsPy; continuar lo independiente.
5. [x] Informe completo con matriz, hallazgos priorizados, reproducciones, impacto, recomendaciones y límites. Registrar incidencias reales, verificar hashes, sincronización del índice y cierre de sesiones propias.

## Criterio de entrega

No llamar «correcto» a una función por compilar. Cada bloque tendrá evidencia concreta o un impedimento identificado y siguiente prueba precisa. La revisión completa del código suministrado puede completarse sin certificar objetos/imports externos; la partida completa y multijugador exigen sus propias entradas y ensayos. No inventar cobertura por número de controles ni trasladar PASS entre revisiones.

Estado: evaluación e inventario completados con límites explícitos en docs/evaluacion-completa-wavesys-2026-10-23.md. Las casillas marcan trabajo de evaluación y delimitación realizado, no aprobación de todas las funciones ni cierre de fallos de producto.

Decisiones y resultados: DevMission sólo como fuente de250recursos;246incorporados/verificados en base independiente. Original de81.262.431bytes hash66e0ce9f… intacto. Núcleo features44/2FAIL; integración25/1FAIL; barrera28/1FAIL; habilidades con recursos28/1FAIL; recorrido10waves/518enemigos67/0FAIL y victoria visible. GameplayAPI parcial24/3FAIL,13rutas directas de disparo, selección incompleta. Matriz114fuentes y15hallazgos.

Pendientes de producto/validación: E01–E15 abiertos; selección por clic/timeout y contención de foco; artefactos visuales sin causa aislada; objetos de armas compatibles; combate prolongado/boss/refuerzos, saturación y multijugador. No se corrigen automáticamente las fuentes. Los laboratorios propios se cerraron por identidad; final-audit-verification.json confirma cero motores propios pendientes, hashes originales intactos y114fuentes iguales al último build.

## Alcance posterior: sólo oleadas

2026-10-23T10:03:14.773148-05:00: el usuario restringe el trabajo al sistema de oleadas. Documento vigente: docs/evaluacion-nucleo-oleadas-2026-10-23.md. Prioridades: E13/E03/E02, después E06/E07 y E14/E08; E09 es una decisión de contrato. IA, habilidades, armas, UI y tienda quedan fuera del trabajo activo. No se autorizaron por este mensaje correcciones de producto; no se aplicaron. Se conserva evidencia y se verificó coincidencia de hashes de las fuentes principales con la revisión evaluada.
