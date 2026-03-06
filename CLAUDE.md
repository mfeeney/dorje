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
├── scripts/           # Homelab management scripts
│   ├── clone-dev.sh   # Clone LXC container from template
│   ├── destroy-dev.sh # Destroy an LXC container
│   └── list-dev.sh    # List all containers
├── docs/
│   └── homelab-ops.md # Full homelab operations guide
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
| `task lxc:list` | List all LXC containers |
| `task lxc:clone -- 101 my-project --start` | Clone a dev container from template |
| `task lxc:destroy -- 101` | Destroy a container |
| `task lxc:ssh -- 101` | SSH into container by ID |
| `task lxc:status` | Show Proxmox host resource usage |

## Conventions
- All API routes are prefixed with `/api`
- Use `uv run` for all Python commands (no manual venv activation)
- Frontend uses `@/` path alias mapping to `./src/`
- shadcn/ui components live in `src/components/ui/`
- Tailwind v4: use `@import "tailwindcss"` — no tailwind.config.js

## Homelab Infrastructure
- **Proxmox host:** Beelink SER8 at `192.168.1.50` (local) / `100.70.107.16` (Tailscale)
- **Container network:** `10.10.10.0/24` — container ID = last IP octet (CT 101 = 10.10.10.101)
- **LXC template:** CT 9000 (Ubuntu 24.04 + git, python3, node 20, zsh, Claude Code)
- **Remote access:** Tailscale mesh VPN with subnet routing for container network
- **Ops guide:** See `docs/homelab-ops.md` for full details

## Environment Variables
Copy `.env.example` to `.env` in `assistant/backend/`:
- `ANTHROPIC_API_KEY` — Required for Claude API
- `DATABASE_URL` — SQLite path (default: `sqlite+aiosqlite:///./dorje.db`)
