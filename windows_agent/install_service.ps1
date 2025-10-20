Param(
  [string]$ProjectPath = ".",
  [string]$Configuration = "Release",
  [string]$Runtime = "win-x64",
  [string]$ServiceName = "RestlyAgent",
  [string]$ServiceDisplayName = "Restly Desktop Agent"
)

Write-Host "Publishing project..."
dotnet publish $ProjectPath -c $Configuration -r $Runtime -o "$ProjectPath\publish"

$publishPath = Join-Path (Resolve-Path $ProjectPath) "publish"
$exePath = Join-Path $publishPath "RestlyAgent.exe"

if (-Not (Test-Path $exePath)) {
    Write-Error "Executable not found at $exePath. Check publish output."
    exit 1
}

$binPath = "`"$exePath`""
Write-Host "Creating service $ServiceName -> $binPath"
sc.exe create $ServiceName binPath= $binPath DisplayName= "$ServiceDisplayName" start= auto
sc.exe description $ServiceName "Restly desktop agent - connects to server and enforces break locks."
Write-Host "Service created. Start it with: Start-Service -Name $ServiceName"
