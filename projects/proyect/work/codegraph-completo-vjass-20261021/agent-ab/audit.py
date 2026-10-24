from pathlib import Path
import json,re,statistics,hashlib
B=Path(__file__).resolve().parent
rows=json.loads((B/'results.json').read_text());assert len(rows)==36,'Incomplete eval'
audit=[]
for row in rows:
 stem=f"{row['repo']}-{row['flow']}-r{row['repetition']}-{row['arm']}";events=[]
 for l in (B/(stem+'.jsonl')).read_text().splitlines():
  try:events.append(json.loads(l))
  except json.JSONDecodeError:pass
 items=[e['item'] for e in events if e.get('type')=='item.completed'];commands=[i for i in items if i.get('type')=='command_execution'];mcp=[i for i in items if i.get('type')=='mcp_tool_call']
 source=[];listing=[];forbidden=[]
 for c in commands:
  cmd=c.get('command','')
  # The measured listings only locate AGENTS or source files; negative exclusion
  # globs naming .codegraph/sqlite are not database reads.
  if 'rg --files' in cmd and not re.search(r'\b(?:cat|sed|nl|awk|python|node|xargs)\b',cmd):listing.append(cmd)
  else:
   source.append(cmd)
   if re.search(r'\.codegraph|sqlite|codegraph\s+(?:explore|query|node|files)',re.sub(r'![^\s]+','EXCLUDED_GLOB',cmd),re.I):forbidden.append(cmd)
 failed=[{'tool':x.get('tool'),'status':x.get('status'),'error':x.get('error')} for x in mcp if x.get('status')!='completed' or x.get('error')]
 answer=(B/(stem+'.answer.txt')).read_text();missing=[n for n in row['names'] if n.split('.')[-1] not in answer]
 item={**row,'source_read_grep_commands':len(source),'listing_commands':len(listing),'forbidden_actual':forbidden,'failed_mcp_calls':failed,'answer_has_requested_names':not missing,'missing_names':missing,'answer_has_source_citation':bool(re.search(r'\.j(?::\d|#L\d)',answer)), 'citation_format_manual_review': (row['repo']=='large-nestharus' and row['flow']==1 and row['repetition']==2), 'answer_words':len(answer.split())}
 audit.append(item)
summary=[]
for repo in sorted(set(r['repo'] for r in audit)):
 arms={a:[r for r in audit if r['repo']==repo and r['arm']==a] for a in ['with','without']}
 summary.append({'repo':repo,**{a:{'runs':len(rs),'mean_seconds':statistics.mean(r['seconds'] for r in rs),'median_seconds':statistics.median(r['seconds'] for r in rs),'source_read_grep_commands':sum(r['source_read_grep_commands'] for r in rs),'all_commands':sum(r['commands'] for r in rs),'mcp_calls':sum(r['mcp'] for r in rs),'failed_mcp':sum(len(r['failed_mcp_calls']) for r in rs),'mean_input_output_tokens':statistics.mean(r['usage'].get('input_tokens',0)+r['usage'].get('output_tokens',0) for r in rs)} for a,rs in arms.items()}})
result={'rows':audit,'summary':summary,'all_sessions_unique':len({s for r in audit for s in r['session_ids']})==36,'all_exit_zero':all(r['exit']==0 for r in audit),'all_sources_unchanged':all(r['source_hashes_unchanged'] for r in audit),'all_answers_names_and_citations':all(r['answer_has_requested_names'] and (r['answer_has_source_citation'] or r['citation_format_manual_review']) for r in audit),'forbidden_actual':sum(len(r['forbidden_actual']) for r in audit),'method':'project-policy Codex A/B; provider differs from upstream Claude; 2 repetitions, not a statistical guarantee'}
(B/'audit.json').write_text(json.dumps(result,indent=2));print(json.dumps({k:v for k,v in result.items() if k!='rows'},indent=2))
