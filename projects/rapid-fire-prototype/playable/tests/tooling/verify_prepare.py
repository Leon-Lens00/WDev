"""Finite public CLI recipe/guard checks; no archive mutation, compiler or game."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / 'tools/prepare_objects.py'
BASE = ROOT / 'base/owned-original.w3x'
REPORT = ROOT / 'reports/packaging-preparation.json'


def main():
    records = []
    before = (BASE.read_bytes(), BASE.stat().st_mtime_ns)
    with TemporaryDirectory(prefix='verify-', dir=Path(__file__).parent) as temp:
        work = Path(temp)
        visible = json.loads((ROOT / 'base/objects-playable.json').read_text())
        hidden = json.loads((ROOT.parent / 'base/objects.json').read_text())
        timing = json.loads((ROOT.parent / 'base/objects-instant-controller-01.json').read_text())
        cases = [('visible', visible, None), ('hidden', hidden, None), ('timing', timing, None)]
        def row(**changes):
            return dict(visible[0], **changes)
        cases += [
            ('invalid-enum', [row(value=2)], 'unverified enum value'),
            ('invalid-kind', [row(kind='unit')], 'invalid owned object kind or id'),
            ('duplicate', [visible[0], visible[0]], 'duplicate recipe field'),
            ('unknown-field', [row(field='zzzz')], 'unknown or disallowed field'),
            ('invalid-level', [row(level=0)], 'invalid metadata level'),
            ('invalid-flag-type', [row(value=True)], 'value type does not match metadata'),
            ('invalid-hotkey', [row(field='ahky', level=0, value='QQ')], 'hotkey must be one ASCII letter or digit'),
            ('invalid-button', [row(field='abpx', level=0, value=4)], 'value outside metadata bounds'),
            ('actor-timing', [row(kind='unit', id='o000', field='ucpt', level=0, value=0.0)], 'cast timing fields require controller o001'),
        ]
        for name, rows, error in cases:
            recipe = work / (name + '.json')
            recipe.write_text(json.dumps(rows))
            out, evidence = work / (name + '.w3x'), work / (name + '-evidence')
            argv = [sys.executable, '-B', str(HELPER), '--base', str(BASE), '--recipe', str(recipe), '--out', str(out), '--evidence', str(evidence)]
            if error is None:
                argv += ['--validate-only']
            result = subprocess.run(argv, capture_output=True, text=True, timeout=5)
            records.append(dict(name=name, argv=argv, exit=result.returncode, stdout=result.stdout, stderr=result.stderr))
            assert result.returncode == (0 if error is None else 1), records[-1]
            assert result.stdout == ('validated owned object recipe\n' if error is None else ''), records[-1]
            assert result.stderr == ('' if error is None else 'error: ' + error + '\n'), records[-1]
            assert not out.exists() and not evidence.exists(), name
            assert recipe.read_text() == json.dumps(rows), name
        # Freshness and symlink rejection exercise the public validation path too.
        for name in ('existing-out', 'existing-evidence', 'symlink-out'):
            recipe = ROOT / 'base/objects-playable.json'
            out, evidence = work / (name + '.w3x'), work / (name + '-evidence')
            if name == 'existing-out':
                out.write_bytes(b'preserve')
                error = 'destination already exists: ' + str(out)
            elif name == 'existing-evidence':
                evidence.mkdir()
                error = 'destination already exists: ' + str(evidence)
            else:
                # Link stays inside the owned test fixture. Guard must still reject it.
                out.symlink_to(recipe)
                error = 'symlink destination: ' + str(out)
            argv = [sys.executable, '-B', str(HELPER), '--base', str(BASE), '--recipe', str(recipe), '--out', str(out), '--evidence', str(evidence), '--validate-only']
            result = subprocess.run(argv, capture_output=True, text=True, timeout=5)
            records.append(dict(name=name, argv=argv, exit=result.returncode, stdout=result.stdout, stderr=result.stderr))
            assert (result.returncode, result.stdout, result.stderr) == (1, '', 'error: ' + error + '\n'), records[-1]
            if name == 'existing-out':
                assert out.read_bytes() == b'preserve' and not evidence.exists()
            elif name == 'existing-evidence':
                assert list(evidence.iterdir()) == [] and not out.exists()
            else:
                assert out.is_symlink() and not evidence.exists()
    assert (BASE.read_bytes(), BASE.stat().st_mtime_ns) == before
    report = json.loads(REPORT.read_text())
    for record in report['inputs']:
        src, dst = Path(record['source']), Path(record['copy'])
        assert hashlib.sha256(src.read_bytes()).hexdigest() == record['sha256']
        assert src.stat().st_mtime_ns == record['mtime_ns']
        if dst != HELPER.relative_to(Path.cwd()):
            assert hashlib.sha256(dst.read_bytes()).hexdigest() == record['sha256']
        record['original_bytes_and_mtime_preserved'] = True
        record['copy_sha256'] = hashlib.sha256(dst.read_bytes()).hexdigest()
    report.update(status='Scanned', helper_checks=records, binary_readback_pending=True,
                  limitations=['No map preparation, compiler, game, editor or multiplayer run in this unit.',
                               'Inherited Channel icon retained; no custom icon asset verified.',
                               'Validate-only verifies recipes/guards, not stored object bytes or in-game UI.'])
    REPORT.write_text(json.dumps(report, indent=2) + '\n')
    print('PASS: 15 public helper checks; original bytes/mtime preserved; no map outputs')
    return 0


if __name__ == '__main__':
    sys.exit(main())
