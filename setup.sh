#!/usr/bin/env bash
# Setup Docker + Python + Jinja2 on Ubuntu or macOS
set -e

echo "==> Detecting OS..."
OS=$(uname -s)

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "✅ $1 already installed"
    return 0
  else
    echo "❌ $1 not found, will install"
    return 1
  fi
}

install_ubuntu() {
  echo "==> Checking Ubuntu dependencies..."
  
  # Check Docker
  if check_command docker; then
    echo "ℹ️  Checking Docker service status..."
    if ! sudo systemctl is-active --quiet docker; then
      echo "🔄 Starting Docker service..."
      sudo systemctl start docker
    fi
  else
    echo "🔄 Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
  fi
  
  # Check Python3
  if ! check_command python3; then
    echo "🔄 Installing Python3..."
    sudo apt install -y python3 python3-pip
  fi
  
  # Check Jinja2
  if python3 -c "import jinja2" 2>/dev/null; then
    echo "✅ jinja2 already installed"
  else
    echo "🔄 Installing jinja2..."
    pip3 install --user jinja2
  fi
  
  echo "✅ Ubuntu ready"
}

install_mac() {
  echo "==> Checking macOS dependencies..."
  
  # Check Homebrew
  if ! check_command brew; then
    echo "🔄 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  
  # Check Docker
  if ! check_command docker; then
    echo "🔄 Installing Docker Desktop..."
    brew install --cask docker
    echo "⚠️  Please start Docker Desktop manually"
  else
    echo "ℹ️  Docker found. Make sure Docker Desktop is running"
  fi
  
  # Check Python3
  if ! check_command python3; then
    echo "🔄 Installing Python..."
    brew install python
  fi
  
  # Check Jinja2
  if python3 -c "import jinja2" 2>/dev/null; then
    echo "✅ jinja2 already installed"
  else
    echo "🔄 Installing jinja2..."
    pip3 install jinja2
  fi
  
  echo "✅ macOS ready"
}

case "$OS" in
  Linux)
    if grep -qi ubuntu /etc/os-release; then install_ubuntu; else echo "Only Ubuntu supported"; exit 1; fi ;;
  Darwin)
    install_mac ;;
  *)
    echo "Unsupported OS"; exit 1 ;;
esac

echo "✅ Done. Run: python3 generate.py && docker compose up -d"
