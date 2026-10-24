from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parent
M=json.loads((R/'manifest.json').read_text())
records=[
('systematic-debugging','Adaptar primero','Alto','Parcial','Secuencia concreta de reproducción, trazado hacia el origen, comparación y prueba de una hipótesis. Aporta más procedimiento que nuestras reglas generales.',
 'Conservar referencias root-cause-tracing y condition-based-waiting. Desacoplar TDD/verificación universales; distinguir errores de Wine, compilador, MPQ y motor. Tres arreglos fallidos justifican revisar hipótesis, no prueban una arquitectura incorrecta.'),
('writing-plans','Adaptar para trabajos grandes','Medio-alto','Parcial','Contratos exactos entre tareas, restricciones globales, verificaciones y cobertura del diseño. Puede servir de relevo entre chats.',
 'Activar para cambios de varias fases; mantener planes/decisiones en el proyecto. Usar verificaciones reales 1.27b y evitar commits o aprobaciones repetidas por rutina cuando la ejecución ya esté autorizada. Suprimir obligación de entrar en otros ejecutores.'),
('test-driven-development','Uso selectivo','Alto con runner; condicionado en mapas','Parcial','Red-green real aporta a scripts Python/TypeScript y a regresiones reproducibles.',
 'Para vJASS definir harness y mapa de ensayo reales. Un script Python que reescribe una fórmula no demuestra el comportamiento del JASS ni del motor. No borrar código útil para cumplir una secuencia ritual ni exigir pruebas para cada edición documental.'),
('verification-before-completion','Mantener lo existente','Bajo aporte incremental','Alto','Exige evidencia observable y distingue linter, compilación y corrección; nuestra AGENTS y skills Warcraft ya cubren esas distinciones.',
 'Si se reutiliza alguna pauta, ligarla al hash/versión examinados y a cobertura real. No repetir verificaciones sólo porque empieza otro mensaje; repetir cuando cambia el estado o queda una duda pertinente.'),
('receiving-code-review','Mantener lo existente','Bajo aporte incremental','Alto','Comprobar sugerencias contra el código y el entorno coincide con la política contra complacencia y Judgment Day.',
 'Evitar paradas de todo el trabajo por una duda localizada; continuar lo independiente. Mantener autorización explícita para mensajes a GitHub y respetar alcance de una revisión sin permiso de corrección.'),
('brainstorming','Reservar para ideas abiertas','Medio','Parcial','Puede ayudar a definir una habilidad o sistema cuando falta una decisión funcional importante. La versión revisada permite ejecutar directamente tareas claras.',
 'Activación acotada. Evitar una cadena obligatoria de preguntas, aprobación y plan para ajustes ya definidos. El acompañante visual tiene poco aporte incremental frente a nuestras visualizaciones disponibles.'),
('executing-plans','Reservar; adaptación importante','Medio','Parcial','Ejecución secuencial, ledger, recuperación por tarea y un revisor final pueden servir para trabajos largos.',
 'Conservar logs/decisiones fuera del scratch antes de su limpieza; distinguir decisiones rutinarias de cambios de alcance. Cubrir fuentes y mapas sin commit. Sustituir modelo forzado por política vigente y TDD general por verificación pertinente.'),
('requesting-code-review','Reservar como revisión simple','Medio','Parcial con Judgment Day','Un revisor separado puede ser más proporcionado que dos jueces para una revisión común; no equivale al protocolo adversarial de Judgment Day.',
 'Activarlo dentro de la autorización de delegación. Incluir snapshot/identidad y dependencias, no sólo un rango de commits si hay cambios sin commit. No añadir otra revisión duplicada cuando Judgment Day ya cubra el mismo alcance.'),
('dispatching-parallel-agents','Reservar para independencia demostrada','Medio','Parcial con herramientas nativas','Aporta separación de contextos y tareas por dominio. Su propio texto excluye trabajos con estado compartido.',
 'Respetar autorización y slots disponibles. Un escritor por W3X/MPQ; no controlar en paralelo el mismo juego/editor/prefijo o modificar el mismo núcleo. Integrar y verificar cambios relacionados juntos.'),
('subagent-driven-development','No adoptar como flujo base','Condicionado a proyectos grandes','Alto con ejecución/revisión existentes','Implementador por tarea, revisión de tarea y revisión final; conserva contexto por archivos. Los implementadores se ejecutan secuencialmente, no en paralelo.',
 'Exige numerosas skills/auxiliares, commits y hasta cinco rondas de corrección por tarea, además de selección explícita de modelos. Adaptar autorización, presupuesto, evidencias, revisión tras arreglos y estados con hallazgos aparcados. No apilarlo sobre Judgment Day por defecto.'),
('using-git-worktrees','Usar capacidades nativas actuales','Bajo aporte incremental','Alto','Detecta worktrees existentes y prioriza herramientas nativas, ideas compatibles con nuestro entorno.',
 'No inferir propiedad por nombre .worktrees/worktrees. Usar identidad del checkout gestionado por Codex; evitar instalar dependencias modernas genéricamente. Un worktree no aísla por sí mismo prefijos Wine o archivos referidos mediante rutas absolutas.'),
('finishing-a-development-branch','Usar flujo nativo actual','Bajo aporte incremental','Alto','Organiza integración, PR y conservación del trabajo; separa descarte solicitado de limpieza.',
 'Usar controles de Codex para sus worktrees y adjuntar PRs creadas. No añadir menús/reconfirmaciones cuando exista decisión explícita. La ruta de una carpeta no demuestra que la creó esta tarea.'),
('writing-skills','Conservar skill-creator oficial','Bajo aporte incremental','Alto','Contiene métodos útiles para evaluar aplicación real y activación de una skill, no sólo su YAML.',
 'Nuestra skill-creator ya contempla forward-testing cuando aporta. No adoptar obligación universal de baseline fallido, múltiples repeticiones, subagentes, borrar y rehacer documentación por cada cambio. Guardar pruebas A/B para casos de riesgo o fallos reales.'),
('using-superpowers','No activar globalmente','Bajo para nuestro flujo','Alto; cambia la selección de procesos','Su bootstrap carga un método global y exige usar skills incluso con una probabilidad mínima de pertinencia.',
 'No necesitamos ese bootstrap para estudiar o adaptar una skill concreta. Su activación es demasiado amplia para nuestro criterio de pertinencia y llevaría a cargar cadenas redundantes. Las instrucciones de la sesión prevalecen sobre el repositorio.'),
('diagnosing-superpowers','No hace falta actualmente','Condicionado a usar Superpowers','Específico del paquete','Audita sesiones y extrae evidencia sobre fallos de uso del paquete; exige siete dimensiones de análisis y protocolos de exportación.',
 'Sólo tiene sentido si se usa Superpowers y hay un problema concreto que diagnosticar. Su protocolo completo no es una herramienta general ligera contra errores del agente. No exportar conversaciones ni abrir incidencias sin autorización.')]
