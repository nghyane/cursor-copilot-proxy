#!/usr/bin/env bash
# One-command setup for Copilot API Load-Balanced with Traefik
# Usage: curl -sSL https://raw.githubusercontent.com/nghyane/cursor-copilot-proxy/main/quick-setup.sh | bash

set -e

PROJECT_NAME="copilot-compose-traefik"
REPO_URL="https://github.com/nghyane/cursor-copilot-proxy.git"

echo "🚀 Starting one-command setup for Copilot API Load-Balanced with Traefik..."

# Clone/update project
if [ ! -d "$PROJECT_NAME" ]; then
    echo "📥 Cloning project..."
    git clone "$REPO_URL"
else
    echo "📂 Updating existing project..."
    cd "$PROJECT_NAME" && git pull && cd ..
fi

cd "$PROJECT_NAME"

# Setup permissions
chmod +x setup.sh generate.py
./setup.sh

# Optimized token setup for SSH/remote servers
setup_tokens() {
    echo ""
    echo "🔑 GitHub Token Setup"
    echo "Get tokens from: https://github.com/settings/tokens"
    echo "Required permissions: user:email, copilot"
    echo ""
    echo "📋 How to input tokens:"
    echo "   • Paste multiple tokens (one per line) then press Ctrl+D"
    echo "   • Or paste single token then press Enter hai lần"
    echo ""
    echo "Paste your GitHub token(s):"
    
    local tokens=()
    local line_count=0
    local empty_count=0
    
    while IFS= read -r line; do
        line_count=$((line_count + 1))
        # Trim whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [ -z "$line" ]; then
            empty_count=$((empty_count + 1))
            # Break on double enter nếu đã có token
            if [ $empty_count -ge 2 ] && [ ${#tokens[@]} -gt 0 ]; then
                break
            fi
        else
            empty_count=0
            # Validate GitHub token format
            if [[ $line =~ ^(ghp_|gho_|ghu_|ghs_|ghr_|github_pat_) ]]; then
                tokens+=("$line")
                echo "  ✅ Token ${#tokens[@]} added"
            else
                echo "  ⚠️ Invalid token format on line $line_count (must start with ghp_, gho_, etc.)"
            fi
        fi
    done
    
    if [ ${#tokens[@]} -eq 0 ]; then
        echo ""
        echo "❌ No valid tokens provided!"
        echo "Example valid token: ghp_xxxxxxxxxxxxxxxxxxxx"
        return 1
    fi
    
    # Preview services
    echo ""
    echo "📋 Preview services to be created:"
    for i in "${!tokens[@]}"; do
        echo "  • copilot-api-$((i+1)): ${tokens[$i]:0:8}..."
    done
    echo -n "Save these tokens? (Y/n): "
    read -r confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        echo "❌ Cancelled."
        return 1
    fi
    
    # Generate tokens.json in correct format for generate.py
    {
        echo "["
        for i in "${!tokens[@]}"; do
            if [ $i -eq $((${#tokens[@]} - 1)) ]; then
                echo "  {\"name\": \"copilot-api-$((i+1))\", \"token\": \"${tokens[$i]}\"}"
            else
                echo "  {\"name\": \"copilot-api-$((i+1))\", \"token\": \"${tokens[$i]}\"},"
            fi
        done
        echo "]"
    } > tokens.json
    
    echo ""
    echo "✅ Created tokens.json with ${#tokens[@]} service(s)"
    return 0
}

# Check/setup tokens
if [ ! -f "tokens.json" ] || [ ! -s "tokens.json" ]; then
    while ! setup_tokens; do
        echo ""
        echo "🔄 Please try again..."
        echo -n "Continue? (Y/n): "
        read -r continue_setup
        if [[ $continue_setup =~ ^[Nn]$ ]]; then
            echo "❌ Setup cancelled"
            exit 1
        fi
    done
fi

# Final validation
echo ""
echo "🔍 Validating configuration..."
if ! token_count=$(python3 -c "import json; data=json.load(open('tokens.json')); print(len(data)) if isinstance(data, list) and len(data) > 0 else 0" 2>/dev/null); then
    token_count=0
fi

if [ "$token_count" -eq "0" ]; then
    echo "❌ Invalid or empty tokens.json"
    rm -f tokens.json
    exit 1
fi

echo "✅ Configuration valid: $token_count token(s) loaded"
echo ""
echo "🚀 Starting services..."

# Generate config and start
python3 generate.py
docker compose up -d

# Wait a moment for containers to start
sleep 3

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "🌐 Access Points:"
echo "  • Load-Balanced API: http://$(hostname -I | awk '{print $1}')/"
echo "  • Traefik Dashboard: http://$(hostname -I | awk '{print $1}'):8080"
echo "  • Local API: http://localhost/"
echo ""
echo "📊 Service Status:"
docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "📋 Management Commands:"
echo "  docker compose logs -f      # View real-time logs"
echo "  docker compose down         # Stop all services"
echo "  docker compose restart     # Restart services"
echo "  docker compose ps           # Check status"
echo ""
echo "💡 To add more tokens: edit tokens.json → python3 generate.py → docker compose up -d"