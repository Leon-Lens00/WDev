#!/usr/bin/env python3
"""Use the verified modern runtime with this integration's own copied prefix."""
from pathlib import Path
import sys, importlib.util, subprocess, json, hashlib, datetime, shutil
ROOT=Path(__file__).resolve().parent
TOOLS=Path('/home/snz/Documentos/ChatGPT/FrozenThone')
spec=importlib.util.spec_from_file_location('modern',TOOLS/'scripts/newgen-moderno.py')
modern=importlib.util.module_from_spec(spec);spec.loader.exec_module(modern)
data=ROOT/'runtime-isolated'
if not data.exists():subprocess.run(['cp','-a','--reflink=always',str(modern.DATA),str(data)],check=True)
modern.DATA=data
source=Path(sys.argv[1]).resolve()
report=ROOT/'evidence'/('isolated-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'));report.mkdir()
game=data/'pfx/drive_c/WarcraftIII'
prefix=('WINEPREFIX='+str(data/'pfx')).encode()
for proc in Path('/proc').glob('[0-9]*'):
    try:
        env=(proc/'environ').read_bytes().split(b'\0');cmd=(proc/'cmdline').read_bytes().split(b'\0')[0]
        if any(v.rstrip(b'/')==prefix for v in env) and cmd.lower().replace(b'\\',b'/').endswith(b'/war3.exe'):raise RuntimeError('Own test game is still running')
    except OSError:pass
for f in (game/'CustomMapData/Logs').glob('InventoryProbe*.txt'):shutil.move(f,report/f.name)
digest=hashlib.sha256(source.read_bytes()).hexdigest();target=game/'Maps/CodexTest'/(digest[:16]+'.w3x');shutil.copy2(source,target)
command=[str(modern.SLR),'--verb=run','--',str(modern.PROTON),'runinprefix',r'C:\WarcraftIII\war3.exe','-loadfile','Maps\\CodexTest\\'+target.name,'-window']
env=modern.environment();env['DXVK_LOG_PATH']=str(report)
metadata={'source':str(source),'sha256':digest,'command':command,'prefix':str(data/'pfx'),'report':str(report)}
(report/'launch.json').write_text(json.dumps(metadata,indent=2));(ROOT/'isolated-launch.json').write_text(json.dumps(metadata,indent=2))
with (report/'runtime.log').open('w') as log:
    proc=subprocess.Popen(command,cwd=game,env=env,stdout=log,stderr=log)
    raise SystemExit(proc.wait())
