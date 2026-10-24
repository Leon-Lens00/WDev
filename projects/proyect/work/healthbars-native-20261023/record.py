import sys,runpy,subprocess,time,signal,json
from pathlib import Path
W=Path(__file__).parent;sys.argv=['control.py','noop'];c=runpy.run_path(str(W/'control.py'));events=[];start=time.monotonic()
def event(s):events.append({'seconds':round(time.monotonic()-start,2),'event':s});(W/'record-events.json').write_text(json.dumps(events,indent=2))
def hold(seconds):
 end=time.monotonic()+seconds
 while time.monotonic()<end:c['focus']();time.sleep(.2)
def chat(s):event(s);c['chat'](s)
with (W/'recorder.log').open('w') as log:
 p=subprocess.Popen(['wf-recorder','-o','HDMI-A-1','-r','30','-c','libx264','-x','yuv420p','-p','preset=veryfast','-p','crf=19','-f',str(W/'barras-horizontales-prueba.mp4')],stdout=log,stderr=subprocess.STDOUT)
 try:
  c['focus']();hold(1);c['shot']('final-full')
  chat('-misiles');c['shot']('final-diagnostics-visible');chat('-misiles');c['shot']('final-diagnostics-hidden')
  chat('-vidaheroe 75');chat('-vidaenemigo 86');hold(1);c['shot']('final-normal')
  chat('-vidaheroe 10');chat('-vidaenemigo 15');hold(1);c['shot']('final-critical')
  chat('-barrasobjetivopaladin');hold(1);c['shot']('final-paladin-icon');chat('-barrasobjetivotauren')
  chat('-vidaheroe 75');chat('-vidaenemigo 86');chat('-patrullardialogo');chat('-dialogo');hold(3);c['shot']('final-dialogue-moving-a');hold(2);c['shot']('final-dialogue-moving-b')
  chat('-pausadialogo');hold(1);chat('-pausadialogo');chat('-cerrardialogo');hold(2);c['shot']('final-closed-moving')
  chat('-barrasocultar');hold(1);c['shot']('final-hidden');chat('-barrasmostrar');chat('-vidaenemigo 0');hold(1);c['shot']('final-enemy-zero')
  event('Finished');hold(1)
 finally:
  p.send_signal(signal.SIGINT);p.wait(timeout=15)
print('Recording complete',flush=True)
