# Texttags y conversaciones en Classic 1.27b

Consultar para diseñar o depurar texto flotante, párrafos, escritura progresiva y diálogos de una interfaz anterior a Frame API. Separar las restricciones de la API, las observaciones del cliente concreto y las propuestas de implementación.

## Evidencia local y cobertura

Evaluación del 22 de octubre de 2026: 29 casos en Warcraft III Classic 1.27b, CachyOS/Wine con el perfil RenderEdge local, cliente de 1920 × 1080 y vista cinematográfica. Se reutilizaron cinco tags, con un solo tag para el cuerpo de cada caso. Los registros confirman las longitudes solicitadas mediante `StringLength`; las capturas permiten distinguir cadena recibida y texto realmente dibujado.

Mapa `TerrainDev-TextTagLab.w3x`, SHA-256 `da831518beae3dab9a5b42b3685ed6127f7710b86df52511e7b44909f7dfce38`. JassHelper release, pJASS y comprobación del MPQ reextraído pasaron. El ensayo contiene cortes deliberadamente expuestos: 29 capturas no equivalen a 29 casos de render completo.

Procedencia permanente en esta PC:

- Informe: `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system/ESTUDIO-TEXTTAGS.md`.
- Entradas: `evidence/texttag-lab/cases.json` bajo esa raíz.
- Capturas, registros y medidas: `evidence/texttag-lab/run-20261022-144050/`, incluidos `measurements.json` y `TextTagLab-*.txt`.
- Generador y laboratorio: `tools/texttag-fixtures.mjs`, `src/TextTagLab.j` y `src/TextTagCases.j` de esa raíz. Consultar primero su índice CodeGraph cuando corresponda a las instrucciones vigentes del proyecto.

No trasladar los valores de píxeles a otra resolución, fuente, proporción de pantalla, renderizador o parche sin contraste. El título superior del laboratorio quedó parcialmente bajo la barra del escritorio; las áreas del cuerpo medidas estaban enteramente dentro de la pantalla. No se ensayó multijugador ni la creación de 101 tags.

## Lo que cambia las decisiones de diseño

- **No existe un máximo universal de caracteres que garantice caber.** La fuente proporcional, el tamaño, las letras, los espacios y los saltos cambian el resultado. Una cadena íntegra puede dibujarse incompleta.
- La API Classic permite texto y tamaño de fuente con `SetTextTagText`, además de posición, color, visibilidad y ciclo de vida. No expone un ancho/alto de caja ni una consulta de sus dimensiones dibujadas. No inventar setters de ancho ni usar Frame API de parches posteriores en vanilla 1.27b.
- El bloque probado se ancla por abajo a la izquierda: los renglones adicionales elevan su borde superior. El ajuste automático durante la escritura puede mover el texto ya visible. Para mantener una línea superior estable, precomponer y posicionar los renglones o compensar explícitamente la altura.
- Un número fijo de columnas, por ejemplo las 36 del prototipo, es aproximado. Medir por avance de glifos y espacio disponible cuando el diseño necesita precisión; no prometer que cualquier cadena de esa longitud cabe.

## Tamaño GUI frente al nativo

El `Blizzard.j` Classic comprobado convierte:

```text
tamaño_nativo = tamaño_GUI × 0.023 / 10
```

Por ejemplo, GUI 10 corresponde a nativo 0.023; nativo 0.027 corresponde aproximadamente a GUI 11.74. El valor nativo no es una cantidad directa de píxeles ni el tamaño del modelo MDX.

En las muestras siguientes se usaron dígitos, espacios y el marcador final `FIN`, con 40, 80 y 160 bytes ASCII totales. Son ejemplos medidos, no capacidades universales:

| Tamaño nativo | 40 caracteres | 80 caracteres | 160 caracteres | Tinta visible de la muestra de 160 |
|---|---:|---:|---|---|
| 0.018 | 1 renglón | 2 | 4, final visible | 444 × 71 px |
| 0.027 | 2 | 3 | 5, final visible | 434 × 138 px |
| 0.036 | 2 | 4 | 7, final visible | 466 × 257 px |
| 0.045 | 2 | 4 | 6 visibles, final perdido | 483 × 275 px |

Los pasos verticales rondaron 19, 29, 38 y 48 px respectivamente. Las cajas de la tabla miden tinta visible, no el rectángulo interno del motor. El OCR fue auxiliar: falló al reconocer algunos finales y necesitó contraste visual; la separación por filas también puede unir líneas con tildes o caracteres pequeños.

## Ancho, párrafos y recortes observados

