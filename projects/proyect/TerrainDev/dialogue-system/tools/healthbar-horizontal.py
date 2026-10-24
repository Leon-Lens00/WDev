#!/usr/bin/env python3
"""Separate horizontal material variant; leaves the approved vertical set intact."""
from pathlib import Path
import hashlib
import json
import shutil
import struct
import sys
import zipfile
import numpy as np
from PIL import Image, ImageDraw
import textures

ROOT=Path(__file__).resolve().parents[1]
VERTICAL=ROOT/'exports/health-bars-v1'
OUT=ROOT/'exports/health-bars-horizontal-v1'
GAME=OUT/'game/UI/HealthBarsHorizontal'
STUDIO=Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/healthbars-horizontal')


def housing(enemy):
    width,height=(512,128) if enemy else (256,128)
    image=Image.new('RGBA',(width*4,height*4));draw=ImageDraw.Draw(image);svg=[]
    base,inset,accent=('#350b16','#722034','#e26b78') if enemy else ('#082a45','#174d75','#48baff')
    def polygon(points,fill,stroke=None,sw=1):
        p=[(x*4,y*4) for x,y in points];draw.polygon(p,fill=fill)
        if stroke:draw.line(p+[p[0]],fill=stroke,width=sw*4,joint='curve')
        svg.append('<polygon points="'+' '.join(f'{x},{y}' for x,y in points)+f'" fill="{fill}" stroke="{stroke or "none"}" stroke-width="{sw}"/>')
    def line(points,color,sw=1):
        draw.line([(x*4,y*4) for x,y in points],fill=color,width=sw*4)
        svg.append('<polyline points="'+' '.join(f'{x},{y}' for x,y in points)+f'" fill="none" stroke="{color}" stroke-width="{sw}"/>')
    shorten=0 if enemy else 192
    shorten_points=lambda points:[(x-shorten if x>100 else x,y) for x,y in points]
    polygon(shorten_points([(14,2),(84,2),(98,15),(437,15),(445,23),(445,41),(437,49),(100,49),(98,78),(84,94),(14,94),(4,84),(4,12)]),'#030910','#d8e9f6',2)
    polygon(shorten_points([(16,6),(82,6),(96,19),(435,19),(441,25),(441,39),(435,45),(96,45),(94,76),(82,90),(16,90),(8,82),(8,14)]),base,inset,2)
    line(shorten_points([(98,21),(433,21),(437,25)]),accent)
    line(shorten_points([(98,43),(433,43),(437,39)]),accent)
    l,r=101,429-shorten
    readout=[17,77,64,14];portrait=[17,10,64,64]
    polygon([(17,77),(81,77),(85,84),(81,91),(17,91),(13,84)],'#020c17',accent)
    cut=[(21,10),(77,10),(81,14),(81,70),(77,74),(21,74),(17,70),(17,14)]
    draw.polygon([(x*4,y*4) for x,y in cut],fill=(0,0,0,0));line(cut+[cut[0]],'#c6d9e4',2)
    role={'textureSize':[width,height],'contentRect':[0,0,448-shorten,96],
          'lifeRect':[102,27,325-shorten,10],'portraitRect':portrait,
          'readoutRect':readout,'frame':'FrameEnemyHorizontal' if enemy else 'FrameHeroHorizontal',
          'contentUMax':(448-shorten)/width,'iconSource':'native unit Art resource'}
    polygon([(l,24),(r,24),(r,40),(l,40)],'#0b111a','#a5b4be')
    for x in range(l+5,r,12):line([(x,25),(x,39)],'#172434')
    line([(l+1,32),(r-1,32)],'#172434')
    mask=''
    if cut:
        points=' '.join(f'{x},{y}' for x,y in cut)
        mask=f'<defs><mask id="portrait"><rect width="{width}" height="{height}" fill="white"/><polygon points="{points}" fill="black"/></mask></defs>'
        body='<g mask="url(#portrait)">'+''.join(svg)+f'</g><polygon points="{points}" fill="none" stroke="#c6d9e4" stroke-width="2"/>'
    else:body=''.join(svg)
    if enemy:
        mirrored=Image.new('RGBA',(width,height));mirrored.paste(image.resize((width,height),Image.Resampling.LANCZOS).crop((0,0,448,128)).transpose(Image.Transpose.FLIP_LEFT_RIGHT),(0,0))
        image=mirrored.resize((width*4,height*4),Image.Resampling.NEAREST)
        for key in ['lifeRect','portraitRect','readoutRect']:
            x,y,w,h=role[key];role[key]=[448-x-w,y,w,h]
        body='<g transform="translate(448 0) scale(-1 1)">'+body+'</g>'
    (OUT/'sources'/(role['frame']+'.svg')).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">{mask}{body}</svg>')
    return image.resize((width,height),Image.Resampling.LANCZOS),role


