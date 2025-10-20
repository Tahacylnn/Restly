# Restly Windows Agent Service

This folder contains a Windows Service-ready agent implemented as a .NET Generic Host hosted service.
It connects to the Restly server via Socket.IO and responds to `lock` / `unlock` messages.

## Build & Install (quick)
1. Install .NET 7 SDK.
2. From this folder run:
   dotnet restore
   dotnet build -c Release
   dotnet publish -c Release -r win-x64 -o publish

3. As Administrator, run:
   .\install_service.ps1

## Notes
- The service uses `appsettings.json` for configuration (WsUrl, Jwt).
- Logging is written to a rolling log file under `logs/`.
- Blocking input (`BlockInput`) is available but commented by default — use cautiously.
