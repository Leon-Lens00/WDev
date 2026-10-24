"""Presence-only checks at fixed authorized locations; bounded local fingerprints."""
import json
from pathlib import Path

from core import Rejected, fingerprint, project_path, read_bytes, ROOT

# Authorization is specific to this workshop, not a configurable external root.
LOCATIONS = {
    'classic_game': '/home/snz/Documentos/ChatGPT/FrozenThone/games/WarcraftIII-1.27b',
    'workshop_tools': '/home/snz/Documentos/ChatGPT/FrozenThone/tools',
    'workshop_scripts': '/home/snz/Documentos/ChatGPT/FrozenThone/scripts',
    'jasshelper_standard': '/home/snz/Documentos/ChatGPT/FrozenThone/editors/newgen/jasshelper/standart',
    'forge': '/home/snz/Documentos/WarDatsPy/wc3-forge',
}
ARTIFACTS = {'common', 'blizzard', 'pjass', 'jasshelper', 'provenance'}


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Duplicate config key')
        result[key] = value
    return result


def inspect_doctor(config=None):
    artifacts = []
    if config is not None:
        data = read_bytes(config, limit=16384)
        try:
            profile = json.loads(data.decode('utf-8'), object_pairs_hook=unique_object)
            if not isinstance(profile, dict) or set(profile) != {'artifacts'}:
                raise ValueError('Expected artifacts only')
            paths = profile['artifacts']
            if not isinstance(paths, dict) or not set(paths) <= ARTIFACTS:
                raise ValueError('Unknown artifact')
            for name, path in sorted(paths.items()):
                if not isinstance(path, str):
                    raise ValueError('Expected path string')
                canonical = project_path(path)
                artifact = read_bytes(canonical)
                artifacts.append({'name': name, 'path': str(canonical.relative_to(ROOT)),
                                  'available': True, **fingerprint(artifact)})
        except (ValueError, UnicodeDecodeError, RecursionError, Rejected) as error:
            raise Rejected('config', 'Invalid profile: use named project-contained artifacts only.') from error
    locations = []
    for name, value in LOCATIONS.items():
        path = Path(value)
        # No directory traversal, archive reads, config ingestion or executable invocation.
        symlink = path.is_symlink()
        available = path.is_dir() if not symlink else False
        locations.append({'name': name, 'path': value, 'available': available,
                          'symlink': symlink, 'check': 'directory presence only'})
    return {'artifacts': artifacts, 'authorized_locations': locations,
            'compatibility_verified': False, 'execution_verified': False,
            'prerequisites': 'Compiler binaries, headers, patch provenance and execution require separate review.'}
