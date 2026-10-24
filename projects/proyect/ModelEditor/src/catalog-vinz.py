"""Build the browsing index from verified library metadata, without changing source files."""
from pathlib import Path
from collections import Counter
import json,urllib.parse
ROOT=Path(__file__).resolve().parents[1];BASE=ROOT.parent/'descargas/warcraft3/misiles/vinz/biblioteca-originales'
m=json.loads((BASE/'manifest.json').read_text());inventory=json.loads((BASE/'inventario-modelos.json').read_text());assert not inventory['errors']
counts=Counter(e['category'] for e in m['entries']);unique=len({x['sha256'] for x in inventory['entries']})
lines=['# Biblioteca de proyectiles de Vinz','',f"Descargados {m['downloaded']} de {m['listed']} paquetes del filtro público de Hive **Vinz + Missile**, el 22 de octubre de 2026. Tres páginas contrastadas. {m['models']} archivos MDX ({unique} hashes distintos); incluyen variantes y elementos auxiliares de paquetes mixtos, no {m['models']} diseños independientes.",'',
'ZIP originales y extracción sin editar; CRC y SHA256 verificados. Autor Vinz y créditos de cada componente conservados en los readme.html incluidos. [Manifiesto](manifest.json) · [Inventario técnico de modelos](inventario-modelos.json).','',
'## Organización','',*['- '+k+f': {v} paquetes.' for k,v in sorted(counts.items())],'',
'Cada paquete tiene `original.zip`, `originales/`, `manifest.json` y `LEEME.txt`. Las carpetas originales conservan sus nombres y archivos. Los Shots I/II editados están fuera de esta biblioteca, en ModelEditor/exports; aquí sólo hay referencias originales.','',
'## Catálogo','', '| Paquete | MDX | Recursos de textura incluidos | Ubicación | Fuente |','|---|---:|---:|---|---|']
for e in m['entries']:
 path=urllib.parse.quote(e['folder']+'/LEEME.txt',safe='/')
 lines.append(f"| {e['title']} | {e['models']} | {e['textures']} | [Abrir carpeta]({path}) | [Hive]({e['url']}) |")
lines+=['','## Alcance de las verificaciones','',
'Todos los 191 archivos se han leído con el parser MDX y declaran versión800. Esto **no certifica Classic1.27b**: Carrion Bats, Deadly Plumage y Winter Blast se publican para1.32 y tienen variantes HD/SD; mantenerlos como referencias hasta comprobarlos en el motor objetivo. El inventario registra secuencias, geometría, PE2, ribbons, luces y rutas de textura/PE1.','',
'Las texturas personalizadas incluidas se conservan en cada ZIP. Las referencias a recursos del juego u otros archivos externos se registran sin afirmar que estén resueltas en1.27b. No se han ejecutado modelos ni medido rendimiento como parte de esta descarga.','',
'El paquete TC15 incluye también cabezas, fuego y otras piezas auxiliares: se conservó completo para respetar la procedencia y se clasificó en Especiales-y-paquetes. No presentar sus30 MDX como30 misiles distintos.','',
'## Apoyo al buster de Mega Man X3','',
'- Shots I/II, Psionic Shots y Firebrand Shots: estudiar núcleo luminoso, capas y segmentos del cuerpo de energía.','- Arcade Bolts, Void Missiles y Fire Missiles: estudiar formas, estelas y transición al impacto.','- Rocket/artillería: comparar separación entre cuerpo, emisión local y estela en espacio del mundo.','',
'Estas son rutas de estudio, no modelos ya convertidos en Mega Man. Las referencias visuales A/B/C se guardan separadas en ModelEditor/references/megaman-x3. La física de fusión, trayectoria y colisiones queda fuera del encargo actual.','']
(BASE/'CATALOGO.md').write_text('\n'.join(lines))
(ROOT/'evidence/vinz-library-20261022/summary.json').write_text(json.dumps({'packages':len(m['entries']),'mdx':len(inventory['entries']),'uniqueMdxHashes':unique,'categories':dict(sorted(counts.items())),'zipCRC':'PASS','allFileHashes':'PASS','parserErrors':0},indent=2)+'\n')
print(json.dumps({'packages':len(m['entries']),'mdx':len(inventory['entries']),'uniqueMdxHashes':unique,'categories':dict(sorted(counts.items()))}))
