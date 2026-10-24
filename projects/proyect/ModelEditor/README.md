# ModelEditor — Warcraft III Classic 1.27b

Herramientas y derivados de modelos. Objetivo: MDX versión 800. Fuentes de Vinz intactas en `../descargas/warcraft3/misiles/vinz/shots-vol-i/`; procedencia/hashes en su manifest.json. Dar crédito a Vinz al usar los derivados. Las máscaras base proceden de la instalación local de Warcraft, no son assets originales del agente.

## Revisión vigente de color y brillo

Usar [Vol. I con brillo](exports/shots-vol-i-organizados-brillo/) y [Vol. II con brillo](exports/shots-vol-ii-organizados-brillo/). Cada colección incluye colores originales anclados y el pack de jugadores revisado, por tipo y color, con recursos propios. Vol. I: simple y doble; Vol. II: sólo simple. Los originales descargados y las revisiones anteriores se conservan.

El primer pack eliminaba los tonos neutros del núcleo al aplicar RGB puro y grises a todas las máscaras. La revisión conserva las máscaras originales Flare/star y el gradiente de brillo de Glow, recoloreando su tono por jugador. Ver [REVISION-BRILLO.md](REVISION-BRILLO.md).

Para reproducir la nueva fase, después de disponer de los anclajes verificados: ejecutar `src/textures-gradient.py` con el Python/Pillow aislado; `src/build-gradient.cjs` y `src/verify-gradient.cjs` con Node fijado; luego `src/organize-gradient.cjs` en una salida nueva. Los scripts anteriores se conservan para reproducir sus revisiones históricas; no regeneran la revisión de brillo.

## Colección anterior organizada para elegir modelos

Usar [shots-vol-i-organizados](exports/shots-vol-i-organizados/): `Colores-de-jugadores` y `Colores-originales`, cada pack dividido en `Misil-simple` / `Misil-doble` y luego una carpeta por color. Cada color incluye MDX, MDL, sus texturas en sus rutas internas, créditos y `IMPORTAR.txt`. Los 36 modelos conservan sus bytes verificados; los recursos compartidos se repiten para que cada carpeta sea independiente. Para importar varios al mismo mapa basta una copia de cada textura por ruta.

El manifiesto de la colección registra hashes y procedencia de las texturas originales extraídas de los MPQ Classic. `src/organize.cjs` reproduce la organización en una salida nueva, sin sobrescribir una colección revisada. Los paquetes planos siguen siendo las entradas reproducibles del proceso de construcción y las pruebas anteriores.

## Componentes

- `src/model.cjs`: lectura/escritura MDX/MDL, evaluación de poses, relectura completa exacta del MDX y lector adicional war3-model.
- `src/anchor.cjs`: anclaje frontal del cuerpo/vuelo; compensación de Death conservando impacto en origen. Double conserva las dos puntas, en el mismo plano frontal, a ambos lados del origen.
- `src/textures.py`: paleta extraída de TeamColor00..11 y copias grises de las máscaras originales. BLP1 alfa8/type4/subtype1, mipmaps completos y píxeles reabiertos.
- `src/build-shots.cjs`: 12 derivados de anclaje y 24 variantes de jugadores. El pack de jugadores aplica únicamente cambios de color/texturas sobre la base ya anclada.
- `src/verify-shots.cjs`: 36 modelos, preservación estructural, curvas, puntos de impacto y poses por secuencia; contraste con otro lector/evaluador. Acepta sólo normalización de flags de tipo y orden de tracks en el MDL.
- `src/fixture.py`: generador del ensayo independiente, con controles de reextracción. El JASS dentro de strings no recibe análisis semántico JASS del grafo; se compila/valida con JassHelper y pJASS reales.

## Reproducir

Node fijado disponible: `/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/runtime-linux/node-v22.14.0-linux-x64/bin/node`.

Python/Pillow aislado: `../work/shots-vol-i-origen-20261022/plot-env/bin/python` (requirements conservados en ese directorio). Las fases son dependientes: detenerse si una falla.

1. Ejecutar `src/textures.py` con ese Python.
2. Ejecutar `src/build-shots.cjs` con Node 22.
3. Ejecutar `src/verify-shots.cjs` con Node 22.
4. Para reconstruir el ensayo, `python ModelEditor/src/fixture.py NOMBRE-NUEVO` desde la raíz del proyecto; elegir directorio nuevo si cambia la fuente JASS. Usar el lanzador `FrozenThone/scripts/wc3.py play` sólo después de verificar el empaquetado.

## Índice CodeGraph

Raíz mínima autorizada: `/home/snz/Documentos/ChatGPT/Proyect/ModelEditor`. Se inicializó con `codegraph init --yes` tras crear runtime.cjs; consultas MCP verificaron fuentes reales. No existía índice ancestro del componente: `~/.codegraph` contiene datos globales/telemetría, no una base del proyecto.

Excluye `exports`, `assets`, `evidence`, `build`, `viewer`, node_modules y cachés. Perfil: JS/Python estándar, sin perfil JASS; dependencias externas del runtime se leen directamente y los require dinámicos son frontera explícita. Los MDX, archivos del juego y evidencia no se indexan. Consultar por MCP y revisar avisos de vigencia tras cambios.

## Límites del anclaje

El cambio alinea el frente geométrico con X=0. No modifica colisiones del sistema del mapa. Un halo translúcido o las partículas de un impacto pueden extenderse alrededor del origen: no son el cuerpo ni una esfera de colisión. Birth/Stand/Death conservan sus tiempos y formas relativas; Death lleva la contracción final al punto de impacto original. El sobre conservador de bounds no se reduce respecto del original.

