"""Archive Vinz's complete public Missile-tag catalog; do not modify models."""
from pathlib import Path,PurePosixPath
import urllib.request,urllib.parse,re,html,json,hashlib,zipfile,io,datetime,concurrent.futures,threading,time
ROOT=Path(__file__).resolve().parents[1];PROJECT=ROOT.parent
OUT=PROJECT/'descargas/warcraft3/misiles/vinz/biblioteca-originales'
EV=ROOT/'evidence/vinz-library-20261022';OUT.mkdir(parents=True,exist_ok=True);EV.mkdir(parents=True,exist_ok=True)
BASE='https://www.hiveworkshop.com';LOCK=threading.Lock()
def fetch(url):
    with urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'Mozilla/5.0'}),timeout=70) as r:
        assert r.status==200
        return r.read(),r.geturl()
def clean(text):return html.unescape(re.sub('<[^>]+>','',text)).strip()
def category(title):
    t=title.lower()
    if any(x in t for x in ['rocket','voyager','torpedo','cannonball','tank shell','interceptor','shock blast','incendiary','grenade']):return '02-Cohetes-y-artilleria'
    if any(x in t for x in ['shots','arcade bolts']):return '01-Energia-y-plasma'
    if any(x in t for x in ['spear','pike','dagger','blade','halberd','javelin']):return '04-Armas-arrojadizas'
    if any(x in t for x in ['arrow','silverbolt','explosive bolt']):return '03-Flechas-y-proyectiles'
    if any(x in t for x in ['banana','nutmissile','tc15','seed shot']):return '06-Especiales-y-paquetes'
    return '05-Magia-y-elementales'
def index():
    url=BASE+'/repositories/classic-sd-models.530/?tags%5B4%5D=i&authors%5B0%5D=Vinz';seen=set();entries=[];pages=[]
    while url:
        assert url not in seen;seen.add(url)
        data,actual=fetch(url);s=data.decode('utf8');page=EV/f'index-{len(pages)+1}.html';page.write_bytes(data)
        rows=re.split(r'<div class="bundle structItem ',s)[1:]
        assert rows,'No catalog rows: do not treat as empty catalog'
        for row in rows:
            author=re.search(r'data-author="([^"]+)"',row).group(1);assert author=='Vinz',author
            link=re.search(r'<a href="([^"]+)"[^>]*data-tp-primary="on"[^>]*>(.*?)</a>',row,re.S);assert link
            tags=[clean(x) for x in re.findall(r'<a[^>]*href="/repositories/[^\"]*\?tag=\d+"[^>]*>(.*?)</a>',row,re.S)]
            assert '#Missile' in tags,tags
            down=re.search(r'<a class="download" href="([^"]+)"',row);assert down
            count=re.search(r'<dt>Resources</dt>\s*<dd>([^<]+)</dd>',row)
            entries.append({'title':clean(link[2]),'url':urllib.parse.urljoin(BASE,html.unescape(link[1])),'author':author,'tags':tags,'listedResources':int(clean(count[1]).replace(',','')) if count else None,'download':urllib.parse.urljoin(BASE,html.unescape(down[1]))})
        pages.append({'url':url,'actual':actual,'path':str(page.relative_to(ROOT)),'rows':len(rows),'sha256':hashlib.sha256(data).hexdigest()})
        next_link=re.search(r'<link rel="next" href="([^"]+)"',s)
        url=urllib.parse.urljoin(BASE,html.unescape(next_link[1])) if next_link else None
    assert len({e['url'] for e in entries})==len(entries)
    (EV/'index.json').write_text(json.dumps({'pages':pages,'entries':entries},ensure_ascii=False,indent=2)+'\n')
    return entries

def archive(e):
    slug=e['url'].rstrip('/').split('/')[-1];folder=OUT/category(e['title'])/slug
    folder.mkdir(parents=True,exist_ok=True);archive=folder/'original.zip';manifest=folder/'manifest.json'
    if manifest.exists():
        old=json.loads(manifest.read_text());assert hashlib.sha256(archive.read_bytes()).hexdigest()==old['zipSha256'];return old
    data,url=fetch(e['download']);assert zipfile.is_zipfile(io.BytesIO(data)),'Not a ZIP'
    files=[]
    with zipfile.ZipFile(io.BytesIO(data)) as z:
        assert sum(i.file_size for i in z.infolist())<=512*1024*1024,'Unexpected archive expansion'
        assert z.testzip() is None,'CRC failure'
        paths=set()
        for item in z.infolist():
            if item.is_dir():continue
            path=PurePosixPath(item.filename.replace('\\','/'))
            assert not path.is_absolute() and '..' not in path.parts and ':' not in path.parts[0],path
            assert path not in paths,'Duplicate archive member';paths.add(path)
            assert item.external_attr>>16&0o170000!=0o120000,'Symbolic link in source ZIP'
            content=z.read(item);target=folder/'originales'/str(path);target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(content);files.append({'path':str(target.relative_to(folder)),'archivePath':item.filename,'bytes':len(content),'sha256':hashlib.sha256(content).hexdigest()})
    archive.write_bytes(data)
    record={k:v for k,v in e.items() if k!='download'}
    record.update({'date':datetime.datetime.now().astimezone().isoformat(),'category':category(e['title']),'folder':str(folder.relative_to(OUT)),'zip':'original.zip','zipBytes':len(data),'zipSha256':hashlib.sha256(data).hexdigest(),'crc':'PASS','files':files,'models':sum(x['path'].lower().endswith('.mdx') for x in files),'textures':sum(x['path'].lower().endswith(('.blp','.tga','.dds','.png')) for x in files)})
    manifest.write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n')
    (folder/'LEEME.txt').write_text(f"{e['title']}\nAutor listado: Vinz. Conservar créditos incluidos en originales.\nFuente: {e['url']}\nZIP y contenido intactos; no se han editado modelos ni certificados parches.\nClasificación local: {category(e['title'])}.\n")
    with LOCK:print(json.dumps({'title':e['title'],'models':record['models'],'zipCRC':'PASS'}),flush=True)
    return record

if __name__=='__main__':
    entries=index();print(json.dumps({'catalogPackages':len(entries)}),flush=True)
    results=[];failures=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        jobs={pool.submit(archive,e):e for e in entries}
        for job in concurrent.futures.as_completed(jobs):
            try:results.append(job.result())
            except Exception as error:
                item={'title':jobs[job]['title'],'url':jobs[job]['url'],'error':str(error)};failures.append(item);print(json.dumps({'FAIL':item}),flush=True)
    results.sort(key=lambda x:(x['category'],x['title']))
    output={'date':datetime.datetime.now().astimezone().isoformat(),'scope':'Hive Classic SD Models, author Vinz, tag Missile, complete pagination','listed':len(entries),'downloaded':len(results),'models':sum(x['models'] for x in results),'failures':failures,'entries':results}
    (OUT/'manifest.json').write_text(json.dumps(output,ensure_ascii=False,indent=2)+'\n');(EV/'download-result.json').write_text(json.dumps({k:v for k,v in output.items() if k!='entries'},indent=2)+'\n')
    print(json.dumps({k:v for k,v in output.items() if k!='entries'}),flush=True)
    if failures:raise SystemExit(1)
