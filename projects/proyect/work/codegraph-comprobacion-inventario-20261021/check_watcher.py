"""Observe automatic create/edit/delete through read-only SQLite, without sync."""
from pathlib import Path
import sqlite3,json,time,hashlib
roots=[Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src'),Path('/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/inventory-integration'),Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist')]
report=[]
for i,r in enumerate(roots):
    js=i==2;name='cg_review_temp_20261021_'+str(i);p=r/(name+('.js' if js else '.j'));assert not p.exists()
    c=sqlite3.connect((r/'.codegraph/codegraph.db').as_uri()+'?mode=ro',uri=True)
    baseline={f:h for f,h in c.execute('select path,content_hash from files')};assert p.name not in baseline
    n1=name+'_created';n2=name+'_changed';entry={'root':str(r),'transitions':[]}
    def source(n):return ('export function '+n+'(){return 1;}\n') if js else ('function '+n+' takes nothing returns integer\n    return 1\nendfunction\n')
    def wait(label,ok):
        start=time.monotonic()
        while time.monotonic()-start<8:
            if ok():entry['transitions'].append({'action':label,'pass':True,'seconds':round(time.monotonic()-start,3)});return
            time.sleep(.1)
        entry['transitions'].append({'action':label,'pass':False});raise RuntimeError('Automatic update timed out: '+str(r)+' '+label)
    def names():return {x for x, in c.execute('select name from nodes where file_path=?',(p.name,))}
    try:
        with p.open('x') as f:f.write(source(n1))
        wait('create',lambda:n1 in names())
        p.write_text(source(n2));wait('edit',lambda:n2 in names() and n1 not in names())
    finally:
        if p.exists():p.unlink()
        wait('delete',lambda:c.execute('select count(*) from files where path=?',(p.name,)).fetchone()[0]==0 and not names())
        now={f:h for f,h in c.execute('select path,content_hash from files')};entry['index_restored']=now==baseline
        entry['original_files_unchanged']=all((r/f).exists() and hashlib.sha256((r/f).read_bytes()).hexdigest()==h for f,h in baseline.items())
        entry['quick_check']=c.execute('pragma quick_check').fetchone()[0]
        report.append(entry);Path(__file__).with_name('watcher-check.json').write_text(json.dumps(report,indent=2))
    assert entry['index_restored'] and entry['original_files_unchanged'] and entry['quick_check']=='ok'
print(json.dumps(report,indent=2))
