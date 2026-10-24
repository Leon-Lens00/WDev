"""Synthetic CLI tests; never invoke Wine, installed tools, or real maps."""
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import struct
import tempfile
from types import SimpleNamespace
import unittest

MODULE = Path(__file__).resolve().parents[1] / 'tools' / 'build.py'


def load_cli():
    spec = importlib.util.spec_from_file_location('classic_build', MODULE)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Archive:
    """Fake reader protocol, not an MPQ implementation."""
    def __init__(self, stream, listfile=False):
        self.file = stream
        assert stream.read(4) == b'MPQ\x1a'
        raw = stream.read()
        self.members = {k: bytes.fromhex(v) for k, v in json.loads(raw).items()}
        self.header = {'offset': 0}
        self.block_table = []

    def get_hash_table_entry(self, name):
        payload = self.members.get(name)
        if payload is None:
            return None
        raw = self.file.getvalue()
        self.block_table = [SimpleNamespace(offset=raw.index(payload.hex().encode()),
                                           archived_size=len(payload.hex()), size=len(payload), flags=123)]
        return SimpleNamespace(block_table_index=0)

    def read_file(self, name):
        payload = self.members.get(name)
        if payload == b'opaque-compression':
            raise RuntimeError('Unsupported compression type.')
        return payload


def archive_bytes(members, prefix=b'HM3W' + b'X' * 508):
    return prefix + b'MPQ\x1a' + json.dumps({k: v.hex() for k, v in members.items()}).encode()


class BuildTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.cli = load_cli()
        self.base = self.root / 'original.w3x'
        self.members = {'war3map.j': b'old demo script', 'war3map.wct': b'original editor data',
                        'war3map.w3e': b'terrain', 'war3map.w3u': b'objects'}
        self.base.write_bytes(archive_bytes(self.members))
        self.sources = []
        for name in ('TimerUtils', 'WorldBounds', 'DummyRecycler', 'Missiles', 'MapMain'):
            p = self.root / (name + '.j')
            p.write_text('// ' + name + '\n')
            self.sources.append(p)
        self.wc3 = self.root / 'wc3'
        self.wc3.write_text('fake launcher')
        self.args = ['build', '--base', str(self.base), '--wc3', str(self.wc3),
                     '--output-dir', str(self.root / 'build'), '--run-id', 'run-001']
        for flag, p in zip(('timer-utils', 'world-bounds', 'dummy-recycler', 'core', 'bootstrap'), self.sources):
            self.args.extend(['--' + flag, str(p)])
        self.calls = []

    def snapshot(self):
        return {str(p.relative_to(self.root)): p.read_bytes()
                for p in self.root.rglob('*') if p.is_file()}

    def invoke(self, args, runner=None):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = self.cli.main(args, archive_factory=Archive, runner=runner or self.runner)
        return code, out.getvalue(), err.getvalue()

    def runner(self, argv):
        self.calls.append(argv)
        if argv[1] == 'vjass':
            Path(argv[3]).write_bytes(b'compiled JASS')
        else:
            self.assertEqual(argv[1:4], ['wc3ctl', 'file', 'set'])
            self.assertEqual(argv[5], 'war3map.j')
            members = dict(self.members, **{'war3map.j': Path(argv[6]).read_bytes()})
            # Deliberately different tool header: builder must restore the original.
            Path(argv[8]).write_bytes(archive_bytes(members, b'HM3W' + b'Y' * 508))
        return {'returncode': 0, 'stdout': 'fake ok\n', 'stderr': ''}

    def reject(self, args, message):
        before = self.snapshot()
        self.assertEqual(self.invoke(args), (1, '', 'error: ' + message + '\n'))
        self.assertEqual(self.snapshot(), before)
        self.assertEqual(self.calls, [])

    def test_help(self):
        with contextlib.redirect_stdout(io.StringIO()) as out:
            with self.assertRaises(SystemExit) as done:
                self.cli.main(['--help'])
        self.assertEqual(done.exception.code, 0)
        self.assertIn('recover', out.getvalue())
        self.assertIn('build', out.getvalue())

    def test_collision_before_any_write(self):
        args = self.args.copy()
        args[args.index('--output-dir') + 1] = str(self.root)
        args[args.index('--run-id') + 1] = 'Missiles.j'
        self.reject(args, 'destination already exists: ' + str(self.sources[3]))

    def test_existing_run_is_immutable(self):
        run = self.root / 'build' / 'run-001'
        run.mkdir(parents=True)
        (run / 'run-001.w3x').write_bytes(b'previous final')
        self.reject(self.args, 'destination already exists: ' + str(run))

    def test_invalid_run_id_rejected(self):
        self.reject(self.args + ['--run-id', '..'], 'invalid run-id')

    def test_destination_ancestor_of_input_rejected(self):
        nested = self.root / 'build/run-001' / 'core.j'
        nested.parent.mkdir(parents=True)
        nested.write_bytes(self.sources[3].read_bytes())
        # An occupied directory is rejected first, before any input is read by a tool.
        self.reject(self.args + ['--core', str(nested)],
                    'destination already exists: ' + str(nested.parent))

    def test_hardlink_input_alias_rejected(self):
        alias = self.root / 'alias.j'
        alias.hardlink_to(self.sources[0])
        self.reject(self.args + ['--core', str(alias)], 'duplicate or aliased inputs')

    def test_invalid_entry_rejected(self):
        self.reject(self.args + ['--harness', str(self.sources[0]), '--entry', 'Bad()'],
                    'invalid harness entry identifier')

    def test_harness_requires_entry(self):
        self.reject(self.args + ['--harness', str(self.sources[0])],
                    '--harness and --entry must be supplied together')

    def test_symlink_output_rejected(self):
        (self.root / 'build').symlink_to(self.root, target_is_directory=True)
        self.reject(self.args, 'symlink destination: ' + str(self.root / 'build'))

    def test_nested_import_rejected_without_writes(self):
        self.sources[3].write_text('//! import "hidden.j"\n')
        self.reject(self.args, 'nested imports are not supported; pass each source explicitly')

    def test_success_entry_roundtrip_and_input_preservation(self):
        harness = self.root / 'Harness.j'
        harness.write_text('function LabRun takes nothing returns nothing\nendfunction\n')
        before = self.snapshot()
        code, out, err = self.invoke(self.args + ['--harness', str(harness), '--entry', 'LabRun'])
        self.assertEqual((code, err), (0, ''))
        report = json.loads(out)
        run = self.root / 'build' / 'run-001'
        entry = (run / 'entry.j').read_text()
        ordered = [*self.sources[:4], harness, self.sources[4]]
        positions = [entry.index('Z:' + str(p).replace('/', '\\')) for p in ordered]
        self.assertEqual(positions, sorted(positions))
        self.assertEqual(entry.count('//! import'), 6)
        self.assertIn('call LabRun()', entry)
        self.assertNotIn('old demo script', entry)
        final = Path(report['output']).read_bytes()
        self.assertEqual(final[:512], self.base.read_bytes()[:512])
        managed = Archive(io.BytesIO(final[512:])).read_file('war3map.j')
        self.assertEqual(managed, b'compiled JASS')
        self.assertEqual(report['managed']['war3map.j'], hashlib.sha256(managed).hexdigest())
        for name, data in before.items():
            self.assertEqual((self.root / name).read_bytes(), data)
        self.assertFalse(report['editor_save_certified'])
        self.assertEqual(len(self.calls), 2)

    def test_build_without_harness_preserves_empty_bootstrap_contract(self):
        code, out, err = self.invoke(self.args)
        self.assertEqual((code, err), (0, ''))
        entry = (self.root / 'build/run-001/entry.j').read_text()
        self.assertIn('function RCStartHarness takes nothing returns nothing\nendfunction', entry)
        self.assertEqual(entry.count('//! import'), 5)
        self.assertEqual(json.loads(out)['inputs'][str(self.base)], hashlib.sha256(self.base.read_bytes()).hexdigest())

    def test_opaque_member_build_preservation(self):
        self.members['war3mapMap.blp'] = b'opaque-compression'
        self.base.write_bytes(archive_bytes(self.members))
        code, out, err = self.invoke(self.args)
        self.assertEqual((code, err), (0, ''))
        self.assertIn('war3mapMap.blp', json.loads(out)['opaque_members'])

    def test_failed_roundtrip_never_publishes_map(self):
        def corrupt(argv):
            result = self.runner(argv)
            if argv[1] == 'wc3ctl':
                Path(argv[8]).write_bytes(archive_bytes(dict(self.members, **{'war3map.j': b'bad'})))
            return result
        self.assertEqual(self.invoke(self.args, corrupt), (1, '', 'error: member roundtrip mismatch: war3map.j\n'))
        self.assertFalse((self.root / 'build/run-001/run-001.w3x').exists())
        self.assertEqual(self.base.read_bytes(), archive_bytes(self.members))

    def test_compiler_failure_records_exit_without_publication(self):
        code, out, err = self.invoke(self.args, lambda argv: {'returncode': 7, 'stdout': 'detail', 'stderr': 'cause'})
        self.assertEqual((code, out, err), (1, '', 'error: tool failed (7); see commands.json\n'))
        run = self.root / 'build/run-001'
        self.assertEqual(json.loads((run / 'commands.json').read_text())[0]['returncode'], 7)
        self.assertFalse((run / 'run-001.w3x').exists())

    def recovery_fixture(self):
        lines = [b'\n'] * 1820
        for start, end, name in [(1, 275, 'TimerUtils'), (276, 332, 'WorldBounds'),
                                 (333, 822, 'DummyRecycler'), (823, 1778, 'Missiles')]:
            lines[start - 1] = ('library ' + name + '\n').encode()
            lines[end - 2] = b'endlibrary\n'
        lines[1778] = b'scope RelativisticMissilesTest initializer Init\n'
        lines[-1] = b'endscope\n'
        global_source = b''.join(lines)
        wct = struct.pack('<I', 1) + b'credit\0' + struct.pack('<I', len(global_source) + 1) + global_source + b'\0' + struct.pack('<I', 0)
        funcs = ''.join('function ' + name + ' takes nothing returns nothing\nendfunction\n'
                        for name in ('InitCustomPlayerSlots', 'InitAllyPriorities', 'config'))
        self.members.update({'war3map.wct': wct, 'war3map.j': global_source + funcs.encode()})
        self.base.write_bytes(archive_bytes(self.members))
        return global_source, ['recover', '--map', str(self.base), '--project', str(self.root / 'project'),
                               '--expected-sha256', hashlib.sha256(self.base.read_bytes()).hexdigest()]

    def test_recovery_exact_sources_and_repeated_rejection(self):
        source, args = self.recovery_fixture()
        before = self.base.read_bytes()
        code, out, err = self.invoke(args)
        self.assertEqual((code, err), (0, ''))
        project = self.root / 'project'
        self.assertEqual((project / 'baseline/global.j').read_bytes(), source)
        core = b''.join(source.splitlines(keepends=True)[822:1778])
        self.assertEqual((project / 'baseline/Missiles.j').read_bytes(), core)
        self.assertEqual((project / 'src/Missiles.j').read_bytes(), core)
        self.assertEqual(self.base.read_bytes(), before)
        self.calls.clear()
        self.reject(args, 'destination already exists: ' + str(project / 'baseline/original.w3x'))

    def test_bootstrap_keeps_exact_config_and_excludes_original_demo(self):
        _, args = self.recovery_fixture()
        self.members['war3map.j'] += (b'function main takes nothing returns nothing\n'
                                    b'    call CreateAllUnits()\n    call InitCustomTriggers()\n'
                                    b'    call SetMapMusic( "Music", true, 0 )\nendfunction\n')
        self.base.write_bytes(archive_bytes(self.members))
        args[-1] = hashlib.sha256(self.base.read_bytes()).hexdigest()
        code, out, err = self.invoke(args)
        self.assertEqual((code, err), (0, ''))
        main = (self.root / 'project/src/MapMain.j').read_bytes()
        self.assertIn(b'function config takes nothing returns nothing\nendfunction\n', main)
        self.assertIn(b'call InitBlizzard()', main)
        self.assertIn(b'call SetMapMusic( "Music", true, 0 )', main)
        self.assertIn(b'Rect(-1024., -1024., 1024., 1024.)', main)
        self.assertNotIn(b'CreateAllUnits', main)
        self.assertNotIn(b'InitCustomTriggers', main)
        self.assertNotIn(b'scope RelativisticMissilesTest', main)

    def test_recovery_opaque_member_records_raw_evidence(self):
        _, args = self.recovery_fixture()
        self.members['war3mapMap.blp'] = b'opaque-compression'
        self.base.write_bytes(archive_bytes(self.members))
        args[-1] = hashlib.sha256(self.base.read_bytes()).hexdigest()
        code, out, err = self.invoke(args)
        self.assertEqual((code, err), (0, ''))
        opaque = json.loads(out)['opaque_members']['war3mapMap.blp']
        self.assertEqual(opaque['error'], 'Unsupported compression type.')
        self.assertEqual(opaque['raw_sha256'], hashlib.sha256(b'opaque-compression'.hex().encode()).hexdigest())

    def test_recovery_bad_hash_no_writes(self):
        _, args = self.recovery_fixture()
        args[-1] = '0' * 64
        self.reject(args, 'source map SHA-256 mismatch')

    def test_recovery_boundary_validation_no_writes(self):
        _, args = self.recovery_fixture()
        self.members['war3map.wct'] = self.members['war3map.wct'].replace(b'library Missiles', b'library Wrongxx')
        self.base.write_bytes(archive_bytes(self.members))
        args[-1] = hashlib.sha256(self.base.read_bytes()).hexdigest()
        self.reject(args, 'unexpected WCT library boundaries')


if __name__ == '__main__':
    unittest.main()