items=[]
for name,verdict,value,overlap,benefit,adapt in records:
 p=R/'upstream/skills'/name/'SKILL.md'
 url=f"https://github.com/obra/superpowers/blob/{M['commit']}/skills/{name}/SKILL.md"
 items.append({'skill':name,'decision':verdict,'incremental_value':value,'overlap':overlap,'contribution':benefit,'adaptation_or_limit':adapt,'source_url':url,'source_sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
assert len(items)==M['skills_review_scope']==15
assert len(set(x['skill'] for x in items))==15
for f in M['files']:
 assert hashlib.sha256((R/'upstream'/f['path']).read_bytes()).hexdigest()==f['sha256'],f['path']
review={
 'date':'2026-10-20','repository':M['repository'],'commit':M['commit'],'version':M['version'],
 'scope':{'skill_entrypoints_reviewed':15,'additional_upstream_files':len(M['files'])-15,'original_helpers_exercised':2,'model_behavior_AB_tests':0,'warcraft_runtime_tests':0},
 'method':'Static instruction/dependency review against local AGENTS, Warcraft build/test skills, CodeGraph limits and Judgment Day; bounded helper checks in a temporary Git fixture.',
 'decision':'Do not install the full package. First candidate: adapt systematic-debugging; second: writing-plans for substantial multi-stage work. TDD selectively for code with an appropriate real test harness.',
 'important_correction':'Selecting systematic-debugging is not a self-contained copy: its text calls TDD and verification skills and has supporting references. A local adaptation must explicitly resolve that chain.',
 'what_this_does_not_prove':'No measured reduction in agent errors, elapsed time or token use; no validation of the installed marketplace payload or compatibility with every Codex client; no execution of Superpowers as active skills.',
 'autovalidation':'Verification instructions can improve discipline, but are not independent execution or a semantic oracle. Reviewers can share errors. Keep compiler/runtime evidence and the scoped independent review protocol where justified.',
 'local_changes':'Only evaluation sources, evidence and reports under work/evaluacion-superpowers-20261020. No skill/plugin installation, Codex configuration changes, source/map modification, or global activation.',
 'skills':items,'helper_evidence':'pruebas-auxiliares.json','source_manifest':'manifest.json'}
(R/'evaluacion.json').write_text(json.dumps(review,ensure_ascii=False,indent=2)+'\n')
lines=['EVALUACIÓN DE SUPERPOWERS PARA ESTE PROYECTO','20 de octubre de 2026',f"Versión declarada: {M['version']}; commit: {M['commit']}",'',review['decision'],'',
 'ALCANCE',f"15 skills y {len(M['files'])-15} archivos complementarios revisados. Dos auxiliares originales ensayados en un repositorio Git temporal. Cero pruebas A/B de agentes y cero pruebas de Warcraft.",'',
 'RESULTADO POR SKILL']
for i in items:
 lines += ['',i['skill']+' — '+i['decision'],'Aporte: '+i['contribution'],'Adaptación/límite: '+i['adaptation_or_limit'],'Fuente: '+i['source_url']]
lines += ['','HALLAZGOS TRANSVERSALES',
 '1. La skill de depuración no es autónoma: remite a TDD, verificación y referencias. Copiar sólo SKILL.md no reproduce el conjunto.',
 '2. Los flujos de ejecución registran evidencias y decisiones en scratch ignorado por Git y ordenan eliminarlo al terminar. Para memoria del proyecto hay que conservar lo relevante de forma duradera.',
 '3. La prueba real de review-package incluyó el delta con commit y excluyó cambios sin commit y un mapa no rastreado; ése es su contrato de rango, no una revisión del checkout completo. Rechazó correctamente un rango vacío con salida 3.',
 '4. La prueba real de sdd-workspace separó dos planes con el mismo nombre y reutilizó la carpeta del mismo plan. Esa separación funcionó en el caso probado.',
 '5. La política de modelos, esperas y creación/limpieza de worktrees debe ajustarse a las herramientas y reglas actuales de Codex. No copiar rutas, modelos o capacidades de otra sesión.',
 '6. No se ha demostrado que añadir estas instrucciones reduzca errores o ahorre tokens. Las skills no añaden soporte semántico de vJASS ni reemplazan JassHelper/pJASS y pruebas en motor.',
 '', 'EVIDENCIA Y LÍMITES',review['what_this_does_not_prove'],review['local_changes'],
 'Detalles estructurados: evaluacion.json. Hashes upstream: manifest.json. Ensayo reproducible: probar_auxiliares.py. Resultados: pruebas-auxiliares.json.']
(R/'EVALUACION.txt').write_text('\n'.join(lines)+'\n')
print('Reviewed skills:',len(items),'Upstream files checked:',len(M['files']))
print('Reports:',R/'EVALUACION.txt',R/'evaluacion.json')
print('All pinned source hashes match the manifest.')
