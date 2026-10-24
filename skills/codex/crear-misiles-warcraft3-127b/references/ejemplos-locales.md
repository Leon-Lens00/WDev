# Ejemplos de BPower disponibles en esta PC

Raíz de datos: `/home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower`.

Abrir el [catálogo con enlaces a los cinco mapas](</home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower/CATALOGO.md>) para procedencia y estado. `manifest.json` guarda SHA-256 de mapas/ZIP; `analisis.json`, el inventario WCT y la comprobación del JASS embebido. Si se mueve el proyecto, localizar el catálogo por nombre y verificar esos hashes, sin descargar ni sustituir automáticamente.

## Elegir el ejemplo por mecánica

Las rutas de bloques siguientes son relativas a la raíz de datos. Sus líneas se refieren a los `.j` recuperados, no a `war3map.j`. Leer el código antes de adaptar: las referencias describen patrones observados, no una auditoría completa de cada hechizo.

| Mecánica | Fuente | Qué observar y qué adaptar |
|---|---|---|
| Lluvia de meteoros | `fuentes/245470/trigger-0009.j` (Armageddon) | `Meteor.onCollide/onRemove`, `CreateMeteor`, `Armageddon.onPeriodic`: separar el emisor canalizado de cada proyectil, decidir qué blancos reciben daño aéreo o de explosión, y configurar duración/altura antes del lanzamiento. |
| Padre e hijos | `fuentes/243397/trigger-0008.j` (Frozen Orb) | `CreateIceBolt` líneas 147–159; `FrozenOrb.onRemove/onPeriod` 166–188: emisión durante el vuelo y ráfaga terminal de 12. Copiar source/owner al hijo y calcular el presupuesto total. En `IceBolt.onCollide`, la rama aleatoria llama a `RemoveUnit` después del daño sin comprobar si murió el blanco: no describirla como exclusiva de cadáveres ni copiarla automáticamente. |
| Explosión al retirarse | `fuentes/245192/trigger-0021.j` (Fireball) | `onCollide` devuelve si el blanco es válido; `onRemove` aplica el área. Esto hace explotar también al retirarse por otras rutas del módulo: añadir una causa/estado si el nuevo diseño sólo explota en determinados impactos. |
| Fragmentación con arco | `fuentes/245192/trigger-0024.j` (ChaoticBoulder) | `createSmallBoulders` 73–88 y `onRemove` 91–108: un marcador diferencia padre e hijos para limitar la generación. `flightTime2Speed` y arc se configuran por proyectil. Confirmar cuántos hijos produce y qué ocurre en cada retirada. |
| Seguimiento y adquisición | `fuentes/245192/trigger-0026.j` (BoneSpirit) | `onPeriod` y lanzamiento: búsqueda espaciada, filtros y objetivo. Su velocidad configurada en unidades/segundo se multiplica por `Missile_TIMER_TIMEOUT`. Comprobar qué ocurre si no hay blancos. |
| Seguimiento con perforación | `fuentes/245192/trigger-0034.j` (GuidedArrow) | `onCollide` 81–94, `searchTarget` 96–122, `onPeriod` 125–162: temporizador de giro, memoria de impacto, reimpacto y salida al morir el blanco. Separar el blanco recordado por la habilidad del que guía actualmente el misil. |
| Anillo con efecto enlazado | `fuentes/245192/trigger-0032.j` (FistOfThunder) | `CreateMissiles` 119–139 y `onRemove/onPeriod`: distribuir ángulos, poseer el lightning por misil y liberarlo con su estado. Verificar alturas absolutas al mover el lightning. |
| Mover una unidad real | `fuentes/245192/trigger-0029.j` (Leap) | `Missile.createEx(source, ...)` transforma temporalmente la unidad en proyectil. Requiere restaurar pathing, animación y estado en todas las rutas de salida; no tratarla como dummy desechable. |
| Emisor con varias cabezas | `fuentes/258518/trigger-0005.j` (Hydra), `trigger-0009.j` (FireHydra) | Separar adquisición y cadencia de la configuración del proyectil; estudiar la composición de comportamientos. Referencia histórica con fallo de pJASS, no base lista para importar. |
| Integración GUI | `fuentes/275718/trigger-0001.j`, WTG y objetos del mismo mapa | JASS con API para GUI 1.6.1. Los campos de evento `Missile__*` y los arrays por índice tienen ámbitos distintos. Reconstruir eventos GUI requiere WTG/objetos; WCT solo no recompone toda la demo. |

## Composición con bibliotecas auxiliares

Usar esta tabla para reconocer recursos que puedan ayudar con la idea solicitada. Estas funciones se observaron en las fuentes recuperadas; consultar la composición completa del ejemplo cuando se elija adaptarlo.

