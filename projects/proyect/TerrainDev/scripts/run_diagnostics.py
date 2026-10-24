#!/usr/bin/env python3
"""Run the prepared single-client laboratory in this PC's existing WC3 profile."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
ENVROOT = Path('/home/snz/Documentos/ChatGPT/FrozenThone')
PREFIX = str(ENVROOT/'runtime/proton-newgen-modern-test/pfx')
HELPER = ENVROOT/'work/two-candidate-tests-20261018/wine_ui_newgen.py'
info = json.loads((ROOT/'reports/latest-game-test.json').read_text())
d = Path(info['directory'])
assert 'diagnostics_logs' in info, 'Prepare with --diagnostics first'
assert hashlib.sha256(Path(info['map']).read_bytes()).hexdigest() == info['map_sha256']
assert all(not Path(p).exists() for p in [*info['logs'].values(),*info['diagnostics_logs'].values()])


def identity(pid):
    proc = Path('/proc')/str(pid)
    prefix = next((x.decode() for x in (proc/'environ').read_bytes().split(b'\0') if x.startswith(b'WINEPREFIX=')), '')
    return {'pid':pid,'prefix':prefix.rstrip('/'),'start':(proc/'stat').read_text().rsplit(')',1)[1].split()[19],
            'command':(proc/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')}


def wait_for(condition, timeout=120):
    end = time.monotonic()+timeout
    while time.monotonic()<end:
        result = condition()
        if result:
            return result
        time.sleep(.25)
    raise TimeoutError('Laboratory condition did not complete')


def clients():
    return json.loads(subprocess.check_output(['hyprctl','-j','clients']))


before = clients()
(d/'clients-before.json').write_text(json.dumps(before,indent=2))
for p in Path('/proc').glob('[0-9]*'):
    try:
        command = (p/'cmdline').read_bytes().split(b'\0')[0].decode(errors='replace').replace('\\','/').rsplit('/',1)[-1].lower()
        if command in ('war3.exe','worldedit.exe','exehack.exe'):
            assert identity(int(p.name))['prefix'] != 'WINEPREFIX='+PREFIX, 'Preserve the existing session in this profile'
    except OSError:
        pass
start = time.time_ns()
launch = subprocess.Popen([sys.executable,str(ENVROOT/'scripts/wc3.py'),'play',info['map']],
                          stdout=(d/'launcher.log').open('w'),stderr=subprocess.STDOUT)
(d/'launch-time.json').write_text(json.dumps({'time_ns':start,'launcher_pid':launch.pid},indent=2))
old_pids = {x['pid'] for x in before}


def find_game():
    hits = [x for x in clients() if x['pid'] not in old_pids and x['title']=='Warcraft III']
    if len(hits)==1:
        return hits[0]
    return None


window = wait_for(find_game)
owner = identity(window['pid'])
assert owner['prefix']=='WINEPREFIX='+PREFIX
assert info['map_sha256'][:16] in owner['command'], 'Wrong staged map in the new game'
(d/'identity.json').write_text(json.dumps(owner,indent=2))
(d/'game-window.json').write_text(json.dumps(window,indent=2))
subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{window["address"]}"}})'],capture_output=True,check=True)
assert json.loads(subprocess.check_output(['hyprctl','-j','activewindow']))['pid']==owner['pid']
subprocess.run(['hyprctl','dispatch','hl.dsp.window.move({workspace="11",follow=true})'],capture_output=True,check=True)


def ui(*args):
    assert identity(owner['pid'])==owner, 'Game ownership changed'
    return subprocess.check_output([sys.executable,str(HELPER),*args],stderr=subprocess.STDOUT).decode(errors='replace')


listing = ui()
(d/'windows.txt').write_text(listing)
handles = re.findall(r'^([0-9A-Fa-f]+) pid=\d+ Warcraft III\s*$',listing,re.MULTILINE)
assert len(handles)==1
hwnd = handles[0]


def command(text):
    ui(hwnd,'13')
    ui(hwnd,'text',text)
    ui(hwnd,'13')


def stage(name):
    p = Path(info['diagnostics_logs'][name])
    wait_for(p.exists)
    raw = p.read_text(errors='replace')
    assert f'DIAGNOSTICS {info["run"]} {name}' in raw and 'probeFailures=0' in raw,raw
    print('Stage verified:',name,flush=True)


def capture(name):
    match = [x for x in clients() if x['pid']==owner['pid'] and x['title']=='Warcraft III']
    assert len(match)==1
    current = match[0]
    monitors = json.loads(subprocess.check_output(['hyprctl','-j','monitors']))
    monitor = next(x for x in monitors if x['id']==current['monitor'])
    subprocess.run(['hyprctl','dispatch',f'hl.dsp.focus({{window="address:{current["address"]}"}})'],check=True,capture_output=True)
    time.sleep(.2)
    subprocess.run(['grim','-o',monitor['name'],str(d/f'{name}.png')],check=True)


stage('idle')
stage('normal')
capture('normal')
subprocess.run([sys.executable,str(ROOT/'scripts/verify_probe.py')],check=True,stdout=(d/'flight-evaluation.txt').open('w'))
command('-diag-diferido')
stage('deferred')
stage('deferred-done')
command('-diag-negativo')
stage('overdue')
capture('overdue')
command('-diag-recuperar')
stage('recovered')
capture('recovered')
command('-misiles')
command('-diag-oculto')
stage('hidden')
command('-misiles')
command('-diag-visible')
stage('visible')
command('-diag-invalido')
stage('invalid')
subprocess.run([sys.executable,str(ROOT/'scripts/verify_diagnostics.py')],check=True,stdout=(d/'diagnostics-evaluation.txt').open('w'))
print('All diagnostics stages passed; close the identified own game with the preferred confirmation flow. Evidence:',d,flush=True)
