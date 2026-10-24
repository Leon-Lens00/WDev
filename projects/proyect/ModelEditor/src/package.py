"""Package verified derivatives and a Classic-compatible color-to-path helper."""
from pathlib import Path
import json
import zipfile
import hashlib

ROOT=Path(__file__).resolve().parents[1]
colors=ROOT/'exports/shots-vol-i-jugadores'
anchor=ROOT/'exports/shots-vol-i-anclaje'
palette=json.loads((ROOT/'assets/palette.json').read_text())
lines=['// Shots Vol. I by Vinz; edited derivatives for Classic 1.27b.',
       '// Import the three BLPs and desired MDXs using their ShotsTeam paths.',
       '// Select when launching; player color can differ from player slot/team ID.',
       'function ShotsTeamPath takes playercolor color, boolean double returns string']
for p in palette:
    base=f"ShotsTeam\\\\Shot_{p['index']:02}_{p['name']}"
    lines += [f"    if color == ConvertPlayerColor({p['index']}) then",'        if double then',f'            return "{base}_Double.mdx"','        endif',f'        return "{base}.mdx"','    endif']
lines += ['    // Unknown/neutral color: documented fallback to LightGray.', '    if double then','        return "ShotsTeam\\\\Shot_08_LightGray_Double.mdx"','    endif','    return "ShotsTeam\\\\Shot_08_LightGray.mdx"','endfunction','',
          'function ShotsPlayerPath takes player owner, boolean double returns string','    return ShotsTeamPath(GetPlayerColor(owner), double)','endfunction','']
(colors/'ShotsTeamPaths.j').write_text('\n'.join(lines))
(colors/'README.txt').write_text('''Shots Vol. I — pack de colores de jugadores, Warcraft III Classic 1.27b

Autor original: Vinz. Fuente: https://www.hiveworkshop.com/threads/shots-vol-i.315258/
Dar crédito a Vinz. Adaptación local: anclaje frontal y recoloración.
Las máscaras derivan de las texturas de Warcraft instaladas localmente.

24 modelos: 12 simples y 12 Double; MDX800 y MDL editables.
Importar los MDX deseados y las TRES BLP de ShotsTeam con la ruta completa
ShotsTeam\\nombre. Quitar el prefijo war3mapImported del gestor de imports.
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
''')
(anchor/'README.txt').write_text('''Shots Vol. I — anclaje frontal, Warcraft III Classic 1.27b / MDX800
Autor original: Vinz. https://www.hiveworkshop.com/threads/shots-vol-i.315258/
Dar crédito a Vinz. Adaptación local solicitada: punta geométrica en X=0.

12 modelos: seis colores originales, simples y Double. Las texturas originales
son recursos internos del juego, no necesitan imports adicionales.
Importar el MDX que corresponda; el MDL es fuente editable opcional.
Los originales descargados se conservaron intactos fuera de esta carpeta.

Desplazamiento de cuerpo, pivotes y emisores de vuelo; compensación de Death
para conservar el origen del impacto. Los tiempos/curvas originales se conservan
salvo esa compensación. Bounds ampliados sin reducir el sobre original.
No modifica la colisión de ninguna biblioteca ni añade CollisionShapes.
Double conserva dos puntas alineadas en el plano X=0 y separadas lateralmente.
Halos/partículas pueden expandirse alrededor del origen.
Ver informe de validación adjunto para cobertura y límites.
''')
for folder in [anchor,colors]:
    (folder/'VERIFICACION.json').write_bytes((ROOT/'evidence/verification.json').read_bytes())
    (folder/'EVALUACION-COLOR.md').write_bytes((ROOT/'EVALUACION-COLOR.md').read_bytes())
    (folder/'VALIDACION.md').write_text('''# Validación — 22 de octubre de 2026

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
''')
    files=[]
    for p in sorted(folder.rglob('*')):
        if p.is_file() and p.name!='SHA256SUMS.txt':files.append(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p.relative_to(folder)))
    (folder/'SHA256SUMS.txt').write_text('\n'.join(files)+'\n')
    target=folder.with_suffix('.zip')
    with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED) as archive:
        for p in sorted(folder.rglob('*')):
            if p.is_file():archive.write(p,folder.name+'/'+str(p.relative_to(folder)))
    with zipfile.ZipFile(target) as archive:assert archive.testzip() is None
    print(target, target.stat().st_size,hashlib.sha256(target.read_bytes()).hexdigest())
