from pathlib import Path
import subprocess,json
b=Path(__file__).resolve().parent; d=b/'compiler-jury';d.mkdir(exist_ok=True)
entry='\nfunction main takes nothing returns nothing\nendfunction\nfunction config takes nothing returns nothing\nendfunction\n'
cases={
'array-values':'globals\nstring array names\nendglobals\nfunction Target takes nothing returns nothing\nendfunction\nfunction Run takes nothing returns nothing\nset names[0]="Target"\ncall ExecuteFunc(names[0])\nendfunction\n'+entry,
'constant-initializers':'function Compute takes nothing returns integer\nreturn 1\nendfunction\nglobals\nconstant integer VALUE=Compute()\nendglobals\nstruct S\nstatic constant integer FIELD=Compute()\nendstruct\n'+entry,
'injected-values':'globals\nstring dispatch=""\nendglobals\nfunction Target takes nothing returns nothing\nendfunction\n//! inject main\nset dispatch=Target.name\ncall ExecuteFunc(dispatch)\n//! dovjassinit\n//! endinject\n'+entry,
'nested-runtime-static':'static if DEBUG_MODE then\nfunction Optional takes nothing returns nothing\nif true then\nendif\nendfunction\nglobals\nconstant boolean FLAG=true\nendglobals\nendif\nstatic if FLAG then\nfunction Yes takes nothing returns nothing\nendfunction\nelse\nfunction No takes nothing returns nothing\nendfunction\nendif\n'+entry,
}
results=[]
for name,source in cases.items():
 p=d/(name+'.j');p.write_text(source)
 for debug in ([False,True] if name=='nested-runtime-static' else [False]):
  out=d/(name+('-debug' if debug else '-release')+'-compiled.j')
  if out.exists():raise RuntimeError('Fresh output required')
  r=subprocess.run(['python',str(b/'compiler-profile.py'),str(p),str(out),'--no-optimize']+(['--debug'] if debug else []),capture_output=True,text=True)
  try:item=json.loads(r.stdout)
  except json.JSONDecodeError:item={'stdout':r.stdout,'stderr':r.stderr}
  item.update(case=name,debug=debug,exit=r.returncode);results.append(item)
  (b/'compiler-jury-results.json').write_text(json.dumps(results,indent=2));print(name,debug,r.returncode,flush=True)
