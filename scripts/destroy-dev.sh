#!/bin/bash
set -euo pipefail

PROXMOX_HOST="root@192.168.1.50"

usage() {
    echo "Usage: $0 <ct-id> [--force]"
    echo ""
    echo "Destroy an LXC container and clean up its resources."
    echo ""
    echo "Arguments:"
    echo "  ct-id     Container ID to destroy"
    echo ""
    echo "Options:"
    echo "  --force   Skip confirmation prompt"
    exit 1
}

[[ $# -lt 1 ]] && usage

CT_ID="$1"
FORCE=false
[[ "${2:-}" == "--force" ]] && FORCE=true

if [[ "$CT_ID" -eq 9000 ]]; then
    echo "Error: Refusing to destroy the template (CT 9000)"
    exit 1
fi

# Get container info
INFO=$(ssh "$PROXMOX_HOST" "pct config $CT_ID 2>/dev/null") || {
    echo "Error: Container $CT_ID does not exist"
    exit 1
}

HOSTNAME=$(echo "$INFO" | grep "^hostname:" | awk '{print $2}')
STATUS=$(ssh "$PROXMOX_HOST" "pct status $CT_ID" | awk '{print $2}')

echo "Container $CT_ID ($HOSTNAME)"
echo "  Status: $STATUS"

if ! $FORCE; then
    read -rp "Are you sure you want to destroy this container? [y/N] " confirm
    [[ "$confirm" != "y" && "$confirm" != "Y" ]] && { echo "Aborted."; exit 0; }
fi

if [[ "$STATUS" == "running" ]]; then
    echo "Stopping container..."
    ssh "$PROXMOX_HOST" "pct stop $CT_ID"
fi

echo "Destroying container..."
ssh "$PROXMOX_HOST" "pct destroy $CT_ID --purge"

echo "Container $CT_ID ($HOSTNAME) destroyed."
