"""Label original reference frames, preserving their pixel colors and provenance."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import subprocess,json
ROOT=Path(__file__).resolve().parents[1]/'references/megaman-x3'
fontfile=subprocess.check_output(['fc-match','-f','%{file}','DejaVu Sans'],text=True)
font=ImageFont.truetype(fontfile,22);small=ImageFont.truetype(fontfile,17)
def frame(name,index):
    with Image.open(ROOT/'originales'/name) as im:
        im.seek(index);return im.convert('RGBA')
canvas=Image.new('RGB',(1440,630),(22,25,31));d=ImageDraw.Draw(canvas)
cases=[('A · Buster básico cargado','buster-estandar.gif',8,(0,0,150,47),'Pulso cargado de la forma básica'),('B · Antes de la fusión','tenor-usuario.gif',56,(0,0,150,133),'Orbes de colores + segundo pulso'),('C · Súper carga fusionada','tenor-usuario.gif',75,(0,0,150,133),'Núcleo rosa, aros verdes y satélites')]
metadata=[]
for col,(title,name,index,crop,subtitle) in enumerate(cases):
    x=col*480
    d.rounded_rectangle((x+8,8,x+472,580),radius=14,fill=(32,36,45))
    d.text((x+25,26),title,font=font,fill='white')
    im=frame(name,index).crop(crop);im=im.resize((im.width*3,im.height*3),Image.Resampling.NEAREST)
    y=125+(399-im.height)//2;canvas.paste(im,(x+15,y),im)
    d.text((x+24,535),subtitle,font=small,fill=(205,211,222))
    metadata.append({'label':title,'source':'originales/'+name,'frame':index,'crop':crop,'scale':3,'method':'nearest, no recolor or repaint'})
d.text((22,598),'Referencias 2D · Mega Man X3 / Capcom · GIF del usuario + Retropixel · Todavía no son modelos MDX',font=small,fill=(190,199,214))
canvas.save(ROOT/'muestras-ABC.png')
(ROOT/'muestras-ABC.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n')
# Short animated excerpts use only original frames and original durations.
for label,start,end in [('B-previos',24,58),('C-fusion',62,106)]:
    frames=[];durations=[]
    with Image.open(ROOT/'originales/tenor-usuario.gif') as im:
        for i in range(start,end):im.seek(i);frames.append(im.convert('RGBA'));durations.append(im.info.get('duration',20))
    frames[0].save(ROOT/(label+'.gif'),save_all=True,append_images=frames[1:],duration=durations,loop=0,disposal=2)
print(ROOT/'muestras-ABC.png')
