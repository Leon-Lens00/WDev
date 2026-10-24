"""Prepare frame apertures, deterministic signal atlas and native portrait dependencies."""
from pathlib import Path
from PIL import Image, ImageDraw
import json,hashlib,shutil,random
from textures import blp,OUT,ART,ROOT
OUT.mkdir(parents=True,exist_ok=True)
result=[]
for color,source in [('Red','conversation-frame-v1.png'),('Blue','conversation-frame-blue-v1.png')]:
    image=Image.open(ART/source).convert('RGBA')
    for l,r in [(.063,.237),(.766,.940)]:
        ImageDraw.Draw(image).rectangle((round(l*image.width),round(.148*image.height),round(r*image.width)-1,round(.473*image.height)-1),fill=(0,0,0,0))
    image.save(ART/f'frame-open-{color.lower()}.png')
    result.append(blp(image.resize((1024,512),Image.Resampling.LANCZOS),f'FrameOpen{color}.blp'))
rng=random.Random(271828);noise=Image.new('RGBA',(256,256))
for y in range(256):
    for x in range(256):
        v=rng.randrange(32,240);noise.putpixel((x,y),(v,v,v,255))
noise.save(ART/'signal-atlas.png');result.append(blp(noise,'Signal.blp'))
result.append(blp(Image.new('RGBA',(8,8),(104,111,116,255)),'PortraitBackground.blp'))
result.append(blp(Image.new('RGBA',(8,8),(230,245,255,255)),'Line.blp'))
Image.new('RGBA',(8,8),(230,245,255,255)).save(ART/'Line.png')
provenance=json.loads((ROOT.parents[1]/'work/dialogue-animated-20261022/originals/provenance.json').read_text())
for item in provenance:
    if not item['file'].endswith('.blp'):continue
    destination=ROOT/'assets/UI/Dialogue/Portraits'/Path(item['file']).name
    shutil.copy2(item['file'],destination)
    browser=ART/'portraits'/destination.name;browser.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(destination,browser)
result.append(blp(Image.new('RGBA',(8,8),(255,3,3,255)),'PortraitTeamColor.blp'))
shutil.copy2(OUT/'PortraitTeamColor.blp',ART/'portraits/PortraitTeamColor.blp')
shutil.copy2(OUT/'PortraitBackground.blp',ART/'portraits/PortraitBackground.blp')
Image.new('RGBA',(8,8),(255,3,3,255)).save(ART/'portraits/PortraitTeamColor.png')
Image.new('RGBA',(8,8),(104,111,116,255)).save(ART/'portraits/PortraitBackground.png')
for name in ['FrameOpenRed','FrameOpenBlue','Signal','PortraitBackground','Line']:
    shutil.copy2(OUT/(name+'.blp'),ART/(name+'.blp'))
lib=Path('/home/snz/Documentos/Slendytubbies-WC3-recuperado-2026-10-09/Personajes-WC3-127b/migracion-linux/runtime/node_modules/mdx-m3-viewer')
(ART/'vendor').mkdir(exist_ok=True)
shutil.copy2(lib/'dist/umd/viewer.min.js',ART/'vendor/mdx-m3-viewer-5.12.js')
shutil.copy2(lib/'LICENSE',ART/'vendor/mdx-m3-viewer-LICENSE.txt')
(ROOT/'evidence/portrait-textures.json').write_text(json.dumps({'textures':result,'native':provenance},indent=2))
print('Frame apertures,16 signal frames, native textures and local viewer prepared.')
