# Laboratorio de colores: contador de retiradas incorrecto

- Fecha: 22 de octubre de 2026, America/Lima; agente principal del chat TerrainDev.
- Entorno: Classic1.27b, JassHelper local, laboratorio ShotColorProbe.j. Estado: corregido pendiente de verificar.
- Síntoma: no compila la nueva copia de laboratorio. La entrega productiva sí compiló y empaquetó antes; no contiene este fixture.
- Causa confirmada: el fixture usó MissileStats.removed, pero el miembro real es MissileStats.retired. JassHelper lo rechazó en la línea4412 del script combinado.
- Evidencia: TerrainDev/reports/shot-colors-20261022/20261022-174606/compile.json y FrozenThone/runtime/wc3-tools/reports/vjass-20261022-174606-429736/jasshelper.log.
- Impacto: no se ejecuta ni valida ese laboratorio hasta corregir/recompilar. No es un defecto demostrado de los misiles ni de los modelos.
- Acción: contrastado el miembro en MissileDiagnostics.j; sustituir las dos referencias de la prueba. Pendiente: recompilar, reextraer y ejecutar el fixture; registrar resultado y límites aquí.

## Recuperación comprobada

Tras usar MissileStats.retired, JassHelper/pJASS y reextracción aprobaron la copia final /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/shot-colors-20261022/20261022-175357. El motor ejecutó40 controles con0fallos,23instancias creadas/retiradas y0activas. Estado: resuelto. La evidencia de compilación fallida se conserva; no se atribuye al producto.
