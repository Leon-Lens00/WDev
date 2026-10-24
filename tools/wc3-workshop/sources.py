"""Small lexical navigator, deliberately not a JassHelper parser."""
import os
import re

from core import MAX_BYTES, MAX_RECORDS, Rejected, decode, fingerprint, project_path, read_bytes, ROOT

SUFFIXES = {'.j', '.jass', '.vjass'}
DECLARATION = re.compile(
    r'^\s*(?:(?:private|public|static|constant|stub)\s+)*'
    r'(library_once|library|scope|struct|module|interface|function|method|native)\s+(\w+)', re.ASCII)
IMPORT = re.compile(r'^//!\s*import\s+(?:(?:jass|vjass|zinc)\s+)?"([^"\r\n]+)"\s*$')


def mask(text, encoding):
    chars = list(text)
    imports = []
    rawcodes = []
    index = 0
    line = 1
    while index < len(text):
        start = index
        if text.startswith('//', index):
            end = text.find('\n', index)
            end = len(text) if end < 0 else end
            directive = IMPORT.fullmatch(text[index:end].rstrip('\r '))
            if directive:
                imports.append({'path': directive[1], 'line': line})
            index = end
        elif text.startswith('/*', index):
            end = text.find('*/', index + 2)
            if end < 0:
                raise Rejected('source', 'Unterminated block comment.')
            index = end + 2
        elif text[index] in ('"', "'"):
            quote = text[index]
            index += 1
            while index < len(text) and text[index] != quote:
                if text[index] in '\r\n':
                    raise Rejected('source', 'Newline in quoted literal.')
                if text[index] == '\\' and quote == '"':
                    if index + 1 < len(text) and text[index + 1] in '\r\n':
                        raise Rejected('source', 'Newline in quoted literal.')
                    index += 1
                index += 1
            if index >= len(text):
                raise Rejected('source', 'Unterminated quoted literal.')
            if quote == "'":
                literal = text[start + 1:index]
                raw = literal.encode(encoding)
                if len(raw) != 4:
                    raise Rejected('source', 'Rawcode literal must contain exactly four bytes.')
                rawcodes.append({'text': literal, 'hex': raw.hex(), 'line': line})
            index += 1
        else:
            if text[index] == '\n':
                line += 1
            index += 1
            continue
        for pos in range(start, index):
            if chars[pos] != '\n':
                chars[pos] = ' '
        line += text.count('\n', start, index)
        if len(imports) + len(rawcodes) > MAX_RECORDS:
            raise Rejected('limit', 'Source record limit exceeded.')
    return ''.join(chars), imports, rawcodes


def source_files(value):
    start = project_path(value)
    if start.is_file():
        if start.suffix.lower() not in SUFFIXES:
            raise Rejected('source', 'Expected .j, .jass or .vjass source.')
        return [start]
    if not start.is_dir():
        raise Rejected('path', 'Expected a regular file or directory.')
    pending = [start]
    files = []
    visited = 0
    while pending:
        directory = pending.pop()
        # Collect bounded entries before sorting; do not materialize an unbounded directory.
        children = []
        with os.scandir(directory) as scan:
            for entry in scan:
                visited += 1
                if visited > 2048:
                    raise Rejected('limit', 'Directory scan exceeds 2048 entries.')
                child = project_path(entry.path)
                children.append(child)
        for child in sorted(children):
            if child.is_dir():
                pending.append(child)
            elif child.is_file() and child.suffix.lower() in SUFFIXES:
                files.append(child)
                if len(files) > 64:
                    raise Rejected('limit', 'Source scan exceeds 64 files.')
    return sorted(files)


def inspect_sources(path):
    files = []
    total_bytes = 0
    total_records = 0
    for source in source_files(path):
        data = read_bytes(source)
        total_bytes += len(data)
        if total_bytes > 4 * MAX_BYTES:
            raise Rejected('limit', 'Source scan exceeds 4 MiB total.')
        text, encoding = decode(data)
        masked, imports, rawcodes = mask(text, encoding)
        declarations = []
        dependencies = []
        modern = []
        for number, line in enumerate(masked.split('\n'), 1):
            declaration = DECLARATION.match(line)
            if declaration:
                kind, name = declaration.groups()
                declarations.append({'kind': kind, 'name': name, 'line': number})
                if kind in ('library', 'library_once'):
                    dependency = re.search(r'\b(?:requires|needs|uses)\s+(.+)', line)
                    if dependency:
                        dependencies.append({'library': name, 'names': [part.strip()
                                             for part in dependency[1].split(',') if part.strip()],
                                             'line': number})
            for match in re.finditer(r'\b(?:Blz\w*|FourCC)\b', line, re.ASCII):
                modern.append({'name': match[0], 'line': number})
        total_records += sum(map(len, (imports, rawcodes, declarations, dependencies, modern)))
        if total_records > MAX_RECORDS:
            raise Rejected('limit', 'Source record limit exceeded.')
        files.append({'path': str(source.relative_to(ROOT)), 'encoding': encoding,
                      **fingerprint(data), 'declarations': declarations, 'dependencies': dependencies,
                      'imports': imports, 'rawcodes': rawcodes, 'modern_api_mentions': modern})
    return {'files': files, 'navigation': 'lexical only; import targets are not opened'}
