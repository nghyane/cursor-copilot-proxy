# Copilot API Load-Balanced with Traefik

This project spins up multiple `copilot-api` containers with different GitHub tokens,
and balances them automatically using **Traefik** reverse proxy.

## 📋 Prerequisites

- Docker & Docker Compose
- Python 3 with Jinja2
- Valid GitHub tokens

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

## 🌐 Access Points

- **Traefik Dashboard**: http://localhost:8080
- **Load-Balanced API**: http://localhost/

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

## 🔒 Security Notes

- **Never commit `tokens.json`** - it contains sensitive GitHub tokens
- Use `.gitignore` to exclude sensitive files
- Consider using environment variables for production

## 🛠️ Troubleshooting

- Ensure Docker Desktop is running (macOS)
- Check Docker service status (Ubuntu): `sudo systemctl status docker`
- Verify tokens are valid and have proper permissions
