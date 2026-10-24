# TerrainDev: base de misiles para Warcraft III Classic 1.27b

Mapa de trabajo: [TerrainDev.w3x](TerrainDev.w3x). Es una copia de `/home/snz/Descargas/TerrainDev.w3x`, cuyo nombre interno es **Swamped Temple_v2**, de **Kai Trausenegger / Anomines**. Sus créditos, terreno, colocaciones, objetos previos y dos triggers GUI se conservan. Por petición del usuario, Melee Initialization queda desactivado para evitar bases/trabajadores/IA de refriega en las pruebas. El original de Descargas y la copia en `maps/originals/` permanecen intactos.

Las bibliotecas se pueden editar dentro de NewGen, en **Trigger Editor → Project Libraries**. El mapa contiene todo el código y el modelo necesario; abrirlo no depende de imports externos. Para guardarlo necesita el editor con JassHelper, como el NewGen local. El World Editor vanilla no compila vJASS.

| Biblioteca | Versión | Uso |
|---|---|---|
| Missile, BPower | 2.5.1 | Movimiento, trayectorias y callbacks de colisión/finalización |
| MissileRecycler, Bribe | 1.4.5.2 | Reutilizar las unidades auxiliares de los proyectiles |
| WorldBounds | 2.0.0.0 | Límites reales del mapa |
| ErrorMessage | 1.0.1.4 | Diagnósticos disponibles en builds de depuración |
| TimerUtils | 2.0 | Temporizadores reutilizables y datos asociados |
| Table | 3.1.0.1 | Tablas y almacenamiento de handles |
| RegisterPlayerUnitEvent | 5.1.0.1 | Registro compartido de eventos de unidades |
| SpellEffectEvent | 1.1.0.0 | Conectar habilidades por rawcode al evento de efecto |
| IsDestructableTree | 1.3.1 | Distinguir árboles de otros destructibles |
| DummyCaster | 2.0.0.1 | Lanzamiento auxiliar de habilidades instantáneas |
| MissileDiagnostics | 1.0.0 local | Multiboard y observación del ciclo de vida |
| GroundCollision / GroundMotion | 1.0.0 local | Consulta de obstáculos y locomoción XY separada |
| RapidFire / RapidFireDemo | 1.0.0 local | Ráfaga, pareja controlador–ejecutor y prototipo jugable |

