# Warcraft UI Studio

Editor local para diseñar interfaces de **InventorySys 1.4.1 / UserInterface 1.0.6**, de TriggerHappy, destinadas a Warcraft III 1.27b. Abre `Abrir UI Studio.cmd` y visita http://127.0.0.1:4317. Requiere Node instalado; no necesita instalar paquetes ni conexión a Internet.

## Diseñar y entregar

Para cerrar por completo: guarda el diseño, ejecuta `Cerrar UI Studio.cmd` y cierra la pestaña. Cerrar solamente la pestaña deja el servidor local activo. El cierre identifica exclusivamente el proceso Node que ejecuta el `server.mjs` de esta carpeta; no detiene otras aplicaciones Node. Para volver a usarlo, ejecuta `Abrir UI Studio.cmd`.

1. Parte de los 74 elementos reconstruidos desde el código del mapa o crea un proyecto vacío.
2. Selecciona elementos en el lienzo o en Capas. Arrastra para mover y usa los ocho tiradores del marco para redimensionar. Las medidas se actualizan durante el gesto. Mayús permite selección múltiple; arrastrar un recuadro desde una zona vacía selecciona los elementos contenidos. El nombre del grupo pliega sus capas; **Todo** selecciona los resultados mostrados de ese grupo. La búsqueda encuentra nombres e identificadores, incluso dentro de grupos plegados.
3. Añade botones, textos, ventanas e imágenes. Selecciona entre las 52 texturas recuperadas; el campo rawcode permite indicar otros destructibles existentes en tu mapa.
4. Usa **Probar** para simular enlaces de acciones. La simulación no ejecuta lógica del juego.
5. En **Exportar vJASS**, elige **Guardar entrega en carpeta local**. Se crea una carpeta fechada dentro de `exports/` con el JSON editable, `UIStudioLayout.j` y `Integracion.txt`. También hay descargas individuales.
6. Entrega el JSON para adaptar el sistema conservando identificadores y callbacks. **Abrir** permite recuperar ese diseño. El autoguardado del navegador es una comodidad, no sustituye esta copia.

Ctrl+Z deshace; Ctrl+Mayús+Z rehace; Ctrl+D duplica; Supr elimina; las flechas desplazan; Mayús+flecha usa un paso mayor. Los controles bloqueados no se arrastran ni eliminan. El filtro de grupos sólo cambia qué ves en el editor; la casilla Visible se guarda en el diseño.

El botón de luna/sol cambia entre tema claro y oscuro y recuerda tu elección. **Biblioteca** e **Inspector** muestran u ocultan cada panel; **Solo lienzo** (F) oculta ambos. En ventanas pequeñas se abren como paneles superpuestos. Las propiedades se organizan en secciones plegables.

Las medidas se presentan en **píxeles del diseño**: el origen está arriba a la izquierda y el tamaño de referencia es 1600 × 900 o 1200 × 900. No son los píxeles de la ventana ni del zoom. El selector **Unidades** permite usar las coordenadas originales de UserInterface; el JSON y vJASS siempre conservan esas coordenadas normalizadas.

Seleccionar varios elementos crea un marco común para moverlos y escalarlos. El escalado conjunto conserva separaciones, proporciones y tamaño relativo de los textos. Los elementos bloqueados u ocultos quedan fuera de esta transformación. Los marcos conservan siempre su proporción; Mayús conserva la proporción al escalar un elemento individual. **Esc** cancela un gesto en curso y deshacer revierte el gesto completo.

**Seleccionar** (V) permite editar; **Mano** (H) permite desplazar la vista ampliada. También puedes mantener Espacio y arrastrar, o usar el botón central del ratón. Ctrl+rueda acerca o aleja alrededor del puntero. Al volver de **Probar**, se recupera la selección anterior.

**Encajar** (Mayús+1) muestra el lienzo completo; **Selección** (Mayús+2) amplía el conjunto seleccionado. El porcentaje de zoom es relativo a la vista encajada. Al ampliar, usa las barras de desplazamiento para recorrer el lienzo.

## Correspondencia con Warcraft

Las coordenadas del archivo son las de UserInterface: X crece a la derecha, Y hacia arriba. La pantalla se representa entre −1 y 1. Los botones originales mantienen sus fórmulas y sus índices: 6 columnas × 5 filas de inventario y 14 posiciones de equipo. La forma visible de las ventanas se estima a partir de los vértices de los modelos MDX recuperados; las dimensiones que toma `createEx` no son directamente el rectángulo visible. Los marcos mantienen la proporción de su modelo.

El JSON es el contrato completo de diseño. La biblioteca exportada contiene datos y fábricas de controles, **no modifica automáticamente el W3X**. La integración sustituye las llamadas originales de creación por las fábricas, conserva iconos dinámicos, callbacks, índices y objetos seleccionables, y adapta las posiciones que `show()` y los tooltips vuelven a escribir. Los enlaces de acciones son metadatos hasta conectarlos con las funciones del mapa.

