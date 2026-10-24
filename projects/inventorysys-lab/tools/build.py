#!/usr/bin/env python3
"""Recover InventorySys locally; assemble plain JASS; optionally validate and package a copy."""
import argparse
import hashlib
from io import BytesIO
import json
from pathlib import Path
import re
import struct
import subprocess
import sys

# Explicit inventory, not an asset extractor. Encrypted listfile is never decoded.
MEMBERS = ('war3map.j', 'war3map.wct', 'war3map.wtg', 'war3map.wts',
           'war3map.w3u', 'war3map.w3t', 'war3map.w3a', 'war3map.w3b',
           'war3map.w3d', 'war3map.w3q', 'war3map.w3h', 'war3map.w3i',
           'war3map.w3e', 'war3map.imp', 'war3map.doo', 'war3mapUnits.doo',
           'war3map.wpm', 'war3map.mmp', 'war3map.shd')
REQUIRED = ('war3map.j', 'war3map.wct', 'war3map.wtg', 'war3map.wts')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def json_bytes(value):
    return (json.dumps(value, indent=2, ensure_ascii=True) + '\n').encode('utf-8')


def write_new(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('xb') as stream:
        stream.write(data)


def no_symlinks(path, kind):
    for part in reversed((path.absolute(), *path.absolute().parents)):
        if part.is_symlink():
            raise ValueError('symlink ' + kind + ': ' + str(part))


def guard(destinations, inputs):
    """Adapted from relativistic-classic: preflight the complete publication roots."""
    identities = [(p.stat().st_dev, p.stat().st_ino) for p in inputs]
    if len(set(identities)) != len(identities):
        raise ValueError('duplicate or aliased inputs')
    for path in inputs:
        no_symlinks(path, 'input')
        if path.stat().st_nlink != 1:
            raise ValueError('hardlinked input: ' + str(path))
    resolved = [p.resolve(strict=True) for p in inputs]
    targets = []
    for dest in destinations:
        no_symlinks(dest, 'destination')
        if dest.exists():
            raise ValueError('destination already exists: ' + str(dest))
        target = dest.resolve()
        if any(target == p or target in p.parents or p in target.parents for p in resolved + targets):
            raise ValueError('destination overlaps input or output: ' + str(dest))
        targets.append(target)


def mpq_offset(data):
    if data.startswith(b'MPQ\x1a'):
        return 0
    if data.startswith(b'HM3W'):
        for offset in range(512, len(data), 512):
            if data[offset:offset + 4] == b'MPQ\x1a':
                return offset
    raise ValueError('aligned MPQ header not found')


def opaque_payloads(archive):
    """Fingerprint raw non-script blocks without decompressing assets or listfile.

    Compare a multiset, not block positions: injection may relocate blocks. This
    conservative guard may reject a tool that rewrites encrypted/compressed data.
    """
    if not archive.block_table:
        return []
    script = archive.get_hash_table_entry('war3map.j').block_table_index
    records = []
    for index, block in enumerate(archive.block_table):
        if index == script or not (block.flags & 0x80000000):
            continue
        archive.file.seek(archive.header['offset'] + block.offset)
        raw = archive.file.read(block.archived_size)
        if len(raw) != block.archived_size:
            raise ValueError('truncated raw MPQ payload')
        records.append({'sha256': digest(raw), 'archived_size': len(raw),
                        'size': block.size, 'flags': block.flags})
    return sorted(records, key=lambda r: (r['sha256'], r['flags'], r['size']))


# Neutral MPQ name hashes, confirmed against the failed real injection's entries.
SCRIPT_ID = (3382118375, 2511869006, 0, 0)
LISTFILE_ID = (4251285776, 1318820007, 0, 0)
ATTRIBUTES_ID = (3548657611, 132115180, 0, 0)
HOUSEKEEPING_FLAGS = 0x80030200  # EXISTS | COMPRESS | ENCRYPTED | FIX_KEY


def archive_snapshot(data, factory):
    """Bind every live hash identity to its raw payload, not its block-table index."""
    archive = factory(BytesIO(data[mpq_offset(data):]), listfile=False)
    blocks = {}
    for index, block in enumerate(archive.block_table):
        if not block.flags & 0x80000000:
            continue
        archive.file.seek(archive.header['offset'] + block.offset)
        raw = archive.file.read(block.archived_size)
        if len(raw) != block.archived_size:
            raise ValueError('truncated raw MPQ payload')
        blocks[index] = {'sha256': digest(raw), 'archived_size': len(raw),
                         'size': block.size, 'flags': block.flags,
                         # Unchanged ciphertext is insufficient if FIX_KEY context moves.
                         'key_offset': block.offset if block.flags & 0x20000 else None}
    identities, referenced = {}, set()
    for entry in archive.hash_table:
        if entry.block_table_index >= 0xfffffffe:  # empty or deleted hash entry
            continue
        key = (entry.hash_a, entry.hash_b, entry.locale, entry.platform)
        if key in identities or entry.block_table_index not in blocks:
            raise ValueError('invalid MPQ identity mapping')
        identities[key] = blocks[entry.block_table_index]
        referenced.add(entry.block_table_index)
    orphans = [json.dumps(row, sort_keys=True) for index, row in blocks.items() if index not in referenced]
    return {'identities': identities, 'unreferenced': sorted(orphans),
            'format': (archive.header['format_version'], archive.header['sector_size_shift'])}


def verify_archive_preservation(original, modified, factory):
    """Allow only managed script, neutral listfile rewrite, and attributes addition.

    Housekeeping contents remain opaque: this explicitly permits their change,
    not decrypted equivalence. Every other identity/raw payload/context must match.
    """
    before, after = archive_snapshot(original, factory), archive_snapshot(modified, factory)
    old, new = before['identities'], after['identities']
    error = 'opaque raw MPQ payload changed'
    if (before['format'] != after['format'] or before['unreferenced'] != after['unreferenced']
            or SCRIPT_ID not in old or SCRIPT_ID not in new or set(old) - set(new)
            or (set(new) - set(old)) - {ATTRIBUTES_ID}):
        raise ValueError(error)
    changes, preserved = [], 0
    for key in sorted(set(old) | set(new)):
        left, right = old.get(key), new.get(key)
        if key == SCRIPT_ID:  # decompressed script is checked separately against assembly
            continue
        if left == right:
            preserved += 1
            continue
        name = None
        if key == LISTFILE_ID and left is not None and right is not None:
            name = '(listfile)'
        elif key == ATTRIBUTES_ID and left is None and right is not None:
            name = '(attributes)'
        if name is None or any(row['flags'] != HOUSEKEEPING_FLAGS or row['size'] <= 0
                               or row['archived_size'] <= 0 for row in (left, right) if row is not None):
            raise ValueError(error)
        changes.append({'name': name, 'identity': list(key), 'before': left, 'after': right})
    return {'preserved_identities': preserved, 'housekeeping_changes': changes,
            'unreferenced_payloads': len(before['unreferenced']),
            'policy': 'Identity-bound raw preservation; only neutral listfile rewrite and attributes addition allowed.'}


def read_map(data, factory):
    offset = mpq_offset(data)
    archive = factory(BytesIO(data[offset:]), listfile=False)
    members = {}
    for name in MEMBERS:
        member = archive.read_file(name)
        if member is not None:
            members[name] = member
    for name in REQUIRED:
        if name not in members:
            raise ValueError('missing member: ' + name)
    return data[:offset], members, opaque_payloads(archive)


def wct_blocks(data):
    """Byte-preserving classic-v1 counterpart of map_inventory.WctReader schema."""
    offset = 0

    def integer():
        nonlocal offset
        if offset + 4 > len(data):
            raise ValueError('truncated WCT integer')
        value = struct.unpack_from('<i', data, offset)[0]
        offset += 4
        return value

    def text():
        nonlocal offset
        size = integer()
        if size < 0 or offset + size > len(data):
            raise ValueError('invalid WCT custom-text length')
        block = data[offset:offset + size]
        offset += size
        if size and block[-1:] != b'\0':
            raise ValueError('invalid WCT custom-text terminator')
        return block[:-1] if size else b''

    if integer() != 1:
        raise ValueError('expected classic WCT version 1')
    end = data.find(b'\0', offset)
    if end < 0:
        raise ValueError('truncated WCT comment')
    comment = data[offset:end]
    offset = end + 1
    global_script = text()
    count = integer()
    if count < 0 or count > (len(data) - offset) // 4:
        raise ValueError('invalid WCT trigger count')
    triggers = [text() for _ in range(count)]
    if offset != len(data):
        raise ValueError('unexpected WCT trailing bytes')
    return comment, global_script, triggers


def recover(args, factory):
    original = args.map.absolute()
    data = original.read_bytes()
    if digest(data) != args.expected_sha256:
        raise ValueError('source map SHA-256 mismatch')
    prefix, members, opaque = read_map(data, factory)
    comment, global_script, triggers = wct_blocks(members['war3map.wct'])
    root = args.project.absolute()
    baseline, report_path = root / 'baseline', root / 'reports/recovery.json'
    guard([baseline, report_path], [original])
    files = {baseline / 'original.w3x': data, baseline / 'wct/comment.txt': comment,
             baseline / 'wct/global.j': global_script}
    source_index = []
    for index, block in enumerate(triggers):
        path = baseline / ('wct/trigger-%03d.j' % index)
        files[path] = block
        declarations = re.findall(rb'(?:^|[\r\n])\s*(?:library|scope)\s+(\w+)', block)
        source_index.append({'slot': index, 'path': str(path.relative_to(root)),
                             'size': len(block), 'sha256': digest(block),
                             'declarations': [n.decode('ascii') for n in declarations]})
    for name, payload in members.items():
        files[baseline / 'members' / name] = payload
    if original.read_bytes() != data:
        raise ValueError('source map changed during recovery')
    report = {'source_map': str(original), 'source_size': len(data),
              'source_sha256_before': digest(data), 'source_sha256_after': digest(original.read_bytes()),
              'prefix_size': len(prefix), 'prefix_sha256': digest(prefix),
              'members': {n: {'size': len(b), 'sha256': digest(b)} for n, b in members.items()},
              'wct_slots': len(triggers), 'wct_nonempty': sum(bool(t.strip()) for t in triggers),
              'source_blocks': source_index, 'opaque_payloads': opaque,
              'inventory_complete': False, 'editor_save_certified': False,
              'permission': 'User-authorized local evaluation only; no redistribution rights inferred.',
              'credits': 'All original map, script and WCT comment/source bytes retained unchanged.',
              'limitations': ['Named-member recovery only; no full asset extraction or encrypted listfile decoding.',
                              'Raw payload hashes are byte evidence, not full archive semantic integrity.',
                              'Original generated JASS is executable source; WCT is reference only.']}
    for path, payload in files.items():
        write_new(path, payload)
    if original.read_bytes() != data:
        raise ValueError('source map changed during recovery')
    write_new(report_path, json_bytes(report))
    return report


def manual_hooks(original, manifest):
    """Return insertions only; exact script/function/anchor byte pins fail closed."""
    try:
        if set(manifest) != {'schema', 'original_sha256', 'functions'} or manifest['schema'] != 1:
            raise ValueError()
        if manifest['original_sha256'] != digest(original) or not manifest['functions']:
            raise ValueError()
        insertions, names = [], set()
        for function in manifest['functions']:
            if set(function) != {'name', 'sha256', 'hooks'}:
                raise ValueError()
            name = function['name']
            if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', name) or name in names:
                raise ValueError()
            names.add(name)
            matches = list(re.finditer(rb'(?m)^[ \t]*function ' + name.encode('ascii') +
                                      rb' takes [^\r\n]*\r?\n.*?^[ \t]*endfunction\r?\n',
                                      original, re.DOTALL | re.MULTILINE))
            if len(matches) != 1 or digest(matches[0][0]) != function['sha256'] or not function['hooks']:
                raise ValueError()
            body = matches[0][0]
            for hook in function['hooks']:
                if set(hook) != {'anchor', 'count', 'side', 'insert'}:
                    raise ValueError()
                anchor, payload = hook['anchor'].encode('ascii'), hook['insert'].encode('ascii')
                if (not anchor or type(hook['count']) is not int or hook['count'] < 1
                        or body.count(anchor) != hook['count'] or hook['side'] not in ('before', 'after')
                        or not payload.endswith(b'\r\n')
                        or not all(re.fullmatch(rb' *call ILM_Log\([^\r\n]*\)\r', line)
                                   for line in payload.split(b'\n')[:-1])):
                    raise ValueError()
                start = 0
                for _ in range(hook['count']):
                    offset = body.index(anchor, start)
                    insertions.append((matches[0].start() + offset +
                                       (len(anchor) if hook['side'] == 'after' else 0), payload))
                    start = offset + len(anchor)
        if len({offset for offset, _ in insertions}) != len(insertions):
            raise ValueError()
        return insertions
    except (KeyError, TypeError, ValueError, UnicodeError, AttributeError):
        raise ValueError('invalid manual hooks') from None


def assemble(original, globals_source, functions, entry, run_id, *, early=b'', hooks=None, metadata=None):
    """Insert three byte ranges only; original bytes are never decoded/reformatted."""
    globals_source.decode('utf-8')
    functions.decode('utf-8')
    for source in (globals_source, functions, early):
        if source.startswith(b'\xef\xbb\xbf') or re.search(rb'(?m)^\s*(?://!\s*import\b|library\b|scope\b|globals\b|endglobals\b)', source):
            raise ValueError('adapter must be plain JASS without imports')
    entry_pattern = rb'(?m)^function ' + entry.encode('ascii') + rb' takes nothing returns nothing\r?$'
    if len(re.findall(entry_pattern, functions)) != 1 or re.search(entry_pattern, original):
        raise ValueError('entry must occur exactly once in adapter')
    starts = list(re.finditer(rb'(?m)^globals[ \t]*\r?$', original))
    ends = list(re.finditer(rb'(?m)^endglobals[ \t]*\r?$', original))
    mains = list(re.finditer(rb'(?m)^function main takes nothing returns nothing\r?\n', original))
    if len(starts) != 1 or len(ends) != 1 or len(mains) != 1 or starts[0].start() >= ends[0].start():
        raise ValueError('unexpected original assembly anchors')
    main = mains[0]
    tail = re.search(rb'(?m)^endfunction[ \t]*\r?$', original[main.end():])
    if tail is None:
        raise ValueError('unexpected original assembly anchors')
    stop = main.end() + tail.start()
    main_body = original[main.end():stop]
    if not re.search(rb'    call InitCustomTriggers\(\)(?:\r?\n)+\Z', main_body) or ends[0].start() >= main.start():
        raise ValueError('unexpected original assembly anchors')
    newline = b'\r\n' if main[0].endswith(b'\r\n') else b'\n'

    def adapter(source):
        value = source.replace(b'@RUN_ID@', run_id.encode('ascii'))
        return value + (b'\n' if not value.endswith(b'\n') else b'')

    insertions = [(ends[0].start(), adapter(globals_source)),
                  (main.start(), adapter(functions)),
                  (stop, b'    call ' + entry.encode('ascii') + b'()' + newline)]
    if early:
        early.decode('utf-8')
        insertions.append((ends[0].end(), newline + adapter(early)))
    if hooks is not None:
        insertions.extend(manual_hooks(original, hooks))
    insertions.sort(key=lambda pair: pair[0])
    result = original
    for offset, payload in reversed(insertions):
        result = result[:offset] + payload + result[offset:]
    if metadata is not None:
        shift = 0
        for offset, payload in insertions:
            metadata.append({'offset': offset + shift, 'size': len(payload), 'sha256': digest(payload)})
            shift += len(payload)
        stripped = result
        for span in reversed(metadata):
            stripped = stripped[:span['offset']] + stripped[span['offset'] + span['size']:]
        if stripped != original:
            raise ValueError('manual insertion roundtrip mismatch')
    return result


def run_tool(argv):
    # Capture exact streams as bytes then decode losslessly; never shell or retry.
    process = subprocess.run(argv, capture_output=True, timeout=120)
    return {'returncode': process.returncode,
            'stdout': process.stdout.decode('utf-8', errors='surrogateescape'),
            'stderr': process.stderr.decode('utf-8', errors='surrogateescape')}


def prepare(args, factory):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]{0,79}', args.run_id):
        raise ValueError('invalid run-id')
    if not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', args.entry):
        raise ValueError('invalid harness entry identifier')
    inputs = [p.absolute() for p in (args.base, args.globals, args.functions)]
    early_path, hooks_path = getattr(args, 'early_functions', None), getattr(args, 'hooks', None)
    if bool(early_path) != bool(hooks_path):
        raise ValueError('manual mode requires --early-functions and --hooks together')
    for path in (early_path, hooks_path):
        if path is not None:
            inputs.append(path.absolute())
    if args.command == 'build':
        inputs.append(args.wc3.absolute())
    run = args.output_dir.absolute() / args.run_id
    guard([run], inputs)
    before = {p: p.read_bytes() for p in inputs}
    prefix, members, opaque = read_map(before[inputs[0]], factory)
    if early_path is None:
        script = assemble(members['war3map.j'], before[inputs[1]], before[inputs[2]], args.entry, args.run_id)
    else:
        try:
            manifest = json.loads(before[hooks_path.absolute()])
        except (ValueError, UnicodeError):
            raise ValueError('invalid manual hooks') from None
        args.insertion_metadata = []
        script = assemble(members['war3map.j'], before[inputs[1]], before[inputs[2]], args.entry, args.run_id,
                          early=before[early_path.absolute()], hooks=manifest, metadata=args.insertion_metadata)
    return run, inputs, before, prefix, members, opaque, script


