"""Lanza lanzar.bat en el prefijo de YDWE con el entorno grafico comprobado (argumento: ruta del bat)."""
import importlib.util
import os
from pathlib import Path
import subprocess
import sys

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
# RASTREO=carpeta: tiempo de cada cuadro y muestras del proceso.
rastreo = os.environ.get('RASTREO')
if rastreo:
    capa = Path(__file__).resolve().parent.parent / 'rastreo'
    env['VK_ADD_LAYER_PATH'] = str(capa)
    env['VK_INSTANCE_LAYERS'] = 'VK_LAYER_WDEV_cuadros'
    env['WC3_CUADROS'] = rastreo + '/cuadros.txt'
    subprocess.Popen([sys.executable, '-I', str(capa / 'rastreador.py'), rastreo])
bat = 'Z:' + sys.argv[1].replace('/', '\\')
sys.exit(subprocess.run([str(config.SLR), '--verb=run', '--', str(config.PROTON), 'run', 'cmd', '/c', bat],
                        env=env, cwd=config.DATA / 'pfx/drive_c/WarcraftIII').returncode)
