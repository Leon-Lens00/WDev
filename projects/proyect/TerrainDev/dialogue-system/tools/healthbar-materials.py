#!/usr/bin/env python3
"""Editable vector housings, static MDX photographs and Classic BLP1 materials.

Run with the project's existing Pillow/numpy environment. Export-only: the
dialogue map and its active assets are never written by this tool.
"""
from pathlib import Path
import hashlib
import json
import math
import shutil
import struct
import sys
import zipfile
import numpy as np
from PIL import Image, ImageDraw
import textures

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'exports/health-bars-v1'
PNG = OUT / 'png'
GAME = OUT / 'game/UI/HealthBars'
STUDIO = Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/healthbars')


def photograph(character):
    spec = json.loads((OUT / 'sources' / (character + '-render.json')).read_text())
    size = spec['size']
    pixels = np.zeros((size, size, 4), dtype=np.float64)
    pixels[:] = [20, 29, 38, 255]
    depth = np.full((size, size), np.inf)
    maps = []
    for texture in spec['textures']:
        if texture.get('replaceable'):
            maps.append(np.array([[[255, 3, 3, 255]]], dtype=np.uint8))
        else:
            maps.append(np.frombuffer((OUT / 'sources' / texture['raw']).read_bytes(), dtype=np.uint8)
                        .reshape(texture['height'], texture['width'], 4))
    for mesh in spec['meshes']:
        points, uv = np.array(mesh['vertices']), np.array(mesh['uv']).reshape(-1, 2)
        for layer in mesh['layers']:
            texture = maps[layer['texture']]
            for indices in np.array(mesh['faces']).reshape(-1, 3):
                triangle = points[indices]
                if np.any(triangle[:, 2] <= 0):
                    continue
                lo = np.maximum(0, np.floor(triangle[:, :2].min(axis=0)).astype(int))
                hi = np.minimum(size - 1, np.ceil(triangle[:, :2].max(axis=0)).astype(int))
                if np.any(hi < lo):
                    continue
                x, y = np.meshgrid(np.arange(lo[0], hi[0]+1)+.5, np.arange(lo[1], hi[1]+1)+.5)
                a, b, c = triangle[:, :2]
                denom = (b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
                if abs(denom) < 1e-8:
                    continue
                wa = ((b[1]-c[1])*(x-c[0])+(c[0]-b[0])*(y-c[1]))/denom
                wb = ((c[1]-a[1])*(x-c[0])+(a[0]-c[0])*(y-c[1]))/denom
                weights = np.stack([wa, wb, 1-wa-wb], axis=-1)
                inverse = (weights/triangle[:, 2]).sum(axis=-1)
                z = 1/np.maximum(1e-12, inverse)
                target = depth[lo[1]:hi[1]+1, lo[0]:hi[0]+1]
                keep = (weights.min(axis=-1) >= -1e-7) & (z <= target+.0001)
                perspective = weights/triangle[:, 2]/np.maximum(1e-12, inverse[..., None])
                texcoord = perspective @ uv[indices]
                tx = np.clip((texcoord[..., 0]*texture.shape[1]).astype(int), 0, texture.shape[1]-1)
                ty = np.clip((texcoord[..., 1]*texture.shape[0]).astype(int), 0, texture.shape[0]-1)
                sample = texture[ty, tx].astype(float)
                alpha = sample[..., 3]/255*layer['alpha']
                if layer['filter'] == 1:
                    keep &= alpha >= .75
                else:
                    keep &= alpha > .001
                region = pixels[lo[1]:hi[1]+1, lo[0]:hi[0]+1]
                mixed = sample[..., :3]*alpha[..., None]+region[..., :3]*(1-alpha[..., None])
                region[..., :3][keep] = mixed[keep]
                target[keep] = z[keep]
    image = Image.fromarray(np.clip(pixels, 0, 255).astype(np.uint8), 'RGBA')
    image = image.resize((128, 128), Image.Resampling.LANCZOS)
    image.save(OUT / 'sources' / ('portrait-' + character + '.png'))
    return image, {k: spec[k] for k in ['source', 'sourceSha256', 'sequence', 'frame', 'elapsed', 'camera', 'photoFraming']}


def housing(theme, height, texture_height):
    factor = 4
    image = Image.new('RGBA', (128*factor, texture_height*factor))
    draw = ImageDraw.Draw(image)
    svg = []
    accent, base, inset = (('#48baff', '#082a45', '#174d75') if theme == 'Blue'
                           else ('#e26b78', '#350b16', '#722034'))
    def polygon(points, fill, stroke=None, width=1):
        pts = [(round(x*factor), round(y*factor)) for x, y in points]
        draw.polygon(pts, fill=fill)
        if stroke:
            draw.line(pts+[pts[0]], fill=stroke, width=width*factor, joint='curve')
        svg.append('<polygon points="'+ ' '.join(f'{x},{y}' for x, y in points)
                   +f'" fill="{fill}" stroke="{stroke or "none"}" stroke-width="{width}"/>')
    def line(points, color, width=1):
        draw.line([(round(x*factor), round(y*factor)) for x, y in points], fill=color, width=width*factor)
        svg.append('<polyline points="'+' '.join(f'{x},{y}' for x, y in points)
                   +f'" fill="none" stroke="{color}" stroke-width="{width}"/>')
    bottom = height-100
    polygon([(54,3),(74,3),(81,10),(81,bottom),(114,bottom+16),
             (114,height-15),(102,height-3),(26,height-3),(14,height-15),
             (14,bottom+16),(47,bottom),(47,10)], '#030910', '#d8e9f6', 2)
    polygon([(56,7),(72,7),(77,12),(77,bottom+3),(109,bottom+19),
             (109,height-17),(100,height-8),(28,height-8),(19,height-17),
             (19,bottom+19),(51,bottom+3),(51,12)], base, inset, 2)
    line([(56,10),(72,10),(75,16),(75,bottom+5)], accent)
    line([(53,16),(53,bottom+5),(23,bottom+21),(23,height-20)], accent)
    polygon([(54,20),(74,20),(74,bottom-1),(54,bottom-1)], '#0b111a', '#a5b4be')
    for y in range(28, bottom-1, 12):
        line([(55,y),(73,y)], '#172434')
    for x in range(60,74,8):
        line([(x,21),(x,bottom-2)], '#172434')
    polygon([(59,11),(69,11),(69,15),(59,15)], '#d4faff', accent)
    py = height-85
    # Erase the independent portrait aperture; preserve its silver bezel.
    aperture = [(34,py),(94,py),(98,py+4),(98,py+60),(94,py+64),
                (34,py+64),(30,py+60),(30,py+4)]
    draw.polygon([(x*factor,y*factor) for x,y in aperture], fill=(0,0,0,0))
    line(aperture+[aperture[0]], '#c6d9e4', 2)
    polygon([(34,height-19),(94,height-19),(99,height-14),(94,height-9),
             (34,height-9),(29,height-14)], '#020c17', accent)
    # SVG aperture mask gives the same editable source topology as the PNG.
    points = ' '.join(f'{x},{y}' for x,y in aperture)
    document = f'<svg xmlns="http://www.w3.org/2000/svg" width="128" height="{texture_height}" viewBox="0 0 128 {texture_height}"><defs><mask id="aperture"><rect width="128" height="{texture_height}" fill="white"/><polygon points="{points}" fill="black"/></mask></defs><g mask="url(#aperture)">'+''.join(svg)+f'</g><polygon points="{points}" fill="none" stroke="#c6d9e4" stroke-width="2"/></svg>'
    (OUT / 'sources' / ('Frame'+theme+'.svg')).write_text(document)
    return image.resize((128,texture_height),Image.Resampling.LANCZOS), {
        'textureSize':[128,texture_height], 'contentRect':[0,0,128,height],
        'lifeRect':[59,21,10,bottom-23], 'portraitRect':[32,py,64,64],
        'readoutRect':[31,height-19,66,12], 'frame':'Frame'+theme,
        'contentVMax':height/texture_height}


def fill(critical=False):
    image=Image.new('RGBA',(16,256))
    for y in range(256):
        t=y/255
        rgb=(255,round(50+85*t),12) if critical else (round(42+213*t),255,8)
        for x in range(16):
            multiplier=.77 if x in (0,15) else .92 if x in (1,14) else 1
            image.putpixel((x,y),tuple(round(c*multiplier) for c in rgb)+(255,))
    return image


def main():
    for p in [PNG,GAME,STUDIO,OUT/'sources']:
        p.mkdir(parents=True,exist_ok=True)
    snapshots={}
    materials={}
    for id in ['paladin','tauren']:
        materials['Portrait'+id.title()],snapshots[id]=photograph(id)
    materials['FrameBlue'],player=housing('Blue',256,256)
    materials['FrameRed'],enemy=housing('Red',448,512)
    materials['LifeNormal'],materials['LifeCritical']=fill(),fill(True)
    textures.OUT=GAME
    entries=[]
    for name,image in materials.items():
        image.save(PNG/(name+'.png'))
        record=textures.blp(image,name+'.blp')
        record.update(name=name,bytes=(GAME/(name+'.blp')).stat().st_size)
        record['png']='png/'+name+'.png'
        entries.append(record)
        # Preview real quantized BLP texels, rather than the preconversion PNG.
        raw=(GAME/(name+'.blp')).read_bytes()
        offset=struct.unpack_from('<I',raw,28)[0]
        w,h=image.size
        palette=np.frombuffer(raw[156:1180],dtype=np.uint8).reshape(256,4)
        indices=np.frombuffer(raw[offset:offset+w*h],dtype=np.uint8).reshape(h,w)
        rgba=palette[indices][...,[2,1,0,3]].copy()
        rgba[...,3]=np.frombuffer(raw[offset+w*h:offset+2*w*h],dtype=np.uint8).reshape(h,w)
        (OUT/'preview').mkdir(exist_ok=True)
        Image.fromarray(rgba,'RGBA').save(OUT/'preview'/(name+'.png'))
        shutil.copy2(OUT/'preview'/(name+'.png'),STUDIO/(name+'.png'))
    contract={'version':1,'target':'Warcraft III Classic 1.27b','maxTextureDimension':512,
              'player':player,'enemy':enemy,'enemyLifeHeightRatio':enemy['lifeRect'][3]/player['lifeRect'][3],
              'portraits':{'paladin':{'name':'Paladín','texture':'PortraitPaladin'},'tauren':{'name':'Tauren','texture':'PortraitTauren'}},
              'fill':{'normal':'LifeNormal','critical':'LifeCritical','criticalAtPercent':20,'anchor':'bottom','uvPolicy':'crop top of full fill, do not rescale its gradient'},
              'layersBackToFront':['portrait','frame','fill inside lifeRect','dynamic text inside readoutRect'],
              'notes':'Rectangles are top-left pixel coordinates inside texture. Enemy geometry uses only contentRect: vMax=448/512. BLP portraits are static pictures, not animated actors.'}
    (OUT/'healthbars.json').write_text(json.dumps(contract,indent=2,ensure_ascii=False)+'\n')
    shutil.copy2(OUT/'healthbars.json',STUDIO/'healthbars.json')
    active=ROOT/'TerrainDev-Dialogue.w3x'
    manifest={'target':'Classic 1.27b / BLP1 palette / alpha8 / complete mipmaps',
              'textures':entries,'totalBlpBytes':sum(e['bytes'] for e in entries),
              'portraitSources':snapshots,'nativeTested':False,'mapIntegrated':False,
              'activeMapSha256':hashlib.sha256(active.read_bytes()).hexdigest(),
              'preview':'http://127.0.0.1:4317/healthbars.html'}
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
    readme=f'''Materiales de barras de vida · Classic 1.27b

Jugador: carcasa azul128×256. Enemigo: granate128×512; contenido128×448,
UV vertical máximo0.875. Canal de vida enemigo{contract['enemyLifeHeightRatio']:.2f} veces más alto.
Relleno de vida10px de ancho y tramo vertical del marco34px, centrados;
base del retrato y altura conservadas, proporción fina como la referencia inicial.
Cada foto de portrait128×128 va aparte del marco; no requiere duplicarlo.
Se incluyen fotos estáticas de Paladín/Tauren desde geometría y cámara animada
del MDX original, posePortrait-1 +600ms, raster local con texturas reales.
La iluminación del render local es aproximada; no se presenta como capturaHUD.

6 BLP1 paletizados alfa8, mipmaps hasta1×1; total{manifest['totalBlpBytes']}bytes.
PNG para preview y SVG editables para carcasas. game/ conserva rutas importables.
Contratohealthbars.json: rectángulos, orden de capas, UV y elección de personaje.
Para vida0 ocultar el relleno; para1..100 recortar desde arriba, anclajeabajo;
20% o menos usaLifeCritical. Los números NO están pintados en textura.

Reproducir desdeProyect:
node TerrainDev/dialogue-system/tools/render-healthbar-portraits.cjs
work/shots-vol-i-origen-20261022/plot-env/bin/python TerrainDev/dialogue-system/tools/healthbar-materials.py
node TerrainDev/dialogue-system/tools/verify-healthbar-materials.cjs
work/shots-vol-i-origen-20261022/plot-env/bin/python TerrainDev/dialogue-system/tools/healthbar-materials.py --pack

Para añadir personaje: preparar fotoPNG128×128 del portrait, registrar fuente,
pose/cámara y hash; convertir mediante el mismo escritorBLP, comprobar mipmaps
y alfa, añadir entradaenportraits. Las rutas son porpersonaje, no porfacción.
Los originales de Blizzard conservan su procedencia; estos derivados no cambian
autoría de los personajes. Materiales del marco generados localmente desdeSVG.

PreviewUI Studio independiente: {manifest['preview']}
Mapa activo conservado. IntegraciónMDX/JASS y prueba nativa pendientes.
'''
    (OUT/'LEEME.txt').write_text(readme)
    package()
    print(json.dumps({'blpTextures':len(entries),'totalBytes':manifest['totalBlpBytes'],'enemyLifeHeightRatio':contract['enemyLifeHeightRatio'],'output':str(OUT)},indent=2))


def package():
    with zipfile.ZipFile(OUT/'health-bars-v1.zip','w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(GAME.rglob('*.blp')):
            z.write(p,str(p.relative_to(OUT/'game')))
        for n in ['healthbars.json','manifest.json','LEEME.txt','validation.json','preview-validation.json']:
            if (OUT/n).exists():
                z.write(OUT/n,n)
    with zipfile.ZipFile(OUT/'health-bars-v1-editables.zip','w',zipfile.ZIP_DEFLATED) as z:
        for folder in ['png','preview']:
            for p in sorted((OUT/folder).glob('*.png')):
                z.write(p,str(p.relative_to(OUT)))
        for p in sorted((OUT/'sources').glob('*.svg')):
            z.write(p,str(p.relative_to(OUT)))
        for n in ['healthbars.json','manifest.json','LEEME.txt']:
            z.write(OUT/n,n)


if __name__=='__main__':
    package() if sys.argv[1:]==['--pack'] else main()
