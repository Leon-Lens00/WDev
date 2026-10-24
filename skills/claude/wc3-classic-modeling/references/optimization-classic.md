# Optimización y compatibilidad clásica

Las rutas Windows restantes son referencias históricas; ver [el entorno Linux](entorno-linux.md) para disponibilidad actual. Las pruebas aquí descritas no se han repetido en juego durante la recuperación de la skill.

Hallazgos obtenidos con Leon en personajes S3/TDAU para Warcraft III 1.27b, hasta 2026-09-29. V11 fue confirmada por Leon en juego para TDAU Newborn y Rangedborn. Aplicar los principios a futuros modelos, ajustando límites a su escala y comportamiento.

## Diagnosticar antes de reducir

Medir por separado geometría, rig, curvas, materiales y texturas. Registrar bytes MDX, vértices, triángulos, huesos/helpers, geosets, capas, secuencias y claves Translation/Rotation/Scaling por secuencia. Separar modelo de paquete con texturas; los modelos que usan texturas internas también consumen recursos aunque no adjunten BLP.

Un modelo visible en Magos puede fallar en el juego. Si el MDL funciona y su MDX se deforma, investigar la conversión binaria con un lector y escritor independientes, comparando índices, grupos, jerarquía, pivotes, tracks e intervalos. No culpar al formato MDX ni reducir polígonos como primera solución.

En los pilotos, corregir el orden huesos/helpers resolvió invisibilidad y ordenar secuencias cronológicamente corrigió un fallo intermitente de caminar. Son hallazgos de aquel flujo: comprobar el archivo real antes de aplicar esos cambios a otros exportadores.

El mismo tipo de desorden se reprodujo después en retratos de diálogo Paladín/Tauren: ordenar las claves no bastaba mientras SEQS conservaba un orden diferente de sus intervalos. Ver [diagnóstico y evidencia de reproducción de retratos](portrait-playback-classic.md); no confundir ese fallo con un clip estático o una transición sin mezcla.

## Pose inicial y aparición

Validar Unanimated además de las secuencias. La pose inicial puede mostrarse brevemente al crear la unidad aunque Walk o Stand sean correctas. No aceptar piezas gigantes, picos o posiciones incoherentes en esa pose.

Probar CreateUnit directamente, sin ocultar la unidad ni forzar inmediatamente Stand: esos recursos pueden esconder el defecto. Revisar fotogramas de aparición y transiciones entre animaciones, no sólo secuencias aisladas.

No asumir que Stand debe empezar en cero. Una prueba al desplazar intervalos a cero quedó invisible; Arthas tiene Stand empezando en 3333. Añadir Birth y claves iniciales tampoco corrigió por sí solo el rig defectuoso. Preservar intervalos y orden validados durante la optimización.

En mapas 1.27b, comprobar que `usca` tenga valor 1.00 y se escriba como Real (tipo 1). Un archivo de prueba lo escribió como Unreal (tipo 2) y el editor mostró 0.00. Verificar tanto el dato binario como el valor visible.

## Jerarquía y transformaciones

Eliminar helpers sin recalcular transformaciones cambia la animación. En los pilotos, cadenas de escalas y transformaciones estaban asociadas a deformaciones al aparecer. La solución final preservó matrices mundiales y reconstruyó una jerarquía compacta de huesos deformadores.

Para un padre P y un hijo H, obtener la matriz local como `inverse(W_P) * W_H`. Comprobar que su descomposición TRS reconstruye la matriz: shear significativo puede impedir una representación exacta. No continuar silenciosamente ante matrices no representables.

Si se cambia un pivote a p, compensar la traducción para conservar la matriz: `t' = t - p + RS*p`. La reconstrucción de jerarquía y pivotes puede reducir claves de posición sin sacrificar movimiento. Huesos independientes en espacio mundial pueden servir como referencia de diagnóstico, pero su muestreo denso produjo cientos de miles de claves y no es una salida eficiente por defecto.

Mantener grupos de matrices compactos y válidos. No crear miles de huesos por vértice ni repetir cientos de índices para aproximar pesos. Cualquier cambio de grupos o pesos exige comparar vértices animados.

