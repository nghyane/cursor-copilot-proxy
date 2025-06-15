 #!/usr/bin/env bash
# One-command setup for Copilot API Load-Balanced with Traefik
# Usage: curl -sSL https://raw.githubusercontent.com/nghyane/cursor-copilot-proxy/main/quick-setup.sh | bash

set -e

PROJECT_NAME="copilot-compose-traefik"
REPO_URL="https://github.com/nghyane/cursor-copilot-proxy.git"

echo "🚀 Starting one-command setup for Copilot API Load-Balanced with Traefik..."

# Clone project if not exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo "📥 Cloning project..."
    git clone "$REPO_URL"
else
    echo "📂 Project already exists, updating..."
    cd "$PROJECT_NAME"
    git pull
    cd ..
fi

# Enter project directory
cd "$PROJECT_NAME"

# Make scripts executable
echo "🔧 Setting up file permissions..."
chmod +x setup.sh
chmod +x generate.py

# Run setup
echo "⚙️  Running setup script..."
./setup.sh

# Check if tokens.json exists
if [ ! -f "tokens.json" ]; then
    echo "⚠️  tokens.json not found. Creating from example..."
    cp tokens.json.example tokens.json
    echo ""
    echo "🔑 Please edit tokens.json with your GitHub tokens:"
    echo "   nano tokens.json"
    echo ""
    echo "Then run the following commands to start:"
    echo "   python3 generate.py"
    echo "   docker compose up -d"
else
    echo "✅ tokens.json found, generating and starting containers..."
    python3 generate.py
    docker compose up -d
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "Access points:"
    echo "  - Traefik Dashboard: http://localhost:8080"
    echo "  - Load-Balanced API: http://localhost/"
    echo ""
    echo "To stop: docker compose down"
    echo "To view logs: docker compose logs -f"
fi