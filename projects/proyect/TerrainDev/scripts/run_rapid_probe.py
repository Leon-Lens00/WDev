#!/usr/bin/env python3
"""Run one fresh Classic laboratory, preserve identity, evidence and leave UI open."""
from pathlib import Path
import hashlib,json,subprocess,sys,time
r=Path(__file__).resolve().parents[1]
i=json.loads((r/'reports/current-rapid-test.json').read_text());d=Path(i['directory'])
envroot=Path('/home/snz/Documentos/ChatGPT/FrozenThone')
prefix=str(envroot/'runtime/proton-newgen-modern-test/pfx')
assert hashlib.sha256(Path(i['map']).read_bytes()).hexdigest()==i['map_sha256']
before=json.loads(subprocess.check_output(['hyprctl','-j','clients']))
for w in before:
    if w['title']=='Warcraft III':
        proc=Path('/proc')/str(w['pid'])
        pre=next(v.decode() for v in (proc/'environ').read_bytes().split(b'\0') if v.startswith(b'WINEPREFIX='))
        assert pre.rstrip('/')!='WINEPREFIX='+prefix, 'Preserve existing game in this profile'
assert not Path(i['log']).exists()
(d/'clients-before.json').write_text(json.dumps(before,indent=2))
start=time.time_ns()
p=subprocess.Popen([sys.executable,str(envroot/'scripts/wc3.py'),'play',i['map']],stdout=(d/'launcher.log').open('w'),stderr=subprocess.STDOUT)
(d/'launch-time.json').write_text(json.dumps(dict(time_ns=start,launcher_pid=p.pid)))
owner=None
end=time.monotonic()+160
while time.monotonic()<end:
    clients=json.loads(subprocess.check_output(['hyprctl','-j','clients']))
    matches=[x for x in clients if x['title']=='Warcraft III' and x['pid'] not in {b['pid'] for b in before}]
    if owner is None and len(matches)==1:
        w=matches[0];proc=Path('/proc')/str(w['pid'])
        command=(proc/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
        pre=next(x.decode() for x in (proc/'environ').read_bytes().split(b'\0') if x.startswith(b'WINEPREFIX='))
        assert pre.rstrip('/')=='WINEPREFIX='+prefix and i['map_sha256'][:16] in command
        owner=dict(pid=w['pid'],start=(proc/'stat').read_text().rsplit(')',1)[1].split()[19],prefix=pre,command=command,window=w)
        (d/'identity.json').write_text(json.dumps(owner,indent=2))
        subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{w["address"]}"}})'],capture_output=True,check=True)
        active=json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))
        assert active['pid']==owner['pid']
        subprocess.run(['hyprctl','dispatch','hl.dsp.window.move({workspace="11",follow=true})'],capture_output=True,check=True)
    log=Path(i['log'])
    if log.exists():
        assert log.stat().st_mtime_ns>=start
        raw=log.read_text(errors='replace')
        if f'RAPID {i["run"]} COMPLETE' in raw:
            (d/'engine-result.txt').write_bytes(log.read_bytes())
            print(raw,flush=True)
            assert owner is not None
            w=next(x for x in clients if x['pid']==owner['pid'])
            monitors=json.loads(subprocess.check_output(['hyprctl','-j','monitors']))
            mon=next(m for m in monitors if m['id']==w['monitor'])
            subprocess.run(['grim','-o',mon['name'],str(d/'complete.png')],check=True)
            sys.exit(0)
    time.sleep(.25)
raise TimeoutError('No fresh complete log; inspect UI and progress')
