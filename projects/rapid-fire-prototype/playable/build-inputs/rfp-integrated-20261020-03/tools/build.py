#!/usr/bin/env python3
"""Recover the audited Classic snapshot or build an external-source executable test map."""
import argparse
import hashlib
from io import BytesIO
import json
from pathlib import Path
import re
import struct
import subprocess
import sys


LIBRARIES = ('TimerUtils', 'WorldBounds', 'DummyRecycler', 'Missiles')
RANGES = ((1, 275), (276, 332), (333, 822), (823, 1778))
# Explicit inventory, not a claim to enumerate protected/unnamed archive entries.
MEMBERS = ('war3map.j', 'war3map.wct', 'war3map.wtg', 'war3map.w3i',
           'war3map.w3e', 'war3map.w3u', 'war3map.w3a', 'war3map.w3t',
           'war3map.w3b', 'war3map.w3d', 'war3map.w3q', 'war3map.w3h',
           'war3map.wts', 'war3map.imp', 'war3map.doo', 'war3mapUnits.doo',
           'war3map.wpm', 'war3map.mmp', 'war3map.shd', 'war3mapMap.blp',
           'war3mapPreview.tga', 'war3mapImported\\dummy.mdx')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def json_bytes(value):
    return (json.dumps(value, indent=2, ensure_ascii=False) + '\n').encode('utf-8')


