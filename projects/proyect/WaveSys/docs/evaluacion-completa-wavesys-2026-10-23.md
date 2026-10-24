# Evaluación ampliada de WaveSys — 23 de octubre de 2026

**Dictamen:** el recorrido básico de supervivencia funciona en el laboratorio: las diez configuraciones originales generan sus 518 enemigos para un humano, pasan los nueve descansos y llegan a la victoria nativa. Hay fallos de ciclo de vida, integración y consumidores que impiden considerar estable el conjunto. La prioridad es estabilizar esos contratos; no hace falta desechar todo el sistema.

Esta es la evaluación vigente de la copia independiente. Complementa el [informe inicial](evaluacion-wavesys-2026-10-23.md), que conserva las reproducciones iniciales de E01–E12. No equivale a certificar cada rama de 30.678 líneas, la partida humana completa, la calidad de todos los modelos ni multijugador. Cada afirmación más fuerte está vinculada a su ensayo.

## Revisión y conservación

- Objetivo: **Warcraft III Classic 1.27b**, JASS/vJASS release, JassHelper seguido de pJASS. Se usó el entorno local Wine/Proton documentado del proyecto.
- Origen del código: `/home/snz/Documentos/WarDatsPy/struct/`. Sus 162 entradas originales se inventariaron por hash. No se mezcló `struct-rebuild`.
- Copia: `/home/snz/Documentos/ChatGPT/Proyect/WaveSys/`. El conjunto actual tiene **114 fuentes activas**: 113 originales del builder más `Players/WavePlayerUtils.j`.
- El cambio de producto autorizado previamente fue crear el registro independiente de jugadores y migrar 16 consumidores de partida. El `PlayerUtils/User` antiguo de la interfaz conserva sus bytes. La ampliación presente añade laboratorios, recursos y documentación; no aplica las correcciones E01–E15 al producto.
- DevMission v0.96 se usó **sólo como fuente de recursos**, según la instrucción del usuario. No se lanzó, compiló, repaquetó ni editó. Su SHA-256 es `66e0ce9f27d741f4785cd26eea46aad2b0f407210f0b94fab06fa2b4e1175a61`.
- El MPQ tiene 264 entradas, todas nombradas en su listfile. Se extrajeron 250 archivos de recursos; 246 se incorporaron a una base de ensayo independiente. Se excluyeron de la superposición el minimapa, los ajustes Misc/Skin y las declaraciones W3S. Se copiaron los siete tipos de tablas de objetos, strings, imports y archivos multimedia seleccionados.
- No se importaron el JASS, los triggers, el terreno, las regiones ni las colocaciones de DevMission. El mundo de ensayo es TerrainDev. Las tablas de objetos y WTS de DevMission reemplazan deliberadamente las de esa base; no son una fusión de dos modos de juego. El WTS puede cambiar etiquetas que usen los mismos índices.
- Cada recurso incorporado se reextrajo y comparó por hash. También se comprobaron el JASS generado, la cabecera y los miembros ajenos de cada mapa. `(attributes)` y `(listfile)` son metadatos MPQ regenerados; su exclusión de igualdad binaria está declarada, no se extiende a los miembros de juego.

Procedencia: [fuente del mapa](../evidence/devmission-source-provenance.json), [paquete verificado](../evidence/devmission-resource-pack.json), [objetos de unidad](../evidence/devmission-unit-objects.json), [habilidades](../evidence/devmission-ability-objects.json), [migración de jugadores](../evidence/player-utils-migration.json).

## Qué se ejecutó realmente

