"""Record a local animation command on the rightmost screen, by owned PID."""
from pathlib import Path
import json,subprocess,time,sys,re
ROOT=Path(__file__).resolve().parents[1];EV=ROOT/'evidence/x3-v13'
ident=next(p for p in json.loads((EV/'ydwe-identity.json').read_text())['processes'] if 'war3.exe' in p['command'].lower())
p=Path('/proc')/str(ident['pid']);assert (p/'stat').read_text().split(') ')[1].split()[19]==ident['start']
assert Path(next(v[11:].decode() for v in (p/'environ').read_bytes().split(b'\0') if v.startswith(b'WINEPREFIX='))).resolve()==Path(ident['prefix'])
command=sys.argv[1];assert command in ['-birth','-stand','-impact','-scale','-move','-slow']
clients=json.loads(subprocess.check_output(['hyprctl','-j','clients']));w=next(c for c in clients if c['pid']==ident['pid']);a=w['address']
subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{a}"}})'],stdout=subprocess.DEVNULL,check=True)
active=json.loads(subprocess.check_output(['hyprctl','-j','activewindow']));assert active['pid']==ident['pid'];assert active['at']==[3840,0]
# Use desktop input after the fresh owned-window screenshot. Avoid launching a
# console window: with two fullscreen games it changed native activation.
def guard():
 assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==ident['pid'],'focus changed before input'
guard()
subprocess.run(['ydotool','key','1:1','1:0'],check=True)
time.sleep(.15)
guard()
subprocess.run(['ydotool','key','28:1','28:0'],check=True)
time.sleep(.15)
guard()
subprocess.run(['ydotool','type','-e','0','--',command],check=True)
time.sleep(.1)
guard()
subprocess.run(['ydotool','key','28:1','28:0'],check=True)
name=sys.argv[2] if len(sys.argv)>2 else command[1:]+'-verified';assert Path(name).name==name
folder=EV/name;folder.mkdir(exist_ok=True);start=time.monotonic();records=[]
for i in range(25):
 assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==ident['pid'],'focus changed during capture'
 clients=json.loads(subprocess.check_output(['hyprctl','-j','clients']));w=next(c for c in clients if c['pid']==ident['pid']);monitors=json.loads(subprocess.check_output(['hyprctl','-j','monitors']));m=next(m for m in monitors if m['id']==w['monitor']);assert m['name']=='DP-1';assert m['activeWorkspace']['id']==w['workspace']['id']
 subprocess.run(['grim','-o','DP-1',str(folder/f'{i:03}.png')],check=True)
 records.append({'frame':i,'t':time.monotonic()-start,'pid':w['pid'],'monitor':m['name'],'workspace':w['workspace']['id']})
(folder/'timing.json').write_text(json.dumps(records,indent=2));print(json.dumps({'command':command,'frames':len(records),'duration':records[-1]['t']}))