- Con nativo 0.027, 77 letras `i` más `FIN` ocupan un renglón y 424 px de ancho. 77 letras `W` más `FIN` ocupan cinco renglones y alcanzan 508 px. Las dos cadenas tienen 80 caracteres y muestran el final.
- Con 157 letras `W` más `FIN`, el final desaparece tras nueve renglones visibles. No usar 508 px como un ancho configurable o umbral exacto: es tinta observada en una muestra concreta.
- Dos líneas explícitas de 70 columnas se convirtieron en seis renglones; cuatro de 35, en cinco. Ocho líneas cortas de 18 columnas permanecieron en ocho, con el final visible.
- A nativo 0.010, cadenas de 128, 256 y 512 bytes con líneas cortas mostraron el final en unas 4, 8 y 16 líneas. El tamaño se eligió para medir capacidad, no por legibilidad para conversaciones.
- La cadena de 1024 bytes llegó con `StringLength = 1024`, pero sólo se vieron unas 25 de las 31 líneas solicitadas, sin `FIN`, aun lejos del borde de pantalla.
- Los casos que se cortaron ocuparon aproximadamente 250–280 px de alto. No se demostró la implementación interna ni se buscó el umbral exacto. Conservar el rango como observación local, no como constante del motor.

Esto separa capacidad de almacenamiento, longitud de entrada y capacidad visual del tag. No intentar resolver un recorte bajando indefinidamente la fuente: paginar o dividir el texto conservando la legibilidad.

## Unicode, formato y límites de las cadenas

- El ensayo español dibujó tildes, ñ, diéresis y signos ¿/¡. Esa frase tenía 78 bytes y 67 grafemas. `StringLength` contó bytes en estas entradas UTF-8; no equiparar bytes con letras visibles. No se acreditaron otros alfabetos ni emoji.
- El salto de línea JASS `\n` y el código `|n` produjeron tres renglones en sus respectivos casos.
- Los códigos `|cAARRGGBB` y `|r` funcionaron en texto estático. Un escritor progresivo debe tratar los códigos como tokens completos y revelar sólo grafemas visibles; cortar esos códigos como letras produciría estados intermedios inválidos.
- La captura del ensayo progresivo se tomó durante un prefijo Unicode. Que aún falte `FIN` en ella no es prueba de truncamiento ni acredita por sí sola la frase final.
- pJASS rechazó el fixture emitido como literal de más de 1023 caracteres, por el riesgo al cargar partidas guardadas. Se mantuvo el control y se construyó la cadena larga mediante fragmentos en ejecución. Ese límite de literal no demuestra un tope de caracteres visibles por texttag; comprobar el diagnóstico exacto del compilador empleado.

## Fuente de los texttags

Ensayo del 30/10/2026 en Classic 1.27b, con una unidad de prueba y Open Sans importada: `MasterFont` en `war3mapSkin.txt` cambió el HUD, pero ni `TextTagFont` ni reemplazar `Fonts\FRIZQT__.TTF` dentro del mapa cambiaron los texttags creados por JASS. Se ven con Friz Quadrata, y `game.dll` contiene ese nombre de archivo. Tratar la fuente de los texttags como no modificable desde el mapa, salvo prueba nueva en motor; no confiar en tutoriales que afirman lo contrario. El estilo disponible es color por letra con `|c`, y brillo o sombra con texttags superpuestos desplazados (cada capa cuenta para el límite de tags). Evidencia: `Proyect/work/titulo-devmission-20261026/RESULTADO.md`, sección v12.

## Cantidad de tags y ciclo de vida

