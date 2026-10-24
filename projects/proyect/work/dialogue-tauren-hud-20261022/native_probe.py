import json,subprocess,time,sys
from pathlib import Path
ROOT=Path('/home/snz/Documentos/ChatGPT/Proyect');WORK=ROOT/'work/dialogue-tauren-hud-20261022'
WRAPPER='/home/snz/Documentos/ChatGPT/FrozenThone/work/two-candidate-tests-20261018/wine_ui_newgen.py'
def cmd(*a):return subprocess.check_output(a,stderr=subprocess.DEVNULL).decode()
def js(kind):return json.loads(cmd('hyprctl','-j',kind))
def dispatch(s):return cmd('hyprctl','dispatch',s)
if sys.argv[1]=='init':
 b=json.loads((ROOT/'TerrainDev/dialogue-system/latest-build.json').read_text());c=next(c for c in js('clients') if c['title']=='Warcraft III' and b['sha256'][:16] in Path('/proc',str(c['pid']),'cmdline').read_bytes().decode());p=Path('/proc',str(c['pid']));pref=next(e.decode().split('=',1)[1] for e in (p/'environ').read_bytes().split(b'\0') if e.startswith(b'WINEPREFIX='));e=cmd('python3',WRAPPER);lines=[l for l in e.splitlines() if 'Warcraft III' in l];assert len(lines)==1
 j=dict(pid=c['pid'],start=(p/'stat').read_text().split()[21],prefix=pref,window=c,hwnd=lines[0].split()[0],map_sha256=b['sha256']);(WORK/'projection-probe-identity.json').write_text(json.dumps(j,indent=2))
 a='address:'+c['address'];dispatch('hl.dsp.focus({monitor="HDMI-A-1"})');dispatch(f'hl.dsp.window.move({{window="{a}",workspace=32,follow=true}})');dispatch(f'hl.dsp.window.move({{window="{a}",monitor="HDMI-A-1",follow=true}})')
else:j=json.loads((WORK/'projection-probe-identity.json').read_text())
def validate():
 p=Path('/proc',str(j['pid']));assert (p/'stat').read_text().split()[21]==j['start'];assert j['map_sha256'][:16] in (p/'cmdline').read_bytes().decode();assert j['prefix'].rstrip('/')=='/home/snz/Documentos/ChatGPT/FrozenThone/runtime/proton-newgen-modern-test/pfx'
def focus():
 validate();dispatch('hl.dsp.focus({monitor="HDMI-A-1"})');dispatch('hl.dsp.focus({workspace=32,on_current_monitor=false})');dispatch('hl.dsp.focus({window="address:'+j['window']['address']+'"})');time.sleep(.35)
 c=next(c for c in js('clients') if c['pid']==j['pid']);m=next(m for m in js('monitors') if m['name']=='HDMI-A-1');assert c['at'][0]==1920 and c['monitor']==2 and c['workspace']['id']==m['activeWorkspace']['id']==32
 return c,m
def chat(s):
 validate()
 for args in [['13'],['text',s],['13']]:subprocess.run(['python3',WRAPPER,j['hwnd'],*args],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
def shot(name):
 c,m=focus();path=WORK/(name+'.png');subprocess.run(['grim','-o',m['name'],str(path)],check=True);(WORK/(name+'.json')).write_text(json.dumps(dict(pid=j['pid'],map_sha256=j['map_sha256'],window=c,monitor=m),indent=2))
if sys.argv[1]=='init':focus();dispatch('hl.dsp.window.fullscreen({mode="fullscreen",action="set"})');print(j['pid'])
elif sys.argv[1]=='chat':chat(sys.argv[2])
elif sys.argv[1]=='series':
 for k in range(int(sys.argv[3])):focus();time.sleep(.6);shot(sys.argv[2]+'-'+str(k))
elif sys.argv[1]=='shot':shot(sys.argv[2])
