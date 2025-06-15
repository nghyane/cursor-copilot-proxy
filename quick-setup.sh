#!/usr/bin/env bash
# One-command setup for Cursor Copilot Proxy
# Usage: curl -sSL https://raw.githubusercontent.com/nghyane/cursor-copilot-proxy/main/quick-setup.sh | bash

set -e

# Configuration
PROJECT_NAME="cursor-copilot-proxy"
REPO_URL="https://github.com/nghyane/cursor-copilot-proxy.git"

# Determine script directory
if [[ -f "lib/core.sh" ]]; then
    # Running from project directory
    SCRIPT_DIR="$(pwd)"
else
    # Running from curl, need to clone first
    SCRIPT_DIR=""
fi

LIB_DIR="$SCRIPT_DIR/lib"

# Basic logging for initial setup (before lib is available)
basic_log() { echo "🔧 $1"; }
basic_success() { echo "✅ $1"; }
basic_warn() { echo "⚠️ $1"; }
basic_error() { echo "❌ $1"; }

setup_project() {
    basic_log "Setting up project..."
    
    if [[ ! -d "$PROJECT_NAME" ]]; then
        basic_log "Cloning project..."
        git clone "$REPO_URL" "$PROJECT_NAME"
    else
        basic_log "Updating existing project..."
        cd "$PROJECT_NAME"
        if [[ -d ".git" ]]; then
            git pull origin main || {
                basic_warn "Git pull failed, continuing with existing code"
            }
        fi
        cd ..
    fi
    
    cd "$PROJECT_NAME"
    SCRIPT_DIR="$(pwd)"
    LIB_DIR="$SCRIPT_DIR/lib"
    basic_success "Project ready"
}

main() {
    echo ""
    basic_success "🚀 Cursor Copilot Proxy - Quick Setup"
    echo ""
    
    # Setup project if not in project directory
    if [[ ! -f "lib/core.sh" ]]; then
        setup_project
    fi
    
    # Load all library functions
    source "$LIB_DIR/core.sh"
    source "$LIB_DIR/docker.sh"
    source "$LIB_DIR/python.sh"
    source "$LIB_DIR/tokens.sh"
    source "$LIB_DIR/services.sh"
    
    # Install dependencies
    log "Installing dependencies..."
    if [[ -f "setup.sh" ]]; then
        chmod +x setup.sh
        ./setup.sh
    else
        error "setup.sh not found!"
        exit 1
    fi
    
    # Setup tokens if not exists
    if ! check_tokens; then
        setup_tokens
    else
        info "Using existing tokens.json"
    fi
    
    # Generate config and start services
    generate_config || exit 1
    start_services
    show_status
}

# Handle script interruption
trap 'basic_error "Setup interrupted"; exit 1' INT TERM

# Run main function
main "$@"