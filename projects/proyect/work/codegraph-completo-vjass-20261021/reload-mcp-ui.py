from pathlib import Path
import subprocess,time,tomllib,json,hashlib,traceback,datetime
B=Path(__file__).resolve().parent;config=Path('/home/snz/.codex/config.toml');states=[]
def value():
 try:return tomllib.loads(config.read_text()).get('mcp_servers',{}).get('codegraph',{}).get('enabled')
 except (OSError,tomllib.TOMLDecodeError):return None
def click():
 subprocess.run(['hyprctl','dispatch','hl.dsp.focus({window="address:0x55bb0733e500"})'],check=True)
 subprocess.run(['hyprctl','dispatch','hl.dsp.cursor.move({x=3375,y=409})'],check=True)
 subprocess.run(['ydotool','mousemove','--','0','1'],check=True);time.sleep(.25)
 subprocess.run(['ydotool','click','-D','100','0xC0'],check=True)
def wait(wanted):
 deadline=time.monotonic()+8
 while time.monotonic()<deadline:
  if value() is wanted:return
  time.sleep(.1)
 raise RuntimeError('MCP enabled did not become '+str(wanted))
try:
 assert value() is True
 click();wait(False);states.append({'enabled':False,'time':datetime.datetime.now().isoformat()});subprocess.run(['grim','-o','HDMI-A-1',str(B/'mcp-reload-off.png')],check=True)
 time.sleep(.5);click();wait(True);states.append({'enabled':True,'time':datetime.datetime.now().isoformat()});time.sleep(2);subprocess.run(['grim','-o','HDMI-A-1',str(B/'mcp-reload-on.png')],check=True)
 d=tomllib.loads(config.read_text());c=d.get('mcp_servers',{}).pop('codegraph',{});before=json.loads((B/'mcp-config-before.json').read_text());other=hashlib.sha256(json.dumps(d,sort_keys=True,default=str).encode()).hexdigest()
 result={'ui_toggle_completed':True,'states':states,'codegraph':c,'other_configuration_unchanged':other==before['other_config_sha256'],'current_chat_query':'pending'}
 (B/'mcp-reload-result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result),flush=True)
except BaseException:
 traceback.print_exc()
 # Never leave the user's CodeGraph disabled if the UI sequence is interrupted.
 if value() is False:
  s=config.read_text();start=s.index('[mcp_servers.codegraph]');end=s.find('\n[',start+1);end=len(s) if end<0 else end;section=s[start:end]
  import re
  section,n=re.subn(r'(?m)^enabled\s*=\s*false\s*$', 'enabled = true',section);assert n==1
  config.write_text(s[:start]+section+s[end:]);print('Fallback restored only codegraph.enabled=true; UI/client verification still required',flush=True)
 raise
