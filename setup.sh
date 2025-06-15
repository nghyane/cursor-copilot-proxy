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
    echo "🔄 Installing Docker from official repository..."
    # Remove old versions
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
      sudo apt-get remove $pkg -y 2>/dev/null || true
    done
    
    # Add Docker's official GPG key
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install latest Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
  fi
  
  # Add current user to docker group if not already added
  if ! groups $USER | grep -q docker; then
    echo "🔄 Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo "⚠️  You may need to log out and log back in for docker group changes to take effect"
  else
    echo "✅ User already in docker group"
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
  
  # Ensure script files are executable
  echo "🔄 Setting file permissions..."
  chmod +x generate.py 2>/dev/null || true
  chmod +x setup.sh 2>/dev/null || true
  
  # Verify Docker is working
  echo "🔍 Verifying Docker installation..."
  if docker --version >/dev/null 2>&1; then
    echo "✅ Docker working correctly"
  else
    echo "⚠️  Docker may need manual verification"
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
