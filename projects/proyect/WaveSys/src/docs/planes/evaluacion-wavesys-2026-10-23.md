# Evaluación de WaveSys — 23 de octubre de 2026

Solicitud: revisión exhaustiva de `/home/snz/Documentos/WarDatsPy/struct/`, con énfasis en oleadas, captura de puntos, acciones e integración del modo supervivencia. Sólo diagnóstico: no corregir fuentes.

## Base y restricciones

- Fuentes actuales en disco; carpeta sin repositorio Git. Se conservarán inventario y hashes de la revisión.
- Objetivo inicial: JASS/vJASS de Warcraft III Classic 1.27b, contrastado con las APIs locales al compilar.
- Builder propio: `build/build-jass.ps1`, descubre `.j` salvo build, Pruebas, MissileExamples y logs. `AllCode.generated.j` es derivado histórico, no fuente autoritativa.
- CodeGraph consultado por MCP: raíz no indexada, respuesta indica usar lectura directa. No inicializar fuera del alcance previamente autorizado.
- No modificar las fuentes ni mezclar `struct-rebuild`. Salidas de análisis en `/home/snz/Documentos/ChatGPT/Proyect/work/wavesys-auditoria-20261023/` e informe final en ese proyecto.

## Fases

1. Identificar construcción, fuentes y dependencias reales; conservar hashes. En curso.
2. Seguir estados: configuración → inicio → spawn → muerte → objetivo → descanso → siguiente oleada → victoria/derrota; revisar pausa, reinicio y reentrada.
3. Examinar IA, habilidades, contadores, crédito de daño, vidas, interfaz y recursos compartidos. Confirmar consumidores de cada posible defecto.
4. Usar comprobaciones existentes y compilador Classic sobre salidas nuevas cuando sea viable. No afirmar ejecución en juego ni multijugador sin ensayo real.
5. Entregar informe con severidad, evidencia de fuente, condiciones de activación, impacto, alternativas y matriz de cobertura; registrar fallos confirmados en informes/errores.

## Criterio de finalización

Hallazgos contrastados contra rutas y condiciones reales, límites de validación explícitos y recomendaciones separadas de defectos. Fuentes originales con los mismos hashes al terminar.
