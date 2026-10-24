# Plan: Frozen Orb con persecución curva y fragmentos

Fecha: 2026-10-20, America/Lima. Estado: **Designed / sólo planificación**.
Proyecto de ensayo: `/tmp/superpowers-skills-forward-q2ye5sc7/planning`.
Objetivo cerrado: Warcraft III Classic 1.27b, JASS/vJASS, CachyOS/Wine.

La autorización actual termina en este documento. Las fases de implementación, compilación, empaquetado y juego siguientes son propuestas; ninguna se ha ejecutado. No hay W3X en el proyecto ni se ha buscado o alterado otro mapa.

## Objetivo y aceptación observable

El orbe persigue una unidad mediante una trayectoria con curvatura lateral visible, emite Ice Bolts durante el recorrido y termina de forma acotada. Se elige curvatura en XY como interpretación de «arco o curvatura»; no se añade un arco vertical. Reutilizar Missile 2.5.1, el módulo MissileStruct, el emisor y la carga de los hijos, evitando cambiar el núcleo.

Criterios previstos para una copia del mapa en 1.27b:

- Contra un blanco quieto y contra uno que se mueve lateralmente, el orbe muestra curvatura, actualiza su dirección durante el vuelo y se acerca al blanco. Registrar una secuencia de posiciones/capturas; un destino actualizado sin vuelo curvo no basta.
- El orbe finaliza al alcanzar su blanco, agotar recorrido/vida, perder un blanco válido o cancelarse. No persigue indefinidamente ni cambia de objetivo automáticamente.
- Se conserva la emisión giratoria durante vuelo y una única ráfaga terminal de 12 hijos en las terminaciones normales. Cancelación y pérdida del blanco limpian sin ráfaga.
- Cada hijo conserva source, owner, nivel, daño, filtro, alcance y retirada del ejemplo, salvo una decisión explícita sobre el defecto heredado descrito abajo. Varios lanzamientos no intercambian objetivos o contadores.
- `Missile.j` conserva exactamente su SHA-256. Compilar acredita sintaxis/API; el comportamiento sólo se acepta tras probarlo dentro de 1.27b. No se declara funcionamiento multijugador sin ensayo de clientes.

## Base y evidencia inspeccionada

Rutas de esta tabla relativas a la raíz del ensayo; hashes de los bytes originales, incluidos CRLF.

| Archivo | SHA-256 | Evidencia relevante |
|---|---|---|
| `contexto.txt` | `22bc2a464e78130ed7db79bb5df22a2c91e7a17742159eb9536115fe42556617` | Objetivo 1.27b, fuentes recuperadas de BPower; sin mapa empaquetado. |
| `Missile.j` | `cbcf79bacd5723c3f655fc6c1402a12144b4a5a4a102209f1b6aa701284e4286` | Cabecera 2.5.1; periodo 1/32 s (85); dummy `dumi` (97); filtro Z activo (135). |
| `FrozenOrb.j` | `acd3e3fb4532555191a77b05b37503f5ff11e492aa595db31c0fc1c74a7f443b` | Cabecera 2.1; orbe, IceBolt y Buff; entrada por SpellEffectEvent. |

Interfaces comprobadas directamente en esta copia:

- `Missile.speed` es desplazamiento por paso; `setMovementSpeed(v)` convierte unidades/s (549, 639–641). El orbe usa 13 por paso = 416 unidades/s; los hijos 20 = 640 unidades/s. No cambiar periodo ni aceleración global.
- Al tener `target`, `move` mueve origen/destino, reinicia `dist`, borra `height` y `curve` (812–822). Las ramas de curva y arco además requieren `target == null` (857 y 877). Por tanto, asignar `target` junto a `arc`/`curve` no cumple el requisito.
- `turn` limita el giro en radianes por paso (827–836). `bounce()` mueve origin a la posición actual y pone el progreso privado `dist` a cero; no borra el acumulador público `distance` (619–622).
- `impact` y `origin` son referencias readonly, pero `MissilePosition.move(x,y,z)` está disponible: Z de entrada es relativo al terreno (1698–1704). No sumar terreno de nuevo.
- El movimiento ocurre antes de los callbacks de los structs. Dentro del módulo: retirada solicitada, colisiones, finish, terreno, period (1528–1618). `onFinish` puede impedir que una llegada intermedia retire el misil; debe renovar el recorrido o terminar, nunca continuar sin límite.
- Devolver true en callbacks de acción retira a través del módulo. `onRemove` devuelve la política de reciclaje, no un permiso de explosión. `destroy()` pide retirada diferida; `terminate()` directo omite `onRemove` y la contabilidad del wrapper (644–672, 1456–1474).
- FrozenOrb ya emite un hijo por periodo (171–175) y 12 en onRemove (156–168). `CreateIceBolt` copia source y owner (138–147); no hace falta otro temporizador ni biblioteca de emisores.

