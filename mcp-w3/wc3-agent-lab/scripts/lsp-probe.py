from pathlib import Path
import subprocess,json,queue,threading,time,os
root=Path(__file__).resolve().parent.parent
api=Path('/home/snz/Documentos/ChatGPT/FrozenThone/tools/wc3-addons/classic-assets/Scripts')
command=[str(root/'bin/ydwe-compiler'),'--lsp','--no-compile-lua','--common-j',str(api/'common.j'),'--blizzard-j',str(api/'Blizzard.j')]
p=subprocess.Popen(command,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=open(root/'reports/lsp-stderr.log','w'),cwd=root/'fixtures')
q=queue.Queue();all_messages=[]
def reader():
    while True:
        headers={}
        while True:
            line=p.stdout.readline()
            if not line:return
            if line==b'\r\n':break
            k,v=line.decode().split(':',1);headers[k.lower()]=v.strip()
        payload=p.stdout.read(int(headers['content-length']))
        q.put(json.loads(payload))
threading.Thread(target=reader,daemon=True).start()
def send(obj):
    b=json.dumps(obj).encode();p.stdin.write(f'Content-Length: {len(b)}\r\n\r\n'.encode()+b);p.stdin.flush()
def receive(timeout=15):
    obj=q.get(timeout=timeout);all_messages.append(obj)
    if 'method' in obj and 'id' in obj:
        send({'jsonrpc':'2.0','id':obj['id'],'result': [] if obj['method']=='workspace/configuration' else None})
    return obj
def request(i,method,params):
    send({'jsonrpc':'2.0','id':i,'method':method,'params':params})
    deadline=time.monotonic()+20
    while time.monotonic()<deadline:
        obj=receive(max(.1,deadline-time.monotonic()))
        if obj.get('id')==i and 'method' not in obj:return obj
try:
    init=request(1,'initialize',{'processId':os.getpid(),'rootUri':(root/'fixtures').as_uri(),'capabilities':{}})
    send({'jsonrpc':'2.0','method':'initialized','params':{}})
    uri=(root/'fixtures/good-vjass.j').as_uri()
    for name in ['good-vjass.j','bad-modern.j','bad-invented.j','bad-method.j','bad-syntax.j']:
        path=root/'fixtures'/name
        send({'jsonrpc':'2.0','method':'textDocument/didOpen','params':{'textDocument':{'uri':path.as_uri(),'languageId':'jass','version':1,'text':path.read_text()}}})
    symbols=request(2,'textDocument/documentSymbol',{'textDocument':{'uri':uri}})
    references=request(3,'textDocument/references',{'textDocument':{'uri':uri},'position':{'line':3,'character':13},'context':{'includeDeclaration':True}})
    result={'command':command,'initialize':init,'symbols':symbols,'references':references}
    deadline=time.monotonic()+3
    while time.monotonic()<deadline:
        try:receive(.25)
        except queue.Empty:pass
    result['messages']=all_messages
    (root/'reports/lsp-results.json').write_text(json.dumps(result,indent=2))
    print('capabilities',json.dumps(init.get('result',{}).get('capabilities',{})))
    print('symbols',json.dumps(symbols)[:1300])
    print('references',json.dumps(references)[:500])
    for msg in all_messages:
        if msg.get('method')=='textDocument/publishDiagnostics':
            v=msg['params'];print(Path(v['uri']).name,'diagnostics',len(v['diagnostics']),json.dumps(v['diagnostics'])[:600])
    request(99,'shutdown',None)
    send({'jsonrpc':'2.0','method':'exit'})
finally:
    p.stdin.close()
    try:p.wait(timeout=3)
    except subprocess.TimeoutExpired:p.terminate();p.wait(timeout=3)
