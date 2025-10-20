# Restly — Full MVP Repo

This repository contains a full starter implementation for Restly:
- `server/` : Node.js server (Express + Socket.IO) with JWT auth, PostgreSQL and example enforcement logic.
- `flutter/` : Completed Flutter app with UI, assets, theming, push placeholders and WebSocket support.
- `windows_agent/` : .NET 7 Windows service agent using SocketIOClient, logging and install/uninstall scripts.
- `docker-compose.yml` : runs Postgres + server for local testing.

This is a prototype. Do not deploy to production without securing secrets, adding tests, and legal review.

See subfolders for setup instructions.
