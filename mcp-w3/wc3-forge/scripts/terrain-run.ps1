param([string]$Spec='examples/terrain/tropical.json',[string]$Out='../artifacts/warcraft-terrain/local-run',[switch]$Batch)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
 $command='generate';if($Batch){$command='batch'}
 & ./build/bin/terrain-gen.exe $command --spec $Spec --out $Out
 if($LASTEXITCODE){throw "terrain-gen failed with exit $LASTEXITCODE"}
} finally {Pop-Location}