## Reducir curvas con error controlado

La cantidad de marcas en la línea de tiempo no mide por sí sola calidad ni coste. Contar claves por track y secuencia. Buscar muestreo redundante, tracks constantes y transformaciones que la jerarquía podría expresar de forma más compacta.

Reducir dentro de cada secuencia, conservando claves de inicio/final y sin interpolar entre animaciones independientes. Considerar secuencias globales y propiedades de interpolación antes de tratarlas como tracks locales. Normalizar cuaterniones y mantener continuidad de signo para evitar recorridos incorrectos.

Usar tolerancias relativas a escala y perceptibilidad. El piloto V11 usó rotación 0.0008 rad, posición 0.01 y escala 0.00001 con su reductor específico; son parámetros iniciales para ese flujo, no límites universales.

Tras escribir el MDX, volver a leerlo y comparar posiciones de todos los vértices animados contra una referencia fiable. V11 evaluó 241 tiempos por secuencia; el muestreo no demuestra igualdad entre muestras. Complementar con reproducción visual y juego.

Con altura aproximada 100, los errores máximos muestreados V11 fueron 0.10235 y 0.08155 unidades. Los modelos pasaron de 482520/1130040 claves a 9455/8252. No usar una cantidad objetivo de claves como sustituto del control de error.

## Geometría y materiales

Optimizar primero lo redundante sin alterar el diseño. Fusionar geosets sólo si sus materiales y demás propiedades son compatibles; conservar UV, grupos de huesos, visibilidad y animaciones. En los pilotos se pasó de 4 a 2 y de 20 a 7 geosets, sin reducir geometría.

Para simplificación geométrica, usar una copia comparativa y proteger rostro, silueta, articulaciones, accesorios y costuras UV. Evaluar a cámara de juego y durante movimiento. No perseguir el presupuesto de Arthas para un personaje con necesidades distintas.

La V11 terminó en 1415 vértices/2314 triángulos para Newborn y 3707/4000 para Rangedborn; Arthas completo medido tenía 650/531. El MDX era comparable en peso (249023 y 315615 bytes frente a 303935), pero eso no iguala el coste de renderizado. La geometría de Rangedborn sigue siendo una oportunidad de mejora.

## Texturas opacas y mipmaps

La regla de cabecera BLP1 con alfa de 8 bits de la skill principal se aplica cuando existe transparencia real. Para texturas totalmente opacas se puede retirar ese payload y usar alfa 0, conservando una cabecera coherente con el formato. No quitar alfa porque el nivel principal parezca opaco: revisar todos los píxeles de todos los mipmaps y el material.

V11 usó BLP1 paletizada (compresión 1, 256 colores, pictureType 4/subtype 1), conservando paleta e índices. Se verificó que todo el alfa explícito era 255. Retirarlo ahorró aproximadamente 49.8% en disco sin cambiar resolución ni RGB. No extrapolar ese ahorro a memoria de GPU o FPS.

Mantener cadena completa hasta 1x1: 512x512 tiene 10 niveles, 256x256 tiene 9 y 16x16 tiene 5. Verificar offsets, tamaños, decodificación y aspecto en juego. Reducir resolución o crear atlas es una operación distinta y necesita evaluar calidad y materiales.

Pillow interpretó el alfa original de una BLP de forma distinta a su payload explícito; la igualdad RGBA del decodificador no bastaba. Contrastar cabeceras, datos alfa, RGB y juego si las herramientas discrepan.

Cabeza y cuerpo pueden usar imágenes diferentes por diseño. Comprobar UV y material antes de atribuir su diferencia al render. Esta optimización conservó el color de la primera conversión piloto; no acredita por sí sola fidelidad completa al shader original de Unity.

## Aceptación y evidencia

### Reducción por importancia visual (acordada con Leon)

No asignar la misma resolución a todas las superficies por costumbre. Proteger rostro y detalles identificables; las zonas pequeñas, uniformes o efectos sencillos pueden admitir menos resolución, siempre con comparación visual.

