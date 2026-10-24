import sys,runpy,subprocess,time,json,signal,shutil
from pathlib import Path
W=Path('/home/snz/Documentos/ChatGPT/Proyect/work/dialogue-tauren-hud-20261022');sys.argv=['native_probe.py','noop'];n=runpy.run_path(str(W/'native_probe.py'));n['focus']();shutil.copy2(W/'projection-probe-identity.json',W/'patrol-video-identity.json')
def fastchat(s):
 n['focus']();subprocess.run(['ydotool','key','28:1','28:0'],check=True);time.sleep(.16);subprocess.run(['ydotool','type','-d','15','-H','15','--',s],check=True);time.sleep(.16);subprocess.run(['ydotool','key','28:1','28:0'],check=True);time.sleep(.16)
fastchat('-cerrardialogo');time.sleep(1)
events=[];start=time.monotonic()
def event(label):
 events.append({'seconds':round(time.monotonic()-start,3),'label':label});(W/'patrol-video-timeline.json').write_text(json.dumps(events,indent=2,ensure_ascii=False))
def hold(sec):
 end=time.monotonic()+sec
 while time.monotonic()<end:n['focus']();time.sleep(min(.5,max(0,end-time.monotonic())))
def chat(s,label):event(label);fastchat(s);event('Ejecutado: '+label)
def key(v,label):
 event(label);n['focus']();subprocess.run(['ydotool','key',f'{v}:1',f'{v}:0'],check=True);time.sleep(.15)
with (W/'patrol-video-recorder.log').open('w') as log:
 rec=subprocess.Popen(['wf-recorder','-o','HDMI-A-1','-r','30','-c','libx264','-x','yuv420p','-p','preset=veryfast','-p','crf=20','-f',str(W/'dialogo-patrulla-raw.mp4')],stdout=log,stderr=subprocess.STDOUT)
 try:
  event('HUD normal');hold(2);assert rec.poll() is None
  chat('-dialogo','Apertura del panel');hold(1)
  chat('-pausadialogo','Pausa del texto: Stand');n['shot']('patrol-paused-a');hold(5);n['shot']('patrol-paused-b')
  chat('-pausadialogo','Reanudar escritura: Talk');hold(10)
  event('Stand automático al completar la página');hold(20);n['shot']('patrol-idle')
  key(106,'Interacción: siguiente página');hold(9)
  key(106,'Interacción: interlocutor azul');hold(5)
  chat('-patrullardialogo','Patrulla con panel abierto');n['shot']('patrol-start');hold(8);n['shot']('patrol-out');hold(8);n['shot']('patrol-return');hold(8)
  chat('-parardialogo','Detener patrulla');hold(2)
  chat('-cerrardialogo','Cerrar panel');hold(4);n['shot']('patrol-closed');event('Fin')
 finally:
  if rec.poll() is None:rec.send_signal(signal.SIGINT)
  rec.wait(timeout=15)
 event('Grabador cerrado');print(json.dumps({'duration':time.monotonic()-start,'recorder_exit':rec.returncode,'events':events},ensure_ascii=False))
