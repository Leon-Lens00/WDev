from pathlib import Path
import sys,json,subprocess,time
ROOT=Path('/home/snz/Documentos/ChatGPT/Proyect');WORK=Path(__file__).parent
PREFIX=str(ROOT/'TerrainDev/inventory-integration/runtime-isolated/pfx')
def js(name):return json.loads(subprocess.check_output(['hyprctl','-j',name]))
def dispatch(s):subprocess.run(['hyprctl','dispatch',s],check=True,stdout=subprocess.DEVNULL)
if sys.argv[1]=='init':
 matches=[]
 for c in js('clients'):
  p=Path('/proc')/str(c['pid'])
  try:
   if any(e.rstrip(b'/')==('WINEPREFIX='+PREFIX).encode() for e in (p/'environ').read_bytes().split(b'\0')) and c['title']=='Warcraft III':matches.append(c)
  except OSError:pass
 assert len(matches)==1,matches
 c=matches[0];p=Path('/proc')/str(c['pid']);j={'pid':c['pid'],'start':(p/'stat').read_text().split()[21],'prefix':PREFIX,'window':c,'map':json.loads((ROOT/'TerrainDev/dialogue-system/latest-build.json').read_text())}
 (WORK/'identity.json').write_text(json.dumps(j,indent=2))
 dispatch('hl.dsp.focus({monitor="HDMI-A-1"})');dispatch('hl.dsp.window.move({window="address:'+c['address']+'",workspace=32,follow=true})');dispatch('hl.dsp.window.move({window="address:'+c['address']+'",monitor="HDMI-A-1",follow=true})')
else:j=json.loads((WORK/'identity.json').read_text())
def focus():
 p=Path('/proc')/str(j['pid']);assert (p/'stat').read_text().split()[21]==j['start'];assert any(e.rstrip(b'/')==('WINEPREFIX='+PREFIX).encode() for e in (p/'environ').read_bytes().split(b'\0'))
 dispatch('hl.dsp.focus({monitor="HDMI-A-1"})');dispatch('hl.dsp.focus({window="address:'+j['window']['address']+'"})');time.sleep(.25)
 assert js('activewindow')['pid']==j['pid']
def key(k):focus();subprocess.run(['ydotool','key','-d','80',str(k)+':1',str(k)+':0'],check=True)
def chat(s):
 key(28);time.sleep(.15);subprocess.run(['ydotool','type','-d','15','-H','15','--',s],check=True);time.sleep(.1);key(28)
def shot(name):
 focus();subprocess.run(['grim','-o','HDMI-A-1',str(WORK/(name+'.png'))],check=True)
if sys.argv[1]=='init':shot('menu');print(j['pid'])
elif sys.argv[1]=='shot':shot(sys.argv[2])
elif sys.argv[1]=='key':key(int(sys.argv[2]))
elif sys.argv[1]=='chat':chat(sys.argv[2])
elif sys.argv[1]=='click':
 focus();dispatch('hl.dsp.cursor.move({x='+str(1920+int(sys.argv[2]))+',y='+str(int(sys.argv[3]))+'})');time.sleep(.15);subprocess.run(['ydotool','click','0x40'],check=True);time.sleep(.12);subprocess.run(['ydotool','click','0x80'],check=True)
