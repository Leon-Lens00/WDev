export const ASPECT=.544/.302;
export const GROUPS={equipment:'Equipo',inventory:'Inventario',tooltip:'Tooltip',custom:'Mis elementos'};
export const TYPES={button:'Botón',text:'Texto',panel:'Ventana',picture:'Imagen',model:'Modelo de héroe'};
export const ACTIONS={none:'Sin acción',select:'Seleccionar objeto',equip:'Equipar / desequipar',previous:'Página anterior',next:'Página siguiente',sell:'Vender',drop:'Soltar',close:'Cerrar panel',custom:'Acción personalizada'};
export const MODELS={bwn2:{mw:70,mh:60,vw:112,vh:94.1982,name:'Inventario'},ewin:{mw:140,mh:130,vw:112,vh:137.3724,name:'Equipo'},ttip:{mw:120,mh:60,vw:338.6934,vh:211.9459,name:'Tooltip'}};
export const clone=x=>JSON.parse(JSON.stringify(x));
export const round=x=>Math.round(x*100000)/100000;
export function screenToUI(px,py,width,height){return {x:round(px/width*2-1),y:round(1-py/height*2)};}
export function uiToScreen(x,y,width,height){return {x:(x+1)*width/2,y:(1-y)*height/2};}
export function element(type,id,x,y,w=.09,h=.09*ASPECT,extra={}){
 return {id,type,name:TYPES[type],group:'custom',x:round(x),y:round(y),w:round(w),h:round(h),z:.5,texture:'B003',text:'Texto',font:8,color:'#ffffff',opacity:100,visible:true,locked:false,action:'none',rightAction:'none',customAction:'',modelId:'bwn2',binding:'',...extra};
}
function panelFromSource(id,group,x,y,z,scale,modelId){
 const m=MODELS[modelId],depth=100.2+z;
 const w=m.vw*scale/(.544*depth),h=m.vh*scale/(.302*depth);
 return element('panel',id,x+(m.mw-m.vw)*scale/(2*.544*depth),y+(m.vh-m.mh)*scale/(2*.302*depth),w,h,{group,name:GROUPS[group],modelId,texture:modelId==='ttip'?'B014':'D201',z,binding:id});
}
export function preset(){
 const e=[];
 e.push(panelFromSource('equipment.background','equipment',.425,.93,11,.28,'ewin'));
 e.push(panelFromSource('inventory.background','inventory',.61,-.3,2,.228,'bwn2'));
 e.push(panelFromSource('tooltip.background','tooltip',-.7,0,.2,.10,'ttip'));
 const textures=['B003','B004','B006','B007','B008','D05W','B009','B00A','B00C','B00D','B00E','B00F','B005','B00B'];
 const names=['Yelmo','Hombrera izquierda','Armadura','Cinturón','Pantalón','Anillo izquierdo','Amuleto','Hombrera derecha','Guantes','Brazales','Botas','Anillo derecho','Arma','Escudo'];
 for(let i=0;i<14;i++){
  let x=i<6?.53:.885, row=i%6;
  if(i===12){x=.665;row=5;}if(i===13){x=.75;row=5;}
  e.push(element('button',`equipment.slot.${i}`,x,.865-row*.09*ASPECT,.09,.09*ASPECT,{group:'equipment',name:names[i],texture:textures[i],z:10,action:'select',rightAction:'equip',binding:`Equipment.getButton(${i})`}));
 }
 e.push(element('model','equipment.hero',.665,.67,.2,.58,{group:'equipment',name:'Modelo del héroe',texture:'',binding:'Equipment.charModel',z:5}));
 e.push(element('text','equipment.title',.525,.9,.35,.06,{group:'equipment',name:'Nombre del héroe',text:'Nombre del héroe',font:8,binding:'Equipment.title',z:1,color:'#f7dc98'}));
 for(let row=0;row<5;row++)for(let col=0;col<6;col++){
  const i=row*6+col;
  e.push(element('button',`inventory.slot.${i}`,.5615+col*.065,-.228-row*.065*ASPECT,.065,.065*ASPECT,{group:'inventory',name:`Casilla ${i+1}`,texture:'dbnk',action:'select',rightAction:'equip',binding:`Inventory.getButton(${i})`}));
 }
 for(const [id,y,texture,action,name] of [['pageUp',-.228,'B00U','previous','Página anterior'],['pageDown',-.228-4*.065*ASPECT,'B00T','next','Página siguiente'],['sell',-.528,'B011','sell','Vender'],['drop',-.378,'B00N','drop','Soltar']])
  e.push(element('button',`inventory.${id}`,.46,y,.065,.065*ASPECT,{group:'inventory',name,texture,action,binding:`Inventory.btn${id[0].toUpperCase()+id.slice(1)}`}));
 e.push(element('text','inventory.page',.91,-.2,.11,.055,{group:'inventory',name:'Número de página',text:'1/5',font:10,binding:'Inventory.pageNum',z:1}));
 e.push(element('picture','tooltip.icon',-.88,.28,.07,.07*ASPECT,{group:'tooltip',name:'Icono del objeto',texture:'B00G',z:.1,binding:'Inventory.infoIcon'}));
 e.push(element('text','tooltip.title',-.85,.1,.52,.07,{group:'tooltip',name:'Nombre del objeto',text:'Corona de reyes +5',color:'#f7dc98',font:10,z:1,binding:'Inventory.infoBoxTitle'}));
 e.push(element('picture','tooltip.gold',-.85,.022,.03,.03*ASPECT,{group:'tooltip',name:'Icono de oro',texture:'B00H',z:0,binding:'Inventory.costIcon'}));
 e.push(element('text','tooltip.cost',-.81,.022,.3,.06,{group:'tooltip',name:'Precio',text:'1000',color:'#f7dc98',font:8,z:1,binding:'Inventory.infoBoxCost'}));
 const lines=['+5 Fuerza','+5 Agilidad','+5 Inteligencia','Requiere nivel 3','Ranuras: 1'];
 for(let i=0;i<16;i++)e.push(element('text',`tooltip.line.${i}`,-.85,-.05-i*.05,.52,.05,{group:'tooltip',name:`Línea ${i+1}`,text:lines[i]||'',font:7.5,z:1,binding:`Inventory.ItemInfoTags[pid][${i}]`}));
 return {format:'wc3-ui-studio',version:1,name:'InventorySys · Diseño original',target:'1.27b',source:'InventorySys 1.4.1 / UserInterface 1.0.6',viewport:{width:1600,height:900},elements:e};
}
export function validateProject(value){
 if(!value||value.format!=='wc3-ui-studio'||value.version!==1||!Array.isArray(value.elements))throw new Error('Este archivo no es un proyecto UI Studio v1.');
 if(value.elements.length>400)throw new Error('El proyecto supera los 400 elementos admitidos.');
 const p=clone(value);p.name=String(p.name||'Mi interfaz').slice(0,100);p.viewport=p.viewport||{width:1600,height:900};
 if(![p.viewport.width,p.viewport.height].every(n=>Number.isFinite(n)&&n>=100&&n<=8192))throw new Error('Resolución inválida.');
 const ids=new Set();
 p.elements=p.elements.map(raw=>{
  if(!raw||typeof raw.id!=='string'||!/^[A-Za-z][A-Za-z0-9_.-]{0,79}$/.test(raw.id)||ids.has(raw.id))throw new Error('Identificador inválido o repetido.');
  ids.add(raw.id);
  if(!Object.hasOwn(TYPES,raw.type))throw new Error('Tipo de elemento desconocido.');
  const e={...element(raw.type,raw.id,0,0),...raw};
  for(const k of ['x','y','w','h','z','font','opacity'])if(!Number.isFinite(e[k]))throw new Error(`Valor inválido: ${e.id}.${k}`);
  if(Math.abs(e.x)>4||Math.abs(e.y)>4||e.w<=0||e.w>4||e.h<=0||e.h>4||e.z<0||e.z>100||e.font<1||e.font>40||e.opacity<0||e.opacity>100)throw new Error(`Dimensiones fuera de rango: ${e.id}`);
  if(!Object.hasOwn(GROUPS,e.group)||!Object.hasOwn(ACTIONS,e.action)||!Object.hasOwn(ACTIONS,e.rightAction))throw new Error('Grupo o acción inválida.');
  if(e.texture!==''&&!/^[A-Za-z0-9]{4}$/.test(e.texture))throw new Error('La textura debe ser un rawcode de cuatro caracteres.');
  if(!/^#[a-fA-F0-9]{6}$/.test(e.color)||!Object.hasOwn(MODELS,e.modelId))throw new Error('Color o modelo inválido.');
  for(const k of ['name','text','binding','customAction']){if(typeof e[k]!=='string')throw new Error(`Texto inválido: ${k}`);e[k]=e[k].slice(0,k==='text'?4000:200);}
  e.visible=!!e.visible;e.locked=!!e.locked;return e;
 });return p;
}
export function issues(p){
 const out=[];
 for(const e of p.elements){
  if(!e.visible)continue;
  if(e.x<-1||e.y>1||e.x+e.w>1||e.y-e.h< -1)out.push({id:e.id,message:'Parte del elemento queda fuera de la pantalla.'});
  if(e.type==='model')out.push({id:e.id,message:'El modelo se representa con una guía 2D; requiere su MDX y escala en el mapa.'});
  if(e.action==='custom'||e.rightAction==='custom')out.push({id:e.id,message:'La acción personalizada necesita un callback vJASS.'});
 }
 return out;
}
const esc=s=>'"'+s.replaceAll('\\','\\\\').replaceAll('"','\\"').replaceAll('\r','').replaceAll('\n','\\n')+'"';
const real=n=>Number(n).toFixed(5);
export function exportJass(project){
 const p=validateProject(project);
 const lines=['// UI Studio | Warcraft III 1.27b | InventorySys 1.4.1',
 '// Import this library alongside UserInterface. Call factories synchronously.',
 '// Factories create controls; existing inventory callbacks must be retained.',
 '// Example: UIStudioButton("inventory.slot.0", runtimeTexture).',
 '// Pass -1 to use the designed texture; pass 0 for no texture.',
 '// Dynamic show()/tooltip code must use UIStudioX/Y to retain edited positions.',
 '// Model heroes are metadata only; keep Equipment.charModel and its attachment.',
 'library UIStudioLayout initializer Init requires UserInterface','globals','    private hashtable H = InitHashtable()','endglobals',
 'function UIStudioX takes string id returns real','    return LoadReal(H, StringHash(id), 0)','endfunction',
 'function UIStudioY takes string id returns real','    return LoadReal(H, StringHash(id), 1)','endfunction',
 'function UIStudioWidth takes string id returns real','    return LoadReal(H, StringHash(id), 2)','endfunction',
 'function UIStudioHeight takes string id returns real','    return LoadReal(H, StringHash(id), 3)','endfunction',
 'function UIStudioVisible takes string id returns boolean','    return LoadBoolean(H, StringHash(id), 10)','endfunction',
 'function UIStudioAction takes string id, boolean rightClick returns string','    if rightClick then','        return LoadStr(H, StringHash(id), 12)','    endif','    return LoadStr(H, StringHash(id), 11)','endfunction',
 'function UIStudioButton takes string id, integer texture returns UIButton','    local integer k = StringHash(id)','    local UIButton b','    if texture == -1 then','        set texture = LoadInteger(H,k,5)','    endif','    set b = UIButton.create(LoadReal(H,k,0),LoadReal(H,k,1),LoadReal(H,k,2),LoadReal(H,k,3),LoadReal(H,k,4),texture)','    call SetUnitVertexColor(b.picture, LoadInteger(H,k,20), LoadInteger(H,k,21), LoadInteger(H,k,22), LoadInteger(H,k,23))','    return b','endfunction',
 'function UIStudioPicture takes string id, integer texture returns UIPicture','    local integer k = StringHash(id)','    local UIPicture pic','    if texture == -1 then','        set texture = LoadInteger(H,k,5)','    endif','    if LoadInteger(H,k,13) != 0 then','        set pic = UIPicture.createEx(LoadReal(H,k,16),LoadReal(H,k,17),LoadReal(H,k,4),LoadReal(H,k,14),LoadInteger(H,k,13),LoadReal(H,k,18),LoadReal(H,k,19),texture)','    else','        set pic = UIPicture.create(LoadReal(H,k,0),LoadReal(H,k,1),LoadReal(H,k,2),LoadReal(H,k,3),LoadReal(H,k,4),texture)','    endif','    call SetUnitVertexColor(pic.picture, LoadInteger(H,k,20), LoadInteger(H,k,21), LoadInteger(H,k,22), LoadInteger(H,k,23))','    return pic','endfunction',
 'function UIStudioText takes string id, player p returns UIText','    local integer k = StringHash(id)','    local UIText t = UIText.createEx(p,LoadReal(H,k,0),LoadReal(H,k,1),LoadReal(H,k,4))','    call SetTextTagText(t.text,LoadStr(H,k,6),LoadReal(H,k,7)*0.0023)','    call SetTextTagColor(t.text, LoadInteger(H,k,20), LoadInteger(H,k,21), LoadInteger(H,k,22), LoadInteger(H,k,23))','    return t','endfunction',
 'private function Init takes nothing returns nothing','    local integer k'];
 for(const e of p.elements){
  lines.push('    set k = StringHash('+esc(e.id)+')');
  [e.x,e.y,e.w,e.h,e.z].forEach((n,i)=>lines.push(`    call SaveReal(H,k,${i},${real(n)})`));
  lines.push(`    call SaveInteger(H,k,5,${e.texture?"'"+e.texture+"'":'0'})`,`    call SaveStr(H,k,6,${esc(e.text)})`,`    call SaveReal(H,k,7,${real(e.font)})`,`    call SaveBoolean(H,k,10,${e.visible})`);
  [e.action,e.rightAction].forEach((a,i)=>lines.push(`    call SaveStr(H,k,${11+i},${esc(a==='custom'?e.customAction:a)})`));
  [...[0,2,4].map(i=>parseInt(e.color.slice(1+i,3+i),16)),Math.round(e.opacity*2.55)].forEach((n,i)=>lines.push(`    call SaveInteger(H,k,${20+i},${n})`));
  if(e.type==='panel'){
   const m=MODELS[e.modelId],d=100.2+e.z,scale=e.w*.544*d/m.vw;
   const x=e.x+e.w/2-m.mw*scale/(2*.544*d),y=e.y-e.h/2+m.mh*scale/(2*.302*d);
   lines.push(`    call SaveInteger(H,k,13,'${e.modelId}')`);
   [[14,scale],[16,x],[17,y],[18,m.mw],[19,m.mh]].forEach(([i,n])=>lines.push(`    call SaveReal(H,k,${i},${real(n)})`));
  }
 }
 lines.push('endfunction','endlibrary');return lines.join('\n')+'\n';
}
export function integrationNotes(p){return `UI Studio — ${p.name}\n\nBase: InventorySys 1.4.1 / UserInterface 1.0.6 / Warcraft III 1.27b\n\n1. Importar UIStudioLayout.j junto a las bibliotecas originales.\n2. Sustituir las llamadas de creación por UIStudioButton(id, textura), UIStudioPicture(id, textura) o UIStudioText(id, jugador). Conservar customValue, selectUnit, callbacks y referencias originales. -1 usa la textura diseñada; el icono dinámico del objeto debe seguir pasándose desde el inventario.\n3. Las posiciones dinámicas en show(), setTooltipPosition() y similares deben consultar UIStudioX/Y. Los paneles usan su geometría de modelo; tamaños de textos son guías del editor, no cajas de recorte del juego.\n4. Mostrar cada control con la cámara apropiada y UIStudioVisible(id). La visibilidad del grupo en el editor es sólo un filtro de trabajo.\n5. UIStudioAction conserva los enlaces de acciones como datos: no ejecuta venta, equipo ni eliminación de objetos. Conectar acciones nuevas mediante callbacks sincronizados y validar propietario/casilla.\n6. El modelo del héroe y el selector de brillo requieren sus recursos y lógica originales; no se crean desde estas fábricas. Los botones no llevan texto propio: usar un UIText separado.\n7. No llamar las fábricas dentro de GetLocalPlayer. No se han aplicado parches ni cambios al mapa. Compilar y probar dos clientes antes de integrar en producción.\n\nDiseño extraído del código; vista previa 2D aproximada. Textos, marcos y relación de aspecto necesitan calibración en el juego. La cuadrícula original tiene 6 columnas y 5 filas.\n\nENLACES\n${p.elements.map(e=>`${e.id} | ${e.type} | ${e.binding||'nuevo'} | clic=${e.action} | derecho=${e.rightAction}`).join('\n')}\n`;}
