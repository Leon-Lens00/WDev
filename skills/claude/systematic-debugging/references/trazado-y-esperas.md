# Trazado de causas y esperas observables

Adaptado de las referencias de depuración de Superpowers indicadas en `provenance.json`.

## Trazar hacia el productor

Cuando el síntoma aparece lejos de la entrada, empezar por el valor incorrecto en el consumidor y seguir sus asignaciones, parámetros y contexto hacia atrás. En cada frontera registrar qué entra, qué sale y qué transformación se esperaba. Distinguir nombres parecidos de la identidad real de una función, archivo o instancia.

Ejemplo: una compilación termina bien, pero el mapa ejecuta el comportamiento anterior. Primero comprobar el mapa lanzado y el hash del script embebido; después la salida del empaquetado, el archivo compilado y su fuente. Eso permite separar un error de selección/empaquetado de un defecto del algoritmo. Un log de compilación de otro archivo no decide entre ellos.

Añadir validación donde exista un contrato que lo justifique: argumentos del productor, transformaciones intermedias o frontera de integración. No introducir varias defensas genéricas sin demostrar qué ruta incorrecta previenen. Los checks auxiliares ayudan al diagnóstico; no cambian por sí solos el resultado funcional.

## Esperar una condición

Para procesos, archivos, editores y pruebas asíncronas, identificar la condición de éxito y de fallo y un límite de tiempo. Observar el proceso/ventana/archivo de esta ejecución, con identidad o fecha/hash cuando proceda. Una señal antigua no completa la prueba actual.

Sondear con un intervalo razonable y mantener comunicación si tarda. Un timeout significa incompleto o fallido según el contrato; no sustituirlo por éxito al agotarse la espera. Conservar la evidencia antes de cerrar recursos propios.

Una espera del anfitrión no sustituye el paso temporal del sistema observado. Al probar duración, velocidad o timers de un juego, medir el comportamiento relevante; no cambiar `Missile_TIMER_TIMEOUT` o el scheduler para quitar una espera del test. Si se necesita una pausa fija para medir un intervalo, justificar esa pausa y comprobar el resultado posterior.
