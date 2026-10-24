"""Reproduce generated maps from a relocated G package. Never launches a GUI/game."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess

def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')

class InputBinder:
    """Rebind runtime references while preserving physical provenance hashes."""
    def __init__(self, package, out, install, contract):
        self.package, self.out, self.install = package, out, install
        self.mapping = contract['path_map']
        self.immutable = set(contract['immutable_json'])
        self.bound, self.busy = {}, set()

    def reference(self, value, parent):
        if not isinstance(value, str) or not value or len(value) > 512 or '\n' in value:
            return None
        candidate = Path(value)
        if not candidate.is_absolute():
            candidate = parent / candidate
        identity = str(candidate.resolve())
        return identity if identity in self.mapping else None

    def bind(self, original):
        if original in self.bound:
            return self.bound[original]
        if original in self.busy:
            raise ValueError('Cyclic runtime input dependency: ' + original)
        self.busy.add(original)
        source = self.package / self.mapping[original]
        if source.suffix.lower() != '.json' or original in self.immutable:
            result = source
        else:
            result = self.out / 'config' / source.name
            pairs = {'source': 'source_sha256', 'review': 'review_sha256',
                     'profile': 'profile_sha256', 'library': 'library_sha256',
                     'base_library': 'base_sha256', 'path': 'sha256',
                     'plan': 'plan_sha256', 'w3e_path': 'w3e_sha256'}
            def transform(value):
                if isinstance(value, list):
                    return [transform(child) for child in value]
                if isinstance(value, dict):
                    data = {key: transform(child) for key, child in value.items()}
                    for key, hash_key in pairs.items():
                        reference = self.reference(value.get(key), Path(original).parent)
                        if reference and hash_key in value:
                            data[hash_key] = sha(self.bind(reference))
                    if 'install' in data:
                        data['install'] = str(self.install)
                    if 'dotnet' in data:
                        data['dotnet'] = str(self.package / 'runtime/dotnet/dotnet.exe')
                    if 'host' in data:
                        data['host'] = str(self.package / 'runtime/host/Host.dll')
                    return data
                reference = self.reference(value, Path(original).parent)
                return str(self.bind(reference)) if reference else value
            write(result, transform(read(source)))
        self.bound[original] = result
        self.busy.remove(original)
        return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--install', type=Path, required=True)
    args = parser.parse_args()
    package, out, install = args.package.resolve(), args.out.resolve(), args.install.resolve()
    if out.exists() and any(out.iterdir()):
        parser.error('--out must be empty')
    if out == package or package in out.parents:
        parser.error('--out must be outside the package')
    contract = read(package / 'reproduction-inputs.json')
    if contract['format'] != 'wc3-landform-portable-inputs-v1':
        raise ValueError('Unsupported generation package')
    for relative, expected in contract['inputs'].items():
        if sha(package / relative) != expected:
            raise ValueError('Packaged input differs: ' + relative)
    for relative, expected in contract['installation'].items():
        if sha(install / relative) != expected:
            raise ValueError('Classic installation differs: ' + relative)
    out.mkdir(parents=True, exist_ok=True)
    binder = InputBinder(package, out, install, contract)
    results = []
    for case in contract['cases']:
        recipe, dest = binder.bind(case['recipe']), out / case['id']
        command = [str(package / 'bin/terrain-gen-landforms.exe'), case['command'],
                   '--spec', str(recipe), '--seed', str(case['seed']), '--out', str(dest)]
        with (out / (case['id'] + '.log')).open('w', encoding='utf-8') as log:
            subprocess.run(command, cwd=package, stdout=log, stderr=subprocess.STDOUT,
                           check=True, timeout=900)
        actual = sha(dest / case['output'])
        result = {'id': case['id'], 'expected_sha256': case['sha256'],
                  'sha256': actual, 'exact': actual == case['sha256'], 'command': command}
        results.append(result)
        write(out / 'result.json', {'passed': len(results) == len(contract['cases']) and all(row['exact'] for row in results),
              'completed': len(results), 'expected_cases': len(contract['cases']),
              'cases': results, 'game_executed': False, 'native_save_simulated': False})
        if not result['exact']:
            raise ValueError('Generated map differs: ' + case['id'])
        print(case['id'], actual, 'exact', flush=True)

if __name__ == '__main__':
    main()
