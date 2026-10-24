#!/usr/bin/env python3
"""Fingerprint the explicit workshop configuration read-only; never execute installed binaries."""
import argparse
import json
from pathlib import Path
import re
import struct
import sys

from build import digest, guard, json_bytes, write_new

EXPECTED = {'common': '9cb04da1c75dd30025d96fec12b4302c2f6a1f1a8c864b66d6cf52c65ecde924',
            'blizzard': 'd290865bd673f8394f4e6fb7b4d6720412fed3a447877523cec9e54e65b8e62c'}


def fingerprint(path):
    data = path.read_bytes()
    result = {'path': str(path), 'resolved': str(path.resolve()), 'size': len(data), 'sha256': digest(data)}
    # VS_FIXEDFILEINFO signature: identity evidence only, not signed authenticity.
    versions = []
    for match in re.finditer(b'\xbd\x04\xef\xfe\x00\x00\x01\x00', data):
        if match.start() + 16 <= len(data):
            high, low = struct.unpack_from('<II', data, match.start() + 8)
            versions.append('%d.%d.%d.%d' % (high >> 16, high & 65535, low >> 16, low & 65535))
    if versions:
        result['fixed_file_version_candidates'] = versions
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True, help='Installed FrozenThone root (read-only)')
    parser.add_argument('--config', type=Path, required=True, help='Workshop Configuracion.json')
    parser.add_argument('--launcher', type=Path, required=True)
    parser.add_argument('--report', type=Path, required=True, help='New toolchain JSON in WDev; never overwritten')
    args = parser.parse_args()
    try:
        root = args.root.resolve(strict=True)
        config = json.loads(args.config.read_text())
        jh = root / config['jasshelper_dir']
        game = root / config['game_dir']
        profile = root / config['game_profile'] / 'pfx/drive_c/WarcraftIII'
        import mpyq
        paths = {'workshop_launcher': args.launcher, 'config': args.config,
                 'python': Path(sys.executable), 'mpyq': Path(mpyq.__file__),
                 'dotnet': root / 'tools/wc3-addons/wc3_agent_tools/dotnet/dotnet',
                 'legacy_wine': root / 'runtime/runtimes/lutris-GE-Proton8-26-x86_64/bin/wine',
                 'wc3_wrapper': root / 'scripts/wc3.py', 'runtime_wrapper': root / 'scripts/editores.py',
                 'jasshelper': jh / 'clijasshelper.exe', 'jasshelper_config': jh / 'jasshelper.conf',
                 'jasshelper_pjass': jh / 'pjass.exe', 'sfmpq': jh / 'sfmpq.dll',
                 'bin_sfmpq': jh / 'bin/sfmpq.dll', 'manual': jh / 'jasshelpermanual.html',
                 'changelog': jh / 'changelog.txt',
                 'pjass': root / 'tools/wc3-addons/wc3_agent_tools/pjass/pjass',
                 'pjass_readme': root / 'tools/wc3-addons/wc3_agent_tools/pjass/readme.md',
                 'wc3ctl': root / config['wc3ctl'],
                 'common': root / config['classic_common'], 'blizzard': root / config['classic_blizzard'],
                 'native_provenance': root / config['classic_assets'] / 'provenance.json',
                 'installed_war3': game / 'war3.exe', 'installed_game_dll': game / 'game.dll',
                 'profile_war3': profile / 'war3.exe', 'profile_game_dll': profile / 'game.dll'}
        guard([args.report], list(paths.values()))
        files = {name: fingerprint(path) for name, path in paths.items()}
        report = {'files': files, 'python_version': sys.version, 'mpyq_version': mpyq.__version__,
                  'native_expected_matches': {name: files[name]['sha256'] == sha for name, sha in EXPECTED.items()},
                  'manual_title': re.search(r'<title>(.*?)</title>', paths['manual'].read_text())[1],
                  'changelog_first_date': re.search(r'\d{4}-\d{2}-\d{2}', paths['changelog'].read_text())[0],
                  'reviewed_invocation': 'wc3 vjass SOURCE NEW_OUTPUT; wrapper stages full config/bin and runs clijasshelper --scriptonly, then native pjass common Blizzard output',
                  'imports': 'Installed manual supports absolute imports. Builder uses explicit Z:\\ paths; nested imports rejected, no lookupfolder dependence.',
                  'pjass_options': 'Wrapper default only; no automatic +oldpatch (it enables returnbug).',
                  'compatibility_verified': False,
                  'limitations': ['Hashes and embedded metadata are observed identity, not official provenance or authentication.',
                                  'Installed manual/changelog identify a dated distribution, not proof of exact compiler source/fork.',
                                  'Native provenance file attributes Scripts to War3Patch.mpq; archive extraction not independently repeated here.',
                                  'Runtime override environment may change Wine/Proton selection; no compiler or game executed.']}
        write_new(args.report, json_bytes(report))
        print(json.dumps(report))
        return 0
    except (OSError, ValueError, KeyError) as exc:
        print('error: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
