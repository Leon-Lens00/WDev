param([switch]$SkipDownloads)
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$revision='42aaf24bcf54ae164fba49c0a59348297904a676'
Push-Location $root
try {
 if (!(Test-Path third_party/MarkovJunior/.git)) {
  if($SkipDownloads){throw 'Missing MarkovJunior checkout'}
  git clone https://github.com/mxgmn/MarkovJunior.git third_party/MarkovJunior
  if($LASTEXITCODE){throw 'Clone failed'}
 }
 git -C third_party/MarkovJunior checkout --detach $revision
 if($LASTEXITCODE){throw 'Revision checkout failed'}
 $samplePatch=Join-Path $root 'generators/markovjunior-sample-bounds.patch'
 git -C third_party/MarkovJunior apply --reverse --check $samplePatch 2>$null
 if($LASTEXITCODE){
  git -C third_party/MarkovJunior apply --check $samplePatch
  if($LASTEXITCODE){throw 'MarkovJunior sample bounds patch cannot be applied'}
  git -C third_party/MarkovJunior apply $samplePatch
  if($LASTEXITCODE){throw 'MarkovJunior sample bounds patch failed'}
 }
 $dotnet=Join-Path $root '.tools/dotnet/dotnet.exe'
 if(!(Test-Path $dotnet)){
  if($SkipDownloads){throw 'Missing local .NET SDK'}
  New-Item -ItemType Directory -Force .tools | Out-Null
  Invoke-WebRequest https://dot.net/v1/dotnet-install.ps1 -OutFile .tools/dotnet-install.ps1
  & ./.tools/dotnet-install.ps1 -Version 10.0.401 -InstallDir .tools/dotnet -NoPath
 }
 & $dotnet restore generators/markovjunior-host/Host.csproj --locked-mode
 if($LASTEXITCODE){throw 'Restore failed'}
 & $dotnet build generators/markovjunior-host/Host.csproj -c Release --no-restore
 if($LASTEXITCODE){throw 'Host build failed'}
 & 'C:/Program Files/Go/bin/go.exe' build -o build/bin/terrain-gen.exe ./cmd/terrain-gen
 if($LASTEXITCODE){throw 'Go build failed'}
} finally {Pop-Location}
