"""Rasterize the static UI geosets using their actual MDX UVs, materials and atlases."""
from pathlib import Path
import struct, json
import numpy as np
from PIL import Image, ImageDraw
ROOT=Path(__file__).resolve().parent
OUT=Path('/home/snz/Documentos/WarDatsPy/ui-studio/dist/assets/frames')
ASSETS=OUT.parent
OUT.mkdir(exist_ok=True)
def u32(b,i):return struct.unpack_from('<I',b,i)[0]
for name,file in [('bwn2','RaceWindow.mdx'),('ewin','RaceWindowLong.mdx'),('ttip','TooltipWindow.mdx')]:
    b=(ROOT/'source-demo/UI'/file).read_bytes();o=4;chunks={}
    while o<len(b):
        n=u32(b,o+4);chunks[b[o:o+4]]=b[o+8:o+8+n];o+=8+n
    geos=[];g=chunks[b'GEOS'];o=0
    while o<len(g):
        n=u32(g,o);d=g[o:o+n];o+=n
        v=d.index(b'VRTX');count=u32(d,v+4);vertices=np.array(struct.unpack_from('<'+'f'*count*3,d,v+8)).reshape((-1,3))
        v=d.index(b'UVBS');uv=np.array(struct.unpack_from('<'+'f'*count*2,d,v+8)).reshape((-1,2))
        v=d.index(b'PVTX');indices=np.array(struct.unpack_from('<'+'H'*u32(d,v+4),d,v+8)).reshape((-1,3))
        v=d.index(b'MATS');material=u32(d,v+8+4*u32(d,v+4))
        geos.append((vertices,uv,indices,material))
    vertices=np.concatenate([x[0] for x in geos]);ymin,ymax=vertices[:,1].min(),vertices[:,1].max();zmin,zmax=vertices[:,2].min(),vertices[:,2].max()
    size=(900,round(900*(zmax-zmin)/(ymax-ymin)))
    for texture in (['B014'] if name=='ttip' else ['D201','D202','D203','D204']):
        out=Image.new('RGBA',size)
        # Transparent background first, frame after it, preserving material alpha.
        for verts,uv,indices,mat in sorted(geos,key=lambda x:-x[3]):
            atlas=Image.open(ASSETS/(texture+'.png' if mat==0 else 'D203.png')).convert('RGBA')
            # The supplied border atlases have an all-zero alpha plane, but the
            # observed War Club replaceable-texture path renders their RGB.
            # Approximate that path for the preview, retaining dark cutouts.
            if atlas.getchannel('A').getextrema()==(0,0):atlas.putalpha(255)
            if mat==0:
                pixels=np.array(atlas)
                pixels[:,:,3]=np.where(pixels[:,:,:3].max(axis=2)<4,0,pixels[:,:,3])
                atlas=Image.fromarray(pixels)
            if mat==1:atlas.putalpha(atlas.getchannel('A').point(lambda a:round(a*.5)))
            xy=np.column_stack(((verts[:,1]-ymin)/(ymax-ymin)*size[0],(zmax-verts[:,2])/(zmax-zmin)*size[1]))
            for tri in indices:
                target=xy[tri];source=uv[tri]*[atlas.width,atlas.height]
                matrix=np.column_stack((target,np.ones(3)))
                if abs(np.linalg.det(matrix))<1e-6:continue
                coeff=np.linalg.solve(matrix,source).T.reshape(-1)
                patch=atlas.transform(size,Image.Transform.AFFINE,tuple(coeff),Image.Resampling.BILINEAR)
                mask=Image.new('L',size);ImageDraw.Draw(mask).polygon([tuple(p) for p in target],fill=255)
                patch.putalpha(Image.composite(patch.getchannel('A'),Image.new('L',size),mask))
                out.alpha_composite(patch)
        out.save(OUT/f'{name}-{texture}.png')
print(OUT)