| Ensayo | Resultado nativo | Alcance y límite |
|---|---|---|
| Núcleo original `core-baseline2` | 18 controles, 7 FAIL | Cinco bibliotecas; `endF` vacío y callbacks finales vacíos. Reproduce seis hallazgos, no siete defectos independientes. |
| Diagnóstico E02 `core-slot-init` | 18 controles, 5 FAIL | Sólo inicializa `s=0` en la entrada generada. Contraste causal, no corrección de `src`. |
| `removal-delayed` | Activo fantasma confirmado | Espera al retiro real del motor tras `RemoveUnit`; no desaparece el contador ni termina la wave. |
| `players-alone-v1` | 39/39 | Registro nuevo aislado, con 144 retiradas de roster. |
| `players-coexist-v1` | 39/39 | Registro nuevo junto al `User` antiguo. No son desconexiones de clientes LAN. |
| `players-negative-v1` | 10 fallos previstos | Mutación deliberada del índice inverso; acredita sensibilidad del ensayo. No se entrega como producto. |
| `features-v1` | 44 controles, 42 PASS, 2 FAIL | Validación, cupos, slots, propietarios, prioridades, cercanía, reservas/FX, eventos, externos y destrucción. Confirma E13 y E14. |
| `integration-v5` | 25 controles, 24 PASS, 1 FAIL | Las 114 fuentes, vidas, protección, crédito/TTL, oro, IA, terminación y descanso real. Confirma E11. |
| `skills-v1` | 28 controles, 27 PASS, 1 FAIL | Guardas, barrera de cinco segundos y persecución. Confirma E10 sin necesitar objetos personalizados. |
| `resource-skills-v2` | 28 controles, 27 PASS, 1 FAIL | Objetos originales, habilidades normales, daño, trampa, pasiva del sacerdote y aura real. Confirma E12 con observadores de lectura generados. |
| `survival-resources-v4` | **67/67, victoria visible** | Diez waves, 518 apariciones y 518 muertes, nueve descansos reales, cierre final. Un barrido de prueba mata enemigos tras aparecer; no mide dificultad. |
| `gameplay-api-v1` | **Parcial:** 24 controles, 21 PASS, 3 FAIL | Inventario, seis objetos de héroe, tender y 13 llamadas directas de disparo. Se detuvo en el diálogo; no llegó a COMPLETE. Los tres FAIL pertenecen a E15. |

Los recuentos pertenecen a sus escenarios; no deben sumarse como porcentaje de corrección de todo el sistema. Hay controles repetidos, contrastes negativos y consumidores presentes sin una aserción individual para cada función.

Los laboratorios de 114 fuentes adaptan en el JASS generado los cuatro nombres `InitTrig_*` rechazados por JassHelper y omiten los inicializadores de `MapBootstrap` y `stage1`. Sus funciones siguen compiladas; el fixture llama explícitamente las entradas necesarias. `PreConfi` y las dependencias reales permanecen. Quince rects del mapa están declarados inicialmente como null; los casos de marcadores preparan su propio rect. Esto prueba integración controlada, no el arranque exacto del mapa histórico.

En `integration-v5` se inicializa `SwlsSound=null` porque el fixture entra directamente al descanso. El stage normal asigna antes ese sonido. La detención de versiones previas no se convirtió en un defecto del producto.

Los resultados y los comandos de compilación/empaquetado están en `evidence/*-build.json`. [Matriz por las 114 fuentes](cobertura-por-archivo-2026-10-23.md), [matriz estructurada y hashes](../evidence/complete-coverage.json).

## Arquitectura y conexiones

`MapBootstrap` inicia selección. La selección crea `PlayerHero`, inicializa vidas/cámara, configura el loadout visual y crea los clientes de interfaz. `SelectionStartFlow` abre la cuenta inicial y guarda el nombre del stage.

`StageExample.Trig_w1_Actions` crea una instancia `Wave`, aplica los puntos registrados, incorpora los héroes como referencias de cercanía y de IA y añade los slots de las unidades normales y del boss correspondiente. Cada grupo normal genera slots para cinco propietarios, Player(8..12); no son cinco jugadores humanos adicionales.

`Wave` reserva cantidad y cupo antes de crear la unidad. El timer de aparición materializa tras 1,5 segundos, registra unidad/slot/propietario y emite eventos. `IAManager` consume esos eventos, aplica perfiles, adquiere héroes y despacha habilidades. Cada familia de habilidad gestiona además sus propios timers, dummies, casts y limpieza.

