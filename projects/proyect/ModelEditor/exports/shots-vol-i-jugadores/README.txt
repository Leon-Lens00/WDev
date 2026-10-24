Shots Vol. I — pack de colores de jugadores, Warcraft III Classic 1.27b

Autor original: Vinz. Fuente: https://www.hiveworkshop.com/threads/shots-vol-i.315258/
Dar crédito a Vinz. Adaptación local: anclaje frontal y recoloración.
Las máscaras derivan de las texturas de Warcraft instaladas localmente.

24 modelos: 12 simples y 12 Double; MDX800 y MDL editables.
Importar los MDX deseados y las TRES BLP de ShotsTeam con la ruta completa
ShotsTeam\nombre. Quitar el prefijo war3mapImported del gestor de imports.
Los archivos MDL son fuentes, no hace falta importarlos al mapa.
Conservar las BLP compartidas: los 24 modelos dependen de las tres.

ShotsTeamPaths.j devuelve el path según playercolor. Ejemplo al lanzar:
    set path = ShotsPlayerPath(GetOwningPlayer(caster), false)
Pasar path a la API real del sistema de proyectiles de tu mapa.
Este helper no cambia física/colisiones ni se integró en TerrainDev.
Para un color común por equipo, pasar ese playercolor a ShotsTeamPath.
No confundir índice del jugador, alianza y color asignado.
El proyectil ya creado conserva su variante si luego cambia el color del jugador.
No se usan APIs Blz ni otros parches modernos. Fallback neutral: gris claro.

El plano frontal geométrico queda en X=0; Double tiene una punta a cada lado.
Los halos y partículas de impacto pueden expandirse alrededor del punto.
No hay CollisionShapes; la colisión efectiva pertenece al sistema del mapa.
Púrpura, marrón y verde oscuro usan la paleta real; su brillo será menor.
Ver informe de validación adjunto para cobertura y límites.
