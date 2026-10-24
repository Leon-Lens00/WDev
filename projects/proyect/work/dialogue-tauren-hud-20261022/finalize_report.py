from pathlib import Path
import json,hashlib,datetime
root=Path('/home/snz/Documentos/ChatGPT/Proyect');r=root/'TerrainDev/dialogue-system';w=root/'work/dialogue-tauren-hud-20261022';m=json.loads((r/'latest-build.json').read_text());identity=json.loads((w/'patrol-video-identity.json').read_text());exit=json.loads((w/'patrol-exit.json').read_text());video=w/'dialogo-patrulla.mp4'
assert hashlib.sha256((r/'TerrainDev-Dialogue.w3x').read_bytes()).hexdigest()==m['sha256']==identity['map_sha256'];assert exit['exited'];assert not Path('/proc',str(identity['pid'])).exists()
test=json.loads((w/'before-blend-latest-game-test.json').read_text());test.update(date=datetime.datetime.now().astimezone().isoformat(),map_sha256=m['sha256'],build=m['build'],pid=identity['pid'],exit=exit,video=str(video),video_validation=str(w/'patrol-video-validation.json'),native_screenshot=str(w/'patrol-return.png'))
test['passed'][0]='47 UI Studio Node tests, including punctuation talk continuity, idle cycles, pose blend completion/interruption/rewind'
test['passed'] += ['Native 200ms pose blend: uble=0.20 only on portrait actors; frame keeps uble=0; MDX BlendTime=200','Partial-page text pause and resume with continuing Stand motion; native frame comparison recorded','Patrol order: repeated outbound/return movement with aligned panel and text; close fully; 95.7s real recording decoded successfully']
test['limitations'] += ['Latest UI pose blending has Node coverage; visual browser check blocked by repeated IAB failure on tab7. Earlier editor screenshot predates this blend change','Original e7b9 freeze correction and new 2cb3 blend are distinct validations; abrupt transition reduced, no claim of exact original-game crossfade curve']
(r/'latest-game-test.json').write_text(json.dumps(test,indent=2,ensure_ascii=False)+'\n');m.update(game_tested=True,game_test_report=str(r/'latest-game-test.json'));(r/'latest-build.json').write_text(json.dumps(m,indent=2)+'\n')
intro='''# Retratos y diálogo · comprobado22/10/2026

Prevalecen [informe actual](evidence/RETRATOS-ANIMADOS.md), latest-build.json y
latest-game-test.json. Mapa2cb340db: cuerpo/brazos/tótem originales, bordes interiores
ampliados y profundidad delante del fondo gris. SEQS cronológicas corrigen el
reposo; mezcla de poses200ms suaviza Talk→Stand.47tests Node PASS, JassHelper/pJASS
y contraste Classic1.27b SP1920×1080: pausa, reposo, interacción, patrulla y cierre.
Vídeo real95.7s en work/dialogue-tauren-hud-20261022/dialogo-patrulla.mp4, desde la raíz.
La mezcla nueva del editor tiene tests; su comprobación visual queda pendiente
por caída recurrente de IAB. Las secciones siguientes conservan contexto histórico.

'''
for name,sep in [('README.md','# Diálogos Classic'),('VERIFICACION.md','## Afinado vigente')]:
 p=r/name;t=p.read_text();p.write_text(intro+t[t.index(sep):])
