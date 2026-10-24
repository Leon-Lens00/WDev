"""Extract selected map members, recover WCT source, validate compiled JASS."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import struct
import subprocess
import sys

ROOT = Path('/home/snz/Documentos/ChatGPT/Proyect/descargas/warcraft3/misiles/bpower')
WORK = Path('/home/snz/Documentos/ChatGPT/Proyect/work/bpower-misiles-20261020')
LAUNCHER = '/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py'
INVENTORY = '/home/snz/.codex/skills/build-warcraft3-vjass-127b/scripts/map_inventory.py'
spec = importlib.util.spec_from_file_location('map_inventory', INVENTORY)
inventory = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inventory)

if __name__ == '__main__':
    manifest = json.loads((ROOT / 'manifest.json').read_text())
    results = []
    for record in manifest['maps']:
        identity = record['resource_id']
        original = ROOT / record['file']
        assert hashlib.sha256(original.read_bytes()).hexdigest() == record['sha256']
        extract = ROOT / 'extraidos' / identity
        extract.mkdir(parents=True, exist_ok=True)
        result = subprocess.run([sys.executable, LAUNCHER, 'wc3ctl', 'extract', str(original),
            '--pattern', 'war3map.j,war3map.wct,war3map.wtg,war3map.w3i,war3map.w3e,war3map.w3u,war3map.w3a,war3map.wts,war3map.imp',
            '--out', str(extract), '--json'], capture_output=True, text=True, timeout=45)
        (WORK / f'{identity}-extraccion.json').write_text(result.stdout)
        if result.returncode or not (extract / 'war3map.j').exists():
            raise ValueError(f'Extraction failed: {identity}: {result.stderr} {result.stdout}')
        wct = inventory.analyze_wct_bytes((extract / 'war3map.wct').read_bytes())
        assert wct['trailing_bytes'] == 0
        (extract / 'wct-decodificado.json').write_text(json.dumps(wct, indent=2, ensure_ascii=False) + '\n')
        sources = ROOT / 'fuentes' / identity
        sources.mkdir(parents=True, exist_ok=True)
        blocks = []
        for index, text in [('global', wct['global_custom_script'])] + [(f'trigger-{t["index"]:04d}', t['text']) for t in wct['triggers']]:
            if not text.strip():
                continue
            target = sources / (index + '.j')
            target.write_text(text, encoding='utf-8')
            versions = re.findall(r'library\s+Missile\s*/\*\s*(?:version\s+|v)([\d.]+)', text)
            if '// Name: Missile' in text and not versions:
                versions = re.findall(r'^// Version:\s*([\d.]+)', text, re.M)
            blocks.append({'file': str(target.relative_to(ROOT)), 'sha256': hashlib.sha256(target.read_bytes()).hexdigest(),
                           'lines': len(text.splitlines()), 'missile_version': versions,
                           'libraries': re.findall(r'^\s*library(?:_once)?\s+(\w+)', text, re.M),
                           'scopes': re.findall(r'^\s*scope\s+(\w+)', text, re.M),
                           'structs': re.findall(r'^\s*(?:private\s+|public\s+)?struct\s+(\w+)', text, re.M)})
        pjass = subprocess.run([sys.executable, LAUNCHER, 'pjass', str(extract / 'war3map.j')], capture_output=True, text=True, timeout=45)
        (WORK / f'{identity}-pjass.log').write_text(pjass.stdout + pjass.stderr)
        map_info_version = struct.unpack_from('<I', (extract / 'war3map.w3i').read_bytes())[0]
        terrain = (extract / 'war3map.w3e').read_bytes()
        terrain_version = struct.unpack_from('<I', terrain, 4)[0] if terrain[:4] == b'W3E!' else None
        summary = {'resource_id': identity, 'title': record['title'], 'map_info_version': map_info_version,
                   'terrain_version': terrain_version, 'wct_version': wct['version'], 'wct_trailing_bytes': wct['trailing_bytes'],
                   'wct_recovered_blocks': len(blocks), 'blocks': blocks,
                   'embedded_jass_pjass_exit': pjass.returncode, 'original_hash_unchanged': hashlib.sha256(original.read_bytes()).hexdigest() == record['sha256'],
                   'game_tested': False, 'vjass_recompiled': False}
        results.append(summary)
        (ROOT / 'analisis.json').write_text(json.dumps(results, indent=2, ensure_ascii=False) + '\n')
        print(json.dumps(summary, ensure_ascii=False), flush=True)
