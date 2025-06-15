#!/usr/bin/env bash
# Docker installation and management

install_docker_linux() {
    log "Installing Docker on Linux..."
    
    # Remove old versions
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Install dependencies
    sudo apt-get update -qq
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
    # Add Docker's GPG key and repository
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt-get update -qq
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Configure Docker
    sudo systemctl enable docker
    sudo systemctl start docker
    
    # Add user to docker group
    if ! groups "$USER" | grep -q docker; then
        sudo usermod -aG docker "$USER"
        warn "Added $USER to docker group. Run: newgrp docker"
    fi
}

install_docker_macos() {
    log "Installing Docker on macOS..."
    
    if ! check_command brew; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    brew install --cask docker
    warn "Start Docker Desktop from Applications"
}

verify_docker() {
    if ! check_command docker; then
        return 1
    fi
    
    if ! docker info >/dev/null 2>&1; then
        warn "Docker daemon not running"
        return 1
    fi
    
    return 0
}

install_docker() {
    if verify_docker; then
        success "Docker already installed and running"
        return 0
    fi
    
    local os
    os=$(detect_os)
    
    case "$os" in
        ubuntu|debian) install_docker_linux ;;
        macos) install_docker_macos ;;
        *) die "Unsupported OS: $os" ;;
    esac
}