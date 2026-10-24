"""Run a local scene pipeline; resume only when inputs AND outputs still match.

Stage commands are explicit argv arrays, never shell strings. Manual review stages
only consume an existing accepted record; this script cannot approve images or UI.
"""
import argparse
import hashlib
import json
import pathlib
import subprocess
import datetime

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def snapshot(paths, base):
    result = {}
    for name in paths:
        path = (base / name).resolve()
        if not path.is_file():
            raise FileNotFoundError(path)
        result[str(path)] = digest(path)
    return result

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('pipeline', type=pathlib.Path)
    p.add_argument('--through', help='Stop after this stage id')
    args = p.parse_args()
    config = args.pipeline.resolve()
    data = json.loads(config.read_text(encoding='utf-8-sig'))
    base = (config.parent / data.get('cwd', '.')).resolve()
    state_path = config.with_suffix('.state.json')
    state = json.loads(state_path.read_text()) if state_path.exists() else {}
    for stage in data['stages']:
        key = stage['id']
        signature = {'stage': stage, 'inputs': snapshot(stage['inputs'], base)}
        previous = state.get(key, {})
        try:
            current = snapshot(stage['outputs'], base)
        except FileNotFoundError:
            current = None
        if previous.get('signature') == signature and current == previous.get('outputs') and current:
            print(key + ': resumed, hashes match', flush=True)
        else:
            if 'review' in stage:
                review = json.loads((base / stage['review']).read_text(encoding='utf-8-sig'))
                if review.get('accepted') is not True:
                    raise RuntimeError(key + ': real review is still pending')
                reviewed = review.get('reviewed_inputs', {})
                review_path = str((base / stage['review']).resolve())
                for path, sha in signature['inputs'].items():
                    if path != review_path and reviewed.get(path) != sha:
                        raise RuntimeError(key + ': review does not cover current input ' + path)
            else:
                log = config.parent / (key + '.log')
                with log.open('w', encoding='utf-8') as stream:
                    result = subprocess.run(stage['argv'], cwd=base, stdout=stream, stderr=subprocess.STDOUT)
                if result.returncode:
                    raise RuntimeError(key + ': failed; inspect ' + str(log))
            current = snapshot(stage['outputs'], base)
            state[key] = {'signature': signature, 'outputs': current,
                          'completed_at': datetime.datetime.now(datetime.timezone.utc).isoformat()}
            state_path.write_text(json.dumps(state, indent=2), encoding='utf-8')
            print(key + ': completed', flush=True)
        if args.through == key:
            break

if __name__ == '__main__':
    main()
