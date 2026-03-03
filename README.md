# Dorje

> *Tibetan: "thunderbolt" or "diamond" — indestructible, cuts through illusion*

Personal homelab infrastructure and AI assistant running on a Beelink SER8 Mini PC with Proxmox VE.

## Hardware

| Component | Spec |
|-----------|------|
| **Machine** | Beelink SER8 Mini PC |
| **CPU** | AMD Ryzen 7 8745HS — 8 cores / 16 threads, Zen 4 |
| **RAM** | 32GB DDR5-5600MHz (expandable to 256GB) |
| **Storage** | 1TB PCIe 4.0 NVMe (second M.2 slot available) |
| **Network** | 2.5Gbps Ethernet, WiFi 6 |
| **TDP** | 65W, vapor chamber cooling (~32dB) |

## Architecture

```
Proxmox VE 9.1 (bare metal)
├── LXC: dorje-assistant    — Always-on AI assistant (web UI + Anthropic API)
├── LXC: dev-template       — Base Ubuntu 24.04 dev environment (cloneable)
├── LXC: dev-agent-N        — Cloned dev environments for parallel Claude Code agents
├── LXC: tailscale          — Mesh VPN for remote access
└── VM:  bt-workbench       — Bluetooth/USB passthrough (BrainBit EEG, on-demand)
```

## Project Structure

```
dorje/
├── docs/                  # Setup guides and architecture decisions
│   ├── 01-proxmox-install.md
│   ├── 02-networking.md
│   ├── 03-remote-access.md
│   ├── 04-lxc-template.md
│   └── 05-assistant.md
├── assistant/             # Dorje AI assistant (custom web UI + API)
├── scripts/               # Automation scripts (post-install, template creation, etc.)
├── templates/             # LXC container configs and setup scripts
└── README.md
```

## Goals (Priority Order)

1. Install Proxmox VE 9.1 on the Beelink
2. Configure networking (static IP, bridged containers, DNS)
3. Set up Tailscale for secure remote access
4. Create base LXC template (Ubuntu 24.04 + dev tools + Claude Code)
5. Build and deploy the Dorje AI assistant
6. Document clone/destroy workflow for dev environments
7. (Future) Bluetooth VM template for BrainBit EEG work

## Remote Access Strategy

- **Tailscale** — Mesh VPN for SSH to Proxmox host and all containers, plus Proxmox web UI
- **Cloudflare Tunnel** — Public access to the Dorje assistant web UI (with Cloudflare Access auth)

## The Dorje Assistant

A custom-built, self-hosted AI assistant accessible from anywhere. Lightweight alternative to OpenClaw with a focus on security and simplicity.

- **Frontend:** React/Next.js chat UI (mobile-friendly)
- **Backend:** Node.js API wrapping the Anthropic SDK
- **Storage:** SQLite for persistent conversation history
- **Auth:** Cloudflare Access + token-based auth
- **Runtime:** Isolated LXC container
- **Model:** Claude (Anthropic API)

See [docs/05-assistant.md](docs/05-assistant.md) for full design.
