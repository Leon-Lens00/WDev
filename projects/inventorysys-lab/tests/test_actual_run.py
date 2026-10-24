"""S1/S2/S3: real retained run, not synthetic game evidence."""
import hashlib
import importlib.util
from pathlib import Path
import unittest

from mpyq import MPQArchive

ROOT = Path(__file__).resolve().parents[1]
RUN_ID = 'inv-baseline-20261019-02'


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class ActualRun(unittest.TestCase):
    def test_actual_source_archive_and_failed_evidence(self):
        build = load('actual_build', ROOT / 'tools/build.py')
        reader = load('actual_reader', ROOT / 'tools/read_logs.py')
        run = ROOT / 'reports/runs' / RUN_ID
        base = (ROOT / 'baseline/original.w3x').read_bytes()
        final = (run / f'{RUN_ID}.w3x').read_bytes()
        self.assertEqual(hashlib.sha256(base).hexdigest(), 'a1b657231bed875ad480a64a9fb428c4548a84249aa89db0545abace39579ada')
        self.assertEqual(hashlib.sha256(final).hexdigest(), '574c634cfa95a075643ec40ea80056c4b6143b1ced23598c4f09d5a405448853')
        prefix, members, _ = build.read_map(base, MPQArchive)
        newprefix, changed, _ = build.read_map(final, MPQArchive)
        self.assertEqual(prefix, newprefix)
        assembled = (run / 'assembled.j').read_bytes()
        self.assertEqual(changed, dict(members, **{'war3map.j': assembled}))
        g = (ROOT / 'src/globals.j').read_bytes()
        f = (ROOT / 'src/functions.j').read_bytes()
        self.assertEqual(assembled, build.assemble(members['war3map.j'], g, f, 'IL_Start', RUN_ID))
        for inserted in (g, f):
            assembled = assembled.replace(inserted.replace(b'@RUN_ID@', RUN_ID.encode('ascii')), b'', 1)
        self.assertEqual(assembled.replace(b'    call IL_Start()\r\n', b'', 1), members['war3map.j'])
        archive = build.verify_archive_preservation(base, final, MPQArchive)
        self.assertEqual(archive['preserved_identities'], 52)
        self.assertEqual([x['name'] for x in archive['housekeeping_changes']], ['(attributes)', '(listfile)'])
        data = (run / f'IL141-{RUN_ID}.pld').read_bytes()
        self.assertEqual(reader.parse(data, RUN_ID), dict(cases=14, fail=2, inconclusive=True, obs=6, **{'pass': 16}, run_id=RUN_ID, skip=4))
        for bad, run_id in ((data, 'other'), (data[:-1], RUN_ID), (data.replace(b'cases=14 pass=16', b'cases=14 pass=17'), RUN_ID)):
            with self.assertRaises(ValueError):
                reader.parse(bad, run_id)

    def test_close_docs_do_not_describe_completed_run_as_pending(self):
        self.assertNotIn('T3 compilation/packaging/gameplay remains pending', (ROOT / 'README.md').read_text())
        self.assertNotIn('Status: Scanned, not compiled or played', (ROOT / 'docs/evaluation.md').read_text())
