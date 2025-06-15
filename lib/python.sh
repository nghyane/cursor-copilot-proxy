#!/usr/bin/env bash
# Python installation and dependency management

install_python_linux() {
    sudo apt-get update -qq
    sudo apt-get install -y python3 python3-pip python3-venv
}

install_python_macos() {
    if check_command brew; then
        brew install python
    else
        die "Homebrew required for macOS Python installation"
    fi
}

install_python() {
    if check_command python3; then
        success "Python3 already installed"
        return 0
    fi
    
    log "Installing Python3..."
    local os
    os=$(detect_os)
    
    case "$os" in
        ubuntu|debian) install_python_linux ;;
        macos) install_python_macos ;;
        *) die "Unsupported OS: $os" ;;
    esac
}

install_python_deps() {
    log "Installing Python dependencies..."
    
    # Check if jinja2 is installed
    if python3 -c "import jinja2" 2>/dev/null; then
        success "jinja2 already installed"
        return 0
    fi
    
    # Install jinja2
    python3 -m pip install --user jinja2 || \
        python3 -m pip install jinja2
    
    success "Python dependencies installed"
}

verify_python() {
    check_command python3 && python3 -c "import jinja2" 2>/dev/null
}