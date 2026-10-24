import collections
import hashlib
import json
import math
import os
from pathlib import Path
import subprocess
import sys

ORIGINAL = Path('/home/snz/Documentos/ChatGPT/WDev')
OWN = Path(sys.argv[1])
PREFIX = Path('projects/relativistic-classic')
ROOT = PREFIX
R = ROOT / 'reports'
NORMAL = 'fixed-20261019-03'
NEGATIVE = 'diag4-e29-timeout-20261019-01'
RUNS = ['fixed-20261019-02', NORMAL, 'diag2-m45-alone-20261019-01', NEGATIVE]

def sha(data):
    return hashlib.sha256(data).hexdigest()

def read_json(path):
    return json.loads(path.read_bytes())

def status():
    result = subprocess.run(['git', '--no-optional-locks', '-C', str(ORIGINAL),
                             'status', '--porcelain=v1', '--untracked-files=all'],
                            capture_output=True, timeout=3)
    assert result.returncode == 0, result.stderr
    return result.stdout

files = set()
for run in RUNS:
    files.add(R / f'RM28-{run}.txt')
    for suffix in ('.json', '.stdout.json', '.stderr.txt'):
        files.add(R / f'lab-{run}{suffix}')
for run, directory in ((NORMAL, 'cycle4'), (NEGATIVE, 'cycle4'), (RUNS[2], 'cycle2')):
    for suffix in ('-launch.json', '-reader-exit.json'):
        files.add(R / directory / (run + suffix))
for run in (NORMAL, NEGATIVE):
    manifest_path = ROOT / 'build' / ('inputs-' + run) / 'manifest.json'
    files.add(manifest_path)
    manifest = read_json(ORIGINAL / manifest_path)
    assert len(manifest['source_after_sha256']) == 13
    for name in manifest['source_after_sha256']:
        files.add(ROOT / 'src' / name)
        files.add(ROOT / 'build' / ('inputs-' + run) / name)
    for name in ('build.json', 'compiled.j', run + '.w3x', 'commands.json', 'entry.j'):
        files.add(ROOT / 'build' / run / name)
files.add(ROOT / 'baseline/original.w3x')
files.add(R / 'cycle4/timeout-injection.patch')
files.add(R / 'cycle4/fixed-20261019-03-build.stdout.json')
files.add(R / 'cycle4/diag4-e29-timeout-20261019-01-build.stdout.json')

