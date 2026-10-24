param(
 [string]$Spec='examples/terrain/tropical-recompose.json',
 [string]$Out='../artifacts/warcraft-terrain/recompose-local',
 [int]$Seed=32700,
 [switch]$Batch,
 [int]$ForgeProcessId=0,
 [string]$ForgeExe='build/bin/wc3-forge-camera.exe'
)
$ErrorActionPreference='Stop'
$repoRoot=Split-Path $PSScriptRoot -Parent
Push-Location $repoRoot
try {
 $resolvedOutput=$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Out)
 if(Test-Path -LiteralPath $resolvedOutput){throw 'Choose a new output directory to preserve prior evidence.'}
 $goExe=(Get-Command go -ErrorAction SilentlyContinue).Source
 if(!$goExe){$goExe='C:/Program Files/Go/bin/go.exe'}
 & $goExe build -o build/bin/terrain-gen.exe ./cmd/terrain-gen
 if($LASTEXITCODE){throw 'CLI build failed'}
 & ./build/bin/terrain-gen.exe library --spec $Spec --out "$resolvedOutput/library"
 if($LASTEXITCODE){throw 'Library extraction failed'}
 if($Batch){
  & ./build/bin/terrain-gen.exe batch --spec $Spec --out "$resolvedOutput/batch"
  if($LASTEXITCODE){throw 'Batch failed; inspect persistent reports'}
  $runs=@((Get-Content -Raw -LiteralPath "$resolvedOutput/batch/batch.json" | ConvertFrom-Json).reports)
 } else {
  & ./build/bin/terrain-gen.exe generate --spec $Spec --seed $Seed --out "$resolvedOutput/$Seed"
  if($LASTEXITCODE){throw 'Generation failed'}
  $runs=@((Get-Content -Raw -LiteralPath "$resolvedOutput/$Seed/report.json" | ConvertFrom-Json))
 }
 foreach($run in $runs){
  $runDir=Split-Path $run.map -Parent
  & ./build/bin/terrain-gen.exe validate --spec "$runDir/spec.json" --map $run.map --out "$runDir/recheck.json"
  if($LASTEXITCODE){throw 'Export validation failed'}
  if($ForgeProcessId -gt 0){
   node mcp/scripts/terrain-preview.mjs $ForgeExe $ForgeProcessId $run.map "$runDir/spec.json" "$runDir/preview" "$runDir/views.json"
   if($LASTEXITCODE){throw 'Viewport capture failed'}
  }
 }
 Write-Output "Generated and structurally validated: $resolvedOutput. Visual review and native editor save remain explicit acceptance steps."
} finally {Pop-Location}

