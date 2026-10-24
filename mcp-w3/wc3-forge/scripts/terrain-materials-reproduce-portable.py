"""Repaint the three frozen bases from a relocated release; Windows, Python 3.10+."""
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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument('--out', type=Path, required=True, help='New, empty output directory')
    args = parser.parse_args()
    package, out = args.package.resolve(), args.out.resolve()
    if out.exists() and any(out.iterdir()):
        parser.error('--out must be empty; previous runs are never overwritten')
    if out == package or package in out.parents:
        parser.error('--out must be outside the package so its manifest remains valid')
    contract = read(package / 'reproduction-inputs.json')
    for relative, expected in contract['inputs'].items():
        path = package / relative
        if not path.is_file() or sha(path) != expected:
            raise ValueError('Input hash mismatch: ' + relative)
    out.mkdir(parents=True, exist_ok=True)
    profile = read(package / 'profile/profile-v3.json')
    profile['source'] = str(package / 'inputs/donor.w3x')
    local_profile = out / 'config/profile-local.json'
    write(local_profile, profile)
    results = []
    for case in contract['cases']:
        brief, seed = case['brief'], case['seed']
        request = read(package / f'config/{brief}-{seed}.json')
        request['map'] = str(package / f'inputs/{brief}/Tropical-{brief}-{seed}.w3x')
        request['layout'] = str(package / f'inputs/{brief}/layout.json')
        request['materials']['profile'] = str(local_profile)
        request['materials']['profile_sha256'] = sha(local_profile)
        request_path = out / f'config/{brief}.json'
        write(request_path, request)
        target = out / brief
        command = [str(package / 'bin/terrain-gen-materials.exe'), 'repaint-materials',
                   '-spec', str(request_path), '-out', str(target)]
        with (out / f'{brief}.log').open('w', encoding='utf-8') as log:
            subprocess.run(command, cwd=package, stdout=log, stderr=subprocess.STDOUT,
                           check=True, timeout=300)
        generated = target / f'Tropical-{brief}-{seed}-materials.w3x'
        actual = sha(generated)
        if actual != case['generated_sha256'] or not read(target / 'validation.json')['passed']:
            raise ValueError('Output differs or validation failed: ' + brief)
        results.append({'brief': brief, 'sha256': actual, 'exact': True, 'command': command})
        print(brief, actual, 'exact', flush=True)
    write(out / 'result.json', {'passed': True, 'cases': results,
          'original_profile_sha256': contract['inputs']['profile/profile-v3.json'],
          'localized_profile_sha256': sha(local_profile),
          'note': 'Only profile source path and request paths/hash rebound. Original package untouched.'})


if __name__ == '__main__':
    main()
