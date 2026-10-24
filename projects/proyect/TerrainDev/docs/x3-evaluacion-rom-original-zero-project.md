> Continuación completada: [ejecución SNES y laboratorio único](../labs/x3-snes/README.md). Seis casos completos,4880valores comparados/0diferencias; transición original18frames y mod8frames. Las limitaciones de ejecución pendientes de este informe corresponden a su fase estática.

# X3: evaluación de ROM original y Zero Project

Fecha: 23 de octubre de 2026. Alcance: investigación de física para TerrainDev / Warcraft III Classic 1.27b. No se modificaron bibliotecas, modelos ni mapa productivo. No se inició ninguna partida nueva.

## Resultado y decisión recomendada

Sí se pueden adaptar ambos estilos dentro de X3Buster. La ROM permite sustituir las estimaciones de movimiento por parámetros y secuencias demostrables de sus rutinas. Conviene conservar dos perfiles distintos: **original USA** y **Zero Project IPS V4.1**. No mezclar los valores del mod con el retroceso del original bajo una etiqueta de fidelidad única.

Original: núcleo con arranque lento y aceleración; las cuatro piezas laterales retroceden y luego avanzan, manteniendo separación lateral lineal. Mod: núcleo sale rápido, la primera pareja avanza desde el principio y la segunda conserva un retroceso mucho menor; ambas parejas describen curvas que cruzan el eje. El pulso que alcanza al precursor tiene una fase de vuelo de velocidad constante en la rutina examinada, mientras nuestra aproximación GIF le aplica aceleración.

La implementación vigente sigue siendo `0.2.0-local-gif`. Esta evaluación no acredita todavía fidelidad visual completa, colisiones SNES ni temporización total del lanzamiento/fusión.

## Identidad de las entradas y parche

