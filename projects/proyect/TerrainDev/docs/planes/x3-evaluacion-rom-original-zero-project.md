# Evaluación ROM X3 y Zero Project — 23 octubre 2026

Objetivo: recuperar la física verificable del disparo de X original y contrastarla con el parche distribuido y el código fuente de Zero Project, para decidir la adaptación posterior a Warcraft III Classic 1.27b. Evaluación autorizada; sin cambiar las bibliotecas ni el mapa productivo.

## Base e identidad

- ROM aportada por el usuario, ZIP en Descargas. SHA256 de la ROM sin cabecera: `65b03268afac296330e8ff8d60dd0825879e13ed658b37713c034a3bd074f1d7`, 2097152 bytes.
- Zero Project HEAD `b1ffc579861b028306bf5db636ed02489bb6eded`. Separar fuente, IPS V4.1 y documento V4.8; no equiparar versiones por nombre.
- Producción vigente: perfil GIF `0.2.0-local-gif`; consultar CodeGraph de TerrainDev/src. Missile, RapidFire y GroundMotion quedan fuera del cambio.

## Fases y aceptación

1. Identidad: hashes, cabecera, mapa de memoria y procedencia. Conservar ZIP original; extracción y parche únicamente en copias locales privadas.
2. Parche: analizar registros IPS, aplicar con límites comprobados y comparar rutinas/tablas pertinentes. Registrar expansión y diferencias respecto a fuente HEAD.
3. Matemática: desensamblar entradas concretas y seguir inicialización, integración, saturación y transición. Separar bytes comprobados, interpretación estática y ejecución nativa no observada. No tratar WIP de Zero como física original de X.
4. Comparación: documentar original / mod / aproximación GIF y propuesta para Classic 1.27b, con unidades y límites. No afirmar fidelidad en ejecución SNES sin traza.

## Estado

Evaluación completada dentro del alcance estático/aislado. Evidencia de esta evaluación en `/home/snz/Documentos/ChatGPT/Proyect/TerrainDev/reports/x3-rom-evaluation-20261023-134543`. ROM verificada y HEAD fijado; consulta CodeGraph ejecutada sobre X3Buster.j con avisos conocidos de cobertura parcial. IPS aplicado a copia;12bloques por variante desensamblados;20combinaciones/2400pasos coincidentes y gráfica revisada. Informe final: `../x3-evaluacion-rom-original-zero-project.md`. Pendiente para una adaptación posterior: traza SNES completa de precursores/animación, implementación y QA Warcraft. No se alteró producción.


## Continuación autorizada: ejecución SNES completa y organización

Usuario autorizó el ensayo y pidió un solo sitio sin residuos dispersos. Laboratorio único: `TerrainDev/labs/x3-snes/`. Análisis estático trasladado a analysis/static-20261023-134543, con enlace histórico sin copia. Registrar ROM, emulador, scripts y estado por variante. Primero arranque real; después preparar escena y capturar el disparo por entrada de control reproducible. Registrar creación/movimiento/fusión/retirada por actualización y por fotograma, distinguir cámara y mundo. No modificar física ROM; cualquier preparación de mejoras mediante RAM debe quedar explícita y cesar durante medición. Comparar original y mod sin usar save states cruzados. Cerrar cada proceso propio y vaciar temporales prescindibles del laboratorio. No alterar mapa Warcraft en esta fase.

Estado: MesenCE2.2.1 descargado y hash cotejado con release oficial; API/launcher comprobados en fuente20ba206…. Índice scripts nuevo con2fuentes y consulta MCP; registro en AGENTS raíz. Arranque y trazas todavía pendientes.


## Cierre de ejecución emulada — 23 octubre 2026

Laboratorio consolidado y reproducible en labs/x3-snes/README.md. ROM original y mod arrancados por separado, estados propios, seis casos definitivos de640frames. Capturas del juego y CSV de objetos contrastados con ecuaciones:1220actualizaciones/4880valores/0discrepancias, seis fusiones con cinco cuerpos cada una. Cadencia~60.098806Hz; formación18frames original,8mod; recolocación de la unión observada y separada de la aceleración lateral. Inputs, equipo, hashes y fuente Lua por caso conservados. Vídeo comparativo y recibos de cierre/limpieza acreditados.5fuentes del laboratorio consultadas por MCP.

Se recuperaron los fallos de bootstrap (nombre de cierre Lua, mando portátil, PC interior de instrucción para guardar). Se cerraron todos los procesos propios; tmp vacío;56.1MB de material prescindible retirado. ZIP del usuario, ROM y mapa conservados. La evaluación y ejecución solicitadas están completas dentro del alcance descrito. Próximo trabajo distinto: port a X3Buster y QA Warcraft; no ejecutado todavía. Hardware SNES, impactos/daño y otros niveles no acreditados.
