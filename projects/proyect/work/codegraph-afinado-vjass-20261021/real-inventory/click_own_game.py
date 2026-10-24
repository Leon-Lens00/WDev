"""Click own game's observed window coordinates; flush motion into Wine first."""
import json,subprocess,time,sys
from pathlib import Path
r=Path(__file__).resolve().parent
ident=json.loads((r/'evidence/current-game.json').read_text());pid=ident['pid'];p=Path('/proc')/str(pid)
assert (p/'stat').read_text().split()[21]==ident['stat'].split()[21]
assert any(v.rstrip(b'/')==('WINEPREFIX='+ident['prefix'].rstrip('/')).encode() for v in (p/'environ').read_bytes().split(b'\0'))
w=next(x for x in json.loads(subprocess.check_output(['hyprctl','-j','clients'])) if x['pid']==pid)
subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{w["address"]}"}})'],check=True);time.sleep(.3)
x,y=map(int,sys.argv[1:3]);subprocess.run(['hyprctl','dispatch',f'hl.dsp.cursor.move({{x={w["at"][0]+x-1},y={w["at"][1]+y}}})'],check=True);time.sleep(.2)
subprocess.run(['ydotool','mousemove','--','1','0'],check=True);time.sleep(.2)
assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==pid
subprocess.run(['ydotool','click','-D','150','0xC1' if sys.argv[3]=='right' else '0xC0'],check=True);time.sleep(.7)
m=next(x for x in json.loads(subprocess.check_output(['hyprctl','-j','monitors'])) if x['id']==w['monitor'])
subprocess.run(['grim','-o',m['name'],str(r/'evidence'/sys.argv[4])],check=True)
