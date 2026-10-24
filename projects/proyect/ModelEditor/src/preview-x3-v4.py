"""Presentation assembled exclusively from captured real MDX/game renders."""
from pathlib import Path
from PIL import Image, ImageOps, ImageDraw, ImageFont
import json

ROOT=Path(__file__).resolve().parents[1]
EV=ROOT/'evidence/x3-v4'
OUT=ROOT/'exports/megaman-x3-buster-v4'
font='/usr/share/fonts/TTF/DejaVuSans.ttf'
def ft(n):return ImageFont.truetype(font,n)
sheet=Image.new('RGB',(1560,1050),'#101720');d=ImageDraw.Draw(sheet)
d.text((40,24),'MEGA MAN X3  /  BUSTER V4',font=ft(34),fill='#f3f6ff')
d.text((40,76),'Modelos MDX reales · identidad, volumen y residuos · Warcraft III Classic 1.27b',font=ft(19),fill='#acb9cb')
panels=[('A · CARGADO','A-lateral-final.png',(420,310,890,670),'Blanco / rosa · copa azul · punta anclada'),('B · ORBES','Grupo-Orbital-3d.png',(430,270,900,720),'Verde / naranja · cian adicional · piezas separadas'),('C · FUSIÓN','C-conjunto-final.png',(390,270,890,720),'Centro rosa · aros verdes · conjunto opcional')]
for i,(label,file,box,caption) in enumerate(panels):
 x=30+510*i
 d.rounded_rectangle((x,125,x+490,780),radius=16,fill='#19232e')
 d.text((x+18,145),label,font=ft(24),fill='white')
 ref=Image.open(ROOT/'viewer/x3-v4'/('reference-'+chr(65+i)+'.png')).convert('RGB');ref=ImageOps.contain(ref,(180,130),Image.Resampling.NEAREST)
 sheet.paste(ref,(x+245-ref.width//2,190+(130-ref.height)//2))
 d.text((x+18,325),'Referencia X3 / Capcom',font=ft(15),fill='#acb9cb')
 im=Image.open(EV/file).convert('RGB').crop(box);im=ImageOps.contain(im,(465,340),Image.Resampling.LANCZOS)
 sheet.paste(im,(x+(490-im.width)//2,365+(340-im.height)//2))
 d.text((x+18,731),caption,font=ft(14),fill='#d7e0ef')
d.text((40,817),'Núcleo claro + borde de color + partículas breves + estelas al desplazarse',font=ft(23),fill='#e1ebff')
d.text((40,862),'8 componentes · Birth / Stand / Death · texturas propias incluidas',font=ft(20),fill='#acb9cb')
d.text((40,900),'Geometría de vuelo hasta X=0. La trayectoria y la lógica de fusión pertenecen al juego.',font=ft(18),fill='#acb9cb')
d.text((40,959),'Capturas del visor 3D. Movimiento comprobado después en YDWE, un jugador, pantalla 3.',font=ft(17),fill='#8b9bb0')
sheet.save(OUT/'MUESTRAS.png')
records=json.loads((EV/'move-verified/timing.json').read_text());frames=[];dur=[]
for i,r in enumerate(records):
 im=Image.open(EV/'move-verified'/f'{i:03}.png').convert('RGB').crop((380,165,1480,790));im.thumbnail((1000,568));frames.append(im)
 dur.append(max(30,round(1000*(records[i+1]['t']-r['t']))) if i+1<len(records) else 150)
frames[0].save(OUT/'MOVIMIENTO.gif',save_all=True,append_images=frames[1:],duration=dur,loop=0,optimize=False)
Image.open(EV/'stand-verified/012.png').save(OUT/'EN-JUEGO.png')
Image.open(EV/'A-frontal-final.png').save(OUT/'FRENTE-3D.png')
print('Muestras reales, movimiento, frente y captura nativa guardados')
