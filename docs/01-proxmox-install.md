# Proxmox VE 9.1 Installation

## Pre-Install Checklist

- [ ] USB drive flashed with Proxmox VE 9.1 ISO (DONE)
- [ ] Beelink SER8 connected to monitor, keyboard, ethernet
- [ ] Note your router's DHCP range (needed for static IP)

## BIOS Setup

1. Power on the Beelink, press `DEL` or `F2` to enter BIOS
2. Enable **AMD-V / SVM** (CPU virtualization) — likely already enabled
3. Enable **IOMMU** if available (needed for future PCI passthrough)
4. Set **USB** as first boot priority
5. Save and exit

## Installation Steps

1. Boot from USB — select "Install Proxmox VE (Graphical)"
2. Accept EULA
3. **Target disk:** Select the 1TB NVMe SSD
   - Filesystem: **ext4** (simpler) or **ZFS** (if you want snapshots — uses more RAM)
   - Recommendation: **ext4** for now, can always add ZFS pools later
4. **Country/Timezone:** United States / America/Chicago (Central Time for Mobile, AL)
5. **Password:** Set a strong root password
6. **Network configuration:**
   - Management interface: The 2.5Gbps ethernet adapter
   - Hostname: `dorje.local`
   - IP: (static IP — see networking doc)
   - Gateway: Your router IP (typically 192.168.1.1)
   - DNS: Your router IP or 1.1.1.1 / 8.8.8.8
7. Install and reboot (remove USB when prompted)

## Post-Install

After reboot, access the web UI from your laptop:
```
https://<static-ip>:8006
```
Login: `root` / (your password)

Then proceed to [02-networking.md](02-networking.md).