La verificación de archivos/poses no acredita por sí sola aspecto en juego, rendimiento o multijugador. Consultar `EVALUACION-COLOR.md` y `evidence/` para el estado real del ensayo.

## Biblioteca original de Vinz y referencias X3

[Catálogo de Vinz](../descargas/warcraft3/misiles/vinz/biblioteca-originales/CATALOGO.md):50 paquetes del filtro público completo Vinz+Missile,191 MDX originales leídos y conservados con ZIP/recursos/créditos/hashes. Seis categorías funcionales. No son191 diseños distintos ni una certificación en1.27b. `src/vinz-library.py`, `inventory-vinz.cjs` y `catalog-vinz.py` documentan la adquisición e inventario.

[Selección del buster X3](references/megaman-x3/SELECCION.md): A básico, B dos proyectiles previos, C resultado fusionado. Física fuera de alcance; no confundir las muestras originales con modelos MDX creados.

## Buster de Mega Man X3 — v1

[Pack de siete componentes](exports/megaman-x3-buster-v1/LEEME.md): pulso cargado, orbes individuales verde/naranja/cian, grupo orbital opcional, núcleo fusionado y flash. [Muestras reales](exports/megaman-x3-buster-v1/MUESTRAS.png) y [validación](exports/megaman-x3-buster-v1/VALIDACION.md). Geometría y máscaras propias; interpretación3D de la guía confirmada, sin física. MDX800 y prueba local enClassic1.27b.

Reproducción: textures-x3.py → build-x3.cjs → verify-x3.cjs; fixture-x3.py construye el laboratorio en una copia. runtime-x3.py usa prefijo propio. identify-x3.py y capture-x3.py actúan sólo sobre su ventana, en pantalla3/DP-1 según AGENTS.md. preview-x3.py produce las láminas de capturas ya verificadas. El GIF fuente no es la preview3D.


## X3 — revisión anterior V3

[Pack V3](exports/megaman-x3-buster-v3/LEEME.md): A/C30% más anchos, orbes25%, núcleo blanco y partículas traseras continuas en espacio mundial, con residuos breves. Fuentes build-x3-v3.cjs/verify-x3-v3.cjs; máscaras propias en assets/x3-v3. V1 y V2 conservadas por separado. [Validación](exports/megaman-x3-buster-v3/VALIDACION.md).

[Visor3D orbital](viewer/x3/index.html): MDX reales, V2/V3, originales Vinz para estudio local, rejilla/ejes/origen, Birth/Stand/Death y movimiento de demostración. Servidor opcional en http://127.0.0.1:8764, LEEME del visor contiene comando de reapertura. Carpeta generada excluida del índice; fuentes viewer-x3.js/html y pack-viewer-x3.cjs sí indexadas.

fixture-x3-v3.py crea una galería compilada aparte; runtime-x3-v3-ydwe.py lanza por YDWE.exe -war3 -loadfile en prefijo propio, EnableHost0, un jugador sin LAN. identify-x3-v3.py y capture-x3-v3.py verifican identidad y pantalla3/DP-1. La galería opcional -move usa umvs300: umvs0 permitió cambiar etiquetas pero casi no actualizó el cuerpo visual, comprobado con control de JASS idéntico. Esto no modifica la física de TerrainDev. Evidencia en evidence/x3-v3/movement-control.json.

## X3 — revisión vigente V4

[Pack V4](exports/megaman-x3-buster-v4/LEEME.md): creciente blanco/rosa con copa azul en A; orbes individuales verde/naranja y cian extra; B opcional de dos orbes; C rosa con aros verdes finos y conjunto opcional con cuatro satélites. Máscaras/geometría propias, estelas y residuos continuos, raíz inmóvil y frenteX0. Ocho componentes independientes con MDX/MDL y nueveBLP por carpeta. V1..V3 conservadas. [Muestras](exports/megaman-x3-buster-v4/MUESTRAS.png), [movimiento nativo](exports/megaman-x3-buster-v4/MOVIMIENTO.gif), [validación](exports/megaman-x3-buster-v4/VALIDACION.md).

[Estudio completo Vinz](references/vinz-estudio-v4/ESTUDIO.md):191MDX/50paquetes, diferencias por modelo y personalidad de cada familia.13 previews parciales por dependencias explícitas ausentes; no se afirma compatibilidad Classic de toda la colección por ser MDX800. Originales intactos. Atlas en viewer/vinz-study-v4/.

[Visor orbital V4](viewer/x3-v4/index.html) con referenciaX3, V3/V4 y controles de cámara/animación/movimiento. Abrir mediante src/serve-model-previews.py; el servidor sólo escucha loopback y escribe URL/identidad en evidence/x3-v4/viewer-server-active.json (puerto elegido porSO). Reinicializar en frío puede tardar; una relectura tras cargar recuperó la vista en las pruebas.

Reproducción: Python/Pillow aislado src/textures-x3-v4.py; Node fijado src/build-x3-v4.cjs y verify-x3-v4.cjs; pack-viewer-x3-v4.cjs. fixture-x3-v4.py compila y reextrae20miembros de una copia. runtime-x3-v4-ydwe.py lanza un jugador/sinLAN, perfil privado EnableHost0. identify/capture-x3-v4.py comprueban PID/inicio/prefijo y pantalla3; captura final comprueba foco en cada frame. Física y lógica de fusión TerrainDev fuera del cambio. Véanse los límites de rendimiento/validación del pack.
