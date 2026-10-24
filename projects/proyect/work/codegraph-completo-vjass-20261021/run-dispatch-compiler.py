from pathlib import Path
import subprocess,json
b=Path(__file__).resolve().parent;results=[]
for p in sorted((b/'compiler-dispatch').glob('*.j')):
 if p.name.endswith('-compiled.j'):continue
 output=p.with_name(p.stem+'-compiled.j')
 r=subprocess.run(['python3',str(b/'compiler-profile.py'),str(p),str(output),'--no-optimize'],capture_output=True,text=True)
 output.with_suffix('.log').write_text(r.stdout+r.stderr)
 try: result=json.loads(r.stdout)
 except ValueError: result={'harness_error':r.stdout+r.stderr}
 result.update(name=p.stem,exit=r.returncode);results.append(result)
 (b/'compiler-dispatch-results.json').write_text(json.dumps(results,indent=2));print(json.dumps(result),flush=True)
