#!/bin/bash
set -euo pipefail

TEMPLATE_ID=9000
SUBNET="10.10.10"
DEFAULT_CORES=2
DEFAULT_RAM=1024
DEFAULT_DISK=20
PROXMOX_HOST="root@192.168.1.50"

usage() {
    echo "Usage: $0 <ct-id> <hostname> [options]"
    echo ""
    echo "Clone a dev environment from the LXC template."
    echo ""
    echo "Arguments:"
    echo "  ct-id       Container ID (101-8999)"
    echo "  hostname    Container hostname"
    echo ""
    echo "Options:"
    echo "  --cores N   CPU cores (default: $DEFAULT_CORES)"
    echo "  --ram N     Memory in MB (default: $DEFAULT_RAM)"
    echo "  --disk N    Disk in GB (default: $DEFAULT_DISK)"
    echo "  --start     Start the container after creation"
    echo ""
    echo "Examples:"
    echo "  $0 101 dorje-dev --start"
    echo "  $0 102 experiment --cores 4 --ram 4096 --start"
    exit 1
}

[[ $# -lt 2 ]] && usage

CT_ID="$1"
HOSTNAME="$2"
shift 2

CORES=$DEFAULT_CORES
RAM=$DEFAULT_RAM
DISK=$DEFAULT_DISK
START=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --cores) CORES="$2"; shift 2 ;;
        --ram)   RAM="$2"; shift 2 ;;
        --disk)  DISK="$2"; shift 2 ;;
        --start) START=true; shift ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

if [[ "$CT_ID" -lt 101 || "$CT_ID" -gt 8999 ]]; then
    echo "Error: CT ID must be between 101 and 8999"
    exit 1
fi

IP="${SUBNET}.${CT_ID}"

echo "Cloning template $TEMPLATE_ID -> CT $CT_ID ($HOSTNAME)"
echo "  IP: ${IP}/24"
echo "  Cores: $CORES, RAM: ${RAM}MB, Disk: ${DISK}GB"
echo ""

ssh "$PROXMOX_HOST" "pct clone $TEMPLATE_ID $CT_ID --hostname $HOSTNAME --full 1"
ssh "$PROXMOX_HOST" "pct set $CT_ID \
    --net0 name=eth0,bridge=vmbr0,ip=${IP}/24,gw=${SUBNET}.1 \
    --cores $CORES \
    --memory $RAM"

# Resize disk if different from template default
if [[ "$DISK" -ne "$DEFAULT_DISK" ]]; then
    DIFF=$((DISK - DEFAULT_DISK))
    if [[ "$DIFF" -gt 0 ]]; then
        ssh "$PROXMOX_HOST" "pct resize $CT_ID rootfs +${DIFF}G"
    else
        echo "Warning: Cannot shrink disk below template size (${DEFAULT_DISK}GB)"
    fi
fi

echo ""
echo "Container $CT_ID ($HOSTNAME) created successfully."
echo "  IP: $IP"

if $START; then
    ssh "$PROXMOX_HOST" "pct start $CT_ID"
    echo "  Status: running"
    echo ""
    echo "Connect with:"
    echo "  ssh root@$IP"
else
    echo "  Status: stopped"
    echo ""
    echo "Start with:"
    echo "  ssh $PROXMOX_HOST \"pct start $CT_ID\""
    echo "Then connect:"
    echo "  ssh root@$IP"
fi
