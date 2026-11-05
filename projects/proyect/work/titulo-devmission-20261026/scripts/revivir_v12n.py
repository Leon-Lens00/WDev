"""Dev Mission v12n (31/10/2026): the character falls and returns, and the controller waits for it.

'Arei' is Reincarnation with no cooldown on the character instance. While the character is down the pair stays alive, stops the burst
and pauses the controller, which then obeys nothing until the character is back. Only a character whose unit is gone ends the pair.

Usage: revivir_v12n.py IN_J OUT_J IN_W3A OUT_W3A
"""
from pathlib import Path
import struct
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))

import puente_v12 as base
from objetos_v12k import parse_w3a, encode_w3a

NONE = b'\0\0\0\0'
DELAY = 1.5
real = lambda v: struct.pack('<f', v)
num = lambda v: struct.pack('<i', v)
# Column 1 is DataA, the delay of Reincarnation.
FIELDS = [(b'anam', 3, 0, 0, b'Reaparicion', NONE), (b'aher', 0, 0, 0, num(0), NONE), (b'acdn', 2, 1, 0, real(0.), NONE),
          (b'Ore1', 2, 1, 1, real(DELAY), NONE)]

TICK_OLD = '''            if not s__GroundCollision_alive(s__RapidPair_actor[this]) or not s__GroundCollision_alive(s__RapidPair_controller[this]) then
                call s__RapidPair_destroy(this)
            else
'''
TICK_NEW = '''            if GetUnitTypeId(s__RapidPair_actor[this]) == 0 or not s__GroundCollision_alive(s__RapidPair_controller[this]) then
                call s__RapidPair_destroy(this)
            elseif not s__GroundCollision_alive(s__RapidPair_actor[this]) then
                if not s__RapidPair_down[this] then
                    set s__RapidPair_down[this]=true
                    call PauseTimer(s__RapidPair_reset[this])
                    call s__RapidPair_finish(this,false)
                    set s__GroundMotion_hasGoal[s__RapidPair_motion[this]]=false
                    call PauseUnit(s__RapidPair_controller[this], true)
                endif
                // The controller must not die with the character: its life is only what the panel shows.
                call SetWidgetLife(s__RapidPair_controller[this], 1.)
            else
                if s__RapidPair_down[this] then
                    set s__RapidPair_down[this]=false
                    call PauseUnit(s__RapidPair_controller[this], false)
                endif
'''
POINT_OLD = '''        if this != 0 then
            // A new cast must not be cancelled by a queued proxy move reset.
'''
POINT_NEW = '''        if this != 0 and not s__RapidPair_down[this] then
            // A new cast must not be cancelled by a queued proxy move reset.
'''
SPELL_OLD = '''        if this != 0 then
            call s__RapidPair_castFamily('''
SPELL_NEW = '''        if this != 0 and not s__RapidPair_down[this] then
            call s__RapidPair_castFamily('''
ACTOR_OLD = '''    call UnitRemoveAbility(Game_Hero[p], 'Aatk')
'''
ACTOR_NEW = ACTOR_OLD + '''    call UnitAddAbility(Game_Hero[p], 'Arei')
'''
GLOBAL_OLD = 'boolean array s__RapidPair_firing\n'


if __name__ == '__main__':
    j_in, j_out, a_in, a_out = sys.argv[1:5]
    s = Path(j_in).read_text(encoding='latin-1', newline='')
    for old, new in ((TICK_OLD, TICK_NEW), (POINT_OLD, POINT_NEW), (SPELL_OLD, SPELL_NEW), (ACTOR_OLD, ACTOR_NEW),
                     (GLOBAL_OLD, GLOBAL_OLD + 'boolean array s__RapidPair_down\n')):
        s = base.once(s, old, new)
    Path(j_out).write_text(s, encoding='latin-1', newline='')

    version, tables = parse_w3a(Path(a_in).read_bytes())
    assert not any(r[1] == b'Arei' for t in tables for r in t), 'id'
    tables[1].append((b'AOre', b'Arei', FIELDS))
    Path(a_out).write_bytes(encode_w3a(version, tables))
    print('ok')
