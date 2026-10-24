from pathlib import Path
from PIL import Image
import numpy as np,json,re,subprocess,io
ROOT=Path(__file__).resolve().parents[1];run=sorted((ROOT/'evidence/texttag-lab').glob('run-*'))[-1];cases=json.loads((ROOT/'evidence/texttag-lab/cases.json').read_text());results=[]
for i,c in enumerate(cases):
 p=run/f'{i:02d}-{c["name"]}.png'
 if not p.exists():continue
 a=np.array(Image.open(p).convert('RGB'));mask=(a[:,:,0]>190)&(a[:,:,1]<120)&(a[:,:,2]>135);mask[:120]=False;mask[800:]=False;mask[:,1600:]=False
 ys,xs=np.where(mask);spans=[]
 for y in np.unique(ys):
  if not spans or y-spans[-1][-1]>2:spans.append([int(y)])
  else:spans[-1].append(int(y))
 measured=[]
 for span in spans:
  yy,xx=np.where(mask[span[0]:span[-1]+1]);measured.append({'y':span[0],'height':len(span),'left':int(xx.min()),'width':int(xx.max()-xx.min()+1)})
 text='';bbox=None
 if len(xs):
  bbox=[int(xs.min()),int(ys.min()),int(xs.max()+1),int(ys.max()+1)]
  # Analysis mask only; source screenshot remains untouched.
  temp=np.full(a.shape[:2],255,dtype=np.uint8);temp[mask]=0
  img=Image.fromarray(temp[max(120,bbox[1]-5):min(800,bbox[3]+5),max(0,bbox[0]-5):min(1600,bbox[2]+5)])
  img=img.resize((img.width*3,img.height*3));buf=io.BytesIO();img.save(buf,format='PNG')
  ocr=subprocess.run(['tesseract','stdin','stdout','--psm','6'],input=buf.getvalue(),capture_output=True);text=ocr.stdout.decode(errors='replace').strip()
 log=(run/f'TextTagLab-{i}.txt').read_text(errors='replace');n=re.search(r'nativeStringLength=(\d+)',log)
 results.append({'case':i,**c,'nativeBytes':int(n[1]) if n else None,'bbox':bbox,'visibleRowsApprox':max(1,round((bbox[3]-bbox[1])/(1080*c['font']))) if bbox else 0,'inkSpans':len(spans),'lineMetrics':measured,'ocr':text,'finDetectedOCR':bool(re.search(r'\bFIN\b',text)),'screenshot':str(p)})
(run/'measurements.json').write_text(json.dumps({'pixels':[1920,1080],'mask':'R>190,G<120,B>135; x<1600,120<=y<800; merges y gaps<=2; bounding ink, not engine rectangle','ocr':'Tesseract auxiliary, requires visual confirmation','cases':results},indent=2,ensure_ascii=False))
for c in results:print(c['case'],c['name'],'rows',c['visibleRowsApprox'],'bbox',c['bbox'],'bytes',c['nativeBytes'],'FIN',c['finDetectedOCR'])
