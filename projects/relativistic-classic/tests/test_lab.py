"""Public CLI tests only; game behavior is tested by the vJASS lab, not Python."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

CLI = Path(__file__).resolve().parents[1] / 'tools/read_logs.py'


class Logs(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.log = self.root / 'current.txt'
        self.report = self.root / 'report.json'

    def payload(self, status='PASS', complete=True, run='fresh-001'):
        records = [f'RM28|{run}|BEGIN|all', f'RM28|{run}|CASE|L01',
                   f'RM28|{run}|CHECK|L01|{status}|once|expected=1 actual=1']
        if complete:
            records.append(f'RM28|{run}|COMPLETE|1|1|{int(status == "FAIL")}|{int(status == "SKIP")}')
        return ('function PreloadFiles takes nothing returns nothing\n' + ''.join(
            'call Preload( "' + r + '" )\n' for r in records) + 'endfunction\n').encode()

    def invoke(self, data=None, *extra):
        if data is not None:
            self.log.write_bytes(data)
        before = self.log.read_bytes()
        result = subprocess.run([sys.executable, '-B', str(CLI), str(self.log),
                                 '--run-id', 'fresh-001', *extra], capture_output=True)
        self.assertEqual(self.log.read_bytes(), before)
        return result

    def expected(self, data, status='PASS'):
        return {'run_id': 'fresh-001', 'group': 'all', 'cases': 1, 'checks': 1,
                'failures': int(status == 'FAIL'), 'skips': int(status == 'SKIP'),
                'observations': int(status == 'OBS'), 'complete': True,
                'status': 'failed' if status == 'FAIL' else ('inconclusive' if status == 'SKIP' else 'passed'),
                'source_sha256': hashlib.sha256(data).hexdigest(),
                'records': [{'case': 'L01', 'status': status, 'name': 'once',
                             'detail': 'expected=1 actual=1'}]}

    def assert_rejected(self, data, message, *extra):
        sentinel = b'keep report bytes\x00'
        self.report.write_bytes(sentinel)
        p = self.invoke(data, *extra)
        invalid_id = extra[extra.index('--run-id') + 1] if '--run-id' in extra else 'fresh-001'
        expected = (json.dumps({'status': 'invalid', 'error': message, 'run_id': invalid_id}, sort_keys=True) + '\n').encode()
        self.assertEqual((p.returncode, p.stdout, p.stderr), (2, expected, ('error: ' + message + '\n').encode()))
        self.assertEqual(self.report.read_bytes(), sentinel)

    def test_normal_pass_and_exclusive_report(self):
        data = self.payload()
        p = self.invoke(data, '--report', str(self.report))
        expected = (json.dumps(self.expected(data), sort_keys=True) + '\n').encode()
        self.assertEqual((p.returncode, p.stdout, p.stderr), (0, expected, b''))
        self.assertEqual(self.report.read_bytes(), expected)

    def test_fail_is_nonzero_with_machine_evidence(self):
        data = self.payload('FAIL')
        p = self.invoke(data)
        self.assertEqual((p.returncode, p.stdout, p.stderr),
                         (1, (json.dumps(self.expected(data, 'FAIL'), sort_keys=True) + '\n').encode(), b''))

    def test_skip_is_not_pass(self):
        data = self.payload('SKIP')
        p = self.invoke(data)
        self.assertEqual((p.returncode, p.stdout, p.stderr),
                         (0, (json.dumps(self.expected(data, 'SKIP'), sort_keys=True) + '\n').encode(), b''))

    def test_observation_is_not_assertion(self):
        data = self.payload('OBS')
        p = self.invoke(data)
        self.assertEqual((p.returncode, p.stdout, p.stderr),
                         (0, (json.dumps(self.expected(data, 'OBS'), sort_keys=True) + '\n').encode(), b''))

    def test_mismatch(self):
        self.assert_rejected(self.payload(run='old'), 'run-id mismatch')

    def test_incomplete(self):
        self.assert_rejected(self.payload(complete=False), 'missing COMPLETE')

    def test_missing_begin(self):
        self.assert_rejected(self.payload().replace(b'RM28|fresh-001|BEGIN|all', b'ignored'), 'expected BEGIN first')

    def test_stale(self):
        self.assert_rejected(self.payload(), 'stale input', '--not-before', '9999999999')

    def test_invalid_run_id(self):
        self.assert_rejected(self.payload(), 'invalid run-id', '--run-id', '../bad')

    def test_counters_rejected(self):
        self.assert_rejected(self.payload().replace(b'COMPLETE|1|1|0|0', b'COMPLETE|1|9|0|0'), 'COMPLETE counters mismatch')

    def test_duplicate_complete(self):
        data = self.payload()
        self.assert_rejected(data + b'RM28|fresh-001|COMPLETE|1|1|0|0\n', 'records after COMPLETE')

    def test_bad_status(self):
        self.assert_rejected(self.payload('MAYBE'), 'invalid CHECK')

    def test_report_never_overwritten(self):
        self.assert_rejected(self.payload(), 'report destination exists', '--report', str(self.report))

    def test_unbegun_case(self):
        self.assert_rejected(self.payload().replace(b'CHECK|L01|', b'CHECK|L02|'), 'invalid CHECK')

    def test_duplicate_case(self):
        self.assert_rejected(self.payload().replace(b'|COMPLETE|1|1|0|0', b'|CASE|L01'), 'invalid CASE')

    def test_nonfinite_freshness(self):
        self.assert_rejected(self.payload(), 'invalid not-before', '--not-before', 'nan')

    def test_freshness_equal_boundary_and_metadata(self):
        data = self.payload()
        self.log.write_bytes(data)
        mtime = self.log.stat().st_mtime
        expected = self.expected(data)
        expected['freshness'] = {'mtime': mtime, 'not_before': mtime}
        p = self.invoke(None, '--not-before', str(mtime))
        self.assertEqual((p.returncode, p.stdout, p.stderr),
                         (0, (json.dumps(expected, sort_keys=True) + '\n').encode(), b''))

    def test_symlink_report_parent_is_rejected(self):
        (self.root / 'alias').symlink_to(self.root, target_is_directory=True)
        self.assert_rejected(self.payload(), 'symlink report parent', '--report', str(self.root / 'alias/new.json'))
        self.assertFalse((self.root / 'new.json').exists())


class CatalogStructure(unittest.TestCase):
    def test_documented_case_ids_match_runner_and_danger_is_last(self):
        # Metadata check ONLY, never evidence of game behavior or bug reproduction.
        root = Path(__file__).resolve().parents[1]
        runner = (root / 'src/lab/Runner.j').read_text()
        docs = (root / 'docs/scenarios.md').read_text()
        count = int(re.search(r'constant integer CASE_COUNT = (\d+)', runner)[1])
        body = runner.split('private function CaseID ', 1)[1].split('endfunction', 1)[0]
        branches = re.findall(r'(?:if|elseif) n (<=|==) (\d+) then\s+return "([A-Z0-9]+)"( \+ I2S\(n\))?', body)
        self.assertTrue(branches)
        default = re.search(r'endif\s+return "([A-Z0-9]+)"', body)[1]
        actual = []
        for n in range(1, count + 1):
            for op, boundary, prefix, suffix in branches:
                matches = n <= int(boundary) if op == '<=' else n == int(boundary)
                if matches:
                    actual.append(prefix + (str(n) if suffix else ''))
                    break
            else:
                actual.append(default)
        documented = re.findall(r'^\| ([LCEMP]\d+) \|', docs, re.M)
        self.assertEqual(documented, actual)
        self.assertEqual(len(set(actual)), count)
        self.assertEqual(actual[-1], 'L99')
        self.assertIn('|COMPLETE|' + str(count) + '|', docs)


if __name__ == '__main__':
    unittest.main()
