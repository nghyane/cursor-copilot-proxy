#!/usr/bin/env bash
# Dependency installer for Cursor Copilot Proxy

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="$SCRIPT_DIR/lib"

# Load libraries
for lib in core docker python; do
    source "$LIB_DIR/$lib.sh"
done

main() {
    log "Starting dependency installation..."
    
    # Install Docker
    install_docker || die "Docker installation failed"
    
    # Install Python and dependencies
    install_python || die "Python installation failed"
    install_python_deps || die "Python dependencies installation failed"
    
    # Set permissions
    chmod +x "$SCRIPT_DIR"/*.py 2>/dev/null || true
    chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null || true
    
    # Verify installation
    log "Verifying installation..."
    verify_docker || die "Docker verification failed"
    verify_python || die "Python verification failed"
    
    success "All dependencies installed successfully!"
}

main "$@"