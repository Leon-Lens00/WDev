"""Independent read-only version2 walker retained from the initial diagnostic.

Not imported by the serializer. Keeps raw record spans for preservation checks.
"""
import io
import struct


def records(data, leveled):
    f = io.BytesIO(data)

    def integer():
        return struct.unpack('<i', f.read(4))[0]

    def raw():
        return f.read(4).decode('ascii')

    def string():
        result = bytearray()
        while True:
            c = f.read(1)
            if not c:
                raise ValueError('unterminated string')
            if c == b'\0':
                return result.decode('utf-8')
            result.extend(c)

    assert integer() == 2
    result = []
    for table in ('original', 'custom'):
        for _ in range(integer()):
            start = f.tell()
            old, new = raw(), raw()
            mods = []
            for _ in range(integer()):
                field, typ = raw(), integer()
                level, pointer = (integer(), integer()) if leveled else (0, 0)
                value = integer() if typ == 0 else struct.unpack('<f', f.read(4))[0] if typ in (1, 2) else string()
                end = raw()
                mods.append(dict(field=field, type=typ, level=level, pointer=pointer, value=value, end=end))
            result.append(dict(table=table, old=old, new=new, mods=mods, raw=data[start:f.tell()]))
    assert f.tell() == len(data)
    return result
