"""Run MesenCE's real SNES core with all writable paths inside this lab."""
from pathlib import Path
import argparse,json,os,subprocess,hashlib,time,re
LAB=Path(__file__).resolve().parents[1]

def run_lab(variant: str, scenario: str, name: str, timeout: int=40, facing: str="right", gap: int=12):
    assert re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]{0,80}',name), 'Use a simple run name inside the lab'
    assert scenario in ('prepare_scene','trace')
    run=LAB/'runs'/name
    run.mkdir(exist_ok=False)
    rom=LAB/'analysis/static-20261023-134543/private'/('original.sfc' if variant=='original' else 'zero-project-v4.1.sfc')
    script=LAB/'scripts'/(scenario+'.lua')
    assert rom.is_file() and script.is_file()
    exe=LAB/'runtime/Mesen'
    (LAB/'runtime/settings.json').write_text(json.dumps({'Snes':{'Port1':{'Type':'SnesController'}},'Debug':{'ScriptWindow':{'AllowIoOsAccess':True,'AllowNetworkAccess':False,'ScriptTimeout':10}}}))
    for sub in ['tmp','profile/config','profile/cache','profile/data','profile/state']:(LAB/'runtime'/sub).mkdir(parents=True,exist_ok=True)
    env=os.environ.copy()
    env.update({'TMPDIR':str(LAB/'runtime/tmp'),'XDG_CONFIG_HOME':str(LAB/'runtime/profile/config'),'XDG_CACHE_HOME':str(LAB/'runtime/profile/cache'),'XDG_DATA_HOME':str(LAB/'runtime/profile/data'),'XDG_STATE_HOME':str(LAB/'runtime/profile/state'),'PYTHONDONTWRITEBYTECODE':'1'})
    conf={'out':str(run),'variant':variant,'lab':str(LAB),'facing':facing,'gap':gap,'state':str(LAB/'runs'/('ready-original-fixed' if variant=='original' else 'ready-mod')/'ready.mss')}
    snapshot=run/'scenario.lua'
    snapshot.write_bytes(script.read_bytes())
    driver=run/'driver.lua'
    driver.write_text('LAB_CONFIG = { '+', '.join(k+' = '+json.dumps(v) for k,v in conf.items())+' }\ndofile('+json.dumps(str(snapshot))+')\n')
    cmd=[str(exe),'--testRunner','--timeout='+str(timeout),str(driver),str(rom)]
    start=time.time()
    with (run/'console.txt').open('w') as log:
        proc=subprocess.Popen(cmd,cwd=LAB,env=env,stdout=log,stderr=subprocess.STDOUT)
        identity={'pid':proc.pid,'proc_start':Path(f'/proc/{proc.pid}/stat').read_text().split()[21],'exe':str(exe),'rom_sha256':hashlib.sha256(rom.read_bytes()).hexdigest(),'cmd':cmd,'scenario_sha256':hashlib.sha256(snapshot.read_bytes()).hexdigest(),'launcher_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'parameters':conf}
        (run/'process.json').write_text(json.dumps(identity,indent=2))
        try:code=proc.wait(timeout=timeout+15)
        except subprocess.TimeoutExpired:
            proc.terminate()
            try:proc.wait(timeout=5)
            except subprocess.TimeoutExpired:proc.kill();proc.wait()
            code=proc.returncode
    result={'returncode':code,'wall_seconds':time.time()-start,'own_process_closed':not Path(f'/proc/{proc.pid}').exists(),'rom_sha256':identity['rom_sha256']}
    (run/'process-result.json').write_text(json.dumps(result,indent=2))
    print(run);print(json.dumps(result))
    return code

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('variant',choices=['original','mod']);p.add_argument('scenario');p.add_argument('name');p.add_argument('--timeout',type=int,default=40);p.add_argument('--facing',choices=['right','left'],default='right');p.add_argument('--gap',type=int,default=12)
    a=p.parse_args();raise SystemExit(run_lab(a.variant,a.scenario,a.name,a.timeout,a.facing,a.gap))