before = {}
after = {}
git_before = status()
(OWN / 'git-status-before.txt').write_bytes(git_before)
try:
    for relative in sorted(files):
        original = ORIGINAL / relative
        assert original.is_file() and not original.is_symlink(), str(original)
        assert not any(p.is_symlink() for p in original.parents), str(original)
        data = original.read_bytes()
        before[str(relative)] = sha(data)
        destination = Path.cwd() / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        with destination.open('xb') as stream:
            stream.write(data)
        assert sha(destination.read_bytes()) == before[str(relative)]

    def load(run):
        raw = (R / f'RM28-{run}.txt').read_bytes()
        rows = []
        for number, line in enumerate(raw.decode('utf-8-sig').splitlines(), 1):
            if 'RM28|' in line:
                fields = line[line.index('RM28|'):].split('"', 1)[0].strip().split('|')
                assert fields[1] == run
                rows.append((number, fields[2:]))
        assert rows[0][1][0] == 'BEGIN'
        assert rows[-1][1][0] == 'COMPLETE'
        assert sum(f[0] == 'BEGIN' for _, f in rows) == 1
        assert sum(f[0] == 'COMPLETE' for _, f in rows) == 1
        cases = [f[1] for _, f in rows if f[0] == 'CASE']
        checks = [(n, *f[1:]) for n, f in rows if f[0] == 'CHECK']
        assert len(cases) == len(set(cases))
        counts = collections.Counter(x[2] for x in checks)
        assert list(map(int, rows[-1][1][1:])) == [
            len(cases), len(checks), counts['FAIL'], counts['SKIP']]
        report = read_json(R / f'lab-{run}.json')
        assert report['run_id'] == run and report['complete'] is True
        assert report['group'] == rows[0][1][1]
        assert report['source_sha256'] == sha(raw)
        assert report['records'] == [
            dict(zip(('case', 'status', 'name', 'detail'), x[1:])) for x in checks]
        for key, value in (('cases', len(cases)), ('checks', len(checks)),
                           ('failures', counts['FAIL']), ('skips', counts['SKIP']),
                           ('observations', counts['OBS'])):
            assert report[key] == value
        assert (R / f'lab-{run}.stdout.json').read_bytes() == (R / f'lab-{run}.json').read_bytes()
        assert (R / f'lab-{run}.stderr.txt').read_bytes() == b''
        if 'freshness' not in report:
            assert run == 'fixed-20261019-02', 'current report missing mandatory freshness'
            (OWN / 'legacy-freshness.json').write_text(json.dumps({
                'run_id': run, 'freshness': 'historicalfreshnessnotrecorded',
                'limitation': 'unavailable; not reconstructed or accepted as PASS'
            }, sort_keys=True) + '\n')
        else:
            fresh = report['freshness']
            assert math.isfinite(fresh['mtime']) and math.isfinite(fresh['not_before'])
            assert fresh['mtime'] >= fresh['not_before']
        return cases, checks, counts, report

    old, new, alone, negative = [load(run) for run in RUNS]
    assert old[0] == new[0] and len(new[0]) == 47 and new[0][-1] == 'L99'
    assert new[2] == {'PASS': 670, 'OBS': 137, 'SKIP': 1}
    assert new[3]['status'] == 'inconclusive'
    def multiplicity(result):
        return collections.Counter((case, status, name)
            for _, case, status, name, detail in result[1] if case != 'E29')
    expected = multiplicity(old)
    expected[('M45', 'FAIL', 'coordinate-fixture-live')] -= 1
    expected[('M45', 'PASS', 'coordinate-fixture-live')] += 1
    expected[('M45', 'PASS', 'launched-public-flags')] += 1
    assert +expected == multiplicity(new), 'unexpected non-E29 multiplicity change'
    m45 = lambda result: [x[1:] for x in result[1] if x[1] == 'M45']
    assert len(m45(new)) == 70 and m45(new) == m45(alone), 'M45 original checks changed'
    original = [(x[3], x[4]) for x in old[1] if x[1] == 'E29']
    current = collections.Counter((x[3], x[4]) for x in new[1] if x[1] == 'E29')
    assert not (collections.Counter(original) - current)
    assert all(x[2] == ('SKIP' if x[3] == 'multiplayer' else 'PASS')
               for x in new[1] if x[1] == 'E29' and x[3] in {n for n, d in original})
    assert [(x[1], x[3]) for x in new[1] if x[2] == 'SKIP'] == [('E29', 'multiplayer')]
    assert collections.Counter(x[2] for x in new[1] if x[1] == 'E29') == {
        'PASS': 34, 'OBS': 13, 'SKIP': 1}
    assert negative[2] == {'PASS': 28, 'OBS': 17, 'FAIL': 1, 'SKIP': 1}
    assert negative[3]['status'] == 'failed'
    assert [(x[3], x[4]) for x in negative[1] if x[2] == 'FAIL'] == [
        ('vision-reference-timeout', 'phase=8 wait=native-reference deadline=2.000 elapsed=2.000')]
    phases = [x[4] for x in negative[1] if x[3] == 'vision-reference-state' and x[4].startswith('phase=8 ')]
    assert len(phases) == 8
    for i, detail in enumerate(phases, 1):
        assert f'elapsed={i*.25:.3f} deadline=2.000' in detail
    assert any('phase=13 wait=abort-cleanup-reference clock=4.000 elapsed=0.250' in x[4]
               for x in negative[1])

    identities = {}
    for run, result, directory in ((NORMAL, new, 'cycle4'), (NEGATIVE, negative, 'cycle4'),
                                    (RUNS[2], alone, 'cycle2')):
        launch = read_json(R / directory / (run + '-launch.json'))
        reader = read_json(R / directory / (run + '-reader-exit.json'))
        assert launch['run_id'] == run
        assert reader['exit_code'] == int(result[2]['FAIL'] > 0)
        assert reader['source_mtime'] == result[3]['freshness']['mtime']
        assert reader['launch_requested_unix'] == launch['launch_requested_unix'] == result[3]['freshness']['not_before']
        assert reader['source_mtime'] >= launch['launch_requested_unix']

    for run in (NORMAL, NEGATIVE):
        frozen = ROOT / 'build' / ('inputs-' + run)
        manifest = read_json(frozen / 'manifest.json')
        assert manifest['run_id'] == run
        assert manifest['selection'] == ('all' if run == NORMAL else 'E29')
        assert sha((frozen / 'manifest.json').read_bytes()) == {
            NORMAL: 'fbb0b46237d2f72c8a7427be5412f05d3328f3b9036423128640db27371bb3fb',
            NEGATIVE: 'fc8793e0c188295d3ea291dbcc8405f2784924d8a2cd2d96d53ce4cf7b1682ef'}[run]
        for name, expected_hash in manifest['source_after_sha256'].items():
            assert sha((ROOT / 'src' / name).read_bytes()) == expected_hash
        for name, expected_hash in manifest['input_sha256'].items():
            data = (frozen / name).read_bytes()
            assert sha(data) == expected_hash
            maintained = (ROOT / 'src' / name).read_bytes()
            if name == 'lab/Config.j':
                assert maintained.count(b'RM_RUN_ID = "UNCONFIGURED"') == 1
                wanted = maintained.replace(b'RM_RUN_ID = "UNCONFIGURED"',
                                           ('RM_RUN_ID = "' + run + '"').encode())
                if run == NEGATIVE:
                    assert wanted.count(b'RM_SELECT = "all"') == 1
                    wanted = wanted.replace(b'RM_SELECT = "all"', b'RM_SELECT = "E29"')
                assert data == wanted
            elif name == 'lab/Environment.j' and run == NEGATIVE:
                injection = manifest['transformation']
                assert sha(injection['old_text'].encode()) == injection['old_sha256']
                assert sha(injection['new_text'].encode()) == injection['new_sha256']
                assert sha((R / 'cycle4/timeout-injection.patch').read_bytes()) == injection['patch_sha256']
                assert maintained.count(injection['old_text'].encode()) == 1
                assert data == maintained.replace(injection['old_text'].encode(), injection['new_text'].encode(), 1)
            else:
                assert data == maintained
        builddir = ROOT / 'build' / run
        build = read_json(builddir / 'build.json')
        saved_build = read_json(R / 'cycle4' / (run + '-build.stdout.json'))
        assert build == saved_build
        for path, expected_hash in build['inputs'].items():
            absolute = Path(path)
            if absolute.is_relative_to(ORIGINAL):
                assert sha(absolute.relative_to(ORIGINAL).read_bytes()) == expected_hash
        assert sha((builddir / 'compiled.j').read_bytes()) == build['managed']['war3map.j']
        map_hash = sha((builddir / (run + '.w3x')).read_bytes())
        launch = read_json(R / 'cycle4' / (run + '-launch.json'))
        assert Path(build['output']) == ORIGINAL / builddir / (run + '.w3x')
        assert launch['map'] == build['output']
        assert map_hash == build['sha256'] == launch['map_sha256']
        assert map_hash == {NORMAL: '4490afbf0824a89186faf22e3a948452b27fe0ae1a111f3d960a108228fb2694',
                            NEGATIVE: 'caec96f8546846b9e6ca9aef64bf1732a79cf9bf4981998e8be7767d5d8f1182'}[run]
        identities[run] = {'map_sha256': map_hash, 'compiled_sha256': build['managed']['war3map.j'],
                           'log_sha256': sha((R / f'RM28-{run}.txt').read_bytes())}
    for name, expected_hash in {
        'Missiles.j': 'adc5ffd93cca18840f0e00406af482a7f41caf74334bf2e4ca928c63933d7cf6',
        'lab/Support.j': '564434895226e3a08ea88556cf797e432a8696ca4ee1e0de3d86eef5e7f3654d',
        'lab/Environment.j': '0b1c72c23fdc2cf90ad7ebdb993b1df5804b62ef3e036e21ceab6ea2b6dbfaf2'}.items():
        assert sha((ROOT / 'src' / name).read_bytes()) == expected_hash
    old_details = [x for x in old[1] if x[1] not in ('E29', 'M45')]
    new_details = [x for x in new[1] if x[1] not in ('E29', 'M45')]
    assert [(x[1], x[2], x[3]) for x in old_details] == [(x[1], x[2], x[3]) for x in new_details]
    locations = [{'case': a[1], 'name': a[3], 'old_line': a[0], 'new_line': b[0],
                  'old_detail': a[4], 'new_detail': b[4]}
                 for a, b in zip(old_details, new_details) if a[4] != b[4]]
    (OWN / 'dynamic-differences.json').write_text(json.dumps(locations, indent=2) + '\n')
    summary = {'comparison': 'PASS', 'cases': 47, 'L99_last': True,
        'normal': dict(new[2]), 'normal_status': new[3]['status'],
        'negative': dict(negative[2]), 'negative_reader_exit': 1,
        'non_E29_multiplicities': 'preserved_except_two_allowed_M45_changes',
        'M45_exact_original_checks': 70, 'original_E29_records_preserved': len(original),
        'dynamic_detail_differences': len(locations),
        'dynamic_difference_cases': sorted({x['case'] for x in locations}),
        'detail_equality_outside_M45': 'not_required',
        'identities': identities, 'copied_files': len(files),
        'source_and_candidate_preserved': True,
        'native_freshness': 'saved_native_mtime_matches_launch_and_reader_metadata',
        'historical_fixed02_freshness': 'historicalfreshnessnotrecorded',
        'scope': 'saved_single_client_evidence_and_identity_only'}
finally:
    for relative in sorted(files):
        if str(relative) in before:
            after[str(relative)] = sha((ORIGINAL / relative).read_bytes())
    (OWN / 'identities.json').write_text(json.dumps({'before': before, 'after': after}, indent=2) + '\n')
    git_after = status()
    (OWN / 'git-status-after.txt').write_bytes(git_after)
    assert before == after, 'ORIGINAL INPUT MUTATION'
    assert git_before == git_after, 'WORKSPACE STATUS MUTATION'
print(json.dumps(summary, sort_keys=True))
