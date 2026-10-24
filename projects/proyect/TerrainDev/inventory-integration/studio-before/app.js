import {ASPECT,GROUPS,TYPES,ACTIONS,MODELS,clone,round,element,preset,validateProject,issues,exportJass,integrationNotes} from './core.js';
import {selectionBounds,moveSelection,resizeSelection,displayGeometry,geometryValue} from './geometry.js';
const $=s=>document.querySelector(s), $$=s=>[...document.querySelectorAll(s)];
const html=s=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let catalog=[];try{catalog=await (await fetch('./catalog.json')).json();}catch{}
const textures=new Map(catalog.map(a=>[a.id,a]));
const STORAGE='wc3-ui-studio-v1';
const icon=name=>`<img class="ui-icon" src="assets/ui/${name}.svg" alt="" aria-hidden="true">`;
let theme='light';try{theme=localStorage.getItem('wc3-ui-studio-theme')||'light';}catch{}
function applyTheme(){document.body.dataset.theme=theme;$('#theme').innerHTML=icon(theme==='light'?'moon':'sun');$('#theme').setAttribute('aria-label',theme==='light'?'Cambiar a tema oscuro':'Cambiar a tema claro');}
$('#theme').onclick=()=>{theme=theme==='light'?'dark':'light';applyTheme();try{localStorage.setItem('wc3-ui-studio-theme',theme);}catch{}};
applyTheme();
let project=preset(),selection=[],past=[],future=[],mode='edit',zoom=1,showSamples=false,page=1,simSelected='',simHidden=new Set(),filterGroups=new Set(Object.keys(GROUPS));
let saveTimer,toastTimer,storageError=false;
const collapsedGroups=new Set(['tooltip']),closedSections=new Set(['interaction','organization']);
let units='px',canvasTool='select',spaceDown=false,editSelection=[],pendingTransform=null;
let fitting=true,libraryOpen=innerWidth>1000,inspectorOpen=innerWidth>1000,focusPanels=null;
try{const saved=localStorage.getItem(STORAGE);if(saved)project=validateProject(JSON.parse(saved));}catch{storageError=true;}
function toast(s){$('#toast').textContent=s;$('#toast').classList.add('show');clearTimeout(toastTimer);toastTimer=setTimeout(()=>$('#toast').classList.remove('show'),3500);}
function saveLocal(){clearTimeout(saveTimer);$('#save-state').textContent='Guardando…';saveTimer=setTimeout(()=>{try{localStorage.setItem(STORAGE,JSON.stringify(project));$('#save-state').textContent='Guardado en este navegador';}catch{$('#save-state').textContent='Sin autoguardado · descarga JSON';}},250);}
function remember(){past.push(clone(project));if(past.length>80)past.shift();future=[];}
function commit(fn){remember();fn();saveLocal();render();}
function selected(){return project.elements.filter(e=>selection.includes(e.id));}
function choose(id,add=false){if(mode!=='edit')return;pendingEdit='';pendingTransform=null;selection=add?(selection.includes(id)?selection.filter(x=>x!==id):[...selection,id]):[id];const e=project.elements.find(e=>e.id===id);if(e)collapsedGroups.delete(e.group);render();}
function updatePanels(){
 document.body.classList.toggle('hide-library',!libraryOpen);document.body.classList.toggle('hide-inspector',!inspectorOpen);
 $('#toggle-library').setAttribute('aria-expanded',libraryOpen);$('#toggle-inspector').setAttribute('aria-expanded',inspectorOpen);
 $('#focus-mode').setAttribute('aria-pressed',!libraryOpen&&!inspectorOpen);$('#focus-mode').innerHTML=icon('maximize')+'<span>'+(!libraryOpen&&!inspectorOpen?'Mostrar paneles':'Solo lienzo')+'</span>';
 $('#panel-shade').hidden=innerWidth>1000||(!libraryOpen&&!inspectorOpen);
 for(const selector of ['.canvas-toolbar','.scene-toolbar','#viewport','.canvas-footer'])$(selector).inert=!$('#panel-shade').hidden;
}
function togglePanel(which){focusPanels=null;if(which==='library'){libraryOpen=!libraryOpen;if(innerWidth<=1000)inspectorOpen=false;}else{inspectorOpen=!inspectorOpen;if(innerWidth<=1000)libraryOpen=false;}updatePanels();}
function toggleFocus(){if(libraryOpen||inspectorOpen){focusPanels=[libraryOpen,inspectorOpen];libraryOpen=false;inspectorOpen=false;}else{[libraryOpen,inspectorOpen]=focusPanels||[true,innerWidth>1000];focusPanels=null;}updatePanels();}
$('#toggle-library').onclick=()=>togglePanel('library');$('#toggle-inspector').onclick=()=>togglePanel('inspector');$('#focus-mode').onclick=toggleFocus;
$('#panel-shade').onclick=()=>{libraryOpen=false;inspectorOpen=false;updatePanels();};

