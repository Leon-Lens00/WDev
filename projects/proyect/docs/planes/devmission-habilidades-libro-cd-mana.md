# Dev Mission: CD, maná y orden de las habilidades del libro

Anotado el 20/11/2026 a petición de Leon ("solo unas cosas para no olvidar"), tras aceptar v20o y la LAN v20p.
Implementado en **v20q** (20/11/2026) con valores elegidos por el agente ("te dejo a recomendacion"). Ver abajo.

## Lo pedido

1. **CD** a las habilidades del libro.
2. **Maná** por habilidad: desde dos cifras para las suaves y más para las fuertes.
3. **Maná de los personajes** nuevo para poder usarlas, con **regeneración lenta** (valor a recomendar). Junto con el
   CD, las habilidades no deben quitar protagonismo a las armas.
4. **Posición** de las habilidades en el libro según su tecla (la Q primero, etc.); revisar todos los personajes.
5. Todos los personajes **empiezan con su habilidad Q** como base.

## Estado actual comprobado (w3a de v20l, igual en v20o; j de v20o)

Los botones del libro son puentes `ANcl` (CD 0, maná 1, salvo Bombardeo 10 s y Estampida 12 s); la habilidad real la
lanza una copia dummy (memoria `habilidades-por-copia`). Posición = (columna, fila) en la cuadrícula del libro.

| Libro | Bien colocado | Desordenado (tecla → posición) |
|---|---|---|
| ALTb Tauren | Q W E R arriba, A S abajo | — |
| ALCb Cairne | Q W E R arriba, A S abajo | — |
| ALGk Goku | — | R→(0,0), T→(1,0), W→(2,0), **Q→(3,0)**, X→(0,1); falta E |
| ALFz Freezer | — | R→(0,0), X→(1,0), E→(2,0), W→(3,0), **Q→(0,1)**, T→(1,1) |
| ALTr Trunks | — | R→(0,0), T→(1,0), E→(2,0), W→(3,0), **Q→(0,1)**, X→(1,1) |
| ALNa Naruto | — | R→(0,0), D→(1,0), T→(2,0), **Q→(3,0)**, E→(0,1), X→(1,1) |

- Teclas fuera de QWER en los de D.O.N: X, T, D. Al reordenar, decidir si pasan a QWER/ASDF por orden de fuerza.
- Maná de los tipos de héroe (w3u): `umpm` 5, `umpi` 100, `umpr` 0,5, `uint` 1. El maná que se ve es el del
  controlador (`Game_Ctrl`, memoria `controlador-misma-unidad`); al reaparecer se llena (j de v20o, línea ~37226).
  Revisar ahí de dónde sale el máximo antes de fijar los valores nuevos.
- Las técnicas de D.O.N se dan hoy por carta (v19k, `Tec_Rango`): empezar con la Q cambia esa entrega.

## Por decidir al implementar

- Tabla de CD y maná por habilidad (suave/fuerte), maná máximo y regeneración: propuesta del agente para que Leon la
  elija.
- Probar con la variante -prueba (registros de lanzamientos) y LAN si se toca lo local.

## v20q (20/11/2026): implementado

Base v20o / v20o-prueba. Fuentes: `scripts/objetos_v20q.py` (w3a, w3u), `scripts/v20q.py` (j), `scripts/hacer-v20q.sh`.

- **Maná de los personajes** (h005, h006, hGok, hFrz, hTrk, hNar, hNaK): base 135 + inteligencia 1 × 15 = **150**;
  regeneración base 0,95 + 0,05 = **1/s** (de vacío a lleno en 2,5 min). Maná inicial 150. Antes: 20 y 0,55/s.
- **Puentes del libro**: recarga y maná propios; la descripción dice "Recarga N s, M de maná." (en Tauren/Cairne se
  añadió o sustituyó la nota "Recarga N s.").
- **Orden**: fila de arriba Q W E R en columnas 0-3; fila de abajo A S T X D desde la columna 0. Goku deja hueco en E.
- **Empiezan con Q**: Naruto (RasenShuriken, antes Rasenrengan), Tauren (Embestida espiritual, antes Lanzar roca) y
  Cairne (su Q, antes la W). Goku, Freezer y Trunks ya empezaban con la Q.

| Personaje | Q | W | E | R | Fila de abajo |
|---|---|---|---|---|---|
| Goku | Kamehameha 25 / 6 s | Warp 40 / 10 | — | Dragon Fist 80 / 25 | T Spirit Bomb 100 / 45; X Power Up 50 / 30 |
| Freezer | You Will Die 25 / 6 | Imprisonment 40 / 10 | Death Break 45 / 12 | Death Ball 80 / 25 | T Power Up 50 / 30; X Destructo 30 / 8 |
| Trunks | Burning Attack 25 / 6 | Finish Buster 40 / 10 | Heat Dome 45 / 12 | Burning Slash 80 / 25 | T Finish Sign 60 / 18; X Power Up 50 / 30 |
| Naruto | RasenShuriken 25 / 6 | — | Rasenrengan 40 / 10 | Kyuubi 90 / 45 | T Senpuu 60 / 18; X Kage Bunshin 50 / 20; D Chakra Blast 60 / 15 |
| Tauren | Embestida 25 / 6 | Tótem 35 / 9 | Roca 40 / 10 | Bombardeo 80 / 25 | A Garra 40 / 12; S 45 / 15 |
| Cairne | 25 / 6 | 35 / 9 | 40 / 10 | Estampida 80 / 25 | A 45 / 14; S 40 / 12 |

Las armas, el disparo y el dash siguen sin maná ni recarga.

| Mapa | SHA-256 |
|---|---|
| TerrainDev-Titulo-v20q.w3x | `2c597bd54ec8c0d683f52823b766a5aa9ff3dc5f2e24e287ab61ba97793e0d5c` |
| TerrainDev-Titulo-v20q-prueba.w3x | `1ead09d5a2548ce4dc8165f904b1a7941c42fb2cf223d587bcf740ab2e8e0525` |

Comprobado: pJASS correcto en las dos; j, w3a y w3u reextraídos iguales; bytes-diff sólo (attributes), (listfile),
j, w3a y w3u; `mpq verify` correcto; copias en WOE comparadas con cmp. **Validated**; sin jugar.

Pendiente de prueba: que el libro muestre el orden nuevo, que la recarga y el maná se gasten del controlador, que el
maná visible sea 150 y suba 1/s, y que la copia dummy siga lanzando con su maná lleno. `Don_Botones` da a hNaK el
libro 'ALTa' (rareza vista, sin tocar).