def build(args, factory, runner):
    run, inputs, before, prefix, original_members, opaque, script = prepare(args, factory)
    report = {'run_id': args.run_id, 'assembled_sha256': digest(script),
              'inputs': {str(p): digest(b) for p, b in before.items()},
              'entry': args.entry, 'startup': 'At end of original main, after InitCustomTriggers()',
              'editor_save_certified': False, 'inventory_complete': False}
    if getattr(args, 'hooks', None) is not None:
        report.update(insertions=args.insertion_metadata, original_script_sha256=digest(original_members['war3map.j']),
                      mode='manual observational recorder; runtime writing unverified')
    write_new(run / 'assembled.j', script)
    if args.command == 'assemble':
        write_new(run / 'assembly.json', json_bytes(report))
        return report
    write_new(run / 'input.w3x', before[inputs[0]])
    commands = []

    def invoke(argv):
        argv = [str(a) for a in argv]
        try:
            result = runner(argv)
        except subprocess.TimeoutExpired as exc:
            result = {'returncode': None, 'stdout': (exc.stdout or b'').decode('utf-8', 'surrogateescape'),
                      'stderr': (exc.stderr or b'').decode('utf-8', 'surrogateescape'), 'timeout': True}
        except OSError as exc:
            result = {'returncode': None, 'stdout': '', 'stderr': '', 'launch_error': str(exc)}
        commands.append(dict(argv=argv, **result))
        write_new(run / ('command-%d.json' % len(commands)), json_bytes(commands[-1]))
        if result['returncode'] != 0:
            write_new(run / 'commands.json', json_bytes(commands))
            raise ValueError('tool failed (%s); see commands.json' % result['returncode'])

    wc3 = inputs[-1]
    invoke([wc3, 'pjass', run / 'assembled.j'])
    invoke([wc3, 'wc3ctl', 'file', 'set', run / 'input.w3x', 'war3map.j', run / 'assembled.j',
            '--out', run / 'injected.w3x', '--json'])
    write_new(run / 'commands.json', json_bytes(commands))
    injected = (run / 'injected.w3x').read_bytes()
    output_bytes = prefix + injected[mpq_offset(injected):]
    final_prefix, members, final_opaque = read_map(output_bytes, factory)
    expected = dict(original_members, **{'war3map.j': script})
    for name, payload in expected.items():
        if members.get(name) != payload:
            raise ValueError('member roundtrip mismatch: ' + name)
    preservation = verify_archive_preservation(before[inputs[0]], output_bytes, factory)
    if final_prefix != prefix:
        raise ValueError('original prefix changed')
    if (run / 'assembled.j').read_bytes() != script:
        raise ValueError('assembled script changed during build')
    if any(p.read_bytes() != data for p, data in before.items()):
        raise ValueError('input changed during build')
    output = run / (args.run_id + '.w3x')
    report.update(output=str(output), sha256=digest(output_bytes), prefix_sha256=digest(prefix),
                  managed={'war3map.j': digest(script)}, opaque_payloads=final_opaque,
                  archive_preservation=preservation,
                  preserved_members={n: digest(b) for n, b in original_members.items() if n != 'war3map.j'},
                  scope='Executable-test copy only; no editor-save, game or multiplayer certification.')
    write_new(output, output_bytes)
    write_new(run / 'build.json', json_bytes(report))
    return report


