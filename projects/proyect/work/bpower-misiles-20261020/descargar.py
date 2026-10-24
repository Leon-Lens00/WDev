"""Download the five author-profile maps with explicit Missile dependency evidence."""
from email.message import Message
import hashlib
import io
import json
from pathlib import Path
import re
import time
from urllib.parse import urlparse, urlunparse
from urllib.request import Request, urlopen
from zipfile import ZipFile

ROOT = Path('/home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower')
SELECTED = {'275718': 'missile-gui', '258518': 'hydra', '245470': 'armageddon',
            '245192': 'simple-spell-collection', '243397': 'frozen-orb'}
catalog = json.loads((ROOT / 'recursos-del-perfil.json').read_text())
records = []
for resource in catalog:
    if resource['id'] not in SELECTED:
        continue
    link = next(item['url'] for item in resource['downloads'] if '/resources/' in item['url'] and '/download' in item['url'])
    cached = ROOT / 'paquetes' / (resource['id'] + '-' + SELECTED[resource['id']] + '.zip')
    if not cached.exists():
        cached = ROOT / 'evidencia' / (resource['id'] + '-download.zip')
    payload = cached.read_bytes() if cached.exists() else None
    filename = None
    content_type = 'application/zip' if payload else None
    final_url = link
    if payload is None:
        for attempt in range(6):
            with urlopen(Request(link, headers={'User-Agent': 'Mozilla/5.0', 'Referer': resource['url']}), timeout=35) as response:
                content_type = response.headers.get('content-type', '')
                final_url = response.url
                disposition = Message()
                disposition['Content-Disposition'] = response.headers.get('Content-Disposition', '')
                filename = disposition.get_filename()
                payload = response.read((32 << 20) + 1)
            if 'text/html' not in content_type:
                break
            (ROOT / 'evidencia' / f"{resource['id']}-download-response-{attempt}.html").write_bytes(payload)
            if b'Download will begin shortly' not in payload:
                raise ValueError('Unexpected download page; stop instead of treating it as a map')
            print(f"Archive generation pending: {resource['title']}", flush=True)
            time.sleep(2)
        if 'text/html' in content_type:
            raise ValueError(f'Archive was not generated within six polls: {resource["title"]}')
    if len(payload) > 32 << 20:
        raise ValueError('Download exceeds 32 MiB')
    archive = None
    if payload.startswith(b'PK\x03\x04'):
        packages = ROOT / 'paquetes'
        packages.mkdir(exist_ok=True)
        archive = packages / (resource['id'] + '-' + SELECTED[resource['id']] + '.zip')
        if archive.exists() and archive.read_bytes() != payload:
            raise ValueError(f'Refusing to replace a different package: {archive}')
        archive.write_bytes(payload)
        with ZipFile(io.BytesIO(payload)) as package:
            maps = [i for i in package.infolist() if i.filename.lower().endswith(('.w3x', '.w3m')) and not i.is_dir()]
            if len(maps) != 1 or maps[0].file_size > 32 << 20:
                raise ValueError(f'Expected one bounded example map, got {len(maps)}')
            filename = Path(maps[0].filename).name
            data = package.read(maps[0])  # CRC checked; no arbitrary archive path extraction.
            for info in package.infolist():
                if info.filename.lower().endswith('/readme.html') and info.file_size < 1 << 20:
                    (ROOT / 'evidencia' / (resource['id'] + '-readme.html')).write_bytes(package.read(info))
    else:
        data = payload
    if not filename or Path(filename).name != filename or not filename.lower().endswith(('.w3x', '.w3m')):
        raise ValueError(f'Unexpected map filename: {filename!r}; {content_type}')
    if not data.startswith(b'HM3W') and b'MPQ\x1a' not in data[:8192]:
        raise ValueError(f'Not a recognized map: {filename}')
    folder = ROOT / 'mapas' / (resource['id'] + '-' + SELECTED[resource['id']])
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / filename
    if target.exists() and target.read_bytes() != data:
        raise ValueError(f'Refusing to replace a different original: {target}')
    target.write_bytes(data)
    record = {'resource_id': resource['id'], 'title': resource['title'], 'author': 'BPower',
              'source_url': resource['url'], 'download_url': urlunparse(urlparse(link)._replace(query='')),
              'downloaded_date': '2026-10-20', 'file': str(target.relative_to(ROOT)),
              'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest(),
              'package_file': str(archive.relative_to(ROOT)) if archive else None,
              'package_sha256': hashlib.sha256(payload).hexdigest() if archive else None,
              'content_type': content_type, 'selection_evidence': 'Explicit Missile use/dependency in the resource description; source verification pending.',
              'verification': 'Downloaded; map header recognized. Not game-tested.'}
    records.append(record)
    (ROOT / 'manifest.json').write_text(json.dumps({'profile_url': 'https://www.hiveworkshop.com/members/bpower.216087/#resources',
        'profile_resources_reviewed': len(catalog), 'maps': records}, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps(record, ensure_ascii=False), flush=True)
(ROOT / 'manifest.json').write_text(json.dumps({'profile_url': 'https://www.hiveworkshop.com/members/bpower.216087/#resources',
    'profile_resources_reviewed': len(catalog), 'maps': records}, indent=2, ensure_ascii=False) + '\n')