La muerte de una unidad de slot actualiza el núcleo y avisa a IA, habilidades, rachas y drops. Los invocados externos tienen una ruta distinta: ahí aparece E02. No se puede suponer que una limpieza probada en unidades normales cubra también invocados o `RemoveUnit`.

Al terminar, `destroyWave` deriva el callback a `TheEnd.endF`, que entra en `RestTime`: vidas, curación/reaparición, premio de oro, tender, tablero y cuenta atrás. El despachador de descanso usa primero `SwlsWaveStartTrigger`; sólo si es null recurre al nombre `WaveTgg`. El nombre de callback no tiene precedencia incondicional sobre el trigger global.

En el final de la décima wave se activa la secuencia de 18 segundos y se llama a la victoria para el roster activo. Esa ruta sí se observó hasta el diálogo nativo de victoria.

## Hallazgos priorizados

**P1:** resolver antes de depender de la ruta afectada como base estable. **P2:** corregir o definir el contrato antes de ampliar esa función. La tabla distingue compilador, motor, análisis estático y dependencias. Las fichas individuales contienen reproducción y límites.

| ID | Prioridad | Hallazgo | Evidencia |
|---|---|---|---|
| [E01](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e01-inittrig.md) | P1 | La unidad de fuentes actual no compila sin adaptación | JassHelper/pJASS, contraste generado |
| [E02](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e02-muerte-invocado.md) | P1 | La muerte de invocados aborta antes de avisar y limpiar | Motor + contraste de inicialización |
| [E03](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e03-removeunit.md) | P1 | RemoveUnit deja la oleada esperando unidades inexistentes | Motor, observación diferida |
| [E04](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e04-jugadores-salida.md) | P1 | PlayerUtils corrompe el índice compacto de jugadores al salir | Fuente; nuevo roster probado, UI antigua pendiente |
| [E05](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e05-ids-habilidades.md) | P1 | Las habilidades agotan índices acumulativos sin reciclar | Estática/compilado; saturación no ejecutada |
| [E06](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e06-contexto-eventos.md) | P2 | Los eventos anidados borran el contexto del evento exterior | Motor, eventos anidados |
| [E07](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e07-table-handles.md) | P2 | La limpieza de Table usa el tipo equivocado | Motor, almacenamiento por tipo |
| [E08](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e08-conteo-puntos.md) | P2 | Aplicar puntos devuelve una cantidad que no se insertó | Motor, límite de puntos |
| [E09](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e09-pausa-reservas.md) | P2 | La pausa permite materializar apariciones ya reservadas | Motor; decisión de semántica de pausa |
| [E10](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e10-cache-ordenes.md) | P2 | La memoria de órdenes puede impedir reanudar persecución | Motor, barrera y orden0 |
| [E11](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e11-tablero-descanso.md) | P2 | El tablero inicial sobrescribe la interfaz de descanso y victoria | Motor en descanso; final estático |
| [E12](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-015734-wavesys-e12-aura-compactacion.md) | P2 | El aura pierde miembros vivos al retirar una entrada inválida | Motor, recursos y observadores de lectura |
| [E13](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-082842-wavesys-e13-pending-instancia-reciclada.md) | P1 | Un temporizador pendiente modifica una instancia de Wave reciclada | Motor, reciclaje de instancia |
| [E14](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-082842-wavesys-e14-prioridad-negativa.md) | P2 | Los slots admiten prioridad negativa pero nunca se eligen | Motor, prioridad negativa |
| [E15](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-091934-wavesys-e15-recursos-armas-ausentes.md) | P1 | DevMission v0.96 carece de objetos que exigen las armas actuales | Tablas por hash + motor, recursos ausentes |

### Ciclo de vida: la prioridad más alta

E02 y E03 rompen dos salidas distintas. En la muerte de externos, un local `WaveSlot s` sin inicializar interrumpe el hilo antes de avisar y limpiar. El contraste generado con `s=0` recupera esa parte. En cambio, retirar una unidad mediante `RemoveUnit` no produce una muerte equivalente: el núcleo conserva el activo y puede esperar indefinidamente incluso después de que el motor devuelva tipo0. Inicializar el local no arregla esta segunda ruta.

