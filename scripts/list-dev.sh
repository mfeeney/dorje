#!/bin/bash
set -euo pipefail

PROXMOX_HOST="root@192.168.1.50"

echo "LXC Containers on Proxmox:"
echo ""
ssh "$PROXMOX_HOST" "pct list"
