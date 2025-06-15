#!/usr/bin/env bash
# One-command setup for Cursor Copilot Proxy

set -euo pipefail

readonly PROJECT_NAME="cursor-copilot-proxy"
readonly REPO_URL="https://github.com/nghyane/cursor-copilot-proxy.git"

# Determine script directory
if [[ -f "lib/core.sh" ]]; then
    SCRIPT_DIR="$(pwd)"
else
    SCRIPT_DIR=""
fi

readonly LIB_DIR="$SCRIPT_DIR/lib"

# Basic logging for initial setup
basic_log() { echo "🔧 $*"; }
basic_success() { echo "✅ $*"; }
basic_error() { echo "❌ $*"; }

setup_project() {
    basic_log "Setting up project..."
    
    if [[ ! -d "$PROJECT_NAME" ]]; then
        git clone "$REPO_URL" "$PROJECT_NAME"
    else
        cd "$PROJECT_NAME"
        [[ -d ".git" ]] && git pull origin main || true
        cd ..
    fi
    
    cd "$PROJECT_NAME"
    basic_success "Project ready"
}

main() {
    echo ""
    basic_success "🚀 Cursor Copilot Proxy - Quick Setup"
    echo ""
    
    # Setup project if needed
    [[ ! -f "lib/core.sh" ]] && setup_project
    
    # Load all libraries
    for lib in core docker python tokens services; do
        source "$LIB_DIR/$lib.sh"
    done
    
    # Run setup
    ./setup.sh
    
    # Setup tokens
    check_tokens || setup_tokens
    
    # Start services
    generate_config && start_services
    show_status
}

trap 'basic_error "Setup interrupted"; exit 1' INT TERM
main "$@"