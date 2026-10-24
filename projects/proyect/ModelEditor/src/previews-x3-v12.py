from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1];EV=ROOT/'evidence/x3-v12';OUT=ROOT/'exports/megaman-x3-buster-v12/Previews';OUT.mkdir(exist_ok=True)
font=ImageFont.truetype('/usr/share/fonts/TTF/DejaVuSans.ttf',16)
def tile(p,box,label):
 im=Image.open(p).convert('RGB').crop(box);o=Image.new('RGB',(im.width,im.height+30),'#111a24');o.paste(im,(0,30));ImageDraw.Draw(o).text((10,6),label,font=font,fill='white');return o
for kind,label in [('stand','V12 · cola abierta y rayos aditivos · muestra a 1/4 de velocidad'),('birth','V12 · aparición · muestra ralentizada'),('death','V12 · impacto · muestra ralentizada')]:
 frames=[tile(p,(470,200,1210,620),label) for p in sorted((EV/'frames-3d').glob(kind+'-*.png'))]
 frames[0].save(OUT/(kind+'-3d.gif'),save_all=True,append_images=frames[1:],duration=80,loop=0,disposal=2)
tile(EV/'compare-3d.png',(300,230,1230,570),'V11 anterior                                    V12 · curva suave y cola abierta').save(OUT/'comparacion-3d.png')
rows=[]
for kind,ids in [('birth',[0,3,8,14]),('death',[0,3,8,19])]:
 for i in ids:
  im=tile(EV/'frames-3d'/f'{kind}-{i:02}.png',(500,225,1200,590),kind+' · '+str((i+1)*20)+' ms');im.thumbnail((420,237));rows.append(im)
sheet=Image.new('RGB',(840,4*237),'#111a24')
for i,im in enumerate(rows):sheet.paste(im,((i%2)*420,(i//2)*237))
sheet.save(OUT/'birth-death-fases.png')
print(OUT)
if (EV/'final-scale24/010.png').exists():
 rows=[]
 for folder,label in [('final-scale05','Escala0.5'),('final-stand-scale1','Escala1'),('final-scale24','Escala2.4')]:
  rows.append(tile(EV/folder/'010.png',(450,350,1350,540),label+' · V11 izquierda / V12 derecha · Warcraft1.27b'))
 sheet=Image.new('RGB',(900,660),'#111a24')
 for i,im in enumerate(rows):sheet.paste(im,(0,220*i))
 sheet.save(OUT/'escalas-en-juego.png')
 tile(EV/'final-stand-scale1/010.png',(610,370,1430,520),'Escala1 · V11 izquierda / V12 derecha · Warcraft1.27b').save(OUT/'comparacion-juego-escala1.png')
 for folder,filename in [('final-birth-slow','aparicion-en-juego.png'),('final-impact-slow','impacto-en-juego.png')]:
  sheet=Image.new('RGB',(900,4*230),'#111a24')
  for j,i in enumerate([1,2,3,5,7,9,15,24]):
   row=tile(EV/folder/f'{i:03}.png',(900,315,1350,515),'V12 · captura'+str(i)+' · animación0.25x')
   sheet.paste(row,((j%2)*450,(j//2)*230))
  sheet.save(OUT/filename)
