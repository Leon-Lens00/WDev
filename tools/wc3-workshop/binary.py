"""Metadata-independent readers for extracted Classic object and import members."""
import math
from pathlib import PureWindowsPath
import struct

from core import Rejected, decode, identity, read_bytes

KINDS = ('unit', 'item', 'ability', 'destructable', 'doodad', 'buff', 'upgrade')
EXTENDED = {'ability', 'doodad', 'upgrade'}


class Reader:
    def __init__(self, path):
        self.data = read_bytes(path)
        self.offset = 0
        self.records = 0

    def take(self, size):
        if size > len(self.data) - self.offset:
            raise Rejected('binary', 'Truncated binary input.')
        start = self.offset
        self.offset += size
        return self.data[start:self.offset]

    def integer(self):
        return struct.unpack('<i', self.take(4))[0]

    def count(self):
        count = self.integer()
        if count < 0:
            raise Rejected('binary', 'Negative record count.')
        self.records += count
        if count > 1000 or self.records > 4000:
            raise Rejected('limit', 'Binary record limit exceeded.')
        return count

    def version(self, expected):
        value = self.integer()
        if value != expected:
            raise Rejected('version', 'Unsupported binary version; expected ' + str(expected) + '.')
        return value

    def string(self):
        end = self.data.find(b'\0', self.offset, self.offset + 4097)
        if end == -1:
            raise Rejected('binary', 'Missing terminator or string exceeds 4096 bytes.')
        raw = self.take(end - self.offset)
        self.take(1)
        return decode(raw)

    def finish(self):
        if self.offset != len(self.data):
            raise Rejected('binary', 'Trailing binary data.')


def inspect_objects(kind, path):
    reader = Reader(path)
    version = reader.version(2)
    result = {'kind': kind, 'version': version}
    for table in ('original', 'custom'):
        entries = []
        for _ in range(reader.count()):
            entry = {'old_id': identity(reader.take(4)), 'new_id': identity(reader.take(4))}
            modifications = []
            for _ in range(reader.count()):
                field = identity(reader.take(4))
                tag = reader.integer()
                if tag not in (0, 1, 2, 3):
                    raise Rejected('binary', 'Unsupported stored object type tag.')
                level = reader.integer() if kind in EXTENDED else None
                column = reader.integer() if kind in EXTENDED else None
                encoding = None
                if tag == 0:
                    value = reader.integer()
                elif tag in (1, 2):
                    value = struct.unpack('<f', reader.take(4))[0]
                    if not math.isfinite(value):
                        raise Rejected('binary', 'Nonfinite object number.')
                else:
                    value, encoding = reader.string()
                end_id = identity(reader.take(4))
                if end_id['hex'] not in ('00000000', entry['old_id']['hex'], entry['new_id']['hex']):
                    raise Rejected('binary', 'Object modification terminator is not an object ID or zero.')
                modifications.append({'field_id': field, 'type_tag': tag, 'level': level,
                                      'data': column, 'value': value, 'encoding': encoding,
                                      'end_id': end_id})
            entry['modifications'] = modifications
            entries.append(entry)
        result[table] = entries
    reader.finish()
    return result


def inspect_imports(path):
    reader = Reader(path)
    version = reader.version(1)
    entries = []
    for _ in range(reader.count()):
        flag = reader.take(1)[0]
        if flag not in (0, 5, 8, 13):
            raise Rejected('binary', 'Unsupported import flag (expected 0, 5, 8 or 13).')
        text, encoding = reader.string()
        windows = PureWindowsPath(text)
        unsafe = (not text or bool(windows.drive) or bool(windows.root)
                  or '..' in windows.parts or ':' in text)
        entries.append({'flag': flag, 'path': text, 'encoding': encoding, 'unsafe_path': unsafe})
    reader.finish()
    return {'version': version, 'entries': entries, 'assets_checked': False}
