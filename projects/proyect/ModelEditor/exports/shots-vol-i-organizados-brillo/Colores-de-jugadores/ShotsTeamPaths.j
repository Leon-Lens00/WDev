// Shots Vol. I by Vinz; edited derivatives for Classic 1.27b.
// Import the three BLPs and desired MDXs using their ShotsTeam paths.
// Select when launching; player color can differ from player slot/team ID.
function ShotsTeamPath takes playercolor color, boolean double returns string
    if color == ConvertPlayerColor(0) then
        if double then
            return "ShotsTeam\\Shot_00_Red_Double.mdx"
        endif
        return "ShotsTeam\\Shot_00_Red.mdx"
    endif
    if color == ConvertPlayerColor(1) then
        if double then
            return "ShotsTeam\\Shot_01_Blue_Double.mdx"
        endif
        return "ShotsTeam\\Shot_01_Blue.mdx"
    endif
    if color == ConvertPlayerColor(2) then
        if double then
            return "ShotsTeam\\Shot_02_Cyan_Double.mdx"
        endif
        return "ShotsTeam\\Shot_02_Cyan.mdx"
    endif
    if color == ConvertPlayerColor(3) then
        if double then
            return "ShotsTeam\\Shot_03_Purple_Double.mdx"
        endif
        return "ShotsTeam\\Shot_03_Purple.mdx"
    endif
    if color == ConvertPlayerColor(4) then
        if double then
            return "ShotsTeam\\Shot_04_Yellow_Double.mdx"
        endif
        return "ShotsTeam\\Shot_04_Yellow.mdx"
    endif
    if color == ConvertPlayerColor(5) then
        if double then
            return "ShotsTeam\\Shot_05_Orange_Double.mdx"
        endif
        return "ShotsTeam\\Shot_05_Orange.mdx"
    endif
    if color == ConvertPlayerColor(6) then
        if double then
            return "ShotsTeam\\Shot_06_Green_Double.mdx"
        endif
        return "ShotsTeam\\Shot_06_Green.mdx"
    endif
    if color == ConvertPlayerColor(7) then
        if double then
            return "ShotsTeam\\Shot_07_Pink_Double.mdx"
        endif
        return "ShotsTeam\\Shot_07_Pink.mdx"
    endif
    if color == ConvertPlayerColor(8) then
        if double then
            return "ShotsTeam\\Shot_08_LightGray_Double.mdx"
        endif
        return "ShotsTeam\\Shot_08_LightGray.mdx"
    endif
    if color == ConvertPlayerColor(9) then
        if double then
            return "ShotsTeam\\Shot_09_LightBlue_Double.mdx"
        endif
        return "ShotsTeam\\Shot_09_LightBlue.mdx"
    endif
    if color == ConvertPlayerColor(10) then
        if double then
            return "ShotsTeam\\Shot_10_Aqua_Double.mdx"
        endif
        return "ShotsTeam\\Shot_10_Aqua.mdx"
    endif
    if color == ConvertPlayerColor(11) then
        if double then
            return "ShotsTeam\\Shot_11_Brown_Double.mdx"
        endif
        return "ShotsTeam\\Shot_11_Brown.mdx"
    endif
    // Unknown/neutral color: documented fallback to LightGray.
    if double then
        return "ShotsTeam\\Shot_08_LightGray_Double.mdx"
    endif
    return "ShotsTeam\\Shot_08_LightGray.mdx"
endfunction

function ShotsPlayerPath takes player owner, boolean double returns string
    return ShotsTeamPath(GetPlayerColor(owner), double)
endfunction