Para Newborn, conservar inicialmente cabeza 512x512 y probar cuerpo 256x256 en una copia paletizada. Preparar cuerpo 128x128 como segunda comparación sólo si se continúa la optimización. No reemplazar la versión aceptada antes de evaluar ambas a cámara de juego y de cerca. Conservar mipmaps completos y rutas coherentes.

Los dos BLP actuales suman 701410 bytes. Cabeza 512 + cuerpo 256 sumarían aproximadamente 439266 bytes, ahorro de alrededor del 37%. Es una estimación de almacenamiento BLP paletizado opaco, no resultado visual validado ni mejora de FPS medida. La reducción de resolución todavía no se ha aplicado a la versión aceptada.

Evaluar compresión JPEG BLP1 en una variante separada de la reducción de resolución, para identificar qué cambio pierde detalle o introduce artefactos. No asumir que siempre pesa menos o que conserva colores exactamente.

Referencia local inspeccionada: `C:/Users/Leon/Desktop/Dev Us Dimensional/Dev Us Dimensional v0.75.w3xTemp/RoyalGlow02.blp`: 68544 bytes (66.94 KiB), 256x256, BLP1 JPEG (compression 0), cabecera alfa 8, pictureType 4/subtype 1, 9 mipmaps. Es un resplandor violeta sobre negro. Pillow mostró alfa 255 en toda la imagen; no se verificó el material que lo usa. Un material aditivo podría eliminar visualmente el negro, pero no darlo por confirmado. Su peso no es un presupuesto obligatorio para piel o rostros. Probar 128/64 para efectos pequeños sólo cuando su degradado y uso real lo permitan.

Conservar fuentes y derivados separados. Entregar métricas antes/después, tolerancias, error medido, MDL/MDX y sus texturas. No borrar fuentes Blender porque una conversión se vea bien.

Probar aparición, Stand, Walk, Attack, Death y otras secuencias existentes, con una y varias unidades; revisar de día y de noche. Conservar personajes rígidos por diseño. No inventar movimiento para completar una lista.

Identificar por separado pendientes funcionales como attachments, eventos, cámaras/retratos y colisiones. Una conversión visual correcta puede no cubrir todas las necesidades de una unidad de mapa.

Reconocer pruebas del usuario como evidencia suya. No afirmar mejora de FPS, estabilidad masiva o multijugador sin pruebas correspondientes. Actualizar conclusiones cuando otro personaje muestre un caso diferente.

## Evidencia local y referencias

Para muertes parciales seguidas de ragdoll, Leon eligió mantener una base Newborn y adaptar la caída por función de huesos, conectándola a la reacción inicial del destino cuando corresponda. Separar muertes explosivas y no sobrescribir una Death completa por costumbre. La primera base articulada V2 está documentada en `/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/animaciones/death-master-v2/TRANSFERENCIA.md`: candidato aplicado a Newborn/Soldier, validación numérica y visual, aún sin prueba nativa confirmada. Su perfil procedural no equivale a una transferencia completa de clip ni a físicas Unity. Leer ese registro antes de reutilizarlo; mapeo de huesos, ejes, empalme y contacto necesitan ajustes por personaje.

Proyecto recuperado: `/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Newborn-WC3-127b`.
Reportes: `informes/jerarquia-v11.json`, `informes/texturas-v11.json`, `informes/comparacion-hive-xgm-v10.json`.
Implementación: `scripts/hierarchy_v11.cjs` y `scripts/opaque_textures_v11.py`; ligados a pilotos y manifiestos, inspeccionar antes de adaptar. Regenerar el rig vuelve a copiar texturas antiguas: aplicar después la optimización de texturas antes del paquete final.
Registro detallado: `skills/claude/optimize-slendytubbies-wc3-127b/references/v11.md`.

Referencias comunitarias estudiadas, no presupuestos obligatorios:

- https://www.hiveworkshop.com/threads/zombie-and-derivatives.247672/
- https://www.hiveworkshop.com/threads/infested-zombie.242317/
- https://xgm.guru/p/wc3/Zombi-rabotnik-hlU
- https://www.hiveworkshop.com/threads/model-optimizer-v1-3-0.323265/
- https://xgm.guru/p/wc3/WC3ModelBatchEditor-f7k
