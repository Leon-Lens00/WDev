# Vinz: recursos ausentes durante estudio completo

23/10/2026, agente raíz, ModelEditor, estudioV4 de191MDX originales. Estado: abierto, límite de cobertura visual.

Al resolver texturas con la cadena MPQ Classic1.27b se encuentran21 rutas HD y3 rutas clásicas ausentes (Ball1, HeroTinker, TinkerRocketRibbon). Datos: evidence/x3-v4/study/resources.json. Los índices de colores12–27 también faltan por pertenecer a parches posteriores, pero no son necesarios para mostrar el equipo0 de las muestras. Algunos packs incluyen texturas de la variante Classic del mismo nombre; se registrará explícitamente su uso como recurso hermano, sin modificar originales.

Impacto: esos modelos sí se han leído y medido, pero no se puede afirmar vista original completa cuando usa una textura ausente. El visor marca parcial y usa recurso transparente sólo en el componente no disponible. Resto del trabajo de X3 puede continuar con familias completas. No afecta al packX3, que lleva máscaras propias. No se modifica ni instala otro juego por este estudio.

Acción: completar atlas y cobertura por modelo; buscar también archivos locales ya incluidos equivalentes por ruta/nombre sin inventar textura. La dependencia moderna ausente se conserva pendiente si no puede recuperarse de una fuente real.

Cobertura final: 178/191 modelos con dependencias utilizadas resueltas, 13 parciales señalados individualmente en atlas-resources.json y ESTUDIO.md. HeroTinker no es utilizado en los modelos mostrados; los índices12..27 de precarga no se cuentan como modelos incompletos. Los recursos hermanos de igual nombre se registran como alias, sin equipararlos a la textura HD original. No se recuperaron las dependencias explícitas restantes; incidencia abierta.
