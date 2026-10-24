# X3V3: movimiento visual de la galería

Fecha22/10/2026, agente raíz, ModelEditor, WC3 Classic1.27b/YDWE, mapa70659fd806685801e3240a13af973df4edb4fe19cb900a33da168516343931bd. Estado: investigación.

Síntoma: tras -move, etiquetas de origen cambian posición con SetTextTagPosUnit pero la geometría del proyectil parece permanecer casi inmóvil. Evidencia: evidence/x3-v3/move-verified,25 capturas en6,36s. Centro de píxeles claros de A en ROI(450..800,240..310) se mantiene x665..673, frente a etiqueta visible que se desplaza más. Comparación visual con stand-verified.

Impacto: carga/texturas y emisión estática sí observadas; la estela durante recorrido en motor aún no acreditada. Visor3D sí reproduce recorrido externo con partículas que permanecen. No modificar física del proyecto TerrainDev.

Hipótesis inicial: dummy con umvs0 no actualiza representación al cambiar coordenadas con SetUnitX; alternativa, transformación MDX/flag. Se probó una galería separada con velocidad de objeto positiva, conservando SetUnitX; no cambiar MDX entre controles.

Corrección comprobada: se cambió sólo umvs0→300 de las siete unidades de ensayo. SetUnitX y el JASS compilado permanecen byte a byte iguales entre controles, MDX idénticos. Reextracción17 miembros PASS. El centro claro de A ahora se desplaza entre x586..704 frente a665..673 en el control, y se ven motas detrás de los orbes. Evidencia movement-control.json y move-verified. Causa confirmada para esta galería: configuración de velocidad cero del dummy impedía acompañamiento visual del recorrido. No se extrapola a todos los usos de SetUnitX. Estado: recuperación visual comprobada; cierre propio en curso.

Cierre final: sesión propia terminada, cero procesos del prefijo y configuración YDWE compartida sin cambios. Birth/Death/recorrido capturados en monitor correcto, mapa cargado con hash verificado. Estado: resuelto.
