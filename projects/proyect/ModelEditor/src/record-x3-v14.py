"""Capture only the owned game's monitor, checking its focus throughout."""
from pathlib import Path
import json,subprocess,time,signal,sys
root=Path(__file__).resolve().parents[1];ev=root/'evidence/x3-v14'
i=json.loads((ev/'ydwe-identity.json').read_text())['processes'][0];p=Path('/proc')/str(i['pid'])
assert p.exists() and (p/'stat').read_text().split(') ')[1].split()[19]==i['start']
prefix=next(v[11:].decode() for v in (p/'environ').read_bytes().split(b'\0') if v.startswith(b'WINEPREFIX='));assert Path(prefix).resolve()==Path(i['prefix'])
name=sys.argv[1];assert Path(name).name==name;out=ev/(name+'.mp4');assert not out.exists()
def guard():
 w=json.loads(subprocess.check_output(['hyprctl','-j','activewindow']));assert w['pid']==i['pid'] and w['at']==[3840,0] and w['monitor']==1
guard();samples=[]
with (ev/(name+'-recorder.log')).open('w') as log:
 proc=subprocess.Popen(['wf-recorder','-o','DP-1','-r','60','-c','libx264','-p','preset=ultrafast','-p','crf=18','-f',str(out)],stdout=log,stderr=log)
 start=time.monotonic()
 try:
  while time.monotonic()-start<5:
   guard();assert proc.poll() is None; samples.append(time.monotonic()-start);time.sleep(.10)
 finally:
  if proc.poll() is None:proc.send_signal(signal.SIGINT)
  code=proc.wait(timeout=10)
assert code==0,code
probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=width,height,r_frame_rate,nb_frames,duration','-of','json',str(out)]))
(ev/(name+'-recording.json')).write_text(json.dumps({'file':str(out),'pid':i['pid'],'focusSamples':len(samples),'returnCode':code,'probe':probe,'note':'Capture rate is not a measured game FPS benchmark.'},indent=2))
print(json.dumps(probe))
