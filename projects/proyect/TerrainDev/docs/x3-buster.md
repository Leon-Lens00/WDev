# X3 Buster — perfiles USA y Zero Project en Warcraft

Destino: Warcraft III Classic 1.27b, vJASS, CachyOS/Proton. El vuelo se traduce de las mediciones de las ROM ejecutadas en MesenCE; se conservan modelos locales propios y las reglas de daño/colisión del mapa. No se incluyen ROM, sprites ni rutinas binarias en el mapa. Procedencia, seis ejecuciones completas y límites de la extracción: [laboratorio SNES](../labs/x3-snes/README.md).

## Controles

| Tecla | Habilidad del controlador | Resultado |
|---|---|---|
| Q | Rapid Fire | Ráfaga y movimiento existentes |
| W | Ax3c / carrionswarm | Buster cargado recto, perfil USA |
| E | Ax3s / shockwave | Cross Buster USA |
| R | Ax3z / breathoffire | Cross Buster Zero Project IPS V4.1 |

W/E/R son lanzamientos discretos para probar la física: todavía no existe carga acumulada por mantener/soltar una tecla. El controlador recibe la habilidad; el actor visible sólo muestra el resultado. Los tres objetos usan órdenes Channel distintas. No se cambia el contrato del movimiento artificial ni el de Rapid Fire.

## API

`X3Buster.fireProfile(actor,x,y,mode,profile)` devuelve una secuencia o cero si se rechaza. Perfiles: `X3Buster.ORIGINAL` (1), `ZERO_PROJECT` (2), `GIF` (0). Modos: 0 pulso cargado; 1 secuencia automática de hélice + segundo pulso; 2 hélice con `sequence.releasePulse()` manual. La liberación repetida se rechaza. `cancel()` solicita retirada de los cuerpos y cancela la formación pendiente.

`X3Buster.fire(actor,x,y,mode)` conserva el perfil GIF anterior para consumidores existentes. `X3Demo.profile` configura W/E (USA por defecto); R selecciona siempre Zero Project. El perfil se copia al cast: modificar la demo no cambia los misiles en vuelo. No destruir dummies directamente ni guardar un identificador de secuencia después de terminar: se reutilizan sus slots.

Origen y dirección quedan fijados al lanzar, incluido el segundo pulso. El desplazamiento posterior del actor no cambia el origen. Cero distancia usa facing; máximo longitudinal1400, incluso al apuntar cerca. Intercepción desde una nueva posición o apuntado diferente del segundo pulso requerirían otro contrato.

## Movimiento nativo

`X3Kinematics` convierte las mediciones a2unidades Warcraft por píxel, una elección de escala visual. Cadencia de referencia60.0988062658451pasos/s. Integra las velocidades discretas en orden nativo y realiza interpolación lineal entre sus posiciones; no sustituye Euler por una parábola continua. Missile conserva su paso1/32s: los valores matemáticos nativos no implican renderizado a60Hz.

La hélice tiene **tres componentes**, offsets longitudinales4/8/0px, verticales−6/0/7px y fases0/4/8 de una tabla cíclica16. El port proyecta el eje vertical de la pantalla SNES sobre la perpendicular XY de la dirección elegida en Warcraft. Altura visual70. El portador empieza a0.5px/paso, acelera8/256 durante15actualizaciones y64/256 después. El tope almacenado5 se aplica después de avanzar: el desplazamiento estable es5.25px/paso. El pulso crece durante4pasos sin avanzar y luego recorre8px/paso.

La demo emite el segundo pulso tras17/FPS (USA) o13/FPS (mod): tiempos observados de nacimiento relativos, no una emulación de botones/carga. El temporizador Warcraft redondea la oportunidad de emisión al siguiente tick.

La unión exige los tres componentes y el pulso vivos, pertenecientes al mismo cast, y que el pulso haya alcanzado su fase elegible. Usa una envolvente longitudinal de30px, calibrada con los encuentros observados; no se afirma que sea la caja de colisión rectangular exacta de SNES. Se resuelven primero impactos anteriores al encuentro. La unión se recoloca a la posición del segundo pulso, retira los cuatro precursores y muestra un flash. Espera18/FPS (USA) u8/FPS (mod) antes de crear el núcleo y sus cuatro satélites. No deja cinco modelos congelados durante esta formación.

