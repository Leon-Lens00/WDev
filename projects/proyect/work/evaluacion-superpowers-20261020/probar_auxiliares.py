"""Bounded helper checks in a disposable Git repository; no Codex skill activation."""
from pathlib import Path
import hashlib,json,subprocess,tempfile

root=Path(__file__).resolve().parent
scripts=root/'upstream/skills/subagent-driven-development/scripts'
results=[]
with tempfile.TemporaryDirectory(prefix='superpowers-evaluacion-') as temp:
 repo=Path(temp)
 def run(args,check=True):
  r=subprocess.run(args,cwd=repo,text=True,capture_output=True,timeout=20)
  if check and r.returncode:raise RuntimeError((args,r.returncode,r.stderr))
  return r
 def git(*args,check=True):
  return run(['git','-c','core.hooksPath=/dev/null','-c','commit.gpgsign=false',
    '-c','user.name=Evaluation fixture','-c','user.email=fixture@example.invalid',*args],check)
 git('-c','init.templateDir=','init','--quiet')
 (repo/'fuente.j').write_text('// committed baseline\n')
 git('add','fuente.j');git('commit','--quiet','-m','fixture baseline')
 base=git('rev-parse','HEAD').stdout.strip()
 (repo/'fuente.j').write_text('// committed change\n')
 git('add','fuente.j');git('commit','--quiet','-m','fixture committed delta')
 head=git('rev-parse','HEAD').stdout.strip()
 (repo/'fuente.j').write_text('// committed change\n// DIRTY_CHANGE_SENTINEL\n')
 (repo/'mapa-nuevo.w3x').write_bytes(b'UNTRACKED_BINARY_SENTINEL')
 for p in ['docs/alpha/plan.md','docs/beta/plan.md']:
  f=repo/p;f.parent.mkdir(parents=True,exist_ok=True);f.write_text('# Synthetic helper evaluation plan\n')
 out=repo/'review.diff'
 args=['bash',str(scripts/'review-package'),'docs/alpha/plan.md',base,head,str(out)]
 r=run(args);text=out.read_text()
 assert 'committed change' in text
 assert 'DIRTY_CHANGE_SENTINEL' not in text and 'mapa-nuevo.w3x' not in text
 saved=root/'evidencia-review-package.diff';saved.write_text(text)
 results.append({'name':'review-package committed range coverage','exit':r.returncode,
  'committed_delta_included':True,'dirty_worktree_delta_included':False,'untracked_map_included':False,
  'conclusion':'Correct commit-range output; caller must separately cover non-committed deliverables.',
  'artifact':saved.name,'sha256':hashlib.sha256(saved.read_bytes()).hexdigest()})
 r=run(['bash',str(scripts/'review-package'),'docs/alpha/plan.md',head,head,str(out)],check=False)
 assert r.returncode==3
 results.append({'name':'review-package rejects empty range','exit':r.returncode,'stderr':r.stderr.strip()})
 r1=run(['bash',str(scripts/'sdd-workspace'),'docs/alpha/plan.md'])
 r2=run(['bash',str(scripts/'sdd-workspace'),'docs/beta/plan.md'])
 r3=run(['bash',str(scripts/'sdd-workspace'),'docs/alpha/plan.md'])
 p1=Path(r1.stdout.strip());p2=Path(r2.stdout.strip())
 assert p1!=p2 and r1.stdout==r3.stdout
 assert (p1/'plan-path').read_text().strip()=='docs/alpha/plan.md'
 assert (p2/'plan-path').read_text().strip()=='docs/beta/plan.md'
 ignored=git('check-ignore',str(p1/'plan-path'))
 results.append({'name':'plan workspaces avoid basename collision and reuse exact plan',
 'separate_plan_paths':True,'same_plan_path_stable':True,'git_ignored':ignored.returncode==0,
 'workspace_names':[p1.name,p2.name]})
report={'scope':'Two original Bash helpers, isolated synthetic Git fixture. No model-behavior or Warcraft tests.',
 'commands':['bash review-package PLAN BASE HEAD OUTFILE','bash review-package PLAN HEAD HEAD OUTFILE','bash sdd-workspace PLAN'],
 'results':results,'temporary_repository_removed':True}
(root/'pruebas-auxiliares.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(report,ensure_ascii=False,indent=2))