E13 añade un riesgo entre instancias. Una reserva antigua conserva ids de Wave y slot. Si se destruyen y reciclan antes de los 1,5 segundos, el callback detecta el token diferente, pero aun así llama a cancelación sobre `ps.wave`. Ese entero ya puede representar otra wave. La reproducción reutilizó waveId4, token15→16 y slot97; una nueva cantidad pendiente de2 pasó a3 cuando venció el timer antiguo.

La solución necesita un contrato de cancelación coherente: drenar o invalidar reservas antes de reciclar, y no modificar una instancia cuando su generación no coincide. Cambiar un contador aislado escondería el síntoma sin proteger a los consumidores.

`destroyWave` también es público y no elimina necesariamente todas las unidades vivas del mundo. Destruir administración, cancelar pendientes y eliminar entidades son operaciones diferentes que deben estar documentadas. Los servicios que reciben Finish pueden limpiar IA mientras otras entidades aún existen si se usa esa entrada fuera de su secuencia normal.

### Eventos, tablas y aura

E06 se reproduce anidando Start→Pause: los listeners posteriores del Start exterior reciben contexto borrado. La ejecución de eventos necesita guardar y restaurar el contexto previo, también ante anidamiento. El tablero usa otro contexto global para su callback; merece el mismo cuidado al introducir callbacks que se llamen entre sí.

E07 es un error de tipo de almacenamiento: `Table.remove(key)` elimina el entero, no un handle guardado en `.unit` ni un real en `.real`. El laboratorio verificó que seguía existiendo el handle tras la limpieza. Debe revisarse el tipo usado en cada alta y cada baja; no basta con reemplazar texto indiscriminadamente en todos los `.remove`.

E12 ya tiene confirmación con el `rspl/A015` original. El aura incorporó cuatro miembros; se retiró una entrada interior distinta de la fuente y del último miembro. La rama inválida reduce el contador sin mover la última entrada. Además, la eliminación por tipo incorrecto puede dejar la entrada inválida disponible para barridos posteriores. El último miembro terminó con `ownerAura=1` después del final del aura. Ese estado huérfano está demostrado. El log no imprime por separado todos los buffs o el inventario, por lo que no se afirma que cada uno permanezca indefinidamente.

La prueba inspecciona el estado mediante cuatro funciones de **sólo lectura**, insertadas dentro de la biblioteca únicamente en el JASS generado. No altera el algoritmo del aura ni presenta esas funciones como API original.

### IA, habilidades y sesiones largas

E10 tiene una reproducción positiva y una negativa: el enemigo recibe un `attack` real contra un héroe lejano, activa su barrera, pasa su duración real de cinco segundos y queda con orden0. La caché conserva el mismo objetivo y evita reenviar el ataque. La adquisición automática puede disimularlo a corta distancia; no se afirma que todos los enemigos se congelen siempre.

E05 afecta contadores acumulativos de casts/aura/visuales que no reciclan ids. En el caso de lightning de ranged, una clave `castId*16 + índice` alcanza el límite de arrays Classic al llegar al cast512. No son 512 casts simultáneos: el riesgo depende del total durante la sesión. La prueba de diez waves mata pronto a los enemigos y no alcanza esa carga. El umbral deriva del código y del compilado; no se ejecutó una prueba de saturación que lo cruzara.

Las habilidades normales ensayadas mostraron telegraph/disparo, impacto de mortero, pausa/liberación por trampa, zona de daño, onda y concesión/retirada de `A004` del sacerdote. La barrera mostró bloqueo, trazas sin duplicado y despachos Wind/Ray. Eso no aprueba cada variante boss, todos los rebotes ni cada interacción entre habilidades.

`WaveSiegeSkillsTryExecute` retorna false en esta revisión: es una capacidad desactivada. `WaveReinforcements.j` es un contenedor vacío; los refuerzos efectivos están en `IAManager`, con windup de1,5s, demora inicial15–20s y enfriamiento50–60s. El recorrido automático elimina a los bosses antes de esa demora; no acredita sus refuerzos ni combate prolongado.

