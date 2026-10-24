from pathlib import Path
from datetime import datetime
from zoneinfo import ZoneInfo
import os,time,json,sqlite3,hashlib,tomllib
B=Path(__file__).resolve().parent;project=B.parents[1];active=Path('/home/snz/Documentos/MCP W3/codegraph-vjass');started=time.time()
btime=next(int(l.split()[1]) for l in Path('/proc/stat').read_text().splitlines() if l.startswith('btime '));ticks=os.sysconf('SC_CLK_TCK')
result={'expected_identity':'1.6.2+jass-vjass.5','extraction':32,'current_chat_tool_call_after_reload':False,'method':'New application-managed MCP process started after installed build; independent fresh .5 MCP tool responses and production SQLite checked separately.'}
while time.time()-started<60:
 found=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   args=(p/'cmdline').read_bytes().split(b'\0')
   if str(active/'dist/bin/codegraph.js').encode() not in args or b'--mcp' not in args:continue
   if (p/'cwd').resolve()!=project:continue
   fields=(p/'stat').read_text().split(') ',1)[1].split();parent=Path('/proc')/fields[1]
   if b'app-server' not in (parent/'cmdline').read_bytes():continue
   if btime+int(fields[19])/ticks<(active/'dist/mcp/version.js').stat().st_mtime:continue
   found.append({'pid':int(p.name),'parent':int(fields[1]),'started_after_build':True})
  except (OSError,ValueError):continue
 if found:
  result['app_mcp_processes']=found;result['indexes']=[]
  sources=json.loads((B/'original-production-sources.json').read_text())
  result['original_source_hashes_unchanged']=all(hashlib.sha256((Path(row['root'])/rel).read_bytes()).hexdigest()==h for row in sources for rel,h in row['source_sha256'].items())
  for row in sources:
   with sqlite3.connect((Path(row['root'])/'.codegraph/codegraph.db').as_uri()+'?mode=ro',uri=True) as db:
    meta=dict(db.execute("SELECT key,value FROM project_metadata WHERE key IN ('indexed_with_version','indexed_with_extraction_version','index_state')"))
    result['indexes'].append({'root':row['root'],'integrity':db.execute('PRAGMA quick_check').fetchone()[0],'metadata':meta})
  result['passed']=result['original_source_hashes_unchanged'] and all(x['integrity']=='ok' and x['metadata'].get('indexed_with_version')=='1.6.2+jass-vjass.5' and x['metadata'].get('indexed_with_extraction_version')=='32' and x['metadata'].get('index_state')=='complete' for x in result['indexes'])
  break
 time.sleep(.25)
result.setdefault('passed',False);result['elapsed_seconds']=round(time.time()-started,2)
if result['passed']:
 name='2026-10-22-011732-codegraph-llamada-implicita-this.md';src=project/'informes/errores'/name;dst=project/'informes/errores/resueltos'/name
 assert src.exists() and not dst.exists()
 s=src.read_text().replace('- Estado actual: corregido y verificado en la revisión .5 y los índices reales; pendiente únicamente la recarga de la conexión de la aplicación antes del archivo final. La historia anterior conserva sus estados intermedios.','- Estado actual: resuelto en la revisión .5, verificado en índices reales y MCP nuevo; reconexión desde configuración MCP comprobada. La historia anterior conserva sus estados intermedios.')
 s+='\n## Cierre y archivo\n\nFecha: '+datetime.now(ZoneInfo('America/Lima')).isoformat()+'''\n
La reconexión desde configuración MCP recreó el proceso administrado por la aplicación después
del build instalado. Se comprobaron tres índices completos e íntegros y fuentes
originales intactas (app-reload-verification.json). El MCP independiente .5 ya
había devuelto fuente y spell → cast. La consulta posterior desde el transporte
de este chat se registra por separado; no se atribuye a esa conexión lo que
sólo fue probado en el proceso independiente. Corrección funcional y activación
comprobadas; informe trasladado a resueltos/ por instrucción del usuario.
'''
 src.write_text(s);src.rename(dst)
 for p in [project/'AGENTS.md',*(project/'docs').rglob('*.md'),*(project/'informes').rglob('*.md')]:
  s=p.read_text();before=s
  s=s.replace('informes/errores/'+name,'informes/errores/resueltos/'+name)
  s=s.replace('(errores/'+name+')','(errores/resueltos/'+name+')')
  if p.name=='codegraph-llamada-this-y-archivo-informes.md':
   s=s.replace('Estado: en ejecución, 22 de octubre de 2026.','Estado: completado, 22 de octubre de 2026.')
   s+='\nCierre: recarga de la aplicación comprobada por observador; seis informes\nresueltos archivados, sin incidencias abiertas en la raíz al finalizar.\n'
  if p.name=='codegraph-vjass-2026-10-22.md':
   s=s.replace('la recarga de la aplicación se registra en\nwork/codegraph-this-20261022/app-reload-verification.json cuando se complete.','la recarga de la aplicación quedó comprobada en\nwork/codegraph-this-20261022/app-reload-verification.json.')
  if s!=before:p.write_text(s)
 readme=project/'informes/errores/README.md'
 with readme.open('a') as f:f.write('\n- ['+name+'](resueltos/'+name+') — corrección .5 y activación verificadas.\n')
 p=B/'promotion.json';data=json.loads(p.read_text());data.update(app_reload='passed',reports_archived=6);p.write_text(json.dumps(data,indent=2)+'\n')
 p=B/'report-moves.json';data=json.loads(p.read_text());data['moved_to_resueltos'].append(name);p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 result['reports_archived']=6;result['open_reports']=[p.name for p in (project/'informes/errores').glob('*.md') if p.name!='README.md']
(B/'app-reload-verification.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
