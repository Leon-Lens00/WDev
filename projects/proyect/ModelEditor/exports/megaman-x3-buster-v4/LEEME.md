# Mega Man X3 — Buster V4

Revisión del 23/10/2026 para Warcraft III Classic 1.27b, MDX800. Interpretación3D de las muestras X3 confirmadas; geometría y máscaras propias, con estudio técnico de los originales de Vinz. Las formas y referencias Mega Man X3 corresponden a Capcom. Vinz es autor de sus referencias, no de estos modelos nuevos.

A: creciente blanco con corona rosa, copa azul y punta luminosa. B: orbes individuales verde/naranja; cian como variante extra. C: centro rosa, aros verdes con textura animada y punta clara. Partículas de plasma locales y residuos traseros en espacio mundial; las estelas se extienden al mover el efecto.

| Carpeta | Contenido / uso |
|---|---|
| A-Buster | Carga A individual |
| B-Orbes-individuales/Verde y Naranja | Dos disparos independientes para tu sistema |
| B-Orbes-individuales/Cian | Variante adicional |
| B-Grupo-visual | Verde y naranja con giro local preanimado, opcional |
| C-Buster-fusionado | Núcleo final C, sin satélites |
| C-Grupo-visual | C con cuatro satélites alternos verde/naranja, opcional |
| C-Flash-union | Destello breve para el momento de unión |

Elige los individuales para controlar órbita y unión en tu física. Los grupos son alternativas visuales precompuestas; no superponer C-Grupo-visual y C-Buster-fusionado. El pack no detecta unión, no mueve su raíz y no incorpora daño/colisión. Giro local de grupos/aros:960ms por vuelta. El grupo B usa los dos colores de la referencia; el cian no se incorpora a ese grupo.

Cada carpeta contiene MDX, MDL y sus nueve BLP. Conservar exactamente X3BusterV4\Nombre.blp al importar las texturas; sólo una copia por ruta al combinar piezas. Importar el MDX elegido y usar su ruta de importación en el sistema. MDL es fuente editable, no hace falta importarlo al mapa. No sustituir texturas de V1..V3: el prefijo V4 es independiente.

Frente del cuerpo de vuelo en X=0, dirección +X; raíz fija en origen. Los halos y partículas son elementos visuales, no colisiones. El flash se expande alrededor del origen. Birth/Stand/Death disponibles; mantener Stand durante vuelo y Death al retirar. Los modelos no hacen la transición lógica de dos disparos a C: tu sistema instancia C al fusionarlos. El flash es finito incluso en Stand.

MUESTRAS.png y FRENTE-3D.png son capturas de MDX en visor real. MOVIMIENTO.gif y EN-JUEGO.png proceden del ensayo nativo. VALIDACION.md separa sus alcances. manifest.json contiene hashes por archivo; sources.json fija los generadores. Originales/V1/V2/V3 conservados aparte.

El conjunto C es la opción más costosa:9198triángulos y23emisores. El núcleo C solo:6366triángulos y7emisores. Elegir individuales/núcleo cuando la lógica ya añade satélites. No se ha hecho ensayo de carga masiva ni benchmarkFPS.
