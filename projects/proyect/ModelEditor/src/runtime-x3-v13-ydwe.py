"""Attempt the observed YDWE single_test launch path in a private prefix."""
from pathlib import Path
import importlib.util,subprocess,sys,json,hashlib,shutil,re,os
ROOT=Path(__file__).resolve().parents[1];FROZEN=Path('/home/snz/Documentos/ChatGPT/FrozenThone');PROFILE=ROOT/'build/x3-v13-ydwe-runtime';EV=ROOT/'evidence/x3-v13'
spec=importlib.util.spec_from_file_location('ydwe_model_runtime',FROZEN/'scripts/ydwe-moderno.py');ydwe=importlib.util.module_from_spec(spec);spec.loader.exec_module(ydwe);base=ydwe.DATA
if not (PROFILE/'pfx').exists():
 PROFILE.mkdir(exist_ok=True);subprocess.run(['cp','-a','--reflink=always',str(base/'pfx'),str(PROFILE/'pfx')],check=True)
 for p in base.iterdir():
  if p.is_file() and p.name!='pfx.lock':shutil.copy2(p,PROFILE/p.name)
ydwe.DATA=PROFILE;modern=ydwe.runtime();env=modern.environment();env['DXVK_LOG_PATH']=str(EV/'ydwe-logs');(EV/'ydwe-logs').mkdir(exist_ok=True)
if len(sys.argv)>1 and sys.argv[1]=='ui':
 env.update(WINEPREFIX=str(PROFILE/'pfx'),WINEESYNC='0',WINEFSYNC='0',WINENTSYNC='0');helper=FROZEN/'work/two-candidate-tests-20261018/window_probe.exe';win='Z:'+str(helper).replace('/','\\');raise SystemExit(subprocess.run([str(modern.SLR),'--verb=run','--',str(modern.PROTON.parent/'files/bin/wine'),win,*sys.argv[2:]],env=env).returncode)
assert not ydwe.session_open(),'Owned YDWE profile already active'
game=PROFILE/'pfx/drive_c/WarcraftIII';editor=PROFILE/'pfx/drive_c/Tools/YDWE';assert not game.is_symlink() and not editor.is_symlink()
config=editor/'bin/EverConfig.cfg';source=base/'pfx/drive_c/Tools/YDWE/bin/EverConfig.cfg';assert config.resolve().is_relative_to(PROFILE);before=source.read_bytes();assert not os.path.samefile(config,source)
text=config.read_text();assert re.search(r'^EnableHost\s*=\s*[01]\s*$',text,re.M);text=re.sub(r'^EnableHost\s*=\s*[01]\s*$', 'EnableHost = 0',text,count=1,flags=re.M);config.write_text(text);assert source.read_bytes()==before;assert re.search(r'^EnableHost\s*=\s*0\s*$',config.read_text(),re.M)
fixture=json.loads((EV/'fixture.json').read_text());path=Path(fixture['map']);data=path.read_bytes();digest=hashlib.sha256(data).hexdigest();assert digest==fixture['sha256'];stage=game/'Maps/CodexTest'/('X3V13-'+digest[:12]+'.w3x');stage.parent.mkdir(exist_ok=True,parents=True);assert stage.parent.resolve().is_relative_to(PROFILE);stage.write_bytes(data)
command=[str(modern.SLR),'--verb=run','--',str(modern.PROTON),'runinprefix',r'C:\Tools\YDWE\YDWE.exe','-war3','-loadfile','Maps\\CodexTest\\'+stage.name]
manifest={'mode':'YDWE single_test branch: one player, EnableHost=0, no -auto and no host','prefix':str(PROFILE/'pfx'),'map':str(stage),'sha256':digest,'command':command,'sourceConfigUnchanged':hashlib.sha256(before).hexdigest(),'privateConfig':hashlib.sha256(config.read_bytes()).hexdigest(),'binaryHashes':{n:hashlib.sha256((game/n).read_bytes()).hexdigest() for n in ['war3.exe','d3d8.dll','d3d9.dll']}}
(EV/'launch-ydwe.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps(manifest),flush=True)
with (EV/'ydwe-launch.log').open('w') as log:code=subprocess.run(command,cwd=game,env=env,stdout=log,stderr=log).returncode
(EV/'ydwe-exit.json').write_text(json.dumps({'returnCode':code,'prefix':str(PROFILE/'pfx')})+'\n');raise SystemExit(code)
