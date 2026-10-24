# Contrato observado de Missile 2.5.1

Referencia elegida por el usuario: [hilo original de BPower](https://www.hiveworkshop.com/threads/missile.265370/). Copia del bloque principal guardada el 20-10-2026 en [Missile-BPower-2.5.1-hive.j](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/bibliotecas/Missile-BPower-2.5.1-hive.j>). La [procedencia](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/bibliotecas/procedencia.json>) contiene hashes y comparación con los núcleos de las demos.

Este contrato corresponde a ese código, no a todas las bibliotecas llamadas Missile. Comprobar la revisión y configuración del mapa antes de aplicarlo. La copia independiente no se ha recompilado ni probado en juego en esta descarga.

## Movimiento y coordenadas

- `speed` representa desplazamiento XY por paso. `setMovementSpeed(v)` lo convierte desde unidades/segundo multiplicando por `Missile_TIMER_TIMEOUT`; la configuración publicada usa `1./32.`. `flightTime2Speed(t)` usa distancia restante, periodo y duración, sin compensar aceleración (líneas 632–637).
- `acceleration` se suma a speed cada paso; `turn` limita el cambio angular por paso. No introducir directamente unidades/segundo² o grados/segundo en esos campos. Si se cambia el periodo, revisar a todos los consumidores que asignan estos valores directamente.
- Angles, arc y curve usan radianes; no pasar PI/2 a arc/curve. Los parámetros Z de `MissilePosition.move` son relativos al terreno del punto; el método añade `Missile_GetLocZ`, y los campos de posición origin/impact almacenan Z absoluto (1696–1702). El Z de vuelo del misil y `terrainZ` se combinan al necesitar altura absoluta, como en FistOfThunder. Evitar sumar el terreno dos veces.
- Al guiar hacia `target`, el bloque de movimiento vuelve a situar origin/impact y pone `height = 0` y `curve = 0` (810–820). Asignar `target` no conserva un arco o curva independiente. Para pedir ambos, diseñar una trayectoria por coordenadas o una modificación acotada, considerando los consumidores; no prometer esa combinación con sólo dos asignaciones.

## Impactos y finalización

- La elección círculo/rectángulo depende del paso de speed y del radio multiplicado por `COLLISION_ACCURACY_FACTOR` (800–807). Aumentar velocidad puede cambiar la ruta de detección, no sólo la duración. El filtro Z y las funciones de tamaño corporal afectan los resultados.
- La memoria de aciertos se actualiza antes de llamar al callback de unidad (1554–1565), incluso si éste rechaza el blanco devolviendo false. Inspeccionar `hasHitWidget`, `removeHitWidget`, `flushHitWidgets` y `enableHitAfter` según la mecánica; no suponer que false significa “no registrado”.
- En `missileIterateP` (1528–1615), la retirada pendiente se procesa primero; después vienen unidad, destructable, item, finish, terreno y period, con comprobaciones de allocated. Una colisión que retira el misil puede impedir finish/period de ese paso. No basar cleanup en que onFinish se ejecute siempre.
- En los callbacks de acción, true solicita la retirada por el módulo y false continúa. **`onRemove` tiene otra semántica**: su retorno controla reciclaje diferido/inmediato cuando la configuración lo permite (1456–1472). No devolver true ahí pensando que evita una segunda explosión.
- Sin callback onFinish, alcanzar el destino retira el misil. Con onFinish propio, éste decide; continuar sin definir un nuevo recorrido o fin puede dejar la instancia viva. Comprobar el contrato de alcance de la habilidad.

## Rutas de retirada: diferencia entre API y documentación

El texto de la API dice que onRemove siempre corre al destruirse. La implementación distingue:

1. Retirada a través de `MissileTerminate.missileTerminateP`: llama a onRemove, termina el núcleo y actualiza la contabilidad del struct (1456–1472).
2. `missile.destroy()`: marca wantDestroy; el siguiente paso del módulo entra en la ruta anterior.
3. **`missile.terminate()` directo**: libera el núcleo (646–672) sin pasar por onRemove ni por StopPeriodic del wrapper. No atribuirle el cleanup de la habilidad.

Para una habilidad ya lanzada, preferir la retirada del módulo por el retorno del callback o `destroy()` para una cancelación diferida. Si se requiere retirada inmediata por otra ruta, inspeccionar el wrapper real y demostrar que libera los datos y actualiza sus colecciones/contadores. Evitar recursión de retirada desde onRemove y uso del índice después de liberar.

Si onRemove genera hijos o aplica daño, decidir qué causas de retirada permiten esos efectos y distinguirlas mediante estado propio. La limpieza de recursos debe mantenerse aunque una causa cancele la explosión. Inicializar el estado que los callbacks necesitan antes de lanzar; no depender de un retraso implícito del timer.

## Configuración del mapa

Verificar `DUMMY_UNIT_ID`, modelo dummy, habilidades Aloc/Amrf, límites del mundo, funciones de tamaño corporal y librerías opcionales. El código admite distintas rutas de reciclaje e indexación: comprobar cuál se compila realmente en el mapa. La edición GUI y la continuación de AGD son componentes/versiones distintos; no sustituir este núcleo para resolver una diferencia de API sin comprobar el parche y los consumidores.
