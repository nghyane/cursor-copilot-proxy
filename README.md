# Copilot API Proxy with Traefik Load Balancer

A simple solution to run multiple instances of `copilot-api` service with Traefik load balancing. Uses dynamic configuration where a Python script generates `docker-compose.yaml` based on your GitHub token configurations.

## 🚀 Key Features

- **Automatic Load Balancing**: Traefik v3.4 distributes requests evenly across instances
- **Flexible Configuration**: Easy to add/remove instances via JSON file
- **Monitoring Dashboard**: Traefik dashboard for service monitoring
- **SSL/HTTPS Ready**: Cloudflare integration for SSL handling
- **Auto-reload**: Automatic configuration reload on changes

## 📋 Requirements

- **Docker & Docker Compose**: Latest version
- **Python 3.6+**: For configuration generation script
- **GitHub Tokens**: Valid tokens for each copilot-api instance

## 🔧 Quick Setup

### Method 1: Automatic Setup
```bash
curl -fsSL https://raw.githubusercontent.com/nghyane/cursor-copilot-proxy/main/quick-setup.sh | bash
```

### Method 2: Manual Setup

1. **Clone repository:**
   ```bash
   git clone https://github.com/nghyane/cursor-copilot-proxy.git
   cd cursor-copilot-proxy
   ```

2. **Configure GitHub tokens:**
   ```bash
   cp tokens.json.example tokens.json
   ```
   
   Edit `tokens.json`:
   ```json
   [
     {
       "name": "service1",
       "token": "ghp_xxxxxxxxxxxxxxxxxxxx"
     },
     {
       "name": "service2", 
       "token": "ghp_yyyyyyyyyyyyyyyyyyyy"
     }
   ]
   ```

3. **Generate Docker Compose configuration:**
   ```bash
   python3 generate.py
   ```
   
   Script will ask for domains (default: `test.localhost`, `cookora.local`)

4. **Start services:**
   ```bash
   docker compose up -d
   ```

## 🌐 Usage

### Main Endpoints
- **API Load Balancer**: `http://localhost/` or your configured domain
- **Traefik Dashboard**: `http://localhost:8080/dashboard/`

### Check Status
```bash
# View all service logs
docker compose logs -f

# View Traefik logs
docker compose logs -f traefik

# View specific service logs
docker compose logs -f service1
```

## ⚙️ Configuration Management

### Add/Remove API Instances

1. **Edit `tokens.json`**:
   ```json
   [
     {
       "name": "new-service",
       "token": "ghp_new_token_here"
     }
   ]
   ```

2. **Regenerate configuration**:
   ```bash
   python3 generate.py
   ```

3. **Restart services**:
   ```bash
   docker compose up -d --force-recreate
   ```

### Change Domains

Edit `traefik/rr.yml` or re-run `generate.py` with new domains:
```yaml
rule: Host(`your-domain.com`) || Host(`api.your-domain.com`)
```

## 🔒 SSL/HTTPS

### Using with Cloudflare (Recommended)

1. **DNS Configuration**: Point domain to your server
2. **Enable Cloudflare Proxy**: Orange cloud on Cloudflare dashboard  
3. **SSL Mode**: Choose "Flexible" or "Full"
4. **Access**: `https://your-domain.com`

### Direct SSL (Advanced)
Create `docker-compose.override.yml`:
```yaml
services:
  traefik:
    command:
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=your-email@domain.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
    ports:
      - "443:443"
    volumes:
      - "./letsencrypt:/letsencrypt"
```

## 📁 Project Structure

```
cursor-copilot-proxy/
├── docker-compose.yaml          # Docker configuration (auto-generated)
├── generate.py                  # Configuration generation script
├── tokens.json                  # GitHub tokens configuration (secure)
├── tokens.json.example          # Template for tokens.json
├── quick-setup.sh              # Automatic setup script
├── templates/
│   ├── docker-compose.yaml.j2  # Docker Compose template
│   └── rr.yml.j2              # Traefik load balancer template
└── traefik/
    └── rr.yml                 # Traefik configuration (auto-generated)
```

## 🛠️ Troubleshooting

### Common Issues

**1. Traefik Dashboard inaccessible**
```bash
# Check if port 8080 is blocked
sudo netstat -tlnp | grep :8080
```

**2. API not working**
```bash
# Check logs
docker compose logs traefik
docker compose logs service1

# Test endpoint
curl -I http://localhost/
```

**3. GitHub Token issues**
```bash
# Test token with curl
curl -H "Authorization: token ghp_xxxx" https://api.github.com/user
```

### Debug Mode

Enable debug in Traefik:
```yaml
# Add to docker-compose.yaml
command:
  - "--log.level=DEBUG"
  - "--api.debug=true"
```

## ⚠️ Important Notes

- **Security**: `tokens.json` contains sensitive tokens, never commit to git
- **Backup**: Regularly backup configurations and tokens
- **Rate Limiting**: GitHub has rate limits, consider number of instances

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/nghyane/cursor-copilot-proxy/issues)
- **Discussions**: [GitHub Discussions](https://github.com/nghyane/cursor-copilot-proxy/discussions)

---
**Made with ❤️ for the Cursor community**
