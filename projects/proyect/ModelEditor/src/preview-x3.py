"""Contact sheets of actual Classic 1.27b captures, with no painted model pixels."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
ROOT=Path(__file__).resolve().parents[1];EV=ROOT/'evidence/x3-v1';OUT=ROOT/'exports/megaman-x3-buster-v1'
font='/usr/share/fonts/TTF/DejaVuSans.ttf'
if not Path(font).exists():font='/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf'
F=lambda n:ImageFont.truetype(font,n)
source=Image.open(EV/'game-scale3.png').convert('RGB');flash=Image.open(EV/'birth-verified/000.png').convert('RGB')
canvas=Image.new('RGB',(1440,920),'#15191f');d=ImageDraw.Draw(canvas)
d.text((22,16),'Mega Man X3 · Componentes 3D v1',font=F(30),fill='white')
d.text((22,57),'Capturas reales de Warcraft III Classic 1.27b · recortes ampliados',font=F(19),fill='#b9c5d6')
crops={
 'A · Buster cargado':(source,(470,225,650,325)),
 'B · Grupo orbital opcional':(source,(825,385,930,530)),
 'C · Núcleo fusionado':(source,(1000,380,1220,525)),
 'Flash de unión':(flash,(510,620,680,770)),
}
notes=['Segundo pulso reutilizable; punta en el origen.','Giro local; el avance lo define tu sistema.','Los satélites se crean con los orbes individuales.','Una ejecución; expansión y desvanecimiento.']
positions=[(16,100),(496,100),(976,100),(496,505)]
records=[]
for ((title,(im,box)),note,(x,y)) in zip(crops.items(),notes,positions):
 d.rounded_rectangle((x,y,x+448,y+385),14,fill='#242b35');d.text((x+16,y+14),title,font=F(23),fill='white')
 crop=im.crop(box);crop.thumbnail((416,270),Image.Resampling.LANCZOS)
 factor=min(416/(box[2]-box[0]),270/(box[3]-box[1]));crop=im.crop(box).resize((round((box[2]-box[0])*factor),round((box[3]-box[1])*factor)),Image.Resampling.LANCZOS)
 canvas.paste(crop,(x+(448-crop.width)//2,y+61+(270-crop.height)//2));
 # Wrap captions without altering source pixels.
 import textwrap
 for j,line in enumerate(textwrap.wrap(note,37)):d.text((x+14,y+337+j*21),line,font=F(17),fill='#c6d1e1')
 records.append({'title':title,'source':'birth-verified/000.png' if im is flash else 'game-scale3.png','crop':box})
x,y=16,505;d.rounded_rectangle((x,y,x+448,y+385),14,fill='#242b35');d.text((x+16,y+14),'Orbes individuales',font=F(23),fill='white')
for i,(label,box) in enumerate([('Verde',(846,232,934,310)),('Naranja',(1115,232,1203,310)),('Cian',(552,433,640,511))]):
 crop=source.crop(box).resize((132,117),Image.Resampling.LANCZOS);canvas.paste(crop,(x+12+144*i,y+130));d.text((x+20+144*i,y+262),label,font=F(19),fill='white');records.append({'title':label,'source':'game-scale3.png','crop':box})
d.text((x+14,y+338),'Tres MDX separados con sus recursos.',font=F(17),fill='#c6d1e1')
x,y=976,505;d.rounded_rectangle((x,y,x+448,y+385),14,fill='#242b35');d.text((x+16,y+14),'Cómo usar las piezas',font=F(23),fill='white')
lines=['• 7 modelos MDX + sus fuentes MDL','• Birth / Stand / Death','• Frente +X; punta en (0, 0, 0)','• Núcleo claro y envolvente de color','','Tu sistema decide la trayectoria,','el encuentro de los dos lanzamientos','y cuándo crear la forma fusionada.','','Interpretación 3D para revisión visual.']
for i,line in enumerate(lines):d.text((x+16,y+66+i*28),line,font=F(19 if i<4 else 17),fill='#d4deed')
canvas.save(OUT/'MUESTRAS.png');(EV/'preview-crops.json').write_text(json.dumps(records,indent=2))
# Animated comparison of the actual local orbit and rings, at their recorded timing.
frames=[];timing=json.loads((EV/'stand-verified/timing.json').read_text());durations=[]
for i in range(5,22):
 im=Image.open(EV/f'stand-verified/{i:03}.png').convert('RGB');frame=Image.new('RGB',(960,340),'#15191f');fd=ImageDraw.Draw(frame)
 for j,(title,box) in enumerate([('A · Cargado',(485,220,655,325)),('B · Órbita local',(830,385,945,535)),('C · Fusionado',(1030,380,1220,530))]):
  crop=im.crop(box);scale=min(300/crop.width,225/crop.height);crop=crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.LANCZOS);frame.paste(crop,(j*320+(320-crop.width)//2,65+(225-crop.height)//2));fd.text((j*320+14,15),title,font=F(22),fill='white')
 fd.text((14,307),'Captura de modelos en 1.27b · sin recorrido ni fusión programados',font=F(17),fill='#b9c5d6');frames.append(frame);durations.append(round(1000*(timing[i+1]['t']-timing[i]['t'])))
frames[0].save(OUT/'MUESTRA-ANIMADA.gif',save_all=True,append_images=frames[1:],duration=durations,loop=0,optimize=False)
print('MUESTRAS.png and MUESTRA-ANIMADA.gif generated from actual captures')
