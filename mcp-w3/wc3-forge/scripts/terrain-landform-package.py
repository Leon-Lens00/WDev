"""Package declared landform finals and all generation references without editing them.

--cases is a JSON list (or {"cases": [...]}) of exactly three final records:
id, seed, recipe, command (generate or biome-generate), output, sha256.
output is the map's path relative to that case's generation directory, including
the Biome paint/ prefix where applicable. Native saves are not regenerated.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import shutil

IMMUTABLE_MATERIAL = '807dcfe966f8424373ae84c6092b0aab0da1a6440160418e81ffe48cc4a36239'
EVIDENCE_FORMATS = {'wc3-landform-plan-v1', 'wc3-landform-profile-v1'}
EXTERNAL_KEYS = {'install', 'dotnet', 'host'}

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')

def copy(source, target):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)

def file_reference(value, parent):
    if not isinstance(value, str) or not value or len(value) > 512 or '\n' in value:
        return None
    candidate = Path(value)
    if not candidate.is_absolute():
        candidate = parent / candidate
    try:
        return candidate.resolve() if candidate.is_file() else None
    except OSError:
        return None

def collect_inputs(recipes, package):
    mapping, immutable, pending = {}, [], []
    def collect(path):
        path = path.resolve()
        identity = str(path)
        if identity in mapping:
            return
        digest = sha(path)
        relative = 'inputs/' + digest[:16] + '-' + path.name
        mapping[identity] = relative
        copy(path, package / relative)
        if path.suffix.lower() != '.json':
            return
        value = read(path)
        if isinstance(value, dict) and (value.get('format') in EVIDENCE_FORMATS or digest == IMMUTABLE_MATERIAL):
            immutable.append(identity)
        def walk(item):
            if isinstance(item, dict):
                for key, child in item.items():
                    if key not in EXTERNAL_KEYS:
                        walk(child)
            elif isinstance(item, list):
                for child in item:
                    walk(child)
            else:
                reference = file_reference(item, path.parent)
                if reference is not None:
                    collect(reference)
                elif isinstance(item, str) and len(item) < 512 and re.match(r'^[A-Za-z]:[\\/]', item):
                    # Stale evidence locations must be explicit, never silently
                    # claimed as packaged runtime dependencies.
                    pending.append({'container': identity, 'unresolved': item})
        walk(value)
    for recipe in recipes:
        collect(recipe)
    if pending:
        raise ValueError('Unresolved local references: ' + json.dumps(pending))
    return mapping, immutable

def copy_third_party_notices(repo, package):
    """Ship the notices belonging to the actual compiled, pinned host inputs."""
    host = repo / 'generators/markovjunior-host'
    dependencies = read(host / 'bin/Release/net10.0/Host.deps.json')
    if 'SixLabors.ImageSharp/3.1.12' not in dependencies['libraries']:
        raise ValueError('Host dependency version differs from the approved ImageSharp license')
    nuget = Path(os.environ.get('NUGET_PACKAGES', str(Path.home() / '.nuget/packages')))
    notices = {
        'MarkovJunior-LICENSE': repo / 'third_party/MarkovJunior/LICENSE',
        'MarkovJunior-CITATION.cff': repo / 'third_party/MarkovJunior/CITATION.cff',
        'SixLabors.ImageSharp-3.1.12-LICENSE': nuget / 'sixlabors.imagesharp/3.1.12/LICENSE',
        'SixLabors.ImageSharp-3.1.12.nuspec': nuget / 'sixlabors.imagesharp/3.1.12/sixlabors.imagesharp.nuspec',
    }
    for name, source in notices.items():
        if not source.is_file():
            raise ValueError('Required dependency notice missing: ' + str(source))
        copy(source, package / 'licenses' / name)
    for relative in ['LICENSE', 'LICENSE.md', 'CREDITS.md']:
        if (repo / relative).is_file():
            copy(repo / relative, package / 'licenses' / ('wc3-forge-' + relative))
    return {name: sha(package / 'licenses' / name) for name in notices}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cases', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--cli', type=Path, required=True)
    parser.add_argument('--install', type=Path, required=True)
    args = parser.parse_args()
    package, repo = args.out.resolve(), Path(__file__).resolve().parents[1]
    if package.exists() and any(package.iterdir()):
        parser.error('--out must be empty; existing deliveries are preserved')
    cases = read(args.cases)
    if isinstance(cases, dict):
        cases = cases['cases']
    if len(cases) != 3 or len({case['id'] for case in cases}) != 3:
        parser.error('declare exactly three distinct final cases')
    for case in cases:
        if not re.fullmatch(r'[A-Za-z0-9_-]+', case['id']):
            parser.error('case IDs must be simple directory names')
        if case['command'] not in ['generate', 'biome-generate'] or not isinstance(case['seed'], int) or case['seed'] < 0:
            parser.error('unsupported generation case')
        output = Path(case['output'])
        if output.is_absolute() or '..' in output.parts or not re.fullmatch(r'[0-9a-f]{64}', case['sha256']):
            parser.error('invalid relative map path or expected hash')
        recipe = Path(case['recipe'])
        if not recipe.is_absolute():
            recipe = args.cases.resolve().parent / recipe
        case['recipe'] = str(recipe.resolve())
    package.mkdir(parents=True, exist_ok=True)
    mapping, immutable = collect_inputs([Path(case['recipe']) for case in cases], package)
    copy(args.cli, package / 'bin/terrain-gen-landforms.exe')
    copy(repo / 'scripts/terrain-landform-reproduce.py', package / 'reproduce.py')
    runtime = repo / '.tools/dotnet'
    copy(runtime / 'dotnet.exe', package / 'runtime/dotnet/dotnet.exe')
    for relative in ['host/fxr/10.0.12', 'shared/Microsoft.NETCore.App/10.0.12']:
        shutil.copytree(runtime / relative, package / 'runtime/dotnet' / relative)
    for name in ['LICENSE.txt', 'ThirdPartyNotices.txt']:
        if (runtime / name).is_file():
            copy(runtime / name, package / 'runtime/dotnet' / name)
    shutil.copytree(repo / 'generators/markovjunior-host/bin/Release/net10.0', package / 'runtime/host')
    notices = copy_third_party_notices(repo, package)
    archives = {path.name: sha(path) for path in sorted(args.install.glob('*.mpq'))}
    if len(archives) < 4:
        raise ValueError('Classic installation MPQs missing')
    write(package / 'reproduction-inputs.json', {
        'format': 'wc3-landform-portable-inputs-v1', 'cases': cases,
        'path_map': mapping, 'immutable_json': immutable, 'installation': archives,
        'third_party_notices': notices,
        'inputs': {str(path.relative_to(package)).replace('\\', '/'): sha(path)
                   for path in package.rglob('*') if path.is_file()},
        'immutable_policy': 'Physical plans/profiles retain exact bytes and provenance paths. path_map locates packaged evidence. Tropical material profile retains its approved SHA; SourceOverride verifies its relocated donor.',
        'external_dependencies': ['Windows x64', 'Python 3.10+', 'Existing Classic 1.27b installation matching MPQ hashes'],
        'native_saves': 'Provided separately as real World Editor evidence; never synthesized by reproduction.'
    })
    print(package, len(mapping), 'verified input references')

if __name__ == '__main__':
    main()