def main(argv=None, *, archive_factory=None, runner=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    recovery = commands.add_parser('recover', help='Create new baseline and recovery report; never overwrite')
    recovery.add_argument('--map', type=Path, required=True)
    recovery.add_argument('--project', type=Path, required=True)
    recovery.add_argument('--expected-sha256', required=True)
    for command in ('assemble', 'build'):
        sub = commands.add_parser(command, help=('Assemble only; no external tool' if command == 'assemble' else
                                                'Classic pJASS then wc3ctl injection into a new copy'))
        for flag in ('base', 'globals', 'functions', 'output-dir'):
            sub.add_argument('--' + flag, type=Path, required=True)
        sub.add_argument('--early-functions', type=Path,
                         help='Manual plain-JASS helpers after endglobals; requires --hooks')
        sub.add_argument('--hooks', type=Path,
                         help='Manual byte-pinned insertion manifest; requires --early-functions')
        sub.add_argument('--entry', required=True, help='Plain JASS no-argument function, e.g. IL_Start or ILM_Init')
        sub.add_argument('--run-id', required=True, help='1-80 ASCII letters/digits/_/-; starts alphanumeric; new directory')
        if command == 'build':
            sub.add_argument('--wc3', type=Path, required=True, help='Reviewed workshop wrapper supporting pjass and wc3ctl')
    args = parser.parse_args(argv)
    try:
        if archive_factory is None:
            from mpyq import MPQArchive
            archive_factory = MPQArchive
        report = recover(args, archive_factory) if args.command == 'recover' else build(args, archive_factory, runner or run_tool)
        print(json.dumps(report, ensure_ascii=True))
        return 0
    except (OSError, ValueError, RuntimeError, ImportError, struct.error, UnicodeError) as exc:
        print('error: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
