// Preview texels are decoded from the delivered BLP files.
const $=id=>document.getElementById(id),canvas=$('preview'),ctx=canvas.getContext('2d');
const banks={};
for(const [variant,root] of Object.entries({vertical:'assets/healthbars/',horizontal:'assets/healthbars-horizontal/'})){
 const contract=await(await fetch(root+'healthbars.json')).json(),images={};
 const names=new Set([contract.player.frame,contract.enemy.frame,contract.fill.normal,contract.fill.critical,...Object.values(contract.portraits).map(p=>p.texture)]);
 await Promise.all([...names].map(async name=>{const i=new Image();i.src=root+name+'.png';await i.decode();images[name]=i;}));
 banks[variant]={contract,images};
}
const background=new Image();background.src='assets/healthbars/background-shared.png';await background.decode();
const controls=['orientation','player-life','enemy-life','player-character','enemy-character','scale','background'];
function bar(bank,role,id,life,x,y,scale,horizontal){
 const {contract,images}=bank,r=Math.max(0,Math.min(100,life))/100;
 if(role.portraitRect){const [px,py,pw,ph]=role.portraitRect;ctx.drawImage(images[contract.portraits[id].texture],x+px*scale,y+py*scale,pw*scale,ph*scale);}
 const [sx,sy,sw,sh]=role.contentRect;ctx.drawImage(images[role.frame],sx,sy,sw,sh,x,y,sw*scale,sh*scale);
 if(r>0){
  const fill=images[life<=contract.fill.criticalAtPercent?contract.fill.critical:contract.fill.normal],[lx,ly,lw,lh]=role.lifeRect;
  if(horizontal)ctx.drawImage(fill,0,0,fill.width*r,fill.height,x+lx*scale,y+ly*scale,lw*r*scale,lh*scale);
  else ctx.drawImage(fill,0,fill.height*(1-r),fill.width,fill.height*r,x+lx*scale,y+(ly+lh*(1-r))*scale,lw*scale,lh*r*scale);
 }
 const [rx,ry,rw,rh]=role.readoutRect;
 ctx.fillStyle='#c7f7ff';ctx.font=`bold ${14*scale}px monospace`;ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillText(Math.round(r*100)+'%',x+(rx+rw/2)*scale,y+(ry+rh/2)*scale);
}
function paint(){
 const variant=$('orientation').value,bank=banks[variant],{contract}=bank,horizontal=variant==='horizontal';
 const player=Math.max(0,Math.min(100,Number($('player-life').value))),enemy=Math.max(0,Math.min(100,Number($('enemy-life').value))),scale=Number($('scale').value)/100;
 ctx.fillStyle='#0a1420';ctx.fillRect(0,0,1920,1080);
 if($('background').value==='game'){ctx.drawImage(background,0,0,1920,1080);ctx.fillStyle='#0004';ctx.fillRect(0,0,1920,1080);}
 else {ctx.strokeStyle='#173048';ctx.lineWidth=1;for(let x=0;x<1920;x+=32){ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,1080);ctx.stroke();}for(let y=0;y<1080;y+=32){ctx.beginPath();ctx.moveTo(0,y);ctx.lineTo(1920,y);ctx.stroke();}}
 if(horizontal){
  if(contract.heroUsesNativeHUDIcon===false){
   bar(bank,contract.player,$('player-character').value,player,...contract.playerOrigin,scale,true);
   bar(bank,contract.enemy,$('enemy-character').value,enemy,1920-24-contract.enemy.contentRect[2]*scale,contract.enemyOrigin[1],scale,true);
  }else{
   const [ix,iy,iw,ih]=contract.nativeHeroIconRect,y=iy+ih/2-32*scale;
   if($('background').value==='grid')ctx.drawImage(background,ix,iy,iw,ih,ix,iy,iw,ih);
   bar(bank,contract.player,$('player-character').value,player,ix+iw+8,y,scale,true);
   bar(bank,contract.enemy,$('enemy-character').value,enemy,1920-24-contract.enemy.contentRect[2]*scale,y,scale,true);
  }
 }else{
  bar(bank,contract.player,$('player-character').value,player,75,180,scale,false);
  bar(bank,contract.enemy,$('enemy-character').value,enemy,1920-75-128*scale,75,scale,false);
 }
 $('status').textContent=horizontal?'Control compartido básico probado · icono HUD oculto · Classic 1.27b SP1920×1080':'Vertical: materiales preparados · integración pendiente';
 $('player-character').disabled=horizontal&&contract.heroUsesNativeHUDIcon!==false;
 $('variant-note').textContent=horizontal?'Héroe: marco azul con icono nativo propio; propietario auxiliar con control compartido. Enemigo: icono nativo a la derecha. La vida aumenta de izquierda a derecha.':'Marco, foto, relleno y cifras independientes. Cambiar de personaje conserva la carcasa.';
 $('state').textContent=`${horizontal?'Horizontal':'Vertical'} · jugador ${player}% · enemigo ${enemy}% · escala ${$('scale').value}% · recorrido enemigo ${(horizontal?contract.enemyLifeLengthRatio:contract.enemyLifeHeightRatio).toFixed(2)}×`;
 const sizes=horizontal?'256×128 / 512×128':'128×256 / 128×512',weight=((contract.totalBlpBytes||378492)/1024).toLocaleString('es',{maximumFractionDigits:2});
 $('inventory').textContent=`${horizontal?4:6} texturas BLP propias · ${weight} KiB · carcasas ${sizes} · ${horizontal?"iconos nativos 64×64":"retratos 128×128"} · relleno 10 px`;
 Object.assign(canvas.dataset,{orientation:variant,playerLife:String(player),enemyLife:String(enemy),playerCharacter:$('player-character').value,enemyCharacter:$('enemy-character').value});
}
for(const c of controls)$(c).addEventListener('input',paint);
for(const button of document.querySelectorAll('[data-life]'))button.addEventListener('click',()=>{$('player-life').value=$('enemy-life').value=button.dataset.life;paint();});
$('reset').addEventListener('click',()=>{$('player-life').value=75;$('enemy-life').value=86;$('player-character').value='paladin';$('enemy-character').value='tauren';$('scale').value=120;$('background').value='game';paint();});
$('download').addEventListener('click',()=>{const a=document.createElement('a');a.href=canvas.toDataURL('image/png');a.download='barras-vida-'+$('orientation').value+'.png';a.click();});
paint();
