"""Lanza lanzar.bat en el prefijo de YDWE con el entorno grafico comprobado (argumento: ruta del bat)."""
import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path('/home/snz/Documentos/ChatGPT/FrozenThone')
sys.path.insert(0, str(ROOT / 'scripts'))
spec = importlib.util.spec_from_file_location('ydwe_runtime', ROOT / 'scripts/newgen-moderno.py')
config = importlib.util.module_from_spec(spec)
spec.loader.exec_module(config)
config.DATA = ROOT / 'runtime/proton-ydwe-modern'
from compartido import prepare
prepare()
env = config.environment()
log = ROOT / 'runtime/logs/modern-ydwe'
log.mkdir(parents=True, exist_ok=True)
env['DXVK_LOG_PATH'] = str(log)
capa = Path(__file__).resolve().parent.parent / 'rastreo'
sys.path.insert(0, str(capa))
from preflight import trace_game, wait_detached_game

bat_path = Path(sys.argv[1]).resolve(strict=True)
requested = os.environ.get('RASTREO')
rastreo = Path(requested) if requested else Path(tempfile.mkdtemp(prefix='rastreo-', dir=bat_path.parent))
bat = 'Z:' + str(bat_path).replace('/', '\\')
command = [str(config.SLR), '--verb=run', '--', str(config.PROTON), 'run', 'cmd', '/c', bat]
with trace_game(env, rastreo) as traced_env:
    status = subprocess.run(command, env=traced_env, cwd=config.DATA / 'pfx/drive_c/WarcraftIII').returncode
    if status == 0 and '/wait' not in bat_path.read_bytes().lower().decode('latin-1'):
        wait_detached_game(traced_env)
    sys.exit(status)
