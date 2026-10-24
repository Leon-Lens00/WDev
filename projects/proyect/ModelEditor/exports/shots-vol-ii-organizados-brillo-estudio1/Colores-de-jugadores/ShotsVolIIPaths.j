// Shots Vol. II by Vinz. Classic 1.27b. Resolve at launch by assigned player color.
function ShotsVolIIPath takes playercolor color returns string
    if color == ConvertPlayerColor(0) then
        return "ShotsVolII\\ShotII_00_Red.mdx"
    endif
    if color == ConvertPlayerColor(1) then
        return "ShotsVolII\\ShotII_01_Blue.mdx"
    endif
    if color == ConvertPlayerColor(2) then
        return "ShotsVolII\\ShotII_02_Cyan.mdx"
    endif
    if color == ConvertPlayerColor(3) then
        return "ShotsVolII\\ShotII_03_Purple.mdx"
    endif
    if color == ConvertPlayerColor(4) then
        return "ShotsVolII\\ShotII_04_Yellow.mdx"
    endif
    if color == ConvertPlayerColor(5) then
        return "ShotsVolII\\ShotII_05_Orange.mdx"
    endif
    if color == ConvertPlayerColor(6) then
        return "ShotsVolII\\ShotII_06_Green.mdx"
    endif
    if color == ConvertPlayerColor(7) then
        return "ShotsVolII\\ShotII_07_Pink.mdx"
    endif
    if color == ConvertPlayerColor(8) then
        return "ShotsVolII\\ShotII_08_LightGray.mdx"
    endif
    if color == ConvertPlayerColor(9) then
        return "ShotsVolII\\ShotII_09_LightBlue.mdx"
    endif
    if color == ConvertPlayerColor(10) then
        return "ShotsVolII\\ShotII_10_Aqua.mdx"
    endif
    if color == ConvertPlayerColor(11) then
        return "ShotsVolII\\ShotII_11_Brown.mdx"
    endif
    return "ShotsVolII\\ShotII_08_LightGray.mdx"
endfunction

function ShotsVolIIPlayerPath takes player owner returns string
    return ShotsVolIIPath(GetPlayerColor(owner))
endfunction
