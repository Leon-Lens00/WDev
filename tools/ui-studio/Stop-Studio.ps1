[CmdletBinding(SupportsShouldProcess = $true)]
param()

$studioScript = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'server.mjs'))
$studioPattern = '(?i)(?:^|\s)"?' + [regex]::Escape($studioScript) + '"?(?:\s|$)'
$studioProcesses = @(Get-CimInstance Win32_Process -Filter "Name = 'node.exe'" | Where-Object {
    $_.CommandLine -match $studioPattern
})
if ($studioProcesses.Count -eq 0) {
    Write-Output 'UI Studio ya esta cerrado.'
    exit 0
}
foreach ($studioProcess in $studioProcesses) {
    if ($PSCmdlet.ShouldProcess("UI Studio (PID $($studioProcess.ProcessId))", 'Detener servidor local')) {
        Stop-Process -Id $studioProcess.ProcessId -ErrorAction Stop
        Write-Output 'UI Studio cerrado. Puedes cerrar su pestana del navegador.'
    }
}