La pausa de Wave detiene nuevas decisiones del manager, pero no congela automáticamente proyectiles, windups, timers ni órdenes nativas ya iniciadas. E09 confirma que una aparición reservada se materializa durante la pausa. Debe decidirse si pausa significa «no reservar más» o «congelar toda la simulación» antes de cambiar el comportamiento.

Varias habilidades llaman `PauseUnit(false)` al terminar sin arbitrar otros motivos de pausa. Hay riesgo de solapamiento con otro sistema que pretenda mantener la misma unidad detenida. Es un riesgo de integración pendiente de un ensayo específico, no un nuevo fallo nativo demostrado aquí.

El getter de escala base del sacerdote usa1.0; su restauración puede pisar una escala de object data o de otro modificador. No se certificó visualmente esa restauración para cada tipo. Los timers/grupos persistentes de servicios tampoco se declararon fugas sólo por vivir durante todo el mapa.

### Tablero, selección, tienda y armas

E11 se observa en el descanso: el handler real escribe `Descanso / Tienda:10`, y a los0,25s aparece `Preparando Wave2/10`. La cuenta atrás sí continúa y despacha el siguiente callback una vez. El problema es tener dos escritores sin una fase de interfaz compartida. El conflicto de la rama final también existe en la fuente, pero la captura de victoria sí mostró `Mapa completado`; no se declara una desaparición visual final que no se observó.

La UI activa actualiza91 celdas cada0,25s; la inicial reconstruye30 celdas cada0,10s. Son conteos del código, no medidas de FPS. Layout/estilo fijo y refresco por cambios reducirían trabajo, una vez resueltos los defectos de estado.

Los seis rawcodes de héroe configurados crean héroes reales con los recursos de DevMission. `gameplay-api-v1` llegó al diálogo de seis elecciones. **Su final, selección manual y timeout no quedaron validados.** Hubo captura/foco compartido con otras partidas y una entrada de ratón cuya posición no coincidió con la prevista. No se atribuye automáticamente la detención a la selección ni se la convierte en PASS. La incidencia conserva el detalle.

Las posiciones originales de héroe/tender usan y=24064, fuera de los límites del terreno independiente empleado. Portar sólo recursos no porta la geometría del escenario. Se ensayó `h004` en una posición explícita del fixture para validar creación y proximidad. No se afirma que la localización del tender original esté probada.

El inventario real pasó inicialización, rechazo de slots/perfiles inválidos, concesión, acumulación de munición, consumo, retorno a Handgun al agotarse y conservación del arma secundaria al reset de muerte. Se llamaron las13 entradas de disparo; todas devolvieron éxito y se registraron eventos de daño durante cada ventana. Son llamadas directas: no validan la entrada por teclado, el origen individual de cada impacto residual ni todas las variantes de cada arma.

E15 es una incompatibilidad verificable entre revisiones: estas fuentes exigen `U0AF/U0C1/U0C2/pRSN`, ausentes de DevMission v0.96. No se perdieron al extraer: las tablas son idénticas por hash. `EnsurePlayer` deja las habilidades en nivel0 y `CreateUnit('pRSN')` no produce esa unidad. No se puede declarar operativa la habilidad unificada de disparo, sus selectores o los pickups de prisionero con esta combinación. Puede haber rutas antiguas de disparo distintas; no se afirma que todas ellas dependan de `U0AF`.

En los archivos activos revisados hay tender, proximidad, cierre de menú y fases llamadas Tienda. No se localizó allí un catálogo con transacciones de compra y descuento de oro. `TenderEscInteraction` está desactivado explícitamente. La palabra «Tienda» en la cuenta atrás no demuestra un sistema de compras completo. La lógica podría pertenecer a otra revisión o al mapa; su script no se importó.

## Puntos, aparición y escalado

Lo que recordabas de colocar unidades para registrar puntos sí corresponde al código y pasó pruebas: el grupo se registra por nombre, rect y rawcode, captura posiciones, elimina los marcadores y conserva coordenadas para aplicarlas a futuras waves. El rawcode configurado `l00A` **sí existe en DevMission**. El ensayo con recursos reales capturó tres markers y verificó su retirada después del procesamiento del motor.