def write_new(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('xb') as stream:
        stream.write(data)


def guard(destinations, inputs):
    """Preflight the whole write set; no replacement, symlink traversal or nesting."""
    resolved = [p.resolve(strict=True) for p in inputs]
    for dest in destinations:
        dest = dest.absolute()
        for part in reversed((dest, *dest.parents)):
            if part.is_symlink():
                raise ValueError('symlink destination: ' + str(part))
        if dest.exists():
            raise ValueError('destination already exists: ' + str(dest))
        target = dest.resolve()
        if any(target == p or target in p.parents or p in target.parents for p in resolved):
            raise ValueError('destination overlaps input: ' + str(dest))


def mpq_offset(data):
    if data.startswith(b'MPQ\x1a'):
        return 0
    if not data.startswith(b'HM3W'):
        raise ValueError('expected HM3W map or raw MPQ')
    for offset in range(512, len(data), 512):
        if data[offset:offset + 4] == b'MPQ\x1a':
            return offset
    raise ValueError('aligned MPQ header not found')


def read_map(data, factory):
    # mpyq does not understand HM3W; provide an in-memory archive slice, never extract_to_disk.
    offset = mpq_offset(data)
    archive = factory(BytesIO(data[offset:]), listfile=False)
    members = {}
    archive.opaque_members = {}
    for name in MEMBERS:
        try:
            member = archive.read_file(name)
        except (RuntimeError, NotImplementedError) as exc:
            if name in ('war3map.j', 'war3map.wct'):
                raise
            # Do not implement another decompressor. Fingerprint the opaque payload
            # through the reviewed mpyq block metadata and retain the original map.
            entry = archive.get_hash_table_entry(name)
            block = archive.block_table[entry.block_table_index]
            archive.file.seek(archive.header['offset'] + block.offset)
            raw = archive.file.read(block.archived_size)
            if len(raw) != block.archived_size:
                raise ValueError('truncated opaque member: ' + name)
            archive.opaque_members[name] = {'error': str(exc), 'size': block.size,
                                            'flags': block.flags, 'raw_sha256': digest(raw)}
            continue
        if member is not None:
            members[name] = member
    for required in ('war3map.j', 'war3map.wct'):
        if required not in members:
            raise ValueError('missing member: ' + required)
    return data[:offset], members, archive


def wct_global(data):
    # Reviewed classic version-1 schema from map_inventory.WctReader; preserve raw bytes.
    if len(data) < 9 or struct.unpack_from('<I', data)[0] != 1:
        raise ValueError('expected classic WCT version 1')
    comment_end = data.find(b'\0', 4)
    if comment_end < 0 or comment_end + 5 > len(data):
        raise ValueError('truncated WCT comment')
    size = struct.unpack_from('<i', data, comment_end + 1)[0]
    start = comment_end + 5
    end = start + size
    if size < 1 or end > len(data) or data[end - 1] != 0:
        raise ValueError('invalid WCT global block')
    return data[start:end - 1]


def split_global(source):
    starts = list(re.finditer(rb'^library ([A-Za-z_]\w*)\b', source, re.M))
    scope = re.search(rb'^scope RelativisticMissilesTest\b', source, re.M)
    if [m[1].decode() for m in starts] != list(LIBRARIES) or not scope:
        raise ValueError('unexpected WCT library boundaries')
    offsets = [m.start() for m in starts] + [scope.start()]
    blocks = [source[a:b] for a, b in zip(offsets, offsets[1:])]
    lines = source.splitlines(keepends=True)
    if len(lines) != 1820:
        raise ValueError('expected 1820 WCT global lines')
    for block, (start, end) in zip(blocks, RANGES):
        if block != b''.join(lines[start - 1:end]) or not block.rstrip().endswith(b'endlibrary'):
            raise ValueError('unexpected WCT library boundaries')
        if len(re.findall(rb'^endlibrary\s*$', block, re.M)) != 1:
            raise ValueError('unexpected WCT library boundaries')
    return dict(zip(LIBRARIES, blocks))


def function_bytes(jass, name):
    found = re.search(rb'^function ' + name.encode() + rb' takes[^\r\n]*[\s\S]*?^endfunction[^\S\r\n]*(?:\r?\n|$)', jass, re.M)
    if not found:
        raise ValueError('missing original function: ' + name)
    return found[0]


def bootstrap(jass):
    helpers = b'\n'.join(function_bytes(jass, name) for name in
                         ('InitCustomPlayerSlots', 'InitAllyPriorities', 'config'))
    # Keep original environment/camera calls, but NOT CreateAllUnits/Items or XE/demo triggers.
    original = re.search(rb'^function main takes[^\r\n]*[\s\S]*?^endfunction', jass, re.M)
    environment = []
    if original:
        names = (b'SetCameraBounds', b'SetDayNightModels', b'NewSoundEnvironment',
                 b'SetAmbientDaySound', b'SetAmbientNightSound', b'SetMapMusic')
        environment = [line for line in original[0].splitlines() if any(b'call ' + n + b'(' in line for n in names)]
    return (b'// External-source executable test bootstrap; no original demonstration triggers.\n'
            b'globals\n    rect RC_TEST_REGION = null\nendglobals\n' + helpers +
            b'\nfunction main takes nothing returns nothing\n' + b'\n'.join(environment) +
            b'\n    call InitBlizzard()\n'
            b'    set RC_TEST_REGION = Rect(-1024., -1024., 1024., 1024.)\n'
            b'    call PanCameraTo(0., 0.)\n'
            b'    call RCStartHarness()\nendfunction\n')


def recover(args, factory):
    original = args.map.resolve(strict=True)
    data = original.read_bytes()
    if digest(data) != args.expected_sha256:
        raise ValueError('source map SHA-256 mismatch')
    prefix, members, archive = read_map(data, factory)
    source = wct_global(members['war3map.wct'])
    blocks = split_global(source)
    if members['war3map.j'].count(source) != 1:
        raise ValueError('WCT global is not uniquely byte-identical in war3map.j')
    root = args.project.absolute()
    files = {root / 'baseline/original.w3x': data, root / 'baseline/global.j': source}
    for name, block in blocks.items():
        files[root / ('baseline/' + name + '.j')] = block
        relative = 'src/Missiles.j' if name == 'Missiles' else 'src/libraries/' + name + '.j'
        files[root / relative] = block
    files[root / 'baseline/original-harness.j'] = source[sum(map(len, blocks.values())):]
    files[root / 'src/MapMain.j'] = bootstrap(members['war3map.j'])
    inventory = {}
    for name, member in members.items():
        relative = 'baseline/members/' + name.replace('\\', '/')
        files[root / relative] = member
        inventory[name] = {'size': len(member), 'sha256': digest(member)}
    report = {'source_map': str(original), 'source_sha256': digest(data),
              'prefix_sha256': digest(prefix), 'prefix_size': len(prefix),
              'global_sha256': digest(source), 'global_lines': 1820,
              'global_j_first_line': members['war3map.j'][:members['war3map.j'].index(source)].count(b'\n') + 1,
              'libraries': {name: {'sha256': digest(block), 'wct_lines': list(lines)}
                            for (name, block), lines in zip(blocks.items(), RANGES)},
              'members': inventory, 'opaque_members': archive.opaque_members,
              'archive_block_count': len(archive.block_table),
              'inventory_complete': False,
              'limitations': ['Explicit named-member inventory only; encrypted listfile is not decoded.',
                              'No compilation, game execution or editor-save certification.'],
              'permission': 'User-authorized local recovery/modification; redistribution rights not inferred.',
              'credits': 'Original source comments preserved: Chopinski; BPower, Dirac, Vexorian; Flux. WorldBounds attribution follows original link to nestharus.'}
    files[root / 'reports/recovery.json'] = json_bytes(report)
    guard(files, [original])
    for path, payload in files.items():
        write_new(path, payload)
    if original.read_bytes() != data:
        raise ValueError('source map changed during recovery')
    return report


def run_tool(argv):
    # No shell, retries, game process control, or automatic legacy pJASS switches.
    process = subprocess.run(argv, capture_output=True, text=True)
    return {'returncode': process.returncode, 'stdout': process.stdout, 'stderr': process.stderr}


def build(args, factory, runner):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,79}', args.run_id):
        raise ValueError('invalid run-id')
    if args.entry and not re.fullmatch(r'[A-Za-z_]\w*', args.entry):
        raise ValueError('invalid harness entry identifier')
    if bool(args.harness) != bool(args.entry):
        raise ValueError('--harness and --entry must be supplied together')
    sources = [args.timer_utils, args.world_bounds, args.dummy_recycler, args.core,
               *args.harness, args.bootstrap]
    sources = [p.resolve(strict=True) for p in sources]
    base, wc3 = args.base.resolve(strict=True), args.wc3.resolve(strict=True)
    inputs = [base, wc3, *sources]
    if len({(p.stat().st_dev, p.stat().st_ino) for p in inputs}) != len(inputs):
        raise ValueError('duplicate or aliased inputs')
    run = args.output_dir.absolute() / args.run_id
    guard([run], inputs)
    before = {p: p.read_bytes() for p in inputs}
    for p in sources:
        text = before[p].decode('utf-8')
        if text.startswith('\ufeff') or re.search(r'^\s*//!\s*import\b', text, re.M):
            raise ValueError('nested imports are not supported; pass each source explicitly')
        if any(ch in str(p) for ch in ('"', '\n', '\r', '\\')):
            raise ValueError('unsupported source path characters')
    prefix, old_members, old_archive = read_map(before[base], factory)
    entry = ''
    # Canonical explicit imports; never concatenate or regex-namespace existing map script.
    for p in sources[:-1]:
        entry += '//! import "Z:' + str(p).replace('/', '\\') + '"\n'
    entry += 'function RCStartHarness takes nothing returns nothing\n'
    if args.entry:
        entry += '    call ' + args.entry + '()\n'
    entry += 'endfunction\n//! import "Z:' + str(sources[-1]).replace('/', '\\') + '"\n'
    run.mkdir(parents=True)
    write_new(run / 'entry.j', entry.encode('utf-8'))
    commands = []

    def invoke(argv):
        result = runner([str(value) for value in argv])
        commands.append(dict(argv=[str(value) for value in argv], **result))
        # Append-only diagnostics: each command has its own immutable log, aggregate last.
        write_new(run / ('command-%d.json' % len(commands)), json_bytes(commands[-1]))
        if result['returncode']:
            write_new(run / 'commands.json', json_bytes(commands))
            raise ValueError('tool failed (%d); see commands.json' % result['returncode'])

    compiled, injected = run / 'compiled.j', run / 'injected.w3x'
    invoke([wc3, 'vjass', run / 'entry.j', compiled])
    invoke([wc3, 'wc3ctl', 'file', 'set', base, 'war3map.j', compiled, '--out', injected, '--json'])
    write_new(run / 'commands.json', json_bytes(commands))
    injected_bytes = injected.read_bytes()
    output_bytes = prefix + injected_bytes[mpq_offset(injected_bytes):]
    # Re-extract from the assembled bytes, not just the injector's intermediate.
    final_prefix, members, final_archive = read_map(output_bytes, factory)
    if final_archive.opaque_members != old_archive.opaque_members:
        raise ValueError('opaque archive payload changed')
    expected = dict(old_members, **{'war3map.j': compiled.read_bytes()})
    for name, payload in expected.items():
        if members.get(name) != payload:
            raise ValueError('member roundtrip mismatch: ' + name)
    if final_prefix != prefix:
        raise ValueError('HM3W prefix mismatch')
    if any(p.read_bytes() != payload for p, payload in before.items()):
        raise ValueError('input changed during build')
    output = run / (args.run_id + '.w3x')
    report = {'output': str(output), 'sha256': digest(output_bytes),
              'inputs': {str(p): digest(payload) for p, payload in before.items()},
              'managed': {'war3map.j': digest(expected['war3map.j'])},
              'preserved_members': {n: digest(b) for n, b in old_members.items() if n != 'war3map.j'},
              'prefix_sha256': digest(prefix), 'opaque_members': final_archive.opaque_members,
              'editor_save_certified': False,
              'source_of_truth': 'external explicit sources; retained original WCT/WTG are NOT executable source',
              'scope': 'Executable-test build only. No editor-save, gameplay or multiplayer certification.'}
    write_new(run / 'build.json', json_bytes(report))
    write_new(output, output_bytes)
    return report


