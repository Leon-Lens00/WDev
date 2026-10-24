from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
ROOT=Path(__file__).resolve().parents[1];EV=ROOT/'evidence/x3-v11';OUT=ROOT/'exports/megaman-x3-buster-v11/Previews';OUT.mkdir(exist_ok=True)
font=ImageFont.truetype('/usr/share/fonts/TTF/DejaVuSans.ttf',16)
def tile(path,box,label):
 im=Image.open(path).convert('RGB').crop(box);res=Image.new('RGB',(im.width,im.height+30),'#111a24');res.paste(im,(0,30));ImageDraw.Draw(res).text((10,6),label,font=font,fill='white');return res
for kind,label in [('stand','V11 · vuelo · muestra ralentizada'),('birth','V11 · Birth · formación local · ralentizado'),('death','V11 · Death · estallido en la punta · ralentizado')]:
 fs=sorted((EV/'frames-3d').glob(kind+'-*.png'));frames=[tile(p,(470,200,1210,620),label) for p in fs]
 duration=[80]*len(fs) if kind=='stand' else [160]*7+[80] if kind=='birth' else [80]*8+[160]*8
 if kind=='death':frames.append(tile(EV/'death-cleared.png',(470,200,1210,620),label));duration.append(700)
 frames[0].save(OUT/(kind+'-3d.gif'),save_all=True,append_images=frames[1:],duration=duration,loop=0,disposal=2)
compare=tile(EV/'compare-3d.png',(300,230,1230,570),'V10 anterior                                    V11 · envoltura alargada y verde reforzado');compare.save(OUT/'comparacion-3d.png')
rows=[]
for kind,ids in [('birth',[0,2,5,7]),('death',[0,3,7,12])]:
 for i in ids:
  im=tile(EV/'frames-3d'/f'{kind}-{i:02}.png',(500,225,1200,590),kind+' · fase '+str(i+1));im.thumbnail((420,237));rows.append(im)
sheet=Image.new('RGB',(840,4*237),'#111a24')
for i,im in enumerate(rows):sheet.paste(im,((i%2)*420,(i//2)*237))
sheet.save(OUT/'birth-death-fases.png')
if (EV/'final-stand-scale1/010.png').exists():tile(EV/'final-stand-scale1/010.png',(610,370,1430,520),'Warcraft III 1.27b · escala 1 · V10 izquierda / V11 derecha').save(OUT/'comparacion-juego-escala1.png')
print(OUT)

rows=[]
for name,label in [('final-scale05','Escala 0.5'),('final-stand-scale1','Escala 1'),('final-scale24','Escala 2.4')]:
 rows.append(tile(EV/name/'005.png',(450,350,1350,540),label+' · V10 izquierda / V11 derecha · captura nativa'))
sheet=Image.new('RGB',(900,660),'#111a24')
for i,im in enumerate(rows):sheet.paste(im,(0,220*i))
sheet.save(OUT/'escalas-en-juego.png')
for name in ['native-birth-sheet.png','native-impact-sheet.png','native-impact-slow-sheet.png']:
 Image.open(EV/name).save(OUT/name)
