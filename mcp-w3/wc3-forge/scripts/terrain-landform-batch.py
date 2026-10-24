"""Run the nine explicit G6 cases sequentially, without retries or GUI.

The v1 manifest selects three cases from each of three recipes. It never edits
recipe seed lists (the tropical legacy brief must retain all four seeds).
Use --check-only before the native pilot; run only after that pilot is accepted.
Inputs are hashed: after an intentional recipe change, review and update the
manifest hashes explicitly before running. A nonempty destination is refused.
"""
from pathlib import Path, PurePosixPath
import argparse, ctypes, datetime, hashlib, json, math, os, re, subprocess, time

FORMAT = 'wc3-landform-batch-v1'

def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1024*1024), b''): h.update(block)
    return h.hexdigest()

def read(path):
    def unique(pairs):
        result = {}
        for k, v in pairs:
            if k in result: raise ValueError('duplicate JSON key: '+k)
            result[k] = v
        return result
    return json.loads(Path(path).read_text(encoding='utf-8-sig'), object_pairs_hook=unique)

def write(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name+'.tmp')
    tmp.write_text(json.dumps(value, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')
    tmp.replace(path)

def keys(value, required, where):
    if not isinstance(value, dict) or set(value) != set(required):
        raise ValueError(where+' has missing or unknown fields')

def relative(value):
    if not isinstance(value, str) or not value or '\\' in value or ':' in value:
        raise ValueError('invalid relative path')
    p = PurePosixPath(value)
    if p.is_absolute() or '..' in p.parts or '.' in p.parts or str(p) != value:
        raise ValueError('unsafe or noncanonical relative path: '+value)
    return p

def seed_list(value, count=None):
    if not isinstance(value, list) or not value or any(type(x) is not int or not 0 <= x <= 2147483647 for x in value):
        raise ValueError('invalid seed list')
    if len(set(value)) != len(value) or (count is not None and len(value) != count):
        raise ValueError('duplicate seeds or incorrect seed count')
    return value

def load_manifest(path):
    path = Path(path).resolve(); root = path.parent; m = read(path)
    keys(m, ('format','criteria','recipes','cases'), 'manifest')
    if m['format'] != FORMAT: raise ValueError('unsupported batch format')
    keys(m['criteria'], ('path','sha256'), 'criteria reference')
    cp = root / relative(m['criteria']['path'])
    if digest(cp) != m['criteria']['sha256']: raise ValueError('criteria hash mismatch')
    criteria = read(cp)
    if criteria.get('format') != 'wc3-landform-criteria-v1' or criteria.get('frozen_before_batch') is not True:
        raise ValueError('criteria are not frozen')
    if not isinstance(m['recipes'],list) or len(m['recipes']) != 3 or not isinstance(m['cases'],list) or len(m['cases']) != 9:
        raise ValueError('v1 requires exactly three recipes and nine cases')
    recipes = {}; snapshots = {}; fingerprints = {str(path):digest(path),str(cp):digest(cp)}
    for r in m['recipes']:
        keys(r, ('id','path','sha256','command'), 'recipe')
        if not isinstance(r['id'],str) or not re.fullmatch('[a-z][a-z0-9-]{0,47}',r['id']) or r['id'] in recipes:
            raise ValueError('duplicate or invalid recipe id')
        if r['command'] not in ('biome-generate','generate'): raise ValueError('command is not allowed')
        spec = root / relative(r['path'])
        if digest(spec) != r['sha256']: raise ValueError('recipe hash mismatch: '+r['id'])
        q=read(spec)
        if r['command']=='biome-generate':
            if q.get('format')!='wc3-territory-recipe-v1' or q.get('realizer')!='landforms-cohorts-v1':
                raise ValueError('biome case requires the explicit landforms realizer')
            seeds=seed_list(q.get('seeds'),3)
            if not isinstance(q.get('id'),str) or not re.fullmatch('[A-Za-z0-9-]+',q['id']): raise ValueError('unsafe biome output id')
        else:
            landscape=q.get('landscape') or {}; brief=landscape.get('brief') or {}
            if q.get('format')!='wc3-scene-spec-v4' or q.get('mode')!='whole-map-landscape' or not landscape.get('landforms') or not landscape.get('materials'):
                raise ValueError('tropical case requires the landform adapter and contextual materials')
            if brief.get('format')!='wc3-landscape-brief-v1' or brief.get('id') not in ('D','E','F'):
                raise ValueError('invalid tropical brief')
            seeds=seed_list(brief.get('seeds'),4)  # Never truncate the legacy contract.
        recipes[r['id']]={**r,'absolute_path':str(spec),'declared_seeds':seeds}
        snapshots[r['id']]=q; fingerprints[str(spec)]=digest(spec)
    if not isinstance(criteria.get('seeds'),dict) or set(criteria['seeds']) != set(recipes):
        raise ValueError('criteria recipe selection differs')
    expected={(rid,s) for rid,seeds in criteria['seeds'].items() for s in seed_list(seeds,3)}
    selected=set(); ids=set()
    for c in m['cases']:
        keys(c, ('id','recipe','seed','expected_output'), 'case')
        if not isinstance(c['id'],str) or not re.fullmatch('[a-z][a-z0-9-]{0,63}',c['id']) or c['id'] in ids:
            raise ValueError('duplicate or invalid case id')
        ids.add(c['id']); rid=c['recipe']; seed=c['seed']
        if rid not in recipes or type(seed) is not int or seed not in recipes[rid]['declared_seeds']:
            raise ValueError('case seed not declared by recipe')
        if (rid,seed) in selected: raise ValueError('duplicate recipe/seed case')
        selected.add((rid,seed)); relative(c['expected_output']); q=snapshots[rid]
        expected_output=(f"paint/{q['id']}-base-materials.w3x" if recipes[rid]['command']=='biome-generate' else f"Tropical-{q['landscape']['brief']['id']}-{seed}.w3x")
        if c['expected_output'] != expected_output: raise ValueError('expected output does not match generator contract')
    if selected!=expected: raise ValueError('case selection differs from frozen criteria')
    return m, recipes, fingerprints

class WindowsMetrics:
    """Own child-process job; memory queries do not control any GUI."""
    def __init__(self, process):
        from ctypes import wintypes as w
        size=ctypes.c_size_t; u64=ctypes.c_ulonglong
        class Counters(ctypes.Structure):
            _fields_=[('cb',w.DWORD),('PageFaultCount',w.DWORD),('PeakWorkingSetSize',size),('WorkingSetSize',size),('QuotaPeakPagedPoolUsage',size),('QuotaPagedPoolUsage',size),('QuotaPeakNonPagedPoolUsage',size),('QuotaNonPagedPoolUsage',size),('PagefileUsage',size),('PeakPagefileUsage',size)]
        class Basic(ctypes.Structure):
            _fields_=[('PerProcessUserTimeLimit',ctypes.c_longlong),('PerJobUserTimeLimit',ctypes.c_longlong),('LimitFlags',w.DWORD),('MinimumWorkingSetSize',size),('MaximumWorkingSetSize',size),('ActiveProcessLimit',w.DWORD),('Affinity',size),('PriorityClass',w.DWORD),('SchedulingClass',w.DWORD)]
        class IO(ctypes.Structure):
            _fields_=[(x,u64) for x in ('ReadOperationCount','WriteOperationCount','OtherOperationCount','ReadTransferCount','WriteTransferCount','OtherTransferCount')]
        class Extended(ctypes.Structure):
            _fields_=[('BasicLimitInformation',Basic),('IoInfo',IO),('ProcessMemoryLimit',size),('JobMemoryLimit',size),('PeakProcessMemoryUsed',size),('PeakJobMemoryUsed',size)]
        self.Counters= Counters; self.Extended=Extended
        self.k=ctypes.WinDLL('kernel32',use_last_error=True); self.ps=ctypes.WinDLL('psapi',use_last_error=True)
        self.k.OpenProcess.argtypes=[w.DWORD,w.BOOL,w.DWORD];self.k.OpenProcess.restype=w.HANDLE
        self.k.CreateJobObjectW.argtypes=[ctypes.c_void_p,w.LPCWSTR];self.k.CreateJobObjectW.restype=w.HANDLE
        self.k.SetInformationJobObject.argtypes=[w.HANDLE,ctypes.c_int,ctypes.c_void_p,w.DWORD];self.k.SetInformationJobObject.restype=w.BOOL
        self.k.AssignProcessToJobObject.argtypes=[w.HANDLE,w.HANDLE];self.k.AssignProcessToJobObject.restype=w.BOOL
        self.k.QueryInformationJobObject.argtypes=[w.HANDLE,ctypes.c_int,ctypes.c_void_p,w.DWORD,ctypes.c_void_p];self.k.QueryInformationJobObject.restype=w.BOOL
        self.k.TerminateJobObject.argtypes=[w.HANDLE,w.UINT];self.k.TerminateJobObject.restype=w.BOOL
        self.k.CloseHandle.argtypes=[w.HANDLE];self.k.CloseHandle.restype=w.BOOL
        self.ps.GetProcessMemoryInfo.argtypes=[w.HANDLE,ctypes.c_void_p,w.DWORD];self.ps.GetProcessMemoryInfo.restype=w.BOOL
        self.handle=self.k.OpenProcess(0x0511,False,process.pid); self.job=self.k.CreateJobObjectW(None,None)
        self.peak=None; self.job_peak=None
        if not self.handle or not self.job: self.close();raise OSError('cannot acquire own process/job handles')
        limits=Extended();limits.BasicLimitInformation.LimitFlags=0x2000 # KILL_ON_JOB_CLOSE, own CLI and descendants only.
        if not self.k.SetInformationJobObject(self.job,9,ctypes.byref(limits),ctypes.sizeof(limits)) or not self.k.AssignProcessToJobObject(self.job,self.handle):
            self.close();raise OSError('cannot establish child cleanup job')
    def sample(self):
        c=self.Counters();c.cb=ctypes.sizeof(c)
        if self.ps.GetProcessMemoryInfo(self.handle,ctypes.byref(c),ctypes.sizeof(c)):
            self.peak=max(self.peak or 0,c.PeakWorkingSetSize)
        e=self.Extended()
        if self.k.QueryInformationJobObject(self.job,9,ctypes.byref(e),ctypes.sizeof(e),None): self.job_peak=max(self.job_peak or 0,e.PeakJobMemoryUsed)
    def terminate(self):
        if self.job:self.k.TerminateJobObject(self.job,1)
    def close(self):
        for name in ('job','handle'):
            value=getattr(self,name,None)
            if value:self.k.CloseHandle(value);setattr(self,name,None)

def run_case(cli, recipe, case, out, timeout):
    dest=out/case['recipe']/str(case['seed']);dest.mkdir(parents=True)
    command=[str(cli),recipe['command'],'--spec',recipe['absolute_path'],'--seed',str(case['seed']),'--out',str(dest)]
    row={**case,'command':command,'attempts':1,'status':'running','started_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'log':str(dest/'generation.log')}
    start=time.perf_counter();process=None;metrics=None
    try:
        with (dest/'generation.log').open('w',encoding='utf-8') as log:
            process=subprocess.Popen(command,stdout=log,stderr=subprocess.STDOUT,cwd=cli.parent,creationflags=subprocess.CREATE_NO_WINDOW)
            metrics=WindowsMetrics(process)
            while True:
                metrics.sample()
                if process.poll() is not None: break
                if time.perf_counter()-start>timeout:
                    metrics.terminate();process.wait(timeout=15)
                    raise TimeoutError('declared per-case time budget exhausted')
                time.sleep(.1)
            metrics.sample();row['exit_code']=process.returncode
            if process.returncode!=0: raise RuntimeError('generator exited with '+str(process.returncode))
        generated=dest/case['expected_output']
        row['map_sha256']=digest(generated)
        validation=read(dest/'validation.json')
        if validation.get('passed') is not True or validation.get('map_sha256')!=row['map_sha256']:
            raise ValueError('exported-map validation failed or references another map')
        report=read(dest/('run.json' if recipe['command']=='biome-generate' else 'report.json'))
        if report.get('seed')!=case['seed']: raise ValueError('reported seed differs from selected case')
        if metrics.peak is None or metrics.peak<=0 or metrics.job_peak is None:
            raise RuntimeError('required Windows memory measurement unavailable')
        row['status']='passed';row['map']=str(generated);row['validation_sha256']=digest(dest/'validation.json')
    except Exception as e:
        row['status']='failed';row['error']=str(e)
        if process and process.poll() is None:
            if metrics:metrics.terminate()
            else:process.kill()
            process.wait(timeout=15)
        if process:row['exit_code']=process.returncode
    finally:
        row['elapsed_seconds']=round(time.perf_counter()-start,4)
        row['peak_working_set_cli_bytes']=metrics.peak if metrics else None
        row['peak_committed_memory_job_bytes']=metrics.job_peak if metrics else None
        row['memory_scope']='OS PeakWorkingSet of CLI; job committed-memory peak includes inherited child runtimes and is a different metric.'
        if metrics:metrics.close()
        write(dest/'case-result.json',row)
    return row

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--manifest',type=Path,required=True);ap.add_argument('--cli',type=Path);ap.add_argument('--out',type=Path);ap.add_argument('--check-only',action='store_true');ap.add_argument('--timeout',type=float,default=900)
    a=ap.parse_args();m,recipes,fingerprints=load_manifest(a.manifest)
    if a.check_only: print('Validated manifest: exactly nine cases; original recipe seed lists retained.');return 0
    if not a.cli or not a.out:ap.error('--cli and --out are required for execution')
    if os.name!='nt':ap.error('execution requires Windows for the specified memory measurement; --check-only is portable')
    if not math.isfinite(a.timeout) or a.timeout<=0:ap.error('--timeout must be finite and positive')
    cli=a.cli.resolve();out=a.out.resolve()
    if not cli.is_file():ap.error('--cli is not an existing file')
    if out.exists() and (not out.is_dir() or any(out.iterdir())):ap.error('--out must be absent or empty; no automatic overwrite/retry')
    out.mkdir(parents=True,exist_ok=True);fingerprints[str(cli)]=digest(cli)
    result={'format':'wc3-landform-batch-result-v1','status':'running','passed':False,'inputs_sha256':fingerprints,'cases':[],'visual_review':'pending','native_editor':'separate required evidence','game_executed':False,'shadows':'excluded'}
    write(out/'manifest.json',m);write(out/'batch.json',result)
    for case in m['cases']:
        try:
            for path,expected in fingerprints.items():
                if digest(path)!=expected:raise ValueError('frozen input changed during batch: '+path)
            row=run_case(cli,recipes[case['recipe']],case,out,a.timeout)
        except Exception as e:
            row={**case,'status':'failed','attempts':0,'error':str(e)}
        result['cases'].append(row);write(out/'batch.json',result)
        print(case['id'],row['status'],row.get('error',row.get('map_sha256','')),flush=True)
    result['passed']=len(result['cases'])==9 and all(c['status']=='passed' for c in result['cases'])
    result['status']='passed' if result['passed'] else 'failed';write(out/'batch.json',result)
    return 0 if result['passed'] else 1

if __name__=='__main__':raise SystemExit(main())
