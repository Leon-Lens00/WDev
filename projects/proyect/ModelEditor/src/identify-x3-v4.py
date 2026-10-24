"""Find only the new X3 game's PID, prefix and window; never act by title alone."""
from pathlib import Path
import json,subprocess,time
ROOT=Path(__file__).resolve().parents[1];prefix=ROOT/'build/x3-v4-ydwe-runtime/pfx'
for attempt in range(120):
 own=[]
 for p in Path('/proc').glob('[0-9]*'):
  try:
   cmd=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
   if 'war3.exe' not in cmd.lower():continue
   env=(p/'environ').read_bytes().split(b'\0');v=next((v[11:].decode() for v in env if v.startswith(b'WINEPREFIX=')),None)
   if v and Path(v).resolve()==prefix:own.append({'pid':int(p.name),'start':(p/'stat').read_text().split(') ')[1].split()[19],'command':cmd,'prefix':str(prefix)})
  except OSError:pass
 windows=[c for c in json.loads(subprocess.check_output(['hyprctl','-j','clients'])) if c['pid'] in [p['pid'] for p in own]]
 if len(windows)==1:break
 time.sleep(.25)
else:raise RuntimeError('No unambiguous owned X3 window after 30 seconds')
(ROOT/'evidence/x3-v4/ydwe-identity.json').write_text(json.dumps({'processes':own,'windows':windows},indent=2))
a=windows[0]['address']
monitors=json.loads(subprocess.check_output(['hyprctl','-j','monitors']))
monitor=next(m for m in monitors if m['name']=='DP-1')
workspace=monitor['activeWorkspace']['id']
for command in [f'hl.dsp.window.move({{window="address:{a}",workspace={workspace},follow=false}})',f'hl.dsp.window.fullscreen_state({{internal=0,client=0,action="set",window="address:{a}"}})',f'hl.dsp.window.fullscreen_state({{internal=2,client=0,action="set",window="address:{a}"}})',f'hl.dsp.focus({{window="address:{a}"}})']:
 subprocess.run(['hyprctl','dispatch',command],check=True)
print(json.dumps({'process':own,'address':a}))

clients=json.loads(subprocess.check_output(['hyprctl','-j','clients']));w=next(c for c in clients if c['pid']==own[0]['pid']);assert w['monitor']==monitor['id'] and w['at']==[monitor['x'],monitor['y']];(ROOT/'evidence/x3-v4/ydwe-screen3.json').write_text(json.dumps(w,indent=2))