def main(argv=None, *, archive_factory=None, runner=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    recovery = commands.add_parser('recover', help='New immutable baseline and byte-identical working sources')
    recovery.add_argument('--map', type=Path, required=True)
    recovery.add_argument('--project', type=Path, required=True)
    recovery.add_argument('--expected-sha256', required=True)
    building = commands.add_parser('build', help='JassHelper + pJASS + verified MPQ injection; never launches game')
    for flag in ('base', 'wc3', 'timer-utils', 'world-bounds', 'dummy-recycler', 'core', 'bootstrap', 'output-dir'):
        building.add_argument('--' + flag, type=Path, required=True)
    building.add_argument('--run-id', required=True, help='Unique immutable run directory and final map name')
    building.add_argument('--harness', type=Path, action='append', default=[], help='Explicit additional source; repeat in import order; no nested imports')
    building.add_argument('--entry', help='Public no-argument harness function called after InitBlizzard')
    args = parser.parse_args(argv)
    try:
        if archive_factory is None:
            from mpyq import MPQArchive
            archive_factory = MPQArchive
        result = recover(args, archive_factory) if args.command == 'recover' else build(args, archive_factory, runner or run_tool)
        print(json.dumps(result, ensure_ascii=False))
        return 0
    except (OSError, ValueError, RuntimeError, ImportError, struct.error) as exc:
        print('error: ' + str(exc), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
