#!/usr/bin/env bash
# Dependency installer for Cursor Copilot Proxy
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Load core functions
source "$LIB_DIR/core.sh"
source "$LIB_DIR/docker.sh"
source "$LIB_DIR/python.sh"

verify_installation() {
    log "Verifying installation..."
    
    local all_good=true
    
    if ! check_command docker; then
        error "Docker installation failed"
        all_good=false
    fi
    
    if ! verify_python; then
        all_good=false
    fi
    
    if [[ "$all_good" == "true" ]]; then
        success "All dependencies installed successfully!"
        return 0
    else
        error "Some dependencies failed to install"
        return 1
    fi
}

main() {
    log "Starting dependency installation..."
    
    local os="$(detect_os)"
    log "Detected OS: $os"
    
    # Install Docker
    install_docker || exit 1
    
    # Install Python dependencies
    install_python_deps || exit 1
    
    # Set permissions
    chmod +x "$SCRIPT_DIR"/*.py 2>/dev/null || true
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
    chmod +x "$LIB_DIR"/*.sh 2>/dev/null || true
    
    verify_installation
}

main "$@"