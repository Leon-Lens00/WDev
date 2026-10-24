# Shots I y II: color con núcleo claro

Fecha: 2026-10-22. Warcraft III Classic 1.27b, MDX800.

El recoloreado inicial convertía las texturas a gris por máximo RGB y sustituía todos los colores por RGB puro del jugador. Al perder el componente neutro original, las capas aditivas no podían reconstruir el centro blanco, especialmente cuando un canal quedaba en cero. Ocurría en los dos volúmenes; los originales descargados no estaban afectados.

La revisión conserva Flare y star5tga originales, y recolorea la textura Glow manteniendo sus diferencias de saturación/intensidad y su alfa. Los colores de malla, segmentos de partículas y luz mantienen la componente neutra de la fuente y trasladan la parte coloreada al tono del jugador. El azul conserva los campos RGB de su fuente. La variante gris conserva detalle de intensidad; los tonos oscuros conservan el núcleo claro y no se interpretan como superficies de RGB uniforme. No son doce rellenos planos.

## Entregas

- Vol. I: `exports/shots-vol-i-organizados-brillo/`, 24 variantes de jugadores: 12 simples y 12 dobles; más 12 anclados con colores originales.
- Vol. II: `exports/shots-vol-ii-organizados-brillo/`, 12 variantes de jugadores simples; más 6 anclados con colores originales. Sin doble por elección expresa del usuario.
- Cada carpeta de color incluye MDX, MDL, las tres texturas que realmente usa, créditos y rutas de importación. Los helpers JASS de selección por playercolor siguen siendo válidos, pues las rutas de modelo se conservaron.
- Conservar los originales de Vinz y dar crédito a Vinz. Máscaras base proceden de Warcraft instalado localmente. Los ZIP originales y los paquetes anteriores siguen intactos.

## Comprobaciones

36 MDX de jugadores reabiertos con lector independiente y MDL comparados completos. 5988 poses comparadas contra las bases ancladas: geometría, jerarquía, pivotes, curvas, filtros, tamaños, emisión, velocidades, alfa, eventos, bounds y anclajes de emisores exactos; sólo se permiten nombre, colores y rutas de textura. 108 referencias de textura completas; hashes de ambos archivos originales verificados.

Doce glows BLP1 con alfa8, type4/subtype1 y mipmaps hasta 1×1; offsets, tamaños y datos contrastados. Alfa base idéntico; error máximo de cuantización RGB 5/255. Flare/star se copian byte a byte. Los recursos propios usan rutas ShotsTeam / ShotsVolII separadas.

Galería final compilada con JassHelper/pJASS y 67 miembros reextraídos exactamente, mapa SHA256 `ab41ef6dec0961214c9209bc2125571c330781718b9f2a9c30cc428ce01a6a4b`. En 1.27b se observaron los 36 modelos en tres grupos y escala 1.5. Capturas en `evidence/brillo/gallery-vol-i-simple.png`, `gallery-vol-i-doble.png`, `gallery-vol-ii-simple.png`. Se observó el impacto de los doce colores de Vol. II y su desaparición, registrado en `anim-vol-ii/death-*.png`. La toma corta de Birth no aisló claramente la transición y no se cuenta como una validación visual independiente; sus curvas y poses sí están contrastadas.

Las muestras intermedias (reintroducción de blancos sobre máscaras grises y primera rotación relativa del tono) se conservaron como estudio. No son el resultado recomendado.

Estado: Tested in map para la galería y casos descritos. No se ha integrado el modelo en el sistema de colisiones del mapa ni medido rendimiento o multijugador. El anclaje corresponde a la punta geométrica; halos e impactos pueden extenderse alrededor del origen. La luz está comprobada en datos, sin medición fotométrica separada.

## Reproducción

Con las bases ancladas disponibles y verificadas: `textures-gradient.py` con el Python/Pillow aislado, `build-gradient.cjs`, `verify-gradient.cjs`, `organize-gradient.cjs` con Node fijado. El organizador exige una salida nueva para conservar revisiones. CodeGraph se consultó antes y después de los cambios dentro de ModelEditor; excluye assets/build/evidence/exports. Los JASS incrustados en Python se compilan por separado, no reciben cobertura semántica JASS de este índice.
