"""Close this test only. Confirm separately after inspecting its dialog."""
from pathlib import Path
import json,subprocess,time,sys
EV=Path(__file__).resolve().parents[1]/'evidence/x3-v13'
i=json.loads((EV/'ydwe-identity.json').read_text())['processes'][0]
p=Path('/proc')/str(i['pid'])
if not p.exists():
 assert not any(w['pid']==i['pid'] for w in json.loads(subprocess.check_output(['hyprctl','-j','clients'])))
 print(json.dumps({'alreadyClosed':True,'inputSent':False,'pid':i['pid']}))
 raise SystemExit(0)
assert (p/'stat').read_text().split(') ')[1].split()[19]==i['start']
prefix=next(x[11:].decode() for x in (p/'environ').read_bytes().split(b'\0') if x.startswith(b'WINEPREFIX='))
assert Path(prefix).resolve()==Path(i['prefix']).resolve()
assert 'war3.exe' in (p/'cmdline').read_bytes().decode().lower()
w=next(w for w in json.loads(subprocess.check_output(['hyprctl','-j','clients'])) if w['pid']==i['pid'])
assert w['monitor']==1 and w['at']==[3840,0]
if sys.argv[1]=='request':
 subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{w["address"]}"}})'],check=True)
 assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==i['pid']
 subprocess.run(['ydotool','key','125:1','16:1','16:0','125:0'],check=True)
 time.sleep(.25)
 subprocess.run(['grim','-o','DP-1',str(EV/'close-confirm.png')],check=True)
elif sys.argv[1]=='confirm':
 assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==i['pid']
 subprocess.run(['ydotool','key','31:1','31:0'],check=True)
else:raise ValueError('request or confirm')
