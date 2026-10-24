from pathlib import Path
import sys,runpy,subprocess,time,signal,json
W=Path(__file__).parent;sys.argv=['control.py','noop'];c=runpy.run_path(str(W/'control.py'));events=[];start=time.monotonic()
def event(s):events.append({'seconds':round(time.monotonic()-start,2),'event':s});(W/'record-events.json').write_text(json.dumps(events,indent=2))
def hold(seconds):
 end=time.monotonic()+seconds
 while time.monotonic()<end:c['focus']();time.sleep(.2)
def chat(s):event(s);c['chat'](s)
with (W/'recorder.log').open('w') as log:
 p=subprocess.Popen(['wf-recorder','-o','HDMI-A-1','-r','30','-c','libx264','-x','yuv420p','-p','preset=veryfast','-p','crf=19','-f',str(W/'barras-control-compartido.mp4')],stdout=log,stderr=subprocess.STDOUT)
 try:
  chat('-barrasmostrar');chat('-vidaheroe 75');chat('-vidaenemigo 86');hold(1);c['shot']('final-normal')
  c['focus']();c['dispatch']('hl.dsp.cursor.move({x=2660,y=300})');time.sleep(.3);event('Native player right-click movement');subprocess.run(['ydotool','click','-D','150','0xC1'],check=True);hold(2);c['shot']('final-native-move');chat('-dialogodiag')
  chat('-patrullardialogo');chat('-dialogo');hold(4);c['shot']('final-dialogue-moving');hold(2);chat('-cerrardialogo');hold(2);c['shot']('final-dialogue-closed')
  chat('-vidaheroe 10');chat('-vidaenemigo 15');hold(1);c['shot']('final-critical')
  chat('-barrasobjetivopaladin');hold(1);c['shot']('final-paladin-icon');chat('-barrasobjetivotauren')
  chat('-vidaheroe 75');chat('-vidaenemigo 86');hold(1);c['shot']('final-final-normal')
  chat('-vidaenemigo 0');hold(1);c['shot']('final-enemy-zero');chat('-dialogodiag');event('Finished');hold(1)
 finally:p.send_signal(signal.SIGINT);p.wait(timeout=15)
print('Shared-control video complete')
