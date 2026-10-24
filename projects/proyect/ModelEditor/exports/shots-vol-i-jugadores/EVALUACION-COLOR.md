# Shots Vol. I — elección de color

Objetivo comprobado: Warcraft III Classic 1.27b, MDX800, doce colores de jugador. No trasladar los 24 colores ni APIs Blz de parches posteriores.

**Elección: doce variantes fijas, seleccionadas automáticamente al lanzar por `GetPlayerColor`.** Se generan simples y Double: 24 modelos que comparten tres texturas. El jugador no necesita elegir un archivo manualmente si su sistema resuelve el color al crear el proyectil.

| Parte de Shots | Color de equipo nativo | Consecuencia para este modelo |
|---|---|---|
| Malla y capas luminosas | Texturas reemplazables 1/2 | Cambia las texturas/lectura de UV. Preservar sus máscaras requiere reconstruir materiales; no basta con activar una casilla. |
| Partículas PE2 (estrellas, grumos, vuelo y chorro) | ReplaceableId 2 | Sustituye la textura por TeamGlow. La estrella deja de usar su máscara de estrella; no es un tintado arbitrario de la textura original. |
| Luz Lite | Color RGB/curvas propios | No tiene ReplaceableId/playercolor en su estructura; activar TC de malla/partículas no cambia ese color. |
| Efecto creado con AddSpecialEffect | No recibe jugador/color en la firma Classic | No asumir que conoce al lanzador. Los modelos en unidades pueden usar SetUnitColor; el contexto de efectos requiere ensayo específico. |

Fuentes: estructura real de los 12 archivos y lectores locales war3-model 4.0.1 / mdx-m3-viewer 5.12.0; common.j Classic (GetPlayerColor, ConvertPlayerColor, SetUnitColor, AddSpecialEffect). Tutorial y ensayo publicado: [Teamcolor Particles, Hive](https://www.hiveworkshop.com/threads/teamcolor-particles.226244/), especialmente la sustitución completa de la textura, referencia válida de textura y restricciones de filtros.

## Pack fijo

Paleta medida en TeamColor00..11 de `war3.mpq` local, con hashes en assets/palette.json. Se conserva el RGB real, incluidos los tonos oscuros de púrpura, verde oscuro y marrón. No se les aumenta artificialmente el brillo; su legibilidad a cámara de juego debe revisarse visualmente. Brillos aditivos/solapados pueden blanquear el núcleo.

Para recolorear todo el efecto, se neutralizaron Flare, star5tga y Blue_Glow2 mediante máximo RGB, conservando forma/intensidad máxima/alfa. Se mantienen cantidades, tamaños, velocidades, tiempos, filtros y geometría. Se tiñen geoset, los tres segmentos de cada emisor y la luz con la paleta. Estas texturas son exclusivas del pack de jugadores; el de anclaje conserva las originales.

El color visual se resuelve por **playercolor**, no por índice del jugador ni número de alianza. Si varios jugadores deben compartir un color por equipo, el mapa debe definir ese color común y pasarlo al resolver. Si se cambia el color después de disparar, una variante fija ya creada conserva el color con el que nació; sólo los siguientes disparos usan el nuevo.

## Estado verificable

Generados 12 modelos de anclaje y 24 de jugadores. Verificación de 11628 poses: error máximo respecto de la transformación esperada 0.000002981; contraste de evaluadores 0.000000209; máximo frontal Birth/Stand 0. Originales conservados por SHA256, MDX reabierto exactamente completo, MDL contrastado con tolerancia de formato decimal. Emisores de impacto/luz/eventos mantienen posiciones. No equivale todavía a aprobación visual del ensayo.

Ensayo final: `build/visual-20261022c/`, con prototipo TC sobre unidades roja/azul y comparaciones con los originales. Las variantes cargaron en 1.27b y se capturaron Birth/Stand/Death; el impacto confirma pérdida de la estrella en el prototipo TC. Estado: Tested in map para la escena descrita en [VALIDACION.md](VALIDACION.md), sin certificar colisiones ni multijugador. La luz se validó en los campos del modelo, sin medición fotométrica separada.