La discusión técnica de [Hive: Local text tags](https://www.hiveworkshop.com/threads/local-text-tags.275280/) describe 100 texttags existentes simultáneamente por cliente, con diferencias entre creación global y local. La evaluación local sólo usó cinco: no volvió a medir ese tope ni prueba seguridad multijugador.

Reutilizar un grupo acotado y liberar los recursos que se poseen cuando termine su ciclo de vida. No confundir ocultar con destruir ni crear un tag por letra. Si se usa `UIText`, revisar además los dummies y asignaciones de su versión concreta. Que un texttag sea presentación no autoriza a crear unidades, temporizadores u otros agentes sólo en un cliente; trazar sus consumidores antes de afirmar sincronización.

## Degradado y texto ligado a piezas (Classic 1.27b, probado en juego)

- Un solo texttag admite degradado horizontal: `|cffRRGGBB` + letra + `|r` por carácter. No hay degradado vertical. Precalcular la cadena fuera del mapa: `StringLength`/`SubString` trabajan en bytes y partirían los caracteres UTF-8.
- Literal JASS limitado a 1023 caracteres: cada letra cuesta 15.
- Para que el texto siga una pieza animada, conservar la unidad como ancla, sin letras en la textura, y copiar su posición con un temporizador. Las funciones que escalan la unidad deben avisar al tag (`SetTextTagText` con tamaño × f).
- Ancho real medido a 1080p: 0,93 × Friz a `size × 1080`, y unos `150 × size` px de desplazamiento a la derecha respecto al cálculo por el borde izquierdo.
- Para desvanecer un tag visible, `SetTextTagColor` no sirve: su alfa no cambia nada, con o sin `|c`. Usar el fundido nativo: `SetTextTagPermanent(t, false)`, `SetTextTagAge(t, 0)`, `SetTextTagLifespan(t, s)`, `SetTextTagFadepoint(t, 0)`. Respeta `|c` y el tag se destruye solo.
- Los texttags se pintan sobre modelos y efectos 3D, pero el filtro de fundido los cubre. Ocultarlos a mano antes de un destello que deba taparlos.

## Elección para conversaciones

Para un diálogo amplio o compacto en el sistema Classic existente, una opción razonable es **marco/retratos MDX + texto dinámico compuesto con fragmentos de texttags reutilizables**:

- Conservar conversación, página y progreso como datos separados de la vista.
- Elegir el ancho útil y una fuente legible; partir por palabras y métricas antes de dibujar. Una palabra excepcionalmente ancha también necesita partición controlada.
- Mantener renglones estables y repartir cada renglón largo en fragmentos contiguos suficientemente cortos para que el motor no vuelva a envolverlos. La unión requiere medir y probar espaciado/kerning, sin suponer que el navegador y la fuente nativa coinciden.
- Mantener la paginación para el texto que exceda el cuadro. En modo compacto reducir primero el cuadro o el contenido por página, sin convertir automáticamente la letra en ilegible.
- Como presupuesto inicial del proyecto se propusieron hasta 4 fragmentos × 3 renglones + nombre + avance = 14 tags. **Es una propuesta aún sin ensayo del renderer completo**, no una cifra exigida o certificada por el motor. Reservar margen para otras interfaces y texto de combate.
- El prototipo evaluado mantiene cinco tags: nombre, tres renglones y avance. No afirmar que el renderer de fragmentos, los modos por mensaje ni su equivalencia con el editor estén implementados por haber terminado el estudio.

Si la fidelidad tipográfica exige una fuente gráfica propia, estudiar un atlas de glifos o un renderer especializado como alternativa. El autor de [PanelText en Panel System](https://www.hiveworkshop.com/threads/panel-system-v2-1.292342/) advierte de mayor coste de recursos y cálculo; [TextSplat](https://www.hiveworkshop.com/threads/textsplat-1-3-2.147358/) expone métricas propias. No se integraron ni validaron esas bibliotecas en el mapa. Su mayor control visual no demuestra menor coste ni compatibilidad con las dependencias actuales.

Diseñar e iterar en el editor con el mismo contrato de datos y métricas; contrastar el lote final en el juego. Una vista web no reproduce por sí sola los límites de tags, el terreno o la proyección del MDX. El defecto de escala/recorte del marco de la copia de diálogo quedó abierto y es independiente de este estudio.

## Fuentes primarias adicionales

- [Character limit, Hive, 2015](https://www.hiveworkshop.com/threads/character-limit.264073/): el autor distingue la cadena íntegra del texto flotante cortado a longitudes variables; la caja interna se plantea como explicación, no especificación numérica.
- [CustomWindow, explicación de Maker](https://www.hiveworkshop.com/threads/customwindow-v1-1-1-2.207526/): advierte del ajuste automático de textos anchos y describe partición por palabras. La referencia es anterior a 1.27b; el efecto se contrastó en la prueba local.

## Composición implementada y avances medidos — 22/10/2026

La copia dialogue-system ya compone3renglones×4fragmentos con un pool fijo14tags (12cuerpo, nombre e indicación), compartiendo dialogue-layout.js con UI Studio y tools/story.mjs. Se probaron conversaciones largas, escritura y uniones. No usar los avances TTF estándar como equivalencia nativa: produjeron huecos entre fragmentos. Se midieron111glifos con8repeticiones en10capturas del cliente1920×1080 a altura0.027. Perfil: /home/snz/Documentos/WarDatsPy/ui-studio/dist/dialogue-font-metrics.js. Datos/método: TerrainDev/dialogue-system/evidence/native-glyph-metrics.json y tools/measure-glyphs.py; capturas válidas metrics-final-00..09.png. i avanza5px, W30px y espacio7px en este perfil. Ancho de tinta y avance no son idénticos; validar contra capturas con tolerancia a bearings. Otros tamaños se interpolan y otras resoluciones no están certificadas. El navegador aproxima las formas de glifos, pero usa los avances compartidos para colocarlos.

El texto original conserva los grafemas; la generación nativa normaliza cada prefijo a NFC para la fuente Classic. Posiciones fijas desde el inicio; no se crean tags por carácter. Colores por parámetro externo; el exportador rechaza pipes de formato salvo |n, que compone como salto. Los nombres se abrevian a un tag de ancho conservador. Capítulo limitado a8190prefijos en arrays separados por slot; inicializadores por bloques .execute para no concentrar todo en un hilo. CodeGraph conserva esas llamadas como candidatas; JassHelper/pJASS y pruebas nativas son evidencia separada.

La unión de texto quedó corregida, pero la unidad que muestra el marco MDX sigue cambiando de aspecto según zona y presentación. No acreditar alineación nativa general a partir del compositor. Dirección ojo→objetivo y SetUnitPosition no resolvieron esa incidencia. Consultar informes/errores/2026-10-22-130405-dialogo-marco-invisible.md y VERIFICACION.md del componente antes de continuar.
