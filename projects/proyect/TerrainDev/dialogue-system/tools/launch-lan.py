#!/usr/bin/env python3
"""Stage the current validated dialogue map, launch isolated LAN menu (create host visually)."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,subprocess,sys,datetime
ROOT=Path(__file__).resolve().parents[1]
ENV=Path('/home/snz/Documentos/ChatGPT/FrozenThone')
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--dry-run',action='store_true');args=parser.parse_args()
 build=json.loads((ROOT/'latest-build.json').read_text());source=Path(build['map']);data=source.read_bytes();digest=hashlib.sha256(data).hexdigest()
 assert build['compiled'] and build['pjass'] and digest==build['sha256'],'Current map must match validated build'
 runtime=ROOT/'runtime-lan';prefix=runtime/'pfx';template=ROOT.parent/'inventory-integration/runtime-isolated'
 for proc in Path('/proc').glob('[0-9]*'):
  try:
   cmd=(proc/'cmdline').read_bytes().replace(b'\\',b'/').lower();own=any(v.rstrip(b'/')==('WINEPREFIX='+str(prefix)).encode() for v in (proc/'environ').read_bytes().split(b'\0'))
   if own and any(name in cmd for name in [b'war3.exe',b'worldedit.exe',b'worldedit121.exe']):parser.error('The isolated LAN profile is occupied; preserve its session.')
  except OSError:pass
 spec=importlib.util.spec_from_file_location('modern',ENV/'scripts/newgen-moderno.py');modern=importlib.util.module_from_spec(spec);spec.loader.exec_module(modern);modern.DATA=runtime
 game=prefix/'drive_c/WarcraftIII';staged=game/'Maps/CodexTest'/f'{digest[:16]}.w3x'
 command=[str(modern.SLR),'--verb=run','--',str(modern.PROTON),'runinprefix',r'C:\WarcraftIII\war3.exe','-window']
 metadata={'map_sha256':digest,'map':str(source),'staged':str(staged),'profile':str(runtime),'port':6218,'command':command,'mode':'LAN menu; host not yet created'}
 if args.dry_run:print(json.dumps(metadata,indent=2));return 0
 if not prefix.exists():
  runtime.mkdir(exist_ok=True);subprocess.run(['cp','-a','--reflink=auto',str(template)+'/.',str(runtime)],check=True)
 for file in [game/'war3.exe',game/'d3d9.dll',modern.SLR,modern.PROTON]:assert file.is_file(),file
 # Private profile only: unique LAN listen port, no shared/global registry changes.
 registry=prefix/'user.reg';text=registry.read_text();import re
 text,count=re.subn(r'"netgameport"=dword:[0-9a-fA-F]+','"netgameport"=dword:0000184a',text)
 assert count==1,'Expected one netgameport setting in private profile';registry.write_text(text)
 staged.parent.mkdir(exist_ok=True);staged.write_bytes(data)
 work=ROOT/'evidence'/('lan-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S'));work.mkdir()
 (work/'launch.json').write_text(json.dumps(metadata,indent=2));print(json.dumps({'evidence':str(work),**metadata},indent=2),flush=True)
 with (work/'runtime.log').open('w') as log:return subprocess.run(command,cwd=game,env=modern.environment(),stdout=log,stderr=log).returncode
if __name__=='__main__':sys.exit(main())
