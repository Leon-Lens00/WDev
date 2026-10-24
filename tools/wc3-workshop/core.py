"""Shared read boundary, limits and evidence envelope (no write operations)."""
import hashlib
import json
import os
from pathlib import Path
import stat

ROOT = Path(__file__).resolve().parents[2]
MAX_BYTES = 1024 * 1024
MAX_OUTPUT = 512 * 1024
MAX_RECORDS = 4000
TARGET = 'Warcraft III Classic 1.27b'
LIMITATIONS = [
    'Read-only static evidence; availability and hashes do not prove compatibility.',
    'No compilation, editor, game, multiplayer, full vJASS semantics or MPQ opening.',
]


class Rejected(Exception):
    def __init__(self, code, message):
        self.code = code
        self.message = message
        super().__init__(message)


def project_path(value):
    """All user paths, including scan entries/config artifacts, pass here.

    Reject every symlink, even internal ones: cycles and redirect ambiguity are
    not useful navigation evidence. This is not a concurrent-adversary sandbox.
    """
    if not isinstance(value, (str, Path)) or not str(value) or '\0' in str(value):
        raise Rejected('path', 'Expected a nonempty project path.')
    candidate = Path(value)
    if not candidate.is_absolute():
        candidate = ROOT / candidate
    try:
        relative = candidate.relative_to(ROOT)
        if '..' in relative.parts:
            raise ValueError('Traversal')
        current = ROOT
        for part in relative.parts:
            if (part.startswith('.') or part.lower() in
                    {'auth.json', 'credentials', 'secrets', 'history', 'id_rsa', 'id_ed25519'}):
                raise ValueError('Sensitive or hidden path')
            current = current / part
            if current.is_symlink():
                raise ValueError('Symlink')
        resolved = candidate.resolve(strict=True)
        resolved.relative_to(ROOT)
    except (OSError, ValueError, RuntimeError):
        raise Rejected('path', 'Path must exist inside the project without traversal, hidden paths or symlinks.')
    return resolved


def read_bytes(value, limit=MAX_BYTES):
    path = project_path(value)
    # Nonblocking avoids hanging on a special file swapped in after validation.
    fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW)
    with os.fdopen(fd, 'rb') as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode):
            raise Rejected('path', 'Input must be a regular file.')
        if info.st_size > limit:
            raise Rejected('limit', 'Input byte limit exceeded.')
        data = stream.read(limit + 1)
    if len(data) > limit:
        raise Rejected('limit', 'Input byte limit exceeded.')
    return data


def decode(data):
    try:
        return data.decode('utf-8'), 'utf-8'
    except UnicodeDecodeError:
        try:
            return data.decode('cp1252'), 'cp1252'
        except UnicodeDecodeError:
            raise Rejected('encoding', 'Input is neither UTF-8 nor defined CP1252.')


def identity(data):
    return {'text': data.decode('latin-1'), 'hex': data.hex()}


def fingerprint(data):
    return {'size': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def envelope(action, result=None, error=None):
    return {'schema_version': 1, 'ok': error is None, 'action': action,
            'target': TARGET, 'evidence': 'Scanned' if error is None else 'Rejected',
            'limitations': LIMITATIONS, 'result': result,
            'error': None if error is None else {'code': error.code, 'message': error.message}}


def serialize(action, result=None, error=None):
    payload = json.dumps(envelope(action, result, error), ensure_ascii=True, allow_nan=False)
    if len(payload) > MAX_OUTPUT:
        payload = json.dumps(envelope(action, error=Rejected('limit', 'Output byte limit exceeded.')))
        return payload, 2
    return payload, 2 if error else 0
