"""After observing its exit confirmation, press S and guarantee this own PID exits."""
import json,subprocess,time,os,signal,sys,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent
identity=json.loads(Path(sys.argv[1]).read_text());pid=identity['pid'];proc=Path('/proc')/str(pid)
forced=False
def own():
    assert proc.exists()
    assert (proc/'stat').read_text().split()[21]==identity['stat'].split()[21]
    assert any(v.rstrip(b'/')==('WINEPREFIX='+identity['prefix'].rstrip('/')).encode() for v in (proc/'environ').read_bytes().split(b'\0'))
if proc.exists():
    own()
    window=next(w for w in json.loads(subprocess.check_output(['hyprctl','-j','clients'])) if w['pid']==pid)
    subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{window["address"]}"}})'],check=True)
    assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==pid
    subprocess.run(['ydotool','key','31:1','31:0'],check=True)
    for _ in range(40):
        if not proc.exists():break
        time.sleep(.1)
    if proc.exists():
        own();os.kill(pid,signal.SIGTERM);forced=True
        for _ in range(30):
            if not proc.exists():break
            time.sleep(.1)
assert not proc.exists()
result={'pid':pid,'exited':True,'confirmation':'S','sigterm_needed':forced}
(ROOT/'evidence'/f'closed-{pid}.json').write_text(json.dumps(result,indent=2))
for f in (Path(identity['prefix'])/'drive_c/WarcraftIII/CustomMapData/Logs').glob('InventoryProbe*.txt'):
    shutil.copy2(f,ROOT/'evidence'/f'{pid}-{f.name}')
print(json.dumps(result))
