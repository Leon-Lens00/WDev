"""Run a tool in the existing NewGen profile; no app/profile configuration changes."""
from pathlib import Path
import importlib,sys,subprocess
root=Path('/home/snz/Documentos/ChatGPT/FrozenThone')
sys.path.insert(0,str(root/'scripts'));c=importlib.import_module('newgen-moderno')
e=c.environment();e.update(WINEPREFIX=str(c.DATA/'pfx'),WINEESYNC='0',WINEFSYNC='0',WINENTSYNC='0')
args=sys.argv[1:]
subprocess.run([str(c.SLR),'--verb=run','--',str(c.PROTON.parent/'files/bin/wine'),*args],env=e,check=True)