- ZIP del usuario: `/home/snz/Descargas/Mega Man X3 (USA).zip`, conservado sin cambios. SHA256 `9e73e07ea907b3984798353db2f809ddb708190035977f18b93707de3096f562`.
- Miembro: `Mega Man X3 (USA).sfc`, 2097152 bytes, sin cabecera de copiador. Título `MEGAMAN X3`, mapa `$20` LoROM, chip `$F3` CX4.
- ROM SHA256 `65b03268afac296330e8ff8d60dd0825879e13ed658b37713c034a3bd074f1d7`; SHA1 `b226f7ec59283b05c1e276e2f433893f45027cac`; CRC32 `FA0FE671`. Suma calculada y almacenada `$4055`, complemento `$BFAA`.
- [Repositorio Zero Project](https://github.com/justin3009/MMX3-ZeroProject), HEAD comprobado `b1ffc579861b028306bf5db636ed02489bb6eded`, igual al de la investigación anterior.
- El repositorio contiene **fuentes y parche**, no se usó una ROM modificada completa descargada de allí. El archivo distribuido se llama `Mega Man X3 (V4.1 - Unheadered).ips`; su SHA256 es `1df358f8df8e1f9b5dc7c44cb6e582d899a9491a190691d2a54192889319ad6a`.
- Se analizaron y aplicaron sus 6233 registros IPS con límites/EOF/RLE comprobados, sobre una copia. Resultado: 4194304 bytes; SHA256 `bfb912b3438c965950a548efe355cdf4da278e980bccb53131a9eae517a1cf76`.
- Las copias ROM están en `private/` de la evidencia, con permisos locales restringidos; no se incorporaron al mapa ni a un paquete para compartir.
- `V4.8 Final Readme.txt` no cambia el nombre ni demuestra la versión del IPS. **Sólo los cambios físicos concretos contrastados** de la fuente HEAD coinciden con el IPS; no se compiló el repositorio entero para afirmar equivalencia global fuente/IPS/V4.8.

## Qué se comprobó y con qué herramientas

1. Lectura de tabla y desensamblado acotado de la ROM original y de la copia parcheada. Mapeo LoROM: `offset=((bank & $7F)*$8000)+(address & $7FFF)` para las regiones examinadas. Los cambios de llamadas `$01/$02/$04` a `$81/$82/$84` en esos bloques conservan los bytes de destino por espejo LoROM; no son aceleraciones nuevas.
2. Intérprete de investigación limitado a los bloques de inicialización y movimiento: ejecuta sus instrucciones reales, con anchos M/X, carry, signo, flags, registro B y memoria de posición fraccionaria. No ejecuta un emulador completo de SNES, CX4, render, colisiones ni planificación de objetos.
3. Comparación campo a campo con una recurrencia deducida por separado de esas rutinas: cinco cuerpos, dos sentidos, dos variantes, 120 pasos cada combinación, **2400 pasos coincidentes** en velocidad X/Y y posición X/Y. También coinciden los campos iniciales de velocidad y aceleración.
4. Curvas trazadas a partir de los resultados aislados; no son capturas del juego. Se revisó visualmente la figura generada.
5. CodeGraph MCP ejecutado en `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/src` sobre `X3Buster.j`, `travel`, `ramp`, `lateral` y `tryFusion`. Fuente vigente leída; permanecen avisos conocidos de macros/condicionales y unidad incompleta. El grafo no acredita ejecución SNES/Warcraft; los laboratorios históricos están fuera de ese índice.

El desensamblador auxiliar procede de [snesrecomp, snes65816.py](https://github.com/RetroPortingToolKit/snesrecomp/blob/68896b6fa93b47c9fa1ca68f0c9c2ef889969839/recompiler/snes65816.py), revisión fijada. Sólo se utiliza el decodificador básico; no su validador heurístico orientado a otros juegos ni una compilación completa. La metadata pública de X3 se descargó como referencia, pero no se empleó para inventar límites o estados que no cubría. Nada de este código se importó a Warcraft ni se instaló globalmente.

## Direcciones y contrato recuperado

| Región | Evidencia relevante |
|---|---|
| `$86:BBA0` | Cinco filas de 8 bytes: ay firmado8, ax firmado8, vx firmado16 LE, vy firmado16 LE, paleta, byte adicional. Los primeros seis se consumen en `$81:C5A6–C5D9`. No se atribuye función nueva al último byte. |
| `$81:C5AF` | Original llama `$01:8CA4`; IPS tiene cuatro NOP. Retira la inversión por facing de **ay**; la inversión de ax/vx sigue activa. |
| `$01:8CA4` | PHP, REP20, BIT `$10`, complemento a dos condicionado por V, PLP, RTL. En ancho16 el bit de facing probado es el de `$11`, no el byte bajo `$10`. |
| `$81:C610–C62D` | Límite horizontal antes de llamar a integración; umbral `$0800` = 8px/paso. |
| `$02:D7C2–D7F2` | Extiende ay/ax de8 a16 con signo; resta esos valores de vy/vx y salta a posición. |
| `$02:D78F–D7C1` | X24 suma vx16 con signo; Y24 resta vy16 con signo; 8 bits de fracción. |
| `$81:C0E8`, `$81:C124`, `$81:C1C5` | Precursor helicoidal, velocidad inicial y aceleración por etapas. |
| `$86:BB37`, `$81:C3BE` | Secuencia discreta de desplazamientos relativos con duración/flags, no una senoide continua inferida del GIF. |
| `$81:8FA2`, `$81:9040–9067` | Objeto03: fase de vuelo con vx `$0800` y avance horizontal `$02:D7F3`. No se encontró aceleración en esa fase. |
| `$81:C42F–C49C` | Busca objeto03 activo con estado/subestado concretos y llama a comprobación de solapamiento `$04:CC5C`. No es sólo un temporizador fijo. |
| `$81:C49D–C4CF`, `$86:BB32` | Emite cinco objetos de combinación: 1F,20,20,20,20. Temporización de la animación intermedia no recuperada completa. |

## Ecuaciones del disparo combinado

Unidades nativas: píxeles por paso de actualización; velocidad fija8.8 y acumulador de posición24 bits. Se normaliza el disparo hacia la derecha, y la coordenada Y positiva hacia abajo. `n=0` significa inmediatamente después de inicializar el objeto, antes de su primer movimiento. No equivale al instante de pulsar el botón.

Tras transformar los valores de tabla según facing:

```
vx[n+1] = min(vx[n], 8) + aX
vy_up[n+1] = vy_up[n] - ay
x[n+1] = x[n] + vx[n+1]
y[n+1] = y[n] - vy_up[n+1]
```

Para disparar a la izquierda, se refleja X y su límite. En la comprobación se ejecutaron ambas orientaciones. No hay saturación vertical en este bloque. Las operaciones reales son enteras/fijas; las divisiones siguientes son una representación exacta de esos valores.

| Cuerpo | Original vx inicial | Original aX | Original vy hacia arriba | Mod vx inicial | Mod aX | Mod vy inicial arriba | Mod ay |
|---|---:|---:|---:|---:|---:|---:|---:|
| Núcleo | 0 | 24/256 | 0 | 10 | 0 | 0 | 0 |
| Pareja1 superior | -8 | 127/256 | +1.5 | +1 | 48/256 | +5 | +96/256 |
| Pareja1 inferior | -8 | 127/256 | -1.5 | +1 | 48/256 | -5 | -96/256 |
| Pareja2 superior | -6 | 96/256 | +0.75 | -3 | 96/256 | +7 | +112/256 |
| Pareja2 inferior | -6 | 96/256 | -0.75 | -3 | 96/256 | -7 | -112/256 |

En el original ay=0 en los cinco cuerpos. Por eso cambiar sólo el coeficiente horizontal no reproduce el cruce del mod: hacen falta sus aceleraciones laterales y la llamada anulada.

**Orden del límite:** se limita vx a8 antes de sumar aX. El desplazamiento estable de este bloque resulta 8+aX, no exactamente8. El núcleo del mod guarda10 inicialmente, pero se limita a8 antes del primer desplazamiento; no recorre un primer paso de10. No debe trasladarse al port como «10 y acelera».

Resultados aislados desde nacimiento, sin vida de pantalla/impactos:

| Perfil/cuerpo | Retroceso máximo | Paso del mínimo | Primer paso con vx≥0 |
|---|---:|---:|---:|
| Original pareja1 | 60.53125px | 16 | 17 |
| Original pareja2 | 45px | 15 | 16 |
| Mod pareja1 | 0 | 0 | 1 |
| Mod pareja2 | 10.5px | 7 | 8 |

En el original las velocidades laterales constantes abren las piezas. En el mod las velocidades laterales cambian de signo: desde origen común, pareja1 cruza Y=0 entre los pasos25/26 y pareja2 en31. Son trayectorias aisladas; no se afirma que todos los cuerpos sobrevivan hasta esos pasos en una escena concreta.

## Precursores, alcance y cosas aún no equivalentes al juego completo

El port GIF usa orbes a260u/s constantes, pulso650→1500u/s, delay0.375s, órbita senoidal2.5Hz, formación0.09375s y núcleo/satélites continuos por aceleración. Esos valores eran estimaciones visuales, no parámetros de la ROM.

La inicialización del portador helicoidal original guarda |vx|=0.5px/paso, contador16 y ax=8/256. En el vuelo se reduce el contador y al llegar a0 pasa ax a64/256. La rutina **integra posición y después limita la velocidad almacenada a5**. Por ello el tramo estable puede desplazar5.25px/paso: copiar el5 como velocidad de posición perdería ese orden. Se acreditó mediante lectura de las instrucciones; esta rama completa no forma parte de los2400pasos del intérprete combinado.

Los componentes relativos consumen una tabla con incrementos verticales y fases. No se ha recuperado toda su relación con los sprites y máscaras de colisión para afirmar cuántos elementos visuales equivalen exactamente a cada slot. La creación contiene tres slots hijos; esto no demuestra tres bolitas visibles idénticas. La pareja visual se debe verificar en ejecución.

El segundo pulso tiene una fase recta de8px/paso. Hay una fase anterior de animación y posicionamiento que no se convirtió en un retardo exacto. La unión se condiciona a encuentro/estado de objetos, y después se emiten los cinco cuerpos en una transición ligada a animación. Quedan pendientes el número exacto de ticks del destello/formación, la traza de scheduler y el momento de cada spawn.

La rutina `Zero_SpiralBusterWIP` no es la referencia de X: el wrapper activo mostrado llama a `$81:C0E8` y conserva comentada la llamada WIP. No se trasladaron sus números a esta evaluación como si fueran originales.

## Adaptación recomendada para Warcraft 1.27b

1. Guardar perfiles ORIGINAL_USA y ZERO_PROJECT_41 separados, manteniendo el perfil GIF como referencia histórica. Primero reproducir el original para fijar base; después añadir el mod con sus tablas propias.
2. Conservar los parámetros nativos por pasos y evaluar su posición por edad; interpolar entre pasos para el render. Una parábola continua con saturación posterior no equivale exactamente a la secuencia discreta original. Separar el reloj de física de las lecturas repetidas de TimerGetElapsed ya corregidas.
3. Calibrar escala espacial S y cadencia lógica F con una ejecución SNES observada. Para unidades físicas continuas, `v_wc3=S*F*v_px_paso`, `a_wc3=S*F²*a_px_paso²`; no usar los30ms de un fotograma GIF como duración nativa demostrada. La escala2u/px del ajuste GIF tampoco obliga a escalar radios/daño.
4. Resolver en X3Buster: usar el eje longitudinal y su perpendicular para las curvas laterales, y definir aparte qué parte de la hélice es altura visual. Mantener el contrato de colisión del mapa sobre XY, barridos durante retroceso/cruce, limpieza y presupuesto. La colisión side-scroller de SNES no es la colisión del mapa Warcraft.
5. Mantener Missile, GroundMotion, RapidFire y los recursos actuales. El núcleo común recibe distancia por tick, no unidades/segundo. Una tabla/función de trayectoria local permite conservar32Hz y usar subdivisiones/interpolación sin cambiar el timer compartido. Esto es diseño viable, todavía no una implementación comprobada.
6. Antes de promover: comprobar por separado traza original/mod en emulador con input reproducible; trasladar coeficientes y fases; compilar JassHelper/pJASS; repetir regresión de fusión, colisión en retroceso/cruce, vida/cancelación y los153controles pertinentes ampliados. La QA vigente sólo cubre el perfil GIF actual.

## Evidencia y reproducibilidad

Directorio: `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-rom-evaluation-20261023-134543`.

- `identity.json`, `ips-analysis.json`, `source-vs-ips.json`: identidad, registros/diferencias y coincidencia concreta de fuente/IPS.
- `focused-disassembly-original.txt`, `focused-disassembly-zero-project-v4.1.txt`:12 regiones explícitas por variante; no confundir tablas de punteros con código. Borradores lineales en exploratory no son evidencia final.
- `evaluate_motion.py`: intérprete acotado y recurrencia independiente. Ejecutar `python3 evaluate_motion.py` desde cualquier directorio con las copias privadas presentes. `isolated-checks.json` y `motion-isolated.csv`:20combinaciones/2400pasos.
- `motion-metrics.json`, `table-decoded.json`, `helix-relative-table.json`: coeficientes y mediciones de la investigación.
- `comparacion-fisica-rom.png` / `.svg`, `plot_motion.py`: curva estática; el script necesita el Python del entorno gráfico local documentado en result.json.
- `codegraph-src.json`: respuesta MCP guardada, límites incluidos.
- `production-observed-hashes.json`: mapa y fuentes observadas, sin cambios en esta evaluación. Mapa `ad594a94d93592d0bdb0a90d38cad420deed8b92ac67179891519b3c16bdc7f1`.

Incidentes auxiliares recuperados: [instrucción ORA ausente](../../informes/errores/resueltos/2026-10-23-135029-x3-interprete-investigacion.md) y [guardado de respuesta MCP](../../informes/errores/resueltos/2026-10-23-135147-x3-guardar-evidencia-codegraph.md). Ninguno demuestra un fallo de la ROM, CodeGraph o el mapa; los resultados se produjeron después de recuperar las herramientas.

Fuentes primarias: [parches físicos del mod](https://github.com/justin3009/MMX3-ZeroProject/blob/b1ffc579861b028306bf5db636ed02489bb6eded/MMX3_OriginalLocations.asm#L1675-L1705), [tabla de objetos](https://github.com/justin3009/MMX3-ZeroProject/blob/b1ffc579861b028306bf5db636ed02489bb6eded/MMX3_Tables.asm#L3407-L3440), [wrapper y WIP](https://github.com/justin3009/MMX3-ZeroProject/blob/b1ffc579861b028306bf5db636ed02489bb6eded/MMX3_NewCode_Locations.asm#L10632-L10653), [instrucciones y alcance del mod](https://github.com/justin3009/MMX3-ZeroProject/blob/b1ffc579861b028306bf5db636ed02489bb6eded/README.md).
