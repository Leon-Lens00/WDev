import sys,runpy,subprocess,time,json,signal
from pathlib import Path
W=Path('/home/snz/Documentos/ChatGPT/Proyect/work/dialogue-tauren-hud-20261022')
sys.argv=['native_probe.py','noop'];n=runpy.run_path(str(W/'native_probe.py'))
n['focus'](); events=[];start=time.monotonic()
def event(label):
 events.append({'seconds':round(time.monotonic()-start,3),'label':label});(W/'video-timeline.json').write_text(json.dumps(events,indent=2,ensure_ascii=False))
def hold(sec):
 end=time.monotonic()+sec
 while time.monotonic()<end:
  n['focus']();time.sleep(min(.5,max(0,end-time.monotonic())))
def chat(s,label):event(label);n['focus']();n['chat'](s)
def key(v,label):
 event(label);n['focus']();subprocess.run(['python3',n['WRAPPER'],n['j']['hwnd'],str(v)],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
with (W/'video-recorder.log').open('w') as log:
 rec=subprocess.Popen(['wf-recorder','-o','HDMI-A-1','-r','30','-c','libx264','-x','yuv420p','-p','preset=veryfast','-p','crf=20','-f',str(W/'dialogue-demo-raw.mp4')],stdout=log,stderr=subprocess.STDOUT)
 (W/'video-recorder-identity.json').write_text(json.dumps({'pid':rec.pid,'start':Path('/proc',str(rec.pid),'stat').read_text().split()[21]}))
 try:
  event('Inicio: HUD normal');hold(2)
  assert rec.poll() is None
  chat('-dialogo','Abrir panel');hold(11)
  key(39,'Interacción: completar texto');hold(20)
  key(39,'Interacción: siguiente página');hold(1)
  chat('-pausadialogo','Pausar escritura: retratos en Stand');hold(7)
  chat('-pausadialogo','Reanudar escritura: Talk');hold(9)
  key(39,'Completar página');hold(4)
  key(39,'Siguiente interlocutor');hold(4)
  chat('-caminardialogo','Movimiento con panel abierto');hold(8)
  chat('-parardialogo','Detener unidad');hold(3)
  chat('-cerrardialogo','Cerrar panel');hold(4)
  event('Fin');n['shot']('video-final')
 finally:
  if rec.poll() is None:rec.send_signal(signal.SIGINT)
  rec.wait(timeout=15)
 event('Grabador cerrado')
 print(json.dumps({'duration':time.monotonic()-start,'recorder_exit':rec.returncode,'events':events},ensure_ascii=False))
