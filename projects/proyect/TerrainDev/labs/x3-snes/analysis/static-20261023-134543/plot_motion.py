from pathlib import Path
import csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parent
rows=list(csv.DictReader((ROOT/'motion-isolated.csv').open()))
fig,axs=plt.subplots(2,2,figsize=(12,8.1),layout='constrained')
colors=['#a83baf','#179b53','#179b53','#df8c15','#df8c15'];names=['Núcleo','Pareja 1, superior','Pareja 1, inferior','Pareja 2, superior','Pareja 2, inferior']
for col,(variant,title) in enumerate([('original','ROM USA original'),('zero-project-v4.1','Zero Project · IPS V4.1')]):
 for body in range(5):
  r=[x for x in rows if x['variant']==variant and int(x['body'])==body and x['direction']=='1' and int(x['tick'])<=40]
  x=[0]+[float(t['x_px']) for t in r];y=[0]+[float(t['y_px']) for t in r];ticks=[0]+[int(t['tick']) for t in r]
  axs[0,col].plot(x,y,color=colors[body],lw=2,label=names[body],ls='--' if body in (2,4) else '-')
  for k in (8,16,24,32,40):axs[0,col].plot(x[k],y[k],'o',color=colors[body],ms=3)
  if body in (0,1,3):axs[1,col].plot(ticks[:33],x[:33],color=colors[body],lw=2,label=names[body].replace(', superior',''))
 axs[0,col].set(title=title,xlabel='Avance longitudinal (píxeles)',ylabel='Desplazamiento lateral (píxeles)',xlim=(-80,300),ylim=(130,-130));axs[0,col].set_aspect('equal',adjustable='box')
 axs[1,col].set(xlabel='Pasos de movimiento desde inicialización',ylabel='Avance longitudinal (píxeles)',xlim=(0,32),ylim=(-70,270))
 for ax in axs[:,col]:ax.axhline(0,color='#777',lw=.7);ax.axvline(0,color='#777',lw=.7);ax.grid(alpha=.2)
 axs[1,col].legend(loc='upper left',fontsize=8)
fig.suptitle('Superdisparo X3: ecuaciones recuperadas de la ROM y del parche',fontsize=15)
fig.supxlabel('Bloques aislados, sin colisiones ni vida de pantalla. No es una captura/traza de partida SNES. Marcas cada 8 pasos.',fontsize=9)
fig.savefig(ROOT/'comparacion-fisica-rom.png',dpi=150)
fig.savefig(ROOT/'comparacion-fisica-rom.svg')