Hay deduplicación y ordenación de posiciones. La lista está congelada tras el build: añadir markers después no la actualiza automáticamente. Volver a construir después de eliminar los markers originales tampoco equivale a conservar la lista anterior; hay que controlar el momento de carga.

E08 aparece al pasar de la capacidad del receptor: el grupo admite128 puntos y Wave100. La función devuelve el tamaño del grupo aunque algunos `addPoint` se rechacen. Su retorno no expresa cuántos puntos se insertaron realmente.

La aparición cercana sortea una referencia viva de `nearUnits` y busca terreno caminable; el laboratorio tomó32 muestras dentro del rango configurado64–256 y ejercitó la referencia muerta. Los puntos fijos requieren que el diseñador coloque ubicaciones utilizables. No hay una prueba general de ruta de navegación para cada punto.

El stage guarda15% de probabilidad cercana y85% de ruta fija, con intervalo0,25s y cap30 por propietario. Es probabilidad por intento; no garantiza una cuota exacta de enemigos ni reparto equitativo entre héroes. La lista de referencias se toma al crear la wave y no descarta por sí sola un héroe vivo cuyo dueño haya abandonado. El roster independiente no borra automáticamente esa referencia de IA/cercanía.

El comentario de `WavePointGroupsConfig` promete fallback manual cuando no hay markers, pero el stage activo sólo muestra `Error No Points`; no añade puntos manuales. Con héroes válidos puede seguir consiguiendo apariciones por la rama cercana; sin puntos ni referencia utilizable no hay progreso. No se debe confundir ese mensaje con recuperación.

Para un humano las cantidades comprobadas son **5,17,27,37,47,57,67,77,87,97**: suman518. A partir de wave5 se añaden tipos cuya cantidad escala con jugadores; los tipos iniciales conservan su base sin escalar. Wave10 tiene35 normales fijos +60 por humano activo +2 bosses. No se probó el balance con varios jugadores reales ni una campaña humana de combate.

## Configuraciones problemáticas y límites adicionales

- E14: prioridad negativa aceptada, pero no seleccionada porque el máximo inicial es-1 y la selección rechaza el resultado negativo. Las prioridades del stage actual son no negativas; no se le atribuye ese bloqueo a sus diez configuraciones.
- Un gate puede ser inalcanzable si exige reducir pendientes que sólo pueden reducirse generando el propio slot. El caso mínimo del núcleo se reproduce. Los gates de los bosses revisados no quedaron bloqueados en el recorrido real de diez waves.
- Un rawcode no nulo inexistente puede producir reintentos sin un error terminal público. E15 muestra por qué no alcanza con validar `rawcode!=0`.
- Capacidades100 slots/puntos/referencias se resuelven con retornos silenciosos. Conviene devolver éxito/cantidad o registrar configuración inválida.
- El compilado dispone de80 instancias Wave simultáneas por los arrays internos. `create` no valida el resultado0 de `allocate`. No se agotó esa concurrencia; no es un límite de80 waves sucesivas, pues las instancias se reciclan.
- `upsert` suma cantidades conservando otros parámetros existentes; su nombre puede hacer esperar reemplazo de perfil, FX, límites o flags. Documentar esa semántica antes de usarlo como reconfiguración general.
- No se encontró una resolución automática de derrota por todos los héroes muertos/sin vidas en las entradas activas revisadas. `HeroLives` deja de revivir al llegar a0. No se inspeccionó el script histórico de DevMission para buscar reglas externas; no se afirma que el mapa original carezca de derrota.
- El mensaje de wave10 menciona que el final boss está pendiente. El final ejecutado actualmente es victoria al terminar esas diez waves; no se acredita un encuentro adicional.

## Qué conviene conservar y qué corregir primero

Conviene conservar la separación entre waves, IA y habilidades, el registro único de puntos, la reserva previa de cupos, los getters de cantidades y el presupuesto de IA. Estas decisiones ya permiten ensayar piezas sin reconstruir todo el escenario.

