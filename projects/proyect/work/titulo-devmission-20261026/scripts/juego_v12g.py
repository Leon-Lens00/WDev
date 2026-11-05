"""Dev Mission title v12g (30/10/2026): characters of the player itself, one life bar for everyone.

Applied on the v12f script.
- No foreign owner: 'otau' and 'ocai' are not heroes, so the native hero icon does not appear and each player owns its
  character. Game_Owner, Game_Selected and the owner alliances go away.
- HealthBars: every player gets 'hbhr' (frame and life) and, one step behind it, the icon of its character. The frame
  has a real opening there, so the icon shows through it as it did inside the model.

Usage: juego_v12g.py IN_J OUT_J
"""
from pathlib import Path
import sys

import juego_v12f as v12f
import puente_v12 as base

BAR = 400.
ICON = 401.

ENTER = '''// v12g: player p enters the play zone with the chosen character, base unit for now.
function Game_Enter takes integer p returns nothing
    local integer k= Hero_Choice[p]
    local integer id= 'otau'
    local integer icon= 'hbi0'
    local location start= GetStartLocationLoc(GetPlayerStartLocation(Player(p)))
    if k == 1 then
        set id='ocai'
        set icon='hbi1'
    endif
    set Game_Cam[p]=s__Camera_create()
    set Game_Hero[p]=CreateUnit(Player(p), id, GetLocationX(start), GetLocationY(start), 270)
    set Game_On[p]=true
    if Game_First < 0 then
        set Game_First=p
    endif
    call HealthBarsBindPlayer(p , Game_Cam[p] , Game_Hero[p] , icon)
    call RemoveLocation(start)
    set start=null
    if GetLocalPlayer() == Player(p) then
        call ClearSelection()
        call SelectUnit(Game_Hero[p], true)
    endif
endfunction
'''

if __name__ == '__main__':
    s = Path(sys.argv[1]).read_text(encoding='latin-1', newline='')

    # --- 1. Own units.
    i = s.index('// v12f: a hero the player owns gets the native icon at the top left.')
    j = s.index('// v12f: player p enters the play zone with the chosen character, base unit for now.')
    s = s[:i] + s[j:]
    s = base.once(s, '// v12f: player p enters the play zone with the chosen character, base unit for now.\n', '')
    s = v12f.replace(s, 'Game_Enter', ENTER)
    s = base.once(s, '''    // The native "control granted" line of the owners set up in Game_Enter.
    call ClearTextMessages()
''', '')
    s = base.once(s, 'integer Game_NextOwner = 8\n', 'unit array HealthBars__Icons\n')

    # --- 2. One bar, the icon behind it.
    place = v12f.function(s, 'HealthBars__Place').group(0)
    new = place.replace('takes unit u,integer cam,real px,real py', 'takes unit u,integer cam,real px,real py,real range')
    new = new.replace(', 400.)', ', range)')
    assert new.count('range') == 2
    s = s.replace(place, new)
    s = base.once(s, 'function HealthBarsBindPlayer takes integer p,integer cam,unit hero,integer kind returns nothing\n',
                  'function HealthBarsBindPlayer takes integer p,integer cam,unit hero,integer icon returns nothing\n')
    s = base.once(s, "// v12f: player p's panel, tied to its camera and character; kind is the bar unit of that character.\n",
                  "// v12g: player p's panel, tied to its camera and character; icon is the unit that shows that character.\n")
    s = base.once(s, '    set HealthBars__HeroBars[p]=HealthBars__Dummy(kind , p)\n',
                  "    set HealthBars__HeroBars[p]=HealthBars__Dummy('hbhr' , p)\n"
                  '    set HealthBars__Icons[p]=HealthBars__Dummy(icon , p)\n')
    s = base.once(s, '            call ShowUnit(HealthBars__HeroBars[p], flag)\n',
                  '            call ShowUnit(HealthBars__HeroBars[p], flag)\n'
                  '            call ShowUnit(HealthBars__Icons[p], flag)\n')
    s = base.once(s, '            call ShowUnit(HealthBars__HeroBars[p], shown)\n',
                  '            call ShowUnit(HealthBars__HeroBars[p], shown)\n'
                  '            call ShowUnit(HealthBars__Icons[p], shown)\n')
    s = base.once(s, '                call HealthBars__Place(HealthBars__HeroBars[p] , cam , 24. , 48.6)\n',
                  '                call HealthBars__Place(HealthBars__HeroBars[p] , cam , 24. , 48.6 , %.0f.)\n'
                  '                call HealthBars__Place(HealthBars__Icons[p] , cam , 24. , 48.6 , %.0f.)\n' % (BAR, ICON))
    s = base.once(s, '                call HealthBars__Place(HealthBars__EnemyBars[p] , cam , 1358.4 , 48.6)\n',
                  '                call HealthBars__Place(HealthBars__EnemyBars[p] , cam , 1358.4 , 48.6 , %.0f.)\n' % BAR)

    for gone in ['Game_Owner', 'Game_Selected', 'Game_NextOwner', 'SetPlayerAlliance(owner', 'SetPlayerName(owner', 'ClearTextMessages', "'Ocbh'",
                 "'hbh0'", "'hbh1'"]:
        assert gone not in s, gone
    Path(sys.argv[2]).write_text(s, encoding='latin-1', newline='')
    print('ok', len(s))
