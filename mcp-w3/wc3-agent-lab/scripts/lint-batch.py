#!/usr/bin/env python3
from pathlib import Path
import importlib.util,json,sys
from dataclasses import asdict
lint=Path('/home/snz/.codex/skills/build-warcraft3-vjass-127b/scripts/wc3lint.py')
if not sys.argv[1:]:
    raise SystemExit('Usage: lint-batch.py SOURCE.j [SOURCE.jass SOURCE.vjass ...]')
spec=importlib.util.spec_from_file_location('wc3lint_hook',lint)
module=importlib.util.module_from_spec(spec)
sys.modules[spec.name]=module
spec.loader.exec_module(module)
findings=[]
paths=[]
for value in dict.fromkeys(sys.argv[1:]):
    path=Path(value).expanduser().resolve(strict=True)
    if not path.is_file() or path.suffix.lower() not in {'.j','.jass','.vjass'}:
        raise SystemExit(f'Unsupported source: {path}')
    paths.append(path)
    findings.extend(module.scan_file(path))
findings.sort(key=lambda f:(f.path,f.line,f.severity,f.rule))
print(json.dumps({'files':len(paths),'findings':[asdict(f) for f in findings]},indent=2))
raise SystemExit(1 if any(f.severity=='ERROR' for f in findings) else 0)
