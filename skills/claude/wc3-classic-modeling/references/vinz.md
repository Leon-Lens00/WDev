# Perfil técnico: Vinz / Mythic

Nota de recuperación Linux (2026-10-22): perfil histórico conservado. El laboratorio `wc3 reforg` y los artefactos Arcane Lance citados con rutas Windows no se localizaron en la copia recuperada; consultar [entorno-linux.md](entorno-linux.md) antes de intentar acceder a ellos. Las validaciones descritas son registros anteriores, no ensayos repetidos en esta PC.

Estado al 14 de septiembre de 2026: colección ampliada en paralelo a 50 archivos MDX de 14 paquetes, incluyendo variantes, uno denominado HD y colaboración parcial en Voljin. No equivale a 50 diseños independientes de Vinz. El usuario ha usado modelos de Vinz varias veces con buenos resultados en sus mapas. Arcane Lance ya tiene un ejercicio original exportado y revisado visualmente en un visor MDX; la reproducción animada de las referencias y la prueba del ejercicio en juego siguen pendientes.

## Decisiones útiles

- Personajes: Ember Knight combina 3066 triángulos, atlas principal de 512 × 512 y ocho huesos nombrados para la capa. La textura inspeccionada contiene sombras y detalles de armadura. Aplicación: coordinar silueta, textura y movimiento secundario; no atribuir toda la apariencia a densidad de malla. La textura es de Moy, el modelo de Vinz.
- Proyectiles: los nueve Psionic Shots mantienen nueve PE2 y diez estelas con distintas referencias de textura. Aplicación: partir de una familia estructural común y explorar color y materiales; igualdad de conteos no demuestra igualdad de curvas.
- Estelas: Psionic Blue contiene trazos de 0,01, 0,10 y 0,12 segundos y diferentes alturas. Aplicación propuesta: combinar persistencias y grosores. Falta evaluar localmente el resultado en movimiento.
- Impactos: Psionic Blue tiene ventanas de emisión de 100, 150 y 250 ms en varios componentes. La vida de las partículas puede continuar después. Aplicación: controlar por separado emisión, expansión y opacidad.
- Variantes: Cannonball conserva 218 triángulos en cuatro versiones; cambian emisores y secuencias. D Rain solo tiene Stand de 3000 ms. Aplicación: revisar el contrato de animación antes de sustituir variantes.
- Recursos existentes: Fire Missiles y Cannonball descargados no incluyen BLP adicionales y referencian texturas del juego. Aplicación: explorar formas existentes antes de añadir texturas. Una ruta declarada no demuestra uso visible.

No usar las cifras anteriores como límites ni como prueba de rendimiento. Estudiar animaciones en movimiento antes de atribuir anticipación, peso o calidad de curvas al autor.

## Ampliación: mecanismos y cronologías

- Construcción: Eldritch desplaza Foundation durante 4–12 s de Birth, Pool durante 10–17 s y Obelisk 0 durante 42–48 s, con emisiones coordinadas. El cristal usa relojes globales independientes de 8 y 12 s. Aplicación: construir por fases y separar movimiento ambiental. La ficha recomienda 1.31+; no asumir compatibilidad con parches anteriores.
- Mecanismos: Stormforger es un héroe mecánico, texturas de Murlocologist. Contiene acciones alternativas y piezas articuladas también usadas en Death. Su PE1 Uber Spray referencia SharedModels/Lightning2.MDL. Aplicación: revisar subsistemas y dependencias de modelos, no solo BLP. El MDX se lee, pero la relectura de nuestro MDL generado falla PivotPoint: esa copia no está validada para editar.
- Cohetes: Airstrike y Voyager retrasan el humo 300 ms desde Death, elevan la tasa durante 50 ms y luego la reducen. Airstrike separa Trail sin ModelSpace de Propulsion con ModelSpace. Aplicación propuesta: llama local y residuo persistente, con relojes de emisión y vida separados.
- Shock Blast: sus mallas están ocultas en Stand y aparecen en Death. Tiene una animación UV declarada pero no referenciada por capas. Aplicación: analizar visibilidad y referencias antes de atribuir la apariencia a la geometría o UV.
- Judgement: Stand empieza en 1000; el cambio principal de emisiones y un evento SND ocurren en 1800, es decir 800 ms relativos, coincidiendo con el impacto indicado por Vinz. Aplicación: coordinar sonido y efectos en una cronología relativa. No confundir tiempo absoluto de clave con tiempo de espera.
- Colaboraciones: Voljin es de TinkerLord con contribución de Vinz al arma. No usar su cuerpo o animaciones como evidencia de técnica de Vinz.
- Mythicopter: piezas con grupos de una matriz; rotor con ciclo global de 1200 ms. En Attack, Gunstick alcanza su retroceso a 100 ms y Gunloop 1 a 200 ms, con recuperaciones a 900 y 1200 ms. Son transformaciones locales en una jerarquía, no movimientos mundiales independientes. Aplicación propuesta: retroceso por piezas con recuperaciones diferentes. En Death, varios geosets se ocultan a 700 ms aunque la secuencia dura 4000 ms.
- Capa de Ember: la jerarquía se ramifica desde Cape02, no forma una cadena simple de ocho huesos. Los segmentos tienen claves en tiempos distintos durante Walk. Aplicación: estudiar ramificaciones y asignación de vértices antes de replicar un esquema de movimiento secundario; los tiempos por sí solos no demuestran el resultado visual.

