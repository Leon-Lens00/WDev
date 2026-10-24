"""Capture the live Forge renderer through its documented bridge; never simulates images."""
import argparse,base64,json,socket
from pathlib import Path

ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('--pid',type=int,required=True)
ap.add_argument('--out',type=Path,required=True)
a=ap.parse_args()
lock=json.loads((Path.home()/'.wc3-forge/mcp'/f'{a.pid}.lock').read_text())
with socket.create_connection(('127.0.0.1',lock['port']),timeout=40) as conn:
    conn.sendall((json.dumps(dict(jsonrpc='2.0',id=1,method='viewport.screenshot',params=dict(_token=lock['token'],max_width=1600)))+'\n').encode())
    response=json.loads(conn.makefile('rb').readline())
if 'error' in response:raise RuntimeError(response['error'])
r=response['result'];data=base64.b64decode(r.pop('bytes_base64'))
a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_bytes(data)
a.out.with_suffix('.json').write_text(json.dumps(r,indent=2)+'\n')
print(a.out)