Parámetros por paso nativo; las parejas se reflejan sobre el eje del disparo:

| Perfil/pieza | Velocidad X inicial | Aceleración X | Velocidad vertical inicial | Aceleración vertical |
|---|---:|---:|---:|---:|
| USA núcleo |0|24/256|0|0|
| USA pareja verde |−8|127/256|±1.5|0|
| USA pareja naranja |−6|96/256|±0.75|0|
| Mod núcleo |8 efectivos|0|0|0|
| Mod pareja verde |1|48/256|±5|∓96/256|
| Mod pareja naranja |−3|96/256|±7|∓112/256|

El límite X se aplica **antes** de acelerar: los cuerpos acelerados terminan en8+a, no8. El núcleo mod almacena10 en la ROM pero su primer desplazamiento ya es8. El USA retrocede60.53125px y45px en sus parejas antes de avanzar; el mod conserva10.5px de retroceso en la naranja, mientras la verde avanza. Las trayectorias mod cruzan el eje por su aceleración vertical. Todos nacen en la unión, sin el offset artificial del perfil GIF.

## Colisión y propiedad

Se conserva `GroundCollision.trace` sobre las posiciones XY reales, también al retroceder y atravesar el eje. Subpasos temporales de como máximo1/128s y cortes en los vértices nativos evitan barrer una cuerda que omita un giro. Cada trace mantiene su muestreo espacial8u. Árboles, destructibles sólidos, obstáculos y desniveles abruptos bloquean; enemigos terrestres válidos reciben daño una vez y el cuerpo termina. Aliados/dummies no bloquean. Colisión2D; altura decorativa, sin volumen3D ni daño a voladores.

| Pieza | Escala | Radio XY | Daño Warcraft |
|---|---:|---:|---:|
| Cargado/segundo pulso |1|29|75|
| Cada componente de hélice |0.55|12.65|35|
| Núcleo fusionado |1|41.25|150|
| Cada satélite |0.55|12.65|25|

Radios ligados a la malla medida de los recursos locales; halo, estela y Death decorativos. Daño, alcance, límites y colisiones son decisiones de Warcraft, no valores copiados del juego SNES. Máximo64secuencias, vida4s y alcance satélites600longitudinales netos. El recorrido incluye retroceso y desviación lateral.

Cada secuencia nativa emite hasta9cuerpos (3+1+5) y1flash. El perfil GIF emite8. `onRemove` es el único propietario de retirar referencias/counters; el cast permanece mientras espere un pulso o forme la unión, aunque tenga cero cuerpos. La formación usa un timer TimerUtils propio, liberado al cancelar y antes de reutilizar el cast. Un emisor muerto durante formación no emite los cinco cuerpos. El flash tiene vida y devolución independientes al MissileRecycler.

`X3Buster.live/projectiles/created/retired/fusions/hits/walls/flashCount()` complementan el panel global. No son medidas de memoria total ni FPS.

## Verificación y reproducción

Estado y evidencias vigentes: [verification.json](../reports/verification.json). Plan: [port ROM](planes/x3-port-rom.md). La aproximación GIF previa permanece documentada históricamente en [investigación visual](x3-investigacion-movimiento-20261023.md) y sus reportes; sus resultados no se transfieren automáticamente a una revisión nueva.

Construir con `python scripts/build.py`. El constructor compila JassHelper/pJASS, verifica hashes, reextrae imports y valida WCT/WTG. Laboratorio separado: `prepare_x3_probe.py`, `X3Probe.j` (regresión GIF), `x3_native_oracle.py` (genera expectativas desde CSV congelados), `X3NativeProbe.j`, evaluadores `verify_x3_probe.py` y `verify_x3_native.py`. Los probes y datos de ROM no se importan a producción.

Consultar CodeGraph por separado en src y scripts; sus relaciones estructurales, módulos proyectados y cobertura parcial no sustituyen compilación ni pruebas. El ensayo local no acredita multijugador, guardado nuevo en editor, todos los terrenos ni identidad visual con SNES. Fuentes compartidas Missile/Recycler/GroundCollision/GroundMotion/RapidFire y modelos originales conservados.