Cobertura de consumidores: en los dos `.j` disponibles se identificaron `FrozenOrb` e `IceBolt` implementando MissileStruct, más `Buff` que usa su jugador neutral. No se dispone del resto del mapa: esto no enumera todos los consumidores reales del núcleo ni todas sus dependencias transitivas.

## Decisiones, riesgos y pendientes

**Elecciones del agente para concretar el diseño:** guía propia en FrozenOrb, blanco almacenado en un miembro distinto de `missile.target`, sin retarget; curvatura lateral; conservar límites actuales de 800 unidades del padre y 400 de los hijos. Mantener modelos, créditos y APIs Classic. No importar otra versión de Missile, TimerUtils ni un sistema nuevo de almacenamiento.

**Selección del blanco pendiente:** se recomienda lanzamiento dirigido a unidad mediante `GetSpellTargetUnit()` y el filtro actual de enemigos vivos no inmunes ni estructuras. La fuente actual sólo usa `GetSpellTargetX/Y()`; no demuestra que el objeto A001 admita seleccionar una unidad. Antes de implementar la entrada, confirmar si se permite adaptar A001 a objetivo de unidad o debe conservarse lanzamiento por punto. En este último caso hay que decidir radio y regla determinista de adquisición antes de programar esa parte. El diseño del vuelo y su estado no dependen de esa elección.

**Defecto heredado demostrado:** `IceBolt.onCollide` comprueba que el objeto existe y la probabilidad tras causar daño, pero no que haya muerto antes de `RemoveUnit` (126–128). Puede eliminar unidades vivas aunque la descripción hable de cadáveres. No atribuirlo al nuevo seguimiento ni corregirlo silenciosamente. Registrar si se conserva el comportamiento o se autoriza limitar el efecto a muertos; esta decisión condiciona la aceptación de la carga, no el diseño de la guía.

**Riesgos de la adaptación:** los puntos de guía se renuevan después del movimiento, por lo que hay un paso de latencia. El giro limitado puede no alcanzar blancos rápidos antes del límite. Los parámetros de curvatura son una propuesta de ajuste visual, no una trayectoria ya ensayada. Los bordes pueden separar la posición calculada del dummy en esta biblioteca: cancelar el padre antes de continuar fuera de los límites efectivos del mapa, sin modificar la política global.

## Fases propuestas

### 1. Identificar integración y cerrar la entrada

Estado: pendiente. Requiere acceso al mapa/fuentes completas cuando se autorice implementar.

Entregable: inventario del mapa original, copia de trabajo nueva, configuración de construcción y decisión sobre selección del blanco/carga heredada. Revisar las instrucciones de ese proyecto antes de adoptar el proceso local.

Comprobar objetos A001, A002, n000 y dumi; sus colisiones con IDs existentes; modelo dummy y Aloc/Amrf; modelos usados por FrozenOrb; configuración de Buff, orden 852226, maná/cooldown y reentrada. Identificar SpellEffectEvent y sus dependencias reales; el catálogo local indica RegisterPlayerUnitEvent y Table opcional, pero sus fuentes no están aquí. Verificar también declaración única de UnitAlive. Inventariar implementaciones de MissileStruct, macros e imports de la integración para detectar consumidores indirectos.

Herramientas existentes: se comprobó únicamente la presencia de `scripts/wc3.py` y `wc3toolchain.json` bajo `/home/snz/Documentos/ChatGPT/FrozenThone`, y del comprobador `check_toolchain.py` de la skill de construcción. Su ejecución, configuración y APIs están pendientes. La referencia local advierte de rutas antiguas de Forge: no cambiar configuración ni adoptar Forge para esta tarea sin resolver su necesidad y estado.

Verificación prevista: inventario con rutas/hashes y dependencias resueltas; conservar original; confirmar que hay un mapa Classic utilizable. Sin W3X/objetos se puede trabajar sobre fuentes, pero no completar integración ni acreditar juego.

### 2. Adaptar estado, guía y ciclo de vida en FrozenOrb.j