1. Hacer reproducible el build exacto: resolver E01 en la fuente apropiada y fijar la revisión de objetos correspondiente a las armas, E15. No convertir adaptaciones del laboratorio en arreglos ocultos.
2. Unificar el ciclo de vida de unidad y reserva: E02, E03 y E13. Regresión con muerte normal/externa, retiro, cancelación y reciclaje mientras hay callbacks pendientes.
3. Restaurar contexto anidado y emparejar tipos Table; compactar aura de forma correcta: E06, E07 y E12. Probar al consumidor real que antes conservaba estado huérfano.
4. Reciclar ids de habilidades/visuales y verificar límites acumulativos, E05. Los pools del núcleo y los de cada habilidad tienen contratos distintos.
5. Invalidar o comprobar órdenes después de habilidades, E10; asignar un único escritor de tablero por fase, E11.
6. Corregir el registro antiguo de UI o completar su aislamiento con pruebas de salida, E04. Mantener el registro nuevo de partida; sus ensayos ya cubren índices dispersos y retiradas.
7. Definir pausa, gates inválidos, prioridades, retorno de puntos y política de abandono antes de ampliar reglas. Después medir rendimiento y balance con cargas representativas.

Una corrección sólo se considerará cerrada después de repetir su reproducción y las rutas consumidoras afectadas. Los hallazgos de producto siguen abiertos en esta evaluación; se han corregido y cerrado únicamente incidencias de preparación cuyo contraste recuperó la prueba.

## Límites y entregables

El estado más fuerte acreditado es **Tested in map, con fallos y cobertura delimitada**. No se acredita multijugador, ausencia de desincronización, desconexiones reales, calidad visual completa, cada habilidad de boss/refuerzo, saturación de ids, todos los escenarios de terreno ni el flujo humano completo de selección/tienda/armas.

Hubo formas triangulares negras/verdes inesperadas en capturas de laboratorios con recursos. La causa no está aislada entre modelos/overlays/terreno/renderer; el avance lógico siguió y terminó en victoria. No se usa el PASS lógico como aprobación visual. El informe visual conserva las capturas y el siguiente contraste necesario.

CodeGraph se consultó primero con la raíz WaveSys y nombres concretos para Wave, puntos, IA, habilidades, vidas, selección, armas, UI y builders. Se consultó el índice propietario TerrainDev/scripts para leer sus parsers y proceso de empaquetado; no se modificó TerrainDev. Perfil release y `completeInputs=false` siguen siendo correctos: scripts derivados y recursos no forman una unidad completa indexada. Condiciones, macros y `ExecuteFunc` tienen los límites registrados. El grafo no sustituyó el compilador ni el motor.

- [Victoria observada](../evidence/survival-resources-v4-final.png) y [67 controles](../evidence/survival-resources-v4-native.txt).
- [Núcleo ampliado](../evidence/features-v1-native.txt), [integración](../evidence/integration-v5-native.txt), [barrera/IA](../evidence/skills-v1-native.txt), [habilidades con recursos](../evidence/resource-skills-v2-native.txt), [armas y selección parcial](../evidence/gameplay-api-v1-native.txt).
- [Hallazgos estructurados](../evidence/findings.json), [cobertura por archivo](cobertura-por-archivo-2026-10-23.md), [consultas y límites de CodeGraph](../evidence/codegraph-coverage.md).
- [Builder del núcleo](../tools/build-core-audit.py), [builder de integración](../tools/build-integration-audit.py), [paquete de recursos](../tools/build-resource-base.py).
- [Plan y estado de continuidad](planes/evaluacion-completa-2026-10-23.md).

Los mapas de `artifacts/` son instrumentos de evaluación y pueden contener fallos deliberadamente conservados. No son una versión corregida lista para publicar.

Incidencias de validación abiertas: [selección SP, foco y entrada gráfica](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-092257-wavesys-seleccion-sp-y-capturas.md) y [artefacto visual](/home/snz/Documentos/ChatGPT/Proyect/informes/errores/2026-10-23-093056-wavesys-artefacto-visual-laboratorio.md). [Verificación final de integridad y cierre](../evidence/final-audit-verification.json).
