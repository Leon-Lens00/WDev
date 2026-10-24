# Contratos de terreno v1

`examples/terrain/scene.schema.json` define la entrada. `ReadSpec` valida además orden, límites, coordenadas de 128 unidades, radio de unidad, perfiles permitidos y hash del mapa. Las rutas relativas se resuelven respecto al JSON.

El perfil `tropical-v1` conserva el tamaño y la paleta del template de Leon. No es un compilador de cualquier bioma: la paleta incorrecta se rechaza. El camino es una polilínea con banda suavizada; la máscara orgánica y el relieve se resuelven por reglas. MarkovJunior decide material/ocupación mediante patrones 2 × 2 de la muestra. Las cuatro etiquetas son claro/suelo, vegetación, roca y árbol. La altura numérica se resuelve después. Esta separación evita multiplicar los estados WFC por cada elevación y recurso.

## Motor

`EngineRequest`: Width, Height, Seed, SampleWidth, SampleHeight, Sample (enteros en orden y/x), Fixed (-1 libre), Steps y Tries. Dimensiones de 2 a 256; 2 a 16 etiquetas, hasta 100.000 pasos y 64 intentos. El proceso tiene además un límite de 120 segundos. El host genera `result.xml` con las reglas efectivamente ejecutadas y devuelve `wc3-mj-result-v1`: revisión, semilla, dimensiones, pasos, states y diagnostics. Nunca obtiene estados de capturas de pantalla.

`Allowed` es opcional: una máscara de bits por celda para etiquetas 0–15; cero no restringe. El host convierte dominios a reglas `in/out` de MarkovJunior y comprueba que la salida los respete; rechaza dominios incompatibles con `Fixed`. `whole-map-restyle` añade la etiqueta 4 (agua/suelo muy bajo), fija su máscara al original y permite 0–3 en tierra. Así la abundancia de mar no se interpreta como abundancia de claros vacíos. El resto de las etiquetas mantiene su significado.

El modo completo exige `sample == edit == límites W3E`, sin rectángulos protegidos ni traslado de cascada. Regenera los objetos de las familias naturales seleccionadas sobre tierra firme; conserva objetos de otras familias, plantaciones de costa y las 192 piezas de la cascada. Fija el terreno bajo esos objetos con una transición suave. La validación compara sus coordenadas y soporte con el original. La estructura de islas, cámaras, inicio, regiones y triggers sigue siendo la del template artístico, no un mapa melee equilibrado.

Las colocaciones nuevas con huella 2×2 usan centros desplazados 32 unidades respecto a la cuadrícula 64 de las huellas 4×4. El ajuste precede al cálculo de Z y a la comprobación del camino. Se comprobó por guardado nativo de ZPvp/ZPms y B000. Las frecuencias de especies se ponderan con todas las colocaciones de la muestra; escala y variación provienen de donantes reales.

`manifest.json` v1 registra hashes de mapa y miembros, importados, revisión del motor, frecuencias y adyacencias de muestra/salida. `report.json` v1 contiene cambios, protección, camino, composición, duración y método de sombras. La validación estructural no declara aceptación visual ni de juego.

La revisión upstream lleva el parche `sample-bounds-v1`: se recorren SMX × SMY, no las dimensiones de salida. Se registran conteos de patrones 2×2, etiquetas y adyacencias; las restricciones condicionan la distribución final. `timings_ms` separa lectura/catálogo/muestra, motor, terreno/decoración, capas espaciales y exportación. El 23/09/2026 Leon excluyó expresamente las sombras de esta entrega.

## Catálogo e importaciones

`wc3-catalog-v1` contiene rawcode, tipo/base, campos resueltos, modelos por variación, texturas, hashes, procedencia local, escalas observadas y huellas viva/muerta. Una huella nula representa ausencia de bloqueo en ese estado. Los importados ya presentes se conservan byte por byte.

`transfer` admite recursos personalizados de una variación, de tipo destructible o doodad, con MDX 800 y dependencias TEXS. Copia definiciones sin inferir tipos binarios, resuelve TRIGSTR, importa modelos/texturas y asigna rawcodes/rutas nuevos ante colisiones. Rechaza perfiles con bases modificadas, varias variaciones o attachments pendientes de resolver; no promete copiar efectos arbitrarios. Nunca extrae recursos del juego al repositorio.

## Composición

La fuente es una anotación rectangular del conjunto artístico y su soporte de terreno. Las piezas conservan su transformación relativa y su altura respecto al soporte trasladado; la traslación XY se alinea a 128. La banda exterior une el soporte con el terreno generado. La reserva impide decoración adicional dentro del conjunto. La desembocadura debe conservar el plano de agua: v1 rechaza traslaciones Z. `composition.json` registra límites, desplazamiento, piezas y política de altura. No reorienta ni deforma automáticamente el conjunto.

