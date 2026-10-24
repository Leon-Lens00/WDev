"""Reproducible compiler oracle; extends the local launcher with debug/nooptimize.
All compiler files and outputs are staged under this task, never in a map.
"""
from pathlib import Path
import argparse, hashlib, importlib.util, json, shutil, subprocess, sys, tempfile

ROOT = Path('/home/snz/Documentos/ChatGPT/FrozenThone')
sys.path.insert(0, str(ROOT / 'scripts'))
import editores

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('destination', type=Path)
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--no-optimize', action='store_true')
    args = parser.parse_args()
    source = args.source.resolve(strict=True)
    destination = args.destination.resolve()
    if destination.exists(): raise RuntimeError('Destination must be new')
    config = json.loads((ROOT / 'wc3-environment.json').read_text())
    compiler_dir = ROOT / config['jasshelper_dir']
    report = Path(tempfile.mkdtemp(prefix='oracle-', dir=Path(__file__).parent))
    for name in ['clijasshelper.exe', 'pjass.exe', 'sfmpq.dll', 'jasshelper.conf']:
        shutil.copy2(compiler_dir / name, report / name)
    shutil.copytree(compiler_dir / 'bin', report / 'bin')
    win = lambda p: 'Z:' + str(p).replace('/', '\\')
    conf = report / 'jasshelper.conf'
    conf.write_text(conf.read_text().replace('[lookupfolders]', '[lookupfolders]\n"' + win(source.parent) + '\\"'))
    common, blizzard = ROOT / config['classic_common'], ROOT / config['classic_blizzard']
    staged = report / 'compiled.j'
    flags = ['--scriptonly'] + (['--debug'] if args.debug else []) + (['--nooptimize'] if args.no_optimize else [])
    command = [*editores.runtime_command('newgen'), str(report / 'clijasshelper.exe'), *flags, win(common), win(blizzard), win(source), win(staged)]
    env = editores.environment('newgen'); env['WINEDEBUG'] = '-all'
    result = subprocess.run(command, cwd=report, env=env, capture_output=True, timeout=90)
    (report / 'jasshelper.log').write_bytes(result.stdout + result.stderr)
    logged = report / 'logs/output_war3map.j'
    if result.returncode == 0 and not staged.exists() and logged.is_file(): shutil.copy2(logged, staged)
    valid = result.returncode == 0 and staged.is_file()
    checker_exit = None
    if valid:
        check = subprocess.run([str(ROOT / 'tools/wc3-addons/wc3_agent_tools/pjass/pjass'), str(common), str(blizzard), str(staged)], capture_output=True, timeout=30)
        (report / 'pjass.log').write_bytes(check.stdout + check.stderr)
        checker_exit = check.returncode
        valid = check.returncode == 0
    if valid:
        destination.parent.mkdir(parents=True, exist_ok=True)
        with destination.open('xb') as output: output.write(staged.read_bytes())
    error_file = report / 'logs/compileerrors.txt'
    evidence = {'compiled': valid, 'compiler_exit': result.returncode, 'checker_exit': checker_exit, 'report': str(report), 'flags': flags,
                'input_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'compiler_sha256': hashlib.sha256((compiler_dir/'clijasshelper.exe').read_bytes()).hexdigest(),
                'language_errors': error_file.read_text(errors='replace') if error_file.exists() else None}
    print(json.dumps(evidence))
    return 0 if valid else 1

if __name__ == '__main__': sys.exit(main())
