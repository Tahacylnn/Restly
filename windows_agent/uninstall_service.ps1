Param([string]$ServiceName = "RestlyAgent")
if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName
    Write-Host "Service $ServiceName removed."
} else {
    Write-Host "Service $ServiceName not found."
}
