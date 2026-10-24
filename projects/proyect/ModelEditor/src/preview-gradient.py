"""Evidence sheet: labeled crops of one unaltered Warcraft capture."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import subprocess,json
ROOT=Path(__file__).resolve().parents[1]
source=ROOT/'evidence/brillo/comparison-final-scale3.png'
im=Image.open(source).convert('RGB')
font_path=subprocess.check_output(['fc-match','-f','%{file}','DejaVu Sans'],text=True)
font=ImageFont.truetype(font_path,19);small=ImageFont.truetype(font_path,15)
out=Image.new('RGB',(1120,610),(23,26,32));d=ImageDraw.Draw(out)
for text,x in [('Original',320),('Pack anterior',600),('Revisión con brillo',880)]:d.text((x,18),text,font=font,fill='white',anchor='mt')
boxes=[('Vol. I\nAzul',(400,210,1390,305)),('Vol. I\nRojo',(400,325,1390,425)),('Vol. II\nAzul',(400,450,1390,570)),('Vol. II\nRojo',(400,615,1390,740))]
for i,(label,box) in enumerate(boxes):
 y=58+i*130;crop=im.crop(box);out.paste(crop,(120,y));d.multiline_text((12,y+25),label,font=font,fill='white',spacing=8)
d.text((120,592),'Capturas de Warcraft III 1.27b · escala 3 · recortes sin alterar el color',font=small,fill=(195,200,210))
out.save(ROOT/'evidence/brillo/comparacion-final.png')
(ROOT/'evidence/brillo/preview-crops.json').write_text(json.dumps({'source':str(source),'crops':[{'label':a,'box':b} for a,b in boxes],'operation':'crop and label only; no pixel recolor or enhancement'},indent=2)+'\n')
