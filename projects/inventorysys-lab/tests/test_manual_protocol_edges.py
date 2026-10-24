"""Independent S2/S3 protocol checkpoint-boundary regressions; synthetic, not gameplay."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

READER = Path(__file__).resolve().parents[1] / 'tools/read_manual_logs.py'

class ProtocolEdges(unittest.TestCase):
    def test_checkpoint_boundary_and_rejected_continuations(self):
        with tempfile.TemporaryDirectory(dir=os.environ.get('TMPDIR') or '/tmp/wdev-inventorysys-lab') as root:
            root = Path(root)
            def row(seq, event, data):
                return ('IL141M|edge-build|edge-session|%d|%d|250|recorder|%s|%s\n'
                        % ((seq-1)//128, seq, event, data)).encode()
            first = root / 'IL141M-edge-build--edge-session--0.pld'
            first.write_bytes(row(1, 'BEGIN', 'schema=1') + b''.join(
                row(n, 'MARK', 'manual') for n in range(2,129)))
            # Other-session data is unrelated, even if it is not parseable.
            (root / 'IL141M-edge-build--other--0.pld').write_bytes(b'not evidence')
            report = root / 'report.json'
            def invoke(expected, status=None):
                before = {p: hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in root.iterdir() if p.is_file()}
                command = [sys.executable, '-B', str(READER), str(root),
                           '--run-id', 'edge-build', '--session', 'edge-session',
                           '--not-before', '0', '--report', str(report)]
                result = subprocess.run(command, capture_output=True, timeout=20)
                self.assertEqual(result.returncode, expected)
                self.assertEqual(result.stderr, b'error: invalid manual evidence\n' if expected==2 else b'')
                for path, digest in before.items():
                    self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), digest)
                if expected==2:
                    self.assertEqual(result.stdout, b'')
                else:
                    data = json.loads(result.stdout)
                    self.assertEqual(data['status'], status)
                    self.assertFalse(data['semantic_certification'])
                    self.assertFalse(data['runtime_writing_verified'])
                    self.assertEqual(report.read_bytes(), result.stdout)
                    self.assertEqual(result.stdout, (json.dumps(data, indent=2, ensure_ascii=True)+'\n').encode())
                return result
            invoke(1, 'partial')  # sealed checkpoint alone cannot imply coverage
            report.unlink()  # isolated fixture only
            last = root / 'IL141M-edge-build--edge-session--1.pld'
            terminal = row(129, 'TERMINAL', 'reason=USER_STOP rows=129 dropped=0')
            last.write_bytes(terminal)
            invoke(0, 'observation_complete')
            # Existing output remains exclusive even for otherwise valid data.
            invoke(2)
            report.unlink()
            for bad in (terminal[:-1], terminal.replace(b'edge-build',b'wrong-build'),
                        terminal.replace(b'|129|',b'|130|')):
                last.write_bytes(bad)
                invoke(2)
                self.assertFalse(report.exists())
            last.write_bytes(terminal)
            first.rename(root / 'saved-first')
            invoke(2)
            self.assertFalse(report.exists())