## Editor y juego

Las huellas estáticas están en WPM; árboles y demás huellas dinámicas se superponen solo para la prueba de conectividad. Se comprueban caminos con radio de unidad y sin cortar esquinas diagonales. World Editor ajusta los destructibles con huella a una cuadrícula de 64: el generador aplica ese ajuste antes de medir alturas y colisiones.

La generación produce SHD provisional explícitamente identificado. `bake` incorpora un horneado real de World Editor dentro de la región editable y su minimapa regenerado. Exige el mismo W3E y colocaciones; admite únicamente redondeo de Z de hasta 0,002. Preserva el DOO y los disparadores originales, sin incorporar normalizaciones ajenas del editor. El mapa de prueba `harness` es una copia separada con instrumentación JASS; los mapas finales conservan los disparadores editables del template.


## Contratos de recomposición v2

Entrada: `wc3-scene-spec-v2`, `mode: whole-map-recompose`, `shadows: omit`. El perfil exige todo el donante tropical, hash fijo, seis IDs únicos y anotaciones alineadas a 128. Los giros elegibles son solo `[0]`; no se aceptan rotaciones no comprobadas. La biblioteca guarda cada pieza original y su pivote; la posición local se obtiene restando el pivote. El layout guarda traslación, anclajes, núcleo, reserva, radios, enlaces paisajísticos y rutas de 32 unidades.

`adjustments` es un mapa creationNumber → desplazamiento XY local. Solo admite los adornos de acceso comprobados (ZRrs/ZRrk/ZRbs/B001), desplazamientos alineados a 128 y hasta 256 por eje dentro del núcleo. Conserva el Z relativo al suelo. Los diez ajustes del puente son explícitos en el ejemplo y el validador espera sus valores exactos; no se retira ninguna de las 794 piezas.

La geografía se propone por semilla con un presupuesto de 64 candidatos: permutación, desplazamiento de posiciones, tamaños diferentes, enlaces orgánicos y pequeños islotes. Cada núcleo trasplantado mantiene su soporte original; su borde se funde con terreno nuevo. Mar exterior a -192, superficie tropical obtenida de Water.slk (-89,6). Las orillas someras se distinguen del mar profundo. El agua profunda debe continuar bloqueada tras guardar en el editor.

MarkovJunior ejecuta WFC 2×2 sobre una muestra de 192×96 extraída del donante completo. Se excluyen interiores de composiciones del patrón de vegetación libre. La máscara fija de agua procede de las alturas nuevas. Estados, petición, XML y resultados quedan en `engine/`. La decoración usa familias y distribuciones del donante, respeta núcleos y reservas de recorridos y conserva fases de huella y orientación fija.

Capas escritas: W3E, DOO, WPM, SHD, W3I, Units.doo, W3C, JASS, minimapa BLP y marcador MMP. W3R vacío, WTG y WCT se conservan; las 17 cámaras conservan nombres, con destinos nuevos también en el script. El guardado nativo recompila esas coordenadas desde las fuentes editables. El autor y cadenas originales se conservan.

`report.json`: estado estructural, tiempos, piezas, decoración, miembros y motor. `layout.json`: transformaciones, intentos/rechazos, IoU y rutas. `validation.json`: comprobación de archivo real reextraído; no aprueba imágenes ni apertura nativa. `editor-audit` compara contra una copia realmente guardada: terreno exacto, objetos por identidad y Z ≤0,002, fuentes y llamadas espaciales conservadas, rutas válidas sobre WPM nativo y cero celdas de mar totalmente profundo abiertas. La clasificación de mar usa los cuatro vértices para excluir celdas de transición costera. MMP conserva identidad/tipo/color y admite como máximo un píxel por eje, diferencia medida de proyección/redondeo nativo; WPM, BLP, contador de guardado y comentarios se informan por separado.

Pruebas: `WC3_RECOMPOSE_SPEC`, `WC3_WHOLE_SPEC` y `WC3_TERRAIN_SPEC` activan integraciones reales. El validador rechaza copias corrompidas de terreno, soporte, objetos, IDs, importaciones, cámaras, inicio, script, pathing y sombras. La evaluación de diez semillas conserva rechazos de restricciones, sin confundir errores de implementación con semillas inválidas. Tres candidatas se repiten en carpetas limpias y se comparan archivos, miembros, layout y estados del motor.