p=r/'README.md';t=p.read_text().replace('`-cerrardialogo` cierra; Esc/derecha completa y después avanza.','`-cerrardialogo` cierra; `-pausadialogo` pausa/reanuda escritura;\n`-patrullardialogo` patrulla y `-parardialogo` detiene la unidad;\nEsc/derecha completa y después avanza.');p.write_text(t)
p=r/'evidence/RETRATOS-ANIMADOS.md';t=p.read_text();t=t.replace('45tests Node pasan','47tests Node pasan');t=t.replace('el mismo W3X e7b9e5353a91cd6986550d63177a565e9c9db4176e4c70e3373f7ecd891dd5f8,','el mismo W3X '+m['sha256']+',');t=t.replace('se conservan, pero no','se conservan, pero no');t += '''
## Mezcla y vídeo final

Después de recuperar el bucle, el usuario señaló el salto Talk→Stand. El dummy
uidm tiene uble=0; los retratos heredaban ese campo. Cambiar sólo MODL.BlendTime
no basta (control6df68d55). Se configura uble=0.20 en dpa0/dta0 y BlendTime200ms
en sus MDX; dlog sigue con0. Relectura de objetos en actor-blend-validation.json.
Control nativo blend200-real-probe.mp4 frente a blend-unit-probe.mp4: la nueva
transición reparte el cambio de pose durante varios fotogramas. Se suaviza el
salto; no se acredita una curva idéntica al HUD original para cualquier modelo.

UI Studio incorpora mezcla lineal de las traslaciones horneadas por200ms, desde
la pose mostrada incluso si se interrumpe.47tests, incluidos inicio/final,
interrupción y rebobinado. La nueva vista tab7 volvió a fallar al crearse: este
ajuste del editor todavía no tiene contraste visual; screenshot previo no lo
acredita. La implementación del visor no es una garantía de interpolación exacta
idéntica al motor.

Vídeo final: [dialogo-patrulla.mp4](../../../work/dialogue-tauren-hud-20261022/dialogo-patrulla.mp4).
95.7s, H2641920×1080/30fps, sin audio ni cortes de acciones; sólo remux faststart.
0:03apertura;0:06pausa parcial con Stand móvil;0:13reanudación;
0:23reposo automático;0:44y0:54avance/interlocutor;1:00–1:26patrulla;
1:31cierre. Las dos imágenes pausadas conservan el mismo texto visible mientras
los retratos cambian de pose. Mínima diferencia de redondeo impide igualdad
binaria de píxeles; medidas/tolerancia en pause-visual-validation.json.
Patrulla usa IssuePointOrder("patrol"), sin teletransporte. La cámara compartida
no cambia. Capturas patrol-start/out/return/closed, identidad/hash/monitor32HDMI,
timeline y decodificación íntegra conservados. PID819827 ausente después de
confirmación de salida observada; no se envió S porque ya había terminado.
''';p.write_text(t)
# Close reports with verified recovery while preserving their entire history.
main=root/'informes/errores/2026-10-22-182141-dialogo-marco-jerarquia-mdx.md';text=main.read_text();text='''Estado vigente: RESUELTO para los dos pilotos Classic1.27b SP1920×1080.
Reposo recuperado por SEQS cronológicas; transición suavizada con uble0.20.
La revisión visual de la mezcla del editor sigue en la incidencia de navegador.
Los estados siguientes son historia de investigación.

'''+text+'''
Recuperación final2cb340db comprobada: JassHelper/pJASS, reextracción y47tests;
validadores MDX/objetos y contraste nativo A/B. El control6df conserva uble0 y
salta; el candidato2cb mezcla durante varios fotogramas. Grabación real final
work/dialogue-tauren-hud-20261022/dialogo-patrulla.mp4: pausa parcial/Stand móvil,
reanudación, reposo automático, interacción, patrulla y cierre total. Identidad
819827/hash2cb/HDMI-A-1/32 registrada, proceso ausente. La falta de bucle no era
la causa (NonLooping0); tampoco nombresStand, proyección periódica o jerarquía
por sí solos. Cuerpo/armas íntegros; fondo gris ya no ocluye la pared del tótem.
Límites: dos pilotos, SP1920×1080; otras resoluciones, multijugador, compacto
nativo y mezcla visual nueva de UI pendientes en sus registros específicos.
''';dest=main.parent/'resueltos'/main.name;assert not dest.exists();main.write_text(text);main.rename(dest)
monitor=root/'informes/errores/2026-10-22-172800-dialogo-monitor-evidencia.md';text='''Estado vigente: RESUELTO para el capturador de esta prueba. Mantener las guardias;
no se afirma corregir globalmente Hyprland ni los cambios de foco ajenos.

'''+monitor.read_text()+'''
Recuperación final: native_probe.py exige identidad PID/inicio/prefijo/hash,
monitorHDMI-A-1, coordenadaX1920 y workspace32 visible; focus de monitor explícito
y on_current_monitor=false. ordered-* y vídeo final2cb340db muestran la partida
propia, apertura/pausa/patrulla/cierre. Cada captura registra metadatos. No se
usan tomas X3/escritorio como evidencia. Todas las partidas propias de estos
ensayos terminaron; ninguna sesión ajena fue cerrada por este flujo.
''';dest=monitor.parent/'resueltos'/monitor.name;assert not dest.exists();monitor.write_text(text);monitor.rename(dest)
p=root/'informes/errores/README.md';t=p.read_text().replace('[Vista del navegador recuperada](2026-10-22-190100-ui-studio-vista-navegador.md)','[Vista del navegador: caídas recurrentes, abierta](2026-10-22-190100-ui-studio-vista-navegador.md)');p.write_text(t)
p=root/'docs/planes/dialogo-retratos-animados-senal.md';p.write_text(p.read_text()+'''
## Cierre de la revisión de cuerpo/variantes y transición

2cb340db,22/10: exportación completa y variantes móviles implementadas. Orden
SEQS cronológico corrige reproducción nativa; uble0.20 sólo en actores suaviza
Talk→Stand.47tests Node, JassHelper/pJASS/reextracción y contraste nativo; vídeo
real95.7s de pausa parcial/Stand, interacción, patrulla y cierre. Proceso propio
terminado. La fase nativa de esta revisión queda comprobada para dos pilotos
SP1920×1080; no equivale a completar toda la matriz futura de formatos/LAN.
Pendiente específico: comprobar visualmente la mezcla nueva en UI Studio cuando
se recupere IAB (tab7 falló al crearse); los tests de interpolación sí pasan.
No sustituir esta limitación por el screenshot del editor anterior al blend.
Ver latest-game-test.json y evidence/RETRATOS-ANIMADOS.md para evidencia y límites.
''')
print(json.dumps({'map_sha256':m['sha256'],'video':str(video),'game_exited':exit['exited'],'reports_closed':[main.name,monitor.name]},ensure_ascii=False))