El héroe es una guía 2D, no un render del MDX. El texto usa una fuente de aproximación y sus cajas no recortan ni distribuyen texto en Warcraft. El orden de capas es una ayuda del editor; el motor depende de profundidad/modelos. Colores de unidades y sombras/modelos se verifican en el juego. Cambiar a 4:3 permite revisar la distribución, pero no recalibra por sí solo las constantes de proyección del mapa. No se promete equivalencia píxel a píxel.

La guía **?** del editor describe controles directos, componentes que requieren lógica adicional y eventos que el sistema no proporciona. No se añaden Frame API ni eventos de ratón de parches modernos.

## Verificación

- `node --test tests/core.test.mjs`: geometría, índices, intercambio JSON, rechazo de entradas inválidas y escape del exportador.
- `node validate-export.mjs`: prepara el diseño inicial y un arnés de compilación en `test-results/` con las bibliotecas recuperadas en el directorio de análisis vecino.
- El export inicial se compiló con JassHelper y pasó pJASS contra la toolchain local de 1.27b. No se probó dentro de Warcraft ni con dos clientes.
- UI comprobada en navegador: crear texto, editar propiedades, arrastrar, duplicar/eliminar, deshacer, autoguardado y simulación de páginas. Los resultados adicionales de la entrega están en `test-results/qa.md`.
- `node --test tests/*.test.mjs`: incluye las pruebas de límites, anclajes, escalado conjunto, tipografía y conversión de unidades de `geometry.js`. La revisión de uso y sus capturas están en `test-results/usability-audit/informe.html`.

Recursos procedentes del mapa suministrado y de la instalación local de Warcraft; `catalog.json` conserva rawcode, ruta y procedencia. El catálogo es local: no se publicaron ni subieron los recursos. Fuente del sistema: https://www.hiveworkshop.com/threads/inventory-equipment-ui-system-v1-4-3.291826/ (la versión 1.4.1 se conserva para el objetivo clásico).

Iconos del editor: Lucide Static 1.49.0, incluidos localmente con su licencia en `dist/assets/ui/LICENSE.txt`. No requieren acceso a una CDN.

## Calibración con TerrainDev · 21 de octubre de 2026

La vista **Warcraft 1.27b · calibrado** usa las capturas reales de TerrainDev a 1920 × 1080, en el perfil Classic/RenderEdge local. La interfaz proyectada ocupa una zona central más estrecha y se sitúa por encima de la consola nativa. **Coordenadas completas** conserva la representación anterior. Cambiar la vista no altera los valores que exporta vJASS.

**Captura del juego** superpone la captura local usada como referencia. La raza del marco y el terreno pertenecen a esa captura; no son una simulación del motor. Los marcos nuevos se rasterizaron con los vértices, UV y materiales de los MDX originales, usando los atlas locales. En modo **Probar**, el tooltip aparece al seleccionar una casilla y sigue las fórmulas del callback original. Su contenido sigue siendo texto de ejemplo del diseño, no datos leídos de una partida.

Se calibró el anclaje de los textos respecto de la línea base y la guía del modelo del héroe. La fuente y el héroe continúan siendo aproximaciones: el diseñador no ejecuta el MDX animado del personaje. Cuatro centros de botones medidos están a menos de cinco píxeles de la captura de referencia. Otros formatos, campos de visión y clientes necesitan su propia comprobación.

Proyecto editable de referencia: `exports/TerrainDev-calibrado-20261021/`. Las exportaciones anteriores se conservan. Código de calibración: `dist/projection.js`; pruebas: `tests/projection.test.mjs`. La edición, selección, conversión del inspector, movimiento y escalado usan la misma transformación. `node --test tests/*.test.mjs` cubre 16 pruebas.

El proyecto fuente, las capturas y el constructor de la copia integrada se encuentran en `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration/`. Las fuentes anteriores del diseñador están respaldadas allí en `studio-before/`.

## Afinado del diálogo, 22/10/2026
Vista gameplay: modelPreviewRect ajusta arte/retratos con perfil medido en1920×1080; separa ese ajuste de las anclas UIText y no cambia JASS. Nombre factor1.37 e indicación0.017/[Esc] como renderer;36tests PASS. Detalles/evidencias: /home/snz/Documentos/ChatGPT/Proyect/work/dialogue-fine-20261022/AFINADO.md. Perfil en dist/assets/dialogue/model-preview-profile.json. Texto y tipografía siguen aproximados fuera de las métricas/escala contrastadas.

## Conversaciones: retratos MDX y transiciones ·22/10/2026

El espacio Conversaciones reproduce MDX/BLP reales del marco y bustos Paladín/Tauren.
Cuerpo fijo en pose de reposo; cuello/cabeza/gestos con reposo/habla, automático
al escribir. Escala/desplazamiento por retrato,6tiempos en JSON, línea/estática/
revelado y selector de fase/instante permiten revisar el resultado aquí. No hay
scissor que oculte salidas del modelo. El fondo es una captura, no terreno en vivo.
Las imágenes son diseño; para mapa se exige modelo registrado. JSON no reconstruye
W3X automáticamente.41tests Node PASS. Contrato/build y evidencia actual en
/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/dialogue-system/evidence/RETRATOS-ANIMADOS.md.
El visor local5.12 y licencia están en dist/assets/dialogue/vendor/.
