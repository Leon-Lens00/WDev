"""Exact orthographic plot of the exported mesh, not a rendered effect preview."""
from pathlib import Path
import json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.collections import PolyCollection
import numpy as np

root=Path(__file__).resolve().parents[1]
data=json.loads((root/'evidence/stand-geometry.json').read_text())
plt.rcParams.update({'figure.facecolor':'#10151d','axes.facecolor':'#151e2a','text.color':'#ecf1f8','axes.labelcolor':'#c5d3e4','xtick.color':'#a1b4ca','ytick.color':'#a1b4ca','axes.edgecolor':'#354b65','font.size':10})
fig,axes=plt.subplots(3,2,figsize=(12,8),layout='constrained')
for row,scale in enumerate([0.5,1,3]):
    for col,stage in enumerate(['Before','After']):
        ax=axes[row,col]
        entry=data['simple'+stage]
        p=np.array(entry['points'])[:,:2]*scale
        faces=np.array(entry['faces']).reshape(-1,3)
        ax.add_collection(PolyCollection(p[faces],facecolor='#168dbd66',edgecolor='#65d8ff',linewidth=0.5))
        ax.axvline(0,color='#ffd45e',lw=1.5,label='Origen / impacto')
        ax.axhline(0,color='#52677f',lw=0.5)
        ax.scatter([0],[0],color='#ffd45e',s=25,zorder=5)
        tip=p[:,0].max()
        ax.annotate(f'Punta X = {tip:.3f}',(tip,0),(tip-60,24),arrowprops={'arrowstyle':'->','color':'#f4f7fd'},color='white')
        ax.set_xlim(-350,170);ax.set_ylim(-35,35)
        ax.set_aspect('equal');ax.set_title(('Original' if col==0 else 'Exportado: punta al origen')+f' · escala {scale:g}')
        ax.grid(alpha=0.12);ax.set_xlabel('X · avance →');ax.set_ylabel('Y')
fig.suptitle('Shots Vol. I — anclaje frontal comprobado\nMalla Stand en vista superior · el sistema mueve el punto amarillo',fontsize=15)
fig.savefig(root/'evidence/plano-ajustado.png',dpi=160)
fig.savefig(root/'evidence/plano-ajustado.svg')
plt.close(fig)
fig,ax=plt.subplots(figsize=(9,3),layout='constrained')
entry=data['doubleAfter'];p=np.array(entry['points'])[:,:2];faces=np.array(entry['faces']).reshape(-1,3)
ax.add_collection(PolyCollection(p[faces],facecolor='#168dbd66',edgecolor='#65d8ff',linewidth=0.6));ax.axvline(0,color='#ffd45e');ax.scatter([0],[0],color='#ffd45e')
ax.set_xlim(-120,20);ax.set_ylim(-30,30);ax.set_aspect('equal');ax.set_xlabel('X · avance →');ax.set_ylabel('Y');ax.set_title('Double: ambas puntas en el plano X=0; origen entre ellas');ax.grid(alpha=.12)
fig.savefig(root/'evidence/plano-double.png',dpi=160)
print('Exact mesh plots written')
