param([switch]$NoBrowser)
$studioUrl = 'http://127.0.0.1:4317'
$studioReady = $false
try { $studioReady = (Invoke-WebRequest -Uri $studioUrl -UseBasicParsing -TimeoutSec 2).Content -match 'Warcraft UI Studio' } catch {}
if (-not $studioReady) {
    $studioNode = (Get-Command node -ErrorAction Stop).Source
    $studioScript = Join-Path $PSScriptRoot 'server.mjs'
    Start-Process -FilePath $studioNode -ArgumentList ('"' + $studioScript + '"') -WorkingDirectory $PSScriptRoot -WindowStyle Hidden
    for ($studioAttempt = 0; $studioAttempt -lt 20; $studioAttempt++) {
        Start-Sleep -Milliseconds 200
        try { $studioReady = (Invoke-WebRequest -Uri $studioUrl -UseBasicParsing -TimeoutSec 1).Content -match 'Warcraft UI Studio' } catch {}
        if ($studioReady) { break }
    }
}
if (-not $studioReady) { throw 'No se pudo iniciar UI Studio en el puerto 4317.' }
if (-not $NoBrowser) { Start-Process $studioUrl }
Write-Output $studioUrl
