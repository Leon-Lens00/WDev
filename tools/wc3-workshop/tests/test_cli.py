"""Public CLI contracts; fixtures never touch workshop originals."""
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[3]
CLI = ROOT / 'tools/wc3-workshop/wc3.py'
KINDS = {'unit': 'w3u', 'item': 'w3t', 'ability': 'w3a',
         'destructable': 'w3b', 'doodad': 'w3d', 'buff': 'w3h', 'upgrade': 'w3q'}


def i(value):
    return struct.pack('<i', value)


def objects(kind, tag=3, value=b'Caf\xe9\0'):
    extra = i(2) + i(7) if kind in ('ability', 'doodad', 'upgrade') else b''
    return (i(2) + i(0) + i(1) + b'hfooH001' + i(1) + b'unam' + i(tag)
            + extra + value + b'H001')


class PublicCLI(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix='fixture-', dir=Path(__file__).parent)
        self.addCleanup(self.scratch.cleanup)
        self.base = Path(self.scratch.name)

    def put(self, name, data):
        path = self.base / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        return str(path.relative_to(ROOT))

    def run_cli(self, *args, ok=True):
        before = {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in self.base.rglob('*') if p.is_file() and not p.is_symlink()}
        result = subprocess.run([sys.executable, '-B', str(CLI), *args], cwd=ROOT,
                                capture_output=True, text=True, timeout=5)
        self.assertEqual(result.returncode, 0 if ok else 2, result.stderr + result.stdout)
        self.assertEqual(result.stderr, '')
        data = json.loads(result.stdout)
        self.assertEqual(set(data), {'schema_version', 'ok', 'action', 'target', 'evidence',
                                     'limitations', 'result', 'error'})
        self.assertEqual(data['schema_version'], 1)
        self.assertEqual(data['target'], 'Warcraft III Classic 1.27b')
        self.assertEqual(data['ok'], ok)
        self.assertEqual(data['action'], args[0])
        self.assertEqual(data['evidence'], 'Scanned' if ok else 'Rejected')
        self.assertTrue(data['limitations'])
        after = {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in self.base.rglob('*') if p.is_file() and not p.is_symlink()}
        self.assertEqual(before, after)
        if ok:
            self.assertIsNone(data['error'])
        else:
            self.assertEqual(data['result'], None)
        return data

    def reject(self, code, *args):
        self.assertEqual(self.run_cli(*args, ok=False)['error']['code'], code)

    def test_doctor_named_artifacts_and_project_config(self):
        artifact = self.put('common.j', b'native Test takes nothing returns nothing\n')
        config = self.put('profile.json', json.dumps({'artifacts': {'common': artifact}}).encode())
        result = self.run_cli('doctor', '--config', config)['result']
        self.assertFalse(result['compatibility_verified'])
        self.assertFalse(result['execution_verified'])
        self.assertEqual(result['artifacts'][0]['sha256'], hashlib.sha256(
            (ROOT / artifact).read_bytes()).hexdigest())
        self.assertTrue(result['authorized_locations'])
        self.assertEqual(self.run_cli('doctor')['result']['artifacts'], [])

    def test_doctor_rejects_explicit_empty_config(self):
        self.put('unchanged.j', b'// Rejected requests must not modify inputs.\n')
        data = self.run_cli('doctor', '--config', '', ok=False)
        self.assertEqual(data['error'], {
            'code': 'path', 'message': 'Expected a nonempty project path.'})
        default = self.run_cli('doctor')['result']
        self.assertEqual(default['artifacts'], [])
        self.assertFalse(default['compatibility_verified'])
        self.assertFalse(default['execution_verified'])

    def test_doctor_rejects_external_and_unknown_config(self):
        for value in ({'artifacts': {'common': '/etc/passwd'}}, {'roots': ['/etc']},
                      {'artifacts': {'passwords': 'anything'}}):
            path = self.put('bad.json', json.dumps(value).encode())
            self.reject('config', 'doctor', '--config', path)
        path = self.put('bad.json', b'{broken')
        self.reject('config', 'doctor', '--config', path)

    def test_sources_masking_navigation_and_encoding(self):
        path = self.put('source.j', b'// function Fake\n/* library Wrong */\n'
                        b'library Demo requires optional Base, Other\n'
                        b'function Real takes nothing returns nothing\n'
                        b'call BJDebugMsg("function Hidden // BlzFake")\n'
                        b'call BlzReal()\nset x = \'hfoo\'\n'
                        b'//! import "other.j"\n// Caf\xe9\n')
        result = self.run_cli('sources', path)['result']['files'][0]
        self.assertEqual(result['encoding'], 'cp1252')
        self.assertEqual(result['declarations'], [
            {'kind': 'library', 'name': 'Demo', 'line': 3},
            {'kind': 'function', 'name': 'Real', 'line': 4}])
        self.assertEqual(result['dependencies'], [{'library': 'Demo', 'names': ['optional Base', 'Other'], 'line': 3}])
        self.assertEqual(result['imports'], [{'path': 'other.j', 'line': 8}])
        self.assertEqual(result['rawcodes'], [{'text': 'hfoo', 'hex': '68666f6f', 'line': 7}])
        self.assertEqual(result['modern_api_mentions'], [{'name': 'BlzReal', 'line': 6}])
        self.assertEqual(len(self.run_cli('sources', str(self.base.relative_to(ROOT)))['result']['files']), 1)

    def test_sources_malformed_and_limits(self):
        for text in (b'/* unterminated', b'call f("oops)', b"set x = 'abc"):
            self.reject('source', 'sources', self.put('broken.j', text))
        self.reject('limit', 'sources', self.put('large.j', b' ' * (1024 * 1024 + 1)))
        self.reject('source', 'sources', self.put('wrong.txt', b'hello'))
        self.reject('source', 'sources', self.put('newline.j', b'call f("a\\\nb")'))
        for number in range(65):
            self.put('many/file%d.j' % number, b'// empty\n')
        self.reject('limit', 'sources', str((self.base / 'many').relative_to(ROOT)))

    def test_all_seven_object_kinds_and_stored_tags(self):
        for kind, suffix in KINDS.items():
            with self.subTest(kind=kind):
                path = self.put('war3map.' + suffix, objects(kind))
                result = self.run_cli('objects', kind, path)['result']
                self.assertEqual(result['version'], 2)
                self.assertEqual(result['kind'], kind)
                self.assertEqual(result['original'], [])
                obj = result['custom'][0]
                self.assertEqual(obj['old_id'], {'text': 'hfoo', 'hex': '68666f6f'})
                self.assertEqual(obj['new_id']['text'], 'H001')
                mod = obj['modifications'][0]
                self.assertEqual(mod['type_tag'], 3)
                self.assertEqual(mod['value'], 'Café')
                self.assertEqual(mod['encoding'], 'cp1252')
                self.assertEqual(mod['end_id']['text'], 'H001')
                self.assertEqual(mod['level'], 2 if kind in ('ability', 'doodad', 'upgrade') else None)
                self.assertEqual(mod['data'], 7 if kind in ('ability', 'doodad', 'upgrade') else None)
        for tag, value, expected in ((0, i(-7), -7), (1, struct.pack('<f', 1.5), 1.5),
                                     (2, struct.pack('<f', 0.25), 0.25)):
            path = self.put('numeric.w3u', objects('unit', tag, value))
            mod = self.run_cli('objects', 'unit', path)['result']['custom'][0]['modifications'][0]
            self.assertEqual((mod['type_tag'], mod['value']), (tag, expected))
        # Preserve both table roles, including a successful empty member.
        data = objects('unit')
        path = self.put('original.w3u', i(2) + data[8:] + i(0))
        result = self.run_cli('objects', 'unit', path)['result']
        self.assertEqual(len(result['original']), 1)
        self.assertEqual(result['custom'], [])
        path = self.put('empty.w3u', i(2) + i(0) + i(0))
        result = self.run_cli('objects', 'unit', path)['result']
        self.assertEqual((result['original'], result['custom']), ([], []))

    def test_objects_reject_bad_structure(self):
        cases = [('version', i(3)), ('binary', objects('unit')[:-1]),
                 ('binary', objects('unit') + b'x'), ('binary', objects('unit', 9)),
                 ('binary', i(2) + i(-1)), ('limit', i(2) + i(1001)),
                 ('binary', objects('unit', 1, struct.pack('<f', float('nan')))),
                 ('binary', objects('unit')[:-4] + b'xxxx'),
                 ('binary', objects('unit', 3, b'x' * 4097 + b'\0'))]
        for code, data in cases:
            self.reject(code, 'objects', 'unit', self.put('bad.w3u', data))

    def test_imports_preserve_spelling_and_find_unsafe_paths(self):
        path = self.put('war3map.imp', i(1) + i(3) + b'\x0dTextures\\Caf\xe9.blp\0'
                        + b'\x05..\\outside.blp\0' + b'\x0dC:\\secret\0')
        result = self.run_cli('imports', path)['result']
        self.assertFalse(result['assets_checked'])
        self.assertEqual(result['entries'], [
            {'flag': 13, 'path': 'Textures\\Café.blp', 'encoding': 'cp1252', 'unsafe_path': False},
            {'flag': 5, 'path': '..\\outside.blp', 'encoding': 'utf-8', 'unsafe_path': True},
            {'flag': 13, 'path': 'C:\\secret', 'encoding': 'utf-8', 'unsafe_path': True}])

    def test_imports_reject_bad_structure(self):
        for code, data in [('version', i(2)), ('binary', i(1) + i(1) + b'\x0dabc'),
                           ('binary', i(1) + i(0) + b'x'), ('binary', i(1) + i(-1)),
                           ('binary', i(1) + i(1) + b'\xffx\0')]:
            self.reject(code, 'imports', self.put('bad.imp', data))

    def test_paths_and_directory_symlinks(self):
        self.reject('path', 'sources', '../outside.j')
        self.reject('path', 'sources', '/etc/passwd')
        link = self.base / 'escape.j'
        link.symlink_to('/etc/passwd')
        self.reject('path', 'sources', str(link.relative_to(ROOT)))
        self.reject('path', 'imports', str(link.relative_to(ROOT)))
        self.reject('path', 'objects', 'unit', str(link.relative_to(ROOT)))
        self.reject('path', 'doctor', '--config', str(link.relative_to(ROOT)))
        self.reject('path', 'sources', str(self.base.relative_to(ROOT)))
        link.unlink()
        (self.base / 'cycle').symlink_to(self.base, target_is_directory=True)
        self.reject('path', 'sources', str(self.base.relative_to(ROOT)))

    def test_argument_errors_and_help(self):
        self.reject('arguments', 'objects', 'unknown', 'file')
        self.reject('arguments', 'sources')
        self.reject('arguments', 'doctor', '--unexpected')
        for action in ('doctor', 'sources', 'objects', 'imports'):
            result = subprocess.run([sys.executable, '-B', str(CLI), action, '--help'],
                                    capture_output=True, text=True, timeout=5)
            self.assertEqual(result.returncode, 0)
            self.assertEqual(result.stderr, '')
            self.assertIn(action, result.stdout)


if __name__ == '__main__':
    unittest.main()
