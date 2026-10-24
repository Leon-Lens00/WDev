"""Public CLI contract tests; fake archive/tools never execute external programs."""
import contextlib
import importlib.util
import hashlib
import io
import json
import os
from pathlib import Path
import struct
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

TOOL = Path(__file__).resolve().parents[1] / 'tools/build.py'
SCRATCH = Path(os.environ.get('TMPDIR') or '/tmp/wdev-inventorysys-lab')
ORIGINAL = (b'// credits retained\r\nglobals\r\ninteger demo = 1\r\nendglobals\r\n'
            b'function main takes nothing returns nothing\r\n'
            b'    call StartGame___Init()\r\n    call InitCustomTriggers()\r\n\r\n'
            b'endfunction\r\nfunction config takes nothing returns nothing\r\nendfunction\r\n')


def wct():
    block = b'// Author credit\rlibrary Demo\rendlibrary'
    return struct.pack('<I', 1) + b'comment\0' + struct.pack('<i', 0) + struct.pack('<Ii', 1, len(block) + 1) + block + b'\0'


def map_bytes(script=ORIGINAL, changed=False):
    members = {'war3map.j': script.hex(), 'war3map.wct': wct().hex(),
               'war3map.wtg': b'GUI'.hex(), 'war3map.wts': b'credits'.hex(),
               'war3map.w3u': (b'changed' if changed else b'objects').hex()}
    return b'HM3W' + bytes(508) + b'MPQ\x1a' + json.dumps(members).encode()


def fake_identity(name):
    known = {'war3map.j': (3382118375, 2511869006, 0, 0),
             '(listfile)': (4251285776, 1318820007, 0, 0),
             '(attributes)': (3548657611, 132115180, 0, 0)}
    values = struct.unpack('<II', hashlib.sha256(name.encode()).digest()[:8])
    return known.get(name, (*values, 0, 0))


class Archive:
    def __init__(self, stream, listfile):
        assert listfile is False
        self.members = {n: bytes.fromhex(v) for n, v in json.loads(stream.read()[4:]).items()}
        self.block_table, self.hash_table = [], []
        raw = b''
        for name, payload in self.members.items():
            self.block_table.append(SimpleNamespace(offset=len(raw), archived_size=len(payload),
                                                    size=len(payload), flags=0x80000000))
            raw += payload
            a, b, locale, platform = fake_identity(name)
            self.hash_table.append(SimpleNamespace(hash_a=a, hash_b=b, locale=locale, platform=platform,
                                                   block_table_index=len(self.block_table) - 1))
        self.file = io.BytesIO(raw)
        self.header = {'offset': 0, 'format_version': 0, 'sector_size_shift': 3}

    def get_hash_table_entry(self, name):
        key = fake_identity(name)
        return next((e for e in self.hash_table if (e.hash_a, e.hash_b, e.locale, e.platform) == key), None)

    def read_file(self, name):
        return self.members.get(name)


