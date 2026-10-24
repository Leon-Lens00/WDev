# Validación — 22 de octubre de 2026

Destino: Warcraft III Classic 1.27b, MDX800. Autor original: Vinz.
Estado: Tested in map para las escenas descritas; no certifica colisiones/LAN.

36 MDX y sus compañeros MDL reabiertos y contrastados. 11628 poses; error
máximo 0.000002981, punta máxima Birth/Stand X=0. Birth además acotado de
forma continua según las curvas y jerarquía reales. Emisores de impacto,
luz y evento conservan posiciones; originales verificados por SHA256.
Sólo en MDL se normalizan bits implícitos de tipo y orden de curvas por tag.

Mapa de ensayo final: 36c445d288631cb9326da1eab9fc6a970609d9926699be0dff95716b8da6401d.
JassHelper/pJASS correctos; 39 miembros reextraídos exactamente. Se observaron
los 24 modelos de jugadores, originales simples Blue/Red, anclajes simples
Blue/Red y un prototipo TC en unidades roja/azul. Birth/Stand/Death visibles;
escalas 0.5, 1.5 y 3 en los ensayos. El impacto conserva estrellas con el pack
fijo; TC las sustituye por resplandores. La luz se revisó estructuralmente,
sin medición fotométrica individual de cada color.

ShotsTeamPaths.j se validó con pJASS. La integración en la API concreta del
sistema del mapa queda aparte. No se ensayó colisión, combate, FPS ni LAN.
Los halos y partículas de impacto pueden expandirse alrededor del origen.
No se comprobó herencia de color de efectos sueltos AddSpecialEffect.

Datos numéricos adjuntos: [VERIFICACION.json](VERIFICACION.json).
Las capturas, fuentes y registro completo permanecen en el workspace original,
ModelEditor/VALIDACION.md y ModelEditor/evidence; no están incluidos en este ZIP.