function title(e){return e.name||TYPES[e.type];}
function matchingLayers(group){const q=$('#layer-search').value.trim().toLowerCase();return project.elements.filter(e=>e.group===group&&(title(e)+' '+e.id).toLowerCase().includes(q));}
function switchTab(assets){$('#asset-panel').hidden=!assets;$('#layer-panel').hidden=assets;$('#tab-assets').classList.toggle('active',assets);$('#tab-layers').classList.toggle('active',!assets);$('#tab-assets').setAttribute('aria-pressed',assets);$('#tab-layers').setAttribute('aria-pressed',!assets);if(assets){libraryOpen=true;if(innerWidth<=1000)inspectorOpen=false;updatePanels();renderAssets();}}
function visible(e){return e.visible&&filterGroups.has(e.group)&&!simHidden.has(e.group);}
function textureURL(id){return textures.get(id)?.preview;}
function render(){
 $('#project-name').value=project.name;$('#count').textContent=project.elements.length;
 $('#aspect').value=project.viewport.width+','+project.viewport.height;
 $('#stage').style.aspectRatio=project.viewport.width+'/'+project.viewport.height;
 $('#stage-size').textContent=`${project.viewport.width} × ${project.viewport.height}`;
 $('#undo').disabled=!past.length;$('#redo').disabled=!future.length;$('#fit-selection').disabled=!selected().some(visible);
 $('#selection-status').textContent=mode==='preview'?'Simulación local · los clics no modifican el mapa':selection.length?`${selection.length} seleccionado${selection.length>1?'s':''} · ${selected()[0]?.id||''}`:'Selecciona un elemento para editarlo';
 $('#group-filters').innerHTML=Object.entries(GROUPS).filter(([g])=>g!=='custom'||project.elements.some(e=>e.group===g)).map(([g,n])=>`<button data-filter="${g}" aria-pressed="${filterGroups.has(g)}" class="${filterGroups.has(g)?'active':''}">${n}</button>`).join('');
 applyZoom();renderLayers();renderInspector();renderIssues();if(!$('#asset-panel').hidden)renderAssets();
}
function renderStage(){
 const height=$('#stage').clientHeight;
 $('#objects').innerHTML=project.elements.filter(visible).map((e,i)=>{
  let tex=e.texture,text=e.text;
  if(e.id==='inventory.page'&&mode==='preview')text=page+'/5';
  if(showSamples&&e.id.startsWith('inventory.slot.')){const n=Number(e.id.split('.').at(-1));if(n<6)tex=catalog.filter(t=>!t.path.startsWith('UI'))[(n+page*3)%Math.max(1,catalog.filter(t=>!t.path.startsWith('UI')).length)]?.id||'B00G';}
  const src=textureURL(tex),isSelected=selection.includes(e.id)&&mode==='edit';
  let content='';
  if(e.type==='button'||e.type==='picture')content=src?`<img src="${html(src)}" alt="" draggable="false">`:'<div class="empty-slot"></div>';
  if(e.type==='text')content=html(text);
  if(e.type==='model')content='<span class="model-marker">◇</span><span>Modelo del héroe</span><small>Referencia 2D</small>';
  if(e.id.startsWith('inventory.slot.')&&!showSamples&&mode==='edit')content+=`<span class="slot-number">${Number(e.id.split('.').at(-1))+1}</span>`;
  
  const z=i+1;
  const font=e.font*.0023*height;
  return `<div class="obj ${e.type} ${e.locked?'locked':''} ${isSelected?'selected':''} ${!text&&e.type==='text'?'empty':''} ${simSelected===e.id&&mode==='preview'?'sim-selected':''}" data-id="${html(e.id)}" data-model="${e.modelId}" title="${html(title(e))}" style="left:${(e.x+1)*50}%;top:${(1-e.y)*50}%;width:${e.w*50}%;height:${e.h*50}%;z-index:${z};color:${e.color};opacity:${e.opacity/100};font-size:${font}px">${content}</div>`;
 }).join('');renderSelectionFrame();
}
function renderSelectionFrame(){
 const es=selected().filter(e=>!e.locked&&visible(e)),b=selectionBounds(es),frame=$('#selection-frame');frame.hidden=!b||mode!=='edit';if(frame.hidden)return;
 Object.assign(frame.style,{left:(b.x+1)*50+'%',top:(1-b.y)*50+'%',width:b.w*50+'%',height:b.h*50+'%'});
 const px=displayGeometry(b,project.viewport),labels={nw:'superior izquierda',n:'superior',ne:'superior derecha',e:'derecha',se:'inferior derecha',s:'inferior',sw:'inferior izquierda',w:'izquierda'};
 frame.innerHTML=`<span class="transform-label">${es.length>1?es.length+' elementos · ':''}${Math.round(px.w)} × ${Math.round(px.h)} px</span>`+Object.entries(labels).map(([h,label])=>`<button class="transform-handle handle-${h}" data-handle="${h}" tabindex="-1" aria-label="Escalar desde ${label}"></button>`).join('');
}
function renderLayers(){
 const q=$('#layer-search').value.trim().toLowerCase();let total=0;
 $('#layers').innerHTML=Object.entries(GROUPS).map(([g,name])=>{
  const es=matchingLayers(g);if(!es.length)return '';total+=es.length;
  const open=!!q||!collapsedGroups.has(g);
  return `<section class="layer-group"><div class="group-heading"><button data-toggle-group="${g}" aria-expanded="${open}" aria-controls="group-${g}">${name}<span>${es.length}</span></button><button data-select-group="${g}" title="Seleccionar ${es.length} elementos mostrados de ${name}" aria-label="Seleccionar ${es.length} elementos mostrados de ${name}">Todo</button></div><div id="group-${g}" ${open?'':'hidden'}>`+es.map(e=>`<div class="layer ${selection.includes(e.id)?'selected':''} ${e.visible?'':'is-hidden'}"><button class="layer-select" data-layer="${html(e.id)}" aria-pressed="${selection.includes(e.id)}" title="${html(title(e))} · ${html(e.id)}">${textureURL(e.texture)?`<img src="${html(textureURL(e.texture))}" alt="">`:`<span class="type-icon" aria-hidden="true">${e.type==='text'?'T':e.type==='model'?'3D':'UI'}</span>`}<span class="layer-name">${html(title(e))}</span></button><button data-lock="${html(e.id)}" aria-pressed="${e.locked}" aria-label="${e.locked?'Desbloquear':'Bloquear'} ${html(title(e))}" title="${e.locked?'Desbloquear':'Bloquear'}">${icon(e.locked?'lock':'lock-open')}</button><button data-visible="${html(e.id)}" aria-pressed="${e.visible}" aria-label="${e.visible?'Ocultar':'Mostrar'} ${html(title(e))}" title="${e.visible?'Ocultar':'Mostrar'}">${icon(e.visible?'eye':'eye-off')}</button></div>`).join('')+'</div></section>';
 }).join('')||'<p class="search-empty">No hay coincidencias.<br>Prueba otro nombre o ID.</p>';
 $('#layer-results').textContent=`${total} elemento${total===1?'':'s'}`;
 $('#collapse-groups').disabled=!!q;
 $('#collapse-groups').textContent=collapsedGroups.size===Object.keys(GROUPS).length?'Desplegar todo':'Plegar todo';
}
$('#collapse-groups').onclick=()=>{if(collapsedGroups.size===Object.keys(GROUPS).length)collapsedGroups.clear();else Object.keys(GROUPS).forEach(g=>collapsedGroups.add(g));renderLayers();};
function section(id,label,content){return `<details class="property-section" data-section="${id}" ${closedSections.has(id)?'':'open'}><summary>${label}</summary><div>${content}</div></details>`;}
$('#inspector').addEventListener('toggle',ev=>{const id=ev.target.dataset.section;if(id)ev.target.open?closedSections.delete(id):closedSections.add(id);},true);
function field(label,key,value,type='text',extra=''){return `<label class="field">${label}<input aria-label="${html(label)}" data-field="${key}" type="${type}" value="${html(value)}" ${extra}></label>`;}
function selectField(label,key,value,options){return `<label class="field">${label}<select aria-label="${html(label)}" data-field="${key}">${Object.entries(options).map(([v,n])=>`<option value="${v}" ${value===v?'selected':''}>${html(n)}</option>`).join('')}</select></label>`;}
function geometryFields(e,multi=false){
 const v=displayGeometry(e,project.viewport,units),w=project.viewport.width,h=project.viewport.height;
 const limits=units==='px'?{x:[-1.5*w,2.5*w],y:[-1.5*h,2.5*h],w:[.005*w/2,2*w],h:[.005*h/2,2*h]}:{x:[-4,4],y:[-4,4],w:[.005,4],h:[.005,4]};
 let fields=Object.entries({x:'X',y:'Y',w:'Ancho',h:'Alto'}).map(([k,label])=>field(label,k,v[k],'number',`step="${units==='px'?1:.005}" min="${limits[k][0]}" max="${limits[k][1]}"`)).join('');
 if(multi)fields=fields.replaceAll('data-field=','data-transform=');
 return `<div class="units-control"><span>Unidades</span><select data-units aria-label="Unidades de posición"><option value="px" ${units==='px'?'selected':''}>Píxeles del diseño</option><option value="ui" ${units==='ui'?'selected':''}>Coordenadas del sistema</option></select></div><div class="field-grid">${fields}</div><p class="hint">${units==='px'?'Origen: esquina superior izquierda. Tamaños del diseño, independientes del zoom.':'Origen: centro · X hacia la derecha · Y hacia arriba.'}${multi?' El conjunto conserva sus proporciones.':''}</p>`;
}
function syncGeometryFields(){
 const es=selected().filter(e=>!e.locked&&visible(e)),e=selection.length>1?selectionBounds(es):selected()[0];if(!e)return;
 const values=displayGeometry(e,project.viewport,units);for(const key of ['x','y','w','h']){const input=$(`#inspector [data-field="${key}"],#inspector [data-transform="${key}"]`);if(input&&document.activeElement!==input)input.value=values[key];}
}
function renderInspector(){
 const es=selected(),e=es[0];$('#selection-type').textContent=es.length===1?TYPES[e.type]:'';
 if(!es.length){$('#inspector').innerHTML='<div class="empty-inspector"><div class="empty-icon">'+icon('mouse-pointer-2')+'</div><strong>Todo empieza con una selección</strong><p>Elige un elemento del lienzo o de la biblioteca para editarlo.</p></div><div class="inspector-tip"><b>Un poco más rápido</b><p>Mantén Mayús para seleccionar varios elementos. Usa «Selección» para acercarte a ellos.</p><kbd>Mayús</kbd> + <kbd>2</kbd></div>';return;}
 if(es.length>1){const movable=es.filter(e=>!e.locked&&visible(e)),b=selectionBounds(movable);$('#inspector').innerHTML=`<div class="multi-label">${es.length} elementos</div><p class="hint">Mueve y escala el conjunto desde su marco. ${es.length-movable.length} bloqueados u ocultos quedan fuera de la transformación.</p>`+(b?section('geometry','Transformar conjunto',geometryFields(b,true)):'')+section('alignment','Alinear',`<div class="align-tools">${[['left','Izquierda'],['center','Centro X'],['right','Derecha'],['top','Arriba'],['middle','Centro Y'],['bottom','Abajo']].map(([v,l])=>`<button data-align="${v}">${l}</button>`).join('')}</div>`)+`<div class="property-actions"><button data-cmd="duplicate">Duplicar</button><button data-cmd="delete">Eliminar</button></div>`;return;}
 const src=textureURL(e.texture);
 const geometry=geometryFields(e);
 let appearance='<div class="field-grid">'+field('Profundidad','z',e.z,'number','step="0.1" min="0" max="100"')+field('Opacidad %','opacity',e.opacity,'number','step="1" min="0" max="100"')+'</div>';
 if(e.type==='panel')appearance+=selectField('Modelo de ventana','modelId',e.modelId,Object.fromEntries(Object.entries(MODELS).map(([k,v])=>[k,v.name])))+'<p class="hint">El marco conserva su proporción al cambiar el tamaño.</p>';
 if(e.type==='text')appearance+='<label class="field">Contenido<textarea aria-label="Contenido" data-field="text">'+html(e.text)+'</textarea></label><div class="field-grid">'+field('Tamaño','font',e.font,'number','step="0.5" min="1" max="40"')+field('Color','color',e.color,'color')+'</div>';
 else if(e.type==='model')appearance+='<p class="notice">Guía de posición 2D. El modelo y su escala se integran en el mapa.</p>';
 else appearance+='<div class="texture-current">'+(src?`<img src="${html(src)}" alt="Textura actual">`:'')+'<button data-cmd="texture">Elegir textura</button></div>'+field('Rawcode de destructible','texture',e.texture,'text','maxlength="4"')+field('Color','color',e.color,'color');
 $('#inspector').innerHTML=field('Nombre','name',e.name)+`<div class="element-id">${html(e.id)}</div>`+(e.locked?'<p class="notice">Posición bloqueada para arrastre y flechas.</p>':'')+
 section('geometry','Posición y tamaño',geometry)+section('appearance',e.type==='text'?'Texto y apariencia':'Apariencia',appearance)+
 (e.type==='button'?section('interaction','Interacción',selectField('Clic izquierdo','action',e.action,ACTIONS)+selectField('Clic derecho','rightAction',e.rightAction,ACTIONS)+(e.action==='custom'||e.rightAction==='custom'?field('Nombre de la acción','customAction',e.customAction):'')):'')+
 section('organization','Organización y enlace',selectField('Grupo','group',e.group,GROUPS)+`<label class="checkbox"><input data-field="locked" type="checkbox" ${e.locked?'checked':''}>Bloquear posición</label><label class="checkbox"><input data-field="visible" type="checkbox" ${e.visible?'checked':''}>Visible en el diseño</label>`+(e.binding?'<p class="hint">Enlace al mapa</p><div class="binding">'+html(e.binding)+'</div>':''))+
 '<div class="property-actions"><button data-cmd="duplicate">Duplicar</button><button data-cmd="front">Al frente</button><button data-cmd="delete" class="danger">Eliminar</button></div>';

}
function renderIssues(){const list=issues(project);$('#issue-count').textContent=list.length;$('#issues').innerHTML=list.length?list.map(i=>`<div class="issue" data-issue="${html(i.id)}"><b>${html(i.id)}</b><br>${html(i.message)}</div>`).join(''):'<p class="hint">Sin elementos fuera del área ni enlaces pendientes detectados.</p>';}
function renderAssets(){
 const q=$('#asset-search').value.trim().toLowerCase(),targets=selected().filter(e=>['button','picture','panel'].includes(e.type));
 const matches=catalog.filter(t=>(t.id+' '+t.name.replace(/([a-z])([A-Z])/g,'$1 $2')).toLowerCase().includes(q));
 $('#asset-context').textContent=targets.length===1?'Aplicar a: '+title(targets[0]):targets.length?`Aplicar a ${targets.length} elementos`:'Selecciona un botón, una imagen o una ventana para aplicar una textura.';
 $('#assets').innerHTML=matches.map(t=>`<button data-texture="${t.id}" aria-label="Aplicar ${html(t.name)}" aria-pressed="${targets.length>0&&targets.every(e=>e.texture===t.id)}" ${targets.length?'':'disabled'} title="${html(t.name)} · ${t.id}"><img src="${t.preview}" alt="" loading="lazy"><span class="asset-name">${html(t.name.replace(/([a-z])([A-Z])/g,'$1 $2'))}</span><small>${t.id}</small></button>`).join('')||'<p class="search-empty">No hay texturas con ese nombre o código.</p>';
}
function revealCreated(){
 $('#layer-search').value='';collapsedGroups.delete('custom');switchTab(false);renderLayers();
 if(innerWidth<=1000){libraryOpen=false;inspectorOpen=true;updatePanels();}
 closedSections.delete('appearance');renderInspector();
 const input=$('#inspector [data-field="text"]')||$('#inspector [data-field="name"]');input?.focus();input?.select();
}
function fieldError(input,message){
 input.setAttribute('aria-invalid',!!message);
 let error=input.closest('.field')?.querySelector('.field-error');
 if(!error){error=document.createElement('small');error.className='field-error';error.id='error-'+(input.dataset.field||input.dataset.transform);error.setAttribute('role','status');input.closest('.field')?.append(error);}
 input.setAttribute('aria-describedby',error.id);error.textContent=message;error.hidden=!message;
}

