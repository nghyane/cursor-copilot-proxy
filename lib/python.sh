#!/usr/bin/env bash
# Python installation and dependencies

source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

install_python() {
    if check_command python3; then
        success "Python3 is already installed"
        return 0
    fi
    
    log "Installing Python3..."
    local os="$(detect_os)"
    
    case "$os" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y python3 python3-pip
            ;;
        macos)
            if check_command brew; then
                brew install python
            else
                error "Please install Homebrew first"
                return 1
            fi
            ;;
        *)
            error "Unsupported OS for Python installation: $os"
            return 1
            ;;
    esac
}

install_python_deps() {
    log "Installing Python dependencies..."
    
    # Ensure python3 is available
    install_python || return 1
    
    # Install jinja2
    if ! python3 -c "import jinja2" 2>/dev/null; then
        log "Installing jinja2..."
        python3 -m pip install --user jinja2
    else
        success "jinja2 is already installed"
    fi
}

verify_python() {
    local all_good=true
    
    if ! check_command python3; then
        error "Python3 not found"
        all_good=false
    fi
    
    if ! python3 -c "import jinja2" 2>/dev/null; then
        error "jinja2 not available"
        all_good=false
    fi
    
    if [[ "$all_good" == "true" ]]; then
        success "Python dependencies verified"
        return 0
    else
        return 1
    fi
}