"""Reader public file/CLI contract; no game evidence is synthesized as real output."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def evidence(status='PASS'):
    rows = [('BEGIN', '-', 'schema=1'), ('CASE', '01-ready', 'before'),
            ('CHECK', '01-ready', 'before=probe'), (status, '01-ready', 'probe'),
            ('RESULT', '01-ready', 'pass=%d fail=%d obs=%d skip=%d' %
             tuple(int(status == s) for s in ('PASS', 'FAIL', 'OBS', 'SKIP'))),
            ('COMPLETE', '-', 'cases=1 pass=%d fail=%d obs=%d skip=%d' %
             tuple(int(status == s) for s in ('PASS', 'FAIL', 'OBS', 'SKIP')))]
    return ''.join('IL141|run-1|%d|%s|%s|%s\n' % (i, *r) for i, r in enumerate(rows, 1))


class ReaderTests(unittest.TestCase):
    def setUp(self):
        root = Path(os.environ.get('TMPDIR') or '/tmp/wdev-inventorysys-lab')
        root.mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix='reader-', dir=root)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.log = self.root / 'log.pld'
        self.log.write_text(evidence())
        os.utime(self.log, (2000, 2000))
        self.report = self.root / 'report.json'

    def invoke(self, extra=(), source=None):
        spec = importlib.util.spec_from_file_location('inventory_logs', ROOT / 'tools/read_logs.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        out, err = io.StringIO(), io.StringIO()
        before = self.log.read_bytes()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = module.main([str(source or self.log), '--run-id', 'run-1', '--not-before', '1000', *extra])
        self.assertEqual(self.log.read_bytes(), before)
        return code, out.getvalue(), err.getvalue()

    def expected(self, status):
        return {'cases': 1, 'fail': int(status == 'FAIL'),
                'inconclusive': status in ('OBS', 'SKIP'), 'obs': int(status == 'OBS'),
                'pass': int(status == 'PASS'), 'run_id': 'run-1', 'skip': int(status == 'SKIP')}

    def test_clean_fail_skip_and_observation(self):
        for status in ('PASS', 'FAIL', 'SKIP', 'OBS'):
            with self.subTest(status=status):
                self.log.write_text(evidence(status))
                os.utime(self.log, (2000, 2000))
                self.assertEqual(self.invoke(), (int(status == 'FAIL'),
                    json.dumps(self.expected(status), indent=2, sort_keys=True) + '\n', ''))

    def test_exclusive_report_matches_stdout_and_never_overwrites(self):
        code, out, err = self.invoke(['--report', str(self.report)])
        self.assertEqual((code, err), (0, ''))
        self.assertEqual(self.report.read_text(), out)
        self.assertEqual(self.invoke(['--report', str(self.report)]),
                         (2, '', 'error: invalid evidence\n'))
        self.assertEqual(self.report.read_text(), out)

    def test_reject_wrong_id_stale_and_invalid_threshold(self):
        for extra in (['--run-id', 'other'], ['--not-before', '3000'],
                      ['--not-before', 'nan'], ['--not-before', 'inf'], ['--run-id', '../bad']):
            with self.subTest(extra=extra):
                self.assertEqual(self.invoke(extra), (2, '', 'error: invalid evidence\n'))

    def test_bad_rows_counts_order_and_malicious_payloads(self):
        good = evidence()
        bad = [good.rsplit('IL141', 1)[0], good[:-1], good + good,
               good.replace('schema=1', 'schema=2'), good.replace('cases=1', 'cases=2'),
               good.replace('pass=1', 'pass=9', 1), good.replace('|4|PASS', '|3|PASS'),
               good.replace('|PASS|', '|BOGUS|'), good.replace('|01-ready|probe', '|other|probe'),
               good.replace('before=probe', 'x|injected'), good.replace('before=probe', '\\"evil'),
               good.replace('before=probe', 'x' * 161), good.replace('before=probe', 'bad\x00'),
               good.replace('|RESULT|', '|CASE|'), good.replace('|CHECK|', '|COMPLETE|'),
               good + 'IL141|run-1|7|OBS|-|late\n', good.replace('probe\n', 'probe\rjunk\n', 1)]
        for text in bad:
            with self.subTest(text=text):
                self.log.write_bytes(text.encode())
                os.utime(self.log, (2000, 2000))
                self.assertEqual(self.invoke(['--report', str(self.report)]),
                                 (2, '', 'error: invalid evidence\n'))
                self.assertFalse(self.report.exists())

    def test_preload_envelope_and_failure_report(self):
        self.log.write_text('function PreloadFiles takes nothing returns nothing\n' + ''.join(
            '    call Preload( "' + row + '" )\n' for row in evidence('FAIL').splitlines()) +
            'endfunction\n')
        os.utime(self.log, (2000, 2000))
        code, out, err = self.invoke(['--report', str(self.report)])
        self.assertEqual((code, err), (1, ''))
        self.assertEqual(out, json.dumps(self.expected('FAIL'), indent=2, sort_keys=True) + '\n')
        self.assertEqual(self.report.read_text(), out)

    def test_missing_input_symlinks_and_report_alias_preserved(self):
        self.assertEqual(self.invoke(['--report', str(self.log)]),
                         (2, '', 'error: invalid evidence\n'))
        link = self.root / 'link'
        link.symlink_to(self.log)
        self.assertEqual(self.invoke(['--report', str(link)]),
                         (2, '', 'error: invalid evidence\n'))
        self.assertEqual(link.read_bytes(), self.log.read_bytes())
        self.assertEqual(self.invoke(['--report', str(self.root / 'absent/report')]),
                         (2, '', 'error: invalid evidence\n'))
        self.assertFalse((self.root / 'absent').exists())

    def test_missing_or_symlink_input_and_invalid_report_preserve_existing_file(self):
        self.assertEqual(self.invoke(source=self.root / 'missing'),
                         (2, '', 'error: invalid evidence\n'))
        link = self.root / 'input-link'
        link.symlink_to(self.log)
        self.assertEqual(self.invoke(source=link), (2, '', 'error: invalid evidence\n'))
        self.report.write_bytes(b'keep existing report')
        self.log.write_text(evidence().replace('cases=1', 'cases=9'))
        os.utime(self.log, (2000, 2000))
        self.assertEqual(self.invoke(['--report', str(self.report)]),
                         (2, '', 'error: invalid evidence\n'))
        self.assertEqual(self.report.read_bytes(), b'keep existing report')

    def test_duplicate_case_unknown_wrapper_and_record_limit(self):
        good = evidence()
        extra_case = ('IL141|run-1|6|CASE|01-ready|before\n'
                      'IL141|run-1|7|PASS|01-ready|again\n'
                      'IL141|run-1|8|RESULT|01-ready|pass=1 fail=0 obs=0 skip=0\n'
                      'IL141|run-1|9|COMPLETE|-|cases=2 pass=2 fail=0 obs=0 skip=0\n')
        many = good.split('IL141|run-1|3|')[0] + ''.join(
            'IL141|run-1|%d|CHECK|01-ready|bounded\n' % i for i in range(3, 514))
        for text in (good.rsplit('IL141', 1)[0] + extra_case,
                     'call ExecuteFunc("evil")\n' + good, many,
                     good.replace('probe', 'nonascii\u00e9')):
            self.log.write_text(text)
            os.utime(self.log, (2000, 2000))
            self.assertEqual(self.invoke(), (2, '', 'error: invalid evidence\n'))

    def test_empty_oversize_and_non_utf8(self):
        for content in (b'', b'x' * 262145, b'\xff'):
            self.log.write_bytes(content)
            os.utime(self.log, (2000, 2000))
            self.assertEqual(self.invoke(), (2, '', 'error: invalid evidence\n'))


if __name__ == '__main__':
    unittest.main()
