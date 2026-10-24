#!/usr/bin/env python3
"""Overlay extracted DevMission resources onto the independent audit terrain.

Never writes to or launches the DevMission source. Object data intentionally
replaces the audit base object tables; map logic/terrain/placements stay exact.
"""
from pathlib import Path
import hashlib
import json
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = Path('/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py')
BASE = ROOT.parent / 'TerrainDev/maps/originals/TerrainDev.w3x'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    provenance = json.loads((ROOT / 'evidence/devmission-source-provenance.json').read_text())
    original = Path(provenance['source'])
    assert sha(original) == provenance['sha256']
    resources = ROOT / 'resources/devmission-v096'
    target = ROOT / 'artifacts/TerrainDev-WaveResources-v1.w3x'
    assert not target.exists()
    work = ROOT / 'artifacts/resource-pack-v1'
    work.mkdir(exist_ok=False)
    # World minimap and map settings are not resource dependencies of the tests.
    excluded = {'war3mapMap.blp', 'war3mapMisc.txt', 'war3mapSkin.txt', 'war3map.w3s'}
    files = sorted(p for p in resources.rglob('*') if p.is_file() and p.name not in excluded)
    forbidden = {'war3map.j', 'war3map.w3i', 'war3map.w3e', 'war3mapUnits.doo', 'war3map.doo'}
    assert not any(p.name in forbidden for p in files)
    current = BASE
    records = []
    for i, path in enumerate(files):
        output = work / f'stage-{i % 2}.w3x'
        assert output != current
        output.unlink(missing_ok=True)
        internal = str(path.relative_to(resources)).replace('/', '\\')
        cmd = [sys.executable, str(LAUNCHER), 'wc3ctl', 'file', 'set', str(current), internal,
               str(path), '-o', str(output), '--json']
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode:
            (work / 'failure.json').write_text(json.dumps(dict(command=cmd, **result.__dict__), default=str))
            raise RuntimeError(f'Failed resource {internal}')
        records.append(dict(internal=internal, size=path.stat().st_size, sha256=sha(path)))
        current = output
        if i % 20 == 0:
            print(f'Packed {i+1}/{len(files)}: {internal}', flush=True)
    current.rename(target)
    verified = work / 'verified'
    cmd = [sys.executable, str(LAUNCHER), 'wc3ctl', 'extract', str(target), '--all', '--out', str(verified), '--json']
    result = subprocess.run(cmd, capture_output=True, text=True)
    (ROOT / 'evidence/devmission-resource-pack-extract.json').write_text(json.dumps(dict(command=cmd,returncode=result.returncode,stdout=result.stdout,stderr=result.stderr),indent=2))
    assert result.returncode == 0
    for r in records:
        assert sha(verified / r['internal'].replace('\\', '/')) == r['sha256'], r
    changed = {r['internal'] for r in records}
    for p in (ROOT / 'artifacts/base-map').rglob('*'):
        if p.is_file() and p.name != '(listfile)':
            internal = str(p.relative_to(ROOT / 'artifacts/base-map')).replace('/', '\\')
            if internal not in changed:
                assert sha(verified / p.relative_to(ROOT / 'artifacts/base-map')) == sha(p), internal
    assert BASE.read_bytes()[:512] == target.read_bytes()[:512]
    assert sha(original) == provenance['sha256']
    report = dict(source=provenance, base=str(BASE), base_sha256=sha(BASE), map=str(target),sha256=sha(target),
                  resources=records, resource_count=len(records), excluded=sorted(excluded),
                  policy='Replace object tables and WTS intentionally; preserve audit terrain, script, placements and header. No DevMission script imported.',
                  reextracted_hashes_match=True, source_unchanged=True)
    (ROOT / 'evidence/devmission-resource-pack.json').write_text(json.dumps(report,indent=2))
    print(f'Verified {len(records)} resources; {target}',flush=True)

if __name__ == '__main__':
    main()
