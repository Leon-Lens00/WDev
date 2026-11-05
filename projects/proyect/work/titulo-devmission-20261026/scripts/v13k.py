#!/usr/bin/env python3
"""v13k: v13h sin registros que corran en partida.

Quita la escritura de archivo al pulsar la flecha arriba y los mensajes de WaveDebugLog,
que armaban su texto en cada muerte aunque el registro estuviera apagado.

Uso: v13k.py IN_J OUT_J
"""
from pathlib import Path
import re
import sys

S = Path(__file__).resolve().parent
sys.path.insert(0, str(S))
import puente_v12 as base


def aplicar(j_in, j_out):
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    s = base.once(s, '''    if GetTriggerEventId() == EVENT_PLAYER_ARROW_UP_DOWN then
        call ConversationUI___Dump()
        return
''', '''    if GetTriggerEventId() == EVENT_PLAYER_ARROW_UP_DOWN then
        return
''')
    s, n = re.subn(r'^[ \t]*call WaveDebugLog\(.*\)\r\n', '', s, flags=re.M)
    assert n == 12, n
    Path(j_out).write_text(s, encoding='latin-1', newline='')


if __name__ == '__main__':
    aplicar(sys.argv[1], sys.argv[2])
