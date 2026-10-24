"""Inputs/captures restricted to the integration's current own Warcraft PID."""
from pathlib import Path
import json,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[1]
prefix=str((ROOT.parent/'inventory-integration/runtime-isolated/pfx').resolve())
identity_file=ROOT/'evidence'/sys.argv[1]
clients=json.loads(subprocess.check_output(['hyprctl','-j','clients']))
if identity_file.exists():
    identity=json.loads(identity_file.read_text())
else:
    matches=[]
    for w in clients:
        p=Path('/proc')/str(w['pid'])
        try:
            own=any(v.rstrip(b'/')==('WINEPREFIX='+prefix).encode() for v in (p/'environ').read_bytes().split(b'\0'))
            command=(p/'cmdline').read_bytes().split(b'\0')[0].lower().replace(b'\\',b'/')
            if own and command.endswith(b'/war3.exe'):matches.append(w)
        except OSError:pass
    assert len(matches)==1,matches
    w=matches[0];identity={'pid':w['pid'],'prefix':prefix,'stat':(Path('/proc')/str(w['pid'])/'stat').read_text(),'window':w}
    identity_file.write_text(json.dumps(identity,indent=2))
p=Path('/proc')/str(identity['pid'])
assert (p/'stat').read_text().split()[21]==identity['stat'].split()[21]
assert any(v.rstrip(b'/')==('WINEPREFIX='+prefix).encode() for v in (p/'environ').read_bytes().split(b'\0'))
w=next(w for w in clients if w['pid']==identity['pid'])
subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{w["address"]}"}})'],check=True,stdout=subprocess.DEVNULL)
time.sleep(.3)
assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==identity['pid']
action=sys.argv[2]
if action=='key':
    key=int(sys.argv[3]);subprocess.run(['ydotool','key','-d','150',f'{key}:1',f'{key}:0'],check=True)
elif action=='chat':
    subprocess.run(['ydotool','key','-d','150','28:1','28:0'],check=True);time.sleep(.15)
    subprocess.run(['ydotool','type','-e','0','--',sys.argv[3]],check=True)
    subprocess.run(['ydotool','key','-d','150','28:1','28:0'],check=True)
elif action=='exitprompt':
    subprocess.run(['ydotool','key','125:1','16:1','16:0','125:0'],check=True)
elif action!='capture':raise ValueError(action)
if action=='capture':
    monitor=next(m for m in json.loads(subprocess.check_output(['hyprctl','-j','monitors'])) if m['id']==w['monitor'])
    subprocess.run(['grim','-o',monitor['name'],str(ROOT/'evidence'/sys.argv[3])],check=True)
print(identity['pid'],action)
