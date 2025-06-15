#!/usr/bin/env bash
# Core utilities and shared functions

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}🔧${NC} $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
warn() { echo -e "${YELLOW}⚠️${NC} $1"; }
error() { echo -e "${RED}❌${NC} $1"; }
info() { echo -e "${PURPLE}📋${NC} $1"; }

# Utility functions
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                echo "${ID:-linux}"
            else
                echo "linux"
            fi
            ;;
        Darwin*) echo "macos" ;;
        *) echo "unknown" ;;
    esac
}

# Get script directory
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
}