---
name: writing-plans
description: "Planificar cambios técnicos de varias fases con dependencias, interfaces o integración, y guardar lo necesario para continuarlos entre sesiones. Usar cuando se solicita un plan o el trabajo necesita coordinación; incluye planificación de mapas y herramientas Warcraft III Classic 1.27b."
license: MIT
metadata:
  upstream: "obra/superpowers:writing-plans"
  upstream-version: "7.0.0"
  local-adaptation: "Codex y entorno local, 2026-10-20"
---

# Planificar trabajos técnicos

Adaptación de Superpowers; [procedencia](references/provenance.json). Producir un plan que otra sesión pueda ejecutar con el proyecto y sus fuentes, conservando el objetivo y las decisiones del usuario. Una edición clara y pequeña puede resolverse directamente, sin un documento de planificación.

## Inspeccionar antes de decidir

Identificar proyecto, versión/runtime, proceso de construcción y restricciones reales. Leer las instrucciones aplicables, planes existentes y los archivos que definen las interfaces a cambiar. Separar requisitos del usuario, hechos observados, decisiones rutinarias del agente y dudas que bloquean una fase. No diseñar una API a partir de nombres supuestos o del README de otra versión.

Consultar al usuario sólo por decisiones ausentes que cambien materialmente alcance o comportamiento; avanzar las partes independientes. Si una premisa técnica contradice la idea, mostrar la evidencia y una alternativa que preserve el objetivo. No convertir la duda en un hecho ni ocultarla dentro de una tarea de implementación.

Para Warcraft, consultar [warcraft-y-continuidad.md](references/warcraft-y-continuidad.md). Para otro proyecto, usar su stack y comprobaciones existentes.

## Plan útil y proporcional

Usar la ubicación/formato de planes del proyecto. Si no hay uno, guardar un archivo con nombre descriptivo en `docs/planes/` dentro del proyecto objetivo; no en una carpeta global o scratch descartable. La [plantilla](assets/plan-template.md) es un punto de partida: completar lo pertinente y quitar secciones vacías.

El plan debe permitir reconocer:

- Objetivo, alcance, restricciones y criterio observable de aceptación.
- Fuentes de requisitos y del estado actual: rutas, versiones y revisión/hash cuando identifican la base.
- Decisiones tomadas y preguntas que condicionan tareas; distinguir una preferencia del usuario de una elección del agente.
- Fases con entregable verificable, archivos/objetos afectados y dependencias en orden de ejecución. Definir interfaces exactas cuando una fase consume lo que produce otra, sin copiar todo el programa en el plan.
- Comprobaciones previstas, sus entradas/cobertura, condición de éxito y evidencia que deberán producir. Distinguirlas de resultados ya ejecutados; no escribir PASS anticipados.
- Estado actual, evidencia existente y próximo paso suficiente para retomar el trabajo.

Agrupar pasos pequeños que pertenecen al mismo entregable. Separar fases donde cambie el contrato o una comprobación pueda rechazar un resultado independiente. Enumerar consumidores de componentes compartidos según la evidencia, incluyendo usos indirectos que una búsqueda simple pueda omitir.

Elegir tests por el comportamiento y el riesgo: usar TDD cuando el runner/caso lo permita; usar escenarios reales para el motor o la interfaz. No imponer un test por función, un framework nuevo, una revisión por tarea, commits por rutina o una cadena de otras skills. Si hace falta aislamiento, usar los mecanismos del proyecto/Codex según la autorización vigente.

## Revisar y continuar

Antes de entregar o ejecutar, comprobar cobertura del objetivo, consistencia de interfaces, viabilidad de comandos/herramientas, consumidores afectados y decisiones pendientes. Resolver contradicciones demostradas y dejar explícitas las comprobaciones que aún no tienen un método viable.

Si el usuario pidió sólo planificación, entregar el plan sin implementar, instalar o ejecutar sus fases. Si la implementación ya está autorizada, el plan no introduce una aprobación adicional: continuar lo autorizado. Un cambio material de alcance o una decisión del usuario ausente puede bloquear la fase dependiente, no todo el trabajo independiente.

Al reanudar, leer el plan y comprobar que su identidad/base y las evidencias siguen vigentes frente a los archivos actuales, incluidos cambios sin commit y archivos nuevos. Actualizar estado, decisiones relevantes, resultados y siguiente paso al terminar una fase o cambiar una decisión; evitar registrar cada acción rutinaria.

Conservar plan, decisiones y enlaces a evidencias al terminar. Corregir una conclusión anterior de forma explícita. Un entregable puede estar implementado y tener verificaciones pendientes: describir ambas cosas; no marcarlo aceptado sólo porque se terminó de escribir.
