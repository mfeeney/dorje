# Dorje — Personal AI Assistant

## Overview
Dorje is a personal AI assistant platform with a FastAPI backend and React frontend. It runs on a Beelink SER8 homelab server via Proxmox LXC.

## Tech Stack
- **Backend:** Python 3.14, FastAPI, SQLAlchemy (async), Alembic, aiosqlite, Anthropic SDK
- **Frontend:** React 19, TypeScript, Vite, Tailwind CSS v4, shadcn/ui
- **Task runner:** go-task (`task dev`, `task test`, `task lint`)
- **Package managers:** uv (Python), npm (Node)

## Project Structure
```
dorje/
├── assistant/
│   ├── backend/       # FastAPI app (uv-managed)
│   │   ├── app/       # Application code
│   │   ├── alembic/   # Database migrations
│   │   └── tests/     # pytest tests
│   └── frontend/      # React app (Vite)
│       └── src/       # Source code
├── Taskfile.yml       # Task runner commands
└── CLAUDE.md          # This file
```

## Dev Commands
| Command | Description |
|---------|-------------|
| `task dev` | Start backend + frontend dev servers |
| `task dev:backend` | FastAPI on :8001 |
| `task dev:frontend` | Vite on :5173 |
| `task install` | Install all deps |
| `task test` | Run all tests |
| `task test:backend` | pytest |
| `task test:frontend` | vitest |
| `task lint` | Lint all |
| `task format` | Format all |
| `task db:migrate` | Run Alembic migrations |
| `task db:revision -- MSG="description"` | Create new migration |

## Conventions
- All API routes are prefixed with `/api`
- Use `uv run` for all Python commands (no manual venv activation)
- Frontend uses `@/` path alias mapping to `./src/`
- shadcn/ui components live in `src/components/ui/`
- Tailwind v4: use `@import "tailwindcss"` — no tailwind.config.js

## Environment Variables
Copy `.env.example` to `.env` in `assistant/backend/`:
- `ANTHROPIC_API_KEY` — Required for Claude API
- `DATABASE_URL` — SQLite path (default: `sqlite+aiosqlite:///./dorje.db`)