Estado: pendiente. Requiere contrato de entrada de fase 1 para conectar OnEffect.

Entregable: modificación local de FrozenOrb.j; Missile.j sin cambios. Estado por índice del misil: `unit trackedTarget`, `integer ageSteps`, `integer emittedCount`, `integer removalReason`, `boolean burstDone`; inicializar todos antes de launch y anular referencias en onRemove. Conservar `level`, `missile.data` como fase del patrón giratorio, source y owner. No usar globales temporales para el blanco ni sobrescribir el dato reservado al emisor.

Interfaz local propuesta: `UpdateGuidance(Missile missile) returns nothing`; actualiza el siguiente tramo, no emite hijos ni incrementa edad. La elección de visibilidad/validez y el motivo de retirada pertenecen al estado de FrozenOrb. `onPeriod` decide fin, cuenta edad y emite; `onFinish` renueva sólo un tramo intermedio o termina por una causa explícita; `onRemove` concentra limpieza y ráfaga permitida.

Diseño de guía por coordenadas:

1. Mantener `missile.target = null`, `curve = 0` y `arc = 0`. La curva visible sale de la dirección progresiva del vuelo, evitando el desplazamiento lateral interno basado en posX/posY privados.
2. En lanzamiento crear una dirección inicial desviada del blanco. Propuesta inicial: 35 grados de desvío a un lado fijo, giro máximo 0.06 rad/paso y sesgo de persecución de hasta 0.35 rad, que disminuye continuamente al acercarse: `sesgo = 0.35*d/(d+256)`, con d como distancia XY al blanco. Son parámetros locales ajustables; no pasar grados a miembros que esperan radianes.
3. Tras cada paso calcular rumbo al blanco más ese sesgo, renovar con `bounce()` y `impact.move(...)` un punto en dicho rumbo a distancia `max(64,d)` del orbe. Usar Z relativa de 50 para conservar el vuelo bajo de la habilidad. `turn` limita el cambio angular hacia ese punto y produce la curva. No escribir x/y/z readonly ni mover el dummy por fuera del núcleo. En el primer lanzamiento preparar la primera guía antes de launch.
4. Llegada al blanco: comprobar distancia al segmento real `prevX/prevY -> x/y` frente a un radio local inicial de 48, no llegada al waypoint sesgado. El padre no añade daño directo ni perfora unidades: sólo dispara su ráfaga al llegar. Si el blanco se mueve muy rápido, comprobar la cobertura de esta captura en la prueba y documentar su límite.
5. Finalizar antes de emitir si la unidad ya no existe, murió, dejó de pasar el filtro, se canceló, sale de límites o se agotó el presupuesto. Recorrido acumulado máximo 800 y techo de 62 pasos con el periodo actual (ceil(800/13)); no reiniciarlos al cambiar de waypoint. Al preparar el siguiente paso, limitar speed al menor entre 13 y el recorrido restante para no superar 800 por un paso completo. No esperar finish si cada paso renueva el destino.
6. Normal (llegada, alcance o vida): permitir una ráfaga de 12. Pérdida del blanco, cancelación o bordes: sólo limpiar. Marcar causa antes de devolver true o pedir destroy; retirada externa sin causa conocida se trata como cancelación. Evitar terminate directo y recursión desde onRemove. Un guardia burstDone evita hijos duplicados; no confundirlo con el booleano de reciclaje.

Verificación prevista de fuente: inicialización/limpieza simétricas, callbacks coherentes con el orden real, fin garantizado aunque no llegue a destino, sin API moderna ni cambios al núcleo. Esto es revisión estática, no prueba del motor.

### 3. Reutilizar emisión y acotar carga

Estado: pendiente. Depende del estado y motivos de fin de fase 2.

Entregable: CreateIceBolt y callbacks conservan la infraestructura existente. Un hijo por periodo, fase angular actual de 3π/5 y ráfaga final espaciada uniformemente; conservar offset 32, altura 50, alcance 400, speed 20, radio 48 y daño por nivel. Resolver sólo la decisión explícita sobre la eliminación heredada. Los hijos no emiten nietos.

Presupuesto conservador por padre: como máximo 62 emisiones periódicas más 12 terminales = 74 hijos; duración de padre hasta 62/32 = 1.9375 s, con tolerancia de un paso para retirada diferida; hijos aproximadamente 0.625 s de vuelo con la configuración actual. El orden de retirada puede reducir el número real; registrar el conteo, no exigir 74 exactos. Para C padres, techo conservador 74C hijos creados. No hay techo de concurrencia global acreditado sin las reglas del mapa; medir 1, 4 y 8 padres como escenarios iniciales y fijar el presupuesto de concurrencia real antes de aceptar rendimiento.

