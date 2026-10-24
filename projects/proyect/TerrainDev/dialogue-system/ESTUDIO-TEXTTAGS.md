# Evaluación de texttags para las conversaciones

Evaluación terminada el 22/10/2026, America/Lima. Objetivo: decidir cómo componer párrafos amplios y cuadros compactos en Warcraft III Classic 1.27b sin depender de predicciones del navegador.

## Evidencia y alcance

- Mapa de laboratorio separado: TerrainDev-TextTagLab.w3x, SHA256 da831518beae3dab9a5b42b3685ed6127f7710b86df52511e7b44909f7dfce38.
- Build20261022-144024-939708: JassHelper release, pJASS, conservación de cabecera y miembros por reextracción correctos.
- [29 capturas y registros frescos](evidence/texttag-lab/run-20261022-144050/), [entradas](evidence/texttag-lab/cases.json), [mediciones](evidence/texttag-lab/run-20261022-144050/measurements.json). Cada registro confirma exactamente la longitud en bytes solicitada y cinco texttags persistentes. Se reutiliza un solo tag para el cuerpo en cada caso.
- Cliente1920 × 1080, perfil local Wine/RenderEdge habitual, interfaz cinematográfica. Texto medido lejos de los límites de pantalla; no se acredita otra resolución, motor, fuente ni multijugador. La barra del escritorio tapa parcialmente el título superior del laboratorio; las áreas de texto y sus marcadores quedan enteramente en pantalla.
- La primera ejecución no se usa para las medidas finales: el capturador no normalizaba la barra final de WINEPREFIX y el bloque largo podía salir por arriba. Se corrigió el capturador y se ancló el cuerpo más abajo. La segunda pasada capturó29/29 casos. Juego PID 558533 cerrado tras confirmación visible y S, sin SIGTERM.

## Resultado principal

No hay un número universal de caracteres que garantice caber en un texttag. Influyen la fuente proporcional, las letras concretas, el tamaño, los espacios, los saltos y el área que el motor dibuja. El texto puede llegar completo a JASS y quedar incompleto en pantalla.

Un texttag es un bloque con anclaje inferior izquierdo en esta prueba: añadir renglones eleva su borde superior, manteniendo aproximadamente el borde inferior. Durante la escritura, un salto automático puede desplazar el texto ya escrito. Separar los renglones mantiene el diálogo estable.

La API Classic expone tamaño de fuente mediante SetTextTagText y posición/color/visibilidad/ciclo de vida. No ofrece ancho/alto de caja ni una consulta del tamaño dibujado. Esto se contrastó por CodeGraph con common.j y Blizzard.j exactos. El índice tiene cobertura parcial; las pruebas del motor y el builder se ejecutaron aparte.

## Tamaños y texto con espacios

Estas muestras contienen dígitos, espacios y un marcador FIN, con40/80/160bytes ASCII totales. Son ejemplos reproducibles, no una capacidad garantizada para cualquier frase. El ancho es tinta visible, no la caja interna del motor. Los renglones se comprobaron en las imágenes y mediante el paso vertical aproximado del raster; la segmentación de tinta sola puede unir renglones con tildes o letras pequeñas.

| Tamaño nativo | Equivalente GUI/BJ |40caracteres|80caracteres|160caracteres|Tinta en la muestra160|
|---|---:|---:|---:|---|---|
|0.018|7.83|1renglón|2|4, FIN visible|444×71px|
|0.027|11.74|2|3|5, FIN visible|434×138px|
|0.036|15.65|2|4|7, FIN visible|466×257px|
|0.045|19.57|2|4|6visibles, FIN perdido|483×275px|

Blizzard.j aplica tamañoNativo=tamañoGUI×0.023/10. El parámetro0.027 no equivale a27píxeles ni al tamañoGUI0.027. En este cliente el paso entre renglones ronda19/29/38/48px respectivamente; depende del perfil.

## Ancho y palabras

A tamaño0.027, la muestra de 80 caracteres formada por77letras i y FIN ocupa un renglón, con424px de tinta. La misma cantidad con 77 letras W y FIN ocupa cinco renglones y alcanza508px de ancho. Ambas muestran FIN. La muestra con 157 W y FIN pierde el final después de nueve renglones visibles.

Por tanto,36 columnas por renglón, como en el prototipo, es una aproximación de composición; no una garantía para cualquier cadena. Cambiar sólo el número de columnas no permite lograr un renglón arbitrariamente largo. Tampoco debe tomarse508px como un ancho configurable o un límite exacto universal: es el máximo observado de tinta en estas muestras.

## Párrafos, altura y longitud

