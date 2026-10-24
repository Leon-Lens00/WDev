"""Build a local texture catalogue from the inspected map; never changes an MPQ."""
import json
import pathlib
import subprocess
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent
SOURCE = ROOT.parent / 'analysis/inventorysys-1.4.1'
OUT = ROOT / 'dist/assets'
OUT.mkdir(parents=True, exist_ok=True)
CACHE = ROOT / '.cache'
CACHE.mkdir(exist_ok=True)
MPQ = pathlib.Path('C:/Users/Leon/Downloads/mpqeditor_en_v3.6.0.868/x64/MPQEditor.exe')
GAME = pathlib.Path('C:/Users/Leon/Desktop/Warcraft III 1.27')
objects = json.loads((SOURCE/'reports/objects-w3b.json').read_text(encoding='utf-8'))
catalog = []
default_count = 0
for obj in objects:
    fields = {m['field']: m['value'] for m in obj['mods']}
    path = fields.get('btxf', '')
    if not path:
        continue
    raw = obj['id'] if obj['id'].strip('\0') else obj['base']
    relative = pathlib.Path(path.replace('\\', '/'))
    source = SOURCE / 'extracted' / relative
    required = raw in ['dbnk', 'D201', 'D202', 'D203', 'D204', 'B00H', 'B00G', 'D009']
    if not source.exists() and not required and default_count >= 28:
        continue
    if not source.exists():
        default_count += 1
        source = CACHE / relative
        for archive in ['war3.mpq', 'War3x.mpq']:
            if source.exists():
                break
            subprocess.run([str(MPQ), 'extract', str(GAME/archive), path, str(CACHE), '/fp'], capture_output=True)
    if not source.exists():
        continue
    try:
        image = Image.open(source).convert('RGBA')
        image.save(OUT/f'{raw}.png')
        catalog.append({'id': raw, 'name': relative.stem.replace('BTN',''), 'path': path,
                        'preview': f'assets/{raw}.png', 'width': image.width, 'height': image.height,
                        'source': 'map' if str(source).startswith(str(SOURCE)) else 'game'})
    except Exception as exc:
        print(raw, str(exc))
(ROOT/'dist/catalog.json').write_text(json.dumps(catalog,ensure_ascii=False,indent=2),encoding='utf-8')
print(f'{len(catalog)} textures converted; source files unchanged.')