Verificación prevista: contadores por lanzamiento y motivo, máximo de hijos activos y ausencia de hijos después de la limpieza. Revisar daño/eventos anidados: el grupo y temporales compartidos de Missile y el caster único de Buff requieren prueba de reentrada; no afirmar que son un fallo por su sola existencia. No añadir búsquedas de grupo dentro de una colisión sin comprobar ese contrato.

### 4. Compilar e integrar una copia Classic

Estado: pendiente. Requiere fases 1–3 y autorización posterior; actualmente no ejecutable como integración completa por faltar mapa/dependencias.

Entregable: fuente editable, JASS compilado nuevo, logs y W3X nuevo. Reutilizar el proceso del mapa. Si aplica el entorno documentado, validar primero su configuración con `python3 /home/snz/.codex/skills/build-warcraft3-vjass-127b/scripts/check_toolchain.py /home/snz/Documentos/ChatGPT/FrozenThone/wc3toolchain.json --json`; después usar `python3 /home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py vjass FUENTE_INTEGRADA.j SALIDA_NUEVA.j` con rutas reales y salida inexistente. El lanzador usa JassHelper bajo Wine y pJASS con APIs Classic; comprobar logs y retornos, no sólo existencia del archivo. Estos comandos están previstos, no ejecutados.

Antes de empaquetar, comparar hash de Missile.j y revisar consumidores nuevos del mapa. Validar objetos/imports y conservar originales; empaquetar con la herramienta del proyecto, reextraer y comparar miembros modificados y cabecera. WCT solo no reconstruye WTG ni objetos. Si sólo se consigue compilar fuentes, informar ese límite sin presentar un mapa integrado.

### 5. Probar mecánica en Warcraft III 1.27b

Estado: pendiente. Requiere mapa integrado y autorización posterior para ejecución visual.

Usar la skill local de pruebas del juego. Matriz mínima: blanco quieto a distancias corta/media/máxima, blanco lateral y alejándose, distancia cero, muerto/eliminado durante vuelo, filtro inválido, cancelación, fin por alcance/vida, plano/desnivel y borde. Incluir blancos aéreos si A001 los admite; la guía propuesta conserva altura 50, por lo que no garantiza encuentro 3D con ellos. Si se requiere alcanzarlos, definir altura de seguimiento y nacimiento Z de hijos antes de aceptar esa variante.

Para cada caso conservar posiciones por paso o vídeo/capturas, motivo de fin, tiempo, conteo de hijos y daño/filtro observado. Éxito: persecución y curva visibles sin saltos, hijos desde el orbe, ráfaga una vez según causa, sin referencias o instancias activas propias tras terminar. Probar 1/4/8 lanzamientos, daño reentrante y restauración del caster de Buff. Comparar vuelo/daño de IceBolt con la base en el mismo escenario y demás habilidades del mapa si están disponibles. Ajustar parámetros locales si falla visibilidad o captura; si aparece necesidad de tocar el núcleo, documentar evidencia, consumidores y alternativa antes de ampliar alcance.

Juego individual no acredita ausencia de desync. Ensayo multijugador es una fase adicional sólo si forma parte de la entrega solicitada.

## Continuidad y resultado actual

Realizado: lectura de las tres fuentes, inspección de movimiento/API/callbacks y consumidores visibles, hashes base, consulta de writing-plans y referencias locales de misiles/construcción, comprobación de presencia de las entradas de herramientas y escritura/revisión de este plan. No se ejecutaron analizadores semánticos ni compiladores. Tampoco se instalaron dependencias, usó red, modificaron fuentes, ejecutó juego o crearon commits.

Próximo paso: cuando se autorice implementar, releer este plan y recalcular los tres hashes; identificar el mapa real y sus instrucciones, resolver la selección de blanco y la carga heredada en fase 1. Retomar fase 2 con esa base; no inferir que las copias del ensayo incluyen todos los objetos o dependencias.

Todas las verificaciones de fases 1–5 siguen pendientes. La viabilidad de los puntos de guía está fundamentada en la interfaz inspeccionada; la calidad visual, captura, carga, integración y funcionamiento en 1.27b todavía no están demostrados.