## Evidencias y fuentes

Proyecto actual: `C:/Users/Leon/Documents/ChatGPT/wc3 reforg`.

- Índice de toda la biblioteca y nuevas categorías: `research/vinz-lab/INDICE.md`.
- Nuevas fichas: `expansion-proyectiles/ESTUDIO.md`, `expansion-estructuras/ESTUDIO.md`, `expansion-personajes/ESTUDIO.md` y `expansion-efectos/ESTUDIO.md`, relativas al laboratorio `research/vinz-lab`.
- Auditoría de todos los paquetes: `research/vinz-lab/collection_audit.json`.

- Personajes y efectos iniciales: `research/vinz-lab/LECCIONES.md`.
- Proyectiles: `research/vinz-lab/PROYECTILES.md`.
- Datos completos: `research/vinz-lab/analysis/summary.json`, JSON por modelo y `binary_checks.json`.
- Procedencia y hashes: `research/vinz-lab/manifest.json`.
- Contexto público: `research/vinz-hive-investigacion.md`.

Fuentes primarias: [Ember Knight](https://www.hiveworkshop.com/threads/ember-forge-ember-knight.318735/), [Psionic Shots](https://www.hiveworkshop.com/threads/psionic-shots.319594/), [Fire Missiles](https://www.hiveworkshop.com/threads/fire-missiles.313049/), [Cannonball](https://www.hiveworkshop.com/threads/cannonball.315873/).

## Primer ejercicio propio

Se creó `models/arcane-lance/arcane-lance.blend` en el proyecto: núcleo facetado, estabilizadores, estelas de varios grosores e impacto por fases. Blender 5.2.1 LTS localizado en `C:/Program Files (x86)/Steam/steamapps/common/Blender/blender.exe`. Generación, guardado y reapertura realizados; renders de vuelo e impacto inspeccionados. Conjunto de vuelo: 608 triángulos; escena de 90 fotogramas a 30 FPS. Detalles en `models/arcane-lance/NOTAS.md`.

El archivo original de Blender conserva el storyboard con mallas; su revisión nativa está en `models/arcane-lance/release/ArcaneLance.mdx`: MDX800, 320 triángulos, 12 PE2, 3 ribbons, 1 luz y cinco BLP1 originales con mipmaps. Cuerpo y efectos son originales, no recursos de Vinz. El fuente de Blender no reproduce fielmente todos los efectos del MDX.

Resultados transferibles del ejercicio, no reglas atribuidas a Vinz:

- Prueba posterior de Leon: el glow aparecía cuadrado durante vuelo/impacto. Se encontró un defecto del escritor BLP1 propio: alphaBits8 con pictureType5/subtipo0; corregido a4/1. El decodificador del visor ignoraba esos dos campos, por lo que un decode exitoso no bastó. Comprobar cabecera clásica directamente además de píxeles/mipmaps. **Leon confirmó después que la versión corregida se ve bien dentro del juego y aportó captura**; es validación del usuario, no una ejecución nuestra ni certificación entre parches. Evidencia, regresión y diagnóstico en `models/arcane-lance/validation/GLOW-FIX.md`; captura conservada en `glow-square-regression/user-game-fixed.png` dentro de esa carpeta de validación.

- Preferencia confirmada por Leon: secuencias de producción centradas; recorrido externo separado como `Movimiento prueba |`. Revisión de Psionic Blue/Fire Spear: ninguna curva Translation; Cannonball: una clave constante cero. Arcane Lance: ninguna traslación en el MDX. Contrato y otros detalles revisados en `models/arcane-lance/validation/CONTRATO-ANIMACION.md`; el usuario se encarga de probar en juego.

- Una tasa20/s durante50 ms podía no emitir un anillo al evaluar claves con pasos16 ms. Para un destello de cantidad definida funcionó un pulso Squirt. Medir partículas efectivamente creadas, no solo número de emisores.
- Separar Visibility que detiene la emisión de la curva Alpha que apaga las estelas existentes; usar AddAlpha cuando la forma de la textura está en su canal alfa.
- En war3-model4.0.1, declarar referencias ausentes como `null` (Parent, GlobalSeqId, TVertexAnimId); dejarlas undefined produjo ceros y referencias inválidas. La validación binaria independiente lo detectó.
- El visor local necesitó canvas opaco para valorar el brillo aditivo, reloj simulado para ribbons y compensación de traslación ModelSpace. No atribuir fallos del visor automáticamente al modelo. Luz nativa y rotaciones generales ModelSpace siguen sin validación visual en ese visor.

Evidencias: `models/arcane-lance/validation/report.json`, `VISUAL.md`, capturas `native-flight.png`/`native-impact.png` y `viewer/simulation-check.json`. Vuelo650 ms, impacto100/300 ms y desaparición1800 ms revisados. Mapa de ensayo compilado y empaquetado. La ejecución local de Warcraft3.0.0.24268 quedó en inicio de sesión de Battle.net; no se cargó el mapa. No afirmar aceptación100%, equivalencia artística con Vinz, compatibilidad con1.27b ni FPS medidos.
