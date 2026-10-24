"""Record a local animation command on the rightmost screen, by owned PID."""
from pathlib import Path
import json,subprocess,time,sys,re
ROOT=Path(__file__).resolve().parents[1];EV=ROOT/'evidence/x3-v10'
ident=next(p for p in json.loads((EV/'ydwe-identity.json').read_text())['processes'] if 'war3.exe' in p['command'].lower())
p=Path('/proc')/str(ident['pid']);assert (p/'stat').read_text().split(') ')[1].split()[19]==ident['start']
assert Path(next(v[11:].decode() for v in (p/'environ').read_bytes().split(b'\0') if v.startswith(b'WINEPREFIX='))).resolve()==Path(ident['prefix'])
command=sys.argv[1];assert command in ['-birth','-stand','-impact','-scale','-move']
listing=subprocess.check_output(['python',str(ROOT/'src/runtime-x3-v10-ydwe.py'),'ui'],text=True)
handles=re.findall(r'^([0-9A-Fa-f]+) pid=\d+ Warcraft III\s*$',listing,re.M);assert len(handles)==1,listing
for args in [['13'],['text',command],['13']]:subprocess.run(['python',str(ROOT/'src/runtime-x3-v10-ydwe.py'),'ui',handles[0],*args],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True)
clients=json.loads(subprocess.check_output(['hyprctl','-j','clients']));w=next(c for c in clients if c['pid']==ident['pid']);a=w['address']
subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{a}"}})'],stdout=subprocess.DEVNULL,check=True)
active=json.loads(subprocess.check_output(['hyprctl','-j','activewindow']));assert active['pid']==ident['pid'];assert active['at']==[3840,0]
# Restore the native game's activation after the console helper exits.
subprocess.run(['hyprctl','dispatch','hl.dsp.cursor.move({x=5340,y=550})'],stdout=subprocess.DEVNULL,check=True)
subprocess.run(['ydotool','click','-D','0','0xC0'],stdout=subprocess.DEVNULL,check=True)
name=sys.argv[2] if len(sys.argv)>2 else command[1:]+'-verified';assert Path(name).name==name
folder=EV/name;folder.mkdir(exist_ok=True);start=time.monotonic();records=[]
for i in range(25):
 assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==ident['pid'],'focus changed during capture'
 clients=json.loads(subprocess.check_output(['hyprctl','-j','clients']));w=next(c for c in clients if c['pid']==ident['pid']);monitors=json.loads(subprocess.check_output(['hyprctl','-j','monitors']));m=next(m for m in monitors if m['id']==w['monitor']);assert m['name']=='DP-1';assert m['activeWorkspace']['id']==w['workspace']['id']
 subprocess.run(['grim','-o','DP-1',str(folder/f'{i:03}.png')],check=True)
 records.append({'frame':i,'t':time.monotonic()-start,'pid':w['pid'],'monitor':m['name'],'workspace':w['workspace']['id']})
(folder/'timing.json').write_text(json.dumps(records,indent=2));print(json.dumps({'command':command,'frames':len(records),'duration':records[-1]['t']}))
