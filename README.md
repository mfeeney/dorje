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

## Roadmap

All tasks, setup guides, and progress are tracked in [GitHub Issues](https://github.com/mfeeney/dorje/issues).

See the [Epic: Dorje Homelab Build-Out](https://github.com/mfeeney/dorje/issues/1) for the full plan.
