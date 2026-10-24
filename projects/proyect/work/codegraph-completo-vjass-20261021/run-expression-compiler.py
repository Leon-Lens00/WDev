from pathlib import Path
import subprocess,json
b=Path(__file__).resolve().parent
results=[]
for i in range(4):
 p=b/'compiler-expressions'/f'case-{i}.j'; output=p.with_name(p.stem+'-compiled.j')
 r=subprocess.run(['python3','/home/snz/Documentos/ChatGPT/FrozenThone/scripts/wc3.py','vjass',str(p),str(output)],capture_output=True,text=True)
 (p.with_suffix('.log')).write_text(r.stdout+r.stderr)
 results.append({'id':i,'expected_valid':i<3,'valid':output.exists(),'launcher_exit':r.returncode,'passed':output.exists()==(i<3)})
 (b/'compiler-expression-results.json').write_text(json.dumps(results,indent=2));print(json.dumps(results[-1]),flush=True)
