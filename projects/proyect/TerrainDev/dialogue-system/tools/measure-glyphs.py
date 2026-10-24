"""Recover repeating glyph advances from the native metric grid; screenshots stay untouched."""
from pathlib import Path
from PIL import Image
import numpy as np,json
ROOT=Path(__file__).resolve().parents[1]
glyphs=json.loads((ROOT/'evidence/metric-glyphs.json').read_text());results=[]
for n,g in enumerate(glyphs):
 page,slot=divmod(n,12);col,row=slot%4,slot//4
 a=np.array(Image.open(ROOT/f'evidence/metrics-final-{page:02}.png').convert('RGB'))
 # Grids measured in a 1920x1080 client. Capture text only, without the white title.
 x=100+440*col;y=180+180*row
 crop=a[y-70:y+40,max(0,x-12):x+350];mask=(crop[:,:,0]>200)&(crop[:,:,1]<110)&(crop[:,:,2]>140)
 yy,xx=np.where(mask)
 if not len(xx):raise RuntimeError(f'Missing glyph {n} {g!r}')
 mask=mask[yy.min():yy.max()+1,xx.min():xx.max()+1]
 scores=[]
 for d in range(max(2,round(mask.shape[1]/8*.72)),min(55,round(mask.shape[1]/8*1.35)+1,mask.shape[1])):
  a1,b1=mask[:,:-d],mask[:,d:];union=np.count_nonzero(a1|b1);score=np.count_nonzero(a1&b1)/union if union else 0
  scores.append((score,d))
 if g==' ':
  cols=np.where(mask.any(axis=0))[0];groups=[]
  for v in cols:
   if not groups or v-groups[-1][-1]>3:groups.append([int(v)])
   else:groups[-1].append(int(v))
  # W + 8 spaces + W: the W advance is recovered independently below.
  result={'glyph':g,'wStartDistance':groups[-1][0]-groups[0][0],'groups':groups}
 else:
  best=max(s for s,d in scores);d=min(d for s,d in scores if s>=best-.005)
  result={'glyph':g,'advance':d,'periodScore':round(best,5),'inkWidth':mask.shape[1],'inkHeight':mask.shape[0]}
 results.append(result)
w=next(x['advance'] for x in results if x['glyph']=='W');results[0]['advance']=(results[0]['wStartDistance']-w)/8
out={'nativeHeight':.027,'client':[1920,1080],'repeatCount':8,'gameIdentity':json.loads((ROOT/'evidence/game-identity-composition-2.json').read_text()),'measurements':results}
(ROOT/'evidence/native-glyph-metrics.json').write_text(json.dumps(out,ensure_ascii=False,indent=2))
for r in results:print(repr(r['glyph']),r['advance'],r.get('periodScore'))
