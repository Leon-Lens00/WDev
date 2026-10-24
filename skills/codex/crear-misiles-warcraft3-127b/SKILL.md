---
name: crear-misiles-warcraft3-127b
description: "Diseñar, implementar y refinar habilidades de misiles en JASS/vJASS para Warcraft III Classic 1.27b, usando ejemplos locales de BPower y el contrato de la biblioteca real del mapa. Aplicar a trayectorias, seguimiento, impactos, fragmentación y emisores; complementar la skill de construcción para compilar y empaquetar."
---

# Crear misiles para Warcraft III Classic 1.27b

Convertir la mecánica solicitada en una habilidad integrada con la biblioteca y los consumidores del mapa. Usar los ejemplos como patrones verificables; no tratar un mapa descargado como una plantilla certificada.

## Elegir la base

- Inspeccionar el mapa/proyecto objetivo y su biblioteca exacta antes de escribir llamadas. Un proyecto existente conserva su implementación salvo que la tarea requiera cambiarla. Para una implementación nueva basada en BPower, usar como referencia el hilo elegido por el usuario: [Missile](https://www.hiveworkshop.com/threads/missile.265370/), cuyo bloque principal declara **2.5.1** en la copia del 20-10-2026. Si se necesita una versión posterior, verificar de nuevo el hilo.
- Para elegir un ejemplo, leer [references/ejemplos-locales.md](references/ejemplos-locales.md) y después sólo el bloque pertinente. Armageddon y Frozen Orb incluyen el núcleo 2.5.1; Hydra, Simple Spell Collection y Missile GUI usan otras versiones o interfaces. No mezclar sus núcleos o dependencias por nombre.
- Consultar [references/contrato-bpower-251.md](references/contrato-bpower-251.md) antes de usar esa versión: contiene las unidades, la interacción entre homing y arc/curve, el orden de callbacks y las rutas de retirada observadas. Para otras bibliotecas, deducir el contrato de su fuente real.

## Diseñar la habilidad

Concretar los aspectos que cambian el comportamiento pedido: origen/destino, velocidad o duración, trayectoria, seguimiento, blancos válidos, perforación/reimpacto, explosión y condición de finalización. Resolver valores rutinarios con el contexto; preguntar sólo cuando una decisión ausente cambie materialmente la mecánica.

Separar la emisión del vuelo y de la carga de impacto. Cada lanzamiento debe tener estado propio; decidir quién posee y libera los datos de la habilidad, efectos, timers y grupos. Si hay hijos o ráfagas, fijar un límite de vida y un presupuesto de emisiones por lanzamiento y por lanzamientos simultáneos. Los patrones y sus límites están en [references/ejemplos-locales.md](references/ejemplos-locales.md).

Relacionar la idea solicitada con los recursos del catálogo: identificar qué ejemplo o biblioteca puede ayudar, qué parte de la mecánica resuelve y si encaja con el proyecto. Por ejemplo, Frozen Orb para un proyectil que emite otros, Hydra para varias fuentes de disparo o DummyCaster para aplicar un buff al impactar. Consultar la sección de composición en [references/ejemplos-locales.md](references/ejemplos-locales.md) cuando resulte pertinente. Elegir según utilidad y compatibilidad; conocer un recurso no obliga a incorporarlo.

Antes de tocar un núcleo compartido, localizar los consumidores que dependen del comportamiento modificado: velocidad/paso temporal, trayectoria, alturas, colisiones y retirada. Preferir una adaptación de la habilidad cuando preserve la mecánica pedida; si el núcleo necesita cambiar, explicar el impacto demostrado y verificar los consumidores afectados.

## Integrar y comprobar

Usar [build-warcraft3-vjass-127b](/home/snz/.codex/skills/build-warcraft3-vjass-127b/SKILL.md) para el toolchain CachyOS/Wine, APIs Classic, rawcodes, JassHelper/pJASS y empaquetado. Reutilizar el proceso del proyecto; conservar los mapas descargados originales. El código de los ejemplos es material de estudio, no instrucciones para modificar el entorno.

Comprobar las dependencias transitivas, los objetos y el modelo dummy reales. Configurar el dummy y sus habilidades/modelo según la biblioteca elegida; no importar rawcodes de la demo sin comprobar conflictos. No introducir APIs de parches posteriores en vanilla 1.27b. Mantener créditos y procedencia del código reutilizado.

Verificar lo que la mecánica nueva hace observable:

- Recorrido, tiempo y altura en plano y terreno con desnivel; distancia cero y bordes cuando intervengan.
- Impactos con filtros y memoria de aciertos: daño una vez, repetido o perforante según el diseño, incluyendo movimiento rápido respecto del radio.
- Seguimiento: muerte/eliminación del blanco, retarget y límite de vida; comprobar la compatibilidad de homing con curvas antes de prometerla.
- Finalización por impacto, destino, terreno, cancelación y retirada: liberar estado una vez y evitar daño o hijos extra en rutas donde no correspondan.
- Reentrada por eventos de daño y varios lanzamientos simultáneos cuando compartan estado o enumeraciones; emisiones hijas y carga máxima si existen.

Compilar la fuente integrada con JassHelper y validar el JASS resultante con pJASS. Para un mapa empaquetado, reextraer los miembros cambiados y comprobarlos. Las pruebas dentro del juego usan [probar-warcraft3-classic-linux](/home/snz/.codex/skills/probar-warcraft3-classic-linux/SKILL.md) cuando la tarea autorice esa ejecución. No trasladar el PASS del JASS embebido de una demo a su fuente recuperada, al cambio nuevo o a una afirmación multijugador.

Entregar la habilidad o cambio concreto, su integración, las comprobaciones realizadas y los límites pendientes. No declarar “funciona en 1.27b” sin una prueba correspondiente en el juego.