Procedencia, hashes y cambios: `libraries.json` y `assets/objects.json`. Las bibliotecas auxiliares proceden de las demos de BPower descargadas en `../descargas/warcraft3/misiles/bpower/`; cada archivo conserva sus créditos. Missile procede del [hilo de BPower](https://www.hiveworkshop.com/threads/missile.265370/) y MissileRecycler del [hilo de Bribe](https://www.hiveworkshop.com/threads/system-missilerecycler.206086/). La copia de la fuente primaria del reciclador se conserva en `assets/upstream/`.

Se añadió el prototipo local Rapid Fire y movimiento separado: [uso y contrato](docs/rapid-fire.md). No se importaron habilidades completas de las demos, otro núcleo de misiles, UnitIndexer ni un motor de daño. `TimerUtils` administra timers; `MissileRecycler` administra unidades: cumplen funciones distintas.

## Prototipo jugable

**Q + clic en suelo** dispara; **Mover o clic derecho en suelo** transmite el destino al ejecutor. Recast repone seis pendientes sin reiniciar el intervalo. El controlador queda fuera de cámara y sólo él tiene la habilidad. El mapa inicia sin refriega. El núcleo de Missile y su reciclador conservan sus hashes de la entrega anterior.

## Panel dentro de la partida

La multiboard **Misiles** aparece al cargar el mapa. Escribir **`-misiles`** la oculta o muestra para ese jugador; el seguimiento continúa mientras está oculta. También se puede minimizar con el control de la tabla.

Muestra instancias actuales y su pico, creadas/retiradas, edad máxima, dummies vivos/pico, prestados, reserva/capacidad, espera de efectos, descartes pendientes y vencidos, precreaciones, unidades nuevas, reutilizaciones y descartes expirados. Incluye pérdidas inesperadas, operaciones inválidas, unidades externas adoptadas, seguimiento omitido, comprobaciones de consistencia y alarmas históricas.

- **Reserva 96/96 y cero instancias es normal.** Son unidades precargadas para reutilizar, no una acumulación accidental. La reserva incluye el periodo de seguridad previo a reutilizar una unidad.
- Los eventos de creación, préstamo, devolución y retirada actualizan los contadores y solicitan un refresco. Los cambios del mismo hilo se agrupan en un refresco diferido. El vigilante revisa vida, edad y expiraciones **cada segundo**; no se dibuja la tabla a cada paso físico.
- **ALERTA** indica esperas vencidas, pérdidas, retornos inválidos o problemas de seguimiento. Un plazo tiene tolerancia adicional de 1.25 s y la detección depende de la siguiente revisión. Una espera normal de efectos se distingue del descarte por vida temporizada.
- **Revisar historial** conserva el aviso después de recuperarse un descarte atascado. Los contadores acumulados no se borran al ocultar el panel. Las pérdidas y operaciones inválidas permanecen visibles hasta reiniciar el mapa.
- **Revisar edad** a partir de 30 s sólo pide revisar una instancia antigua: una habilidad larga puede ser legítima. La edad cuenta desde la creación de la instancia, incluso antes de lanzarla.
- Reutilizaciones cuenta todos los préstamos desde la reserva, incluidos los dummies precargados. Por eso el ensayo de 90 misiles registra 24 préstamos de reserva, aunque sólo 12 reutilicen handles de su primera tanda.

El seguimiento observa handles reales de MissileRecycler y las instancias de Missile, sin enumerar dummies con Locust. Libera sus propias referencias a unidades observadas muertas. Admite hasta 8190 registros simultáneos de unidades; al superar la cobertura, muestra omitidos y alerta sin impedir crear misiles. La observación no mueve, elimina ni recicla unidades y no repara fallos automáticamente.

El panel **no mide memoria total, FPS, todos los handles de Warcraft ni recursos de otras bibliotecas**. Tampoco demuestra por sí solo que un proyectil activo durante mucho tiempo sea una fuga. Es una multiboard Classic; futuras tablas deben coordinar su visibilidad con ésta. La instrumentación de ambos núcleos es opcional si se retira MissileDiagnostics de los imports y del manifiesto.

Para repetir el ensayo ampliado en esta PC:

```bash
python3 /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/scripts/prepare_probe.py --diagnostics
python3 /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/scripts/run_diagnostics.py
```

El runner usa una copia de laboratorio, conserva sesiones preexistentes, compara las 90 retiradas con los contadores del panel y prueba espera de efectos, atasco provocado, recuperación, historial, retorno inválido y ocultar/mostrar. Los comandos `-diag-*` y los emisores de prueba sólo existen en esa copia, nunca en el mapa de trabajo.

## Objetos y configuración

- `dumi`: unidad de Missile y MissileRecycler, basada en el objeto de Frozen Orb. Modelo `war3mapImported\dummy.mdx`, con habilidades `Amrf,Aloc,Avul`. Modelo dummy acreditado a Vexorian, Anitarf e iNfraNe.
- `dcst`: unidad dedicada a DummyCaster, adaptada del objeto `n002` de Simple Spell Collection. Evita los IDs existentes `n000` y `n001`; es invisible, invulnerable, sin colisión, ataques, visión ni coste de población y con punto de lanzamiento/backswing cero. Conserva la base de edificio del ejemplo.
- Se conserva `KoboldDigger.mdx`, ya presente en el mapa.
- Se sustituyó la directiva ejecutable ObjectMerger del reciclador por un comentario: los objetos se integran explícitamente y no requieren ejecutar ese generador al guardar.
- Se corrigió una incompatibilidad de limpieza comprobada en 1.27b: el reciclador pausaba los dummies excedentes antes de aplicarles vida temporizada, y la pausa impedía que expirase. La adaptación quita la pausa sólo al descartar excedentes. El ensayo aislado con tres unidades idénticas confirmó la causa; fuentes originales y resultados previos se conservan.
- Missile usa paso `1./32.` y `setMovementSpeed()` recibe unidades por segundo. Su campo `speed` es desplazamiento por paso; no asignarle directamente una velocidad por segundo.
- El reciclador reserva 8 ángulos × 12 unidades y espera 2 segundos antes de reutilizar una unidad devuelta. Si un ángulo agota sus unidades, crea más; al devolver excedentes puede descartarlos. Esa capacidad no limita la cantidad de misiles a 96.
- DummyCaster requiere habilidades instantáneas, coste de maná y cooldown cero y rango 92083. Los buffs y sus objetos se crean según cada habilidad; esta base no los inventa. No se ha probado todavía un lanzamiento de buff con DummyCaster.

## Reconstruir y editar

En esta PC:

```bash
python3 /home/snz/Documentos/ChatGPT/Proyect/TerrainDev/scripts/build.py
```

El script usa el JassHelper, pJASS, APIs Classic y wc3ctl del entorno FrozenThone mediante su lanzador local. Requiere esas herramientas instaladas; sus rutas no son parte de la compatibilidad del mapa en juego.

`src/libraries/*.j` contiene las fuentes; `src/Main.j` y `libraries.json` definen el mismo orden de inclusión. Para añadir código, crear su fuente de texto personalizado y añadirla a ambas listas. La construcción parte siempre del original inmutable, conserva sus dos triggers GUI (Melee Initialization desactivado) y genera las fuentes WCT editables con el mismo orden. No reconstruir desde las fuentes externas después de editar el mapa en NewGen sin trasladar antes esos cambios al proyecto: la construcción reemplaza la salida generada y archiva la anterior en su carpeta de build.

Los resultados de construcción están en `reports/latest-build.json`; el estado final, enlazado a los ensayos posteriores, está en `reports/verification.json`. Cada ejecución guarda compilación, pJASS, lectura independiente de triggers/objetos y comparación de los miembros MPQ. El empaquetado conserva la cabecera HM3W y comprueba por hash el terreno, colocaciones e imports ajenos.

## Comprobaciones de la base anterior

Estas evidencias corresponden a la base de once bibliotecas; las del prototipo actual están al final y en `reports/verification.json`.

- Compilación conjunta de once bibliotecas con JassHelper y pJASS frente a las APIs locales de 1.27b. También pasa la compilación al retirar la biblioteca opcional del panel.
- Mapa reextraído: dos triggers originales conservados, once fuentes WCT completas y objetos/imports comprobados.
- La copia con la multiboard se abrió, guardó y reabrió en NewGen: once fuentes preservadas, dos triggers originales, terreno/imports conservados y JASS recompilado con panel válido para pJASS. Evidencia en `reports/multiboard/20261021-022712/editor/`; las revisiones anteriores están en `reports/editor-final/` y `reports/editor-test/`. NewGen normaliza nombres hacia WTS y elimina overrides equivalentes a valores heredados.
- El laboratorio de juego vive exclusivamente en `maps/work/` y `scripts/IntegrationProbe.j`; RapidFireDemo sí pertenece al prototipo entregado, pero los controles del laboratorio no. Prepararlo con `scripts/prepare_probe.py`, ejecutarlo con el lanzador `wc3.py play` y evaluar sus logs con `scripts/verify_probe.py`. El manifiesto de la ejecución está en `reports/latest-game-test.json`.
- Ensayo local con panel: **90 creados, 90 retirados, 70 llegadas, 10 colisiones, 10 cancelaciones; cero fallos**. Coinciden los contadores independientes del fixture y la instrumentación. El panel registra pico de 60 instancias/144 dummies, 24 préstamos de reserva y 66 excedentes expirados; al terminar, 96 en reserva y cero pendientes/alarma. Incluye vuelo recto, arco, curva y seguimiento, lectura/escritura de Table y datos de TimerUtils. El evaluador rechazó tres controles negativos.
- Nueve etapas del panel comprobadas: reposo, final normal, espera de efectos y su retorno, descarte atascado detectado, recuperación con historial, oculto, visible y retorno inválido. Las anomalías se provocan exclusivamente en el laboratorio; ninguna se emite en la entrega. Logs y capturas en `reports/game-test/20261021-024016/`.

El ensayo local no acredita multijugador, una prueba de carga ni todos los futuros consumidores de estas bibliotecas. Los ensayos nuevos de Rapid Fire se enlazan desde reports/verification.json; no trasladar el PASS de la base anterior a revisiones nuevas. DummyCaster no tiene un ensayo de buff nuevo.

## Verificación de Rapid Fire

La revisión con colores (22oct2026) pasa40 controles de selección/escala/override y44 de Rapid Fire en Classic1.27b. Incluye los12 modelos Misil-simple de Vinz y3 texturas compartidas, reextraídos por hash. El radio sigue en16 y la escala visual16/5.832; ver [misiles por color](docs/misiles-colores.md) y `reports/shot-colors-20261022/result.json`. La instancia propia quedó cerrada. No se repitió el guardado en editor ni multijugador para esta revisión.

La base anterior acreditó además la regresión90 y9 etapas del panel, cuyos núcleos conservan sus hashes. NewGen guardó/reabrió aquella copia con15 fuentes y regeneró84 celdas de pathing (40 de walkability). La entrega conserva el pathing original. La verificación vigente separa estos resultados históricos de los ensayos nuevos: `reports/verification.json`.

## Buster X3

W: cargado USA. E: Cross Buster USA. R: Cross Buster Zero Project IPS V4.1. Q mantiene RapidFire. Tres componentes iniciales, segundo pulso y unión con núcleo+cuatro satélites; trayectorias discretas medidas en ROM, adaptadas a Warcraft. Controles discretos; sin carga por mantener tecla.

Revisión actual:192controles funcionales/0fallos y5259valores nativos cotejados dentro de1.27b. Núcleos compartidos sin cambios, cero proyectiles/casts/flashes al terminar y pruebas propias cerradas. [Uso, API y límites](docs/x3-buster.md), [resultado](reports/x3-rom-port-20261023-143455/result.json), [vídeo USA/mod](reports/x3-rom-port-20261023-143455/demostracion-usa-zero.mp4). Estado vigente en `reports/verification.json`.
