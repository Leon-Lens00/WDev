import json, subprocess, time
from pathlib import Path
root=Path('/home/snz/Documentos/MCP W3/wc3-agent-lab')
out=root/'evaluation'
lint=Path('/home/snz/.codex/skills/build-warcraft3-vjass-127b/scripts/wc3lint.py')
cases={
'modern-call':('call BlzSetUnitMaxHP(null, 100)',True),
'string-only':('call BJDebugMsg("BlzSetUnitMaxHP is unavailable")',False),
'block-comment':('/*\ncall BlzSetUnitMaxHP(null, 100)\n*/\ncall BJDebugMsg("classic")',False),
'local-unit':('if GetLocalPlayer() == Player(0) then\ncall CreateUnit(Player(0), \'hfoo\', 0., 0., 0.)\nendif',True),
'global-unit':('call CreateUnit(Player(0), \'hfoo\', 0., 0., 0.)',False),
'local-camera':('if GetLocalPlayer() == Player(0) then\ncall SetCameraPosition(0., 0.)\nendif',False),
'local-random':('local integer n\nif GetLocalPlayer() == Player(0) then\nset n = GetRandomInt(1, 10)\nendif',True),
'commented-local-unit':('/*\nif GetLocalPlayer() == Player(0) then\ncall CreateUnit(Player(0), \'hfoo\', 0., 0., 0.)\nendif\n*/\ncall BJDebugMsg("classic")',False),
}
def run(cmd):
 t=time.monotonic(); p=subprocess.run([str(v) for v in cmd],capture_output=True,text=True,timeout=60)
 try: result=json.loads(p.stdout)
 except: result={'stdout':p.stdout[:2000],'stderr':p.stderr[:2000]}
 return {'exit':p.returncode,'seconds':round(time.monotonic()-t,3),'result':result}
results=[]
for name,(body,expected) in cases.items():
 f=out/(name+'.j');f.write_text('function main takes nothing returns nothing\n'+body+'\nendfunction\n')
 row={'case':name,'should_flag_modern_or_local_gameplay':expected,'wc3lint':run(['python3',lint,f,'--json']),'patterns':run([root/'bin/jass-pattern-review',f])}
 row['wc3lint_flag']=any(x['severity']=='ERROR' for x in row['wc3lint']['result'].get('findings',[]))
 row['pattern_flag']=bool(row['patterns']['result'].get('findings'))
 results.append(row)
(out/'pattern-comparison.json').write_text(json.dumps(results,indent=2))
# Check the hook actually processes every advertised extension.
rows=[]
for ext in ['j','jass','vjass']:
 f=out/('extension-probe.'+ext);f.write_text((out/'modern-call.j').read_text())
 rows.append({'extension':ext,**run(['python3',root/'scripts/lint-batch.py',f])})
(out/'hook-extension-check-after.json').write_text(json.dumps(rows,indent=2))
project=Path('/home/snz/Documentos/WarDatsPy/struct-rebuild')
deps=[project/'libraries'/n for n in ['TimerUtils.j','Table.j','RegisterPlayerUnitEvent.j','TextTagDebug.j','TerrainPathability.j']]
real=[]
for f in [project/'MoveSys/MoveCast.j',project/'MoveSys/Config/MovementSpellTargetConfig.j']:
 additional=[project/'MoveSys/MoveCast.j'] if f.name=='MovementSpellTargetConfig.j' else []
 real.append({'file':str(f),'audit':run([root/'bin/vjass-audit',f,*deps,*additional]),'patterns':run([root/'bin/jass-pattern-review',f]),'wc3lint':run(['python3',lint,f,'--json'])})
(out/'real-source-comparison.json').write_text(json.dumps(real,indent=2))
print(json.dumps({'pattern_cases':[{'case':x['case'],'expected':x['should_flag_modern_or_local_gameplay'],'lint':x['wc3lint_flag'],'ast':x['pattern_flag'],'ast_status':x['patterns']['result'].get('status')} for x in results], 'hook_extensions':[{'extension':x['extension'],'exit':x['exit'],'files':x['result'].get('files')} for x in rows], 'real_sources':[{'file':x['file'],'audit_seconds':x['audit']['seconds'],'parser_errors':len(x['audit']['result'].get('parser',{}).get('errors',[])),'semantic_errors':len(x['audit']['result'].get('semantic',{}).get('errors',[])),'semantic_warnings':len(x['audit']['result'].get('semantic',{}).get('warnings',[])),'pattern_status':x['patterns']['result'].get('status'),'lint_findings':len(x['wc3lint']['result'].get('findings',[]))} for x in real]},indent=2))