- Una entrada de dos líneas explícitas de70columnas acaba dibujada en seis renglones por el ajuste automático.
- Cuatro líneas de35columnas acaban en cinco renglones; ocho líneas cortas de18columnas permanecen en ocho, con FIN visible y225px de alto.
- A tamaño0.010, las cadenas de128, 256 y 512 bytes con renglones explícitos cortos muestran FIN: aproximadamente4,8 y16renglones.512bytes ocupa178×175px de tinta. Ese tamaño se usa como ensayo, no como recomendación de legibilidad para el diálogo.
- La cadena de 1024 bytes llega con StringLength=1024, pero sólo se ven unas25 de las31 líneas solicitadas y falta FIN. Ocupa178×274px de tinta y sigue dentro de la pantalla: no es un recorte por el borde del cliente.
- También se pierde el final en160caracteres a0.045, aunque160caracteres con espacios a0.027 se ve completo. Esto distingue límite visual de un supuesto tope fijo de caracteres.

Se observa saturación vertical en torno a250–280 px en los casos que se cortan. No se ha identificado la implementación interna ni medido un umbral exacto con búsqueda binaria. No presentar ese rango como una constante de todas las resoluciones.

## Formato y escritura

- Las tildes, ñ, diéresis, ¿ y ¡ del ensayo español se dibujan correctamente. La frase usa78bytes y menos caracteres visibles: StringLength cuenta bytes en estas entradasUTF8. No se ensayaron otros alfabetos ni emoji.
- Tanto el saltoJASS\\n como |n producen tres renglones en los casos correspondientes.
- Los códigos |cAARRGGBB y |r funcionan en el tag estático probado. Estos códigos consumen bytes y no deben revelarse parcialmente durante una animación; el escritor actual de texto plano necesitaría tokenizarlos si se habilita formato enriquecido.
- El ensayo de escritura captura un prefijo Unicode progresivo, reutilizando el mismo tag. La captura tomada a los dos segundos no prueba por sí sola la frase final; no se cuenta como corte del motor que todavía falte FIN en ese prefijo.

## Cantidad de tags y fuentes web

Los hilos primarios de autores de sistemas y respuestas de Hive distinguen cantidad de instancias y longitud de texto:

- [Local text tags, discusión de 2016](https://www.hiveworkshop.com/threads/local-text-tags.275280/): describe100 texttags simultáneos por cliente y la diferencia entre creación local y global. La prueba actual utiliza sólo cinco: no ensaya crear 101ni acredita sincronización multijugador. No basar el diseño en un tag por letra ni asumir que ocultar equivale a destruir.
- [Character limit, reproducción de 2015](https://www.hiveworkshop.com/threads/character-limit.264073/): el autor registra cortes a distintas longitudes y confirma que la cadena íntegra aparece mediante otro canal. La explicación de una caja interna se plantea como hipótesis; no es una especificación numérica del motor.
- [CustomWindow, explicación del autor Maker](https://www.hiveworkshop.com/threads/customwindow-v1-1-1-2.207526/): advierte del ajuste automático de renglones anchos y describe partición por palabras. Es una referencia anterior a1.27b; se contrastó el efecto en nuestra ejecución.
- [TextSplat1.3.2](https://www.hiveworkshop.com/threads/textsplat-1-3-2.147358/) y [PanelSystem2.1, PanelText](https://www.hiveworkshop.com/threads/panel-system-v2-1.292342/): alternativas basadas en recursos gráficos y métricas de fuente. Sus autores ofrecen ancho/alto o fuentes propias, con más recursos y trabajo por carácter. No se instalaron ni se certificó su compatibilidad con el mapa.

No confundir100 tags con100 caracteres, ni el límite de literalJASS con el área visible. El primer fixture largo fue rechazado por pJASS: los literales de más de 1023 caracteres son peligrosos al cargar partidas guardadas. Se construyó la cadena larga mediante fragmentos en ejecución, conservando la validación. Esto permitió medir1024bytes en el tag sin desactivar el control.

## Decisión para la interfaz de diálogo

Estamos listos para pasar al diseño con un contrato claro:

1. Conservar conversación y párrafos completos como datos; paginar antes de dibujar y no recortar silenciosamente texto.
2. Elegir tamaño legible y ancho útil del texto por separado del tamaño del cuadro. El modo compacto debe reducir el cuadro o la cantidad de texto por página antes de reducir excesivamente la fuente.
3. Medir por avance de glifos y espacio disponible; el conteo de caracteres solo no basta con una fuente proporcional.
4. Para renglones como los de la referencia, componer varios fragmentos contiguos en un pool reutilizable, controlando su ancho para que el motor no vuelva a envolverlos. Como presupuesto inicial: hasta4fragmentos×3renglones+nombre+avance=14 tags. Es una propuesta de implementación, aún no ensayada; no una exigencia fija del motor.
5. Mantener la posición superior estable mientras aparecen letras. No crear tags por letra. La implementación actual conserva cinco tags: nombre, tres renglones y avance.
6. Incorporar al editor el ancho medido, alto, páginas, tamaño y coste de tags; avisar cuando una composición depende de fragmentación no disponible en el renderer actual. Primero diseño en el editor, después comprobación del lote final en juego.

Los modos por mensaje amplio/compacto y el renderer de fragmentos siguen pendientes de implementar. El defecto independiente de escala/recorte del marco permanece en [su incidencia](../../informes/errores/resueltos/2026-10-22-130405-dialogo-marco-invisible.md). Esta evaluación no lo corrige ni declara lista la integración final del mapa.
