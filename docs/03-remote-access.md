# Remote Access

## Strategy

| Method | Purpose | Scope |
|--------|---------|-------|
| **Tailscale** | SSH, Proxmox web UI, container access | Everything (private) |
| **Cloudflare Tunnel** | Dorje assistant web UI | Public-facing with auth |

## Tailscale Setup

### 1. Create Account
- Sign up at https://tailscale.com (free for personal, up to 100 devices)
- Can use Google/GitHub/Microsoft SSO

### 2. Install on Proxmox Host

```bash
# Add Tailscale repo
curl -fsSL https://tailscale.com/install.sh | sh

# Start and authenticate
tailscale up

# Enable subnet routing so you can reach containers
tailscale up --advertise-routes=192.168.1.0/24 --accept-routes
```

### 3. Approve Subnet Routes
- Go to Tailscale admin console → Machines → dorje → approve the advertised route
- Now any device on your tailnet can reach containers by their LAN IPs

### 4. Install Tailscale on Your Laptop/Phone
- Laptop: `curl -fsSL https://tailscale.com/install.sh | sh && tailscale up`
- Phone: Install Tailscale app from App Store / Play Store

### What This Gets You
- SSH into Proxmox from anywhere: `ssh root@dorje` (via Tailscale MagicDNS)
- Access Proxmox web UI from anywhere: `https://dorje:8006`
- SSH into any container from anywhere (via subnet routing)

## Cloudflare Tunnel Setup

### 1. Prerequisites
- A domain name (buy one on Cloudflare Registrar or transfer DNS to Cloudflare)
- Cloudflare account (free tier is fine)

### 2. Install cloudflared in the Assistant Container

```bash
# Install cloudflared
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflared.list
apt update && apt install cloudflared

# Authenticate
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create dorje-assistant

# Configure
cat > ~/.cloudflared/config.yml << EOF
tunnel: <TUNNEL_ID>
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: assistant.yourdomain.com
    service: http://localhost:3000
  - service: http_status:404
EOF

# Run as service
cloudflared service install
systemctl enable cloudflared
systemctl start cloudflared
```

### 3. Cloudflare Access (Auth Layer)
- In Cloudflare dashboard → Zero Trust → Access → Applications
- Create an application for `assistant.yourdomain.com`
- Set policy: Allow only your email address
- Now the assistant requires Cloudflare login before you can reach it
