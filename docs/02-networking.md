# Networking

## TODO Before Install

- [ ] Log into your router admin page and find the DHCP range
- [ ] Pick a static IP for Proxmox OUTSIDE that range (e.g., 192.168.1.50)
- [ ] Note your gateway IP and subnet mask

## Proxmox Host Network

The installer will configure `/etc/network/interfaces` with:

```
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.50/24    # <-- your chosen static IP
    gateway 192.168.1.1        # <-- your router
    bridge-ports enp1s0        # <-- the physical ethernet adapter
    bridge-stp off
    bridge-fd 0
```

`vmbr0` is a Linux bridge — it's what lets containers get IPs on your LAN.

## Container Networking (Bridged)

Each LXC container will attach to `vmbr0` and get an IP from your router via DHCP (or you can assign static IPs per container).

- Simple, containers appear as regular devices on your network
- You can SSH directly to any container from your laptop
- Tailscale on the host covers remote access for all of them

## DNS

For local name resolution, two options:

1. **Simple:** Just use IPs. Tailscale gives magic DNS names automatically (e.g., `dorje.tailnet-name.ts.net`)
2. **Later:** Set up Pi-hole or Adguard Home in a container for local DNS + ad blocking

Recommendation: Start simple, add DNS later if needed.

## Firewall

Proxmox has a built-in firewall. For now:

- Default deny inbound on the host
- Allow ports: 22 (SSH), 8006 (Proxmox web UI) from LAN
- Tailscale traffic bypasses firewall (it's on its own interface)
- Cloudflare Tunnel traffic originates from inside the container (outbound only, no ports to open)
