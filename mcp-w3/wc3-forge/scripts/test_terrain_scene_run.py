"""Exercise resume and stale manual-review rejection using real subprocesses."""
import hashlib
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest

RUNNER = pathlib.Path(__file__).with_name('terrain-scene-run.py')


class ResumeTests(unittest.TestCase):
    def test_review_is_bound_to_reviewed_bytes(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = pathlib.Path(tmp)
            artifact = base / 'map.txt'
            artifact.write_text('reviewed')
            review = base / 'review.json'
            record = {'accepted': True, 'reviewed_inputs': {
                str(artifact.resolve()): hashlib.sha256(artifact.read_bytes()).hexdigest()}}
            review.write_text(json.dumps(record))
            config = base / 'pipeline.json'
            config.write_text(json.dumps({'stages': [{
                'id': 'visual', 'inputs': ['map.txt', 'review.json'],
                'outputs': ['review.json'], 'review': 'review.json'}]}))
            def run():
                return subprocess.run([sys.executable, str(RUNNER), str(config)],
                                      capture_output=True, text=True)
            self.assertEqual(run().returncode, 0)
            resumed = run()
            self.assertEqual(resumed.returncode, 0)
            self.assertIn('resumed, hashes match', resumed.stdout)
            artifact.write_text('changed after approval')
            stale = run()
            self.assertNotEqual(stale.returncode, 0)
            self.assertIn('review does not cover current input', stale.stderr)
            record['accepted'] = False
            review.write_text(json.dumps(record))
            pending = run()
            self.assertNotEqual(pending.returncode, 0)
            self.assertIn('real review is still pending', pending.stderr)


if __name__ == '__main__':
    unittest.main()
