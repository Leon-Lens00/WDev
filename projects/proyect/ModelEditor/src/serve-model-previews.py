"""Loopback-only preview server; let the OS choose a free port."""
from http.server import ThreadingHTTPServer,SimpleHTTPRequestHandler
from pathlib import Path
import json,sys,os,functools
root=Path(sys.argv[1]).resolve();record=Path(sys.argv[2]).resolve()
server=ThreadingHTTPServer(('127.0.0.1',0),functools.partial(SimpleHTTPRequestHandler,directory=str(root)))
record.write_text(json.dumps({'pid':os.getpid(),'root':str(root),'url':f'http://127.0.0.1:{server.server_port}/'},indent=2)+'\n')
server.serve_forever()