class CliTests(unittest.TestCase):
    def setUp(self):
        SCRATCH.mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix='cli-', dir=SCRATCH)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        environment = {}
        for variable, directory in (('HOME', 'home'), ('TMPDIR', 'tmp'), ('XDG_CACHE_HOME', 'cache')):
            path = self.root / directory
            path.mkdir()
            environment[variable] = str(path)
        env_patch = patch.dict(os.environ, environment)
        env_patch.start()
        self.addCleanup(env_patch.stop)
        spec = importlib.util.spec_from_file_location('inventory_build', TOOL)
        self.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.module)
        self.base = self.root / 'base.w3x'
        self.base.write_bytes(map_bytes())
        self.globals = self.root / 'globals.j'
        self.globals.write_bytes(b'    string IL_RUN = "@RUN_ID@"\n')
        self.functions = self.root / 'functions.j'
        self.functions.write_bytes(b'function IL_Start takes nothing returns nothing\nendfunction\n')
        self.wc3 = self.root / 'wc3'
        self.wc3.write_bytes(b'fake tool')
        self.calls = []

    def invoke(self, args, runner=None, factory=None):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = self.module.main(args, archive_factory=factory or Archive, runner=runner or self.runner)
        return code, out.getvalue(), err.getvalue()

    def arguments(self, command='assemble'):
        return [command, '--base', str(self.base), '--globals', str(self.globals),
                '--functions', str(self.functions), '--entry', 'IL_Start', '--run-id', 'inv-001',
                '--output-dir', str(self.root / 'runs')] + (['--wc3', str(self.wc3)] if command == 'build' else [])

    def runner(self, argv):
        self.calls.append(argv)
        if argv[1] == 'wc3ctl':
            assembled = Path(argv[6]).read_bytes()
            Path(argv[8]).write_bytes(map_bytes(assembled))
        return {'returncode': 0, 'stdout': 'tool stdout\n', 'stderr': 'tool stderr\n'}

    def reject(self, args, message):
        before = {p: p.read_bytes() for p in (self.base, self.globals, self.functions, self.wc3)}
        code, out, err = self.invoke(args)
        self.assertEqual((code, out, err), (1, '', 'error: ' + message + '\n'))
        for path, data in before.items():
            self.assertEqual(path.read_bytes(), data)
        self.assertFalse((self.root / 'runs').exists())
        self.assertEqual(self.calls, [])

    def test_assembly_preserves_original_bytes_and_hooks_after_demo(self):
        code, out, err = self.invoke(self.arguments())
        self.assertEqual((code, err), (0, ''))
        report = json.loads(out)
        run = self.root / 'runs/inv-001'
        self.assertEqual(report, json.loads((run / 'assembly.json').read_text()))
        script = (run / 'assembled.j').read_bytes()
        g = b'    string IL_RUN = "inv-001"\n'
        f = self.functions.read_bytes()
        hook = b'    call IL_Start()\r\n'
        self.assertEqual(script, ORIGINAL.replace(b'endglobals', g + b'endglobals').replace(
            b'function main takes', f + b'function main takes').replace(
            b'\r\nendfunction\r\nfunction config', b'\r\n' + hook + b'endfunction\r\nfunction config'))
        self.assertEqual(self.base.read_bytes(), map_bytes())
        self.assertEqual(self.calls, [])
        snapshot = {p: p.read_bytes() for p in run.iterdir()}
        code, out, err = self.invoke(self.arguments())
        self.assertEqual((code, out), (1, ''))
        self.assertEqual(err, 'error: destination already exists: ' + str(run) + '\n')
        self.assertEqual({p: p.read_bytes() for p in run.iterdir()}, snapshot)

    def test_recovered_original_startup_is_preserved_byte_for_byte(self):
        original = (TOOL.parents[1] / 'baseline/members/war3map.j').read_bytes()
        self.base.write_bytes(map_bytes(original))
        code, out, err = self.invoke(self.arguments())
        self.assertEqual((code, err), (0, ''))
        self.assertEqual(json.loads(out)['startup'], 'At end of original main, after InitCustomTriggers()')
        expected = original.replace(b'\r\nendglobals\r\n',
                                    b'\r\n    string IL_RUN = "inv-001"\nendglobals\r\n', 1)
        expected = expected.replace(b'function main takes nothing returns nothing',
                                    self.functions.read_bytes() + b'function main takes nothing returns nothing', 1)
        expected = expected.replace(b'    call InitCustomTriggers()\r\n\r\nendfunction',
                                    b'    call InitCustomTriggers()\r\n\r\n    call IL_Start()\r\nendfunction', 1)
        script = (self.root / 'runs/inv-001/assembled.j').read_bytes()
        self.assertEqual(script, expected)
        self.assertEqual(script.count(b'    call IL_Start()'), 1)
        self.assertEqual(self.base.read_bytes(), map_bytes(original))
        self.assertEqual(self.calls, [])

    def test_reject_bad_run_ids(self):
        for value in ('../escape', '.', '..', 'bad id', 'a' * 81):
            with self.subTest(value=value):
                args = self.arguments(); args[args.index('--run-id') + 1] = value
                self.reject(args, 'invalid run-id')

    def test_reject_missing_duplicate_or_changed_anchors(self):
        for script in (ORIGINAL.replace(b'\r\nglobals\r\n', b'\r\n// removed\r\n'),
                       ORIGINAL.replace(b'endglobals', b'// removed'),
                       ORIGINAL + b'\nendglobals\n',
                       ORIGINAL.replace(b'function main takes', b'function absent takes'),
                       ORIGINAL + ORIGINAL,
                       ORIGINAL.replace(b'    call InitCustomTriggers()', b'    call OtherInit()')):
            with self.subTest(script=script):
                self.base.write_bytes(map_bytes(script))
                self.reject(self.arguments(), 'unexpected original assembly anchors')

    def test_reject_adapter_imports_and_missing_entry(self):
        for value, message in ((b'//! import "duplicate.j"\n', 'adapter must be plain JASS without imports'),
                               (b'function Other takes nothing returns nothing\nendfunction\n', 'entry must occur exactly once in adapter')):
            self.functions.write_bytes(value)
            self.reject(self.arguments(), message)

    def test_reject_input_alias_and_symlink_destination(self):
        self.functions.unlink()
        os.link(self.globals, self.functions)
        self.reject(self.arguments(), 'duplicate or aliased inputs')
        self.functions.unlink()
        self.functions.write_bytes(b'function IL_Start takes nothing returns nothing\nendfunction\n')
        (self.root / 'runs').symlink_to(self.root, target_is_directory=True)
        self.assertEqual(self.invoke(self.arguments()),
                         (1, '', 'error: symlink destination: ' + str(self.root / 'runs') + '\n'))
        self.assertFalse((self.root / 'inv-001').exists())
        self.assertEqual(self.base.read_bytes(), map_bytes())

    def test_build_public_roundtrip_and_exact_tool_evidence(self):
        code, out, err = self.invoke(self.arguments('build'))
        self.assertEqual((code, err), (0, ''))
        report = json.loads(out)
        run = self.root / 'runs/inv-001'
        self.assertEqual(report, json.loads((run / 'build.json').read_text()))
        self.assertEqual(Path(report['output']).read_bytes(), map_bytes((run / 'assembled.j').read_bytes()))
        commands = json.loads((run / 'commands.json').read_text())
        self.assertEqual([c['argv'] for c in commands], self.calls)
        self.assertEqual(self.calls[0], [str(self.wc3), 'pjass', str(run / 'assembled.j')])
        self.assertEqual(self.calls[1], [str(self.wc3), 'wc3ctl', 'file', 'set', str(run / 'input.w3x'),
                                       'war3map.j', str(run / 'assembled.j'), '--out', str(run / 'injected.w3x'), '--json'])
        for command in commands:
            self.assertEqual({k: command[k] for k in ('returncode', 'stdout', 'stderr')},
                             {'returncode': 0, 'stdout': 'tool stdout\n', 'stderr': 'tool stderr\n'})
        self.assertEqual(self.base.read_bytes(), map_bytes())

    def test_tool_failure_retains_diagnostics_without_publishing_map(self):
        def failure(argv):
            return {'returncode': 7, 'stdout': 'before failure\n', 'stderr': 'compiler error\n'}
        code, out, err = self.invoke(self.arguments('build'), failure)
        self.assertEqual((code, out, err), (1, '', 'error: tool failed (7); see commands.json\n'))
        run = self.root / 'runs/inv-001'
        self.assertFalse((run / 'inv-001.w3x').exists())
        self.assertFalse((run / 'build.json').exists())
        self.assertEqual(json.loads((run / 'commands.json').read_text())[0]['stderr'], 'compiler error\n')
        self.assertEqual(self.base.read_bytes(), map_bytes())

    def test_roundtrip_mismatch_fails_closed(self):
        def corrupt(argv):
            result = self.runner(argv)
            if argv[1] == 'wc3ctl':
                Path(argv[8]).write_bytes(map_bytes(Path(argv[6]).read_bytes(), changed=True))
            return result
        code, out, err = self.invoke(self.arguments('build'), corrupt)
        self.assertEqual((code, out, err), (1, '', 'error: member roundtrip mismatch: war3map.w3u\n'))
        self.assertFalse((self.root / 'runs/inv-001/inv-001.w3x').exists())
        self.assertEqual(self.base.read_bytes(), map_bytes())

    def test_recover_preserves_blocks_and_rejects_overwrite(self):
        project = self.root / 'recovery'
        args = ['recover', '--map', str(self.base), '--project', str(project), '--expected-sha256',
                self.module.digest(self.base.read_bytes())]
        code, out, err = self.invoke(args)
        self.assertEqual((code, err), (0, ''))
        report = json.loads(out)
        self.assertEqual(report, json.loads((project / 'reports/recovery.json').read_text()))
        self.assertEqual((project / 'baseline/original.w3x').read_bytes(), self.base.read_bytes())
        self.assertEqual((project / 'baseline/wct/trigger-000.j').read_bytes(), b'// Author credit\rlibrary Demo\rendlibrary')
        code, out, err = self.invoke(args)
        self.assertEqual((code, out), (1, ''))
        self.assertEqual(err, 'error: destination already exists: ' + str(project / 'baseline') + '\n')
        self.assertEqual(self.base.read_bytes(), map_bytes())

    def test_opaque_raw_payload_change_fails_closed(self):
        def factory(stream, listfile):
            archive = Archive(stream, listfile)
            # Non-script opaque payload is never passed to read_file/decompression.
            old = archive.members['war3map.j'] == ORIGINAL
            archive.file = io.BytesIO(b'JASS' + (b'old' if old else b'new'))
            archive.block_table = [SimpleNamespace(offset=0, archived_size=4, size=4, flags=0x80000000),
                                   SimpleNamespace(offset=4, archived_size=3, size=9, flags=0x80000200)]
            archive.hash_table = [SimpleNamespace(hash_a=3382118375, hash_b=2511869006, locale=0,
                                                  platform=0, block_table_index=0),
                                  SimpleNamespace(hash_a=1, hash_b=2, locale=0, platform=0, block_table_index=1)]
            return archive

        self.assertEqual(self.invoke(self.arguments('build'), factory=factory),
                         (1, '', 'error: opaque raw MPQ payload changed\n'))
        self.assertFalse((self.root / 'runs/inv-001/inv-001.w3x').exists())
        self.assertEqual(self.base.read_bytes(), map_bytes())

    def replay_failed_fixture(self, corrupt=False):
        from mpyq import MPQArchive
        project = TOOL.parents[1]
        failed = project / 'reports/runs/inv-baseline-20261019-01'
        protected = [*sorted((project / 'baseline').rglob('*')), *sorted(failed.iterdir()),
                     project / 'src/globals.j', project / 'src/functions.j']
        before = {p: p.read_bytes() for p in protected if p.is_file()}
        injected = bytearray((failed / 'injected.w3x').read_bytes())
        if corrupt:
            archive = MPQArchive(io.BytesIO(injected[512:]), listfile=False)
            named = {archive.get_hash_table_entry(n).block_table_index
                     for n in (*self.module.MEMBERS, '(listfile)', '(attributes)')
                     if archive.get_hash_table_entry(n) is not None}
            block = next(b for i, b in enumerate(archive.block_table)
                         if i not in named and b.flags & 0x80000000 and b.archived_size > 8)
            # Mutate a real unnamed asset, not a managed/named member or housekeeping.
            injected[512 + block.offset + block.archived_size // 2] ^= 1

        def replay(argv):
            self.calls.append(argv)
            if argv[1] == 'wc3ctl':
                self.assertEqual(Path(argv[6]).read_bytes(), (failed / 'assembled.j').read_bytes())
                Path(argv[8]).write_bytes(injected)
            return {'returncode': 0, 'stdout': 'fixture replay only\n', 'stderr': ''}

        args = ['build', '--base', str(project / 'baseline/original.w3x'),
                '--globals', str(project / 'src/globals.j'), '--functions', str(project / 'src/functions.j'),
                '--entry', 'IL_Start', '--run-id', 'inv-baseline-20261019-01',
                '--output-dir', str(self.root / 'replay'), '--wc3', str(self.wc3)]
        result = self.invoke(args, runner=replay, factory=MPQArchive)
        self.assertEqual({p: p.read_bytes() for p in before}, before)
        self.assertEqual(len(self.calls), 2)
        return result, self.root / 'replay/inv-baseline-20261019-01', bytes(injected)

    def test_identity_remapping_and_unsupported_housekeeping_changes_rejected(self):
        for mutation in ('swap', 'unknown-add', 'localized-listfile', 'removed', 'existing-attributes',
                         'fixed-key-relocation', 'sector-size', 'orphan'):
            with self.subTest(mutation=mutation):
                def factory(stream, listfile):
                    archive = Archive(stream, listfile)
                    modified = archive.members['war3map.j'] != ORIGINAL
                    if mutation == 'existing-attributes':
                        a, b, locale, platform = fake_identity('(attributes)')
                        archive.hash_table[1].hash_a, archive.hash_table[1].hash_b = a, b
                        if modified:
                            archive.block_table[1].flags |= 0x10000
                    elif mutation == 'fixed-key-relocation':
                        archive.block_table[1].flags |= 0x30000
                        if modified:
                            # Same raw bytes at another location are not proof for FIX_KEY.
                            raw = archive.file.getvalue()
                            archive.file = io.BytesIO(b'x' + raw)
                            for block in archive.block_table:
                                block.offset += 1
                    elif modified:
                        if mutation == 'swap':
                            archive.hash_table[1].block_table_index, archive.hash_table[2].block_table_index = 2, 1
                        elif mutation in ('unknown-add', 'localized-listfile'):
                            key = fake_identity('(listfile)') if mutation == 'localized-listfile' else (1, 2, 0, 0)
                            archive.hash_table.append(SimpleNamespace(hash_a=key[0], hash_b=key[1],
                                                                     locale=1 if mutation == 'localized-listfile' else 0,
                                                                     platform=0, block_table_index=1))
                        elif mutation == 'removed':
                            archive.hash_table.pop()
                        elif mutation == 'sector-size':
                            archive.header['sector_size_shift'] += 1
                        elif mutation == 'orphan':
                            archive.block_table.append(archive.block_table[1])
                    return archive

                args = self.arguments('build')
                args[args.index('--run-id') + 1] = 'case-' + mutation
                before = {p: p.read_bytes() for p in (self.base, self.globals, self.functions, self.wc3)}
                self.assertEqual(self.invoke(args, factory=factory),
                                 (1, '', 'error: opaque raw MPQ payload changed\n'))
                run = self.root / 'runs' / ('case-' + mutation)
                self.assertFalse((run / ('case-' + mutation + '.w3x')).exists())
                self.assertFalse((run / 'build.json').exists())
                self.assertEqual({p: p.read_bytes() for p in before}, before)

    def test_real_failed_fixture_housekeeping_rewrite_is_accepted(self):
        (code, out, err), run, injected = self.replay_failed_fixture()
        self.assertEqual((code, err), (0, ''))
        report = json.loads(out)
        self.assertEqual(report, json.loads((run / 'build.json').read_text()))
        self.assertEqual(Path(report['output']).read_bytes(), injected)
        self.assertEqual(report['archive_preservation']['preserved_identities'], 52)
        self.assertEqual([r['name'] for r in report['archive_preservation']['housekeeping_changes']],
                         ['(attributes)', '(listfile)'])

    def test_real_unknown_asset_corruption_is_rejected(self):
        result, run, _ = self.replay_failed_fixture(corrupt=True)
        self.assertEqual(result, (1, '', 'error: opaque raw MPQ payload changed\n'))
        self.assertFalse((run / 'inv-baseline-20261019-01.w3x').exists())
        self.assertFalse((run / 'build.json').exists())
        self.assertTrue((run / 'commands.json').exists())

    def test_managed_script_mismatch_fails_closed(self):
        def corrupt(argv):
            result = self.runner(argv)
            if argv[1] == 'wc3ctl':
                Path(argv[8]).write_bytes(map_bytes(ORIGINAL))
            return result
        self.assertEqual(self.invoke(self.arguments('build'), corrupt),
                         (1, '', 'error: member roundtrip mismatch: war3map.j\n'))
        self.assertFalse((self.root / 'runs/inv-001/inv-001.w3x').exists())
        self.assertEqual(self.base.read_bytes(), map_bytes())

    def test_invalid_entry_and_output_input_overlap_rejected(self):
        args = self.arguments()
        args[args.index('--entry') + 1] = 'IL_Start()'
        self.reject(args, 'invalid harness entry identifier')
        args = self.arguments()
        args[args.index('--output-dir') + 1] = str(self.base)
        self.reject(args, 'destination overlaps input or output: ' + str(self.base / 'inv-001'))

    def test_recovery_hash_mismatch_writes_nothing(self):
        project = self.root / 'recovery'
        code, out, err = self.invoke(['recover', '--map', str(self.base), '--project', str(project),
                                      '--expected-sha256', '0' * 64])
        self.assertEqual((code, out, err), (1, '', 'error: source map SHA-256 mismatch\n'))
        self.assertFalse(project.exists())


if __name__ == '__main__':
    unittest.main()
