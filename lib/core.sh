#!/usr/bin/env bash
# Core utilities and shared functions

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Icons
readonly ICON_INFO="🔧"
readonly ICON_SUCCESS="✅"
readonly ICON_WARN="⚠️"
readonly ICON_ERROR="❌"
readonly ICON_ROCKET="🚀"

# Logging functions
log() { echo -e "${BLUE}${ICON_INFO}${NC} $*"; }
success() { echo -e "${GREEN}${ICON_SUCCESS}${NC} $*"; }
warn() { echo -e "${YELLOW}${ICON_WARN}${NC} $*"; }
error() { echo -e "${RED}${ICON_ERROR}${NC} $*"; }
info() { echo -e "${PURPLE}📋${NC} $*"; }

# Utility functions
check_command() {
    command -v "$1" >/dev/null 2>&1
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

# Error handling
die() {
    error "$*"
    exit 1
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Spinner for long operations
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [[ "$(ps a | awk '{print $1}' | grep $pid)" ]]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}