// Puente entre el nucleo de oleadas y RestTime: al terminar una Wave ligada por el stage, RestTime abre el descanso
// y guarda la funcion de la siguiente oleada. Sustituye a la antigua llamada endF del nucleo.
library WaveRestTimeBridge initializer Init requires WaveTest, RestTimeEndFlow
    globals
        // Ligado por instancia: el token evita que un id de Wave reciclado herede el ligado anterior.
        private string array NextWaveFunc
        private integer array BoundToken
    endglobals

    // Liga una Wave para que su fin (natural o por terminate) encadene el descanso con la funcion indicada.
    function WaveRestTimeBindNext takes Wave w, string nextWaveFunc returns nothing
        if w == 0 or nextWaveFunc == null or nextWaveFunc == "" then
            return
        endif
        set NextWaveFunc[w] = nextWaveFunc
        set BoundToken[w] = w.waveToken
    endfunction

    function WaveRestTimeUnbind takes Wave w returns nothing
        if w != 0 then
            set BoundToken[w] = 0
            set NextWaveFunc[w] = ""
        endif
    endfunction

    private function OnFinish takes nothing returns nothing
        local Wave w = GetWaveEventWave()
        local string nextWaveFunc
        if w == 0 or BoundToken[w] == 0 or BoundToken[w] != w.waveToken then
            return
        endif
        set nextWaveFunc = NextWaveFunc[w]
        call WaveRestTimeUnbind(w)
        call RestTimeOnWaveFinished(nextWaveFunc)
    endfunction

    private function Init takes nothing returns nothing
        call RegisterWaveFinishEvent(function OnFinish)
    endfunction
endlibrary
