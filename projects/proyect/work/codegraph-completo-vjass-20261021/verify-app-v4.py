from pathlib import Path
import os,time,json,sqlite3,hashlib
B=Path(__file__).resolve().parent;project=B.parents[1];build=Path('/home/snz/Documentos/MCP W3/codegraph-vjass/dist/mcp/tools.js');started=time.time()
btime=next(int(l.split()[1]) for l in Path('/proc/stat').read_text().splitlines() if l.startswith('btime '));ticks=os.sysconf('SC_CLK_TCK');result={'expected_identity':'1.6.2+jass-vjass.4','current_chat_tool_call_after_reload':False}
while time.time()-started<60:
 found=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   args=(p/'cmdline').read_bytes().split(b'\0')
   if b'/home/snz/Documentos/MCP W3/codegraph-vjass/dist/bin/codegraph.js' not in args or b'--mcp' not in args:continue
   if (p/'cwd').resolve()!=project:continue
   fields=(p/'stat').read_text().split(') ',1)[1].split();parent=Path('/proc')/fields[1]
   if b'app-server' not in (parent/'cmdline').read_bytes():continue
   if btime+int(fields[19])/ticks<build.stat().st_mtime:continue
   found.append({'pid':int(p.name),'parent':int(fields[1]),'started_after_build':True})
  except (OSError,ValueError):continue
 if found:
  result['app_mcp_processes']=found;result['indexes']=[]
  sources=json.loads((B/'production-rebuild-results.json').read_text());result['source_hashes_unchanged']=all(hashlib.sha256((Path(r['root'])/f).read_bytes()).hexdigest()==h for r in sources for f,h in r['source_sha256'].items())
  for r in sources:
   with sqlite3.connect((Path(r['root'])/'.codegraph/codegraph.db').as_uri()+'?mode=ro',uri=True) as d:result['indexes'].append({'root':r['root'],'integrity':d.execute('pragma quick_check').fetchone()[0],'metadata':dict(d.execute("select key,value from project_metadata where key in ('indexed_with_version','indexed_with_extraction_version','index_state')"))})
  result['passed']=result['source_hashes_unchanged'] and all(x['integrity']=='ok' and x['metadata'].get('indexed_with_version')=='1.6.2+jass-vjass.4' and x['metadata'].get('indexed_with_extraction_version')=='31' for x in result['indexes']);break
 time.sleep(.25)
result.setdefault('passed',False);result['elapsed_seconds']=round(time.time()-started,2);(B/'app-reload-v4-verification.json').write_text(json.dumps(result,indent=2));print(json.dumps(result),flush=True)