def package():
    with zipfile.ZipFile(OUT/'health-bars-horizontal-v1.zip','w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(GAME.iterdir()):
            if p.suffix in ['.blp','.mdx']:z.write(p,str(p.relative_to(OUT/'game')))
        for n in ['healthbars.json','manifest.json','LEEME.txt','validation.json','preview-validation.json','latest-healthbar-test.json']:
            if (OUT/n).exists():z.write(OUT/n,n)
        for n in ['HealthBars.j','ConversationUI.j']:
            z.write(ROOT/'src'/n,'src/'+n)
    with zipfile.ZipFile(OUT/'health-bars-horizontal-editables.zip','w',zipfile.ZIP_DEFLATED) as z:
        for folder,ext in [('png','*.png'),('preview','*.png'),('sources','*.svg'),('sources','*.mdl')]:
            for p in sorted((OUT/folder).glob(ext)):z.write(p,str(p.relative_to(OUT)))
        for p in sorted((OUT/'sources/native').iterdir()):
            if p.suffix in ['.json','.txt','.blp','.png']:z.write(p,str(p.relative_to(OUT)))
        for n in ['healthbars.json','manifest.json','LEEME.txt']:z.write(OUT/n,n)


def main():
    for p in [OUT/'sources',OUT/'png',OUT/'preview',GAME,STUDIO]:p.mkdir(parents=True,exist_ok=True)
    approved=json.loads((VERTICAL/'manifest.json').read_text())
    vertical_before={t['path']:hashlib.sha256(Path(t['path']).read_bytes()).hexdigest() for t in approved['textures']}
    images={}
    images['FrameHeroHorizontal'],player=housing(False)
    images['FrameEnemyHorizontal'],enemy=housing(True)
    for n in ['LifeNormal','LifeCritical']:
        images[n+'Horizontal']=Image.open(VERTICAL/'png'/(n+'.png')).convert('RGBA').transpose(Image.Transpose.ROTATE_270)
    icons=json.loads((OUT/'sources/native/icons.json').read_text())
    for icon in icons.values():shutil.copy2(icon['png'],STUDIO/(icon['texture']+'.png'))
    textures.OUT=GAME;entries=[]
    for name,image in images.items():
        image.save(OUT/'png'/(name+'.png'));entry=textures.blp(image,name+'.blp')
        entry.update(name=name,bytes=(GAME/(name+'.blp')).stat().st_size)
        entries.append(entry)
        raw=(GAME/(name+'.blp')).read_bytes();offset=struct.unpack_from('<I',raw,28)[0];w,h=image.size
        palette=np.frombuffer(raw[156:1180],dtype=np.uint8).reshape(256,4)
        indices=np.frombuffer(raw[offset:offset+w*h],dtype=np.uint8).reshape(h,w)
        rgba=palette[indices][...,[2,1,0,3]].copy();rgba[...,3]=np.frombuffer(raw[offset+w*h:offset+2*w*h],dtype=np.uint8).reshape(h,w)
        Image.fromarray(rgba,'RGBA').save(OUT/'preview'/(name+'.png'))
        shutil.copy2(OUT/'preview'/(name+'.png'),STUDIO/(name+'.png'))
    contract={'version':1,'variant':'horizontal','target':'Warcraft III Classic 1.27b',
              'maxTextureDimension':512,'player':player,'enemy':enemy,
              'enemyLifeLengthRatio':325/133,'nativeHeroIconRect':None,
              'heroUsesNativeHUDIcon':False,'playerOrigin':[24,48.6],'enemyOrigin':[1358.4,48.6],
              'nativeOwnerIndex':10,'controllerIndex':0,'displayColorFromController':True,
              'portraits':icons,
              'fill':{'normal':'LifeNormalHorizontal','critical':'LifeCriticalHorizontal','criticalAtPercent':20,
                      'anchor':'left','growth':'left-to-right','uvPolicy':'crop the right side; preserve left origin'},
              'layersBackToFront':['native HUD / enemy portrait','frame','fill inside lifeRect','dynamic text'],
              'previewCoordinates':'1920x1080 reference screenshot only; native anchoring in engine pending',
              'totalBlpBytes':sum(t['bytes'] for t in entries)}
    (OUT/'healthbars.json').write_text(json.dumps(contract,indent=2,ensure_ascii=False)+'\n');shutil.copy2(OUT/'healthbars.json',STUDIO/'healthbars.json')
    manifest={'target':'Classic 1.27b / BLP1 palette / alpha8 / complete mipmaps','variant':'horizontal',
              'textures':entries,'totalBlpBytes':contract['totalBlpBytes'],'verticalMaterialHashes':vertical_before,'nativeIcons':icons,
              'activeMapSha256':hashlib.sha256((ROOT/'TerrainDev-Dialogue.w3x').read_bytes()).hexdigest(),
              'mapIntegrated':False,'nativeTested':False,'preview':'http://127.0.0.1:4317/healthbars.html'}
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n')
    for file,expected in vertical_before.items():assert hashlib.sha256(Path(file).read_bytes()).hexdigest()==expected
    (OUT/'LEEME.txt').write_text('Barras horizontales con iconos nativos · Classic1.27b\n\nHéroe:marco azul completo con icono Art nativo, a la izquierda. UnidadHpal de\nPlayer10(auxiliar reservado), controlada porPlayer0 y con su color visual.\nALLIANCE_SHARED_CONTROL=true y ALLIANCE_SHARED_ADVANCED_CONTROL=false:\nel control avanzado añade un icono lateral nativo; el básico lo oculta y permite\nmover y lanzar Luz sagrada. No se añadió un campo deobjeto ajeno a1.27b.\nLa alianza comparte todas las unidades del propietarioauxiliar:reservarlo.\n\nEnemigo:iconoArt nativo al extremo derecho; relleno325px frente a133px dehéroe,\nanclado a la izquierda. Grosor10px. Ambos iconos64×64 desdearchivos internos.\nMarcos256×128/512×128,4BLP propios288752bytes y37mips;3MDX800112716bytes.\nNo se reimportan BTNHeroPaladin/BTNTauren. RegistroHpal/otau yprocedencia\nsources/native/icons.json. Para otros tipos, ampliar registro/modelo/rawcode.\n\nMapa y alcance:vermanifest.json/latest-healthbar-test.json parahash yprueba.\nNativeSP1920×1080:selección, movimiento de ratón, habilidad(manà255→190),\nvida normal/crítica/cero, iconos, patrulla y diálogo. Otros aspectos/multijugador\npendientes. Las bibliotecasCamera/UserInterface yfoundation se conservan.\n\nAPI:HealthBarsBind(Camera,hero,target), HealthBarsTarget(unit),\nHealthBarsSetVisible(boolean), HealthBarsUpdate() después deactualizar lacámara.\nVida consultada cada0,05s y proyección cada0,01s, en el reloj de cámara existente.\n\nComandos demo:\n-vidaheroe 75 / -vidaenemigo 86 (vida real;0 mata la unidad)\n-barrasocultar / -barrasmostrar\n-barrasobjetivopaladin / -barrasobjetivotauren\n-patrullardialogo / -parardialogo\n-dialogo / -reiniciardialogo / -cerrardialogo\n-controlbasico (siniconolateral) / -controlavanzado (prueba comparativa)\n-misiles:cuadrodiagnóstico, oculto aliniciar.\n\nFuentes:healthbar-native-icons.cjs extraeiconos efectivos deClassic;\nhealthbar-horizontal.py(PythonPillow documentado) genera texturas ycontrato;\nbuild.py generaMDX, compilaJASS e importa enuna copia. Validadores:\nverify-healthbar-horizontal.cjs y verify-healthbar-models.cjs. Builder reextrae\nlos miembros para compararlos. La vista UI Studio usa los mismos texelesBLP y\nun fondo real nuevo con barras ocultas. La variantevertical queda conservada.\n')
    package();print(json.dumps({'textures':len(entries),'bytes':contract['totalBlpBytes'],'output':str(OUT)},indent=2))


if __name__=='__main__':
    package() if sys.argv[1:]==['--pack'] else main()
