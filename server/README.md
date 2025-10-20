# Server (Node.js + Express + Socket.IO)

## Quick start (using Docker Compose)

1. Copy `.env.example` to `.env` and adjust values.
2. From repo root run:
   ```bash
   docker compose up
   ```
3. Enter the server container or run locally:
   ```bash
   cd server
   npm install
   npm run dev
   ```

Seeded demo user: demo@restly.local / demo_password

Socket.IO clients (desktop agents) should connect using `?token=JWT`.