| Biblioteca | Función observada y criterio de reutilización |
|---|---|
| `TimerUtils` | Timers con datos asociados para emisores, duración y otras fases. Comprobar qué instancia adquiere/libera cada timer; el timer compartido de Missile no reemplaza automáticamente estos usos. |
| `SpellEffectEvent` y `RegisterPlayerUnitEvent` | Registro y despacho de eventos de habilidades/unidades. Reutilizar la infraestructura del mapa para conectar el lanzamiento; SpellEffectEvent requiere RegisterPlayerUnitEvent y admite Table opcional. |
| `SpellIndex` | Estado por lanzamiento y limpieza de algunos efectos. En la colección declara Table, Missile, TimerUtils, DummyCaster, WorldBounds y ambas bibliotecas de eventos. Su destroy limpia effect/ubersplat/lightning y anula clock; no libera por sí mismo ese timer. Revisar las obligaciones del consumidor. |
| `DummyCaster` | Aplicar habilidades y buffs mediante un dummy. Verificar objetos, órdenes, mana, cooldown y concurrencia/reentrada según su implementación. Es un papel distinto del dummy visual de Missile. |
| `Table` | Almacenamiento auxiliar; forma parte de las dependencias de SpellIndex y puede integrarse opcionalmente con eventos. Revisar qué API usa el consumidor antes de sustituirla por un hashtable propio. |
| `WorldBounds` | Datos de límites del mundo e integración opcional con Missile. La presencia de esta integración cambia las rutas de movimiento del núcleo; conservar la configuración coherente. |
| `IsDestructableTree` | Clasificación de árboles para colisiones o daño a destructables; Armageddon la usa condicionalmente. No sustituir el filtro por dañar todos los destructables. |
| `TerrainPathability` / `IsTerrainWalkable`, `CameraEQNoise` | Comprobación de destino y efecto de cámara en Leap. Son relevantes al mover una unidad real aunque no sean requisitos del vuelo de un proyectil dummy. |
| `Hydra`, `ErrorMessage` | Hydra compone un emisor de varias cabezas con Missile y TimerUtils; ErrorMessage aporta diagnóstico opcional. Distinguir el fallo observado del mapa de la utilidad de este patrón de composición. |

El catálogo ofrece opciones de diseño. Elegir los recursos cuyo aporte concreto encaje con la idea y comprobar su versión, contrato e integración antes de usarlos.

## Límites del conjunto

- Armageddon y Frozen Orb contienen Missile **2.5.1**. Sus cuerpos coinciden con la fuente del hilo principal tras quitar cabeceras TESH y normalizar saltos de línea; sus SHA originales difieren y se conservan.
- Simple Spell Collection incorpora Missile **2.0.2**. Se identificó uso real en Fireball, ChaoticBoulder, BoneSpirit, Leap, FistOfThunder y GuidedArrow; IceSiege y Chaosflare no lo usan. Los encabezados `uses` no bastan para detectar todos los consumidores transitivos.
- Hydra incorpora Missile **1.4**. El JASS embebido falla pJASS por `ndist` y `bdist` sin inicializar (`extraidos/258518/war3map.j`, líneas 2215 y 2221). No corregir el original para ocultar el fallo ni concluir automáticamente un fallo visible en partida.
- La edición GUI **1.6.1** es otra interfaz; el estado de Hive observado es “Awaiting update”.
- Cuatro de los cinco scripts JASS embebidos pasan pJASS con APIs locales 1.27b. Se recuperaron 59 bloques WCT no vacíos; no se recompilaron con JassHelper ni se ensayaron los mapas en juego/multijugador. Los imports extraídos son selectivos.

Los ejemplos usan en algunos puntos grupos globales y variables temporales compartidas. Eso no demuestra un fallo por sí solo: antes de reutilizarlos en un sistema con daño/eventos anidados, inspeccionar si una llamada puede reentrar y sobrescribir la enumeración o contexto. Usar estado por instancia o una enumeración protegida cuando el flujo lo requiera.

Para un emisor periódico, una estimación inicial es `hijosPorPaso * ceil(vidaMáxima / periodo) + ráfagaFinal`, añadiendo el posible disparo inicial y límites propios del scheduler. Multiplicar por padres simultáneos y contar también los hijos aún vivos. Es un presupuesto de diseño; medir la carga real antes de atribuirle rendimiento.

No indexar juntas las cinco copias como un único proyecto compilable: contienen bibliotecas del mismo nombre y versiones diferentes. Para CodeGraph o búsquedas, usar por separado `fuentes/<id>` y conservar el ID como contexto; los módulos/macros siguen necesitando inspección y compilación.