function newId(type){let n=1;while(project.elements.some(e=>e.id===`custom.${type}.${n}`))n++;return `custom.${type}.${n}`;}
function add(type){commit(()=>{const id=newId(type);const e=element(type,id,-.3,.4,type==='text'?.4:type==='panel'?.5:.09,type==='text'?.07:type==='panel'?.5*MODELS.bwn2.vh/MODELS.bwn2.vw*ASPECT:.09*ASPECT,{text:type==='text'?'Nuevo texto':'',texture:type==='panel'?'D201':'B003'});project.elements.push(e);selection=[id];filterGroups.add('custom');});revealCreated();}
function duplicate(){if(!selected().length)return;commit(()=>{const ids=[];for(const e of selected()){const c=clone(e);c.id=newId(c.type);c.name+=' · copia';c.x=round(c.x+.025);c.y=round(c.y-.025);c.binding='';c.group='custom';c.locked=false;project.elements.push(c);ids.push(c.id);}selection=ids;filterGroups.add('custom');});revealCreated();}
function remove(){if(!selected().some(e=>!e.locked))return;commit(()=>{project.elements=project.elements.filter(e=>!selection.includes(e.id)||e.locked);selection=[];});}
function changeField(key,value){const e=selected()[0];if(!e)return;if(['x','y','w','h','z','font','opacity'].includes(key)){value=Number(value);if(!Number.isFinite(value))return;}
 const candidate=clone(project),c=candidate.elements.find(x=>x.id===e.id);c[key]=value;
 if(c.type==='panel'&&['w','h','modelId'].includes(key)){const m=MODELS[c.modelId],ratio=m.vh/m.vw*ASPECT;if(key==='h')c.w=round(c.h/ratio);else c.h=round(c.w*ratio);}
 try{validateProject(candidate);commit(()=>{project=candidate;});}catch(err){toast(err.message);renderInspector();}
}
function align(type){const es=selected().filter(e=>!e.locked);if(es.length<2)return;commit(()=>{const l=Math.min(...es.map(e=>e.x)),r=Math.max(...es.map(e=>e.x+e.w)),t=Math.max(...es.map(e=>e.y)),b=Math.min(...es.map(e=>e.y-e.h));for(const e of es){if(type==='left')e.x=l;if(type==='center')e.x=(l+r-e.w)/2;if(type==='right')e.x=r-e.w;if(type==='top')e.y=t;if(type==='middle')e.y=(t+b+e.h)/2;if(type==='bottom')e.y=b+e.h;e.x=round(e.x);e.y=round(e.y);}});}
function download(text,filename,type){const u=URL.createObjectURL(new Blob([text],{type})),a=document.createElement('a');a.href=u;a.download=filename;a.click();setTimeout(()=>URL.revokeObjectURL(u),1000);toast('Descarga preparada: '+filename);}
function saveJSON(){download(JSON.stringify(project,null,2),'interfaz.wc3ui.json','application/json');}
function setMode(next){if(next===mode)return;if(next==='preview'){editSelection=[...selection];selection=[];}else selection=editSelection.filter(id=>project.elements.some(e=>e.id===id));mode=next;spaceDown=false;setCanvasTool('select');simHidden.clear();simSelected='';page=1;document.body.dataset.mode=mode;$('#edit-mode').setAttribute('aria-pressed',mode==='edit');$('#preview-mode').setAttribute('aria-pressed',mode==='preview');$('#edit-mode').classList.toggle('active',mode==='edit');$('#preview-mode').classList.toggle('active',mode==='preview');if(mode==='preview')toast('Simulación: clic izquierdo o derecho sobre los botones.');render();}
function simulate(e,right){if(e.type!=='button')return;const action=right?e.rightAction:e.action;simSelected=e.id;if(action==='previous')page=(page+3)%5+1;if(action==='next')page=page%5+1;if(action==='close')simHidden.add(e.group);toast('Simulación · '+(action==='custom'?e.customAction||'Acción personalizada':ACTIONS[action]));renderStage();}
let drag=null;
function setCanvasTool(tool){canvasTool=tool;$('#tool-select').setAttribute('aria-pressed',tool==='select');$('#tool-hand').setAttribute('aria-pressed',tool==='hand');$('#viewport').classList.toggle('hand-tool',tool==='hand'||spaceDown);}
$('#tool-select').onclick=()=>setCanvasTool('select');$('#tool-hand').onclick=()=>setCanvasTool('hand');
function applyTransformed(elements){for(const value of elements){const e=project.elements.find(e=>e.id===value.id);Object.assign(e,{x:value.x,y:value.y,w:value.w,h:value.h});if(e.type==='text')e.font=value.font;}}
function paintLiveGeometry(){
 const elements=new Map(project.elements.map(e=>[e.id,e])),height=$('#stage').clientHeight;
 for(const node of $$('#objects [data-id]')){const e=elements.get(node.dataset.id);Object.assign(node.style,{left:(e.x+1)*50+'%',top:(1-e.y)*50+'%',width:e.w*50+'%',height:e.h*50+'%',fontSize:e.font*.0023*height+'px'});}
 renderSelectionFrame();syncGeometryFields();
 const font=$('#inspector [data-field="font"]');if(font&&document.activeElement!==font&&selected().length===1)font.value=selected()[0].font;
}
function finishGesture(cancel=false){
 if(!drag)return;const previous=drag;drag=null;$('#marquee').hidden=true;$('#viewport').classList.remove('is-panning');
 if(previous.kind==='pan')return;
 if(cancel){if(previous.snapshot)project=previous.snapshot;selection=previous.selection;}
 else if(previous.kind!=='marquee'&&previous.changed){past.push(previous.snapshot);if(past.length>80)past.shift();future=[];saveLocal();}
 render();
}
$('#viewport').addEventListener('pointerdown',ev=>{
 if(ev.button!==0&&ev.button!==1)return;
 const viewport=$('#viewport');
 if(canvasTool==='hand'||spaceDown||ev.button===1){ev.preventDefault();drag={kind:'pan',x:ev.clientX,y:ev.clientY,left:viewport.scrollLeft,top:viewport.scrollTop};viewport.classList.add('is-panning');viewport.setPointerCapture(ev.pointerId);return;}
 if(!ev.target.closest('#stage'))return;
 const target=ev.target.closest('[data-id]'),handle=ev.target.closest('[data-handle]')?.dataset.handle;
 if(mode==='preview'){if(target&&ev.button===0)simulate(project.elements.find(e=>e.id===target.dataset.id),false);return;}
 if(ev.button!==0)return;ev.preventDefault();pendingEdit='';pendingTransform=null;
 const priorSelection=[...selection],rect=$('#stage').getBoundingClientRect();
 if(handle){drag={kind:'resize',handle};}
 else if(target){const e=project.elements.find(e=>e.id===target.dataset.id);if(ev.shiftKey){choose(e.id,true);return;}if(!selection.includes(e.id))choose(e.id);if(e.locked)return;drag={kind:'move'};}
 else{drag={kind:'marquee',base:ev.shiftKey?[...selection]:[]};if(!ev.shiftKey)selection=[];}
 Object.assign(drag,{x:ev.clientX,y:ev.clientY,rect,selection:priorSelection,snapshot:clone(project),originals:clone(selected().filter(e=>!e.locked&&visible(e))),changed:false});
 viewport.setPointerCapture(ev.pointerId);
});
$('#viewport').addEventListener('pointermove',ev=>{
 if(!drag)return;
 const deltaX=ev.clientX-drag.x,deltaY=ev.clientY-drag.y;
 if(drag.kind==='pan'){$('#viewport').scrollTo(drag.left-deltaX,drag.top-deltaY);return;}
 if(Math.abs(deltaX)+Math.abs(deltaY)<3&&!drag.changed)return;
 const dx=deltaX*2/drag.rect.width,dy=-deltaY*2/drag.rect.height;
 if(drag.kind==='marquee'){
  const left=Math.min(drag.x,ev.clientX)-drag.rect.left,top=Math.min(drag.y,ev.clientY)-drag.rect.top,w=Math.abs(deltaX),h=Math.abs(deltaY),box=$('#marquee');
  box.hidden=false;Object.assign(box.style,{left:left+'px',top:top+'px',width:w+'px',height:h+'px'});
  const ids=project.elements.filter(e=>visible(e)&&!e.locked).filter(e=>{const x=(e.x+1)*drag.rect.width/2,y=(1-e.y)*drag.rect.height/2;return x>=left&&y>=top&&x+e.w*drag.rect.width/2<=left+w&&y+e.h*drag.rect.height/2<=top+h;}).map(e=>e.id);
  selection=[...new Set([...drag.base,...ids])];drag.changed=true;renderStage();return;
 }
 let transformed;
 if(drag.kind==='resize')transformed=resizeSelection(drag.originals,drag.handle,dx,dy,ev.shiftKey);
 else{const anchor=selectionBounds(drag.originals);if(!anchor)return;const snap=n=>$('#snap').checked?Math.round(n/.01)*.01:n;transformed=moveSelection(drag.originals,snap(anchor.x+dx)-anchor.x,snap(anchor.y+dy)-anchor.y);}
 applyTransformed(transformed);drag.changed=transformed.some((e,i)=>['x','y','w','h','font'].some(k=>e[k]!==drag.originals[i][k]));paintLiveGeometry();
});
$('#viewport').addEventListener('pointerup',()=>finishGesture());$('#viewport').addEventListener('pointercancel',()=>finishGesture(true));
$('#viewport').addEventListener('lostpointercapture',()=>finishGesture());
$('#stage').addEventListener('contextmenu',ev=>{ev.preventDefault();if(mode==='preview'){const t=ev.target.closest('[data-id]');if(t)simulate(project.elements.find(e=>e.id===t.dataset.id),true);}});
$('#viewport').addEventListener('wheel',ev=>{
 if(!ev.ctrlKey&&!ev.metaKey)return;ev.preventDefault();if(drag)return;
 const viewport=$('#viewport'),before=$('#stage').getBoundingClientRect(),rx=(ev.clientX-before.left)/before.width,ry=(ev.clientY-before.top)/before.height;
 setZoom(zoom*Math.exp(-ev.deltaY*.002));const after=$('#stage').getBoundingClientRect();viewport.scrollBy(after.left+rx*after.width-ev.clientX,after.top+ry*after.height-ev.clientY);
},{passive:false});
window.addEventListener('keyup',ev=>{if(ev.code==='Space'){spaceDown=false;setCanvasTool(canvasTool);}});
window.addEventListener('blur',()=>{spaceDown=false;setCanvasTool(canvasTool);finishGesture(true);});
let pendingEdit='';
$('#inspector').addEventListener('input',ev=>{
 const key=ev.target.dataset.transform;if(!key)return;
 let value=Number(ev.target.value);if(ev.target.value===''||!Number.isFinite(value)){fieldError(ev.target,'Introduce un número válido.');return;}
 const es=selected().filter(e=>!e.locked&&visible(e));if(!es.length)return;
 if(!pendingTransform||pendingTransform.key!==key)pendingTransform={key,originals:clone(es),snapshot:clone(project),saved:false};
 const b=selectionBounds(pendingTransform.originals);value=geometryValue(key,value,project.viewport,units);
 if((key==='w'||key==='h')&&value<=0){fieldError(ev.target,'El tamaño debe ser mayor que cero.');return;}
 const transformed=key==='x'||key==='y'?moveSelection(pendingTransform.originals,key==='x'?value-b.x:0,key==='y'?value-b.y:0):resizeSelection(pendingTransform.originals,'se',key==='w'?value-b.w:0,key==='h'?b.h-value:0,true);
 if(Math.abs(selectionBounds(transformed)[key]-value)>.0001){fieldError(ev.target,'Fuera de los límites del diseño. Este valor no se ha guardado.');return;}
 const candidate=clone(project);for(const e of transformed)Object.assign(candidate.elements.find(x=>x.id===e.id),e);
 try{validateProject(candidate);}catch(err){fieldError(ev.target,err.message);return;}
 if(!pendingTransform.saved){past.push(pendingTransform.snapshot);if(past.length>80)past.shift();future=[];pendingTransform.saved=true;}
 project=candidate;fieldError(ev.target,'');saveLocal();paintLiveGeometry();renderIssues();$('#undo').disabled=false;$('#redo').disabled=true;
});
$('#inspector').addEventListener('input',ev=>{
 const key=ev.target.dataset.field,e=selected()[0];if(!e||!key||ev.target.matches('select,input[type=checkbox]'))return;
 let value=ev.target.value;if(['x','y','w','h','z','font','opacity'].includes(key)){if(value===''){fieldError(ev.target,'Introduce un número. Este valor no se ha guardado.');return;}value=Number(value);
 const min=Number(ev.target.min),max=Number(ev.target.max);if(!Number.isFinite(value)||value<min||value>max){fieldError(ev.target,`Usa un valor entre ${min} y ${max}. Este valor no se ha guardado.`);return;}}
 if(['x','y','w','h'].includes(key))value=geometryValue(key,value,project.viewport,units);
 const candidate=clone(project),c=candidate.elements.find(x=>x.id===e.id);c[key]=value;
 if(c.type==='panel'&&['w','h'].includes(key)){const m=MODELS[c.modelId],ratio=m.vh/m.vw*ASPECT;if(key==='h')c.w=round(c.h/ratio);else c.h=round(c.w*ratio);}
 try{validateProject(candidate);}catch(err){fieldError(ev.target,err.message+' Este valor no se ha guardado.');return;}
 fieldError(ev.target,'');if(c[key]===e[key])return;
 if(pendingEdit!==e.id+key){remember();pendingEdit=e.id+key;}
 project=candidate;saveLocal();renderStage();renderLayers();renderIssues();$('#undo').disabled=!past.length;$('#redo').disabled=true;
 if(c.type==='panel'&&['w','h'].includes(key)){const other=key==='w'?'h':'w';$('#inspector [data-field="'+other+'"]').value=displayGeometry(c,project.viewport,units)[other];}
});
$('#inspector').addEventListener('change',ev=>{if(ev.target.dataset.units!==undefined){units=ev.target.value;pendingEdit='';pendingTransform=null;renderInspector();return;}if(ev.target.dataset.transform){pendingTransform=null;return;}const key=ev.target.dataset.field;if(!key)return;if(ev.target.matches('select,input[type=checkbox]'))changeField(key,ev.target.type==='checkbox'?ev.target.checked:ev.target.value);else{pendingEdit='';}});
document.addEventListener('click',ev=>{
 const t=ev.target.closest('button,[data-layer],[data-issue]');if(!t)return;
 if(t.dataset.close!==undefined){t.closest('dialog').close();return;}
 if(t.dataset.add){setMode('edit');add(t.dataset.add);}
 else if(t.dataset.lock)commit(()=>{const e=project.elements.find(e=>e.id===t.dataset.lock);e.locked=!e.locked;});
 else if(t.dataset.visible)commit(()=>{const e=project.elements.find(e=>e.id===t.dataset.visible);e.visible=!e.visible;});
 else if(t.dataset.layer){const id=t.dataset.layer;choose(id,ev.shiftKey);$$('[data-layer]').find(b=>b.dataset.layer===id)?.focus({preventScroll:true});}
 else if(t.dataset.toggleGroup){const g=t.dataset.toggleGroup;collapsedGroups.has(g)?collapsedGroups.delete(g):collapsedGroups.add(g);renderLayers();$(`[data-toggle-group="${g}"]`).focus();}
 else if(t.dataset.selectGroup){if(mode==='preview')setMode('edit');selection=matchingLayers(t.dataset.selectGroup).map(e=>e.id);render();}
 else if(t.dataset.filter){const g=t.dataset.filter;filterGroups.has(g)?filterGroups.delete(g):filterGroups.add(g);render();}
 else if(t.dataset.texture){const es=selected().filter(e=>['button','picture','panel'].includes(e.type));if(!es.length){toast('Selecciona primero un botón, una imagen o una ventana.');return;}commit(()=>es.forEach(e=>e.texture=t.dataset.texture));}
 else if(t.dataset.issue){setMode('edit');filterGroups.add(project.elements.find(e=>e.id===t.dataset.issue).group);choose(t.dataset.issue);}
 else if(t.dataset.align)align(t.dataset.align);
 else if(t.dataset.cmd==='duplicate')duplicate();else if(t.dataset.cmd==='delete')remove();else if(t.dataset.cmd==='texture')switchTab(true);
 else if(t.dataset.cmd==='front')commit(()=>{const es=selected();project.elements=project.elements.filter(e=>!selection.includes(e.id)).concat(es);});
});
$('#tab-assets').onclick=()=>switchTab(true);$('#tab-layers').onclick=()=>switchTab(false);
$('#layer-search').oninput=renderLayers;$('#asset-search').oninput=renderAssets;
$('#project-name').onchange=ev=>commit(()=>{project.name=ev.target.value.trim()||'Mi interfaz';});
$('#aspect').onchange=ev=>{commit(()=>{const [width,height]=ev.target.value.split(',').map(Number);project.viewport={width,height};});fitCanvas();};
$('#grid').onchange=()=>$('#stage').classList.toggle('grid',$('#grid').checked);
$('#edit-mode').onclick=()=>setMode('edit');$('#preview-mode').onclick=()=>setMode('preview');
$('#samples').onclick=()=>{showSamples=!showSamples;$('#samples').setAttribute('aria-pressed',showSamples);$('#samples').classList.toggle('active',showSamples);renderStage();};
function undo(){if(!past.length)return;future.push(clone(project));project=past.pop();selection=selection.filter(id=>project.elements.some(e=>e.id===id));saveLocal();render();}
function redo(){if(!future.length)return;past.push(clone(project));project=future.pop();selection=[];saveLocal();render();}
$('#undo').onclick=undo;$('#redo').onclick=redo;
function fitWidth(){const v=$('#viewport'),style=getComputedStyle(v);return Math.max(100,Math.min(v.clientWidth-parseFloat(style.paddingLeft)-parseFloat(style.paddingRight),(v.clientHeight-90)*project.viewport.width/project.viewport.height));}
function applyZoom(){const width=fitWidth()*zoom;$('#stage-wrap').style.width=width+'px';$('#stage-wrap').style.maxWidth='none';$('#zoom-level').textContent=Math.round(zoom*100)+'%';renderStage();}
function setZoom(v){fitting=false;zoom=Math.max(.4,Math.min(6,v));applyZoom();}
function fitCanvas(){fitting=true;zoom=1;applyZoom();$('#viewport').scrollTo(0,0);}
function fitSelection(){const es=selected().filter(visible);if(!es.length)return;
 const l=Math.max(-1,Math.min(...es.map(e=>e.x))),r=Math.min(1,Math.max(...es.map(e=>e.x+e.w))),t=Math.min(1,Math.max(...es.map(e=>e.y))),b=Math.max(-1,Math.min(...es.map(e=>e.y-e.h)));
 if(r<=l||t<=b){toast('La selección está fuera del lienzo.');return;}
 const v=$('#viewport'),base=fitWidth();setZoom(Math.min((v.clientWidth-100)/(base*(r-l)/2),(v.clientHeight-130)/(base*project.viewport.height/project.viewport.width*(t-b)/2)));
 requestAnimationFrame(()=>{const rect=$('#stage').getBoundingClientRect(),vr=v.getBoundingClientRect();v.scrollTo({left:v.scrollLeft+rect.left-vr.left+((l+r)/2+1)*rect.width/2-v.clientWidth/2,top:v.scrollTop+rect.top-vr.top+(1-(t+b)/2)*rect.height/2-v.clientHeight/2});});
}
$('#zoom-in').onclick=()=>setZoom(zoom+.25);$('#zoom-out').onclick=()=>setZoom(zoom-.25);$('#fit').onclick=fitCanvas;$('#fit-selection').onclick=fitSelection;
new ResizeObserver(()=>{if(fitting)zoom=1;applyZoom();}).observe($('#viewport'));
window.addEventListener('resize',()=>{if(innerWidth<=1000&&libraryOpen&&inspectorOpen){libraryOpen=false;inspectorOpen=false;}updatePanels();});
$('#save').onclick=saveJSON;$('#download-json').onclick=saveJSON;
$('#export').onclick=()=>{$('#saved-folder').textContent='';$('#code-preview').value=exportJass(project);$('#export-dialog').showModal();};
$('#download-jass').onclick=()=>download(exportJass(project),'UIStudioLayout.j','text/plain');
$('#download-notes').onclick=()=>download(integrationNotes(project),'Integracion.txt','text/plain');
$('#save-folder').onclick=async()=>{const b=$('#save-folder');b.disabled=true;try{const response=await fetch('/api/save',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(project)});const data=await response.json();if(!response.ok)throw Error(data.error||'No se pudo guardar');$('#saved-folder').textContent='Entrega guardada: '+data.path;toast('JSON, vJASS y guía guardados en tu carpeta local.');}catch{toast('No se pudo guardar en carpeta. Usa las descargas individuales.');}finally{b.disabled=false;}};
$('#help').onclick=()=>$('#help-dialog').showModal();$('#show-issues').onclick=()=>$('#issues').hidden=!$('#issues').hidden;
function confirmReplace(name,fn){$('#confirm-title').textContent=name;$('#confirm-dialog').showModal();$('#confirm-accept').onclick=()=>{$('#confirm-dialog').close();commit(()=>{project=fn();selection=[];});};}
$('#reset').onclick=()=>confirmReplace('Cargar el diseño original del mapa',preset);
$('#blank').onclick=()=>confirmReplace('Crear un proyecto vacío',()=>({...preset(),name:'Mi interfaz',elements:[]}));
$('#open').onclick=()=>$('#file-input').click();
$('#file-input').onchange=async ev=>{const file=ev.target.files[0];ev.target.value='';if(!file)return;try{if(file.size>4*1024*1024)throw new Error('El archivo es demasiado grande. Máximo: 4 MB.');const p=validateProject(JSON.parse(await file.text()));confirmReplace('Abrir '+p.name,()=>p);}catch(err){toast('No se pudo abrir: '+err.message);}};
document.addEventListener('keydown',ev=>{
 if($('dialog[open]'))return;
 if(ev.key==='Escape'&&drag){ev.preventDefault();finishGesture(true);return;}
 if(ev.key==='Escape'&&innerWidth<=1000&&(libraryOpen||inspectorOpen)){libraryOpen=false;inspectorOpen=false;updatePanels();$('#toggle-library').focus();return;}
 if(ev.target.matches('input,textarea,select'))return;
 if(ev.code==='Space'){ev.preventDefault();spaceDown=true;setCanvasTool(canvasTool);return;}
 if(!ev.ctrlKey&&!ev.metaKey&&['v','h'].includes(ev.key.toLowerCase())){ev.preventDefault();setCanvasTool(ev.key.toLowerCase()==='h'?'hand':'select');return;}
 if((ev.ctrlKey||ev.metaKey)&&ev.key.toLowerCase()==='s'){ev.preventDefault();saveJSON();return;}
 if(!ev.ctrlKey&&!ev.metaKey&&ev.key.toLowerCase()==='f'){ev.preventDefault();toggleFocus();return;}
 if(ev.shiftKey&&ev.code==='Digit1'){ev.preventDefault();fitCanvas();return;}
 if(ev.shiftKey&&ev.code==='Digit2'){ev.preventDefault();fitSelection();return;}
 if(mode!=='edit')return;
 if((ev.ctrlKey||ev.metaKey)&&ev.key.toLowerCase()==='z'){ev.preventDefault();ev.shiftKey?redo():undo();return;}
 if((ev.ctrlKey||ev.metaKey)&&ev.key.toLowerCase()==='d'){ev.preventDefault();duplicate();return;}
 if(ev.key==='Delete'||ev.key==='Backspace'){ev.preventDefault();remove();return;}
 if(ev.key==='Escape'){selection=[];render();return;}
 if(ev.key.startsWith('Arrow')&&selection.length){ev.preventDefault();const step=ev.shiftKey?.02:.005;commit(()=>applyTransformed(moveSelection(selected().filter(e=>!e.locked&&visible(e)),ev.key==='ArrowRight'?step:ev.key==='ArrowLeft'?-step:0,ev.key==='ArrowUp'?step:ev.key==='ArrowDown'?-step:0)));}
});
new ResizeObserver(()=>renderStage()).observe($('#stage'));
updatePanels();render();renderAssets();fitCanvas();if(storageError)toast('No se pudo recuperar el autoguardado. Se cargó la prueba del mapa.');
// Feature-detected local design access. No external transmission or map mutation.
if(document.modelContext?.registerTool){
 const controller=new AbortController();window.addEventListener('pagehide',()=>controller.abort(),{once:true});
 for(const tool of [
  {name:'read_ui_design',title:'Leer diseño de interfaz',description:'Devuelve el proyecto local actual, sus coordenadas y enlaces.',inputSchema:{type:'object',properties:{},additionalProperties:false},annotations:{readOnlyHint:true},execute:()=>clone(project)},
  {name:'update_ui_positions',title:'Mover elementos del diseño',description:'Actualiza posiciones en el editor local. No modifica ni compila el mapa.',inputSchema:{type:'object',properties:{elements:{type:'array',items:{type:'object',properties:{id:{type:'string'},x:{type:'number'},y:{type:'number'}},required:['id','x','y'],additionalProperties:false}}},required:['elements'],additionalProperties:false},execute:input=>{if(!input||!Array.isArray(input.elements))throw Error('elements requerido');const p=clone(project);for(const x of input.elements){const e=p.elements.find(e=>e.id===x.id);if(!e||e.locked)throw Error('Elemento inexistente o bloqueado');e.x=x.x;e.y=x.y;}validateProject(p);commit(()=>project=p);return {updated:input.elements.length};}}
 ])try{Promise.resolve(document.modelContext.registerTool(tool,{signal:controller.signal})).catch(()=>{});}catch{}
}

window.addEventListener('pagehide',()=>{try{localStorage.setItem(STORAGE,JSON.stringify(project));}catch{}});
