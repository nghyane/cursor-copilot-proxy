# Copilot API Load-Balanced with Traefik

Easily spin up multiple `copilot-api` containers with different GitHub tokens, automatically load-balanced using **Traefik** reverse proxy.

---

## 📚 Table of Contents
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
  - [One-Command Setup (Recommended)](#option-1-one-command-setup-recommended)
  - [Manual Setup](#option-2-manual-setup)
- [Access Points](#-access-points)
- [SSL/HTTPS Configuration](#-sslhttps-configuration)
- [Configuration](#-configuration)
  - [Adding/Removing Services](#addingremoving-services)
  - [Project Structure](#project-structure)
- [Security Notes](#-security-notes)
- [Troubleshooting](#-troubleshooting)

---

## 📋 Prerequisites
- Docker & Docker Compose
- Python 3 with Jinja2
- Valid GitHub tokens

---

## 🚀 Quick Start

### Option 1: One-Command Setup (Recommended)
For the fastest setup, run this single command:
```bash
curl -sSL https://raw.githubusercontent.com/nghyane/cursor-copilot-proxy/main/quick-setup.sh | bash
```
This will:
1. Clone the project
2. Set proper file permissions
3. Install all dependencies
4. Guide you through token configuration
5. Start the containers

### Option 2: Manual Setup

#### 1. Clone Project
```bash
git clone https://github.com/nghyane/cursor-copilot-proxy.git
cd cursor-copilot-proxy
```

#### 2. Set File Permissions
```bash
chmod +x setup.sh      # Make setup script executable
chmod +x generate.py   # Make generator script executable
```

#### 3. Setup Dependencies
```bash
./setup.sh            # Auto-detect OS and install dependencies
```

#### 4. Configure Tokens
Edit `tokens.json.example` and save as `tokens.json`:
```json
[
  {
    "name": "service1",
    "token": "your_github_token_here"
  },
  {
    "name": "service2", 
    "token": "another_github_token_here"
  }
]
```

#### 5. Generate & Run
```bash
python3 generate.py 
docker compose up -d  
```

---

## 🌐 Access Points
- **Traefik Dashboard**: [http://localhost:8080](http://localhost:8080)
- **Load-Balanced API**: [http://localhost/](http://localhost/)

---

## 🔒 SSL/HTTPS Configuration
This setup is optimized for use with **Cloudflare** as SSL/TLS proxy:
- **HTTP only** on the server side (port 80)
- **HTTPS handled by Cloudflare** proxy
- **No Let's Encrypt** certificates needed
- **Simplified configuration** without SSL complexity

**Using with Cloudflare:**
1. Point your domain to Cloudflare
2. Enable Cloudflare proxy (orange cloud)
3. Set SSL/TLS mode to "Flexible" or "Full"
4. Access your API via HTTPS through Cloudflare

---

## 📝 Configuration

### Adding/Removing Services
1. Edit `tokens.json` with your GitHub tokens
2. Regenerate and restart:
```bash
python3 generate.py && docker compose up -d
```
Traefik will automatically discover and route traffic to new containers.

### Project Structure
```
├── setup.sh                    # Dependency installer
├── generate.py                 # Docker Compose generator
├── tokens.json                 # GitHub tokens config (create from example)
├── templates/
│   └── docker-compose.yaml.j2  # Jinja2 template
└── README.md                   # This file
```

---

## 🔒 Security Notes
- **Never commit `tokens.json`** - it contains sensitive GitHub tokens
- Use `.gitignore` to exclude sensitive files
- Consider using environment variables for production

---

## 🛠️ Troubleshooting
- Ensure Docker Desktop is running (macOS)
- Check Docker service status (Ubuntu): `sudo systemctl status docker`
- Verify tokens are valid and have proper permissions
