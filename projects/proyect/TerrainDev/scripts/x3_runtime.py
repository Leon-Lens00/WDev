"""Scoped Proton copy and HWND input for this model test; no shared launcher edits."""
from pathlib import Path
import sys, importlib.util, subprocess, json, hashlib, shutil, os

ROOT=Path(__file__).resolve().parents[1]
FROZEN=Path('/home/snz/Documentos/ChatGPT/FrozenThone')
PROFILE=ROOT/'build/x3-runtime'
EVIDENCE=Path(json.loads((ROOT/'reports/current-x3.json').read_text())['directory'])
spec=importlib.util.spec_from_file_location('model_test_modern',FROZEN/'scripts/newgen-moderno.py')
modern=importlib.util.module_from_spec(spec);spec.loader.exec_module(modern)
BASE=modern.DATA

def prepare():
    if not (PROFILE/'pfx').exists():
        assert BASE.stat().st_dev==PROFILE.parent.stat().st_dev,'Reflink source must be on the same filesystem'
        PROFILE.mkdir(exist_ok=True)
        subprocess.run(['cp','-a','--reflink=always',str(BASE/'pfx'),str(PROFILE/'pfx')],check=True)
        for p in BASE.iterdir():
            if p.is_file() and p.name!='pfx.lock':shutil.copy2(p,PROFILE/p.name)
        for name in ['war3.exe','d3d8.dll','d3d9.dll']:
            a=BASE/'pfx/drive_c/WarcraftIII'/name;b=PROFILE/'pfx/drive_c/WarcraftIII'/name
            assert hashlib.sha256(a.read_bytes()).digest()==hashlib.sha256(b.read_bytes()).digest(),name
        (EVIDENCE/'runtime-copy.json').write_text(json.dumps({'base':str(BASE),'isolated':str(PROFILE),'copy':'Btrfs reflink with independent writable files','binaryHashes':'PASS'},indent=2)+'\n')
    modern.DATA=PROFILE
    env=modern.environment()
    log=PROFILE/'logs';log.mkdir(exist_ok=True)
    env['DXVK_LOG_PATH']=str(log)
    return env

env=prepare()
if len(sys.argv)>1 and sys.argv[1]=='ui':
    env.update(WINEPREFIX=str(PROFILE/'pfx'),WINEESYNC='0',WINEFSYNC='0',WINENTSYNC='0')
    helper=FROZEN/'work/two-candidate-tests-20261018/window_probe.exe'
    assert helper.is_file()
    winpath='Z:'+str(helper).replace('/','\\')
    raise SystemExit(subprocess.run([str(modern.SLR),'--verb=run','--',str(modern.PROTON.parent/'files/bin/wine'),winpath,*sys.argv[2:]],env=env).returncode)
if modern.session_open():raise RuntimeError('This isolated profile already has an active game/editor')
fixture_path=Path(sys.argv[1]).resolve() if len(sys.argv)>1 else EVIDENCE/'fixture.json'
fixture=json.loads(fixture_path.read_text())
EVIDENCE=fixture_path.parent
source=Path(fixture['map']);data=source.read_bytes();digest=hashlib.sha256(data).hexdigest();assert digest==fixture['sha256']
game=PROFILE/'pfx/drive_c/WarcraftIII'
staged=game/'Maps/CodexTest'/(digest[:16]+'.w3x');staged.parent.mkdir(parents=True,exist_ok=True)
if staged.exists():assert staged.read_bytes()==data
else:staged.write_bytes(data)
command=[str(modern.SLR),'--verb=run','--',str(modern.PROTON),'runinprefix',r'C:\WarcraftIII\war3.exe','-loadfile','Maps\\CodexTest\\'+staged.name,'-window']
(EVIDENCE/'launch-isolated.json').write_text(json.dumps({'source':str(source),'sha256':digest,'staged':str(staged),'prefix':str(PROFILE/'pfx'),'command':command},indent=2)+'\n')
print(json.dumps({'launching':str(staged),'prefix':str(PROFILE/'pfx')}),flush=True)
with (EVIDENCE/'runtime-isolated.log').open('w') as log:
    code=subprocess.run(command,cwd=game,env=env,stdout=log,stderr=log).returncode
(EVIDENCE/'exit.json').write_text(json.dumps({'returnCode':code,'prefix':str(PROFILE/'pfx')})+'\n')
raise SystemExit(code)
