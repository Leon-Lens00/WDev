# Color rojo y sentinel null en Classic1.27b

- Fecha: 2026-10-22T17:52:40.005410-05:00; agente principal, integración TerrainDev ShotsTeam.
- Estado: en investigación/corrección.
- Revisión: entrega candidata3f8c1aada0ad82e27eab1fe3feeee46f2673d33c773a296bb0120ab6df741a04; laboratorio c3ff128a85dc1c7b65e806bd314cae88010050a6f1ea22d84b1f1fe864755f10.
- Síntoma:40 comprobaciones de colores completadas,39PASS/1FAIL. La prueba esperaba modelForColor(null)=gris, pero el motor seleccionó rojo.
- Evidencia: TerrainDev/reports/shot-colors-20261022/20261022-175007/colors-engine.txt. Todos los colores explícitos0..11, reciclaje, intervalo y retorno owner pasaron.
- Causa: PLAYER_COLOR_RED corresponde al valor enum0 y se compara igual a null en este runtime. El setter nuevo usa null como ausencia de override: por ello puede confundir un override rojo explícito con color del propietario. La expectativa de fallback de la prueba era también incorrecta para null; colores fuera0..11 sí usan gris.
- Impacto: unidades cuyo propietario no sea rojo podrían no obtener el misil rojo al pedir ese override. No afecta al radio/daño/temporización y no es un defecto de los modelos.
- Acción prevista: booleano explícito para presencia de override; clearColor() separado para restablecer owner. setColor(PLAYER_COLOR_RED) debe permanecer un override válido. Retirar contrato null-reset, imposible de distinguir del rojo con ese enum.
- Verificación pendiente: caso en motor con propietario naranja y override rojo; conservar vuelo anterior y cambios de propietario/recast; repetir todo el laboratorio y regresión Rapid Fire. No se considera aprobada esta revisión.

## Recuperación comprobada

RapidPair usa hasTint independiente y clearColor(). El laboratorio final /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/shot-colors-20261022/20261022-175357 ejecutó40controles/0fallos: propietario naranja con override rojo, vuelo antiguo rojo conservado tras recast rosa, clearColor con owner amarillo, equipo verde, cambio de propietario púrpura, escala en dummy reutilizado, intervalo mínimo y retirada23/23. Se corrigió también la expectativa sobre null=rojo. Estado: resuelto en Classic1.27b local; no prueba multijugador.
