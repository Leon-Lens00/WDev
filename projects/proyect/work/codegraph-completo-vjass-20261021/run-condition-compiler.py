from pathlib import Path
import subprocess,json
b=Path(__file__).resolve().parent;results=[]
for name,debug in [('debug',False),('debug',True),('or',False),('forward',False),('module-forward',False),('const-expr',False)]:
 output=b/'compiler-conditions'/(name+('-debug' if debug else '-release')+'-compiled.j')
 command=['python3',str(b/'compiler-profile.py'),str(b/'compiler-conditions'/(name+'.j')),str(output),'--no-optimize']+(['--debug'] if debug else [])
 r=subprocess.run(command,capture_output=True,text=True)
 (output.with_suffix('.log')).write_text(r.stdout+r.stderr)
 try: result=json.loads(r.stdout)
 except ValueError: result={'harness_error':r.stdout+r.stderr}
 if output.exists(): result['chosen_present']='Chosen' in output.read_text();result['early_present']='s__S_early' in output.read_text()
 result.update(name=name,debug=debug,exit=r.returncode);results.append(result)
 (b/'compiler-condition-results.json').write_text(json.dumps(results,indent=2));print(json.dumps(result),flush=True)
