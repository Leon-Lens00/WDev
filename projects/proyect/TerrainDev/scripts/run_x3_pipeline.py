#!/usr/bin/env python3
"""Run the engine fixture in its already-verified own window; no map mutation."""
from pathlib import Path
import subprocess,json,time,shutil,sys
r=Path(__file__).resolve().parents[1]
info=json.loads((r/'reports/current-x3-test.json').read_text());d=Path(info['directory'])
identity=json.loads((d/'window-identity.json').read_text());pid=identity['window']['pid'];addr=identity['window']['address'];hwnd=identity['hwnd'];begun=time.monotonic()
for tag,command,limit in [('x3','-x3test',55),('colors','-testcolors',20),('rapid','-rapid',45),('native','-native',45)]:
    cmdline=Path(f'/proc/{pid}/cmdline').read_bytes().decode().replace('\0',' ')
    assert info['sha256'][:16] in cmdline and 'war3.exe' in cmdline
    for args in [['13'],['text',command],['13']]:
        subprocess.run([sys.executable,str(r/'scripts/x3_runtime.py'),'ui',hwnd,*args],capture_output=True,check=True)
    p=Path(info['log_directory'])/f'TerrainDev-{info["run"]}-{tag}.txt';deadline=time.monotonic()+limit
    while time.monotonic()<deadline:
        w=next((x for x in json.loads(subprocess.check_output(['hyprctl','-j','clients'])) if x['pid']==pid and x['address']==addr),None)
        assert w is not None
        subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{addr}"}})'],capture_output=True,check=True)
        raw=p.read_text() if p.exists() else ''
        if ' COMPLETE' in raw:
            shutil.copy2(p,d/f'{tag}-engine.txt');print(tag,'COMPLETE','contains FAIL:', '"FAIL ' in raw,flush=True);break
        if 'TIMEOUT' in raw:raise RuntimeError(raw)
        time.sleep(.75)
    else:raise RuntimeError(f'{tag} did not complete before deadline')
print('all stages completed',round(time.monotonic()-begun,2),flush=True)
