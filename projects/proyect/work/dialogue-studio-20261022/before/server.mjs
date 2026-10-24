import http from 'node:http';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {validateProject,exportJass,integrationNotes} from './dist/core.js';
const root=fileURLToPath(new URL('./dist/',import.meta.url));
const exportsRoot=fileURLToPath(new URL('./exports/',import.meta.url));
const mime={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.json':'application/json; charset=utf-8','.png':'image/png','.svg':'image/svg+xml'};
const server=http.createServer(async(req,res)=>{try{
 if(req.method==='POST'&&req.url==='/api/save'){
  if(req.headers.origin!=='http://127.0.0.1:4317'){res.writeHead(403);return res.end('Origen no permitido');}
  let data='';for await(const chunk of req){data+=chunk;if(Buffer.byteLength(data)>4*1024*1024){res.writeHead(413);return res.end('Archivo demasiado grande');}}
  let project;try{project=validateProject(JSON.parse(data));}catch(e){res.writeHead(400,{'Content-Type':'application/json'});return res.end(JSON.stringify({error:e.message}));}
  const folder=new Date().toISOString().replace(/[:.]/g,'-');const dir=path.join(exportsRoot,folder);await mkdir(dir,{recursive:true});
  await Promise.all([writeFile(path.join(dir,'interfaz.wc3ui.json'),JSON.stringify(project,null,2)),writeFile(path.join(dir,'UIStudioLayout.j'),exportJass(project)),writeFile(path.join(dir,'Integracion.txt'),integrationNotes(project))]);
  res.writeHead(200,{'Content-Type':'application/json'});return res.end(JSON.stringify({folder,path:dir,files:['interfaz.wc3ui.json','UIStudioLayout.j','Integracion.txt']}));
 }
 const pathname=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
 const target=path.resolve(root,'.'+(pathname==='/'?'/index.html':pathname));
 if(!target.startsWith(root)){res.writeHead(403);return res.end();}
 const body=await readFile(target);res.writeHead(200,{'Content-Type':mime[path.extname(target)]||'application/octet-stream','Cache-Control':'no-cache'});res.end(body);
}catch{res.writeHead(404);res.end('No encontrado');}});
server.listen(4317,'127.0.0.1',()=>console.log('UI Studio: http://127.0.0.1:4317'));
