#!/usr/bin/env python3
"""One owned Classic session, all visual cases; leaves explicit exit to operator."""
from pathlib import Path
import json,hashlib,subprocess,time,datetime,shutil,sys
ROOT=Path(__file__).resolve().parents[1];INV=ROOT.parent/'inventory-integration';PREFIX=str(INV/'runtime-isolated/pfx')
LOGS=INV/'runtime-isolated/pfx/drive_c/WarcraftIII/CustomMapData/Logs'
metadata=json.loads((ROOT/'latest-texttag-build.json').read_text());assert hashlib.sha256(Path(metadata['map']).read_bytes()).hexdigest()==metadata['sha256']
def own(pid):
 p=Path('/proc')/str(pid)
 try:return any(v.rstrip(b'/')==('WINEPREFIX='+PREFIX).encode() for v in (p/'environ').read_bytes().split(b'\0')) and (p/'cmdline').read_bytes().split(b'\0')[0].lower().replace(b'\\',b'/').endswith(b'/war3.exe')
 except OSError:return False
assert not [p.name for p in Path('/proc').glob('[0-9]*') if own(p.name)],'Own game already running'
run=ROOT/'evidence/texttag-lab'/('run-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'));run.mkdir()
for p in LOGS.glob('TextTagLab-*.txt'):shutil.move(p,run/('previous-'+p.name))
launchlog=(run/'launch.log').open('w');launcher=subprocess.Popen(['python3',str(INV/'play_isolated.py'),metadata['map']],stdout=launchlog,stderr=launchlog,start_new_session=True)
start=time.monotonic();window=None
while time.monotonic()-start<60:
 windows=[w for w in json.loads(subprocess.check_output(['hyprctl','-j','clients'])) if own(w['pid'])]
 if len(windows)==1:window=windows[0];break
 time.sleep(.25)
assert window,'No owned game window'
pid=window['pid'];stat=(Path('/proc')/str(pid)/'stat').read_text();identity={'pid':pid,'prefix':PREFIX,'stat':stat,'window':window}
(ROOT/'evidence/game-identity-texttag-current.json').write_text(json.dumps(identity,indent=2));(run/'identity.json').write_text(json.dumps(identity,indent=2))
cases=json.loads((ROOT/'evidence/texttag-lab/cases.json').read_text());seen={};captured=[]
while time.monotonic()-start<360:
 assert own(pid),'Owned game ended before all cases'
 assert (Path('/proc')/str(pid)/'stat').read_text().split()[21]==stat.split()[21]
 for i,c in enumerate(cases):
  p=LOGS/f'TextTagLab-{i}.txt'
  if not p.exists() or i in captured:continue
  seen.setdefault(i,time.monotonic())
  if time.monotonic()-seen[i]<2:continue
  current=next(w for w in json.loads(subprocess.check_output(['hyprctl','-j','clients'])) if w['pid']==pid)
  subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{current["address"]}"}})'],check=True,stdout=subprocess.DEVNULL)
  time.sleep(.3)
  if json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']!=pid:continue
  monitor=next(m for m in json.loads(subprocess.check_output(['hyprctl','-j','monitors'])) if m['id']==current['monitor'])
  subprocess.run(['grim','-o',monitor['name'],str(run/f'{i:02d}-{c["name"]}.png')],check=True)
  shutil.copy2(p,run/p.name);captured.append(i)
  print(f'Captured {i+1}/{len(cases)} {c["name"]}',flush=True)
  (run/'progress.json').write_text(json.dumps({'pid':pid,'map':metadata,'captured':captured,'expected':len(cases)},indent=2))
 done=LOGS/f'TextTagLab-{len(cases)-1}-complete.txt'
 if done.exists() and len(captured)==len(cases):shutil.copy2(done,run/done.name);break
 time.sleep(.25)
assert len(captured)==len(cases),(len(captured),len(cases))
(ROOT/'evidence/texttag-lab/latest-run.json').write_text(json.dumps({'path':str(run),'pid':pid,'captured':len(captured),'sha256':metadata['sha256'],'visual_reviewed':False},indent=2))
print('CAPTURE COMPLETE '+str(run),flush=True)
