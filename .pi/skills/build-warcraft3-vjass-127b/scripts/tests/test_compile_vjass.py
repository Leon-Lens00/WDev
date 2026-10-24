import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).parents[1] / 'compile_vjass.py'


class CompileTests(unittest.TestCase):
    def test_staged_compile_preserves_destination_on_failure(self):
        sys.path.insert(0, str(SCRIPT.parent))
        try:
            spec = importlib.util.spec_from_file_location('compile_vjass', SCRIPT)
            compiler = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(compiler)
        finally:
            sys.path.pop(0)
        for failure in ('compiler', 'validator', None):
            with self.subTest(failure=failure), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                command = [str(SCRIPT)]
                for name in ('jasshelper', 'pjass', 'common', 'blizzard', 'input'):
                    path = root / name
                    path.write_bytes(b'// fixture')
                    command += ['--' + name, str(path)]
                output, log = root / 'output.j', root / 'log.json'
                output.write_bytes(b'previous')
                command += ['--output', str(output), '--log', str(log)]

                def runner(args, cwd):
                    stage = 'compiler' if '--scriptonly' in args else 'validator'
                    if stage == 'compiler' and failure != stage:
                        Path(args[-1]).write_bytes(b'compiled')
                    return subprocess.CompletedProcess(args, int(stage == failure), '', '')

                from io import StringIO
                with patch.object(sys, 'argv', command), patch.object(compiler, 'run', side_effect=runner), patch('sys.stdout', new_callable=StringIO) as stdout, patch('sys.stderr', new_callable=StringIO) as stderr:
                    code = compiler.main()
                self.assertEqual(code, 1 if failure else 0)
                self.assertEqual(stdout.getvalue(), '')
                self.assertEqual(stderr.getvalue(), 'JassHelper did not produce the requested output.\n' if failure == 'compiler' else '')
                self.assertEqual(output.read_bytes(), b'previous' if failure else b'compiled')
                self.assertEqual(json.loads(log.read_text())['validated'], failure is None)
                self.assertFalse(list(root.glob('.vjass-*')))

    def test_dry_run_and_collision_safety(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            names = ('jasshelper', 'pjass', 'common', 'blizzard', 'input')
            paths = {name: root / name for name in names}
            for path in paths.values():
                path.write_bytes(b'// fixture\n')
            dependency = root / 'external.j'
            dependency.write_bytes(b'// dependency\n')
            paths['input'].write_text('//! import "external.j"\n', encoding='utf-8')
            command = [sys.executable, '-B', str(SCRIPT)]
            for name, path in paths.items():
                command += ['--' + name, str(path)]
            output = root / 'new' / 'compiled.j'
            before = {p: p.read_bytes() for p in (*paths.values(), dependency)}
            result = subprocess.run(command + ['--output', str(output), '--dry-run', '--debug', '--no-optimize'], capture_output=True, text=True)
            self.assertEqual((result.returncode, result.stderr), (0, ''))
            plan = json.loads(result.stdout)
            self.assertIn('--debug', plan['jasshelper_command'])
            self.assertIn('--nooptimize', plan['jasshelper_command'])
            self.assertFalse(output.parent.exists())
            for protected in (*paths.values(), dependency):
                for option in ('--output', '--log'):
                    with self.subTest(protected=protected.name, option=option):
                        args = ['--output', str(output), '--dry-run']
                        if option == '--output':
                            args[1] = str(protected)
                        else:
                            args += ['--log', str(protected)]
                        result = subprocess.run(command + args, capture_output=True, text=True)
                        self.assertEqual(result.returncode, 2, (result.stdout, result.stderr))
                        self.assertEqual(result.stdout, '')
                        self.assertIn('must not overwrite', result.stderr)
                        self.assertEqual(before, {p: p.read_bytes() for p in before})
            for kind in ('hardlink', 'symlink'):
                alias = root / kind
                if kind == 'hardlink':
                    os.link(dependency, alias)
                else:
                    alias.symlink_to(dependency)
                result = subprocess.run(command + ['--output', str(alias), '--dry-run'], capture_output=True, text=True)
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertEqual(dependency.read_bytes(), before[dependency])
            result = subprocess.run(command + ['--output', str(output), '--log', str(output), '--dry-run'], capture_output=True, text=True)
            self.assertEqual(result.returncode, 2, result.stderr)
            self.assertEqual(result.stdout, '')
            self.assertFalse(output.parent.exists())


if __name__ == '__main__':
    unittest.main()
