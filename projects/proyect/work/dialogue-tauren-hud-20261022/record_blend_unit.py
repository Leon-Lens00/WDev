import sys,runpy,time,subprocess,signal,json
from pathlib import Path
W=Path('/home/snz/Documentos/ChatGPT/Proyect/work/dialogue-tauren-hud-20261022');sys.argv=['native_probe.py','noop'];n=runpy.run_path(str(W/'native_probe.py'));n['focus']()
def fastchat(s):
 n['focus']();subprocess.run(['ydotool','key','28:1','28:0'],check=True);time.sleep(.16);subprocess.run(['ydotool','type','-d','15','-H','15','--',s],check=True);time.sleep(.16);subprocess.run(['ydotool','key','28:1','28:0'],check=True);time.sleep(.16)
with (W/'blend-unit-recorder.log').open('w') as log:
 p=subprocess.Popen(['wf-recorder','-o','HDMI-A-1','-r','30','-c','libx264','-x','yuv420p','-p','preset=veryfast','-p','crf=18','-f',str(W/'blend-unit-probe.mp4')],stdout=log,stderr=subprocess.STDOUT)
 try:
  time.sleep(1);fastchat('-reiniciardialogo')
  end=time.monotonic()+12
  while time.monotonic()<end:n['focus']();time.sleep(.5)
  n['shot']('blend-probe-end')
 finally:p.send_signal(signal.SIGINT);p.wait(timeout=15)
 print('done')
