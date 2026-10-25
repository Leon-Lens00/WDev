# Evaluación centrada en el sistema de oleadas

Alcance vigente por indicación del usuario: configuración y ejecución de `Wave`, slots, cantidades, prioridades y gates; registro de puntos mediante marcadores; aparición fija/cercana y efectos; reservas/cupos; unidades normales y externas; eventos, pausa, terminación y reciclaje. Entorno: Warcraft III Classic1.27b.

Las observaciones de IA, habilidades, armas, selección, tienda e interfaz permanecen en el informe amplio como antecedentes, pero no se usan para juzgar el núcleo. El error de compilación E01 pertenece al conjunto completo de fuentes, no al núcleo aislado que sí compiló en sus laboratorios.

## Dictamen del núcleo

La generación normal funciona: captura y retira marcadores, registra coordenadas, reserva cupos antes de materializar, crea unidades y descuenta muertes normales. Los problemas importantes están en las rutas excepcionales de ciclo de vida y en algunos contratos de la API. No está listo para depender de cualquier combinación de retiro, destrucción, reciclaje o evento anidado.

Fuentes principales: `src/WaveSysAnAI/SwlsWave/SwlsWave.j` —biblioteca `WaveTest`—, `WavePointGroups.j` y `WavePointApi.j`. Dependencias directas de `WaveTest`: Table, TimerUtils, SwlsMath y TheEnd. El registro independiente WavePlayerUtils se mantiene como soporte de jugadores allí donde sus consumidores lo utilicen.

**Límite de aislamiento:** TheEnd es una dependencia real del núcleo actual. En los laboratorios aislados se aporta `endF` vacío y se usan callbacks finales vacíos; prueban los contadores, eventos y destrucción, pero no el coordinador de partida. Reemplazar ese conector para independizar el producto sería un cambio posterior de interfaz, no una corrección ya aplicada.

## Hallazgos que sí pertenecen a oleadas

| Prioridad | Hallazgo | Consecuencia demostrada |
|---|---|---|
| P1 · E13 | Un timer pendiente modifica una Wave reciclada | Una instancia nueva con2 pendientes pasa a3 al vencer una reserva antigua. |
| P1 · E03 | `RemoveUnit` no reconcilia los activos | La wave conserva un enemigo que el motor ya retiró y no termina, tampoco mediante `terminate(true)` en el escenario probado. |
| P1 · E02 | Local de slot sin inicializar al morir una unidad externa | Se interrumpen la notificación y limpieza de esa muerte; el contraste generado con `s=0` recupera esa ruta. |
| P2 · E06 | No se restaura el contexto después de eventos anidados | Start→Pause deja Wave=0 para el siguiente listener del Start exterior. |
| P2 · E07 | Limpieza de Table con tipo incorrecto | Se borra el entero donde se había guardado un handle; la referencia sigue almacenada. No se midió una fuga ilimitada. |
| P2 · E08 | Aplicar puntos informa más inserciones de las realizadas | Grupo2 + Wave con99 puntos: devuelve2, pero sólo añade1 por el límite100. |
| P2 · E14 | Se aceptan prioridades negativas que no se seleccionan | Una configuración aceptada por la API puede quedar sin generar unidades. El stage actual usa prioridades no negativas. |
| Contrato · E09 | Pausa parcial de apariciones | Una reserva anterior a `pause()` se materializa a los1,5s. Definir si pausa debe suspender nuevas reservas o congelar también las existentes. |

Son **siete defectos reproducidos y una advertencia de contrato** dentro del alcance. Se mantienen los identificadores históricos para conservar vínculos con sus reproducciones; no son ocho defectos nuevos.

Fichas con causa, reproducción y límites: [E13](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-082842-wavesys-e13-pending-instancia-reciclada.md), [E03](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-015734-wavesys-e03-removeunit.md), [E02](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-015734-wavesys-e02-muerte-invocado.md), [E06](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-015734-wavesys-e06-contexto-eventos.md), [E07](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-015734-wavesys-e07-table-handles.md), [E08](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-015734-wavesys-e08-conteo-puntos.md), [E14](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-082842-wavesys-e14-prioridad-negativa.md), [E09](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/resueltos/2026-10-23-015734-wavesys-e09-pausa-reservas.md).

## Evidencia disponible

- `core-baseline2`:18 controles/7FAIL sobre las cinco bibliotecas del núcleo y soporte. Sus siete FAIL corresponden a seis hallazgos, incluyendo la semántica de pausa; no son siete fallos independientes.
- `core-slot-init`: contraste de causa para E02, con18controles/5FAIL. El cambio existe sólo en el JASS generado.
- `removal-delayed`: observa0,5s después de retirar una unidad; acredita tipo0 y contador activo1, descartando el mero retraso del motor.
- `features-v1`:44controles/42PASS/2FAIL; los dos FAIL son E13 y E14. Acredita además configuraciones básicas, cupos, propietarios, prioridades válidas, apariciones cercanas, materialización y registro de externos.
- `survival-resources-v4`: evidencia complementaria de integración; diez configuraciones generan518entidades y completan su cierre normal. El barrido automático de enemigos no prueba dificultad ni subsana las rutas excepcionales anteriores. Sus67controles incluyen otros componentes y no se atribuyen íntegramente al núcleo.

En este ajuste de alcance no se repitieron las partidas: se reutilizó evidencia existente y se comprobaron los hashes actuales de las fuentes principales y de soporte contra la revisión evaluada. No se modificó código de producto. Multijugador sigue sin acreditar.

## Orden de trabajo centrado en oleadas

1. **Ciclo de vida:** reservas, retiro y muerte externa; E13, E03 y E02. Proteger la identidad de cada instancia antes de modificar contadores y completar cada baja una sola vez.
2. **Eventos y almacenamiento:** restauración del contexto exterior y limpieza según el tipo guardado; E06 y E07.
3. **Configuración y retornos:** validar prioridades/gates/capacidades e informar inserciones reales; E14 y E08. El gate inalcanzable ya observado requiere una regla de validación, sin atribuirlo a las diez configuraciones que sí avanzaron.
4. **Contrato de pausa/cierre:** definir qué permanece reservado, qué se cancela y cuándo se puede reciclar la Wave. Destruir la administración y eliminar las unidades del mundo no son la misma operación.

Las comprobaciones deben conservar tres distinciones: unidad pendiente de reservar, reserva pendiente de materializar y entidad viva registrada. Los cupos actuales incluyen las reservas; un contador que parece activo todavía puede representar un efecto de entrada. La reconciliación de un retiro debe respetar esa diferencia.

Los límites de concurrencia/slots/puntos, los reintentos por rawcodes inexistentes y el comportamiento de grupos reconstruidos después de consumir sus markers siguen siendo parte de esta revisión del núcleo. Se distinguirán los contratos estáticos de las reproducciones nativas; los huecos de otras funciones del juego no se incorporarán a este dictamen.

## Registros

- [Núcleo original](../evidence/core-engine-baseline2.txt).
- [Contraste del slot](../evidence/core-engine-slot-init.txt).
- [Retirada diferida](../evidence/removal-delayed-engine.txt).
- [Prueba ampliada](../evidence/features-v1-native.txt).
- [Manifiesto del laboratorio ampliado](../evidence/features-v1-build.json).
- [Informe amplio anterior](evaluacion-completa-wavesys-2026-10-23.md), sólo como antecedentes de componentes externos.
