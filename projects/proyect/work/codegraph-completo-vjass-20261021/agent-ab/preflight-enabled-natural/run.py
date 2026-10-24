import json, subprocess, time, os, hashlib, statistics
from pathlib import Path
B=Path(__file__).resolve().parents[1]; OUT=B/'agent-ab'; OUT.mkdir(exist_ok=True)
G=json.loads((B/'corpus-flow-goldens.json').read_text())
NODE='/home/snz/.local/share/codegraph-vjass/runtime/node'
BIN=B/'checkout/dist/bin/codegraph.js'
results=[]
# A fresh session per cell; alternating order controls first-run/cache effects.
for repetition in range(2):
 for repo in G:
  root=B/'corpus-runs'/repo['name']
  for i,names in enumerate(repo['flows']):
   prompt=('Read-only repository investigation. Explain the exact call chain connecting '+ ' -> '.join(names)+'. Identify the actual intermediate wiring and conditions, and cite file:line source evidence. Use available tools; source returned by a tool counts as already read. Do not edit files or execute project code. Do not inspect .codegraph, SQLite databases, benchmark files or other repositories, and do not invoke the CodeGraph CLI. Keep the final answer under 180 words. State any uncertainty rather than guessing.')
   for arm in (['with','without'] if (repetition+i)%2==0 else ['without','with']):
    stem=f"{repo['name']}-{i+1}-r{repetition+1}-{arm}"
    report=OUT/(stem+'.json')
    if report.exists():
     results.append(json.loads(report.read_text())); continue
    args=['/usr/lib/chatgpt/resources/codex','exec','--ignore-user-config','--ephemeral','--json','--sandbox','read-only','--skip-git-repo-check','--cd',str(root),'-c','model="gpt-6.1-sol"','-c','model_reasoning_effort="high"','-c','approval_policy="never"','-c','project_doc_max_bytes=0','--output-last-message',str(OUT/(stem+'.answer.txt'))]
    if arm=='with':
     args+=['-c','mcp_servers.codegraph.enabled=true','-c','mcp_servers.codegraph.command='+json.dumps(NODE),'-c','mcp_servers.codegraph.args='+json.dumps(['--liftoff-only','--disable-warning=ExperimentalWarning',str(BIN),'serve','--mcp','--path',str(root)])]
     for k in ['CODEGRAPH_TELEMETRY','CODEGRAPH_NO_UPDATE_CHECK','CODEGRAPH_NO_DAEMON','CODEGRAPH_NO_WATCH']:
      args+=['-c','mcp_servers.codegraph.env.'+k+'='+json.dumps('0' if k=='CODEGRAPH_TELEMETRY' else '1')]
    def hashes(): return {str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in root.rglob('*') if p.is_file() and '.codegraph' not in p.parts}
    before=hashes(); start=time.monotonic()
    with (OUT/(stem+'.jsonl')).open('w') as stdout, (OUT/(stem+'.stderr.log')).open('w') as stderr:
     try: code=subprocess.run(args+[prompt],stdin=subprocess.DEVNULL,stdout=stdout,stderr=stderr,timeout=360).returncode
     except subprocess.TimeoutExpired: code=124
    events=[]
    for line in (OUT/(stem+'.jsonl')).read_text().splitlines():
     try: events.append(json.loads(line))
     except json.JSONDecodeError: pass
    items=[e['item'] for e in events if e.get('type')=='item.completed']
    commands=[x for x in items if x.get('type')=='command_execution']
    mcp=[x for x in items if x.get('type')=='mcp_tool_call']
    usage={}
    for e in events:
     for k,v in e.get('usage',{}).items(): usage[k]=usage.get(k,0)+v
    forbidden=[x.get('command','') for x in commands if any(s in x.get('command','').lower() for s in ['.codegraph','sqlite','codegraph explore','codegraph query'])]
    r={'repo':repo['name'],'flow':i+1,'names':names,'repetition':repetition+1,'arm':arm,'exit':code,'seconds':time.monotonic()-start,'usage':usage,'commands':len(commands),'command_text':[x.get('command') for x in commands],'mcp':len(mcp),'mcp_tools':[x.get('tool') for x in mcp],'mcp_errors':[x for x in mcp if x.get('error') or x.get('result',{}).get('isError')],'forbidden_commands':forbidden,'source_hashes_unchanged':hashes()==before,'session_ids':[e.get('thread_id') for e in events if e.get('type')=='thread.started']}
    report.write_text(json.dumps(r,indent=2));results.append(r)
    (OUT/'results.json').write_text(json.dumps(results,indent=2))
    print(stem,code,round(r['seconds'],1),'commands',r['commands'],'MCP',r['mcp'],flush=True)
print('COMPLETE',len(results),flush=True)
