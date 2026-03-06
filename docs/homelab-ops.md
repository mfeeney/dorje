# Homelab Operations Guide

Quick reference for managing the Proxmox homelab and LXC containers.

## Infrastructure Overview

| Component | Details |
|-----------|---------|
| **Hardware** | Beelink SER8 — Ryzen 7 8745HS, 32GB DDR5, 1TB NVMe |
| **Hypervisor** | Proxmox VE 9.1 |
| **Local IP** | 192.168.1.50 (WiFi) |
| **Tailscale IP** | 100.70.107.16 |
| **Container network** | 10.10.10.0/24 (NAT via vmbr0) |
| **Template** | CT 9000 — Ubuntu 24.04, git, python3, node 20, zsh, Claude Code |

## Access

| What | How |
|------|-----|
| **Proxmox web UI** | https://100.70.107.16:8006 (or https://192.168.1.50:8006 on local WiFi) |
| **SSH to host** | `ssh root@100.70.107.16` |
| **SSH to container** | `ssh root@10.10.10.<ct-id>` (requires Tailscale subnet routing) |

## Clone a Dev Environment

```bash
# Basic clone
./scripts/clone-dev.sh <ct-id> <hostname> --start

# With custom resources
./scripts/clone-dev.sh 101 dorje-dev --cores 4 --ram 4096 --start

# Examples
./scripts/clone-dev.sh 101 dorje-dev --start
./scripts/clone-dev.sh 102 experiment --cores 4 --ram 4096 --start
./scripts/clone-dev.sh 103 agent-worker --start
```

The CT ID is also the last octet of the container's IP: CT 101 = 10.10.10.101.

## Destroy a Container

```bash
# Interactive (asks for confirmation)
./scripts/destroy-dev.sh 101

# Skip confirmation
./scripts/destroy-dev.sh 101 --force
```

This stops the container if running and removes all its storage.

## List Containers

```bash
./scripts/list-dev.sh
```

## Manual Operations (Proxmox CLI via SSH)

```bash
# Start/stop
ssh root@192.168.1.50 "pct start 101"
ssh root@192.168.1.50 "pct stop 101"

# Enter a container from the host (no SSH needed)
ssh root@192.168.1.50 "pct enter 101"

# Execute a command in a container
ssh root@192.168.1.50 "pct exec 101 -- bash -c 'whoami'"

# View container config
ssh root@192.168.1.50 "pct config 101"

# Resize disk (can only grow)
ssh root@192.168.1.50 "pct resize 101 rootfs +10G"
```

## Resource Limits

**Host capacity:** 27GB usable RAM, ~794GB thin-provisioned disk (local-lvm)

Containers use thin provisioning — a 20GB container only consumes actual used space (~1.5GB for the base template). Idle containers use ~30MB RAM.

| Scenario | Containers | RAM each | Total RAM | Disk |
|----------|-----------|----------|-----------|------|
| Light dev | 3-4 | 1GB | 3-4GB | ~6GB actual |
| Heavy dev (Claude Code) | 3-4 | 2-4GB | 6-16GB | ~6GB actual |
| Max comfortable | 6-8 | 2GB | 12-16GB | ~12GB actual |
| Absolute max | 10+ | 1GB | 10GB+ | grows with use |

**Rule of thumb:** Keep total allocated RAM under 24GB to leave headroom for the host and disk cache. With 2GB per container, that's ~10-12 containers.

## Container IP Allocation

| Range | Purpose |
|-------|---------|
| 10.10.10.1 | Gateway (Proxmox host, vmbr0) |
| 10.10.10.100 | Template (CT 9000, not running) |
| 10.10.10.101-199 | Dev environments and services |

## Troubleshooting

**Can't reach container from laptop:**
1. Check container is running: `./scripts/list-dev.sh`
2. Check Tailscale is up on laptop: `tailscale status`
3. Check subnet route is approved: https://login.tailscale.com/admin/machines
4. Test from Proxmox host: `ssh root@192.168.1.50 "pct exec <id> -- ping 8.8.8.8"`

**Container has no internet:**
- Check NAT is working: `ssh root@192.168.1.50 "iptables -t nat -L POSTROUTING"`
- Check IP forwarding: `ssh root@192.168.1.50 "cat /proc/sys/net/ipv4/ip_forward"` (should be 1)

**Locked container (e.g. after interrupted clone):**
```bash
ssh root@192.168.1.50 "pct unlock <ct-id>"
```

**Proxmox host unreachable:**
- If on local WiFi, try `ping 192.168.1.50`
- If remote, check Tailscale: `tailscale ping beelink`
- Last resort: connect monitor + keyboard to Beelink
